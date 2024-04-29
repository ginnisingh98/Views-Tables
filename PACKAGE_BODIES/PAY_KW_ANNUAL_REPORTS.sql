--------------------------------------------------------
--  DDL for Package Body PAY_KW_ANNUAL_REPORTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KW_ANNUAL_REPORTS" AS
/* $Header: pykwyear.pkb 120.36.12010000.12 2019/03/19 13:37:06 somdhar ship $ */

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

  -------------------------------------------------------------------------
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

  PROCEDURE report55
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
     AND    org_information_context = 'KW_BG_DETAILS';

    /* Cursor for fetching Defined balance ids from Org EIT */
        CURSOR csr_get_def_bal_ids (l_emp_id number) IS
        SELECT  ORG_INFORMATION1
        FROM    HR_ORGANIZATION_INFORMATION
        WHERE   Organization_id = l_emp_id
        AND	org_information_context = 'KW_SI_DETAILS';

     /* Cursor for fetching Defined balance ids from Org EIT for Bonus which is stored in org_information2 Oct 2012 */
        CURSOR csr_get_def_bal_ids_b (l_emp_id number) IS
        SELECT  ORG_INFORMATION2
        FROM    HR_ORGANIZATION_INFORMATION
        WHERE   Organization_id = l_emp_id
        AND	org_information_context = 'KW_SI_DETAILS';

    /*Cursor for fetching Employer SSN*/
    CURSOR csr_employer_ssn IS
    SELECT LPAD(org_information4,9,'0')
    FROM   hr_organization_information
    WHERE  organization_id = p_employer_id
    AND    org_information_context = 'KW_LEGAL_EMPLOYER_DETAILS';

    /*Cursor for fetching Employer Civil Identifier - added Oct 2012*/
    CURSOR csr_employer_civilid IS
    SELECT LPAD(org_information6,8,'0')
    FROM   hr_organization_information
    WHERE  organization_id = p_employer_id
    AND    org_information_context = 'KW_LEGAL_EMPLOYER_DETAILS';


    /*Cursor for fetching Employer Name*/
    CURSOR csr_employer_name IS
    SELECT name
    FROM   hr_organization_units
    WHERE  organization_id = p_employer_id;

    /*Cursor for fetching defined balance id*/
    CURSOR csr_get_def_bal_id(p_user_name VARCHAR2)  IS
    SELECT  u.creator_id
    FROM    ff_user_entities  u,
            ff_database_items d
    WHERE   d.user_name = p_user_name
    AND     u.user_entity_id = d.user_entity_id
    AND     u.legislation_code = 'KW'
    AND     u.business_group_id is null
    AND     u.creator_type = 'B';

    /*Cursor for fetching list of employees*/
    CURSOR csr_get_emp (l_employer_id number, l_date date , l_nat varchar2) IS
    SELECT distinct asg.person_id
    		    ,asg.assignment_id
                    ,paa.assignment_action_id
    FROM   per_assignments_f asg
           ,pay_assignment_actions paa
           ,pay_payroll_actions ppa
           ,hr_soft_coding_keyflex hscl
           ,per_people_f ppf
    WHERE  asg.assignment_id = paa.assignment_id
    AND    paa.payroll_action_id = ppa.payroll_action_id
    AND    ppa.action_type in ('R','Q')
    AND    ppa.action_status = 'C'
    AND    paa.action_status in ('C','S')
    AND    trunc(ppa.date_earned,'MM') = TRUNC(l_date, 'MM')
    AND    trunc(l_date, 'MM') between trunc(asg.effective_start_date,'MM') and asg.effective_end_date
    AND    hscl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
    AND    hscl.segment1 = to_char(l_employer_id)
    AND    ppf.person_id = asg.person_id
    AND    trunc(l_date, 'MM') between trunc(ppf.effective_start_date,'MM') and ppf.effective_end_date
    AND    ppf.nationality = l_nat;
    rec_get_emp        csr_get_emp%ROWTYPE;

    /* Cursor to fetch first assignment_action_id and date earned for the employee */
    CURSOR csr_get_first_assact (l_assignment_id number,l_date date) IS
    select decode(trunc(ppa.date_earned,'YYYY'),trunc(l_date,'YYYY'),trunc(l_date,'YYYY'),ppa.date_earned) , paa.assignment_action_id
    from pay_payroll_actions ppa, pay_assignment_actions paa
    Where paa.assignment_id = l_assignment_id
    and   paa.payroll_action_id = ppa.payroll_action_id
    and   ppa.action_type in ('R','Q')
    and   ppa.action_status = 'C'
    and   paa.action_status IN ('C','S')
    order by ppa.date_earned asc;

    /* Cursor to fetch phone and fax information of the employer */
    CURSOR csr_get_det_employer (l_type varchar2) IS
    select  	org_information3
    from 	hr_organization_information
    where	org_information_context = 'ORG_CONTACT_DETAILS'
    and		organization_id = p_employer_id
    and		org_information1 = l_type;

    /* Cursor for fetching person's phone details */
    CURSOR csr_p_phone_data (l_person_id number,l_ph_type varchar2,l_effective_date date) IS
    SELECT  pp.phone_number
    FROM    per_phones pp,per_people_f ppf
    WHERE   pp.parent_id = ppf.person_id
    AND     pp.phone_type = l_ph_type
    AND     ppf.person_id = l_person_id
    AND     l_effective_date between pp.date_from and nvl(pp.date_to,to_date('31-12-4712','DD-MM-YYYY'))
    AND     l_effective_date between ppf.effective_start_date and ppf.effective_end_date; -- Bug 17572074

    /* Cursor for fetching Employer's location_id */
    CURSOR csr_get_loc_id IS
    select   location_id
    from     hr_organization_units
    where    organization_id = p_employer_id
    and	     business_group_id = p_business_group_id;

    /* Cursor for fetching Employer's Address */
    CURSOR csr_get_address (l_location_id number) IS
    select   address_line_1 || decode(address_line_2,null,null,',') || address_line_2 , postal_code
    from     hr_locations
    where    location_id = l_location_id;

    /* Cursor for fetching person's full name */
    CURSOR csr_get_full_name (l_person_id number, l_effective_date date) IS
    SELECT	ppf.full_name
    FROM	per_people_f ppf
    WHERE	ppf.person_id = l_person_id
    AND		l_effective_date between ppf.effective_start_date and ppf.effective_end_date;

    /* Cursor for fetching the person's assignment data */
    CURSOR csr_p_asg_data (l_person_id number,l_effective_date date) IS
    SELECT hsck.segment2,paf.job_id
    FROM	per_assignments_f paf,hr_soft_coding_keyflex hsck
    WHERE 	paf.person_id = l_person_id
    AND     paf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
    AND     hsck.segment1 = p_employer_id
    AND	    l_effective_date between paf.effective_start_date and paf.effective_end_date
    AND     paf.primary_flag = 'Y'     -- Bug 17572074
    AND     paf.assignment_type = 'E'; -- Bug 17572074

    /* Cursor for fetching the person's job */
    CURSOR csr_p_job (l_person_id number,l_effective_date date) IS
    SELECT pjb.name
    FROM   per_assignments_f paf,per_jobs pjb
    WHERE  paf.person_id = l_person_id
    AND    pjb.job_id = paf.job_id
    AND    l_effective_date between paf.effective_start_date and paf.effective_end_date
    AND    paf.primary_flag = 'Y'  -- Bug 17572074
    AND    paf.assignment_type = 'E';  -- Bug 17572074

    /* Cursor to fetch assignment_action_ids and date earned for the employee TO CAPTURE SOCIAL ALLOWANCE */
    CURSOR csr_get_assact_first (l_assignment_id number,l_date date) IS
    select ppa.date_earned, paa.assignment_action_id
    from pay_payroll_actions ppa, pay_assignment_actions paa
    Where paa.assignment_id = l_assignment_id
    and   paa.payroll_action_id = ppa.payroll_action_id
    and   ppa.action_type in ('R','Q')
    and   ppa.action_status = 'C'
    and   paa.action_status IN ('C','S')
    and	  ppa.date_earned <= l_date
    order by ppa.date_earned ASC;

    /* Cursor to fetch assignment_action_id corresponding to first_date_earned to calculate social allowance */
    CURSOR csr_get_assact_one (l_assignment_id number,l_date date) IS
    select paa.assignment_action_id
    from pay_payroll_actions ppa, pay_assignment_actions paa
    Where paa.assignment_id = l_assignment_id
    and   paa.payroll_action_id = ppa.payroll_action_id
    and   ppa.action_type in ('R','Q')
    and   ppa.action_status = 'C'
    and   paa.action_status IN ('C','S')
    and	  trunc(ppa.date_earned,'MM') = trunc(l_date,'MM') ;

    TYPE assact_rec IS RECORD
    (person_id                 NUMBER
    ,assignment_id	       NUMBER
    ,assignment_action_id      NUMBER);
    TYPE t_assact_table IS TABLE OF assact_rec INDEX BY BINARY_INTEGER;
    t_store_assact   t_assact_table;


    l_postal_code varchar2(100);
    l_employer_name            hr_organization_units.name%TYPE;
    l_employer_ssn             NUMBER;
    l_employer_civilid         NUMBER; -- Oct 2012
    l_basic_social_id         NUMBER;
    l_supplementary_social_id          NUMBER;
    l_additional_social_id	       NUMBER;
    l_first_assact_id number;
    l_job_id number;
    l_def_bal_id number;

    l_first_date date;

    l_monthly_sal number(15,3);
    l_monthly_earning number(15,3);
    l_first_social number(15,3);
    l_total number(15,3);
    l_second_social number(15,3); /* added Oct 2012 */

    l_fm_l_monthly_sal varchar2(100);
    l_fm_l_first_social varchar2(100);
    l_fm_l_second_social varchar2(100); /* added Oct 2012 */
    l_fm_l_total varchar2(100);

    l_basic_si_base_val        NUMBER;
    l_supp_si_base_val         NUMBER;
    l_add_si_val               NUMBER;

    l_full_name varchar2(240);
    l_insured_ssn varchar2(100);
    l_job varchar2(100);

    l_effective_date           DATE;
    l_input_date                VARCHAR2(30);

    l_total_amount             NUMBER;

    l_fm_total_amount          VARCHAR2(50);
    l_effective_month          VARCHAR2(50);

    l_loc_id number;
    l_employer_address varchar2(400);
    l_employer_phone varchar2(100);
    l_employer_fax varchar2(100);
    l number;
    i number;
    j number;
    l_new_processed number;
    l_all_processed number;
    l_new_count number;

    l_basic_arrears_id number;
    l_supp_arrears_id number;
    l_add_arrears_id number;
    l_tot_earn_bal_id number;
    l_social_id number;
    l_bonus  number;

    l_first_date_earned date;
    l_assact_one number;
    l_first_assact number;
    l_loc_nat varchar2(100);

    l_user_format VARCHAR2(80);

  BEGIN


    set_currency_mask(p_business_group_id);

    l_input_date := '01-'||p_effective_month||'-'||p_effective_year;
    l_effective_date := last_day(to_date(l_input_date,'DD-MM-YYYY'));

    INSERT INTO fnd_sessions (session_id, effective_date)
    VALUES (userenv('sessionid'), l_effective_date);

    -- To clear the PL/SQL Table values.
    vXMLTable.DELETE;
    vCtr := 1;
    hr_utility.set_location('Entering report55 ',10);

    l_effective_month := hr_general.decode_lookup('KW_GREGORIAN_MONTH', p_effective_month);

    l_user_format := NVL(FND_PROFILE.VALUE('HR_LOCAL_OR_GLOBAL_NAME_FORMAT'),'G');

/*    vXMLTable(vCtr).TagName := 'month';
    vXMLTable(vCtr).TagValue := l_effective_month;
    vctr := vctr + 1;

    vXMLTable(vCtr).TagName := 'year';
    vXMLTable(vCtr).TagValue := p_effective_year;
    vctr := vctr + 1;
*/

   /*Fetch Local Nationality */
    OPEN csr_get_loc_nat;
    FETCH csr_get_loc_nat into l_loc_nat;
    CLOSE csr_get_loc_nat;

    /*Fetch Employer SSN*/
    OPEN csr_employer_ssn;
    FETCH csr_employer_ssn INTO l_employer_ssn;
    CLOSE csr_employer_ssn;

       /*Fetch Employer Civil Identifier - Oct 2012*/
    OPEN csr_employer_civilid;
    FETCH csr_employer_civilid INTO l_employer_civilid;
    CLOSE csr_employer_civilid;

/*    vXMLTable(vCtr).TagName := 'employer_ssn';
    vXMLTable(vCtr).TagValue := l_employer_ssn;
    vctr := vctr + 1;*/

    /*Fetch Employer Name*/
    OPEN csr_employer_name;
    FETCH csr_employer_name INTO l_employer_name;
    CLOSE csr_employer_name;

/*    vXMLTable(vCtr).TagName := 'employer_name';
    vXMLTable(vCtr).TagValue := l_employer_name;
    vctr := vctr + 1;*/

    /*Fetch Employer Address*/
    OPEN csr_get_loc_id;
    FETCH csr_get_loc_id INTO l_loc_id;
    CLOSE csr_get_loc_id;

    OPEN csr_get_address (l_loc_id);
    FETCH csr_get_address INTO l_employer_address,l_postal_code;
    CLOSE csr_get_address;

    OPEN csr_get_def_bal_id('TOTAL_EARNINGS_ASG_RUN');
    FETCH csr_get_def_bal_id into l_tot_earn_bal_id;
    CLOSE csr_get_def_bal_id;

    OPEN csr_get_def_bal_ids(p_employer_id);
    FETCH csr_get_def_bal_ids into l_social_id;
    CLOSE csr_get_def_bal_ids;

