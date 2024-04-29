--------------------------------------------------------
--  DDL for Package Body HR_FI_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_FI_UTILITY" AS
 -- $Header: hrfiutil.pkb 120.2.12010000.5 2009/11/20 07:12:38 dchindar ship $
 --
 g_package varchar2(30) := 'hr_fi_utility';
 FUNCTION per_fi_full_name(
        p_first_name       in varchar2
       ,p_middle_names     in varchar2
       ,p_last_name        in varchar2
       ,p_known_as         in varchar2
       ,p_title            in varchar2
       ,p_suffix           in varchar2
       ,p_pre_name_adjunct in varchar2
       ,p_per_information1 in varchar2
       ,p_per_information2 in varchar2
       ,p_per_information3 in varchar2
       ,p_per_information4 in varchar2
       ,p_per_information5 in varchar2
       ,p_per_information6 in varchar2
       ,p_per_information7 in varchar2
       ,p_per_information8 in varchar2
       ,p_per_information9 in varchar2
       ,p_per_information10 in varchar2
       ,p_per_information11 in varchar2
       ,p_per_information12 in varchar2
       ,p_per_information13 in varchar2
       ,p_per_information14 in varchar2
       ,p_per_information15 in varchar2
       ,p_per_information16 in varchar2
       ,p_per_information17 in varchar2
       ,p_per_information18 in varchar2
       ,p_per_information19 in varchar2
       ,p_per_information20 in varchar2
       ,p_per_information21 in varchar2
       ,p_per_information22 in varchar2
       ,p_per_information23 in varchar2
       ,p_per_information24 in varchar2
       ,p_per_information25 in varchar2
       ,p_per_information26 in varchar2
       ,p_per_information27 in varchar2
       ,p_per_information28 in varchar2
       ,p_per_information29 in varchar2
       ,p_per_information30 in VARCHAR2
			 )
			  RETURN VARCHAR2 AS
--
l_full_name varchar2(240);
l_title varchar2(240);

--
BEGIN
   --
   l_full_name := p_last_name|| ' '||p_first_name|| ' ';
   if p_middle_names is not null then
         l_full_name := l_full_name|| p_middle_names||' ';
   end if;
   if p_title is not null then
	 l_title := hr_general.decode_lookup('TITLE',p_title);

         l_full_name := l_full_name|| l_title||' ';
   end if;
   if p_known_as  is not null then
         l_full_name := l_full_name||'('|| p_known_as ||')';
   end if;

   return (rtrim(l_full_name));
   --
END;
--
--
FUNCTION per_fi_order_name(
        p_first_name       in varchar2
       ,p_middle_names     in varchar2
       ,p_last_name        in varchar2
       ,p_known_as         in varchar2
       ,p_title            in varchar2
       ,p_suffix           in varchar2
       ,p_pre_name_adjunct in varchar2
       ,p_per_information1 in varchar2
       ,p_per_information2 in varchar2
       ,p_per_information3 in varchar2
       ,p_per_information4 in varchar2
       ,p_per_information5 in varchar2
       ,p_per_information6 in varchar2
       ,p_per_information7 in varchar2
       ,p_per_information8 in varchar2
       ,p_per_information9 in varchar2
       ,p_per_information10 in varchar2
       ,p_per_information11 in varchar2
       ,p_per_information12 in varchar2
       ,p_per_information13 in varchar2
       ,p_per_information14 in varchar2
       ,p_per_information15 in varchar2
       ,p_per_information16 in varchar2
       ,p_per_information17 in varchar2
       ,p_per_information18 in varchar2
       ,p_per_information19 in varchar2
       ,p_per_information20 in varchar2
       ,p_per_information21 in varchar2
       ,p_per_information22 in varchar2
       ,p_per_information23 in varchar2
       ,p_per_information24 in varchar2
       ,p_per_information25 in varchar2
       ,p_per_information26 in varchar2
       ,p_per_information27 in varchar2
       ,p_per_information28 in varchar2
       ,p_per_information29 in varchar2
       ,p_per_information30 in VARCHAR2
			  )
			   RETURN VARCHAR2 AS
--
l_order_name varchar2(240);
--
BEGIN
   --
   l_order_name := p_last_name || '              ' || p_first_name;
   return (rtrim(l_order_name));
   --
