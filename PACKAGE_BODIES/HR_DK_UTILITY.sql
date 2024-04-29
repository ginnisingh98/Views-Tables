--------------------------------------------------------
--  DDL for Package Body HR_DK_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DK_UTILITY" AS
/* $Header: hrdkutil.pkb 120.4.12010000.3 2009/11/20 07:20:40 dchindar ship $ */
   --
   --
   --
   -- Function to Formate the Full Name for Denmark
   --

FUNCTION per_dk_full_name(
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
   -- <last name><,> <middle name> <first name> <initials>
   --
   -- Modifed for bug fix 4666216
   -- Now Construct the full name which has the following format:
   --
   -- <last name><,> <first name> <middle name> <initials>


      SELECT SUBSTR(TRIM(
             TRIM(p_last_name)
	   || ', '
           ||TRIM(p_first_name)
           ||' '
	   ||TRIM(p_middle_name)
	   ||' '
	   ||TRIM(p_per_information1))
           , 1, 240)
       INTO   l_full_name
       FROM   dual;

   --
   --
   -- Return Full name
   --

      RETURN l_full_name;
   --
  END per_dk_full_name;


   --
   --
   --
   -- Function to Formate the Order Name for Denmark
   --
FUNCTION per_dk_order_name(
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
   -- <last name>,<first name>,<middle name>
   --
   --

      SELECT SUBSTR(TRIM(p_last_name)||','||TRIM(p_first_name) ||
		    DECODE(TRIM(P_MIDDLE_NAME),NULL,'', ',' || TRIM(p_middle_name)), 1, 240)
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
END per_dk_order_name;


 -- Validates the bank account number.
 --
 -- The format is as follows NNNNNNNNNN


 FUNCTION validate_account_number
 (p_account_number IN VARCHAR2) RETURN NUMBER IS
 	l_i NUMBER;
 	l_rem NUMBER;
 	l_strlen NUMBER;
 	l_valid NUMBER;
 	l_account_number VARCHAR2(15);
 BEGIN
   --
   -- Bug 4124370 , an account number less than 10 digits should be allowed
   IF LENGTH(p_account_number) >  10 THEN
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
    ELSE
  	 		RETURN 0 ;
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
-- This function will get called from the bank keyflex field segments  Bug 9127804
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
RETURN VARCHAR2
IS


L_CENTURY NUMBER(2);
L_NAT_ID_YY NUMBER(2);  --YY PART OF CPR NUMBER
L_NAT_ID_CD NUMBER(1);  --DIGIT CORRESPONDING TO CENTURY IN CPR NUMBER
L_DATE DATE;

BEGIN


	L_NAT_ID_YY := 	TO_NUMBER(SUBSTR(p_nat_id,5,2));
	L_NAT_ID_CD := 	TO_NUMBER(SUBSTR(p_nat_id,8,1));

	IF L_NAT_ID_CD <= 3 THEN
	    L_CENTURY := 19;
	ELSIF L_NAT_ID_CD = 4 THEN
	    IF L_NAT_ID_YY <= 36 THEN
		L_CENTURY := 20;
	    ELSE
		L_CENTURY := 19;
	    END IF;
	ELSIF L_NAT_ID_CD = 5 THEN
	    IF L_NAT_ID_YY <= 36 THEN
		L_CENTURY := 20;
	    ELSIF L_NAT_ID_YY >=58 THEN
	    	L_CENTURY := 18;
	    ELSE
		RETURN '0';
	    END IF;
	ELSIF L_NAT_ID_CD = 6 THEN
	    IF L_NAT_ID_YY <= 36 THEN
		L_CENTURY := 20;
	    ELSIF L_NAT_ID_YY >=58 THEN
	    	L_CENTURY := 18;
	    ELSE
		RETURN '0';
	    END IF;
  	ELSIF L_NAT_ID_CD = 7 THEN
	    IF L_NAT_ID_YY <= 36 THEN
		L_CENTURY := 20;
	    ELSIF L_NAT_ID_YY >=58 THEN
	    	L_CENTURY := 18;
	    ELSE
		RETURN '0';
	    END IF;
	ELSIF L_NAT_ID_CD = 8 THEN
	    IF L_NAT_ID_YY <= 36 THEN
		L_CENTURY := 20;
	    ELSIF L_NAT_ID_YY >=58 THEN
	    	L_CENTURY := 18;
	    ELSE
		RETURN '0';
	    END IF;
	ELSIF L_NAT_ID_CD = 9 THEN
	    IF L_NAT_ID_YY <= 36 THEN
		L_CENTURY := 20;
	    ELSE
		L_CENTURY := 19;
	    END IF;
	END IF;


       l_date := to_date(substr(p_nat_id,1,4)||l_century||substr(p_nat_id,5,2),'DDMMYYYY');
       RETURN TO_CHAR(L_DATE,'DDMMYYYY');
EXCEPTION
               WHEN others THEN
               RETURN '0';
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
--		COND_OF_EMP for Condition of Employment
--		EMP_GROUP for Employee Group


FUNCTION get_employment_information (
			p_assignment_id  IN number,
			p_emp_information_code IN varchar2 )
			RETURN VARCHAR2 IS

	-- local variables declaration --
	l_scl_id  NUMBER(5);
	l_organization_id Number(15);
	l_is_hr_org  varchar2(150);
	l_information varchar2(150);
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
		and lookups.lookup_code = decode(l_information_code,'DK_COND_OF_EMP',scl.segment3,
													   'DK_EMP_GROUP',scl.segment4,NULL);

	cursor get_info_from_org is
		select lookups.meaning
		from hr_organization_units hou, hr_organization_information hoi , hr_lookups lookups
		where hou.organization_id = l_organization_id
		and hou.organization_id = hoi.organization_id
		and hoi.org_information_context = 'DK_EMPLOYMENT_DEFAULTS'
		and lookups.lookup_type = l_information_code
		and lookups.enabled_flag = 'Y'
		and lookups.lookup_code = decode(l_information_code,'DK_COND_OF_EMP',hoi.org_information1,
													   'DK_EMP_GROUP',hoi.org_information2,NULL);

	cursor get_legal_employer is
		 select segment2
		 from hr_soft_coding_keyflex
		 where soft_coding_keyflex_id = l_scl_id;


	cursor get_info_from_legal_employer is
		select lookups.meaning
		from hr_organization_information hoi , hr_lookups lookups
		where hoi.organization_id = l_org_id
		and hoi.org_information_context = 'DK_EMPLOYMENT_DEFAULTS'
		and lookups.lookup_type = l_information_code
		and lookups.enabled_flag = 'Y'
		and lookups.lookup_code = decode(l_information_code,'DK_COND_OF_EMP',hoi.org_information1,
													   'DK_EMP_GROUP',hoi.org_information2,NULL);

	cursor get_bg_id is
		select business_group_id
		from hr_organization_units
		where organization_id = l_organization_id;

	cursor is_hr_org is
		select nvl(hoi.org_information1,'NO_DATA')
		from hr_organization_units hou , hr_organization_information hoi
		where hou.organization_id = l_organization_id
		and hou.organization_id = hoi.organization_id
		and hoi.org_information_context = 'CLASS'
		and hoi.org_information1 = 'HR_ORG';



	begin

	if l_information_code not in ('COND_OF_EMP','EMP_GROUP') then
		return 'ERR_WRONG_PARAMETER';
	end if;

	l_information_code := 'DK_'||p_emp_information_code;

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



		-------------------------------------------
		--Try at the Legal Employer Level --
		--------------------------------------------
		-- get legal employer id --
		open get_legal_employer;
		fetch get_legal_employer into l_legal_employer;
		close get_legal_employer;

		-- get information at local unit level --
		l_org_id := l_legal_employer;
		open get_info_from_legal_employer;
		fetch get_info_from_legal_employer into l_information;
		close get_info_from_legal_employer;

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


	END get_employment_information;


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
			   --l_proc varchar2(72) := g_package||'.get_message';
	--
	begin
	--
	   --hr_utility.set_location('Entered '||l_proc,5);
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
	   --hr_utility.set_location('leaving '||l_proc,100);
	   return l_message;
	end get_message;

-----------------------------------------------------------

FUNCTION REPLACE_SPECIAL_CHARS(p_xml IN VARCHAR2)
RETURN VARCHAR2
IS
l_xml VARCHAR2(240);
BEGIN
/* Handle special charaters in data */

If p_xml is not null then
    l_xml := '<![CDATA['||p_xml||']]>';  /*Remove the Space*/
end if;

RETURN l_xml;

END REPLACE_SPECIAL_CHARS;

--------------------------------------------------------------


   --
   -- End of the Package

END hr_dk_utility;


/
