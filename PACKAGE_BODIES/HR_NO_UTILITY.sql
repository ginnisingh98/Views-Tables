--------------------------------------------------------
--  DDL for Package Body HR_NO_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_NO_UTILITY" AS
/* $Header: hrnoutil.pkb 120.7.12010000.2 2009/11/26 14:05:15 dchindar ship $ */
   --
   --
   --
   -- Function to Formate the Full Name for Norway
   --
   g_package VARCHAR2(30);

FUNCTION per_no_full_name(
                p_first_name        IN VARCHAR2
               ,p_middle_name       IN VARCHAR2
               ,p_last_name         IN VARCHAR2
               ,p_known_as          IN VARCHAR2
               ,p_title             IN VARCHAR2
               ,p_suffix            IN VARCHAR2
               ,p_pre_name_adjunct  IN VARCHAR2
               ,p_per_information1  IN VARCHAR2
               ,p_per_information2  IN VARCHAR2
               ,p_per_information3  IN VARCHAR2
               ,p_per_information4  IN VARCHAR2
               ,p_per_information5  IN VARCHAR2
               ,p_per_information6  IN VARCHAR2
               ,p_per_information7  IN VARCHAR2
               ,p_per_information8  IN VARCHAR2
               ,p_per_information9  IN VARCHAR2
               ,p_per_information10 IN VARCHAR2
               ,p_per_information11 IN VARCHAR2
               ,p_per_information12 IN VARCHAR2
               ,p_per_information13 IN VARCHAR2
               ,p_per_information14 IN VARCHAR2
               ,p_per_information15 IN VARCHAR2
               ,p_per_information16 IN VARCHAR2
               ,p_per_information17 IN VARCHAR2
               ,p_per_information18 IN VARCHAR2
               ,p_per_information19 IN VARCHAR2
               ,p_per_information20 IN VARCHAR2
               ,p_per_information21 IN VARCHAR2
               ,p_per_information22 IN VARCHAR2
               ,p_per_information23 IN VARCHAR2
               ,p_per_information24 IN VARCHAR2
               ,p_per_information25 IN VARCHAR2
               ,p_per_information26 IN VARCHAR2
               ,p_per_information27 IN VARCHAR2
               ,p_per_information28 IN VARCHAR2
               ,p_per_information29 IN VARCHAR2
               ,p_per_information30 IN VARCHAR2
               ) RETURN VARCHAR2 is

   --
   --
   --
   -- Local Variable
   --
      l_full_name  VARCHAR2(240);
   --
   --

      BEGIN
   --
   --
   -- Construct the full name which has the following format:
   --
   -- <first name> <middle name> <last name>
   --


      SELECT SUBSTR(LTRIM(RTRIM(
             RTRIM(p_first_name)
           ||DECODE(p_middle_name,NULL, '', ' ' || LTRIM(RTRIM(p_middle_name)))
           ||' '||LTRIM(p_last_name))
           ), 1, 240)
       INTO   l_full_name
       FROM   dual;

   --
   --
   -- Return Full name
   --

      RETURN l_full_name;
   --
  END per_no_full_name;


   --
   --
   --
   -- Function to Formate the Full Name for Norway
   --
FUNCTION per_no_order_name(
                p_first_name        IN VARCHAR2
               ,p_middle_name       IN VARCHAR2
               ,p_last_name         IN VARCHAR2
               ,p_known_as          IN VARCHAR2
               ,p_title             IN VARCHAR2
               ,p_suffix            IN VARCHAR2
               ,p_pre_name_adjunct  IN VARCHAR2
               ,p_per_information1  IN VARCHAR2
               ,p_per_information2  IN VARCHAR2
               ,p_per_information3  IN VARCHAR2
               ,p_per_information4  IN VARCHAR2
               ,p_per_information5  IN VARCHAR2
               ,p_per_information6  IN VARCHAR2
               ,p_per_information7  IN VARCHAR2
               ,p_per_information8  IN VARCHAR2
               ,p_per_information9  IN VARCHAR2
               ,p_per_information10 IN VARCHAR2
               ,p_per_information11 IN VARCHAR2
               ,p_per_information12 IN VARCHAR2
               ,p_per_information13 IN VARCHAR2
               ,p_per_information14 IN VARCHAR2
               ,p_per_information15 IN VARCHAR2
               ,p_per_information16 IN VARCHAR2
               ,p_per_information17 IN VARCHAR2
               ,p_per_information18 IN VARCHAR2
               ,p_per_information19 IN VARCHAR2
               ,p_per_information20 IN VARCHAR2
               ,p_per_information21 IN VARCHAR2
               ,p_per_information22 IN VARCHAR2
               ,p_per_information23 IN VARCHAR2
               ,p_per_information24 IN VARCHAR2
               ,p_per_information25 IN VARCHAR2
               ,p_per_information26 IN VARCHAR2
               ,p_per_information27 IN VARCHAR2
               ,p_per_information28 IN VARCHAR2
               ,p_per_information29 IN VARCHAR2
               ,p_per_information30 IN VARCHAR2)
                RETURN VARCHAR2 IS
   --
   --
   --
   -- Local Variable
   --
      l_order_name  VARCHAR2(240);
   --
   --
      BEGIN
   --
   --
   -- Construct the order name which has the following format:
   --
   -- <last name> <first name>
   --
   --

      SELECT SUBSTR(TRIM(p_last_name)||'   '||TRIM(p_first_name), 1, 240)
      INTO   l_order_name
      FROM   dual;

   --
   --
   -- Return the Order Name
   --

    RETURN l_order_name;
   --
   --
   --