END;

 --
 -- Validates the bank account number.
 --
 -- The format is as follows BC-ACCX where
 --
 -- BC = 6 Digits representing the Branch Code
 -- X = 1 Digit representing the Validation Code
 -- Acc = Between 2 to 7 Digits

 FUNCTION validate_account_number
 (p_account_number IN VARCHAR2) RETURN NUMBER AS
 	l_valid NUMBER;
 	l_strlen NUMBER;
 	l_calc NUMBER;
 	l_account_number VARCHAR2(15);
 BEGIN
 	 -- Account no length should be between 9 and 15 characters.
   --
   IF LENGTH(p_account_number) NOT BETWEEN 9 AND  15 THEN
     RETURN 1;
   END IF;
   -- Check separators exist at the correct places within the account no.
   --
   IF SUBSTR(p_account_number,7,1) <> '-' THEN
     RETURN 1;
   END IF;

   -- Ensure the ABI consists only of digits.
   --
   l_strlen:= LENGTH(p_account_number);
   FOR i IN 1..l_strlen
   LOOP
   	 IF i <> 7 AND (SUBSTR(p_account_number,i,1) < '0'
	 OR SUBSTR(p_account_number,i,1) > '9') then
   	 	  l_valid :=1;
   	 END IF;

   END LOOP;
    IF  l_valid =1 THEN
    	RETURN 1 ;
    END IF;

   -- Ensure the Branch Code is Correct
   --
   IF substr(p_account_number,1,1) not in ('1','2','3','4','5','6','8') THEN
   		RETURN 1;
   END IF;

   -- Populate the Account No Upto 15 Digits
   --
   IF substr(p_account_number,1,1) in ('1','2','3','6','8') THEN
   		l_account_number:=substr(p_account_number,1,6)||
		LPAD(substr(p_account_number,8,8),8,'0');

   ELSE
   			l_account_number:=substr(p_account_number,1,6)||substr(p_account_number,8,1)||
	LPAD(substr(p_account_number,9,7),7,'0');
   END IF;

   -- Calculate the Weights of the Products using the weighted coefficients of the
   --Lunh Modulus 10
   -- Use weights 2, 1, 2, 1, 2, 1 ? from right to left for first 13 Digits
   --


   l_calc :=nvl(substr((substr(l_account_number,1,1)* 2),1,1),0)
	    + nvl(substr((substr(l_account_number,1,1)* 2),2,1),0)
   	    + nvl(substr((substr(l_account_number,2,1)* 1),1,1),0)
	    + nvl(substr((substr(l_account_number,2,1)* 1),2,1),0)
   	    + nvl(substr((substr(l_account_number,3,1)* 2),1,1),0)
            + nvl(substr((substr(l_account_number,3,1)* 2),2,1),0)
   	    + nvl(substr((substr(l_account_number,4,1)* 1),1,1),0)
            + nvl(substr((substr(l_account_number,4,1)* 1),2,1),0)
   	    + nvl(substr((substr(l_account_number,5,1)* 2),1,1),0)
            + nvl(substr((substr(l_account_number,5,1)* 2),2,1),0)
   	    + nvl(substr((substr(l_account_number,6,1)* 1),1,1),0)
            + nvl(substr((substr(l_account_number,6,1)* 1),2,1),0)
	    + nvl(substr((substr(l_account_number,7,1)* 2),1,1),0)
	    + nvl(substr((substr(l_account_number,7,1)* 2),2,1),0)
	    + nvl(substr((substr(l_account_number,8,1)* 1),1,1),0)
	    + nvl(substr((substr(l_account_number,8,1)* 1),2,1),0)
	    + nvl(substr((substr(l_account_number,9,1)* 2),1,1),0)
 	    + nvl(substr((substr(l_account_number,9,1)* 2),2,1),0)
	    + nvl(substr((substr(l_account_number,10,1)* 1),1,1),0)
	    + nvl(substr((substr(l_account_number,10,1)* 1),2,1),0)
	    + nvl(substr((substr(l_account_number,11,1)* 2),1,1),0)
	    + nvl(substr((substr(l_account_number,11,1)* 2),2,1),0)
	    + nvl(substr((substr(l_account_number,12,1)* 1),1,1),0)
	    + nvl(substr((substr(l_account_number,12,1)* 1),2,1),0)
	    + nvl(substr((substr(l_account_number,13,1)* 2),1,1),0)
	    + nvl(substr((substr(l_account_number,13,1)* 2),2,1),0) ;

    IF l_calc < 10 THEN
    	l_calc := 10 - l_calc ;

    ELSIF mod(l_calc,10) = 0 THEN
     	l_calc := 0 ;
    ELSE
     	l_calc :=l_calc + 10 - (mod(l_calc,10) + l_calc ) ;
   END IF;
   -- Verify the Validation Code
   --

   IF substr(l_account_number,14,1)= 	l_calc THEN
   		return 0;
   ELSE
   		return  1 ;
   END IF;
 END ;

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
-- This function will get called from the bank keyflex field segments  Bug 9127776
----
FUNCTION validate_account_entered
(p_acc_no        IN VARCHAR2,
 p_is_iban_acc   IN varchar2 ) RETURN NUMBER IS
   --
   l_ret NUMBER ;
 begin
