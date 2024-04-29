--------------------------------------------------------
--  DDL for Package Body PAY_KW_GENERAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KW_GENERAL" as
/* $Header: pykwgenr.pkb 120.2.12010000.2 2008/09/23 12:59:02 bkeshary ship $ */
	g_package varchar2(30);
	l_organization_id hr_all_organization_units.organization_id%type;
	l_person_id per_all_people_f.person_id%type;
	l_nationality_cd hr_lookups.meaning%type;
	l_nationality_person per_all_people_f.nationality%type;
------------------------------------------------------------------------
-- Function LOCAL_NATIONALITY_NOT_DEFINED
-- This function return NOTEXISTS If the value for HR: Local Nationality
-- Profile has not been defined else it retuns EXISTS.
------------------------------------------------------------------------
	function local_nationality_not_defined (p_business_group_id IN number) return varchar2
	is
	begin
		BEGIN
/*			l_organization_id := FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID');*/
/* Added context business group id */
			l_organization_id := p_business_group_id;
			Select Org_Information1
			Into l_nationality_cd
			From HR_ORGANIZATION_INFORMATION
			Where ORG_INFORMATION_CONTEXT = 'KW_BG_DETAILS'
			And ORGANIZATION_ID = l_organization_id;
		EXCEPTION
			WHEN no_data_found Then
			Null;
		END;
		if l_nationality_cd is null then
			return 'NOTEXISTS';
		else
			return 'EXISTS';
		end if;
/****		if FND_PROFILE.VALUE('PER_LOCAL_NATIONALITY') is null then
			return 'NOTEXISTS';
		else
			return 'EXISTS';
		end if;
****/
	end local_nationality_not_defined;
------------------------------------------------------------------------
-- Function LOCAL_NATNATIONALITY_MATCHES
-- This function return NOMATCH If the value for HR: Local Nationality
-- Profile does not match with the person's nationality else it retuns MATCH.
------------------------------------------------------------------------
	function local_nationality_matches
	(p_assignment_id IN per_all_assignments_f.assignment_id%type,
	 p_date_earned IN Date)
	 return varchar2
	is
	begin
		BEGIN
			Select person_id
			Into l_person_id
			From PER_ALL_ASSIGNMENTS_F
			Where ASSIGNMENT_ID = p_assignment_id
			AND p_date_earned between EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE;
		EXCEPTION
			WHEN no_data_found Then
			Null;
		END;
		BEGIN
			Select Nationality
			Into l_nationality_person
			From PER_ALL_PEOPLE_F
			Where PERSON_ID = l_person_id
			AND p_date_earned between EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE;
		EXCEPTION
			WHEN no_data_found Then
			Null;
		END;
		if l_nationality_cd = l_nationality_person then
			return 'MATCH';
		else
			return 'NOMATCH';
		end if;
	end local_nationality_matches;
------------------------------------------------------------------------
-- Function GET_LOCAL_NATIONALITY
-- This function is used to obtain a the local nationality defined at
-- the Business Group Level.
------------------------------------------------------------------------
function get_local_nationality return varchar2
is
l_nationality hr_lookups.meaning%type;
begin
	l_nationality := hr_general.decode_lookup('NATIONALITY',l_nationality_cd);
	RETURN l_nationality;
END get_local_nationality;
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
			   l_proc varchar2(72) ;
	--
	begin
	g_package := 'pay_kw_general';
	l_proc := g_package||'.get_message';
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
-- Function GET_TABLE_BANDS
-- This function is used to obtain User table's high and low values.
------------------------------------------------------------------------
	function get_table_bands
			(p_Date_Earned  IN DATE
			,p_table_name        in varchar2
			,p_return_type       in varchar2) return number
			is
			 CURSOR csr_get_user_table_id(l_table_name  varchar2) IS
			 SELECT user_table_id
			 FROM   pay_user_tables
			 WHERE  legislation_code='KW'
	  		 AND    UPPER(user_table_name) = UPPER(l_table_name);
	  		 CURSOR csr_get_min_low (l_user_table_id  NUMBER, l_effective_date DATE) IS
			 SELECT MIN(fnd_number.canonical_to_number(row_low_range_or_name))
			 FROM   pay_user_rows_f
			 WHERE  user_table_id = l_user_table_id
			 AND    legislation_code = 'KW'
	  		 AND    l_effective_date BETWEEN effective_start_date AND effective_end_date;
			 CURSOR csr_get_min_high (l_user_table_id  number ,l_effective_date DATE ) IS
			 SELECT MIN(fnd_number.canonical_to_number(row_high_range))
			 FROM   pay_user_rows_f
			 WHERE  user_table_id = l_user_table_id
			 AND    legislation_code = 'KW'
	  		 AND    l_effective_date BETWEEN effective_start_date AND effective_end_date;
	  		 CURSOR csr_get_max_high (l_user_table_id  number, l_effective_date DATE) IS
			 SELECT MAX(fnd_number.canonical_to_number(row_high_range))
			 FROM   pay_user_rows_f
			 WHERE  user_table_id = l_user_table_id
			 AND    legislation_code = 'KW'
  		 	 AND    l_effective_date BETWEEN effective_start_date AND effective_end_date;
  		 	 l_ret_val number(15,3);
  		 	 l_table_id number(9);
   		       l_proc varchar2(72) ;
	--
	begin
	g_package := 'pay_kw_general';
	l_proc := g_package||'.get_table_bands';
	--
	   hr_utility.set_location('Entered '||l_proc,5);
	   -- Get the User Table ID
	   OPEN csr_get_user_table_id(p_table_name);
	   FETCH csr_get_user_table_id INTO l_table_id;
	   CLOSE csr_get_user_table_id;
	   --
	   IF p_return_type = 'MIN_LOW' THEN
	   OPEN csr_get_min_low (l_table_id,p_Date_Earned);
	   FETCH csr_get_min_low INTO l_ret_val;
	   CLOSE csr_get_min_low;
	   ELSIF p_return_type = 'MIN_HIGH' THEN
	   OPEN csr_get_min_high (l_table_id,p_Date_Earned);
	   FETCH csr_get_min_high INTO l_ret_val;
	   CLOSE csr_get_min_high;
	   ELSIF p_return_type = 'MAX_HIGH' THEN
	   OPEN csr_get_max_high (l_table_id, p_Date_Earned);
	   FETCH csr_get_max_high INTO l_ret_val;
	   CLOSE csr_get_max_high;
	   END IF;
	   return l_ret_val;
	end get_table_bands;