END per_no_order_name;



FUNCTION validate_account_number
 (p_account_number IN VARCHAR2) RETURN NUMBER IS
 	l_i NUMBER;
 	l_rem NUMBER;
 	l_strlen NUMBER;
 	l_valid NUMBER;
 	l_account_number VARCHAR2(15);
 BEGIN
 	 -- Account no length should be 11 characters.
   --
   IF LENGTH(p_account_number) <>  11 THEN
     RETURN 1;
   END IF;

   -- Ensure the Account Number consists only of digits.
   --
   l_strlen:= LENGTH(p_account_number);
   FOR i IN 1..l_strlen
   LOOP
   	 IF  (SUBSTR(p_account_number,i,1) < '0' OR SUBSTR(p_account_number,i,1) > '9') then
   	 	  l_valid :=1;
   	 END IF;

   END LOOP;
    IF  l_valid =1 THEN
    	RETURN 1 ;
    END IF;
  -- Using Modulus 11 Validation
  --
  l_i := 0;
  l_i := l_i + substr(p_account_number,  1, 1) * 5;
  l_i := l_i + substr(p_account_number,  2, 1) * 4;
  l_i := l_i + substr(p_account_number,  3, 1) * 3;
  l_i := l_i + substr(p_account_number,  4, 1) * 2;
  l_i := l_i + substr(p_account_number,  5, 1) * 7;
  l_i := l_i + substr(p_account_number,  6, 1) * 6;
  l_i := l_i + substr(p_account_number,  7, 1) * 5;
  l_i := l_i + substr(p_account_number,  8, 1) * 4;
  l_i := l_i + substr(p_account_number,  9, 1) * 3;
  l_i := l_i + substr(p_account_number,  10, 1) * 2;
  l_rem := mod( l_i, 11 );
  IF l_rem = 0 THEN
  	 	RETURN 0 ;
  ELSE
  	 IF 11- l_rem = substr(p_account_number,  11, 1) THEN
  	 		RETURN 0 ;
  	 ELSE
  	 		RETURN 1 ;
  	 END IF;
  END IF;

END;


----
-- Function added for IBAN Validation
----
FUNCTION validate_iban_acc(p_account_no VARCHAR2)RETURN NUMBER IS
BEGIN
     IF IBAN_VALIDATION_PKG.validate_iban_acc(p_account_no) = 1 then
     RETURN 1;
     else
     RETURN 0;
     END IF;
END validate_iban_acc;

----
-- This function will get called from the bank keyflex field segments
----
FUNCTION validate_account_entered
(p_acc_no        IN VARCHAR2,
 p_is_iban_acc   IN varchar2 ) RETURN NUMBER IS
   --
   l_ret NUMBER ;
 begin
--   hr_utility.trace_on(null,'ACCVAL');
  l_ret :=0;
  hr_utility.set_location('p_is_iban_acc    ' || p_is_iban_acc,1);
  hr_utility.set_location('p_account_number ' || p_acc_no,1);

  IF (p_acc_no IS NOT NULL AND p_is_iban_acc = 'N') then
    l_ret := validate_account_number(p_acc_no);
    hr_utility.set_location('l_ret ' || l_ret,1);
    RETURN l_ret;
  ELSIF (p_acc_no IS NOT NULL AND p_is_iban_acc = 'Y') then
    l_ret := validate_iban_acc(p_acc_no);
    hr_utility.set_location('l_ret ' || l_ret,3);
    RETURN l_ret;
  ELSIF (p_acc_no IS NULL AND p_is_iban_acc IS NULL) then
    hr_utility.set_location('Both Account Nos Null',4);
    RETURN 1;
  ELSE
    hr_utility.set_location('l_ret: 3 ' ,5);
    RETURN 3;
  END if;
End validate_account_entered;



FUNCTION chk_valid_date (p_nat_id IN VARCHAR2)
RETURN NUMBER
IS
l_date DATE;
l_day varchar2(2);
l_century NUMBER;
BEGIN

	-- Identify the century form NI Number
	IF TO_NUMBER(SUBSTR(p_nat_id,8,2)) < 50  THEN
             l_century := 19;

	ELSIF TO_NUMBER(SUBSTR(p_nat_id,8,2)) >= 50  AND TO_NUMBER(SUBSTR(p_nat_id,8,2)) < 75 THEN
	       IF TO_NUMBER(SUBSTR(p_nat_id,8,2)) >= 50 THEN
		      l_century := 18;
	       END IF;
	ELSIF TO_NUMBER(SUBSTR(p_nat_id,8,2)) >= 50 THEN
              l_century := 20;
	END IF;


	-- Identify the date form NI Number
	IF TO_NUMBER(substr(p_nat_id,1,2)) > 31 THEN
		l_day := TO_CHAR(TO_NUMBER(substr(p_nat_id,1,2)) - 40);
		IF to_number(l_day) < 10 THEN
			l_day := '0' || l_day;
		END IF;
	ELSE
		l_day := substr(p_nat_id,1,2);
	END IF;

	-- check for validity of date
       l_date:=to_date(l_day || substr(p_nat_id,3,2) || to_char(l_century) || substr(p_nat_id,5,2),'DDMMYYYY');
       RETURN 1;