--  hr_utility.trace_on(null,'ACCVAL');
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


FUNCTION get_retirement_information
 ( p_person_id        IN NUMBER
 , p_date	      IN DATE
 , p_retire_information_code IN VARCHAR2 )
 RETURN VARCHAR2 AS
 l_dob		Date;
 l_retire_date	VARCHAR2(150) ;
 l_return_value	VARCHAR2(150) ;

CURSOR c_retire IS
SELECT DATE_OF_BIRTH,PER_INFORMATION8
FROM PER_ALL_PEOPLE_F
WHERE PERSON_ID=p_person_id
AND p_date between EFFECTIVE_START_DATE and EFFECTIVE_END_DATE ;
 BEGIN
	 OPEN  c_retire;
	 FETCH c_retire INTO l_dob,l_retire_date;
	 CLOSE c_retire;
	 IF  p_retire_information_code='RD' THEN
		l_return_value :=l_retire_date;
	 ELSIF p_retire_information_code='RA' THEN
		l_return_value :=FLOOR((fnd_date.canonical_to_date(l_retire_date)-l_dob)/365);
	 END IF;
	 RETURN l_return_value;

 END get_retirement_information;


 -- Checks whether the input is a valid date.
 --
 FUNCTION chk_valid_date (p_date IN VARCHAR2,p_century IN VARCHAR2 )
 RETURN VARCHAR2
 AS
 l_date DATE;
 l_century NUMBER;
 BEGIN
 	IF p_century='+'   THEN
   		l_century:=18 ;
 	ELSIF p_century='-'  THEN
		l_century:=19 ;
	ELSIF p_century='A'   THEN
		l_century:=20 ;
	ELSE
		 RETURN '0' ;
	END IF;
	l_date:=to_date(substr(p_date,1,4)||l_century||substr(p_date,5,2),'DDMMYYYY');
 	RETURN '1';
 exception
 		WHEN others THEN
 		RETURN '0';
 	end ;

-- Function    :  get_employment_information
-- Parameters  : assignment_id  -  p_assignment_id,
--		 employment information code - l_information_code.
-- Description : The function returns the employment information based on the assignment id
--		 and the information code parameters. The information is first searced for at
--		 the assignment level through the HR_Organization level , Local Unit level ,
--		 Legal Employer Level to the Business group level.
--
-- The values for  p_emp_information_code can be
--		FI_EMPLOYMENT_TYPE  for Employment Type
--		FI_WORKING_TIME_TYPE	for Working Time Type
--		FI_SHIFT_WORK_TYPE for Shift Work Type
--		FI_SHIFT_WORK_TYPE_DAYS for Shift Work Type Days
--		FI_COM_PRICE_CAT  for Community Price Category
--		FI_EMPLOYEE_STATUS  for  Employee Status
--		FI_PERSONNEL_GRP for Personnel Group
--		FI_INS_OCC_GRP for Insurance Occupational Group
--		FI_EMPR_OCC_GRP forEmployer Union Occupational Group