/* added Oct 2012 */
      OPEN csr_get_def_bal_ids_b(p_employer_id);
    FETCH csr_get_def_bal_ids_b into l_bonus;
    CLOSE csr_get_def_bal_ids_b;

 /*
    vXMLTable(vCtr).TagName := 'work_address';
    vXMLTable(vCtr).TagValue := l_employer_address;
    vctr := vctr + 1;

    vXMLTable(vCtr).TagName := 'postal_code';
    vXMLTable(vCtr).TagValue := l_postal_code;
    vctr := vctr + 1;
*/

    /*Fetch Employer Phone*/
    OPEN csr_get_det_employer('PHONE');
    FETCH csr_get_det_employer INTO l_employer_phone;
    CLOSE csr_get_det_employer;

/*
    vXMLTable(vCtr).TagName := 'work_phone';
    vXMLTable(vCtr).TagValue := l_employer_phone;
    vctr := vctr + 1;
*/

    /*Fetch Employer Fax*/
    OPEN csr_get_det_employer('FAX');
    FETCH csr_get_det_employer INTO l_employer_fax;
    CLOSE csr_get_det_employer;

/*
    vXMLTable(vCtr).TagName := 'work_fax';
    vXMLTable(vCtr).TagValue := l_employer_fax;
    vctr := vctr + 1;
*/

    i := 0;

    OPEN csr_get_emp(p_employer_id , l_effective_date ,l_loc_nat);
    LOOP
      FETCH csr_get_emp INTO rec_get_emp;
      EXIT WHEN csr_get_emp%NOTFOUND;
      i := i + 1;
      t_store_assact(i).person_id := rec_get_emp.person_id;
      t_store_assact(i).assignment_id := rec_get_emp.assignment_id;
      t_store_assact(i).assignment_action_id := rec_get_emp.assignment_action_id;
    END LOOP;
    CLOSE csr_get_emp;

    IF i > 0  THEN
      l_new_processed := 0;
    ELSE
      l_new_processed := 1;
    END IF;

    l_all_processed := 0;

    l := 1;

    j := 1;

    WHILE l_all_processed  <> 1 LOOP
        --Writing data for new employees
    l_new_count := 0;

            vXMLTable(vCtr).TagName := 'employer_name';
            vXMLTable(vCtr).TagValue := l_employer_ssn;
            vctr := vctr + 1;

            vXMLTable(vCtr).TagName := 'employer_ssn';  /*** Changed after demo ***/
            vXMLTable(vCtr).TagValue := l_employer_name;
            vctr := vctr + 1;

            vXMLTable(vCtr).TagName := 'employer_civilid';  /*** change for Oct 2012 ***/
            vXMLTable(vCtr).TagValue := l_employer_civilid;
            vctr := vctr + 1;

	    vXMLTable(vCtr).TagName := 'month';
	    vXMLTable(vCtr).TagValue := l_effective_month;
	    vctr := vctr + 1;

	    vXMLTable(vCtr).TagName := 'year';
	    vXMLTable(vCtr).TagValue := p_effective_year;
	    vctr := vctr + 1;

            vXMLTable(vCtr).TagName := 'Month';
            vXMLTable(vCtr).TagValue := l_effective_month;
            vctr := vctr + 1;

            vXMLTable(vCtr).TagName := 'Year';
            vXMLTable(vCtr).TagValue := p_effective_year;
            vctr := vctr + 1;


    	    vXMLTable(vCtr).TagName := 'work_address';
    	    vXMLTable(vCtr).TagValue := l_employer_address;
    	    vctr := vctr + 1;

    	    vXMLTable(vCtr).TagName := 'postal_code';
    	    vXMLTable(vCtr).TagValue := l_postal_code;
    	    vctr := vctr + 1;

    	    vXMLTable(vCtr).TagName := 'work_phone';
    	    vXMLTable(vCtr).TagValue := l_employer_phone;
    	    vctr := vctr + 1;

    	    vXMLTable(vCtr).TagName := 'work_fax';
    	    vXMLTable(vCtr).TagValue := l_employer_fax;
	    vctr := vctr + 1;

      WHILE j <= i LOOP

      OPEN csr_get_full_name(t_store_assact(j).person_id,l_effective_date);
      FETCH csr_get_full_name INTO l_full_name;
      CLOSE csr_get_full_name;

	l_full_name := null;

        l_full_name := hr_person_name.get_person_name
                       (p_person_id       => t_store_assact(j).person_id
                       ,p_effective_date  => l_effective_date
                       ,p_format_name     => 'FULL_NAME'
                       ,p_user_format_choice => l_user_format);

	/* Reset ssn */

	l_insured_ssn := null;
	l_job_id := null;

      OPEN csr_p_asg_data(t_store_assact(j).person_id, l_effective_date);
      FETCH csr_p_asg_data into l_insured_ssn,l_job_id;
      CLOSE csr_p_asg_data;

	/* Reset job */

	l_job := null;

      OPEN csr_p_job(t_store_assact(j).person_id, l_effective_date);
      FETCH csr_p_job into l_job;
      CLOSE csr_p_job;

      l_new_count := l_new_count+1;

      OPEN csr_get_first_assact (t_store_assact(j).assignment_id,l_effective_date);
      FETCH csr_get_first_assact into l_first_date,l_first_assact_id;
      CLOSE csr_get_first_assact;

      l_monthly_earning := pay_balance_pkg.get_value(l_tot_earn_bal_id,t_store_assact(j).assignment_action_id);

      OPEN csr_get_assact_first(t_store_assact(j).assignment_id,l_effective_date);
      FETCH csr_get_assact_first INTO l_first_date_earned,l_first_assact;
      CLOSE csr_get_assact_first;

      If trunc(l_first_date_earned,'MM') <> trunc(l_effective_date,'YYYY') then
	      If trunc(l_first_date_earned,'YYYY') < trunc(l_effective_date,'YYYY') then
		      l_first_date_earned := trunc(l_effective_date,'YYYY');
	      End If;
      End If;

l_assact_one := null;

      /* Get the assact id corresponding to the first_assact_date calculated above */
      OPEN csr_get_assact_one (t_store_assact(j).assignment_id,l_first_date_earned);
      FETCH csr_get_assact_one into l_assact_one;
      CLOSE csr_get_assact_one;

      If l_social_id is not null THEN
       	If l_assact_one is not null then
            l_first_social := pay_balance_pkg.get_value(l_social_id,l_assact_one);
	      Else
	     	l_first_social := 0;
	      End If;
      Else
            l_first_social := 0;
      End If;

/* added Oct 2012 */
     If l_bonus is not null THEN
       	If l_assact_one is not null then
            l_second_social := pay_balance_pkg.get_value(l_bonus,l_assact_one);
	      Else
	     	l_second_social := 0;
	      End If;
      Else
            l_second_social := 0;
      End If;

/*fnd_file.put_line(fnd_file.log,' l_first_social '|| l_first_social);
fnd_file.put_line(fnd_file.log,' l_assact_one '|| l_assact_one);
fnd_file.put_line(fnd_file.log,' l_social_id '|| l_social_id);*/

      l_monthly_sal := l_monthly_earning - (l_first_social+l_second_social) ; /* modified Oct 2012 */

      l_total := l_monthly_earning;

      l_fm_l_monthly_sal := to_char(l_monthly_sal,lg_format_mask);
      l_fm_l_first_social := to_char(l_first_social,lg_format_mask);
      l_fm_l_second_social := to_char(l_second_social,lg_format_mask); /* added Oct 2012 */
      l_fm_l_total := to_char(l_total,lg_format_mask);

      /** Populate the XML file **/

      vXMLTable(vCtr).TagName := 's_no_'||l;
      vXMLTable(vCtr).TagValue := l;
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'insured_ssn_'||l;
      vXMLTable(vCtr).TagValue := l_insured_ssn;
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'insured_name_'||l;
      vXMLTable(vCtr).TagValue := SUBSTR(l_full_name,1,60);
      vctr := vctr + 1;


      vXMLTable(vCtr).TagName := 'job_'||l;
      vXMLTable(vCtr).TagValue := substr(l_job,1,30);
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'monthly_sal_dinars_'||l;
      vXMLTable(vCtr).TagValue := substr(l_fm_l_monthly_sal,1,length(l_fm_l_monthly_sal)-4);
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'monthly_salary_fills_'||l;
      vXMLTable(vCtr).TagValue := substr(l_fm_l_monthly_sal,length(l_fm_l_monthly_sal)-2);
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'first_sal_dinars_'||l;
      vXMLTable(vCtr).TagValue := substr(l_fm_l_first_social,1,length(l_fm_l_first_social)-4);
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'first_salary_fills_'||l;
      vXMLTable(vCtr).TagValue := substr(l_fm_l_first_social,length(l_fm_l_first_social)-2);
      vctr := vctr + 1;

/* added Oct 2012 */

      vXMLTable(vCtr).TagName := 'second_sal_dinars_'||l;
      vXMLTable(vCtr).TagValue := substr(l_fm_l_second_social,1,length(l_fm_l_second_social)-4);
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'second_salary_fills_'||l;
      vXMLTable(vCtr).TagValue := substr(l_fm_l_second_social,length(l_fm_l_second_social)-2);
      vctr := vctr + 1;
/* end 2012 */

      vXMLTable(vCtr).TagName := 'total_sal_dinars_'||l;
      vXMLTable(vCtr).TagValue := substr(l_fm_l_total,1,length(l_fm_l_total)-4);
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'total_salary_fills_'||l;
      vXMLTable(vCtr).TagValue := substr(l_fm_l_total,length(l_fm_l_total)-2);
      vctr := vctr + 1;

      j := j + 1;

      l := l + 1;

      IF j > i THEN
        l_all_processed := 1;
      END IF;

      IF l_new_count = 14 THEN
      	l := 1;


	vXMLTable(vCtr).TagName := 'PAGE-BK';
	vXMLTable(vCtr).TagValue := '    ';
      	vctr := vctr + 1;

        EXIT;
      END IF;
     END LOOP;

      IF j > i THEN
        l_new_processed := 1;
        EXIT;
      END IF;
    END LOOP;

    hr_utility.set_location('Finished creating xml data for Procedure report166 ',20);

    WritetoCLOB ( l_xfdf_blob );

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

  END report55;