EXCEPTION
               WHEN others THEN
               RETURN 0;
END;


-- Function     : get_employment_information
-- Parameters : assignment_id  -  p_assignment_id,
--			employment information code - l_information_code.
-- Description : The function returns the employment information based on the assignment id
--			and the information code parameters. The information is first searced for at
--			the assignment level through the HR_Organization level , Local Unit level ,
--			Legal Employer Level to the Business group level.
--
-- The values for  p_emp_information_code can be
--		JOB_STATUS  for Job Status
--		COND_OF_EMP	for Condition of Employment
--		PART_FULL_TIME for Full/Part Time
--		SHIFT_WORK  for Shift Work
--		PAYROLL_PERIOD for Payroll Period
--		AGREED_WORKING_HOURS for Agreed working hours

FUNCTION get_employment_information (
			p_assignment_id  IN number,
			p_emp_information_code IN varchar2 )
			RETURN VARCHAR2 IS

	-- local variables declaration --
	l_scl_id  NUMBER(5);
	l_organization_id Number(15);
	l_is_hr_org  varchar2(150);
	l_information varchar2(150);
	l_local_unit number(15);
	l_legal_employer number(15);
	l_org_id number(15);
	l_bg_id  number(15);
	l_information_code varchar2(50);

	cursor get_scl_id is
		select SOFT_CODING_KEYFLEX_ID
		from  PER_ALL_ASSIGNMENTS_F
		where assignment_id = p_assignment_id;

	cursor get_org_id is
		select ORGANIZATION_ID
		from  PER_ALL_ASSIGNMENTS_F
		where assignment_id = p_assignment_id;

	cursor get_info_from_scl  is
		select lookups.meaning
		from HR_SOFT_CODING_KEYFLEX scl, hr_lookups lookups
		where scl.SOFT_CODING_KEYFLEX_ID = l_scl_id
		and lookups.lookup_type=l_information_code
		and lookups.enabled_flag = 'Y'
		and lookups.lookup_code = decode(l_information_code,'NO_JOB_STATUS',scl.segment5,
													   'NO_COND_OF_EMP',scl.segment6,
													   'NO_PART_FULL_TIME',scl.segment7,
													   'NO_SHIFT_WORK',scl.segment8,
													   'NO_PAYROLL_PERIOD',scl.segment9,
													   'NO_AGREED_WORKING_HOURS',scl.segment10,null);

	cursor get_info_from_org is
		select lookups.meaning
		from hr_organization_units hou, hr_organization_information hoi , hr_lookups lookups
		where hou.organization_id = l_organization_id
		and hou.organization_id = hoi.organization_id
		and hoi.org_information_context = 'NO_EMPLOYMENT_DEFAULTS'
		and lookups.lookup_type = l_information_code
		and lookups.enabled_flag = 'Y'
		and lookups.lookup_code = decode(l_information_code,'NO_JOB_STATUS',hoi.org_information1,
                                                                   'NO_COND_OF_EMP',hoi.org_information2,
                                                                   'NO_PART_FULL_TIME',hoi.org_information3,
                                                                   'NO_SHIFT_WORK',hoi.org_information4,
                                                                   'NO_PAYROLL_PERIOD',hoi.org_information5,
                                                                   'NO_AGREED_WORKING_HOURS',hoi.org_information6,null);

	cursor is_hr_org is
		select nvl(hoi.org_information1,'NO_DATA')
		from hr_organization_units hou , hr_organization_information hoi
		where hou.organization_id = l_organization_id
		and hou.organization_id = hoi.organization_id
		and hoi.org_information_context = 'CLASS'
		and hoi.org_information1 = 'HR_ORG';

	cursor get_local_unit is
		 select segment2
		 from hr_soft_coding_keyflex
		 where soft_coding_keyflex_id = l_scl_id;


	cursor get_info_from_local_unit is
		select lookups.meaning
		from hr_organization_information hoi , hr_lookups lookups
		where hoi.organization_id = l_org_id
		and hoi.org_information_context = 'NO_EMPLOYMENT_DEFAULTS'
		and lookups.lookup_type = l_information_code
		and lookups.enabled_flag = 'Y'
		and lookups.lookup_code = decode(l_information_code,'NO_JOB_STATUS',hoi.org_information1,
													   'NO_COND_OF_EMP',hoi.org_information2,
													   'NO_PART_FULL_TIME',hoi.org_information3,
													   'NO_SHIFT_WORK',hoi.org_information4,
													   'NO_PAYROLL_PERIOD',hoi.org_information5,
													   'NO_AGREED_WORKING_HOURS',hoi.org_information6,null);

	cursor get_legal_employer is
		select hoi2.organization_id
		from hr_organization_information hoi1 , hr_organization_information hoi2
		where hoi1.org_information1 = to_char(l_local_unit) and hoi1.org_information_context = 'NO_LOCAL_UNITS'
		and hoi2.org_information_context = 'CLASS' and hoi2.org_information1 = 'HR_LEGAL_EMPLOYER'
		and hoi2.organization_id = hoi1.organization_id;


	cursor get_bg_id is
		select business_group_id
		from hr_organization_units
		where organization_id = l_organization_id;

	cursor get_info_from_scl_awh  is
		select scl.segment10
		from HR_SOFT_CODING_KEYFLEX scl
		where scl.SOFT_CODING_KEYFLEX_ID = l_scl_id;


	cursor get_info_from_org_awh is
		select hoi.org_information6
		from hr_organization_units hou, hr_organization_information hoi
		where hou.organization_id = l_organization_id
		and hou.organization_id = hoi.organization_id
		and hoi.org_information_context = 'NO_EMPLOYMENT_DEFAULTS';


   	cursor get_info_from_local_unit_awh is
		select 	hoi.org_information6
		from hr_organization_information hoi
		where hoi.organization_id = l_org_id
		and hoi.org_information_context = 'NO_EMPLOYMENT_DEFAULTS';



	begin

	if l_information_code not in ('JOB_STATUS','COND_OF_EMP',
			'PART_FULL_TIME','SHIFT_WORK','PAYROLL_PERIOD','AGREED_WORKING_HOURS') then
		return null;
	end if;

	l_information_code := 'NO_'||p_emp_information_code;

	---------------------------------------------------------------------------------
	--     To return information other than Agreed working hours	   --
	---------------------------------------------------------------------------------

	if l_information_code <> 'NO_AGREED_WORKING_HOURS'  then
		--------------------------------------
		--Try at the Assignment Level --
		--------------------------------------

		-- get scl id --
		open get_scl_id;
		fetch get_scl_id into l_scl_id;
		close get_scl_id;

		if l_scl_id is not null then
			-- get information at assignment level --
			open get_info_from_scl;
			fetch get_info_from_scl into l_information;
			close get_info_from_scl;
			if  l_information is not null then
				return l_information;
			end if;
		end if;

		--------------------------------------
		--Try at the HR_ORG Level --
		--------------------------------------

		-- get organization_id --
		open get_org_id;
		fetch get_org_id into l_organization_id;
		close get_org_id;

		-- organization id cannot be null --
		-- check if the organization is HR_ORG --
		open is_hr_org;
		fetch is_hr_org into l_is_hr_org;
		if  is_hr_org%NOTFOUND then
			l_is_hr_org := 'NO_INFO';
		end if;

		--  get information at the HR Organization level --
		if l_is_hr_org <> 'NO_INFO' then
			open get_info_from_org;
			fetch get_info_from_org into l_information;
			close get_info_from_org;

			if l_information is not null then
				return l_information;
			end if;
		end if;

		--------------------------------------
		--Try at the Local Unit Level --
		--------------------------------------
		-- get local unit id --
		open get_local_unit;
		fetch get_local_unit into l_local_unit;
		close get_local_unit;

		-- get information at local unit level --
		l_org_id := l_local_unit;
		open get_info_from_local_unit;
		fetch get_info_from_local_unit into l_information;
		close get_info_from_local_unit;

		if l_information is not null then
			return l_information;
		end if;

		------------------------------------------
		--Try at the Legal Employer Level --
		------------------------------------------
		-- get legal employer id --
		open get_legal_employer;
		fetch get_legal_employer into l_legal_employer;
		close get_legal_employer;

		-- the cursor for local unit can be reused--
		l_org_id := l_legal_employer;
		open get_info_from_local_unit;
		fetch get_info_from_local_unit into l_information;
		close get_info_from_local_unit;

		if l_information is not null then
			return l_information;
		end if;

		------------------------------------------
		--Try at the Business Group Level --
		------------------------------------------
		-- get bg id --
		open get_bg_id;
		fetch get_bg_id into l_bg_id;
		close get_bg_id;

		-- search at bg level--
		-- the value in l_organization_id will no longer be necessary --
		-- storing bg_id in l_organization_id --

		l_organization_id := l_bg_id;
		open get_info_from_org;
		fetch get_info_from_org into l_information;
		close get_info_from_org;

		if l_information is not null then
			return l_information;
		end if;

		-- return null if the emp information is not present at any level --
		return null;

	----------------------------------------------------------------------------------
	--		To Return Agreed Working Hours Information		    --
	----------------------------------------------------------------------------------
	elsif  l_information_code = 'NO_AGREED_WORKING_HOURS' then

		--------------------------------------
		--Try at the Assignment Level --
		--------------------------------------

		-- get scl id --
		open get_scl_id;
		fetch get_scl_id into l_scl_id;
		close get_scl_id;

		if l_scl_id is not null then
			-- get information at assignment level --
			open get_info_from_scl_awh;
			fetch get_info_from_scl_awh into l_information;
			close get_info_from_scl_awh;
			if  l_information is not null then
				return l_information;
			end if;
		end if;

		--------------------------------------
		--Try at the HR_ORG Level --
		--------------------------------------

		-- get organization_id --
		open get_org_id;
		fetch get_org_id into l_organization_id;
		close get_org_id;

		-- organization id cannot be null --
		-- check if the organization is HR_ORG --
		open is_hr_org;
		fetch is_hr_org into l_is_hr_org;
		if  is_hr_org%NOTFOUND then
			l_is_hr_org := 'NO_INFO';
		end if;

		--  get information at the HR Organization level --
		if l_is_hr_org <> 'NO_INFO' then
			open get_info_from_org_awh;
			fetch get_info_from_org_awh into l_information;
			close get_info_from_org_awh;

			if l_information is not null then
				return l_information;
			end if;
		end if;

		--------------------------------------
		--Try at the Local Unit Level --
		--------------------------------------
		-- get local unit id --
		open get_local_unit;
		fetch get_local_unit into l_local_unit;
		close get_local_unit;

		-- get information at local unit level --
		l_org_id := l_local_unit;
		open get_info_from_local_unit_awh;
		fetch get_info_from_local_unit_awh into l_information;
		close get_info_from_local_unit_awh;

		if l_information is not null then
			return l_information;
		end if;

		------------------------------------------
		--Try at the Legal Employer Level --
		------------------------------------------
		-- get legal employer id --
		open get_legal_employer;
		fetch get_legal_employer into l_legal_employer;
		close get_legal_employer;

		-- the cursor for local unit can be reused--
		l_org_id := l_legal_employer;
		open get_info_from_local_unit_awh;
		fetch get_info_from_local_unit_awh into l_information;
		close get_info_from_local_unit_awh;

		if l_information is not null then
			return l_information;
		end if;

		------------------------------------------
		--Try at the Business Group Level --
		------------------------------------------
		-- get bg id --
		open get_bg_id;
		fetch get_bg_id into l_bg_id;
		close get_bg_id;

		-- search at bg level--
		-- the value in l_organization_id will no longer be necessary --
		-- storing bg_id in l_organization_id --

		l_organization_id := l_bg_id;
		open get_info_from_org_awh;
		fetch get_info_from_org_awh into l_information;
		close get_info_from_org_awh;

		if l_information is not null then
			return l_information;
		end if;

		-- return null if the emp information is not present at any level --
		return null;

	end if;

	END get_employment_information;



