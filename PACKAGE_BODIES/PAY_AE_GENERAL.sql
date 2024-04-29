--------------------------------------------------------
--  DDL for Package Body PAY_AE_GENERAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AE_GENERAL" as
/* $Header: pyaegenr.pkb 120.6 2005/11/10 03:05:54 abppradh noship $ */
	g_package varchar2(30);
	l_organization_id hr_all_organization_units.organization_id%type;
	l_person_id per_all_people_f.person_id%type;
	l_nationality_cd hr_lookups.meaning%type;
	l_nationality_person per_all_people_f.nationality%type;
------------------------------------------------------------------------
-- Function LOCAL_NATNATIONALITY_NOT_DEFINED
-- This function return NOTEXISTS If the value for HR: Local Nationality
-- Profile has not been defined else it retuns EXISTS.
------------------------------------------------------------------------
	function local_nationality_not_defined return varchar2
	is
	begin
		BEGIN
			l_organization_id := FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID');
			Select Org_Information1
			Into l_nationality_cd
			From HR_ORGANIZATION_INFORMATION
			Where ORG_INFORMATION_CONTEXT = 'AE_BG_DETAILS'
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
	end local_nationality_not_defined;
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
			Select per_information18
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
	l_nationality := hr_general.decode_lookup('AE_NATIONALITY',l_nationality_cd);
	RETURN l_nationality;
