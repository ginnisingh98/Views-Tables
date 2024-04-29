--------------------------------------------------------
--  DDL for Package Body PAY_SA_GENERAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SA_GENERAL" as
/* $Header: pysagenr.pkb 120.2.12010000.2 2008/08/06 08:16:32 ubhat ship $ */

	g_package varchar2(30) := 'pay_sa_general';

------------------------------------------------------------------------
-- Function LOCAL_NATNATIONALITY_NOT_DEFINED
-- This function return NOTEXISTS If the value for HR: Local Nationality
-- Profile has not been defined else it retuns EXISTS.
------------------------------------------------------------------------

	function local_nationality_not_defined return varchar2
	is

	begin

		if FND_PROFILE.VALUE('PER_LOCAL_NATIONALITY') is null then
			return 'NOTEXISTS';
		else
			return 'EXISTS';
		end if;
	end local_nationality_not_defined;


------------------------------------------------------------------------
------------------------------------------------------------------------
-- Function LOCAL_NATIONALITY_MATCHES
-- This function return NOMATCH If the value for HR: Local Nationality
-- Profile does not match with the person's nationality else it retuns MATCH.
------------------------------------------------------------------------
	function local_nationality_matches
	(p_assignment_id IN per_all_assignments_f.assignment_id%type,
	 p_date_earned IN Date)
	 return varchar2
	is
		l_person_id number;
		l_nat_cd varchar2(100);

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
			SELECT NATIONALITY
			INTO   l_nat_cd
			FROM   per_all_people_f
			WHERE  person_id = l_person_id
			AND    p_date_earned BETWEEN effective_start_date AND effective_end_date;

		EXCEPTION
			WHEN no_data_found Then
			Null;
		END;

		if UPPER(l_nat_cd) = FND_PROFILE.VALUE('PER_LOCAL_NATIONALITY') then
			return 'MATCH';
		else
			return 'NOMATCH';
		end if;
	end local_nationality_matches;
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
------------------------------------------------------------------
--Functions for EFT
------------------------------------------------------------------
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
function get_sum return number as
 l_sum pay_pre_payments.value%type;
 CURSOR CSR_SA_EFT_SUM is
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
         open CSR_SA_EFT_SUM;
         fetch CSR_SA_EFT_SUM into l_sum;
         close CSR_SA_EFT_SUM;
         return l_sum;
 END get_sum;
----------------
function get_count RETURN NUMBER as
 l_count NUMBER(15);
 CURSOR CSR_SA_EFT_COUNT IS
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
         open CSR_SA_EFT_COUNT;
         fetch CSR_SA_EFT_COUNT into l_count;
         close CSR_SA_EFT_COUNT;
         return l_count;
 END get_count;
------------------------
------------------------------------------------------------------------
-- Function for returning contributory wage of employees over 50 years
------------------------------------------------------------------------
FUNCTION  get_cont_wage_emp_50 (
          p_assignment_action_id  IN NUMBER
         ,p_assignment_id              IN NUMBER
         ,p_date_earned                 IN DATE
         ,p_pct_value                      IN NUMBER
         ,p_subject_to_gosi            IN NUMBER)