-- function for Norway BIK to get element entry effective start date

FUNCTION Get_EE_EFF_START_DATE
( p_EE_ID pay_element_entries_f.ELEMENT_ENTRY_ID%TYPE,
  p_date_earned DATE )
RETURN DATE
IS
l_Date DATE;
BEGIN
    BEGIN
        select  EFFECTIVE_START_DATE
        INTO    l_Date
        from    pay_element_entries_f
        where   element_entry_id=p_EE_ID
        and     p_date_earned between EFFECTIVE_START_DATE and EFFECTIVE_END_DATE;
        EXCEPTION
        WHEN NO_DATA_FOUND
        THEN

	  l_Date := fnd_date.canonical_to_date('4712/12/31');
    END;

RETURN l_Date;
END Get_EE_EFF_START_DATE;
--


-- function for Norway BIK to get element entry effective end date

FUNCTION Get_EE_EFF_END_DATE
( p_EE_ID pay_element_entries_f.ELEMENT_ENTRY_ID%TYPE,
  p_date_earned DATE )
RETURN DATE
IS
l_Date DATE;
BEGIN
    BEGIN
        select  EFFECTIVE_END_DATE
        INTO    l_Date
        from    pay_element_entries_f
        where   element_entry_id=p_EE_ID
        and     p_date_earned between EFFECTIVE_START_DATE and EFFECTIVE_END_DATE;

        EXCEPTION
        WHEN NO_DATA_FOUND
        THEN

	  l_Date := fnd_date.canonical_to_date('4712/12/31');
    END;