function get_employment_information
(p_assignment_id        IN NUMBER
,p_emp_information_code IN VARCHAR2 ) RETURN VARCHAR2 IS
	-- local variables declaration --
	l_scl_id  NUMBER(5);
	l_information varchar2(150);
	l_local_unit number(15);
	l_legal_employer number(15);
	l_org_id number(15);
	l_bg_id  number(15);
	l_information_code varchar2(50);
	l_organization_id  number(15);

	cursor get_scl_id is
	select SOFT_CODING_KEYFLEX_ID
	from  PER_ALL_ASSIGNMENTS_F
	where assignment_id = p_assignment_id;

	cursor get_info_from_scl  is
	select lookups.meaning
	from HR_SOFT_CODING_KEYFLEX scl, hr_lookups lookups
	where scl.SOFT_CODING_KEYFLEX_ID = l_scl_id
	and lookups.lookup_type=l_information_code
	and lookups.enabled_flag = 'Y'
	and lookups.lookup_code = decode(l_information_code,'FI_EMPLOYMENT_TYPE',scl.segment3,
				   'FI_WORKING_TIME_TYPE',scl.segment4,
				   'FI_SHIFT_WORK_TYPE',scl.segment5,
				   'FI_SHIFT_WORK_TYPE_DAYS',scl.segment6,
				   'FI_COM_PRICE_CAT',scl.segment7,
				   'FI_EMPLOYEE_STATUS',scl.segment8,
				   'FI_PERSONNEL_GRP',scl.segment9,
				   'FI_INS_OCC_GRP',scl.segment10,
				   'FI_EMPR_OCC_GRP',scl.segment11,null);


	cursor get_local_unit is
	 select segment2
	 from hr_soft_coding_keyflex
	 where soft_coding_keyflex_id = l_scl_id;


	cursor get_info_from_local_unit is
	select lookups.meaning
	from hr_organization_information hoi , hr_lookups lookups
	where hoi.organization_id = l_org_id
	and hoi.org_information_context = 'FI_EMPLOYMENT_DEFAULTS'
	and lookups.lookup_type = l_information_code
	and lookups.enabled_flag = 'Y'
	and lookups.lookup_code = decode(l_information_code,'FI_EMPLOYMENT_TYPE',hoi.org_information1,
				   'FI_WORKING_TIME_TYPE',hoi.org_information2,
				   'FI_SHIFT_WORK_TYPE',hoi.org_information3,
				   'FI_SHIFT_WORK_TYPE_DAYS',hoi.org_information4,
				   'FI_COM_PRICE_CAT',hoi.org_information5,null);

	cursor get_legal_employer is
	select hoi2.organization_id
	from hr_organization_information hoi1 , hr_organization_information hoi2
	where hoi1.org_information1 = to_char(l_local_unit) and hoi1.org_information_context = 'FI_LOCAL_UNITS'
	and hoi2.org_information_context = 'CLASS' and hoi2.org_information1 = 'HR_LEGAL_EMPLOYER'
	and hoi2.organization_id = hoi1.organization_id;

	cursor get_info_from_org is
		select lookups.meaning
		from hr_organization_units hou, hr_organization_information hoi , hr_lookups lookups
		where hou.organization_id = l_organization_id
		and hou.organization_id = hoi.organization_id
		and hoi.org_information_context = 'FI_EMPLOYMENT_DEFAULTS'
		and lookups.lookup_type = l_information_code
		and lookups.enabled_flag = 'Y'
		and lookups.lookup_code = decode(l_information_code,'FI_EMPLOYMENT_TYPE',hoi.org_information1,
				   'FI_WORKING_TIME_TYPE',hoi.org_information2,
				   'FI_SHIFT_WORK_TYPE',hoi.org_information3,
				   'FI_SHIFT_WORK_TYPE_DAYS',hoi.org_information4,
				   'FI_COM_PRICE_CAT',hoi.org_information5,null);

	cursor get_bg_id is
	select business_group_id
	from hr_organization_units
	where organization_id = l_organization_id;


	begin

	if p_emp_information_code not in ('EMPLOYMENT_TYPE','WORKING_TIME_TYPE',
			'SHIFT_WORK_TYPE','SHIFT_WORK_DAYS','COM_PRICE_CAT','EMPLOYEE_STATUS','PERSONNEL_GRP','INS_OCC_GRP','EMPR_OCC_GRP') then
		return 'ERR_WRONG_PARAMETER';
	end if;

	l_information_code := 'FI_'||p_emp_information_code;

	---------------------------------------------------------------------------------
	--     To return information other than Agreed working hours	   --
	---------------------------------------------------------------------------------


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

	if p_emp_information_code in ('EMPLOYMENT_TYPE','WORKING_TIME_TYPE','SHIFT_WORK_TYPE','SHIFT_WORK_DAYS','COM_PRICE_CAT') then
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

	end if;
	end get_employment_information;