-----------------------------------------------------------------------
-- Functions for EFT file
-----------------------------------------------------------------------
 -----------------------------------------------------------------------------
 -- GET_PARAMETER  used in SQL to decode legislative parameters
 -----------------------------------------------------------------------------
 FUNCTION get_parameter(
                 p_parameter_string  IN VARCHAR2
                ,p_token             IN VARCHAR2
                ,p_segment_number    IN NUMBER DEFAULT NULL ) RETURN VARCHAR2
 IS
   l_parameter  pay_payroll_actions.legislative_parameters%TYPE:=NULL;
   l_start_pos  NUMBER;
   l_delimiter  varchar2(1):=' ';
   l_proc VARCHAR2(60):= g_package||' get parameter ';
 BEGIN
   l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');
   IF l_start_pos = 0 THEN
     l_delimiter := '|';
     l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');
   end if;
   IF l_start_pos <> 0 THEN
     l_start_pos := l_start_pos + length(p_token||'=');
     l_parameter := substr(p_parameter_string,
                           l_start_pos,
                           instr(p_parameter_string||' ',
                           ',',l_start_pos)
                           - l_start_pos);
     IF p_segment_number IS NOT NULL THEN
       l_parameter := ':'||l_parameter||':';
       l_parameter := substr(l_parameter,
                             instr(l_parameter,':',1,p_segment_number)+1,
                             instr(l_parameter,':',1,p_segment_number+1) -1
                             - instr(l_parameter,':',1,p_segment_number));
     END IF;
   END IF;
   RETURN l_parameter;
 END get_parameter;
 --
 FUNCTION  chk_multiple_assignments(p_effective_date IN DATE
                                   ,p_person_id     IN NUMBER) RETURN VARCHAR2 AS
   CURSOR get_multiple_assgts IS
   SELECT count(DISTINCT paf.assignment_id)
   FROM   per_all_assignments_f paf
         ,per_assignment_status_types pas
   WHERE  paf.assignment_type    = 'E'
   AND    paf.PERSON_ID          = p_person_id
   AND    p_effective_date between effective_start_date and effective_end_date
   AND    paf.assignment_status_type_id = pas.assignment_status_type_id
   AND    pas.per_system_status in ('ACTIVE_ASSIGN', 'SUSP_ASSIGN');
   l_count   NUMBER :=0;
 BEGIN
   OPEN get_multiple_assgts;
     FETCH get_multiple_assgts INTO l_count;
   CLOSE get_multiple_assgts;
   IF l_count > 1 THEN
      RETURN 'Y';
   ELSE
      RETURN 'N';
   END IF;
 END  chk_multiple_assignments;
 -----
  function get_count RETURN NUMBER as
  l_count NUMBER(15);
  CURSOR CSR_KW_EFT_COUNT IS
  SELECT COUNT(*)
  FROM  per_assignments_f            paf
        ,per_people_f                 pef
        ,pay_pre_payments             ppp
        ,pay_assignment_actions       paa
        ,pay_payroll_actions          ppa
  WHERE  paa.payroll_action_id          =
         pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
  AND    paa.pre_payment_id             = ppp.pre_payment_id
  AND    paa.payroll_action_id          = ppa.payroll_action_id
  AND    paa.assignment_id              = paf.assignment_id
  AND    paf.person_id                  = pef.person_id
  AND    ppp.value                      > 0
  AND    ppa.effective_date BETWEEN paf.effective_start_date
                                AND paf.effective_end_date
  AND    ppa.effective_date BETWEEN pef.effective_start_date
                                AND pef.effective_end_date;
  BEGIN
          open CSR_KW_EFT_COUNT;
          fetch CSR_KW_EFT_COUNT into l_count;
          close CSR_KW_EFT_COUNT;
          return l_count;
  END get_count;
  ---------
  function get_sum return number as
  l_sum pay_pre_payments.value%type;
  CURSOR CSR_KW_EFT_SUM is
  SELECT SUM(ppp.value)
  FROM  per_assignments_f            paf
        ,per_people_f                 pef
        ,pay_pre_payments             ppp
        ,pay_assignment_actions       paa
        ,pay_payroll_actions          ppa
  WHERE  paa.payroll_action_id          =
         pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
  AND    paa.pre_payment_id             = ppp.pre_payment_id
  AND    paa.payroll_action_id          = ppa.payroll_action_id
  AND    paa.assignment_id              = paf.assignment_id
  AND    paf.person_id                  = pef.person_id
  AND    ppp.value                      > 0
  AND    ppa.effective_date BETWEEN paf.effective_start_date
                                AND paf.effective_end_date
  AND    ppa.effective_date BETWEEN pef.effective_start_date
                                AND pef.effective_end_date;
  BEGIN
          open CSR_KW_EFT_SUM;
          fetch CSR_KW_EFT_SUM into l_sum;
          close CSR_KW_EFT_SUM;
          return l_sum;
  END get_sum;
--------
end pay_kw_general;

/