RETURN l_Date;
END Get_EE_EFF_END_DATE;

--

-- function for Norway BIK Company Cars to get vehile information using Vehicle Repository

FUNCTION get_vehicle_info
( p_assignment_id per_all_assignments_f.assignment_id%TYPE,
  p_date_earned DATE,
  p_list_price OUT NOCOPY pqp_vehicle_repository_f.LIST_PRICE%TYPE,
  p_reg_number OUT NOCOPY pqp_vehicle_repository_f.REGISTRATION_NUMBER%TYPE,
  p_reg_date   OUT NOCOPY pqp_vehicle_repository_f.INITIAL_REGISTRATION%TYPE
)
return NUMBER
IS
l_value NUMBER;
BEGIN
    BEGIN

    select pvr.LIST_PRICE
          ,pvr.REGISTRATION_NUMBER
          ,pvr.INITIAL_REGISTRATION
    INTO   p_list_price
          ,p_reg_number
          ,p_reg_date
    from   pqp_vehicle_allocations_f  pva
          ,pqp_vehicle_repository_f   pvr
    where  pva.assignment_id = p_assignment_id
    and    pvr.vehicle_repository_id = pva.vehicle_repository_id
    and    p_date_earned between pva.EFFECTIVE_START_DATE and pva.EFFECTIVE_END_DATE
    and    p_date_earned between pvr.EFFECTIVE_START_DATE and pvr.EFFECTIVE_END_DATE;

    l_value :=1;

    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
        l_value :=0;

    END;

RETURN l_value;
END get_vehicle_info;
--

-- function for Norway BIK Company Cars to get number of periods and months

/* For BIK , to get number of pay periods and the number of months
   in the current payroll year for Company Cars */

FUNCTION get_num_of_periods_n_months
( p_payroll_id IN PAY_PAYROLLS_F.PAYROLL_ID%TYPE ,
  p_start_date IN DATE,
  p_end_date   IN DATE,
  p_curr_pay_start_date IN DATE,
  p_curr_per_pay_date IN DATE,
  p_num_of_periods OUT NOCOPY VARCHAR2,
  p_num_of_months OUT NOCOPY VARCHAR2
)
RETURN NUMBER
IS
l_num_of_periods NUMBER;
l_num_of_months  NUMBER;
l_start_date DATE;
l_val NUMBER;