------------------------------------------------------------------------
-- Function GET_VEHICLE_INFORMATION
-- This function is used to obtain vehicle information.
-- The input parameters are assignment id , business group and effective date.
-- The information being returned via out parameters are model year ,price
-- and engine capacity (cc).
------------------------------------------------------------------------



	FUNCTION get_vehicle_information
	(p_assignment_id                 in     number
	,p_business_group_id             in     number
	,p_effective_date                in     date
	,p_vehicle_allot_id		 in	varchar2
	,p_model_year                    out nocopy number
	,p_price                         out nocopy number
	,p_engine_capacity_in_cc         out nocopy number
	,p_vehicle_type			 out nocopy varchar2
	) RETURN NUMBER
	AS

		CURSOR get_vehicle_information IS
		SELECT NVL(a.model_year,0)
		, nvl(a.list_price,0)
		+ nvl(a.accessory_value_at_startdate,0)
		+ nvl(a.accessory_value_added_later ,0)
		, a.engine_capacity_in_cc
		, a.vehicle_type
		FROM pqp_vehicle_repository_f  a , pqp_vehicle_allocations_f b
		WHERE a.VEHICLE_REPOSITORY_ID  = b.VEHICLE_REPOSITORY_ID
		AND  p_effective_date between b.effective_start_date
		AND  b.effective_end_date
		AND  p_effective_date between a.effective_start_date
		AND  a.effective_end_date
		AND  b.assignment_id             =  p_assignment_id
		AND  b.business_group_id         =  p_business_group_id
		AND  b.vehicle_allocation_id     =  p_vehicle_allot_id;

	BEGIN
		OPEN get_vehicle_information ;
			FETCH get_vehicle_information INTO p_model_year , p_price , p_engine_capacity_in_cc, p_vehicle_type  ;
		CLOSE get_vehicle_information ;

		RETURN 1 ;


	EXCEPTION
	WHEN OTHERS THEN
		p_model_year := 0;
		p_price := 0;
		p_engine_capacity_in_cc := 0;
	END;

------------------------------------------------------------------------
-- Function GET_MESSAGE
-- This function is used to obtain a message.
-- The token parameters must be of the form 'TOKEN_NAME:TOKEN_VALUE' i.e.
-- If you want to set the value of a token called ELEMENT to Social Ins
-- the token parameter would be 'ELEMENT:Social Ins.'
------------------------------------------------------------------------
	function get_message
			(p_product           in varchar2
			,p_message_name      in varchar2
			,p_token1            in varchar2 default null
                        ,p_token2            in varchar2 default null
                        ,p_token3            in varchar2 default null) return varchar2
			is
			   l_message varchar2(2000);
			   l_token_name varchar2(20);
			   l_token_value varchar2(80);
			   l_colon_position number;
			   l_proc varchar2(72) := g_package||'.get_message';
	--
	begin
	--
	   hr_utility.set_location('Entered '||l_proc,5);
	   hr_utility.set_location('.  Message Name: '||p_message_name,40);
	   fnd_message.set_name(p_product, p_message_name);
	   if p_token1 is not null then
	      /* Obtain token 1 name and value */
	      l_colon_position := instr(p_token1,':');
	      l_token_name  := substr(p_token1,1,l_colon_position-1);
	      l_token_value := substr(p_token1,l_colon_position+1,length(p_token1));
	      fnd_message.set_token(l_token_name, l_token_value);
	      hr_utility.set_location('.  Token1: '||l_token_name||'. Value: '||l_token_value,50);
	   end if;
	   if p_token2 is not null  then
	      /* Obtain token 2 name and value */
	      l_colon_position := instr(p_token2,':');
	      l_token_name  := substr(p_token2,1,l_colon_position-1);
	      l_token_value := substr(p_token2,l_colon_position+1,length(p_token2));
	      fnd_message.set_token(l_token_name, l_token_value);
	      hr_utility.set_location('.  Token2: '||l_token_name||'. Value: '||l_token_value,60);
	   end if;
	   if p_token3 is not null then
	      /* Obtain token 3 name and value */
	      l_colon_position := instr(p_token3,':');
	      l_token_name  := substr(p_token3,1,l_colon_position-1);
	      l_token_value := substr(p_token3,l_colon_position+1,length(p_token3));
	      fnd_message.set_token(l_token_name, l_token_value);
	      hr_utility.set_location('.  Token3: '||l_token_name||'. Value: '||l_token_value,70);
	   end if;
	   l_message := substr(fnd_message.get,1,254);
	   hr_utility.set_location('leaving '||l_proc,100);
	   return l_message;
	end get_message;