RETURN NUMBER AS

  CURSOR csr_get_def_bal_id (p_def_bal_name IN VARCHAR2) IS
  SELECT  u.creator_id
  FROM    ff_user_entities  u,
                 ff_database_items d
  WHERE   d.user_name = p_def_bal_name
  AND      u.user_entity_id = d.user_entity_id
  AND      u.legislation_code = 'SA'
  AND      u.business_group_id is null
  AND      u.creator_type = 'B';

  CURSOR csr_get_assact_id IS
  SELECT paa.assignment_action_id
                ,ppa.date_earned
  FROM pay_assignment_actions paa
             ,pay_payroll_actions ppa
             ,pay_run_results prr
             ,pay_element_types_f pet
  WHERE paa.assignment_id = p_assignment_id
  AND   paa.assignment_action_id = prr.assignment_action_id
  AND   paa.payroll_action_id = ppa.payroll_action_id
  AND   paa.action_status = 'C'
  AND   ppa.action_status = 'C'
  AND   ppa.action_type in ('R','Q')
  AND   prr.element_type_id = pet.element_type_id
  AND   pet.element_name ='GOSI'
  AND   p_date_earned between pet.effective_start_date and pet.effective_end_date
  AND   prr.status = 'P'
  AND   paa.assignment_action_id < p_assignment_action_id
  --AND   ppa.date_earned >= ADD_MONTHS(TRUNC(p_date_earned,'YYYY'),-12)
  ORDER BY paa.assignment_action_id DESC;

  rec_get_assact_id     csr_get_assact_id%ROWTYPE;

  l_prev_salary             NUMBER;
  l_subject_gosi_id       NUMBER;
  l_old_assact_id          NUMBER;
  l_prev_assact_id       NUMBER;
  l_ref_earnings_id        NUMBER;
  l_diff_exist                   NUMBER;
  l_diff_salary                   NUMBER;
  l_old_wage                 NUMBER;
  l_c_wage_1                NUMBER;
  l_c_wage_2                NUMBER;
  l_old_date_earned     DATE;

BEGIN
  l_diff_exist := 0;
  l_ref_earnings_id := NULL;
  OPEN csr_get_def_bal_id( 'GOSI_REFERENCE_EARNINGS_ASG_YTD');
  FETCH csr_get_def_bal_id INTO l_ref_earnings_id;
  CLOSE csr_get_def_bal_id;

  l_subject_gosi_id := NULL;
  OPEN csr_get_def_bal_id( 'SUBJECT_TO_GOSI_ASG_RUN');
  FETCH csr_get_def_bal_id INTO l_subject_gosi_id;
  CLOSE csr_get_def_bal_id;

  l_old_assact_id := NULL;

  /*check if the earlier run was in previous year and get the assignment action_id*/
  OPEN csr_get_assact_id;
  LOOP
    FETCH csr_get_assact_id INTO rec_get_assact_id;
    EXIT WHEN csr_get_assact_id%NOTFOUND;
    IF l_old_assact_id IS NULL THEN
      IF TRUNC(rec_get_assact_id.date_earned,'YYYY') < TRUNC(p_date_earned, 'YYYY') THEN
        l_old_assact_id := rec_get_assact_id.assignment_action_id;
        l_old_date_earned := rec_get_assact_id.date_earned;
        l_old_wage := pay_balance_pkg.get_value(l_ref_earnings_id,l_old_assact_id);
      ELSE
        /*Exit if the earlier run is in the same year. This indicates there is no need to calculate contributory wage*/
        EXIT;
      END IF;
    END IF;
    /*l_prev_salary := pay_balance_pkg.get_value(l_subject_gosi_id,rec_get_assact_id.assignment_action_id);*/
    /*Check if there is any salary change in the previous year*/
    IF TRUNC(l_old_date_earned ,'YYYY') = TRUNC(rec_get_assact_id.date_earned,'YYYY') THEN
     /*Bug No6976224*/
      /*IF l_prev_salary <> p_subject_to_gosi THEN*/
        IF l_old_wage  <> p_subject_to_gosi THEN
        l_diff_exist := 1;
        EXIT;
      END IF;
    END IF;

  END LOOP;
  CLOSE csr_get_assact_id;

  IF (l_diff_exist = 1) AND (l_old_assact_id IS NOT NULL) THEN
    /*Calculate contributory wage if there is any change*/
    l_diff_salary := p_subject_to_gosi - l_prev_salary;
     /*Bug No 6976224*/
    /*l_c_wage_1 := ((p_pct_value/100) * (l_diff_salary)) + l_old_wage;*/
    l_c_wage_1 := ((p_pct_value/100) * (l_old_wage)) + l_old_wage;
    l_c_wage_2 := p_subject_to_gosi;

    RETURN (LEAST(l_c_wage_1, l_c_wage_2));
  END IF;

  RETURN(nvl(l_old_wage,0));

END get_cont_wage_emp_50;

end pay_sa_general;


/