BEGIN
    BEGIN

    l_start_date := p_start_date;
    l_val := 1;
    l_num_of_periods := 1;
    l_num_of_months  := 0;

    /* if the element was created in a year before the current payroll period pay date year */
    IF to_number(to_char(l_start_date,'yyyy')) < to_number(to_char(p_curr_per_pay_date,'yyyy'))
      THEN
        /* then set the starting of element to the begining of the current payroll period pay date year */
        l_start_date := to_date('01-01-'||to_char(p_curr_per_pay_date,'RRRR'),'DD-MM-RRRR' );
    END IF;

    /* p_start_date is the original element entry effective start date */
    /* l_start_date is the modified element entry effective start date when the payroll changes year*/

    Select  COUNT(*)
    INTO    l_num_of_periods
    from    PER_TIME_PERIODS
    where   PAYROLL_ID=p_payroll_id
    and     REGULAR_PAYMENT_DATE <> p_start_date
    and     REGULAR_PAYMENT_DATE between l_start_date and p_end_date
    and     REGULAR_PAYMENT_DATE <= to_date('31-12-' || to_char(p_curr_pay_start_date,'RRRR'),'DD-MM-RRRR');

    l_num_of_months := 12-(to_number(to_char(l_start_date,'mm')))+1 ;

    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
        l_num_of_periods := 1;
        l_num_of_months  := 0;
        l_val := 0;
    END;

    p_num_of_periods := to_char(l_num_of_periods);
    p_num_of_months  := to_char(l_num_of_months);

Return l_val;
END get_num_of_periods_n_months;
--

/* For BIK , to get number of pay periods with pay date
   in the current payroll year for Preferential Loans */

FUNCTION get_num_of_periods
( p_payroll_id IN PAY_PAYROLLS_F.PAYROLL_ID%TYPE ,
  p_curr_per_pay_date IN DATE
)
RETURN NUMBER
IS
l_num_of_periods NUMBER;

BEGIN
    BEGIN

    Select  COUNT(*)
    INTO    l_num_of_periods
    from    PER_TIME_PERIODS
    where   PAYROLL_ID=p_payroll_id
    and     to_char(REGULAR_PAYMENT_DATE,'mm-yyyy') = to_char(p_curr_per_pay_date,'mm-yyyy');

    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
        l_num_of_periods := 1;
    END;

Return l_num_of_periods;
END get_num_of_periods;
--


/* For BIK , to get the regular payment date
   for the current payroll period */

FUNCTION get_regular_pay_date
( p_payroll_id IN PAY_PAYROLLS_F.PAYROLL_ID%TYPE ,
  p_Curr_Pay_Start_Date IN DATE
)
RETURN DATE
IS
l_regular_pay_date DATE;

BEGIN
    BEGIN

    Select  REGULAR_PAYMENT_DATE
    INTO    l_regular_pay_date
    from    PER_TIME_PERIODS
    where   PAYROLL_ID=p_payroll_id
    and     START_DATE = p_Curr_Pay_Start_Date;

    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
         l_regular_pay_date := fnd_date.canonical_to_date('4712/12/31');
    END;

Return l_regular_pay_date;
END get_regular_pay_date;
--


/* Function to get the message text */

FUNCTION get_msg_text
( p_applid   IN NUMBER,
  p_msg_name IN VARCHAR2
)
RETURN varchar2
IS

l_msg_text varchar2(2000);

BEGIN
    BEGIN

	FND_MESSAGE.SET_NAME(hr_general.get_application_short_name(p_applid),p_msg_name);
 	l_msg_text := FND_MESSAGE.GET;

    END;

Return l_msg_text;
END get_msg_text;
--
------------------------------------------------------------------------
-- Function GET_TABLE_VALUE
------------------------------------------------------------------------
FUNCTION get_table_value
			(p_Date_Earned     IN DATE
			,p_table_name      IN VARCHAR2
			,p_column_name     IN VARCHAR2
			,p_return_type     IN VARCHAR2) RETURN NUMBER
IS
CURSOR csr_get_user_table_id IS
SELECT user_table_id
FROM   pay_user_tables
WHERE  legislation_code = 'NO'
AND    UPPER(user_table_name) = UPPER(p_table_name);

CURSOR csr_get_column_id (l_user_table_id NUMBER) IS
SELECT user_column_id
FROM   pay_user_columns
WHERE  legislation_code = 'NO'
AND    UPPER(user_column_name) = UPPER(p_column_name)
AND    user_table_id = l_user_table_id;

-- Modifying CURSOR csr_get_row_id , commenting the use of fnd_date.canonical_to_date

/*
CURSOR csr_get_row_id (l_user_table_id NUMBER) IS
SELECT user_row_id
FROM   pay_user_rows_f
WHERE  legislation_code = 'NO'
AND    UPPER(row_low_range_or_name) = UPPER(p_return_type)
AND    user_table_id = l_user_table_id
AND    fnd_date.canonical_to_date(p_Date_Earned) BETWEEN effective_start_date AND effective_end_date;
*/

CURSOR csr_get_row_id (l_user_table_id NUMBER) IS
SELECT user_row_id
FROM   pay_user_rows_f
WHERE  legislation_code = 'NO'
AND    UPPER(row_low_range_or_name) = UPPER(p_return_type)
AND    user_table_id = l_user_table_id
AND    p_Date_Earned BETWEEN effective_start_date AND effective_end_date;