------------------------------------------------------------------------
-- Function get_dependent_number
-- This function is used to obtain the number of dependents of a person.
------------------------------------------------------------------------

FUNCTION get_dependent_number
(p_assignment_id		IN      NUMBER
,p_business_group_id		IN      NUMBER
,p_process_date			IN      DATE
) RETURN NUMBER IS

	l_dependent_number NUMBER;

BEGIN

	SELECT COUNT(distinct(c.contact_person_id))
	INTO l_dependent_number
	FROM per_contact_relationships c
	WHERE c.person_id = (SELECT b.person_id from per_all_assignments_f b
	WHERE b.assignment_id = p_assignment_id
	AND p_process_date between b.effective_start_date AND b.effective_end_date
	)
	AND c.dependent_flag = 'Y'
	AND c.business_group_id = p_business_group_id;

	RETURN l_dependent_number;


 EXCEPTION
 		WHEN others THEN
 		RETURN NULL;
 END get_dependent_number;


-----------------------------------------------------------------------------------------------------------+++
------------------------------------------------------------------------
-- Function check_Contract_Reasons
-- This function is used to check_Contract_Reasons
------------------------------------------------------------------------
-- Added enhancements w.r.t Bug 8425533

FUNCTION check_Contract_Reasons
(p_assignment_id		IN      NUMBER
 ,p_contract_type                IN      VARCHAR2
) RETURN NUMBER IS

	l_reasons_value NUMBER;

        CURSOR csr_chk_contract_reasons(
	csr_v_assignment_id     NUMBER,
	csr_v_information_type  VARCHAR2
	) IS
	SELECT AEI_INFORMATION1 Reason
        FROM per_assignment_extra_info
        WHERE assignment_id = csr_v_assignment_id
        AND INFORMATION_TYPE = csr_v_information_type;

	lr_chk_reasons  csr_chk_contract_reasons%ROWTYPE;


	CURSOR csr_soft_coded_keyflex_info (
         csr_v_soft_coding_keyflex_id        hr_soft_coding_keyflex.soft_coding_keyflex_id%TYPE
         ) IS
         SELECT SEGMENT3 l_Employment_Type,
	        SEGMENT4 l_Working_Time_Type
         FROM hr_soft_coding_keyflex
         WHERE soft_coding_keyflex_id = csr_v_soft_coding_keyflex_id;

         lr_soft_coded_keyflex_info     csr_soft_coded_keyflex_info%ROWTYPE;


	 CURSOR csr_get_soft_coded_kf_id (
	 csr_v_assignment_id  NUMBER
	 ) IS
	 SELECT max(SOFT_CODING_KEYFLEX_ID) l_soft_code_kf_id
         FROM per_all_assignments_f
	 WHERE assignment_id = csr_v_assignment_id;

	 lr_soft_coded_kf_id   csr_get_soft_coded_kf_id%ROWTYPE;

 BEGIN
        OPEN csr_get_soft_coded_kf_id(p_assignment_id);
	FETCH csr_get_soft_coded_kf_id INTO lr_soft_coded_kf_id;
	CLOSE csr_get_soft_coded_kf_id;

	OPEN csr_soft_coded_keyflex_info(lr_soft_coded_kf_id.l_soft_code_kf_id);
	FETCH csr_soft_coded_keyflex_info INTO lr_soft_coded_keyflex_info;
	CLOSE csr_soft_coded_keyflex_info;



	IF p_contract_type = 'Time-Fixed' THEN

	OPEN csr_chk_contract_reasons(p_assignment_id,'FI_EMPLOYMENT_TYPE_REASON');
	FETCH csr_chk_contract_reasons INTO lr_chk_reasons;
	CLOSE csr_chk_contract_reasons;

		IF lr_soft_coded_keyflex_info.l_Employment_Type = 2 AND  lr_chk_reasons.Reason IS NULL THEN
		l_reasons_value := 0;
		ELSE
		l_reasons_value := 1;
		END IF;
        END IF;

        IF p_contract_type = 'Part-Time' THEN

	OPEN csr_chk_contract_reasons(p_assignment_id,'FI_WORKING_TIME_TYPE_REASON');
	FETCH csr_chk_contract_reasons INTO lr_chk_reasons;
	CLOSE csr_chk_contract_reasons;

		IF lr_soft_coded_keyflex_info.l_Working_Time_Type = 5 AND  lr_chk_reasons.Reason IS NULL THEN
		l_reasons_value := 0;
		ELSE
		l_reasons_value := 1;
		END IF;
        END IF;


	RETURN l_reasons_value;

 EXCEPTION
 		WHEN others THEN
 		RETURN NULL;
 END check_Contract_Reasons;