------------------------------------------------------------------------------------

  PROCEDURE report56
    (p_request_id              NUMBER
    ,p_report                  VARCHAR2
    ,p_business_group_id       NUMBER
    ,p_employer_id             NUMBER
    ,p_effective_month         VARCHAR2
    ,p_effective_year          VARCHAR2
    ,p_assignment_id	       NUMBER DEFAULT NULL
    ,l_xfdf_blob               OUT NOCOPY BLOB
    )

   AS


    l_effective_date           DATE;

    /*Cursor for fetching Local nationality for the BG */
     CURSOR csr_get_loc_nat IS
     SELECT org_information1
     FROM   hr_organization_information
     WHERE  organization_id = p_business_group_id
     AND    org_information_context = 'KW_BG_DETAILS';

    /*Cursor for fetching Employer SSN*/
    CURSOR csr_employer_ssn IS
    SELECT LPAD(org_information4,9,'0')
    FROM   hr_organization_information
    WHERE  organization_id = p_employer_id
    AND    org_information_context = 'KW_LEGAL_EMPLOYER_DETAILS';

    /*Cursor for fetching Employer Name*/
    CURSOR csr_employer_name IS
    SELECT name
    FROM   hr_organization_units
    WHERE  organization_id = p_employer_id;

    /*Cursor for fetching defined balance id*/
    CURSOR csr_get_def_bal_id(p_user_name VARCHAR2)  IS
    SELECT  u.creator_id
    FROM    ff_user_entities  u,
            ff_database_items d
    WHERE   d.user_name = p_user_name
    AND     u.user_entity_id = d.user_entity_id
    AND     u.legislation_code = 'KW'
    AND     u.business_group_id is null
    AND     u.creator_type = 'B';

    /*Cursor for fetching list of employees*/
    CURSOR csr_get_emp (l_employer_id number , l_date date , l_nat varchar2) IS
    SELECT distinct asg.person_id
    		    ,asg.assignment_id
                    ,paa.assignment_action_id
                    ,ppa.date_earned
    FROM   per_assignments_f asg
           ,pay_assignment_actions paa
           ,pay_payroll_actions ppa
           ,hr_soft_coding_keyflex hscl
           ,per_people_f ppf
    WHERE  asg.assignment_id = paa.assignment_id
    AND    paa.payroll_action_id = ppa.payroll_action_id
    AND    ppa.action_type in ('R','Q')
    AND    ppa.action_status = 'C'
    AND    paa.action_status IN ('C','S')
    AND    trunc(ppa.date_earned,'MM') = TRUNC(l_date, 'MM')
    AND    trunc(l_date, 'MM') between trunc(asg.effective_start_date,'MM') and asg.effective_end_date
    AND    hscl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
    AND    hscl.segment1 = to_char(l_employer_id)
    AND    ppf.person_id = asg.person_id
    AND    trunc(l_date, 'MM') between trunc(ppf.effective_start_date,'MM') and ppf.effective_end_date
    AND    ppf.nationality = l_nat;
    rec_get_emp        csr_get_emp%ROWTYPE;

    /*Cursor for fetching person_id if employee is the parameter */
    CURSOR csr_get_emp_det (l_employer_id number, l_date date, l_nat varchar2) IS
    SELECT distinct asg.person_id
                    ,asg.assignment_id
                    ,paa.assignment_action_id
                    ,ppa.date_earned
    FROM   per_assignments_f asg
           ,pay_assignment_actions paa
           ,pay_payroll_actions ppa
           ,hr_soft_coding_keyflex hscl
           ,per_people_f ppf
    WHERE  asg.assignment_id = p_assignment_id
    AND	   asg.assignment_id = paa.assignment_id
    AND    paa.payroll_action_id = ppa.payroll_action_id
    AND    ppa.action_type in ('R','Q')
    AND    ppa.action_status = 'C'
    AND    paa.action_status IN ('C','S')
    AND    trunc(ppa.date_earned,'MM') = TRUNC(l_date, 'MM')
    AND    trunc(l_date, 'MM') between trunc(asg.effective_start_date,'MM') and asg.effective_end_date
    AND    hscl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
    AND    hscl.segment1 = to_char(l_employer_id)
    AND    ppf.person_id = asg.person_id
    AND    trunc(l_date, 'MM') between trunc(ppf.effective_start_date,'MM') and ppf.effective_end_date
    AND    ppf.nationality = l_nat;

    /*Cursor for fetching employee name*/
    CURSOR csr_get_emp_name(p_person_id NUMBER,l_format VARCHAR2) IS
   SELECT decode(l_format,'L',PER_INFORMATION3,SUBSTR(first_name,1,60)) first_name ,
          decode(l_format,'L',PER_INFORMATION4,SUBSTR(PER_INFORMATION1,1,60)) father_name ,
          decode(l_format,'L',PER_INFORMATION5,SUBSTR(PER_INFORMATION2,1,60)) grandfather_name,
          decode(l_format,'L',PER_INFORMATION6,SUBSTR(last_name,1,60)) last_name
    FROM   per_people_f ppf
    WHERE  person_id = p_person_id
    AND    l_effective_date BETWEEN effective_start_date AND effective_end_date;
    rec_get_emp_name   csr_get_emp_name%ROWTYPE;

    /* Cursor to fetch assignment_action_ids and date earned for the employee */
    CURSOR csr_get_assact (l_assignment_id number,l_date date) IS
    select ppa.date_earned, paa.assignment_action_id
    from pay_payroll_actions ppa, pay_assignment_actions paa
    Where paa.assignment_id = l_assignment_id
    and   paa.payroll_action_id = ppa.payroll_action_id
    and   ppa.action_type in ('R','Q')
    and   ppa.action_status = 'C'
    and   paa.action_status IN ('C','S')
    and	  ppa.date_earned <= l_date
    order by ppa.date_earned DESC;

    /* Cursor for fetching the person's assignment data */
    CURSOR csr_p_asg_data (l_person_id number,l_effective_date date) IS
    SELECT 	hsck.segment2
    FROM	per_assignments_f paf,hr_soft_coding_keyflex hsck
    WHERE 	paf.person_id = l_person_id
    AND    	paf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
    AND     	hsck.segment1 = p_employer_id
    AND	l_effective_date between paf.effective_start_date and paf.effective_end_date
    AND 	paf.primary_flag = 'Y'     -- Bug 17572074
    AND 	paf.assignment_type = 'E';  -- Bug 17572074

    /* Cursor to fetch termination details */
    CURSOR csr_get_term_details_56 (l_assignment_id number,l_date date) IS
    SELECT pos.actual_termination_date,pos.leaving_reason
    FROM per_periods_of_service pos , per_assignments_f paf
    WHERE  paf.assignment_id = l_assignment_id
    AND    paf.period_of_service_id = pos.period_of_service_id
    AND    trunc(pos.actual_termination_date,'MM') = trunc(l_date,'MM')
    AND    trunc(l_date,'MM') between trunc(paf.effective_start_date,'MM') and paf.effective_end_date;

    /* Cursor to fetch leaving reason meaning */
    CURSOR csr_fetch_leav_reas (l_code varchar2) IS
    SELECT meaning
    FROM hr_lookups
    WHERE lookup_type = 'LEAV_REAS'
    AND   lookup_code = l_code
    AND    enabled_flag = 'Y';

    /* Cursor to fetch hire date for an employee */
    CURSOR csr_get_hire_date_56(l_assignment_id number, l_date date) IS
    SELECT pos.date_start
    from  per_periods_of_service pos, per_assignments_f paf
    WHERE paf.assignment_id = l_assignment_id
    AND   paf.period_of_service_id = pos.period_of_service_id
    AND   trunc(pos.date_start,'MM') = trunc(l_date,'MM')
    AND   trunc(l_date,'MM') between trunc(paf.effective_start_date,'MM') and paf.effective_end_date;

    TYPE assact_rec IS RECORD
    (person_id                 NUMBER
    ,assignment_id             NUMBER
    ,assignment_action_id      NUMBER
    ,date_earned		DATE);
    TYPE t_assact_table IS TABLE OF assact_rec INDEX BY BINARY_INTEGER;
    t_store_assact   t_assact_table;

    TYPE store_rec IS RECORD
    (date_earned               date
    ,assignment_action_id      NUMBER
    ,supp_bal_value            number(15,3)
    ,tot_earn_value            number(15,3));
    TYPE t_store_table IS TABLE OF store_rec INDEX BY BINARY_INTEGER;
    t_store_recs   t_store_table;

    x number;
    y number;
    i number;
    j number;
    z number;
    v number;
    e number;

    l_employer_name varchar2(240);
    l_employer_ssn varchar2(100);
    l_full_name varchar2(240);
    l_input_date varchar2(100);
    l_supp_id number;

    l_emp varchar2(10);
    l_per_person_id	number;
    l_per_assact_id	number;
    l_per_date_earned	date;
    l_new_processed	number;
    l_all_processed	number;
    l_per_assignment_id number;
    l_emp_term_date	date;
    l_commencement_date	date;
    l_termination_date	date;
    l_last_sal_date	date;
    l_new_count 	number;
    l_insured_ssn	varchar2(100);
    l_current_supp_contri	number(15,3);
    l_fm_l_current_supp_contri	varchar2(100);

    l_temp_bal_value	number(15,3);

    l_supp_bal	number(15,3);
    l_termination	varchar2(10);
    l_rejoin	varchar2(10);
    l_new	varchar2(10);
    l_diff_exists	varchar2(10);
    l_first_name varchar2(120);
    l_father_name  varchar2(120);
    l_grand_name varchar2(120);
    l_last_name varchar2(120);
    l_loc_nat varchar2(100);
    l_tot_earn_id	number;
    l_tot_earn 	number(15,3);
    l_act_term_date_56 date;
    l_leav_reas varchar2(100);
    l_leav_reas_cd varchar2(30);
    l_hire_date_56 date;

    l_df_flag varchar2(10);

    l_user_format VARCHAR2(80);

  BEGIN

    set_currency_mask(p_business_group_id);

    l_input_date := '01-'||p_effective_month||'-'||p_effective_year;
    l_effective_date := last_day(to_date(l_input_date,'DD-MM-YYYY'));
    /*l_eff_term_date := to_date('28-'||to_char(l_effective_date,'MM-YYYY'),'DD-MM-YYYY');*/
    INSERT INTO fnd_sessions (session_id, effective_date)
    VALUES (userenv('sessionid'), l_effective_date);

       -- To clear the PL/SQL Table values.
       vXMLTable.DELETE;
       vCtr := 1;
       hr_utility.set_location('Entering FORM1 ',10);

	l_user_format := null;
	l_user_format := FND_PROFILE.VALUE('HR_LOCAL_OR_GLOBAL_NAME_FORMAT');

     /*Fetch Local Nationality */
     OPEN csr_get_loc_nat;
     FETCH csr_get_loc_nat into l_loc_nat;
     CLOSE csr_get_loc_nat;

       /*Fetch Employer SSN*/
       OPEN csr_employer_ssn;
       FETCH csr_employer_ssn INTO l_employer_ssn;
       CLOSE csr_employer_ssn;

       /*Fetch Employer Name*/
       OPEN csr_employer_name;
       FETCH csr_employer_name INTO l_employer_name;
       CLOSE csr_employer_name;


       OPEN csr_get_def_bal_id('SUPPLEMENTARY_SOCIAL_INSURANCE_BASE_ASG_RUN');
       FETCH csr_get_def_bal_id into l_supp_id;
       CLOSE csr_get_def_bal_id;

       OPEN csr_get_def_bal_id('TOTAL_EARNINGS_ASG_RUN');
       FETCH csr_get_def_bal_id into l_tot_earn_id;
       CLOSE csr_get_def_bal_id;


       i := 0;
	l_df_flag := 'U';


       If p_assignment_id is null then

   	l_emp := 'N';

   	    OPEN csr_get_emp(p_employer_id , l_effective_date ,l_loc_nat);
   	    LOOP
   	      FETCH csr_get_emp INTO rec_get_emp;
   	      EXIT WHEN csr_get_emp%NOTFOUND;

   	      i := i + 1;

   	      t_store_assact(i).person_id := rec_get_emp.person_id;
   	      t_store_assact(i).assignment_id := rec_get_emp.assignment_id;
   	      t_store_assact(i).assignment_action_id := rec_get_emp.assignment_action_id;
   	      t_store_assact(i).date_earned := rec_get_emp.date_earned;
   	    END LOOP;
   	    CLOSE csr_get_emp;
        Else
        	l_emp := 'Y';

              OPEN csr_get_emp_det(p_employer_id, l_effective_date,l_loc_nat);
              FETCH csr_get_emp_det into l_per_person_id ,l_per_assignment_id, l_per_assact_id, l_per_date_earned;
              CLOSE csr_get_emp_det;

              If l_per_person_id is not null then
              	i := 1;
   	      	t_store_assact(i).person_id := l_per_person_id;
   	      	t_store_assact(i).assignment_id := p_assignment_id;
   	      	t_store_assact(i).assignment_action_id := l_per_assact_id;
   	      	t_store_assact(i).date_earned := l_per_date_earned;
   	      End If;

        End If;



       IF i > 0  THEN
         l_new_processed := 0;
       ELSE
         l_new_processed := 1;

       END IF;

       l_all_processed := 0;

           j := 1;



       WHILE j <= i LOOP

       l_new := null;
       l_termination := null;
       l_rejoin := null;
       l_termination_date := null;
       l_last_sal_date := null;
       l_father_name := null;
       l_grand_name := null;
       l_first_name := null;
       l_insured_ssn := null;

       l_act_term_date_56 := null;
       l_leav_reas := null;
       l_leav_reas_cd  := null;
       l_hire_date_56 := null;
       l_commencement_date := null;

       v := 1;

   	      OPEN csr_get_assact (t_store_assact(j).assignment_id,l_effective_date);
   	      LOOP
   		      FETCH csr_get_assact into t_store_recs(v).date_earned,t_store_recs(v).assignment_action_id;
   		      EXIT WHEN csr_get_assact%notfound;
   		      l_supp_bal := pay_balance_pkg.get_value(l_supp_id,t_store_recs(v).assignment_action_id);
                      l_tot_earn := pay_balance_pkg.get_value(l_tot_earn_id,t_store_recs(v).assignment_action_id);
   		      t_store_recs(v).supp_bal_value := l_supp_bal;
                      t_store_recs(v).tot_earn_value := l_tot_earn;
   		      v:= v + 1;
    	      END LOOP;

   	      CLOSE csr_get_assact;

   	      For x in t_store_recs.first..t_store_recs.last
   	      LOOP

   	      	e := t_store_recs.last;


   	      	y := x + 1;

   	      	If y > e then
   	      		l_new := 'Y';

   	      		EXIT;
   	      	End If;

   	      		If t_store_recs(x).supp_bal_value = 0 then
   	      			y := x + 1;

   	      			If t_store_recs(y).supp_bal_value > 0 or l_emp_term_date < t_store_recs(x).date_earned then
   	      				l_termination := 'Y';

					open csr_get_term_details_56(t_store_assact(j).assignment_id,l_effective_date);
					fetch csr_get_term_details_56 into l_act_term_date_56 , l_leav_reas_cd;
					close csr_get_term_details_56;

					If l_leav_reas_cd is not null then
						OPEN csr_fetch_leav_reas(l_leav_reas_cd);
						FETCH csr_fetch_leav_reas into l_leav_reas;
						CLOSE csr_fetch_leav_reas;
					Else
						l_leav_reas := null;
					End If;


					If l_act_term_date_56 is not null then
						l_termination_date := l_act_term_date_56;
					Else
	   	      				l_termination_date := last_day(add_months(t_store_recs(x).date_earned,-1));
					End If;

   	      				EXIT;
   	      			End if;
   	      		Else
   	      			y := x + 1;

   	      			If t_store_recs(y).supp_bal_value = 0 then
   	      				y := y + 1;
   	      				If y <= t_store_recs.last then

   	      					FOR z in y..t_store_recs.last
   	      					LOOP
   	      						l_temp_bal_value := t_store_recs(z).supp_bal_value;
   	      						If l_temp_bal_value > 0 then
   	      							l_rejoin := 'Y';
   	      							EXIT;
   	      						End If;
   	      					END LOOP;
   	      				Else
   	      					l_new := 'Y';
   	      				End If;
   	      			Else
   	      				l_new := 'N';
   	      				l_rejoin := 'N';
   	      			End If;


				If l_rejoin <>'Y' and l_new <> 'N' then
   	      				l_new := 'Y';
   	      				EXIT;
   	      			Else
   	      				EXIT;
				End If;

   	      		End If;
   	      	END LOOP;

   	      	l_diff_exists := 'N';

   	      For x in t_store_recs.first..t_store_recs.last
                 LOOP
   	        	If t_store_recs(x).supp_bal_value > 0 then
   	        		l_commencement_date := t_store_recs(x).date_earned; /* COMMENCEMENT DATE*/
   	        	End If;

   	        	y := x + 1;

   	        	If y > v-1 then
				If l_diff_exists <> 'Y' then
					l_last_sal_date := t_store_recs(x).date_earned; /* May require change */
				End If;

    		           EXIT;

			End If;

   	        	If (t_store_recs(x).tot_earn_value <> t_store_recs(y).tot_earn_value) and l_diff_exists <> 'Y' then
   	        		l_diff_exists := 'Y';