END get_local_nationality;
------------------------------------------------------------------------
-- Function GET_SECTOR
------------------------------------------------------------------------
	function get_sector (p_tax_unit_id IN NUMBER) return varchar2
	IS
	l_sector varchar2(1);
	CURSOR GET_AE_SECTOR (l_tax_unit_id number) IS
	SELECT org_information6
	FROM hr_organization_information
	WHERE organization_id = l_tax_unit_id
	AND org_information_context = 'AE_LEGAL_EMPLOYER_DETAILS';
	begin
	l_sector := null;
		OPEN get_ae_sector (p_tax_unit_id);
		FETCH get_ae_sector INTO l_sector;
		CLOSE get_ae_sector;
	If l_sector is null THEN
		return 'N';
	Else
		return l_sector;
	End If;
	end get_sector;
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
	g_package := 'pay_ae_general';
	l_proc := g_package||'.get_message';
	--
	   hr_utility.set_location('Entered '||l_proc,5);
	   hr_utility.set_location('.  Message Name: '||p_message_name,40);
	   fnd_message.set_name(p_product, p_message_name);
	   if p_token1 is not null then
	      -- Obtain token 1 name and value
	      l_colon_position := instr(p_token1,':');
	      l_token_name  := substr(p_token1,1,l_colon_position-1);
	      l_token_value := substr(p_token1,l_colon_position+1,length(p_token1));
	      fnd_message.set_token(l_token_name, l_token_value);
	      hr_utility.set_location('.  Token1: '||l_token_name||'. Value: '||l_token_value,50);
	   end if;
	   if p_token2 is not null  then
	      -- Obtain token 2 name and value
	      l_colon_position := instr(p_token2,':');
	      l_token_name  := substr(p_token2,1,l_colon_position-1);
	      l_token_value := substr(p_token2,l_colon_position+1,length(p_token2));
	      fnd_message.set_token(l_token_name, l_token_value);
	      hr_utility.set_location('.  Token2: '||l_token_name||'. Value: '||l_token_value,60);
	   end if;
	   if p_token3 is not null then
	      -- Obtain token 3 name and value
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
			 WHERE  legislation_code='AE'
	  		 AND    UPPER(user_table_name) = UPPER(l_table_name);
	  		 CURSOR csr_get_min_low (l_user_table_id  NUMBER, l_effective_date DATE) IS
			 SELECT MIN(to_number(row_low_range_or_name))
			 FROM   pay_user_rows_f
			 WHERE  user_table_id = l_user_table_id
			 AND    legislation_code = 'AE'
	  		 AND    l_effective_date BETWEEN effective_start_date AND effective_end_date;
			 CURSOR csr_get_min_high (l_user_table_id  number ,l_effective_date DATE ) IS
			 SELECT MIN(to_number(row_high_range))
			 FROM   pay_user_rows_f
			 WHERE  user_table_id = l_user_table_id
			 AND    legislation_code = 'AE'
	  		 AND    l_effective_date BETWEEN effective_start_date AND effective_end_date;
	  		 CURSOR csr_get_max_high (l_user_table_id  number, l_effective_date DATE) IS
			 SELECT MAX(to_number(row_high_range))
			 FROM   pay_user_rows_f
			 WHERE  user_table_id = l_user_table_id
			 AND    legislation_code = 'AE'
  		 	 AND    l_effective_date BETWEEN effective_start_date AND effective_end_date;
  		 	 l_ret_val number(15,3);
  		 	 l_table_id number(9);
   		       l_proc varchar2(72) ;
	--
	begin
	g_package := 'pay_ae_general';
	l_proc := g_package||'.get_table_bands';
	--
	   hr_utility.set_location('Entered '||l_proc,5);
	   -- Get the User Table ID
	   OPEN csr_get_user_table_id(p_table_name);
	   FETCH csr_get_user_table_id INTO l_table_id;
	   CLOSE csr_get_user_table_id;
	   --
	   IF p_return_type = 'MIN_LOW' THEN
	   OPEN csr_get_min_low (l_table_id, p_date_earned);
	   FETCH csr_get_min_low INTO l_ret_val;
	   CLOSE csr_get_min_low;
	   ELSIF p_return_type = 'MIN_HIGH' THEN
	   OPEN csr_get_min_high (l_table_id, p_date_earned);
	   FETCH csr_get_min_high INTO l_ret_val;
	   CLOSE csr_get_min_high;
	   ELSIF p_return_type = 'MAX_HIGH' THEN
	   OPEN csr_get_max_high (l_table_id, p_date_earned);
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
  CURSOR CSR_AE_EFT_COUNT IS
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
  AND    ppp.value                      <> 0
  AND    ppa.effective_date BETWEEN paf.effective_start_date
                                AND paf.effective_end_date
  AND    ppa.effective_date BETWEEN pef.effective_start_date
                                AND pef.effective_end_date;
  BEGIN
          open CSR_AE_EFT_COUNT;
          fetch CSR_AE_EFT_COUNT into l_count;
          close CSR_AE_EFT_COUNT;
          return l_count;
  END get_count;
  ---------
  function get_total_sum return number as
  l_total_sum pay_pre_payments.value%type;
  CURSOR CSR_AE_EFT_SUM is
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
  AND    ppp.value                      <> 0
  AND    ppa.effective_date BETWEEN paf.effective_start_date
                                AND paf.effective_end_date
  AND    ppa.effective_date BETWEEN pef.effective_start_date
                                AND pef.effective_end_date;
  BEGIN
          open CSR_AE_EFT_SUM;
          fetch CSR_AE_EFT_SUM into l_total_sum;
          close CSR_AE_EFT_SUM;
          return l_total_sum;
  END get_total_sum;
--------
  ---------
  function get_credit_sum return number as
  l_credit_sum pay_pre_payments.value%type;
  CURSOR CSR_AE_EFT_SUM is
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
          open CSR_AE_EFT_SUM;
          fetch CSR_AE_EFT_SUM into l_credit_sum;
          close CSR_AE_EFT_SUM;
          return l_credit_sum;
  END get_credit_sum;
--------
  ---------
  function get_debit_sum return number as
  l_debit_sum pay_pre_payments.value%type;
  CURSOR CSR_AE_EFT_SUM is
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
  AND    ppp.value                      < 0
  AND    ppa.effective_date BETWEEN paf.effective_start_date
                                AND paf.effective_end_date
  AND    ppa.effective_date BETWEEN pef.effective_start_date
                                AND pef.effective_end_date;
  BEGIN
          open CSR_AE_EFT_SUM;
          fetch CSR_AE_EFT_SUM into l_debit_sum;
          close CSR_AE_EFT_SUM;
          return l_debit_sum;
  END get_debit_sum;