-- Modifying CURSOR csr_get_user_table_value , commenting the use of fnd_date.canonical_to_date

/*
CURSOR csr_get_user_table_value (l_user_column_id NUMBER, l_user_row_id NUMBER) IS
SELECT value
FROM   pay_user_column_instances_f
WHERE  legislation_code = 'NO'
AND    user_column_id = l_user_column_id
AND    user_row_id = l_user_row_id
AND    fnd_date.canonical_to_date(p_Date_Earned) BETWEEN effective_start_date AND effective_end_date;
*/

/*
CURSOR csr_get_user_table_value (l_user_column_id NUMBER, l_user_row_id NUMBER) IS
SELECT value
FROM   pay_user_column_instances_f
WHERE  legislation_code = 'NO'
AND    user_column_id = l_user_column_id
AND    user_row_id = l_user_row_id
AND    p_Date_Earned BETWEEN effective_start_date AND effective_end_date;
*/

-- Bug Fix 5943303 and 5943317
-- A numeric value from a varchar2 column is being returned to a number variable without any conversion.
-- Using fnd_number.canonical_to_number on column value.

CURSOR csr_get_user_table_value (l_user_column_id NUMBER, l_user_row_id NUMBER) IS
SELECT fnd_number.canonical_to_number(value)
FROM   pay_user_column_instances_f
WHERE  legislation_code = 'NO'
AND    user_column_id = l_user_column_id
AND    user_row_id = l_user_row_id
AND    p_Date_Earned BETWEEN effective_start_date AND effective_end_date;


l_user_table_id  NUMBER;
l_user_column_id NUMBER;
l_user_row_id    NUMBER;

-- l_ret_val        NUMBER(15,2);

-- Bug Fix 5943303 and 5943317
l_ret_val        NUMBER;

l_proc           VARCHAR2(72) ;

BEGIN
g_package := 'pay_no_travel_expenses';
l_proc := g_package||'.get_table_value';

--

-- Get the User Table ID
OPEN csr_get_user_table_id;
	FETCH csr_get_user_table_id INTO l_user_table_id;
CLOSE csr_get_user_table_id;

-- Get the Column ID
OPEN csr_get_column_id(l_user_table_id);
	FETCH csr_get_column_id INTO l_user_column_id;
CLOSE csr_get_column_id;

-- Get the Row ID
OPEN csr_get_row_id(l_user_table_id);
	FETCH csr_get_row_id INTO l_user_row_id;
CLOSE csr_get_row_id;

-- Get the value
OPEN csr_get_user_table_value(l_user_column_id,l_user_row_id);
	FETCH csr_get_user_table_value INTO l_ret_val;
CLOSE csr_get_user_table_value;


RETURN nvl(l_ret_val,0);

END get_table_value;
PROCEDURE CREATE_NO_DEI_INFO
(P_PERSON_ID	 IN NUMBER DEFAULT NULL,
P_ISSUED_DATE IN DATE  DEFAULT NULL,
P_DATE_FROM	 IN DATE,
P_DATE_TO IN DATE,
P_DOCUMENT_NUMBER IN VARCHAR2  DEFAULT NULL,
P_DOCUMENT_TYPE_ID	 IN NUMBER
)is

 l_exists varchar2(1);
cursor csr_doc_exists is
   select null from hr_document_extra_info
    where person_id = p_person_id
      and document_type_id = p_document_type_id
      and (date_from between p_date_from and p_date_to or
           date_to between p_date_from and p_date_to or
           p_date_from between date_from and date_to);

/*CURSOR CHECK_OVERLAP_DEI_INFO IS
SELECT 1 FROM HR_DOCUMENT_EXTRA_INFO WHERE
DOCUMENT_TYPE_ID=P_DOCUMENT_TYPE_ID AND
(P_DATE_FROM< DATE_TO AND P_DATE_TO > DATE_FROM );*/
BEGIN
IF P_ISSUED_DATE IS NULL THEN
 HR_UTILITY.SET_MESSAGE(800,'HR_376898_NO_DEI_DATE_REQD');
           hr_utility.raise_error;
END IF;

    open csr_doc_exists;
     fetch csr_doc_exists into l_exists;
       if csr_doc_exists%FOUND then
          hr_utility.set_message(800,'HR_376897_NO_OVERLAP_DEI_INFO');
          hr_utility.raise_error;
       end if;
    close csr_doc_exists;

END;


PROCEDURE UPDATE_NO_DEI_INFO
(P_PERSON_ID	 IN NUMBER DEFAULT NULL,
P_ISSUED_DATE IN DATE  DEFAULT NULL,
P_DATE_FROM	 IN DATE,
P_DATE_TO IN DATE,
P_DOCUMENT_NUMBER IN VARCHAR2  DEFAULT NULL,
P_DOCUMENT_EXTRA_INFO_ID IN NUMBER,
P_DOCUMENT_TYPE_ID	 IN NUMBER
)IS
 l_exists varchar2(1);
 cursor csr_doc_exists is
   select null from hr_document_extra_info
    where person_id = p_person_id
      and document_type_id = p_document_type_id
      and (date_from between p_date_from and p_date_to or
           date_to between p_date_from and p_date_to or
           p_date_from between date_from and date_to)
      and document_extra_info_id <> p_document_extra_info_id;