/*************************** change in last salary date logic , myay require change ***************************/
				l_last_sal_date := t_store_recs(x).date_earned; /* May require change */
-- /*****/       		l_last_sal_date := t_store_recs(y).date_earned;   /* LAST SALARY DATE */
   	        	End If;

                 END LOOP;

   	      l_new_count := l_new_count+1;

   	      OPEN csr_get_emp_name(t_store_assact(j).person_id,l_user_format);
   	      FETCH csr_get_emp_name INTO l_first_name,l_father_name,l_grand_name,l_last_name;
   	      CLOSE csr_get_emp_name;

   	      OPEN csr_p_asg_data (t_store_assact(j).person_id,l_effective_date);
   	      FETCH csr_p_asg_data  INTO l_insured_ssn;
   	      CLOSE csr_p_asg_data ;


   	      x := 1;

   	      l_current_supp_contri := t_store_recs(x).supp_bal_value;
   	      l_fm_l_current_supp_contri := to_char(l_current_supp_contri,lg_format_mask);

/*fnd_file.put_line(fnd_file.log,' new '|| l_new || ' rejoin ' || l_rejoin || ' term ' || l_termination || ' ' ||t_store_assact(j).assignment_action_id);   */

   	      /** Populate the XML file **/

	If   l_termination ='Y' OR (l_rejoin = 'Y' and l_current_supp_contri <>0 ) OR (l_new = 'Y' and l_current_supp_contri <> 0)  then

		l_df_flag := 'Y';

                 vXMLTable(vCtr).TagName := 'employer_ssn';
                 vXMLTable(vCtr).TagValue := l_employer_ssn;
                 vctr := vctr + 1;

                 vXMLTable(vCtr).TagName := 'employer_name';
                 vXMLTable(vCtr).TagValue := l_employer_name;
                 vctr := vctr + 1;

   	        vXMLTable(vCtr).TagName := 'insured_last';
   	        vXMLTable(vCtr).TagValue := l_last_name;
   	        vctr := vctr + 1;

                vXMLTable(vCtr).TagName := 'insured_grand';
                vXMLTable(vCtr).TagValue := l_father_name;
                vctr := vctr + 1;

                vXMLTable(vCtr).TagName := 'insured_father';
                vXMLTable(vCtr).TagValue := l_grand_name;
                vctr := vctr + 1;

                vXMLTable(vCtr).TagName := 'insured_first';
                vXMLTable(vCtr).TagValue := l_first_name;
                vctr := vctr + 1;



   	      vXMLTable(vCtr).TagName := 'insured_ssn';
   	      vXMLTable(vCtr).TagValue := l_insured_ssn;
   	      vctr := vctr + 1;

   	      If l_termination = 'Y' then
   			vXMLTable(vCtr).TagName := 'application_type';
   	      		vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','TERM_56');
   	      		vctr := vctr + 1;
   	      ElsIf l_rejoin = 'Y' then
   			vXMLTable(vCtr).TagName := 'application_type';
                        vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','REJOIN_56');
/*   	      		vXMLTable(vCtr).TagValue := 'Rejoining of Complementary Contribution'; */
   	      		vctr := vctr + 1;
   	      ElsIf l_new = 'Y' then
   			vXMLTable(vCtr).TagName := 'application_type';
                        vXMLTable(vCtr).TagValue := get_lookup_meaning('KW_FORM_LABELS','NEW_56');
/*   	      		vXMLTable(vCtr).TagValue := 'Commencement of Complimentary Contribution'; */
   	      		vctr := vctr + 1;

			l_last_sal_date := t_store_assact(j).date_earned;

			OPEN csr_get_hire_date_56 (t_store_assact(j).assignment_id , l_effective_date);
			FETCH csr_get_hire_date_56 into l_hire_date_56;
			CLOSE csr_get_hire_date_56;

			If trunc(l_hire_date_56,'MM') = trunc(l_effective_date,'MM') then
				l_commencement_date := l_hire_date_56;
			End If;

   	      End If;

   	      vXMLTable(vCtr).TagName := 'commencement_day';
   	      vXMLTable(vCtr).TagValue := to_char(l_commencement_date,'DD');
   	      vctr := vctr + 1;

   	      vXMLTable(vCtr).TagName := 'commencement_month';
   	      vXMLTable(vCtr).TagValue := to_char(l_commencement_date,'MM');
   	      vctr := vctr + 1;

   	      vXMLTable(vCtr).TagName := 'commencement_year';
   	      vXMLTable(vCtr).TagValue := to_char(l_commencement_date,'YYYY');
   	      vctr := vctr + 1;

   	      vXMLTable(vCtr).TagName := 'supplementary_dinars';
   	      vXMLTable(vCtr).TagValue := substr(l_fm_l_current_supp_contri,1,length(l_fm_l_current_supp_contri)-4);
   	      vctr := vctr + 1;

   	      vXMLTable(vCtr).TagName := 'supplementary_fills';
   	      vXMLTable(vCtr).TagValue := substr(l_fm_l_current_supp_contri,length(l_fm_l_current_supp_contri)-2);
   	      vctr := vctr + 1;

   	      vXMLTable(vCtr).TagName := 'total_dinars';
   	      vXMLTable(vCtr).TagValue := substr(l_fm_l_current_supp_contri,1,length(l_fm_l_current_supp_contri)-4);
   	      vctr := vctr + 1;

   	      vXMLTable(vCtr).TagName := 'total_fills';
   	      vXMLTable(vCtr).TagValue := substr(l_fm_l_current_supp_contri,length(l_fm_l_current_supp_contri)-2);
   	      vctr := vctr + 1;

   	      vXMLTable(vCtr).TagName := 'termination_day';
   	      vXMLTable(vCtr).TagValue := to_char(l_termination_date,'DD');
   	      vctr := vctr + 1;

   	      vXMLTable(vCtr).TagName := 'termination_month';
   	      vXMLTable(vCtr).TagValue := to_char(l_termination_date,'MM');
   	      vctr := vctr + 1;

   	      vXMLTable(vCtr).TagName := 'termination_year';
   	      vXMLTable(vCtr).TagValue := to_char(l_termination_date,'YYYY');
   	      vctr := vctr + 1;

              vXMLTable(vCtr).TagName := 'termination_reason';
              vXMLTable(vCtr).TagValue := l_leav_reas;
              vctr := vctr + 1;

   	      vXMLTable(vCtr).TagName := 'last_salary_day';
   	      vXMLTable(vCtr).TagValue := to_char(l_last_sal_date,'DD');
   	      vctr := vctr + 1;

   	      vXMLTable(vCtr).TagName := 'last_salary_month';
   	      vXMLTable(vCtr).TagValue := to_char(l_last_sal_date,'MM');
   	      vctr := vctr + 1;

   	      vXMLTable(vCtr).TagName := 'last_salary_year';
   	      vXMLTable(vCtr).TagValue := to_char(l_last_sal_date,'YYYY');
   	      vctr := vctr + 1;

   	      vXMLTable(vCtr).TagName := 'PAGE-BK';
   	      vXMLTable(vCtr).TagValue := '    ';
   	      vctr := vctr + 1;

   	End If;

   		t_store_recs.DELETE;

   	           j := j + 1;

         IF j > i THEN
           l_new_processed := 1;
           EXIT;
         END IF;
       END LOOP;

       hr_utility.set_location('Finished creating xml data for Procedure REPORT56 ',20);

	If l_df_flag <> 'Y' then
		fnd_file.put_line(fnd_file.log,get_lookup_meaning('KW_FORM_LABELS','NDF'));
	End If;

    WritetoCLOB ( l_xfdf_blob );


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

  END report56;
-------------------------------------------------------------------------------------------



  PROCEDURE report103
    (p_request_id              NUMBER
    ,p_report                  VARCHAR2
    ,p_business_group_id       NUMBER
    ,p_employer_id             NUMBER
    ,p_effective_month         VARCHAR2
    ,p_effective_year          VARCHAR2
    ,p_employee_id	       NUMBER DEFAULT NULL
    ,l_xfdf_blob               OUT NOCOPY BLOB
    )
   AS

    l_effective_date           DATE;

    /*Cursor for fetching Local nationality for the BG */
     CURSOR csr_get_loc_nat IS
     SELECT org_information1
     FROM   hr_organization_information
     WHERE  organization_id = p_business_group_id
     AND    org_information_context = 'KW_BG_DETAILS';

    /* Cursor for fetching Defined balance ids from Org EIT */
        CURSOR csr_get_def_bal_ids (l_emp_id number) IS
        SELECT  ORG_INFORMATION1
        FROM    HR_ORGANIZATION_INFORMATION
        WHERE   Organization_id = l_emp_id
        AND	org_information_context = 'KW_SI_DETAILS';

    /*Cursor for fetching Employer SSN*/
    CURSOR csr_employer_ssn IS
    SELECT LPAD(org_information4,9,'0')
    FROM   hr_organization_information
    WHERE  organization_id = p_employer_id
    AND    org_information_context = 'KW_LEGAL_EMPLOYER_DETAILS';

    /*Cursor for fetching Employer Name*/
    CURSOR csr_employer_name IS
    SELECT name
    FROM   hr_organization_units
    WHERE  organization_id = p_employer_id;

    /*Cursor for fetching defined balance id*/
    CURSOR csr_get_def_bal_id(p_user_name VARCHAR2)  IS
    SELECT  u.creator_id
    FROM    ff_user_entities  u,
            ff_database_items d
    WHERE   d.user_name = p_user_name
    AND     u.user_entity_id = d.user_entity_id
    AND     u.legislation_code = 'KW'
    AND     u.business_group_id is null
    AND     u.creator_type = 'B';

    /*Cursor for fetching list of new / terminated employees*/
    CURSOR csr_get_new_term_emp (l_date date, l_nat varchar2) IS
    SELECT distinct  asg.person_id
    		    ,asg.assignment_id
                    ,paa.assignment_action_id
                    ,ppa.date_earned
                    ,decode(trunc(NVL(pos.actual_termination_date, to_date('31-12-4712','DD-MM-YYYY')),'MM'),TRUNC(l_date, 'MM'),'Y','N') term_flag
    FROM   per_assignments_f asg
           ,pay_assignment_actions paa
           ,pay_payroll_actions ppa
           ,hr_soft_coding_keyflex hscl
           ,per_periods_of_service pos
           ,per_people_f ppf
    WHERE  asg.assignment_id = paa.assignment_id
    AND    paa.payroll_action_id = ppa.payroll_action_id
    AND    pos.period_of_service_id = asg.period_of_service_id
    AND    ppa.action_type in ('R','Q')
    AND    ppa.action_status = 'C'
    AND    paa.action_status IN ('C','S')
    AND    trunc(ppa.date_earned,'MM') = TRUNC(l_date, 'MM')
    AND (   trunc(NVL(pos.actual_termination_date, to_date('31-12-4712','DD-MM-YYYY')),'MM') = TRUNC(l_date, 'MM')
        OR    trunc(pos.date_start, 'MM') = trunc(l_date, 'MM') )
    AND    trunc(l_date, 'MM') between trunc(asg.effective_start_date,'MM') and asg.effective_end_date
    AND    hscl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
    AND    hscl.segment1 = to_char(p_employer_id)
    AND    ppf.person_id = asg.person_id
    AND    trunc(l_date, 'MM') between trunc(ppf.effective_start_date,'MM') and ppf.effective_end_date
    AND    ppf.nationality = l_nat;
    rec_get_emp        csr_get_new_term_emp%ROWTYPE;

    /*Cursor for fetching employee details */
    CURSOR csr_get_emp_details (p_person_id NUMBER,l_format VARCHAR2) IS
    SELECT decode(l_format,'L',PER_INFORMATION3,SUBSTR(first_name,1,60)),
	   decode(l_format,'L',PER_INFORMATION6,SUBSTR(last_name,1,60)),
           decode(l_format,'L',PER_INFORMATION4,per_information1),
           decode(l_format,'L',PER_INFORMATION5,per_information2),
           sex,date_of_birth, pos.date_start , national_identifier , per_information9,per_information10,
           fnd_date.canonical_to_date(per_information11)
    FROM   per_people_f ppf , per_periods_of_service pos, per_assignments_f paf
    WHERE  ppf.person_id = p_person_id
    AND    ppf.person_id = pos.person_id
    AND    l_effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
    AND    trunc(l_effective_date,'MM') between trunc(pos.date_start,'MM') and nvl(pos.actual_termination_date,to_date('31-12-4712','DD-MM-YYYY'))
    AND    paf.person_id = ppf.person_id					-- Bug 17572074
    AND    paf.primary_flag = 'Y'     					-- Bug 17572074
    AND    paf.assignment_type = 'E' 					-- Bug 17572074
    AND    paf.period_of_service_id = pos.period_of_service_id   			-- Bug 17572074
    AND    l_effective_date between paf.effective_start_date and paf.effective_end_date;  		-- Bug 17572074

    /* Cursor for fetching the person's assignment data */
    CURSOR csr_p_asg_data (l_person_id number,l_date date) IS
    SELECT 	hsck.segment2,job_id , fnd_date.canonical_to_date(hsck.segment3)
    FROM	per_assignments_f paf,hr_soft_coding_keyflex hsck
    WHERE 	paf.person_id = l_person_id
    AND    	paf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
    AND             hsck.segment1 = p_employer_id
    AND	l_date between paf.effective_start_date and paf.effective_end_date
    AND 	paf.primary_flag = 'Y'     -- Bug 17572074
    AND 	paf.assignment_type = 'E';  -- Bug 17572074

    CURSOR csr_p_gender (l_sex varchar2) IS
    SELECT hl.meaning
    FROM	hr_lookups hl
    WHERE 	hl.lookup_type = 'SEX'
    AND		hl.lookup_code = l_sex
    AND		hl.enabled_flag = 'Y';

    /* Cursor for fetching the job */
    CURSOR csr_p_job (l_job varchar2 ,l_date date) IS
    SELECT 	name
    FROM	per_jobs
    WHERE 	job_id = l_job
    AND		l_date between date_from and nvl(date_to, to_date('31-12-4712','dd-mm-yyyy'));

    /* Cursor for fetching person's Address */
    CURSOR csr_p_address_data (l_person_id number,l_date date) IS
    SELECT  substr(addr.ADDRESS_LINE1 || ' ' ||addr.address_line2,1,120)
    FROM    per_addresses addr
    WHERE   addr.person_id = l_person_id
    AND     l_date between addr.date_from and nvl(addr.date_to,to_date('31-12-4712','dd-mm-yyyy'))
    AND     addr.primary_flag = 'Y';

    /* Cursor to fetch assignment_action_ids and date earned for the employee TO CAPTURE LAST SALARY DATE */
    CURSOR csr_get_assact_de (l_assignment_id number,l_date date) IS
    select ppa.date_earned, paa.assignment_action_id
    from pay_payroll_actions ppa, pay_assignment_actions paa
    Where paa.assignment_id = l_assignment_id
    and   paa.payroll_action_id = ppa.payroll_action_id
    and   ppa.action_type in ('R','Q')
    and   ppa.action_status = 'C'
    and   paa.action_status IN ('C','S')
    and	  ppa.date_earned <= l_date
    order by ppa.date_earned DESC;

    /* Cursor to fetch assignment_action_ids and date earned for the employee TO CAPTURE SOCIAL ALLOWANCE */
    CURSOR csr_get_assact_first (l_assignment_id number,l_date date) IS
    select ppa.date_earned, paa.assignment_action_id
    from pay_payroll_actions ppa, pay_assignment_actions paa
    Where paa.assignment_id = l_assignment_id
    and   paa.payroll_action_id = ppa.payroll_action_id
    and   ppa.action_type in ('R','Q')
    and   ppa.action_status = 'C'
    and   paa.action_status IN ('C','S')
    and	  ppa.date_earned <= l_date
    order by ppa.date_earned ASC;

    /* Cursor to fetch assignment_action_id corresponding to first_date_earned to calculate social allowance */
    CURSOR csr_get_assact_one (l_assignment_id number,l_date date) IS
    select paa.assignment_action_id
    from pay_payroll_actions ppa, pay_assignment_actions paa
    Where paa.assignment_id = l_assignment_id
    and   paa.payroll_action_id = ppa.payroll_action_id
    and   ppa.action_type in ('R','Q')
    and   ppa.action_status = 'C'
    and   paa.action_status IN ('C','S')
    and	 trunc(ppa.date_earned,'MM') = trunc(l_date,'MM') ;

    /* Cursor for fetching all deduction details UNION additional SI */
    CURSOR csr_get_ded_details (l_assignment_id number , l_assignment_action_id number, l_effective_date date) IS
    SELECT rrv.RESULT_VALUE val,pee.entry_information1 ref,pee.entry_information2 authority,pee.entry_information3 type,
           pee.entry_information4 debt,fnd_date.canonical_to_date(pee.entry_information5) start_d
           ,fnd_date.canonical_to_date(pee.entry_information6) end_d ,pet.element_type_id
    FROM 	pay_element_types_f 	pet,
    		pay_element_entries_f 	pee,
    		pay_run_results		prr,
    		pay_run_result_values	rrv,
		pay_input_values_f      piv
    WHERE  	rrv.RUN_RESULT_ID = prr.RUN_RESULT_ID
	    	AND prr.assignment_action_id = l_assignment_action_id
    	   	AND prr.ELEMENT_ENTRY_ID = pee.ELEMENT_ENTRY_ID
                AND piv.element_type_id = pet.element_type_id
                AND piv.name = 'Pay Value'
                AND rrv.input_value_id = piv.input_value_id
    	   	AND pee.assignment_id = l_assignment_id
    	   	AND TRUNC(l_effective_date,'MM')  between trunc(pee.effective_start_date,'MM') and nvl(pee.effective_end_date,to_date('31-12-4712','DD-MM-YYYY'))
                AND TRUNC(l_effective_date,'MM')  between trunc(piv.effective_start_date,'MM') and nvl(piv.effective_end_date,to_date('31-12-4712','DD-MM-YYYY'))
    	   	AND pee.element_type_id = pet.element_type_id
		AND pee.entry_information3 is not null
    	        AND rrv.result_value is not null
    	        AND TRUNC(l_effective_date,'MM')  between trunc(pet.effective_start_date,'MM') and nvl(pet.effective_end_date,to_date('31-12-4712','DD-MM-YYYY'));