--------
	--------
	function chk_tran_code (p_value IN	VARCHAR2)  return VARCHAR2 as
		l_flag varchar2(1) := null;
	BEGIN
	  If p_value <> 0 then
		If p_value < 0 then
			l_flag := 'N';
		elsif p_value > 0 then
			l_flag := 'Y';
		end if;
	  End if;
	  Return nvl(l_flag,' ');
	  End chk_tran_code;
	  -----------
--------
------------------------------------------------------------------------
-- Function get_contract
------------------------------------------------------------------------
  FUNCTION get_contract
    (p_assignment_id IN per_all_assignments_f.assignment_id%type,
     p_date_earned   IN Date)
    RETURN VARCHAR2 IS
    l_contract VARCHAR2(30);
  BEGIN
    BEGIN
      SELECT cont.type
      INTO   l_contract
      FROM   per_contracts_f cont
             ,per_all_assignments_f asg
      WHERE  asg.assignment_id = p_assignment_id
      AND    asg.contract_id = cont.contract_id
      AND    p_date_earned BETWEEN asg.effective_start_date AND asg.effective_end_date
      AND    p_date_earned BETWEEN cont.effective_start_date AND cont.effective_end_date;
    EXCEPTION
      WHEN OTHERS THEN
        l_contract := 'N';
    END;
    RETURN l_contract;
  END get_contract;
--------
------------------------------------------------------------------------
-- Function get_contract_expiry_status
------------------------------------------------------------------------
  FUNCTION get_contract_expiry_status
    (p_assignment_id IN per_all_assignments_f.assignment_id%type,
     p_date_earned   IN Date)
    RETURN VARCHAR2 IS
    l_contract VARCHAR2(30);
    l_expiry_date DATE;
    l_expiry_status VARCHAR2(10);
  BEGIN
    l_expiry_status := 'N';
    BEGIN

      SELECT cont.type, fnd_date.canonical_to_date(cont.ctr_information2)
      INTO   l_contract, l_expiry_date
      FROM   per_contracts_f cont
             ,per_all_assignments_f asg
      WHERE  asg.assignment_id = p_assignment_id
      AND    asg.contract_id = cont.contract_id
      AND    p_date_earned BETWEEN asg.effective_start_date AND asg.effective_end_date
      AND    p_date_earned BETWEEN cont.effective_start_date AND cont.effective_end_date;

      IF l_expiry_date IS NOT NULL THEN
        IF l_contract = 'FIXED_CONTRACT' AND TRUNC(l_expiry_date,'MM') <= TRUNC(p_date_earned,'MM') THEN
          l_expiry_status := 'Y';
        END IF;
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        l_expiry_status := 'N';
    END;
    RETURN l_expiry_status;
  END get_contract_expiry_status;
--------