/*CURSOR CHECK_OVERLAP_DEI_INFO IS
SELECT 1 FROM HR_DOCUMENT_EXTRA_INFO WHERE
DOCUMENT_TYPE_ID=P_DOCUMENT_TYPE_ID AND
(P_DATE_FROM< DATE_TO AND P_DATE_TO > DATE_FROM );*/
BEGIN
IF P_ISSUED_DATE IS NULL THEN
 HR_UTILITY.SET_MESSAGE(800,'HR_376898_NO_DEI_DATE_REQD');
 HR_UTILITY.RAISE_ERROR;
END IF;

    open csr_doc_exists;
     fetch csr_doc_exists into l_exists;
       if csr_doc_exists%FOUND then
          hr_utility.set_message(800,'HR_376897_NO_OVERLAP_DEI_INFO');
          hr_utility.raise_error;
       end if;
    close csr_doc_exists;

END;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : get_IANA_charset                                    --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to IANA charset equivalent of              --
--                  NLS_CHARACTERSET                                    --
-- Parameters     :                                                     --
--             IN : N/A                                                 --
--            OUT : N/A                                                 --
--         RETURN : VARCHAR2                                            --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_IANA_charset RETURN VARCHAR2 IS
    CURSOR csr_get_iana_charset IS
        SELECT tag
          FROM fnd_lookup_values
          WHERE lookup_type = 'FND_ISO_CHARACTER_SET_MAP'
          AND lookup_code = SUBSTR(USERENV('LANGUAGE'),
                                    INSTR(USERENV('LANGUAGE'), '.') + 1)
          AND language = 'US';

    lv_iana_charset fnd_lookup_values.tag%type;
BEGIN
    OPEN csr_get_iana_charset;
        FETCH csr_get_iana_charset INTO lv_iana_charset;
    CLOSE csr_get_iana_charset;

    hr_utility.trace('IANA Charset = '||lv_iana_charset);
    RETURN (lv_iana_charset);
END get_IANA_charset;


--Function to display messages after payroll run.
FUNCTION get_message(p_product IN VARCHAR2,   p_message_name IN VARCHAR2,   p_token1 IN VARCHAR2 DEFAULT NULL,   p_token2 IN VARCHAR2 DEFAULT NULL,   p_token3 IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 IS l_message VARCHAR2(2000);
l_token_name VARCHAR2(20);
l_token_value VARCHAR2(80);
l_colon_position NUMBER;
--l_proc varchar2(72) := g_package||'.get_message';
--
BEGIN
  --
  --hr_utility.set_location('Entered '||l_proc,5);
  hr_utility.set_location('.  Message Name: ' || p_message_name,   40);
  fnd_message.set_name(p_product,   p_message_name);

  IF p_token1 IS NOT NULL THEN

    /* Obtain token 1 name and value */ l_colon_position := instr(p_token1,   ':');
    l_token_name := SUBSTR(p_token1,   1,   l_colon_position -1);
    l_token_value := SUBSTR(p_token1,   l_colon_position + 1,   LENGTH(p_token1));
    fnd_message.set_token(l_token_name,   l_token_value);
    hr_utility.set_location('.  Token1: ' || l_token_name || '. Value: ' || l_token_value,   50);
  END IF;

  IF p_token2 IS NOT NULL THEN

    /* Obtain token 2 name and value */ l_colon_position := instr(p_token2,   ':');
    l_token_name := SUBSTR(p_token2,   1,   l_colon_position -1);
    l_token_value := SUBSTR(p_token2,   l_colon_position + 1,   LENGTH(p_token2));
    fnd_message.set_token(l_token_name,   l_token_value);
    hr_utility.set_location('.  Token2: ' || l_token_name || '. Value: ' || l_token_value,   60);
  END IF;

  IF p_token3 IS NOT NULL THEN

    /* Obtain token 3 name and value */ l_colon_position := instr(p_token3,   ':');
    l_token_name := SUBSTR(p_token3,   1,   l_colon_position -1);
    l_token_value := SUBSTR(p_token3,   l_colon_position + 1,   LENGTH(p_token3));
    fnd_message.set_token(l_token_name,   l_token_value);
    hr_utility.set_location('.  Token3: ' || l_token_name || '. Value: ' || l_token_value,   70);
  END IF;

  l_message := SUBSTR(fnd_message.GET,   1,   254);
  --hr_utility.set_location('leaving '||l_proc,100);
  RETURN l_message;
END get_message;


 ---------------------------------------------------------------------------
 -- Function : get_global_value
 -- Function returns the global value for the given date.
 ---------------------------------------------------------------------------

 FUNCTION get_global_value (l_global_name VARCHAR2 , l_date DATE ) RETURN VARCHAR2 IS

 CURSOR get_global_value(l_global_name VARCHAR2 , l_date date)  IS
 SELECT GLOBAL_VALUE
 FROM ff_globals_f
 WHERE global_name = l_global_name
 AND LEGISLATION_CODE = 'NO'
 AND BUSINESS_GROUP_ID IS NULL
 AND l_date BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE ;


 l_value ff_globals_f.global_value%TYPE;

 BEGIN

 OPEN get_global_value(l_global_name , l_date);
 FETCH get_global_value INTO l_value;
 CLOSE get_global_value;

 RETURN l_value;

 EXCEPTION

 WHEN others THEN
 hr_utility.trace('SQLERRM:'||substr(sqlerrm,1,200));
 raise;

 END get_global_value;



 --
 -- End of the Package
END hr_no_utility;

/