/*  Commented the code after Kuwait 167 report review
	UNION
    select distinct eev1.SCREEN_ENTRY_VALUE val, eev2.SCREEN_ENTRY_VALUE ref, eev3.SCREEN_ENTRY_VALUE authority, '72' type,
           eev4.SCREEN_ENTRY_VALUE debt,eev1.effective_start_date start_d,eev1.effective_end_date end_d, pet.element_type_id
    from   pay_element_entry_values_f eev1,
	   pay_element_types_f pet,
	   pay_element_entries_f pee,
	   pay_input_values_f piv1,
	   pay_input_values_f piv2,
	   pay_input_values_f piv3,
	   pay_input_values_f piv4,
	   pay_element_entry_values_f eev2,
	   pay_element_entry_values_f eev3,
	   pay_element_entry_values_f eev4
    where  pet.element_name = 'Additional Social Insurance Information'
	   AND 	pet.element_type_id = pee.element_type_id
	   AND	pee.assignment_id =  l_assignment_id
	   AND	pee.element_entry_id = eev1.element_entry_id
	   AND  PAY_PAYWSMEE_PKG.PROCESSED(pee.element_entry_id,pee.original_entry_id , pet.processing_type , pee.entry_type, l_effective_date) = 'Y'
	   AND	piv1.element_type_id = pet.element_type_id
	   AND	piv1.name = 'Amount'
	   AND	eev1.input_value_id = piv1.input_value_id
	   AND	TRUNC(l_effective_date,'MM')  between trunc(eev1.effective_start_date,'MM') and nvl(eev1.effective_end_date,to_date('31-12-4712','DD-MM-YYYY'))
	   AND	pee.element_entry_id = eev2.element_entry_id
	   AND	piv2.element_type_id = pet.element_type_id
	   AND	piv2.name = 'Reference Number'
	   AND	eev2.input_value_id = piv2.input_value_id
	   AND	TRUNC(l_effective_date,'MM')  between trunc(eev2.effective_start_date,'MM') and nvl(eev2.effective_end_date,to_date('31-12-4712','DD-MM-YYYY'))
	   AND	pee.element_entry_id = eev3.element_entry_id
	   AND	piv3.element_type_id = pet.element_type_id
	   AND	piv3.name = 'Deduction Authority'
	   AND	eev3.input_value_id = piv3.input_value_id
	   AND	TRUNC(l_effective_date,'MM')  between trunc(eev3.effective_start_date,'MM') and nvl(eev3.effective_end_date,to_date('31-12-4712','DD-MM-YYYY'))
	   AND	pee.element_entry_id = eev4.element_entry_id
	   AND	piv4.element_type_id = pet.element_type_id
	   AND	piv4.name = 'Total Deduction Amount'
	   AND	eev4.input_value_id = piv4.input_value_id
	   AND	TRUNC(l_effective_date,'MM')  between trunc(eev4.effective_start_date,'MM') and nvl(eev4.effective_end_date,to_date('31-12-4712','DD-MM-YYYY'))
	   AND	TRUNC(l_effective_date,'MM')  between trunc(pet.effective_start_date,'MM') and nvl(pet.effective_end_date,to_date('31-12-4712','DD-MM-YYYY'))
	   AND	TRUNC(l_effective_date,'MM')  between trunc(pee.effective_start_date,'MM') and nvl(pee.effective_end_date,to_date('31-12-4712','DD-MM-YYYY'))
	   AND	TRUNC(l_effective_date,'MM')  between trunc(piv1.effective_start_date,'MM') and nvl(piv1.effective_end_date,to_date('31-12-4712','DD-MM-YYYY'))
	   AND	TRUNC(l_effective_date,'MM')  between trunc(piv2.effective_start_date,'MM') and nvl(piv2.effective_end_date,to_date('31-12-4712','DD-MM-YYYY'))
	   AND	TRUNC(l_effective_date,'MM')  between trunc(piv3.effective_start_date,'MM') and nvl(piv3.effective_end_date,to_date('31-12-4712','DD-MM-YYYY'))
	   AND	TRUNC(l_effective_date,'MM')  between trunc(piv4.effective_start_date,'MM') and nvl(piv4.effective_end_date,to_date('31-12-4712','DD-MM-YYYY'));	*/

    /* Cursor for fetching termination date and reason */
    CURSOR csr_get_term_det (l_person_id number, l_date date) IS
    SELECT pos.actual_termination_date , pos.leaving_reason
    FROM   per_periods_of_service pos, per_assignments_f paf
    WHERE  pos.person_id = l_person_id
    AND    trunc(l_date,'MM') between trunc(pos.date_start,'MM') and nvl(actual_termination_date,to_date('31-12-4712','dd-mm-yyyy'))
    AND    paf.person_id = l_person_id				-- Bug 17572074
    AND    paf.primary_flag = 'Y'				-- Bug 17572074
    AND    paf.assignment_type = 'E'				-- Bug 17572074
    AND    paf.period_of_service_id = pos.period_of_service_id		-- Bug 17572074
    AND    l_effective_date between paf.effective_start_date and paf.effective_end_date;	-- Bug 17572074

    /* Cursor to fetch termination reason meaning */
    CURSOR csr_get_term_meaning (l_code varchar2) IS
    SELECT hl.meaning
    FROM hr_lookups hl
    WHERE hl.lookup_type = 'LEAV_REAS'
    AND hl.lookup_code = l_code
    AND hl.enabled_flag = 'Y';

    /* Cursor to fetch previous employer name */
    CURSOR csr_get_prev_emp_name (l_person_id number) IS
    SELECT  employer_name
    FROM    per_previous_employers
    WHERE   person_id = l_person_id
    ORDER by previous_employer_id DESC;

    /* Cursor to fetch deduction_type meaning */
    CURSOR csr_get_ded_meaning (L_TYPE VARCHAR2) IS
    SELECT  hl.meaning
    FROM    hr_lookups hl
    WHERE   hl.lookup_type = 'KW_DEDUCTION_CODES'
    AND     hl.lookup_code = l_type
    AND     hl.enabled_flag = 'Y';

    /* Cursor to fetch person id and termination flag when Employee is the parameter */
    CURSOR csr_get_per_term_data (l_asg_id number , l_date date , l_nat varchar2) IS
    SELECT	ppf.person_id , paf.assignment_id , decode(trunc(pos.actual_termination_date,'MM'),trunc(l_date,'MM'),'Y','N') , decode(trunc(pos.date_start,'MM'),trunc(l_date,'MM'),'Y','N')
    FROM	per_people_f ppf, per_periods_of_service pos , per_assignments_f paf
    WHERE	paf.assignment_id = l_asg_id
    AND		paf.person_id = ppf.person_id
    AND		paf.period_of_service_id = pos.period_of_service_id
    AND		paf.person_id = pos.person_id
    AND         ppf.nationality = l_nat
    AND		trunc(l_date,'MM') between trunc(paf.effective_start_date,'MM') and paf.effective_end_date
    AND		trunc(l_date,'MM') between trunc(ppf.effective_start_date,'MM') and ppf.effective_end_date
    AND		trunc(l_date,'MM') between trunc(pos.date_start,'MM') and nvl(pos.actual_termination_date,to_date('31-12-4712','dd-mm-yyyy'));

    /* Cursor to fetch assignment_action_id and date_earned if Employee is the parameter */
    CURSOR csr_get_emp_assact_data (l_assignment_id number,l_date date) IS
    select paa.assignment_action_id , ppa.date_earned
    from pay_payroll_actions ppa, pay_assignment_actions paa
    Where paa.assignment_id = l_assignment_id
    and   paa.payroll_action_id = ppa.payroll_action_id
    and   ppa.action_type in ('R','Q')
    and   ppa.action_status = 'C'
    and   paa.action_status IN ('C','S')
    and	  trunc(ppa.date_earned,'MM') = trunc(l_date,'MM') ;

   /* Cursor to fetch last sal date */
    CURSOR csr_get_last_sal_date(l_assignment_id number , l_date date) IS
    SELECT min(ppa.date_earned)
    FROM   pay_payroll_actions ppa, pay_assignment_actions paa
    WHERE  paa.assignment_id = l_assignment_id
    AND    paa.payroll_action_id = ppa.payroll_action_id
    and   ppa.action_type in ('R','Q')
    and   ppa.action_status = 'C'
    and   paa.action_status IN ('C','S')
    and   ppa.date_earned > l_date;

       /* cursor to fetch employee telephone details  Oct 2012 */
    CURSOR csr_p_phone_data (l_person_id number,l_ph_type varchar2,l_effective_date date) IS
    SELECT  pp.phone_number
    FROM    per_phones pp,per_people_f ppf
    WHERE   pp.parent_id = ppf.person_id
    AND     pp.phone_type = l_ph_type
    AND     ppf.person_id = l_person_id
    AND     l_effective_date between pp.date_from and nvl(pp.date_to,to_date('31-12-4712','DD-MM-YYYY'))
    AND     l_effective_date between ppf.effective_start_date and ppf.effective_end_date;		 -- Bug 17572074

     /*Cursor for fetch the nationality for the employee Oct 2012 */
     CURSOR csr_get_nationality (l_person_id number,l_date date) IS
  /*  SELECT paf.NATIONALITY
     FROM  per_all_people_f paf
     WHERE person_id = l_person_id
     AND   l_date between paf.effective_start_date and paf.effective_end_date; */
    SELECT hl.meaning
     FROM  per_all_people_f paf, hr_lookups hl
     WHERE person_id = l_person_id
     AND   l_date between paf.effective_start_date and paf.effective_end_date
     and  hl.lookup_type = 'NATIONALITY'
     and hl.enabled_flag = 'Y'
     and hl.LOOKUP_CODE = paf.nationality;

    TYPE assact_rec IS RECORD
    (person_id                 NUMBER
    ,assignment_id             NUMBER
    ,assignment_action_id      NUMBER
    ,date_earned		DATE
    ,term_flag                 VARCHAR2(1));
    TYPE t_assact_table IS TABLE OF assact_rec INDEX BY BINARY_INTEGER;
    t_store_assact   t_assact_table;

    l_input_date	varchar2(30);
    l_employer_ssn	varchar2(30);
    l_employer_name	varchar2(240);
    l_si_id	number;
    l_basic_social_id	number;
    l_supplementary_social_id	number;
    l_additional_social_id	number;
    l_supp_base_id	number;
    l_basic_arrears_id	number;
    l_supp_arrears_id	number;
    l_add_arrears_id	number;

    i number;
    l_new_processed	number;
    l_all_processed	number;
    j	number;

    l_first_name	varchar2(240);
    l_gender	varchar2(30);
    l_gender_meaning 	varchar2(30);
    l_per_address	varchar2(2000);
    l_insured_ssn	varchar2(30);
    l_job_cd	varchar2(30);
    l_job_meaning	varchar2(240);
    l_first_date_earned	date;
    l_last_name	varchar2(240);
    l_father_name	varchar2(240);
    l_grandfather_name	varchar2(240);
    l_subscription_date	date;
    l_first_assact	number;
    l_assact_one	number;
    l_first_social	number(15,3);
    l_curr_val	number(15,3);
    l_temp_date	date;
    l_temp_assact	number;
    l_diff_exists	varchar2(10);

    l_dob	date;
    l_subject_supp_val	number(15,3);
    l_temp_val	number(15,3);
    l_temp_per_date	date;
    l_term_per_reason_cd	varchar2(30);
    l_prev_emp_name	varchar2(240);
    l_start_date	date;
    l_diff_date	date;
    l_term_per_date	date;
    l_term_reason_cd	varchar2(100);
    l_term_reason_meaning	varchar2(100);
    l_application_type	varchar2(100);
    l_new_count	number;
    l_civil_id	varchar2(100);
    l_nat_number	varchar2(100);
    l_article_number	varchar2(100);
    l_nat_date date;
    l_ded_count	number;
    l_ded_val	number(15,3);
    l_ded_val_v varchar2(30);
    l_ded_type	varchar2(30);
    l_ded_meaning	varchar2(240);
    l_ded_authority	varchar2(240);
    l_ded_debt		varchar2(100);
    l_ded_start	date;
    l_ded_end	date;
    l_ded_ele_id	number;

    l_fl_l_curr_val varchar2(100);
    l_fl_l_first_social varchar2(100);
    l_fl_l_subject_supp_val varchar2(100);
    l_emp_person_id	number;
    l_emp_assact	number;
    l_emp_date_earned	date;
    l_emp_term_flag	varchar2(10);
    l_emp_new_flag	varchar2(10);
    l_social_id number;
    l_tot_earn_id number;
    l_ref_num varchar2(60);
    l_loc_nat varchar2(100);
    l_emp_asg_id number;
    l_tot_ded_count number := 0;
    l_csr_tot number := 0;

    l_df_flag varchar2(10);

    l_user_format VARCHAR2(80);

    l_phone_number varchar2(20);
    l_nationality varchar2(10);
    l_application_type_rb1 varchar2(10);
    l_application_type_rb2 varchar2(10);
    l_application_type_rb3  varchar2(10);

   BEGIN

     set_currency_mask(p_business_group_id);

     l_input_date := '01-'||p_effective_month||'-'||p_effective_year;
     l_effective_date := last_day(to_date(l_input_date,'DD-MM-YYYY'));
     /*l_eff_term_date := to_date('28-'||to_char(l_effective_date,'MM-YYYY'),'DD-MM-YYYY');*/
     INSERT INTO fnd_sessions (session_id, effective_date)
     VALUES (userenv('sessionid'), l_effective_date);

        -- To clear the PL/SQL Table values.
        vXMLTable.DELETE;
        vCtr := 1;
        hr_utility.set_location('Entering FORM1 ',10);

        l_user_format := null;
        l_user_format := FND_PROFILE.VALUE('HR_LOCAL_OR_GLOBAL_NAME_FORMAT');

        /*Fetch Local Nationality */
        OPEN csr_get_loc_nat;
        FETCH csr_get_loc_nat into l_loc_nat;
        CLOSE csr_get_loc_nat;

        OPEN csr_get_def_bal_ids(p_employer_id);
        FETCH csr_get_def_bal_ids into l_social_id;
        CLOSE csr_get_def_bal_ids;

	OPEN csr_get_def_bal_id('TOTAL_EARNINGS_ASG_RUN');
	FETCH csr_get_def_bal_id into l_tot_earn_id;
	CLOSE csr_get_def_bal_id;

	OPEN csr_get_def_bal_id('SUPPLEMENTARY_SOCIAL_INSURANCE_BASE_ASG_RUN');
	FETCH csr_get_def_bal_id into l_supp_base_id;
	CLOSE csr_get_def_bal_id;