-----------------------------------------------------------------------------------------------------------+++


------------------------------------------------------------------------
-- Function Court Order Details
-- This function is used to obtain the number of dependents of a person.
------------------------------------------------------------------------



FUNCTION get_court_order_details
 (p_assignment_id		IN          NUMBER
 ,p_effective_date		IN	   DATE
 ,p_dependent_number		OUT NOCOPY  NUMBER
 ,p_third_party			OUT NOCOPY  NUMBER
 ,p_court_order_amount		OUT NOCOPY  NUMBER
 ,p_periodic_installment	OUT NOCOPY  NUMBER
 ,p_number_of_installments	OUT NOCOPY  NUMBER
 ,p_suspension_flag		OUT NOCOPY  VARCHAR2
 ) RETURN NUMBER IS
  --

CURSOR get_details(p_assignment_id NUMBER , p_effective_date  DATE , p_input_value VARCHAR2 ) IS
   SELECT eev1.screen_entry_value  screen_entry_value
   FROM   per_all_assignments_f      asg1
         ,per_all_assignments_f      asg2
         ,per_all_people_f           per
         ,pay_element_links_f        el
         ,pay_element_types_f        et
         ,pay_input_values_f         iv1
         ,pay_element_entries_f      ee
         ,pay_element_entry_values_f eev1
   WHERE  asg1.assignment_id    = p_assignment_id
     AND p_effective_date BETWEEN asg1.effective_start_date AND asg1.effective_end_date
     AND p_effective_date BETWEEN asg2.effective_start_date AND asg2.effective_end_date
     AND p_effective_date BETWEEN ee.effective_start_date AND ee.effective_end_date
     AND p_effective_date BETWEEN eev1.effective_start_date AND eev1.effective_end_date
     AND  per.person_id         = asg1.person_id
     AND  asg2.person_id        = per.person_id
     AND  asg2.primary_flag     = 'Y'
     AND  et.element_name       = 'Court Order Information'
     AND  et.legislation_code   = 'FI'
     AND  iv1.element_type_id   = et.element_type_id
     AND  iv1.name              = p_input_value
     AND  el.business_group_id  = per.business_group_id
     AND  el.element_type_id    = et.element_type_id
     AND  ee.assignment_id      = asg2.assignment_id
     AND  ee.element_link_id    = el.element_link_id
     AND  eev1.element_entry_id = ee.element_entry_id
     AND  eev1.input_value_id   = iv1.input_value_id;

	l_rec get_details%ROWTYPE;
  --
 BEGIN
  --
  OPEN  get_details(p_assignment_id , p_effective_date ,'Dependent Number');
  FETCH get_details INTO l_rec;
  p_dependent_number             := l_rec.screen_entry_value ;
  CLOSE get_details;



  OPEN  get_details(p_assignment_id , p_effective_date , 'Third Party');
  FETCH get_details INTO l_rec;
  p_third_party             := l_rec.screen_entry_value ;
  CLOSE get_details;



  OPEN  get_details(p_assignment_id , p_effective_date ,'Court Order Amount');
  FETCH get_details INTO l_rec;
  p_court_order_amount       := l_rec.screen_entry_value ;
  CLOSE get_details;



  OPEN  get_details(p_assignment_id , p_effective_date ,'Periodic Installment');
  FETCH get_details INTO l_rec;
  p_periodic_installment       := l_rec.screen_entry_value ;
  CLOSE get_details;



  OPEN  get_details(p_assignment_id , p_effective_date ,'Number Of Installments');
  FETCH get_details INTO l_rec;
  p_number_of_installments       := l_rec.screen_entry_value ;
  CLOSE get_details;



  OPEN  get_details(p_assignment_id , p_effective_date ,'Suspension Flag');
  FETCH get_details INTO l_rec;

  p_suspension_flag        := l_rec.screen_entry_value ;

  CLOSE get_details;


  --
  RETURN 1;
  --
 END get_court_order_details;