------------------------------------------------------------------------
-- Function get_termination_initiator
------------------------------------------------------------------------
  function get_termination_initiator
    (p_assignment_id IN per_all_assignments_f.assignment_id%type,
     p_date_earned   IN Date)
    RETURN VARCHAR2 IS
    l_leav_reason  per_periods_of_service.leaving_reason%TYPE;
    l_initiator    VARCHAR2(20);
  BEGIN
    l_initiator :='EE';
    BEGIN
      SELECT pos.leaving_reason
      INTO   l_leav_reason
      FROM   per_all_assignments_f   assign
             ,per_periods_of_service pos
      WHERE  p_date_earned BETWEEN assign.effective_start_date AND assign.effective_end_date
      AND    assign.assignment_id = p_assignment_id
      AND    assign.period_of_service_id = pos.period_of_service_id;
      SELECT NVL(i.value,'EE')
      INTO   l_initiator
      FROM   pay_user_column_instances_f i
             ,pay_user_rows_f r
             ,pay_user_columns c
             ,pay_user_tables t
      WHERE  ((i.legislation_code = 'AE' AND i.business_group_id IS NULL) OR
               (i.legislation_code IS NULL AND i.business_group_id = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')))
      AND    ((r.legislation_code = 'AE' AND r.business_group_id IS NULL) OR
               (r.legislation_code IS NULL AND r.business_group_id = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')))
      AND    c.legislation_code = 'AE'
      AND    t.legislation_code = 'AE'
      AND    UPPER(t.user_table_name) = UPPER('AE_TERMINATION_INITIATOR')
      AND    t.user_table_id = r.user_table_id
      AND    t.user_table_id = c.user_table_id
      AND    r.row_low_range_or_name = l_leav_reason
      AND    r.user_row_id = i.user_row_id
      AND    UPPER(c.user_column_name) = UPPER('INITIATOR')
      AND    c.user_column_id = i.user_column_id
      AND    p_date_earned BETWEEN r.effective_start_date AND r.effective_end_date
      AND    p_date_earned BETWEEN i.effective_start_date AND i.effective_end_date;
    EXCEPTION
      WHEN OTHERS THEN
        l_initiator := 'EE';
    END;
    RETURN l_initiator;
  END;

------------------------------------------------------------------------
-- Function user_gratuity_formula_exists
------------------------------------------------------------------------
  FUNCTION user_gratuity_formula_exists
    (p_assignment_id IN per_all_assignments_f.assignment_id%type,
     p_date_earned   IN Date)
    RETURN VARCHAR2 IS
    cursor csr_get_formula_id  is
    select  HOI2.org_information1
    from    hr_organization_units HOU
            ,hr_organization_information HOI1
            ,hr_organization_information HOI2
            ,hr_soft_coding_keyflex HSCK
            ,per_all_assignments_f PAA
    where   HOU.business_group_id = PAA.business_group_id
    and    trunc(p_date_earned) between HOU.date_from and nvl(HOU.date_to,
	to_date('4712/12/31','YYYY/MM/DD'))
    and   HOU.organization_id = HOI1.organization_id
    and   HOI1.org_information_context = 'CLASS'
    and   HOI1.org_information1 = 'HR_LEGAL_EMPLOYER'
    and   HOI1.organization_id = HOI2.organization_id
    and   PAA.assignment_id = p_assignment_id
    and   trunc(p_date_earned) between PAA.effective_start_date and PAA.effective_end_date
    and   PAA.soft_coding_keyflex_id = HSCK.soft_coding_keyflex_id
    /*and   HSCK.id_flex_num = 20
    and   decode(HSCK.id_flex_num,20,to_number(HSCK.segment1),-9999) = HOU.organization_id*/
    and   hsck.segment1 = hou.organization_id
    and   HOI2.org_information_context = 'AE_GRATUITY_REF_FORMULA';
    rec_get_formula_id csr_get_formula_id%ROWTYPE;
    l_formula_id       NUMBER;
    l_indicator        NUMBER;
  BEGIN
    OPEN csr_get_formula_id;
    FETCH csr_get_formula_id INTO rec_get_formula_id;
    l_formula_id := rec_get_formula_id.org_information1;
    CLOSE csr_get_formula_id;
    IF l_formula_id IS NULL THEN
      l_indicator := 0;
    ELSE
      l_indicator := 1;
    END IF;
    RETURN l_indicator;
  END;

  PROCEDURE run_formula(p_formula_id      IN NUMBER
                       ,p_effective_date  IN DATE
                       ,p_inputs          IN ff_exec.inputs_t
                       ,p_outputs         IN OUT NOCOPY ff_exec.outputs_t) IS
   l_inputs ff_exec.inputs_t;
   l_outputs ff_exec.outputs_t;
  BEGIN
   hr_utility.set_location('--In Formula ',20);
   --
   -- Initialize the formula
   --
   ff_exec.init_formula(p_formula_id, p_effective_date  , l_inputs, l_outputs);
   --
   hr_utility.trace('after ff_exec');
   -- Set up the input values
   --
   IF l_inputs.count > 0 and p_inputs.count > 0 THEN
    FOR i IN l_inputs.first..l_inputs.last LOOP
     FOR j IN p_inputs.first..p_inputs.last LOOP
      IF l_inputs(i).name = p_inputs(j).name THEN
       l_inputs(i).value := p_inputs(j).value;
       exit;
      END IF;
     END LOOP;
    END LOOP;
   END IF;
   --
   -- Run the formula
   --
   hr_utility.trace('about to exec');
   ff_exec.run_formula(l_inputs,l_outputs);
   --
   -- Populate the output table
   --
   IF l_outputs.count > 0 and p_inputs.count > 0 then
    FOR i IN l_outputs.first..l_outputs.last LOOP
     FOR j IN p_outputs.first..p_outputs.last LOOP
      IF l_outputs(i).name = p_outputs(j).name THEN
       p_outputs(j).value := l_outputs(i).value;
       exit;
      END IF;
     END LOOP;
    END LOOP;
   END IF;
  EXCEPTION
   /*WHEN hr_formula_error THEN
    fnd_message.set_name('PER','FFX22J_FORMULA_NOT_FOUND');
    fnd_message.set_token('1', g_formula_name);
    fnd_message.raise_error;*/
   WHEN OTHERS THEN
    raise;
  --
  END run_formula;

  function run_gratuity_formula
   (p_assignment_id         IN NUMBER
   ,p_date_earned           IN DATE
   ,p_business_group_id     IN NUMBER
   ,p_payroll_id            IN NUMBER
   ,p_payroll_action_id     IN NUMBER
   ,p_assignment_action_id  IN NUMBER
   ,p_tax_unit_id           IN NUMBER
   ,p_element_entry_id      IN NUMBER
   ,p_element_type_id       IN NUMBER
   ,p_original_entry_id     IN NUMBER
   ,p_monthly_gratuity      OUT NOCOPY NUMBER
   ,p_paid_gratuity         OUT NOCOPY NUMBER
   )
  return NUMBER is
    cursor csr_get_formula_id  is
    select  HOI2.org_information2
    from    hr_organization_units HOU
            ,hr_organization_information HOI1
            ,hr_organization_information HOI2
            ,hr_soft_coding_keyflex HSCK
            ,per_all_assignments_f PAA
    where   HOU.business_group_id = PAA.business_group_id
    and    trunc(p_date_earned) between HOU.date_from and nvl(HOU.date_to,
	to_date('4712/12/31','YYYY/MM/DD'))
    and   HOU.organization_id = HOI1.organization_id
    and   HOI1.org_information_context = 'CLASS'
    and   HOI1.org_information1 = 'HR_LEGAL_EMPLOYER'
    and   HOI1.organization_id = HOI2.organization_id
    and   PAA.assignment_id = p_assignment_id
    and   trunc(p_date_earned) between PAA.effective_start_date and PAA.effective_end_date
    and   PAA.soft_coding_keyflex_id = HSCK.soft_coding_keyflex_id
    /*and   HSCK.id_flex_num = 20
    and   decode(HSCK.id_flex_num,20,to_number(HSCK.segment1),-9999) = HOU.organization_id*/
    and   hsck.segment1 = hou.organization_id
    and   HOI2.org_information_context = 'AE_REFERENCE_FF';
    l_formula_id NUMBER;
    l_inputs     ff_exec.inputs_t;
    l_outputs    ff_exec.outputs_t;
    l_value      NUMBER;
    l_indicator        NUMBER;
    i            NUMBER;
  begin
    l_indicator := 0;
    i := 0;
    open csr_get_formula_id;
    fetch csr_get_formula_id into l_formula_id;
    close csr_get_formula_id;
    l_inputs(1).name  := 'ASSIGNMENT_ID';
    l_inputs(1).value := p_assignment_id;
    l_inputs(2).name  := 'DATE_EARNED';
    l_inputs(2).value := fnd_date.date_to_canonical(p_date_earned);
    l_inputs(3).name  := 'BUSINESS_GROUP_ID';
    l_inputs(3).value := p_business_group_id;
    l_inputs(4).name  := 'PAYROLL_ID';
    l_inputs(4).value := p_payroll_id;
    l_inputs(5).name  := 'PAYROLL_ACTION_ID';
    l_inputs(5).value := p_payroll_action_id;
    l_inputs(6).name  := 'ASSIGNMENT_ACTION_ID';
    l_inputs(6).value := p_assignment_action_id;
    l_inputs(7).name  := 'TAX_UNIT_ID';
    l_inputs(7).value := p_tax_unit_id;
    l_inputs(8).name  := 'ELEMENT_ENTRY_ID';
    l_inputs(8).value := p_element_entry_id;
    l_inputs(9).name  := 'ELEMENT_TYPE_ID';
    l_inputs(9).value := p_element_type_id;
    l_inputs(10).name  := 'ORIGINAL_ENTRY_ID';
    l_inputs(10).value := p_original_entry_id;
    l_outputs(1).name := 'MONTHLY_GRATUITY';
    l_outputs(2).name := 'PAID_GRATUITY';
    if l_formula_id is not null then
      run_formula (l_formula_id
                   ,p_date_earned
                   ,l_inputs
                   ,l_outputs);
      i := l_outputs.first;
      --p_accrued_gratuity := NVL(l_outputs(i).value,0);
      p_monthly_gratuity := NVL(l_outputs(i).value,0);
      p_paid_gratuity := NVL(l_outputs(i+1).value,0);
      l_indicator := 1;
    else
      l_indicator := 0;
    end if;
    RETURN l_indicator;

  end run_gratuity_formula;

  function run_gratuity_salary_formula
   (p_assignment_id         IN NUMBER
   ,p_date_earned           IN DATE
   ,p_business_group_id     IN NUMBER
   ,p_payroll_id            IN NUMBER
   ,p_payroll_action_id     IN NUMBER
   ,p_assignment_action_id  IN NUMBER
   ,p_tax_unit_id           IN NUMBER
   ,p_element_entry_id      IN NUMBER
   ,p_element_type_id       IN NUMBER
   ,p_original_entry_id     IN NUMBER

   )
  return NUMBER is
    cursor csr_get_formula_id  is
    select  HOI2.org_information3
    from    hr_organization_units HOU
            ,hr_organization_information HOI1
            ,hr_organization_information HOI2
            ,hr_soft_coding_keyflex HSCK
            ,per_all_assignments_f PAA
    where   HOU.business_group_id = PAA.business_group_id
    and    trunc(p_date_earned) between HOU.date_from and nvl(HOU.date_to,
	to_date('4712/12/31','YYYY/MM/DD'))
    and   HOU.organization_id = HOI1.organization_id
    and   HOI1.org_information_context = 'CLASS'
    and   HOI1.org_information1 = 'HR_LEGAL_EMPLOYER'
    and   HOI1.organization_id = HOI2.organization_id
    and   PAA.assignment_id = p_assignment_id
    and   trunc(p_date_earned) between PAA.effective_start_date and PAA.effective_end_date
    and   PAA.soft_coding_keyflex_id = HSCK.soft_coding_keyflex_id
    /*and   HSCK.id_flex_num = 20
    and   decode(HSCK.id_flex_num,20,to_number(HSCK.segment1),-9999) = HOU.organization_id*/
    and   hsck.segment1 = hou.organization_id
    and   HOI2.org_information_context = 'AE_REFERENCE_FF';
    l_formula_id      NUMBER;
    l_inputs          ff_exec.inputs_t;
    l_outputs         ff_exec.outputs_t;
    l_value           NUMBER;
    l_monthly_salary    NUMBER;
    i                 NUMBER;
  begin
    l_monthly_salary := 0;
    i := 0;
    open csr_get_formula_id;
    fetch csr_get_formula_id into l_formula_id;
    close csr_get_formula_id;
    l_inputs(1).name  := 'ASSIGNMENT_ID';
    l_inputs(1).value := p_assignment_id;
    l_inputs(2).name  := 'DATE_EARNED';
    l_inputs(2).value := fnd_date.date_to_canonical(p_date_earned);
    l_inputs(3).name  := 'BUSINESS_GROUP_ID';
    l_inputs(3).value := p_business_group_id;
    l_inputs(4).name  := 'PAYROLL_ID';
    l_inputs(4).value := p_payroll_id;
    l_inputs(5).name  := 'PAYROLL_ACTION_ID';
    l_inputs(5).value := p_payroll_action_id;
    l_inputs(6).name  := 'ASSIGNMENT_ACTION_ID';
    l_inputs(6).value := p_assignment_action_id;
    l_inputs(7).name  := 'TAX_UNIT_ID';
    l_inputs(7).value := p_tax_unit_id;
    l_inputs(8).name  := 'ELEMENT_ENTRY_ID';
    l_inputs(8).value := p_element_entry_id;
    l_inputs(9).name  := 'ELEMENT_TYPE_ID';
    l_inputs(9).value := p_element_type_id;
    l_inputs(10).name  := 'ORIGINAL_ENTRY_ID';
    l_inputs(10).value := p_original_entry_id;


    l_outputs(1).name := 'MONTHLY_SALARY';
    if l_formula_id is not null then
      run_formula (l_formula_id
                   ,p_date_earned
                   ,l_inputs
                   ,l_outputs);
      i := l_outputs.first;
      l_monthly_salary := NVL(l_outputs(i).value,0);
    end if;
    RETURN l_monthly_salary;

  end run_gratuity_salary_formula;

------------------------------------------------------------------------
-- Function get_unauth_absence
-- Function for fetching unauthorised absences
------------------------------------------------------------------------
  FUNCTION get_unauth_absence
   (p_assignment_id         IN NUMBER
   ,p_date_earned           IN DATE
   ,p_business_group_id     IN NUMBER
   --,p_period_start_date     IN VARCHAR2
   --,p_period_end_date       IN VARCHAR2
   )
    RETURN NUMBER IS
    l_days  NUMBER;
  BEGIN
    l_days := 0;
    /*OPEN csr_get_abs_days;
    FETCH csr_get_abs_days INTO l_days;
    CLOSE csr_get_abs_days;*/


    SELECT SUM(paa.absence_days) --(NVL(paa.absence_days, (paa.DATE_END - paa.DATE_START))
    INTO   l_days
    FROM   per_absence_attendances paa
           ,per_absence_attendance_types paat
           ,per_all_assignments_f asg
    WHERE  paat.absence_category ='UL'
    AND    paat.business_group_id = paa.business_group_id
    AND    paat.business_group_id = p_business_group_id
    AND    paat.absence_attendance_type_id = paa.absence_attendance_type_id
    AND    paa.person_id = asg.person_id
    AND    asg.assignment_id = p_assignment_id
    AND    TRUNC(p_date_earned) BETWEEN asg.effective_start_date AND asg.effective_end_date
    AND    TRUNC(p_date_earned) >= TRUNC(paa.date_end,'MM') ;

    RETURN NVL(l_days,0);

  EXCEPTION
    WHEN OTHERS THEN
      l_days := 0;
      RETURN l_days;

  END get_unauth_absence;

------------------------------------------------------------------------
-- Function get_gratuity_basis
-- Function for fetching gratuity basis
------------------------------------------------------------------------
  FUNCTION get_gratuity_basis
   (p_assignment_id         IN NUMBER
   ,p_date_earned           IN DATE
   )
    RETURN VARCHAR2 IS
    CURSOR csr_get_gratuity_basis IS
    select  NVL(HOI2.org_information1,'X')
    from    hr_organization_units HOU
            ,hr_organization_information HOI1
            ,hr_organization_information HOI2
            ,hr_soft_coding_keyflex HSCK
            ,per_all_assignments_f PAA
    where   HOU.business_group_id = PAA.business_group_id
    and    trunc(p_date_earned) between HOU.date_from and nvl(HOU.date_to,
	to_date('4712/12/31','YYYY/MM/DD'))
    and   HOU.organization_id = HOI1.organization_id
    and   HOI1.org_information_context = 'CLASS'
    and   HOI1.org_information1 = 'HR_LEGAL_EMPLOYER'
    and   HOI1.organization_id = HOI2.organization_id
    and   PAA.assignment_id = p_assignment_id
    and   trunc(p_date_earned) between PAA.effective_start_date and PAA.effective_end_date
    and   PAA.soft_coding_keyflex_id = HSCK.soft_coding_keyflex_id
    and   hsck.segment1 = hou.organization_id
    and   HOI2.org_information_context = 'AE_GRATUITY_DETAILS';
    l_basis VARCHAR2(80);
  BEGIN
    l_basis := 'X';

    OPEN csr_get_gratuity_basis;
    FETCH csr_get_gratuity_basis INTO l_basis;
    CLOSE csr_get_gratuity_basis;
    RETURN l_basis;

  END get_gratuity_basis;

end pay_ae_general;

/