/*      OPEN csr_get_def_bal_id('SUBJECT_TO_SOCIAL_INSURANCE_ASG_RUN');
        FETCH csr_get_def_bal_id into l_si_id;
        CLOSE csr_get_def_bal_id;

	OPEN csr_get_def_bal_id('EMPLOYEE_BASIC_SOCIAL_INSURANCE_ASG_RUN');
	FETCH csr_get_def_bal_id into l_basic_social_id ;
	CLOSE csr_get_def_bal_id;

	OPEN csr_get_def_bal_id('EMPLOYEE_SUPPLEMENTARY_SOCIAL_INSURANCE_ASG_RUN');
	FETCH csr_get_def_bal_id into l_supplementary_social_id ;
	CLOSE csr_get_def_bal_id;

	OPEN csr_get_def_bal_id('ADDITIONAL_SOCIAL_INSURANCE_ASG_RUN');
	FETCH csr_get_def_bal_id into l_additional_social_id;
	CLOSE csr_get_def_bal_id;


	OPEN csr_get_def_bal_id('EMPLOYEE_BASIC_SOCIAL_INSURANCE_ARREARS_ASG_RUN');
	FETCH csr_get_def_bal_id into l_basic_arrears_id;
	CLOSE csr_get_def_bal_id;

	OPEN csr_get_def_bal_id('EMPLOYEE_SUPPLEMENTARY_SOCIAL_INSURANCE_ARREARS_ASG_RUN');
	FETCH csr_get_def_bal_id into l_supp_arrears_id;
	CLOSE csr_get_def_bal_id;

	OPEN csr_get_def_bal_id('ADDITIONAL_SOCIAL_INSURANCE_ARREARS_ASG_RUN');
	FETCH csr_get_def_bal_id into l_add_arrears_id;
	CLOSE csr_get_def_bal_id;
*/

        i := 0;

        l_df_flag := 'U';

        If p_employee_id is not null then


        	OPEN csr_get_per_term_data (p_employee_id,l_effective_date, l_loc_nat);
        	FETCH csr_get_per_term_data into l_emp_person_id,l_emp_asg_id, l_emp_term_flag, l_emp_new_flag;
        	CLOSE csr_get_per_term_data;

        	OPEN csr_get_emp_assact_data (l_emp_asg_id , l_effective_date);
        	FETCH csr_get_emp_assact_data into l_emp_assact, l_emp_date_earned;
        	CLOSE csr_get_emp_assact_data;

        	If l_emp_person_id is not null then
       	        	i := i + 1;
        		t_store_assact(i).person_id := l_emp_person_id;
        		t_store_assact(i).assignment_id := l_emp_asg_id;
        		t_store_assact(i).assignment_action_id := l_emp_assact;
        		t_store_assact(i).date_earned := l_emp_date_earned;
        		t_store_assact(i).term_flag := l_emp_term_flag;
        	End If;

        Else

		OPEN csr_get_new_term_emp(l_effective_date , l_loc_nat);
		LOOP
			FETCH csr_get_new_term_emp INTO rec_get_emp;
			EXIT WHEN csr_get_new_term_emp%NOTFOUND;
			i := i + 1;
			t_store_assact(i).person_id := rec_get_emp.person_id;
			t_store_assact(i).assignment_id := rec_get_emp.assignment_id;
			t_store_assact(i).assignment_action_id := rec_get_emp.assignment_action_id;
		        t_store_assact(i).date_earned := rec_get_emp.date_earned;
		        t_store_assact(i).term_flag := rec_get_emp.term_flag;
		END LOOP;
		CLOSE csr_get_new_term_emp;
	End If;


        IF i > 0  THEN
          l_new_processed := 0;
        ELSE
          l_new_processed := 1;
        END IF;

        l_all_processed := 0;

	j := 1;

        WHILE j <= i LOOP


		/*Fetch Employer SSN*/
		OPEN csr_employer_ssn;
		FETCH csr_employer_ssn INTO l_employer_ssn;
		CLOSE csr_employer_ssn;

		/*Fetch Employer Name*/
		OPEN csr_employer_name;
		FETCH csr_employer_name INTO l_employer_name;
		CLOSE csr_employer_name;

		/* Reset grandfather name,father name,nat number etc */

		l_father_name:=null;
		l_first_name := null;
		l_last_name := null;
		l_grandfather_name := null;
		l_civil_id := null;
		l_nat_number := null;
		l_per_address := null;
		l_article_number := null;
		l_nat_date := null;


		OPEN csr_get_emp_details(t_store_assact(j).person_id,l_user_format);
		FETCH csr_get_emp_details INTO l_first_name,l_last_name,l_father_name,l_grandfather_name,l_gender,l_dob,l_start_date,l_civil_id, l_nat_number,l_article_number,l_nat_date;
		CLOSE csr_get_emp_details;

		OPEN csr_p_gender (l_gender);
		FETCH csr_p_gender INTO l_gender_meaning;
		CLOSE csr_p_gender;

    open csr_get_nationality(t_store_assact(j).person_id,l_effective_date);
    FETCH csr_get_nationality INTO l_nationality;
		CLOSE csr_get_nationality;

        /* added Oct 2012 */
   OPEN csr_p_phone_data(t_store_assact(j).person_id,'M',l_effective_date);
		FETCH csr_p_phone_data INTO l_phone_number;
		CLOSE csr_p_phone_data;


		OPEN csr_p_address_data (t_store_assact(j).person_id,l_effective_date);
		FETCH csr_p_address_data into l_per_address;
		CLOSE csr_p_address_data;

	/* Reset job */

		l_job_cd := null;
		l_subscription_date := null;
		l_insured_ssn := null;
		l_job_meaning := null;

		OPEN csr_p_asg_data (t_store_assact(j).person_id,l_effective_date);
		FETCH csr_p_asg_data  INTO l_insured_ssn,l_job_cd,l_subscription_date;
		CLOSE csr_p_asg_data ;

		OPEN csr_p_job (l_job_cd , l_effective_date);
		FETCH csr_p_job INTO l_job_meaning;
		CLOSE csr_p_job;

		OPEN csr_get_assact_first (t_store_assact(j).assignment_id,l_effective_date);
		FETCH csr_get_assact_first into l_first_date_earned, l_first_assact;
		CLOSE csr_get_assact_first;

		If trunc(l_first_date_earned,'MM') <> trunc(l_effective_date,'YYYY') then
			If trunc(l_first_date_earned,'YYYY') < trunc(l_effective_date,'YYYY') then
				l_first_date_earned := trunc(l_effective_date,'YYYY');
			End If;
		End If;

l_assact_one := null;

		/* Get the assact id corresponding to the first_assact_date calculated above */
		OPEN csr_get_assact_one (t_store_assact(j).assignment_id,l_first_date_earned);
		FETCH csr_get_assact_one into l_assact_one;
		CLOSE csr_get_assact_one;

		/* Get Social allowance */

		If l_social_id is not null then
			If l_assact_one is not null then
				l_first_social := pay_balance_pkg.get_value(l_social_id,l_assact_one);
			Else
				l_first_social := 0;
			End If;
		Else
			l_first_social := 0;
		End If;

		/* Get current salary */

		l_curr_val := pay_balance_pkg.get_value(l_tot_earn_id,t_store_assact(j).assignment_action_id);

		/* Get amount subject to supplementary_social_insurance */

		l_subject_supp_val := pay_balance_pkg.get_value(l_supp_base_id,t_store_assact(j).assignment_action_id);

		/* Get Last salary date */

		OPEN csr_get_assact_de (t_store_assact(j).assignment_id, l_effective_date);
		LOOP

			FETCH csr_get_assact_de into l_temp_date , l_temp_assact;
			EXIT WHEN csr_get_assact_de%NOTFOUND;
			l_diff_exists := 'N';

			l_temp_val := pay_balance_pkg.get_value(l_tot_earn_id,l_temp_assact);

			If l_curr_val <> l_temp_val then
				l_diff_exists := 'Y';
				OPEN csr_get_last_sal_date(t_store_assact(j).assignment_id,l_temp_date);
				FETCH csr_get_last_sal_date into l_diff_date;
				CLOSE csr_get_last_sal_date;