------------------------------------------------------------------------
-- Function union details
-- This function is used to obtain the trade union details of a person.
------------------------------------------------------------------------

FUNCTION get_union_details
(p_assignment_id		IN         NUMBER
,p_effective_date		IN	   DATE
,p_fixed_union_fees		OUT NOCOPY NUMBER
,p_percentage_union_fees        OUT NOCOPY NUMBER
,p_payment_calculation_mode     OUT NOCOPY VARCHAR2
) RETURN NUMBER IS

	CURSOR get_details(p_assignment_id NUMBER ,p_effective_date DATE ) IS
	select hoi2.org_information2,hoi2.org_information3,hoi2.org_information4,pap1.per_information11
		       , pap1.per_information12 , pap1.per_information13
		 from HR_ORGANIZATION_UNITS o1
		, HR_ORGANIZATION_INFORMATION hoi1
		, HR_ORGANIZATION_INFORMATION hoi2
		, per_all_people_f             pap1
		, per_all_assignments_f        paa
		WHERE hoi1.organization_id = o1.organization_id
		and hoi1.org_information1 = 'FI_TRADE_UNION'
		and hoi1.org_information_context = 'CLASS'
		and hoi2.ORG_INFORMATION_CONTEXT='FI_TRADE_UNION_DETAILS'
		and o1.organization_id = pap1.per_information9
                and hoi1.organization_id = hoi2.organization_id
		AND pap1.person_id = paa.person_id
	        AND o1.business_group_id = paa.business_group_id
		AND p_effective_date BETWEEN paa.effective_start_date AND paa.effective_end_date
 		AND  p_effective_date BETWEEN nvl(fnd_date.canonical_to_date(pap1.per_information18),
     hr_general.start_of_time) AND nvl(fnd_date.canonical_to_date(pap1.per_information19),
     hr_general.end_of_time)
		AND paa.assignment_id = p_assignment_id;

		l_rec get_details%ROWTYPE;
--
BEGIN

	OPEN get_details(p_assignment_id , p_effective_date);
	FETCH get_details into l_rec;
	CLOSE get_details;
	IF l_rec.per_information11 is null THEN
		p_fixed_union_fees	:=    l_rec.org_information3 ;
		p_percentage_union_fees :=    l_rec.org_information4 ;
		p_payment_calculation_mode := l_rec.org_information2 ;
	ELSE
			p_payment_calculation_mode := l_rec.per_information11;
			IF l_rec.per_information12  IS NULL THEN
				p_fixed_union_fees :=    l_rec.org_information3 ;
			ELSE

				p_fixed_union_fees :=   l_rec.per_information12 ;
			END IF;

			IF l_rec.per_information13  IS NULL THEN
				p_percentage_union_fees :=    l_rec.org_information4 ;
			ELSE

				p_percentage_union_fees :=   l_rec.per_information13 ;
			END IF;

	END IF;

	IF p_payment_calculation_mode is null THEN
		p_payment_calculation_mode :='N';
	END IF;

	RETURN 1;

EXCEPTION
 		WHEN others THEN
 		RETURN NULL;

END get_union_details;

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


END;

/