/************************May need some change ****************************/
-- 				l_diff_date := l_temp_date; /* LAST SALARY DATE EARNED */
				EXIT;
			End If;
		END LOOP;

		CLOSE csr_get_assact_de;

		If l_diff_exists <> 'Y' and l_diff_date is null then
			l_diff_date := l_temp_date;
		End If;

		If t_store_assact(j).term_flag = 'Y' then
			OPEN csr_get_term_det (t_store_assact(j).person_id , l_effective_date);
			FETCH csr_get_term_det into l_term_per_date, l_term_per_reason_cd;
			CLOSE csr_get_term_det;

			OPEN csr_get_term_meaning (l_term_per_reason_cd);
			FETCH csr_get_term_meaning INTO l_term_reason_meaning;
			CLOSE csr_get_term_meaning;
		Else
			l_term_per_date := null;
			l_term_reason_meaning := null;
		End If;

    	      	OPEN csr_get_prev_emp_name(t_store_assact(j).person_id);
    	      	FETCH csr_get_prev_emp_name INTO l_prev_emp_name;
    	      	CLOSE csr_get_prev_emp_name;



		l_new_count := l_new_count+1;

		l_fl_l_curr_val := to_char(l_curr_val,lg_format_mask);
		l_fl_l_first_social := to_char(l_first_social,lg_format_mask);
		l_fl_l_subject_supp_val := to_char(l_subject_supp_val,lg_format_mask);

		/** Populate the XML file **/

		If p_employee_id is not null and (l_emp_new_flag = 'N' and l_emp_term_flag = 'N')  then
			EXIT;
		End If;


	OPEN csr_get_ded_details(t_store_assact(j).assignment_id,t_store_assact(j).assignment_action_id,l_effective_date);
	LOOP
		FETCH csr_get_ded_details into l_ded_val , l_ref_num ,l_ded_authority, l_ded_type , l_ded_debt , l_ded_start , l_ded_end , l_ded_ele_id;
		EXIT WHEN csr_get_ded_details%NOTFOUND;
		l_tot_ded_count := l_tot_ded_count + 1;
	END LOOP;
	CLOSE csr_get_ded_details;

	l_ded_val := null;
	l_ref_num := null;
	l_ded_authority:= null;
	l_ded_type := null;
	l_ded_debt := null;
	l_ded_start := null;
	l_ded_end := null;
	l_ded_ele_id:= null;
	l_ded_val_v := null;
  l_application_type_rb1 := null;
    l_application_type_rb2 := null;
    l_application_type_rb3  := null;

    	        	If t_store_assact(j).term_flag = 'Y' then
/*    	        		l_application_type := 'Termination of service';*/ /******** To be taken from lookup ********/
				l_application_type := get_lookup_meaning('KW_FORM_LABELS','TERM_103');
				l_application_type_rb1 := '*';
    	        	ElsIf t_store_assact(j).term_flag = 'N' AND l_insured_ssn is not null then
/*    	        		l_application_type := 'Previously Subscripted';*/
                                l_application_type := get_lookup_meaning('KW_FORM_LABELS','PREV_103');
                	        l_diff_date := t_store_assact(j).date_earned;
				l_application_type_rb2 := '*';
    	        	Else
/*    	        		l_application_type := 'Commencement of Subscription';*/
                                l_application_type := get_lookup_meaning('KW_FORM_LABELS','NEW_103');
				l_diff_date := t_store_assact(j).date_earned;
				l_application_type_rb3 := '*';
    	        	End If;


				l_df_flag := 'Y';

     /*   if l_application_type = 'Previously Subscripted' then
           l_application_type_rb2 := '*';
        elsif l_application_type = 'Termination of service' then
            l_application_type_rb1 := '*';
        elsif l_application_type = 'Commencement of Subscription' then
              l_application_type_rb3 := '*';
       end if; */


				vXMLTable(vCtr).TagName := 'application_type';
				vXMLTable(vCtr).TagValue := l_application_type;
				vctr := vctr + 1;


				vXMLTable(vCtr).TagName := 'First_time_rb';   /* term */
				vXMLTable(vCtr).TagValue := l_application_type_rb1;
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'Second_time_rb';  /* prev sub */
				vXMLTable(vCtr).TagValue := l_application_type_rb2;
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'Third_time_rb'; /* new join */
				vXMLTable(vCtr).TagValue := l_application_type_rb3;
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'insured_name_first';
				vXMLTable(vCtr).TagValue := l_first_name;
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'insured_name_father';
				vXMLTable(vCtr).TagValue := l_father_name;
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'insured_name_grandfather';
				vXMLTable(vCtr).TagValue := l_grandfather_name;
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'insured_name_last';
				vXMLTable(vCtr).TagValue := l_last_name;
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'address';
				vXMLTable(vCtr).TagValue := l_per_address;
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'insured_ssn';
				vXMLTable(vCtr).TagValue := l_insured_ssn;
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'dob_day';
				vXMLTable(vCtr).TagValue := to_char(l_dob,'DD');
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'dob_month';
				vXMLTable(vCtr).TagValue := to_char(l_dob,'MM');
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'dob_year';
				vXMLTable(vCtr).TagValue := to_char(l_dob,'YYYY');
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'gender';
				vXMLTable(vCtr).TagValue := l_gender_meaning;
				vctr := vctr + 1;

        vXMLTable(vCtr).TagName := 'nationality';
				vXMLTable(vCtr).TagValue := l_nationality;
				vctr := vctr + 1;

         /* added for Oct 2012 */
        vXMLTable(vCtr).TagName := 'insured_tel_mob';
				vXMLTable(vCtr).TagValue := l_phone_number;
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'nationality_number';
				vXMLTable(vCtr).TagValue := l_nat_number;
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'article';
				vXMLTable(vCtr).TagValue := l_article_number;
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'nat_date_day';
				vXMLTable(vCtr).TagValue := to_char(l_nat_date,'DD');
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'nat_date_month';
				vXMLTable(vCtr).TagValue := to_char(l_nat_date,'MM');
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'nat_date_year';
				vXMLTable(vCtr).TagValue := to_char(l_nat_date,'YYYY');
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'civil_id';
				vXMLTable(vCtr).TagValue := l_civil_id;
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'employer_name';
				vXMLTable(vCtr).TagValue := l_employer_name;
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'employer_ssn';
				vXMLTable(vCtr).TagValue := l_employer_ssn;
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'hire_date_day';
				vXMLTable(vCtr).TagValue := to_char(l_start_date,'DD');
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'hire_date_month';
				vXMLTable(vCtr).TagValue := to_char(l_start_date,'MM');
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'hire_date_year';
				vXMLTable(vCtr).TagValue := to_char(l_start_date,'YYYY');
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'commencement_date_day';
				vXMLTable(vCtr).TagValue := to_char(l_subscription_date,'DD');
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'commencement_date_month';
				vXMLTable(vCtr).TagValue := to_char(l_subscription_date,'MM');
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'commencement_date_year';
				vXMLTable(vCtr).TagValue := to_char(l_subscription_date,'YYYY');
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'job';
				vXMLTable(vCtr).TagValue := substr(l_job_meaning,1,30);
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'total_salary_dinars';
				vXMLTable(vCtr).TagValue := substr(l_fl_l_curr_val,1,length(l_fl_l_curr_val)-4);
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'total_salary_fills';
				vXMLTable(vCtr).TagValue := substr(l_fl_l_curr_val,length(l_fl_l_curr_val)-2);
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'social_allowance_dinars';
				vXMLTable(vCtr).TagValue := substr(l_fl_l_first_social,1,length(l_fl_l_first_social)-4);
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'social_allowance_fills';
				vXMLTable(vCtr).TagValue := substr(l_fl_l_first_social,length(l_fl_l_first_social)-2);
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'subject_to_comp_dinars';
	/** commented    	vXMLTable(vCtr).TagValue := substr(l_fl_l_subject_supp_val,1,length(l_fl_l_subject_supp_val)-4);*/
        	                vXMLTable(vCtr).TagValue := ' ';
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'subject_to_comp_fills';
	/**commented            vXMLTable(vCtr).TagValue := substr(l_fl_l_subject_supp_val,length(l_fl_l_subject_supp_val)-2);*/
				vXMLTable(vCtr).TagValue := ' ';
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'last_salary_date';
				vXMLTable(vCtr).TagValue := to_char(l_diff_date,'YYYY/MM/DD');
				vctr := vctr + 1;

        vXMLTable(vCtr).TagName := 'last_salary_day';
				vXMLTable(vCtr).TagValue := to_char(l_diff_date,'DD');
				vctr := vctr + 1;

        vXMLTable(vCtr).TagName := 'last_salary_month';
				vXMLTable(vCtr).TagValue := to_char(l_diff_date,'MM');
				vctr := vctr + 1;

        vXMLTable(vCtr).TagName := 'last_salary_year';
				vXMLTable(vCtr).TagValue := to_char(l_diff_date,'YYYY');
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'term_date_day';
				vXMLTable(vCtr).TagValue := to_char(l_term_per_date,'DD');
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'term_date_month';
				vXMLTable(vCtr).TagValue := to_char(l_term_per_date,'MM');
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'term_date_year';
				vXMLTable(vCtr).TagValue := to_char(l_term_per_date,'YYYY');
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'termination_reason';
				vXMLTable(vCtr).TagValue := l_term_reason_meaning;
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'prev_employer';
				vXMLTable(vCtr).TagValue := l_prev_emp_name;
				vctr := vctr + 1;


	OPEN csr_get_ded_details(t_store_assact(j).assignment_id,t_store_assact(j).assignment_action_id,l_effective_date);
	LOOP
		l_ded_count := 1;

		--OPEN csr_get_ded_details(t_store_assact(j).assignment_id,t_store_assact(j).assignment_action_id,l_effective_date);
		LOOP
			FETCH csr_get_ded_details into l_ded_val , l_ref_num ,l_ded_authority, l_ded_type , l_ded_debt , l_ded_start , l_ded_end , l_ded_ele_id;
			EXIT WHEN csr_get_ded_details%NOTFOUND;

			l_csr_tot := l_csr_tot + 1;

			OPEN csr_get_ded_meaning (l_ded_type);
			FETCH csr_get_ded_meaning into l_ded_meaning;
			CLOSE csr_get_ded_meaning;

			vXMLTable(vCtr).TagName := 'ref_number_' || l_ded_count;
			vXMLTable(vCtr).TagValue := l_ref_num;
			vctr := vctr + 1;

			vXMLTable(vCtr).TagName := 'deduction_authority_' || l_ded_count;
			vXMLTable(vCtr).TagValue := l_ded_authority;
			vctr := vctr + 1;

			OPEN csr_get_ded_meaning(l_ded_type);
			FETCH csr_get_ded_meaning INTO l_ded_meaning;
			CLOSE csr_get_ded_meaning;

			vXMLTable(vCtr).TagName := 'deduction_type_' || l_ded_count;
			vXMLTable(vCtr).TagValue := substr(l_ded_meaning,1,30);
			vctr := vctr + 1;

			vXMLTable(vCtr).TagName := 'total_debt_' || l_ded_count;
			vXMLTable(vCtr).TagValue := l_ded_debt;
			vctr := vctr + 1;

			vXMLTable(vCtr).TagName := 'monthly_installment_' || l_ded_count;
			vXMLTable(vCtr).TagValue := to_char(l_ded_val,lg_format_mask);
			vctr := vctr + 1;

			vXMLTable(vCtr).TagName := 'deduction_start_date_' || l_ded_count;
			vXMLTable(vCtr).TagValue := l_ded_start;
			vctr := vctr + 1;

			vXMLTable(vCtr).TagName := 'deduction_end_date_' || l_ded_count;
			vXMLTable(vCtr).TagValue := l_ded_end;
			vctr := vctr + 1;

  /* added Oct 2012 */

      vXMLTable(vCtr).TagName := 'deduction_start_month_' || l_ded_count;
			vXMLTable(vCtr).TagValue := to_char(l_ded_start,'MM');
			vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'deduction_start_year_' || l_ded_count;
			vXMLTable(vCtr).TagValue := to_char(l_ded_start,'YYYY');
			vctr := vctr + 1;

			vXMLTable(vCtr).TagName := 'deduction_end_month_' || l_ded_count;
			vXMLTable(vCtr).TagValue := to_char(l_ded_end,'MM');
			vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'deduction_end_year_' || l_ded_count;
			vXMLTable(vCtr).TagValue := to_char(l_ded_end,'YYYY');
			vctr := vctr + 1;

			l_ded_count := l_ded_count + 1;

			If l_ded_count = 5 then

                		vXMLTable(vCtr).TagName := 'PAGE-BK';
	        	        vXMLTable(vCtr).TagValue := '    ';
		                vctr := vctr + 1;
				EXIT;
			End If;

		END LOOP;


	If (l_ded_count = 5 and l_ded_count <= l_tot_ded_count) then
    	        	If t_store_assact(j).term_flag = 'Y' then
    	        		l_application_type := 'Termination of service'; /******** To be taken from lookup ********/
                  l_application_type_rb1 := '*';
    	        	ElsIf t_store_assact(j).term_flag = 'N' AND l_insured_ssn is not null then
    	        		l_application_type := 'Previously Subscripted';
                	        l_diff_date := t_store_assact(j).date_earned;
                          l_application_type_rb2 := '*';
    	        	Else
    	        		l_application_type := 'Commencement of Subscription';
				l_diff_date := t_store_assact(j).date_earned;
         l_application_type_rb3 := '*';
    	        	End If;


				vXMLTable(vCtr).TagName := 'application_type';
				vXMLTable(vCtr).TagValue := l_application_type;
				vctr := vctr + 1;


				vXMLTable(vCtr).TagName := 'First_time_rb';   /* term */
				vXMLTable(vCtr).TagValue := l_application_type_rb1;
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'Second_time_rb';  /* prev sub */
				vXMLTable(vCtr).TagValue := l_application_type_rb2;
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'Third_time_rb'; /* new join */
				vXMLTable(vCtr).TagValue := l_application_type_rb3;
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'insured_name_first';
				vXMLTable(vCtr).TagValue := l_first_name;
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'insured_name_father';
				vXMLTable(vCtr).TagValue := l_father_name;
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'insured_name_grandfather';
				vXMLTable(vCtr).TagValue := l_grandfather_name;
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'insured_name_last';
				vXMLTable(vCtr).TagValue := l_last_name;
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'address';
				vXMLTable(vCtr).TagValue := l_per_address;
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'insured_ssn';
				vXMLTable(vCtr).TagValue := l_insured_ssn;
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'dob_day';
				vXMLTable(vCtr).TagValue := to_char(l_dob,'DD');
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'dob_month';
				vXMLTable(vCtr).TagValue := to_char(l_dob,'MM');
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'dob_year';
				vXMLTable(vCtr).TagValue := to_char(l_dob,'YYYY');
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'gender';
				vXMLTable(vCtr).TagValue := l_gender_meaning;
				vctr := vctr + 1;

         /* added for Oct 2012 */
        vXMLTable(vCtr).TagName := 'nationality';
				vXMLTable(vCtr).TagValue := l_nationality;
				vctr := vctr + 1;

                /* added for Oct 2012 */
        vXMLTable(vCtr).TagName := 'insured_tel_mob';
				vXMLTable(vCtr).TagValue := l_phone_number;
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'nationality_number';
				vXMLTable(vCtr).TagValue := l_nat_number;
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'article';
				vXMLTable(vCtr).TagValue := l_article_number;
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'nat_date_day';
				vXMLTable(vCtr).TagValue := to_char(l_nat_date,'DD');
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'nat_date_month';
				vXMLTable(vCtr).TagValue := to_char(l_nat_date,'MM');
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'nat_date_year';
				vXMLTable(vCtr).TagValue := to_char(l_nat_date,'YYYY');
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'civil_id';
				vXMLTable(vCtr).TagValue := l_civil_id;
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'employer_name';
				vXMLTable(vCtr).TagValue := l_employer_name;
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'employer_ssn';
				vXMLTable(vCtr).TagValue := l_employer_ssn;
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'hire_date_day';
				vXMLTable(vCtr).TagValue := to_char(l_start_date,'DD');
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'hire_date_month';
				vXMLTable(vCtr).TagValue := to_char(l_start_date,'MM');
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'hire_date_year';
				vXMLTable(vCtr).TagValue := to_char(l_start_date,'YYYY');
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'commencement_date_day';
				vXMLTable(vCtr).TagValue := to_char(l_subscription_date,'DD');
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'commencement_date_month';
				vXMLTable(vCtr).TagValue := to_char(l_subscription_date,'MM');
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'commencement_date_year';
				vXMLTable(vCtr).TagValue := to_char(l_subscription_date,'YYYY');
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'job';
				vXMLTable(vCtr).TagValue := substr(l_job_meaning,1,30);
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'total_salary_dinars';
				vXMLTable(vCtr).TagValue := substr(l_fl_l_curr_val,1,length(l_fl_l_curr_val)-4);
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'total_salary_fills';
				vXMLTable(vCtr).TagValue := substr(l_fl_l_curr_val,length(l_fl_l_curr_val)-2);
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'social_allowance_dinars';
				vXMLTable(vCtr).TagValue := substr(l_fl_l_first_social,1,length(l_fl_l_first_social)-4);
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'social_allowance_fills';
				vXMLTable(vCtr).TagValue := substr(l_fl_l_first_social,length(l_fl_l_first_social)-2);
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'subject_to_comp_dinars';
	/** commented    	vXMLTable(vCtr).TagValue := substr(l_fl_l_subject_supp_val,1,length(l_fl_l_subject_supp_val)-4);*/
        	                vXMLTable(vCtr).TagValue := ' ';
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'subject_to_comp_fills';
	/**commented            vXMLTable(vCtr).TagValue := substr(l_fl_l_subject_supp_val,length(l_fl_l_subject_supp_val)-2);*/
				vXMLTable(vCtr).TagValue := ' ';
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'last_salary_date';
				vXMLTable(vCtr).TagValue := to_char(l_diff_date,'YYYY/MM/DD');
				vctr := vctr + 1;

           /* added for Oct 2012 */

        vXMLTable(vCtr).TagName := 'last_salary_day';
				vXMLTable(vCtr).TagValue := to_char(l_diff_date,'DD');
				vctr := vctr + 1;

        vXMLTable(vCtr).TagName := 'last_salary_month';
				vXMLTable(vCtr).TagValue := to_char(l_diff_date,'MM');
				vctr := vctr + 1;

        vXMLTable(vCtr).TagName := 'last_salary_year';
				vXMLTable(vCtr).TagValue := to_char(l_diff_date,'YYYY');
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'term_date_day';
				vXMLTable(vCtr).TagValue := to_char(l_term_per_date,'DD');
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'term_date_month';
				vXMLTable(vCtr).TagValue := to_char(l_term_per_date,'MM');
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'term_date_year';
				vXMLTable(vCtr).TagValue := to_char(l_term_per_date,'YYYY');
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'termination_reason';
				vXMLTable(vCtr).TagValue := l_term_reason_meaning;
				vctr := vctr + 1;

				vXMLTable(vCtr).TagName := 'prev_employer';
				vXMLTable(vCtr).TagValue := l_prev_emp_name;
				vctr := vctr + 1;
	                End If;

/*
		If l_ded_count = 5 then
			If l_csr_tot <> l_tot_ded_count then
				vXMLTable(vCtr).TagName := 'PAGE-BK';
				vXMLTable(vCtr).TagValue := '    ';
				vctr := vctr + 1;
			End If;
		End If;
*/

		If l_ded_count <> 5 then
			EXIT;
		End If;

		If l_ded_count = 5 then
			If l_csr_tot = l_tot_ded_count then
				EXIT;
			End If;
		End If;

	EXIT WHEN csr_get_ded_details%NOTFOUND;

	END LOOP;

		CLOSE csr_get_ded_details;

		vXMLTable(vCtr).TagName := 'PAGE-BK';
		vXMLTable(vCtr).TagValue := '    ';
		vctr := vctr + 1;




		j := j + 1;

          IF j > i THEN
            l_new_processed := 1;
            EXIT;
          END IF;
        END LOOP;

        hr_utility.set_location('Finished creating xml data for Procedure REPORT103 ',20);

	If l_df_flag <> 'Y' then
		fnd_file.put_line(fnd_file.log,get_lookup_meaning('KW_FORM_LABELS','NDF'));
	End If;

    WritetoCLOB ( l_xfdf_blob );

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

  END report103;
-------------------------------------------------------------------------------------------

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
	  /* Added CDATA to handle special characters Bug No:7476344 */
	  l_str9 := '<![CDATA['||l_str9||']]>';
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
      --l_raw_buffer := utl_raw.cast_to_raw(l_varchar_buffer);
      l_raw_buffer := utl_raw.convert(utl_raw.cast_to_raw(l_varchar_buffer),'American_America.UTF8',g_nls_db_char);
   fnd_file.put_line(fnd_file.log,l_varchar_buffer);
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
   p_effective_month varchar2,
	 p_effective_year varchar2,
	 p_pdf_blob OUT NOCOPY blob)
  IS
  BEGIN
    IF (p_report='REPORT55') THEN
/* changed for Oct 2012 Bug 14849011 */
     IF last_day(to_date('01-' || p_effective_month || '-' || p_effective_year,'DD-MM-YYYY')) <= last_day(to_date('01-09-2012','DD-MM-YYYY')) then
      Select file_data
      Into p_pdf_blob
      From fnd_lobs
      Where file_id = (select max(file_id) from fnd_lobs where file_name like '%PAY_R55_ar_KW.pdf');

     ELSE
      Select file_data
      Into p_pdf_blob
      From fnd_lobs
      Where file_id = (select max(file_id) from fnd_lobs where file_name like '%PAY_R55_12_ar_KW.pdf');

     END IF;
    ELSIF (p_report='REPORT56') THEN
      Select file_data
      Into p_pdf_blob
      From fnd_lobs
      Where file_id = (select max(file_id) from fnd_lobs where file_name like '%PAY_R56_ar_KW.pdf');
    ELSIF (p_report='REPORT103') THEN
       IF last_day(to_date('01-' || p_effective_month || '-' || p_effective_year,'DD-MM-YYYY')) <= last_day(to_date('01-09-2012','DD-MM-YYYY')) then
      Select file_data
      Into p_pdf_blob
      From fnd_lobs
      Where file_id = (select max(file_id) from fnd_lobs where file_name like '%PAY_R103_ar_KW.pdf');
     ELSE
      Select file_data
      Into p_pdf_blob
      From fnd_lobs
      Where file_id = (select max(file_id) from fnd_lobs where file_name like '%PAY_R103_12_ar_KW.pdf');

     END IF;
 /*     Select file_data
      Into p_pdf_blob
      From fnd_lobs
      Where file_id = (select max(file_id) from fnd_lobs where file_name like '%PAY_R103_ar_KW.pdf'); */
    END IF;
  EXCEPTION
    when no_data_found then
      null;
  END fetch_pdf_blob;

-------------------------------------------------------------------


PROCEDURE WritetoXML (
        p_request_id in number,
        p_report in varchar2,
        p_output_fname out nocopy varchar2)
IS
        p_l_fp UTL_FILE.FILE_TYPE;
        l_audit_log_dir varchar2(500);
        l_file_name varchar2(50);
        l_check_flag number;
BEGIN
        --l_audit_log_dir := '/sqlcom/outbound';
/*Msg in the temorary table*/
--insert into tstmsg values('Entered the procedure WritetoXML.');
        -----------------------------------------------------------------------------
        -- Writing into XML File
        -----------------------------------------------------------------------------
        -- Assigning the File name.
        l_file_name :=  to_char(p_request_id) || '.xml';
        -- Getting the Util file directory name.mostly it'll be /sqlcom/outbound )
        BEGIN
                SELECT value
                INTO l_audit_log_dir
                FROM v$parameter
                WHERE LOWER(name) = 'utl_file_dir';
                -- Check whether more than one util file directory is found
                IF INSTR(l_audit_log_dir,',') > 0 THEN
                   l_audit_log_dir := substr(l_audit_log_dir,1,instr(l_audit_log_dir,',')-1);
                END IF;
        EXCEPTION
                when no_data_found then
              null;
        END;
        -- Find out whether the OS is MS or Unix based
        -- If it's greater than 0, it's unix based environment
        IF INSTR(l_audit_log_dir,'/') > 0 THEN
                p_output_fname := l_audit_log_dir || '/' || l_file_name;
        ELSE
        p_output_fname := l_audit_log_dir || '\' || l_file_name;
        END IF;
        -- getting Agency name
        p_l_fp := utl_file.fopen(l_audit_log_dir,l_file_name,'A');
        utl_file.put_line(p_l_fp,'<?xml version="1.0" encoding="UTF-8"?>');
        utl_file.put_line(p_l_fp,'<xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">');
        -- Writing from and to dates
        utl_file.put_line(p_l_fp,'<fields>');
        -- Write the header fields to XML File.
        --WriteXMLvalues(p_l_fp,'P0_from_date',to_char(p_from_date,'dd') || ' ' || trim(to_char(p_from_date,'Month')) || ' ' || to_char(p_from_date,'yyyy') );
        --WriteXMLvalues(p_l_fp,'P0_to_date',to_char(p_to_date,'dd') || ' ' ||to_char(p_to_date,'Month') || ' ' || to_char(p_to_date,'yyyy') );
        -- Loop through PL/SQL Table and write the values into the XML File.
        -- Need to try FORALL instead of FOR
        IF vXMLTable.count >0 then

        FOR ctr_table IN vXMLTable.FIRST .. vXMLTable.LAST LOOP
                WriteXMLvalues(p_l_fp,vXMLTable(ctr_table).TagName ,vXMLTable(ctr_table).TagValue);
        END LOOP;
        END IF;
        -- Write the end tag and close the XML File.
        utl_file.put_line(p_l_fp,'</fields>');
        utl_file.put_line(p_l_fp,'</xfdf>');
        utl_file.fclose(p_l_fp);
/*Msg in the temorary table*/
--insert into tstmsg values('Leaving the procedure WritetoXML.');
END WritetoXML;
---------------------------------------------------------------------
PROCEDURE WriteXMLvalues( p_l_fp utl_file.file_type,p_tagname IN VARCHAR2, p_value IN VARCHAR2) IS
BEGIN
        -- Writing XML Tag and values to XML File
--      utl_file.put_line(p_l_fp,'<' || p_tagname || '>' || p_value || '</' || p_tagname || '>'  );
        -- New Format XFDF
        utl_file.put_line(p_l_fp,'<field name="' || p_tagname || '">');
        utl_file.put_line(p_l_fp,'<value>' || p_value || '</value>'  );
        utl_file.put_line(p_l_fp,'</field>');
END WriteXMLvalues;



END pay_kw_annual_reports;

/
