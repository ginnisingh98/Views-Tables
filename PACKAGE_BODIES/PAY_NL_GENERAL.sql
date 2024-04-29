--------------------------------------------------------
--  DDL for Package Body PAY_NL_GENERAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NL_GENERAL" as
/* $Header: pynlgenr.pkb 120.9.12000000.4 2007/07/04 11:54:05 abhgangu noship $ */
--
g_package varchar2(30) := 'pay_nl_general';
hr_formula_error  EXCEPTION;

-- +********************************************************************+
-- |                        PUBLIC FUNCTIONS                            |
-- +********************************************************************+
--
------------------------------------------------------------------------
-- Function GET_POSTAL_CODE
-- This function gets a string with a space at the 5th position and
-- returns the string with the space removed.
------------------------------------------------------------------------
function get_postal_code
            (p_postal_code  in varchar2)
return varchar2
is

begin
    if length(p_postal_code) = 7 then
        return concat(substr(p_postal_code,1,4),substr(p_postal_code,6,2));
    else
        return p_postal_code;
    end if;
end get_postal_code;

------------------------------------------------------------------------
-- Function GET_POSTAL_CODE_NEW
-- This function gets a string without a space and returns it with
-- a space at the 5th position.
------------------------------------------------------------------------
function get_postal_code_new
            (p_postal_code  in varchar2)
return varchar2
is

begin
    if length(p_postal_code) = 6 then
        return concat(substr(p_postal_code,1,4),concat(' ',substr(p_postal_code,5,2)));
    else
        return p_postal_code;
    end if;
end get_postal_code_new;


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
                        ,p_token3            in varchar2 default null)
return varchar2
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

   l_message := substrb(fnd_message.get,1,254);

   hr_utility.set_location('leaving '||l_proc,100);

   return l_message;
end get_message;
--

---------------------------------------------------------------------------
--  Function:    PAY_PERIOD_ASG_DATES
--  Description: Function returns pay period assignment dates
---------------------------------------------------------------------------

function get_period_asg_dates (p_assignment_id in number
		      ,p_period_start_date in date
		      ,p_period_end_date in date
		      ,p_asg_start_date out nocopy date
		      ,p_asg_end_date out nocopy date
		      ) return number is


cursor csr_asg_dates is
	select min(asg.effective_start_date) asg_start_date
	,max(asg.effective_end_date) asg_end_date
	from   per_assignments_f asg,
	per_assignment_status_types past
	where  asg.assignment_id = p_assignment_id
	and   past.per_system_status = 'ACTIVE_ASSIGN'
	and   asg.assignment_status_type_id = past.assignment_status_type_id
	and    asg.effective_start_date <= p_period_end_date
	and    nvl(asg.effective_end_date, p_period_end_date) >= p_period_start_date;

cursor csr_asg_act_dates (p_date date) is
	select asg.effective_end_date
	from   per_assignments_f asg,
	per_assignment_status_types past
	where  asg.assignment_id = p_assignment_id
	and   past.per_system_status = 'ACTIVE_ASSIGN'
	and   asg.assignment_status_type_id = past.assignment_status_type_id
	and    asg.effective_start_date =p_date;

v_csr_asg_act_dates csr_asg_act_dates%ROWTYPE;

begin

        hr_utility.set_location('get_period_asg_dates',1);

        open csr_asg_dates;
        fetch csr_asg_dates into p_asg_start_date,p_asg_end_date;
        close csr_asg_dates;

        --Bug 3119100
        /*Check if the Assignment has a Active Record starting from
        next day in which case return Effective End date of that assignment
        record else return the date obtained as before(Indicating the asg
        is inactive starting from the next day */
	if p_asg_end_date = p_period_end_date then

	   OPEN csr_asg_act_dates(p_asg_end_date+1);
	   FETCH csr_asg_act_dates INTO v_csr_asg_act_dates;
	   IF csr_asg_act_dates%FOUND THEN
		p_asg_end_date := v_csr_asg_act_dates.effective_end_date;
	   END IF;
	   CLOSE csr_asg_act_dates;

	end if;

        hr_utility.set_location('get_period_asg_dates',99);

        return 1;

exception

    when others then
    hr_utility.trace('SQLERRM: '||substr(sqlerrm,1,200));
    raise;

end get_period_asg_dates;

------------------------------------------------------------------
-- Function : get_run_result_value
-- This is a generic function that returns the run result value
-- given the assignment_action_id , element_Type_id,
-- input_value_id and run_result_id
------------------------------------------------------------------

function get_run_result_value(p_assignment_action_id number,
                              p_element_type_id number,
                              p_input_value_id number,
                              p_run_result_id number,
                              p_UOM varchar2)return varchar2 is

cursor csr_get_run_result_value(p_assignment_action_id number,
                                p_element_type_id number,
                                p_input_value_id number,p_run_result_id number)is
select prrv.result_value from pay_run_result_values prrv,pay_run_results prr
where prr.assignment_action_id=p_assignment_action_id
and prr.element_type_id=p_element_type_id
and prr.run_result_id=p_run_result_id
and prrv.run_result_id=prr.run_result_id
and prrv.input_value_id=p_input_value_id;

l_result_value pay_run_result_values.result_value%TYPE;

begin

OPEN csr_get_run_result_value(p_assignment_action_id,p_element_type_id,p_input_value_id,p_run_result_id);
FETCH csr_get_run_result_value into l_result_value;
IF p_UOM = 'M' OR p_UOM = 'N' THEN
 l_result_value := to_char(fnd_number.canonical_to_number(l_result_value));
END IF;
CLOSE csr_get_run_Result_value;

return l_result_value;

exception

	when others then
	hr_utility.trace('SQLERRM:'||substr(sqlerrm,1,200));
	raise;

end get_run_result_value;


------------------------------------------------------------------
-- Function : get_run_result_value
-- This is a generic function that returns the run result value
-- given the assignment_action_id , element_Type_id and
-- input_value_id
------------------------------------------------------------------

function get_run_result_value(p_assignment_action_id number,
                              p_element_type_id number,
                              p_input_value_id number)return number is

cursor csr_get_run_result_value(p_assignment_action_id number,
                                p_element_type_id number,
                                p_input_value_id number)is
select fnd_number.canonical_to_number(prrv.result_value) from pay_run_result_values prrv,pay_run_results prr
where prr.assignment_action_id=p_assignment_action_id
and prr.element_type_id=p_element_type_id
and prrv.run_result_id=prr.run_result_id
and prrv.input_value_id=p_input_value_id;

l_result_value number;

begin

OPEN csr_get_run_result_value(p_assignment_action_id,p_element_type_id,p_input_value_id);
FETCH csr_get_run_result_value into l_result_value;
CLOSE csr_get_run_Result_value;

return l_result_value;

exception

	when others then
	hr_utility.trace('SQLERRM:'||substr(sqlerrm,1,200));
	raise;

end get_run_result_value;


---------------------------------------------------------------------------
-- Function : get_retro_period
-- Function returns the retro period for the given element_entry_id and
-- date_earned
---------------------------------------------------------------------------

function get_retro_period
        (
             p_element_entry_id in pay_element_entries_f.element_entry_id%TYPE,
             p_date_earned in pay_payroll_actions.date_earned%TYPE
        )return date is

cursor c_get_creator_type(c_element_entry_id in pay_element_entries_f.element_entry_id%TYPE,
                          c_date_earned in pay_payroll_actions.date_earned%TYPE
                         ) is
SELECT creator_type
FROM pay_element_entries_f pee
WHERE pee.element_entry_id=c_element_entry_id
and c_date_earned between pee.effective_start_date and pee.effective_end_date;

cursor get_retro_period_rr
           ( c_element_entry_id in pay_element_entries_f.element_entry_id%TYPE,
             c_date_earned in pay_payroll_actions.date_earned%TYPE
           ) is

SELECT ptp.start_date
FROM per_time_periods ptp,
pay_payroll_actions ppa,
pay_assignment_actions paa,
pay_run_results prr,
pay_element_entries_f pee
WHERE  pee.element_entry_id=c_element_entry_id
and prr.run_result_id = pee.source_id
and paa.assignment_action_id=prr.assignment_action_id
and ppa.payroll_action_id=paa.payroll_action_id
and ptp.payroll_id=ppa.payroll_id
and pee.creator_type='RR'
and ppa.date_earned between ptp.start_date and ptp.end_date
and c_date_earned between pee.effective_start_date and pee.effective_end_date;

cursor get_retro_period_nr
           ( c_element_entry_id in pay_element_entries_f.element_entry_id%TYPE,
             c_date_earned in pay_payroll_actions.date_earned%TYPE
           ) is

SELECT ptp.start_date
FROM per_time_periods ptp,
pay_payroll_actions ppa,
pay_assignment_actions paa,
pay_run_results prr,
pay_element_entries_f pee
WHERE  pee.element_entry_id=c_element_entry_id
and prr.run_result_id = pee.source_id
and paa.assignment_action_id=prr.assignment_action_id
and ppa.payroll_action_id=paa.payroll_action_id
and ptp.payroll_id=ppa.payroll_id
and pee.creator_type='NR'
and ppa.date_earned between ptp.start_date and ptp.end_date
and c_date_earned between pee.effective_start_date and pee.effective_end_date;

cursor get_retro_period_pr
           ( c_element_entry_id in pay_element_entries_f.element_entry_id%TYPE,
             c_date_earned in pay_payroll_actions.date_earned%TYPE
           ) is

SELECT ptp.start_date
FROM per_time_periods ptp,
pay_payroll_actions ppa,
pay_assignment_actions paa,
pay_run_results prr,
pay_element_entries_f pee
WHERE  pee.element_entry_id=c_element_entry_id
and prr.run_result_id = pee.source_id
and paa.assignment_action_id=prr.assignment_action_id
and ppa.payroll_action_id=paa.payroll_action_id
and ptp.payroll_id=ppa.payroll_id
and pee.creator_type='PR'
and ppa.date_earned between ptp.start_date and ptp.end_date
and c_date_earned between pee.effective_start_date and pee.effective_end_date;

cursor get_retro_period_ee
           ( c_element_entry_id in pay_element_entries_f.element_entry_id%TYPE,
             c_date_earned in pay_payroll_actions.date_earned%TYPE
           ) is
SELECT ptp.start_date
FROM per_time_periods ptp,
pay_payroll_actions ppa,
pay_assignment_actions paa,
pay_element_entries_f pee
WHERE pee.element_entry_id=c_element_entry_id
and  paa.assignment_action_id=pee.source_asg_action_id
and ppa.payroll_action_id=paa.payroll_action_id
and ptp.payroll_id=ppa.payroll_id
and pee.creator_type='EE'
and ppa.date_earned between ptp.start_date and ptp.end_date
and c_date_earned between pee.effective_start_date and pee.effective_end_date;

l_creator_type pay_element_entries_f.creator_type%TYPE;
l_period_obtained_flag number;
l_retro_date date;



begin
l_period_obtained_flag:=1;
hr_utility.set_location('Entering: '||l_period_obtained_flag,1);

   OPEN  c_get_creator_type(p_element_entry_id,p_date_earned);
   FETCH c_get_creator_type INTO l_creator_type ;
   CLOSE c_get_creator_type;


if l_creator_type = 'RR' then
  OPEN get_retro_period_rr(p_element_entry_id,p_date_earned);
  FETCH get_retro_period_rr into  l_retro_date;
  CLOSE get_retro_period_rr;
  l_period_obtained_flag:=1;
end if;

if l_creator_type = 'NR' then
  OPEN get_retro_period_nr(p_element_entry_id,p_date_earned);
  FETCH get_retro_period_nr into  l_retro_date;
  CLOSE get_retro_period_nr;
  l_period_obtained_flag:=1;
end if;

if l_creator_type = 'PR' then
  OPEN get_retro_period_pr(p_element_entry_id,p_date_earned);
  FETCH get_retro_period_pr into  l_retro_date;
  CLOSE get_retro_period_pr;
  l_period_obtained_flag:=1;
end if;

if l_creator_type = 'EE' then
  OPEN get_retro_period_ee(p_element_entry_id,p_date_earned);
  FETCH get_retro_period_ee into  l_retro_date;
  CLOSE get_retro_period_ee;
  l_period_obtained_flag:=1;
end if;

hr_utility.set_location('Entering element entry id: '||p_element_entry_id,4);
hr_utility.set_location('Entering start date earned : '||p_date_earned,5);
hr_utility.set_location('Entering period obtained flag: '||l_period_obtained_flag,6);

return  l_retro_date;


end get_retro_period;

---------------------------------------------------------------------------
-- Function : get_defined_balance_id
-- Function returns the defined balance id
---------------------------------------------------------------------------

FUNCTION GET_DEFINED_BALANCE_ID(p_user_name IN VARCHAR2) RETURN NUMBER
IS
	/* Cursor to retrieve Defined Balance Id */
	CURSOR csr_def_bal_id(p_user_name VARCHAR2) IS
	SELECT  u.creator_id
	FROM    ff_user_entities  u,
		ff_database_items d
	WHERE   d.user_name = p_user_name
	AND     u.user_entity_id = d.user_entity_id
	AND     (u.legislation_code = 'NL' )
	AND     (u.business_group_id IS NULL )
	AND     u.creator_type = 'B';

	l_defined_balance_id ff_user_entities.user_entity_id%TYPE;

BEGIN
	OPEN csr_def_bal_id(p_user_name);
	FETCH csr_def_bal_id INTO l_defined_balance_id;
	CLOSE csr_def_bal_id;
	RETURN l_defined_balance_id;

END GET_DEFINED_BALANCE_ID;

---------------------------------------------------------------------------
-- Function : get_iv_run_result
-- Function returns the input value run_result for the specified element
-- input value name
---------------------------------------------------------------------------
FUNCTION get_iv_run_result(p_run_result_id IN NUMBER
							,p_element_type_id IN NUMBER
							,p_input_value_name IN VARCHAR2) RETURN VARCHAR2 IS
	CURSOR cur_iv_id(lp_element_type_id number,lp_input_value_name varchar2) IS
		SELECT iv.input_value_id
		from pay_input_values_f iv
		where iv.name=lp_input_value_name
		and iv.element_type_id=lp_element_type_id;
	v_cur_iv_id cur_iv_id%ROWTYPE;

	CURSOR cur_iv_rrv(lp_input_value_id number,lp_run_result_id in number) IS
		SELECT rrv.result_value
		from pay_run_result_values rrv
		where rrv.input_value_id=lp_input_value_id
		and rrv.run_result_id=p_run_result_id;
	v_cur_iv_rrv cur_iv_rrv%ROWTYPE;

BEGIN
	v_cur_iv_id := null;

	OPEN cur_iv_id(p_element_type_id,p_input_value_name);
	FETCH cur_iv_id INTO v_cur_iv_id;
	CLOSE cur_iv_id;

	v_cur_iv_rrv := null;
	OPEN cur_iv_rrv(v_cur_iv_id.input_value_id,p_run_result_id);
	FETCH cur_iv_rrv INTO v_cur_iv_rrv;
	CLOSE cur_iv_rrv;

	return v_cur_iv_rrv.result_value;
END get_iv_run_result;

---------------------------------------------------------------------------
-- Function : get_sit_type_name
-- Function returns the Si Type Name for specified Context Balance
---------------------------------------------------------------------------
FUNCTION get_sit_type_name(p_balance_type_id  pay_balance_types.balance_type_id%TYPE
							,p_assgn_action_id  NUMBER
							,p_date_earned      DATE
							,p_si_type	    VARCHAR2) RETURN VARCHAR2 IS

    --
    CURSOR csr_get_sit_type_name (lp_balance_type_id  pay_balance_types.balance_type_id%TYPE
                                ,lp_assgn_action_id  NUMBER
                                ,lp_date_earned      DATE
                                ,lp_si_type	    VARCHAR2) IS
    SELECT prrv1.result_value       si_type_name
    FROM   pay_balance_feeds_f      pbf
          ,pay_balance_types        pbt
          ,pay_input_values_f       piv
          ,pay_input_values_f       piv1
          ,pay_input_values_f       piv2
          ,pay_element_types_f      pet
          ,pay_run_results          prr
          ,pay_run_result_values    prrv
          ,pay_run_result_values    prrv1
    WHERE  pbf.balance_type_id      = pbt.balance_type_id
    AND    pbt.balance_type_id      = lp_balance_type_id
    AND    piv.input_value_id       = pbf.input_value_id
    AND	   (piv.name                 ='Pay Value'
    OR     piv.name                 ='Days')
    AND    pet.element_type_id      = piv.element_type_id
    AND    pet.classification_id <> (SELECT classification_id
            from pay_element_classifications
            where classification_name ='Balance Initialization'
            and business_group_id is null
            and legislation_code is null)
    AND    piv1.element_type_id     = pet.element_type_id
    AND    piv1.name                = 'SI Type Name'
    AND    piv2.element_type_id     = pet.element_type_id
    AND    piv2.name                = 'SI Type'
    AND    prr.element_type_id      = pet.element_type_id
    AND    prr.assignment_action_id = lp_assgn_action_id
    AND    prrv.run_result_id       = prr.run_result_id
    AND    prrv.input_value_id      = piv2.input_value_id
    AND    prrv.result_value        = lp_si_type
    AND    prrv1.run_result_id      = prrv.run_result_id
    AND    prrv1.input_value_id     = piv1.input_value_id
    AND    lp_date_earned             BETWEEN pbf.effective_start_date
                                     AND     pbf.effective_end_date
    AND    lp_date_earned             BETWEEN pet.effective_start_date
                                     AND     pet.effective_end_date
    AND    lp_date_earned             BETWEEN piv.effective_start_date
                                     AND     piv.effective_end_date
    AND    lp_date_earned             BETWEEN piv1.effective_start_date
                                     AND     piv1.effective_end_date
    AND    lp_date_earned             BETWEEN piv2.effective_start_date
                                     AND     piv2.effective_end_date;
	v_csr_get_sit_type_name csr_get_sit_type_name%ROWTYPE;
BEGIN
		OPEN csr_get_sit_type_name(p_balance_type_id
		,p_assgn_action_id
		,p_date_earned
		,p_si_type);
		FETCH csr_get_sit_type_name INTO v_csr_get_sit_type_name;
		CLOSE csr_get_sit_type_name;

		RETURN v_csr_get_sit_type_name.si_type_name;

END get_sit_type_name;

---------------------------------------------------------------------------
-- Procedure : insert_leg_rule
-- Creates a Row in Pay_Legislation_Rules
---------------------------------------------------------------------------
/* Procedure to insert legislation rule via concurrent program*/

PROCEDURE insert_leg_rule(errbuf out nocopy varchar2, retcode out nocopy varchar2,p_retropay_method IN number) is

	CURSOR c_leg_rule(p_rule_type varchar2) is
	SELECT 'Y' FROM pay_legislation_rules
	WHERE legislation_code='NL'
	AND rule_type=p_rule_type;

	l_rule_found varchar2(10):='N';

begin
	retcode := 0;
	fnd_file.put_line(FND_FILE.LOG,'Entering Procedure pay_nl_general.insert_leg_rule');

	OPEN c_leg_rule('RETRO_COMP_DFLT_OVERRIDE');
	FETCH c_leg_rule INTO l_rule_found;

	IF c_leg_rule%NOTFOUND then
	   l_rule_found:='N';
	END if;

	CLOSE c_leg_rule;




	if (p_retropay_method = 1 AND l_rule_found = 'N') then /* Replacement Method */
	   insert into pay_legislation_rules(legislation_code,rule_type,rule_mode)  values ('NL','RETRO_COMP_DFLT_OVERRIDE','Y');
	   fnd_file.put_line(FND_FILE.LOG,'Legislation Rule Added,Retropay method is now REPLACEMENT');
	else   /*Standard Method*/
	   IF (p_retropay_method = 0 AND l_rule_found = 'Y') then
	   delete from pay_legislation_rules
	   where legislation_code='NL'
	   and rule_type='RETRO_COMP_DFLT_OVERRIDE';
	   fnd_file.put_line(FND_FILE.LOG,'Legislation Rule Removed,Retropay method is now STANDARD');
	   END if;
	end if;
	fnd_file.put_line(FND_FILE.LOG,'Leaving Procedure pay_nl_general.insert_leg_rule');
END insert_leg_rule;


---------------------------------------------------------------------------
-- Function : get_default_retro_definition
-- Function returns the Default Retro Definition ID
---------------------------------------------------------------------------


FUNCTION get_default_retro_definition(p_business_group_id IN number)
RETURN NUMBER
is

CURSOR c_leg_rule(p_rule_type varchar2) is
SELECT 'Y' FROM pay_legislation_rules
WHERE legislation_code='NL'
AND rule_type=p_rule_type;

CURSOR c_std_retro_definition
is
SELECT prd.retro_definition_id
FROM   pay_retro_definitions prd
WHERE  prd.legislation_code = 'NL'
AND    prd.definition_name='Standard Retropay';

CURSOR c_rep_retro_definition
is
SELECT prd.retro_definition_id
FROM   pay_retro_definitions prd
WHERE  prd.legislation_code = 'NL'
AND    prd.definition_name='Replacement Retropay';


Cursor c_retro_method(p_business_group_id in number)
is
    Select hoi.org_information2
    from    hr_organization_information hoi
    where  hoi.org_information_context = 'NL_BG_INFO'
    and     hoi.organization_id         = p_business_group_id;


l_rule_found varchar2(10):='N';
l_business_group_id number;
l_retro_method varchar2(10);
l_std_retro_definition_id number;
l_rep_retro_definition_id number;



BEGIN

OPEN c_leg_rule('RETRO_COMP_DFLT_OVERRIDE');
FETCH c_leg_rule INTO l_rule_found;

IF c_leg_rule%NOTFOUND then
   l_rule_found:='N';
END if;

CLOSE c_leg_rule;

OPEN c_std_retro_definition;
FETCH c_std_retro_definition INTO l_std_retro_definition_id;
CLOSE c_std_retro_definition;

OPEN c_rep_retro_definition;
FETCH c_rep_retro_definition INTO l_rep_retro_definition_id;
CLOSE c_rep_retro_definition;


IF l_rule_found='Y' THEN

  /* check if use intends to override replacement method at BG */

  Open c_retro_method(p_business_group_id);
  Fetch c_retro_method  into l_retro_method;
  Close c_retro_method;

  IF l_retro_method='Y' THEN /* override replacement method, use standard retro definition*/
  RETURN l_std_retro_definition_id;
  else
  RETURN l_rep_retro_definition_id;
  END if;

 else

 RETURN l_std_retro_definition_id;


 END if;



END get_default_retro_definition;

 ---------------------------------------------------------------------------
 -- Function : get_global_value
 -- Function returns the global value for the given date earned
 ---------------------------------------------------------------------------
 Function get_global_value(l_date_earned date,l_global_name varchar2) return varchar2 is

 cursor get_global_value(l_global_name varchar2



 ,l_date_earned date)  IS
 select GLOBAL_VALUE
 from ff_globals_f
 where global_name = l_global_name
 and LEGISLATION_CODE = 'NL'
 and BUSINESS_GROUP_ID IS NULL
 and l_date_earned between EFFECTIVE_START_DATE and EFFECTIVE_END_DATE;

 l_value ff_globals_f.global_value%TYPE;
 Begin

 OPEN get_global_value(l_global_name,l_date_earned);
 FETCH get_global_value INTO l_value;
 CLOSE get_global_value;
 Return l_value;
 EXCEPTION
 when others then
 hr_utility.trace('SQLERRM:'||substr(sqlerrm,1,200));
 raise;
 END get_global_value;


 Function get_global_value(l_date_earned date,l_payroll_action_id number,l_global_name varchar2) return varchar2 is

 cursor get_global_value(l_global_name varchar2
  ,l_date date)  IS
 select GLOBAL_VALUE
 from ff_globals_f
 where global_name = l_global_name
 and LEGISLATION_CODE = 'NL'
 and BUSINESS_GROUP_ID IS NULL
 and l_date between EFFECTIVE_START_DATE and EFFECTIVE_END_DATE;

 l_value ff_globals_f.global_value%TYPE;

 l_date date;
 l_effective_date_ppa date;
 l_date_earned_ppa date;

 cursor csr_get_ppa_date is
 select effective_date,date_earned
 from pay_payroll_actions ppa
 where ppa.payroll_action_id = l_payroll_action_id;
 Begin

 open  csr_get_ppa_date;
 fetch csr_get_ppa_date into l_effective_date_ppa,l_date_earned_ppa;
 close csr_get_ppa_date;
 if l_date_earned = l_date_earned_ppa then
    l_date := l_effective_date_ppa;
 else
    l_date := l_date_earned;
 end if;

 OPEN get_global_value(l_global_name,l_date);
 FETCH get_global_value INTO l_value;
 CLOSE get_global_value;
 Return l_value;
 EXCEPTION
 when others then
 hr_utility.trace('SQLERRM:'||substr(sqlerrm,1,200));
 raise;
 END get_global_value;

 --
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                                        +
--                   create_scl_flex_dict                                 +
--                                                                        +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
   NAME
      create_scl_flex_dict - create Soft Coded Legislation Keyflex DB items
--
   DESCRIPTION
      This procedure is the main entry point for creating Soft Coded
      Legislation Keyflex database items.  The parameter passed is is the
      id flex number.
      --
      The database items created use the name as defined in the column
      'segment_name' from the foundation table 'fnd_id_flex_segments'.
      There are 3 levels of SCL keyflex:
      --
      ASSIGNMENT
      PAYROLL
      ORGANIZATION
      --
      The routine loops through and generates DB items for each level.
      For a given SCL flexfield there could be several database items.
      --
      The routine has been enhanced to loop around to create dbitems
      for each of the legislations which use the flex_num passed in.
   NOTES
      It is intended that this  creation procedure be run from the
      Standard Report Submission (SRS) form.
*/
procedure create_scl_flex_dict
(
    p_id_flex_num in number
) is
--
-- declare cursor 0 for retrieving each legislation using this flex num
--
cursor c0 is
select legislation_code
from   pay_legislation_rules
where  rule_type = 'S'
and    rule_mode = to_char (p_id_flex_num);
l_created_by          number;
l_last_login          number;
l_legislation_code    pay_legislation_rules.legislation_code%type;
--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                         create_scl_flex                                +
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/*
   NAME
      create_scl_flex - called from procedure create_scl_flex_dict
--
   DESCRIPTION
      This procedure is called from create_scl_flex_dict, and is responsible
      for creating the user entity and database items for a particular SCL
      flexfield.
*/
procedure create_scl_flex
(
    p_id_flex_num     in number,
    p_leg_code        in varchar2,
    p_route_name      in varchar2,
    p_entity_name     in varchar2,
    p_attribute_type  in varchar2
) is
--
-- declare cursor 1 for retrieving the segment names and target columns
--
cursor c1 is
select SEG.application_column_name     c_def_text,
       replace (ltrim(rtrim(upper(SEG.segment_name))),' ','_') c_db_name,
       SEG.created_by                  c_created_by,
       SEG.last_update_login           c_last_login
from   fnd_id_flex_segments            SEG
,      fnd_segment_attribute_values    VALUE
where  SEG.application_id            = 800
and    SEG.id_flex_code              = 'SCL'
and    SEG.id_flex_num               = p_id_flex_num
and    SEG.enabled_flag              = 'Y'
and    VALUE.application_column_name = SEG.application_column_name
and    VALUE.id_flex_code            = 'SCL'
and    VALUE.id_flex_num             = p_id_flex_num
and    VALUE.segment_attribute_type  = p_attribute_type
and    VALUE.attribute_value         = 'Y';
--
l_user_entity_id   number;
l_db_item_exist    boolean;
l_record_inserted     boolean;
begin
    l_db_item_exist := false;
    for c1rec in c1 loop
        if (l_db_item_exist = false) then  -- first time through loop
            --
            -- create a user entity
            --
            l_created_by := c1rec.c_created_by;
            l_last_login := c1rec.c_last_login;
            --
            hr_utility.trace ('creating SCL flex entity for '|| p_entity_name);
            hrdyndbi.insert_user_entity (p_route_name,
                                p_entity_name,
                                'route for SCL level : '|| p_attribute_type,
                                'Y',
                                'KF',
                                p_id_flex_num,
                                null,               -- null business group id
                                p_leg_code,
                                l_created_by,
                                l_last_login,
                                l_record_inserted);
            --
            -- only insert parameter values/database items if entity
            -- was inserted
            --
            IF l_record_inserted THEN
                --
                -- insert the id flex num for the where clause filler
                --
                hrdyndbi.insert_parameter_value (p_id_flex_num, 1);
                l_db_item_exist := true;
            END IF;
        end if;
        --
        -- now create the database item
        --
        IF p_entity_name = 'SCL_ASG_DE_NL' THEN
        hrdyndbi.insert_database_item (substr(p_entity_name,1,8) || p_leg_code,
                              c1rec.c_db_name || '_DE' ,
                              'T',                           -- data type
                              'target.' || c1rec.c_def_text,
                              'Y',                           -- null allowed
                              'database item for : ' || p_entity_name);
        ELSIF p_entity_name = 'SCL_ASG_DP_NL' THEN
        hrdyndbi.insert_database_item (substr(p_entity_name,1,8) || p_leg_code,
                              c1rec.c_db_name || '_DP' ,
                              'T',                           -- data type
                              'target.' || c1rec.c_def_text,
                              'Y',                           -- null allowed
                              'database item for : ' || p_entity_name);
      ELSE
       hrdyndbi.insert_database_item (p_entity_name,
                                     c1rec.c_db_name  ,
                                     'T',                           -- data type
                                     'target.' || c1rec.c_def_text,
                                     'Y',                           -- null allowed
                              'database item for : ' || p_entity_name);
      END IF;
    end loop;  -- c1 loop
end create_scl_flex;
--
---------------------- create_scl_flex_dict  -------------------------
--
BEGIN
    --
    -- get each legislation code
    --
    hr_utility.set_location ('hrdyndbi.create_scl_flex_dict', 1);
    --
    for c0rec in c0 loop
        --
        l_legislation_code := c0rec.legislation_code;
        --
        -- delete any old SCL keyflex DB items that were created with the same id
        --
        hrdyndbi.delete_keyflex_dict (p_id_flex_num,
                             'SCL',
                             l_legislation_code,
                             null);

        --
        -- delete user entities (and dbitems) owned by a user entity
        -- for an old value of the S leg rule
        --
        delete from ff_user_entities
        where creator_type        = 'KF'
        and   creator_id          <> p_id_flex_num
        and   user_entity_name like 'SCL%'
        and   nvl (legislation_code, ' ') = nvl (l_legislation_code, ' ')
        and   business_group_id is null;

        --
        -- generate DB items for the 3 levels of SCL:
        --

        create_scl_flex (p_id_flex_num,
                         l_legislation_code,
                         'NL Soft Coded Key Flex Information',
                         'SCL_ASG_' || l_legislation_code,
                         'ASSIGNMENT');

        create_scl_flex (p_id_flex_num,
                         l_legislation_code,
                         'SCL_ASS_FLEX_ROUTE',
                         'SCL_ASG_DE_' || l_legislation_code,
                         'ASSIGNMENT');
        --
        create_scl_flex (p_id_flex_num,
                         l_legislation_code,
                         'SCL_ASS_FLEX_DP',
                         'SCL_ASG_DP_' || l_legislation_code,
                         'ASSIGNMENT');
       --
        create_scl_flex (p_id_flex_num,
                         l_legislation_code,
                         'SCL_PAY_FLEX_ROUTE',
                         'SCL_PAY_' || l_legislation_code,
                         'PAYROLL');
        --
        create_scl_flex (p_id_flex_num,
                         l_legislation_code,
                         'SCL_ORG_FLEX_ROUTE',
                         'SCL_ORG_' || l_legislation_code,
                         'ORGANIZATION');
        --
    end loop; -- c0 loop
end create_scl_flex_dict;
--

PROCEDURE cache_formula(p_formula_name           IN VARCHAR2
                        ,p_business_group_id     IN NUMBER
                        ,p_effective_date        IN DATE
                        ,p_formula_id		 IN OUT NOCOPY NUMBER
                        ,p_formula_exists	 IN OUT NOCOPY BOOLEAN
                        ,p_formula_cached	 IN OUT NOCOPY BOOLEAN
                        ) IS

--
  CURSOR c_compiled_formula_exist IS
  SELECT 'Y'
  FROM   ff_formulas_f ff
        ,ff_compiled_info_f ffci
  WHERE  ff.formula_id           = ffci.formula_id
  AND    ff.effective_start_date = ffci.effective_start_date
  AND    ff.effective_end_date   = ffci.effective_end_date
  AND    ff.formula_id           = p_formula_id
  AND    ff.business_group_id    = p_business_group_id
  AND    p_effective_date        BETWEEN ff.effective_start_date
                                 AND     ff.effective_end_date;
--
  CURSOR c_get_formula(p_formula_name ff_formulas_f.formula_name%TYPE
                                 ,p_effective_date DATE)  IS
  SELECT ff.formula_id
  FROM   ff_formulas_f ff
  WHERE  ff.formula_name         = p_formula_name
  AND    ff.business_group_id    = p_business_group_id
  AND    p_effective_date        BETWEEN ff.effective_start_date
                                 AND     ff.effective_end_date;
--
l_test VARCHAR2(1);

BEGIN
--
  IF p_formula_cached = FALSE THEN
  --
  --
    OPEN c_get_formula(p_formula_name,p_effective_date);
    FETCH c_get_formula INTO p_formula_id;
      IF c_get_formula%FOUND THEN
         OPEN c_compiled_formula_exist;
         FETCH c_compiled_formula_exist INTO l_test;
         IF  c_compiled_formula_exist%NOTFOUND THEN
           p_formula_cached := FALSE;
           p_formula_exists := FALSE;
           --
           fnd_message.set_name('PAY','FFX03A_FORMULA_NOT_FOUND');
           fnd_message.set_token('1', p_formula_name);
           fnd_message.raise_error;
         ELSE
           p_formula_cached := TRUE;
           p_formula_exists := TRUE;
         END IF;
      ELSE
        p_formula_cached := FALSE;

        p_formula_exists := FALSE;
      END IF;
    CLOSE c_get_formula;
  END IF;
--
END cache_formula;


PROCEDURE run_formula(p_formula_id      IN NUMBER
                     ,p_effective_date  IN DATE
                     ,p_formula_name    IN VARCHAR2
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
  hr_utility.set_location('--Leaving Formula ',21);
  EXCEPTION
  WHEN hr_formula_error THEN
      fnd_message.set_name('PER','FFX22J_FORMULA_NOT_FOUND');
      fnd_message.set_token('1', p_formula_name);
      fnd_message.raise_error;
  WHEN OTHERS THEN
    raise;
--
END run_formula;

FUNCTION get_element_type_id(p_element_name VARCHAR2,
                             p_effective_date DATE)RETURN number
IS
l_element_type_id number;
BEGIN
select element_type_id into l_element_type_id
from pay_element_types_f
where element_name = p_element_name
and p_effective_date between effective_start_date and effective_end_date
and legislation_code='NL';

return l_element_type_id;

END get_element_type_id;

FUNCTION get_input_value_id(p_element_type_id NUMBER,
                            p_input_value_name VARCHAR2,
                            p_effective_date DATE)RETURN number
IS
l_input_value_id number;
BEGIN
select input_value_id into l_input_value_id
from pay_input_values_f
where element_type_id = p_element_type_id
and name = p_input_value_name
and p_effective_date between effective_start_date and effective_end_date
and legislation_code='NL';

return l_input_value_id;

END get_input_value_id;

------------------------------------------------------------------
-- Function : get_employee_address
-- This is a  function that returns the employee address
-- given the person_id , effective_date
------------------------------------------------------------------
FUNCTION get_employee_address(p_person_id IN    NUMBER
                             ,p_effective_date IN DATE
                             ,p_house_number  IN OUT NOCOPY VARCHAR2
                             ,p_house_no_add  IN OUT NOCOPY VARCHAR2
                             ,p_street_name   IN OUT NOCOPY VARCHAR2
                             ,p_line1         IN OUT NOCOPY VARCHAR2
                             ,p_line2         IN OUT NOCOPY VARCHAR2
                             ,p_line3         IN OUT NOCOPY VARCHAR2
                             ,p_city          IN OUT NOCOPY VARCHAR2
                             ,p_country       IN OUT NOCOPY VARCHAR2
                             ,p_postal_code   IN OUT NOCOPY VARCHAR2
			     ,p_address_type    IN            VARCHAR2  DEFAULT NULL
                             )
  RETURN NUMBER IS


	 CURSOR emp_address
	 IS
	 SELECT   pad.add_information13     house_number
		 ,pad.add_information14     house_no_add
		 ,pad.region_1              street_name
		 ,pad.address_line1         address_line1
		 ,pad.address_line2         address_line2
		 ,pad.address_line3         address_line3
		 ,get_postal_code(pad.postal_code)           postcode				--get the postal code and remove the space
		 ,hr_general.decode_lookup('HR_NL_CITY',pad.town_or_city)          city
		 ,pad.country               country
	FROM      per_addresses pad
	WHERE     pad.person_id=p_person_id
	AND       p_effective_date between date_from AND NVL(date_to,hr_general.end_of_time)
	AND       ((pad.primary_flag = 'Y' and p_address_type is null)
                  or (p_address_type is not null and pad.address_type = p_address_type));

BEGIN
	OPEN emp_address;
	FETCH emp_address INTO p_house_number,p_house_no_add,p_street_name,p_line1,p_line2,p_line3,p_postal_code,p_city,p_country;
	CLOSE emp_address;

p_country := get_country_name(p_country);

RETURN 1;
END get_employee_address;

------------------------------------------------------------------
-- Function : get_emp_address
-- This function returns the employee address with postal code in the correct format
-- given the person_id , effective_date
------------------------------------------------------------------
FUNCTION get_emp_address(p_person_id IN    NUMBER
                             ,p_effective_date IN DATE
                             ,p_house_number  IN OUT NOCOPY VARCHAR2
                             ,p_house_no_add  IN OUT NOCOPY VARCHAR2
                             ,p_street_name   IN OUT NOCOPY VARCHAR2
                             ,p_line1         IN OUT NOCOPY VARCHAR2
                             ,p_line2         IN OUT NOCOPY VARCHAR2
                             ,p_line3         IN OUT NOCOPY VARCHAR2
                             ,p_city          IN OUT NOCOPY VARCHAR2
                             ,p_country       IN OUT NOCOPY VARCHAR2
                             ,p_postal_code   IN OUT NOCOPY VARCHAR2
			     ,p_address_type    IN            VARCHAR2  DEFAULT NULL
                             )
  RETURN NUMBER IS


	 CURSOR emp_address
	 IS
	 SELECT   pad.add_information13     house_number
		 ,pad.add_information14     house_no_add
		 ,pad.region_1              street_name
		 ,pad.address_line1         address_line1
		 ,pad.address_line2         address_line2
		 ,pad.address_line3         address_line3
		 ,get_postal_code_new(pad.postal_code)           postcode	    --introduce a space at the 5th position if there isn't one
		 ,hr_general.decode_lookup('HR_NL_CITY',pad.town_or_city)          city
		 ,pad.country               country
	FROM      per_addresses pad
	WHERE     pad.person_id=p_person_id
	AND       p_effective_date between date_from AND NVL(date_to,hr_general.end_of_time)
	AND       ((pad.primary_flag = 'Y' and p_address_type is null)
                  or (p_address_type is not null and pad.address_type = p_address_type));

BEGIN
	OPEN emp_address;
	FETCH emp_address INTO p_house_number,p_house_no_add,p_street_name,p_line1,p_line2,p_line3,p_postal_code,p_city,p_country;
	CLOSE emp_address;

p_country := get_country_name(p_country);

RETURN 1;
END get_emp_address;


------------------------------------------------------------------
-- Function : get_organization_address
-- This is a  function that returns the organization address
-- given the organization_id and  business_group_id
------------------------------------------------------------------
FUNCTION get_organization_address
                           (p_org_id         IN NUMBER,
                            p_bg_id          IN NUMBER,
                            p_house_number   IN OUT NOCOPY VARCHAR2,
                            p_house_no_add   IN OUT NOCOPY VARCHAR2,
                            p_street_name    IN OUT NOCOPY VARCHAR2,
                            p_line1	     IN OUT NOCOPY VARCHAR2,
                            p_line2	     IN OUT NOCOPY VARCHAR2,
                            p_line3	     IN OUT NOCOPY VARCHAR2,
                            p_city	     IN OUT NOCOPY VARCHAR2,
                            p_country	     IN OUT NOCOPY VARCHAR2,
                            p_postal_code    IN OUT NOCOPY VARCHAR2
                           )
  RETURN NUMBER IS

	  CURSOR c_employer_address IS
		SELECT
			  hlc.loc_information14     house_number
			 ,hlc.loc_information15     house_number_add
			 ,hlc.address_line_1        address_1
			 ,hlc.address_line_2        address_2
			 ,hlc.address_line_3        address_3
			 ,hlc.region_1              street_name
			 ,get_postal_code(hlc.postal_code)           postcode			--get the postal code and remove the space
			 ,hr_general.decode_lookup('HR_NL_CITY',hlc.town_or_city)          city
			 ,hlc.country               country
		FROM  hr_locations              hlc
		      ,hr_organization_units     hou
		WHERE    hou.business_group_id        = p_bg_id
		     AND  hou.organization_id         = p_org_id
		     AND  hlc.location_id             = hou.location_id;



BEGIN

OPEN c_employer_address;
FETCH c_employer_address INTO p_house_number,p_house_no_add,p_line1,p_line2,p_line3,p_street_name,p_postal_code,p_city,p_country;
CLOSE c_employer_address;
p_country := get_country_name(p_country);

RETURN 1;

END get_organization_address;

------------------------------------------------------------------
-- Function : get_org_address
-- This function returns the organization address with postal code in the correct format
-- given the organization_id and  business_group_id
------------------------------------------------------------------
FUNCTION get_org_address
                           (p_org_id         IN NUMBER,
                            p_bg_id          IN NUMBER,
                            p_house_number   IN OUT NOCOPY VARCHAR2,
                            p_house_no_add   IN OUT NOCOPY VARCHAR2,
                            p_street_name    IN OUT NOCOPY VARCHAR2,
                            p_line1	     IN OUT NOCOPY VARCHAR2,
                            p_line2	     IN OUT NOCOPY VARCHAR2,
                            p_line3	     IN OUT NOCOPY VARCHAR2,
                            p_city	     IN OUT NOCOPY VARCHAR2,
                            p_country	     IN OUT NOCOPY VARCHAR2,
                            p_postal_code    IN OUT NOCOPY VARCHAR2
                           )
  RETURN NUMBER IS

	  CURSOR c_employer_address IS
		SELECT
			  hlc.loc_information14     house_number
			 ,hlc.loc_information15     house_number_add
			 ,hlc.address_line_1        address_1
			 ,hlc.address_line_2        address_2
			 ,hlc.address_line_3        address_3
			 ,hlc.region_1              street_name
			 ,get_postal_code_new(hlc.postal_code)           postcode    --introduce a space at the 5th position if there isn't one
			 ,hr_general.decode_lookup('HR_NL_CITY',hlc.town_or_city)          city
			 ,hlc.country               country
		FROM  hr_locations              hlc
		      ,hr_organization_units     hou
		WHERE    hou.business_group_id        = p_bg_id
		     AND  hou.organization_id         = p_org_id
		     AND  hlc.location_id             = hou.location_id;



BEGIN

OPEN c_employer_address;
FETCH c_employer_address INTO p_house_number,p_house_no_add,p_line1,p_line2,p_line3,p_street_name,p_postal_code,p_city,p_country;
CLOSE c_employer_address;
p_country := get_country_name(p_country);

RETURN 1;

END get_org_address;

------------------------------------------------------------------
-- Function : get_country_name
-- This is a  function that returns the territory name
-- given the territory code
------------------------------------------------------------------
FUNCTION get_country_name(p_territory_code IN  VARCHAR2)
  RETURN VARCHAR2 IS

l_territory_name fnd_territories_vl.territory_short_name%TYPE;

	CURSOR c_territory_name IS
		 SELECT ter.territory_short_name
		 FROM fnd_territories_vl ter
		 WHERE ter.territory_code = p_territory_code;

BEGIN
	OPEN c_territory_name;
	FETCH c_territory_name INTO l_territory_name;
	CLOSE c_territory_name;

RETURN l_territory_name;
END get_country_name;

------------------------------------------------------------------------------
-- Function : get_retro_sum_pri_class
-- Function returns the sum of retrospective values for a sub classification
-- for a period.
-------------------------------------------------------------------------------
FUNCTION get_retro_sum_pri_class(p_retro_period IN DATE,
                            p_pri_class_name IN VARCHAR2,
			                 p_assact_id IN NUMBER)
RETURN NUMBER IS
cursor csr_get_retro_bal_val IS
select sum(nvl(fnd_number.canonical_to_number(prv.result_value),0))  value
    from
    pay_payroll_actions ppa,
    pay_assignment_actions paa,
    pay_run_results prr,
    pay_run_result_values prv,
    pay_element_types_f pet,
    pay_element_classifications pec,
    pay_input_values_f piv
    where
    paa.payroll_action_id=ppa.payroll_action_id
    and paa.SOURCE_ACTION_ID is not null
   -- and ppa.payroll_action_id = paa.payroll_action_id
    and paa.action_status='C'
    and prr.ASSIGNMENT_ACTION_ID=paa.assignment_action_id
    and pay_nl_general.get_retro_period(prr.source_id,ppa.effective_date) = p_retro_period
    and prr.run_result_id=prv.run_result_id
    and pet.element_type_id = prr.element_type_id
    and pec.classification_id=pet.classification_id
    and pec.legislation_code = 'NL'
    and pet.element_type_id = piv.element_type_id
    and piv.name ='Pay Value'
   -- and piv.legislation_code='NL'
    and prv.input_value_id = piv.input_value_id
    and p_retro_period between piv.effective_start_date and piv.effective_end_date
    and pec.classification_name= p_pri_class_name
 --   and ppa.payroll_action_id= nvl(p_pact_id,ppa.payroll_action_id)
    and paa.assignment_action_id= p_assact_id;
  l_value number;
begin
OPEN csr_get_retro_bal_val;
FETCH csr_get_retro_bal_val INTO l_value;
CLOSE csr_get_retro_bal_val;
RETURN l_value;
END get_retro_sum_pri_class;
-------------------------------------------------------------------------------
-- Function : get_retro_sum_sec_class
-- Function returns the sum of retrospective values for a sub classification
-- for a period.
-------------------------------------------------------------------------------
FUNCTION get_retro_sum_sec_class(p_retro_period IN DATE,
                            p_sec_class_name IN VARCHAR2,
			                p_assact_id IN NUMBER)
RETURN NUMBER IS
CURSOR csr_retro_bal_val IS
select sum(nvl(fnd_number.canonical_to_number(prv.result_value),0)) value
	from
	pay_payroll_actions ppa,
	pay_assignment_actions paa,
	pay_run_results prr,
	pay_run_result_values prv,
	pay_element_types_f pet,
	pay_element_classifications pec,
	pay_sub_classification_rules_f pecs,
        pay_input_values_f piv
	where
	paa.payroll_action_id=ppa.payroll_action_id
	and paa.SOURCE_ACTION_ID is not null
	and ppa.payroll_action_id = paa.payroll_action_id
	and paa.action_status='C'
	and prr.ASSIGNMENT_ACTION_ID=paa.assignment_action_id
	and pay_nl_general.get_retro_period(prr.source_id,ppa.effective_date) = p_retro_period
        and prr.run_result_id=prv.run_result_id
	and pet.element_type_id = prr.element_type_id
        and pec.legislation_code = 'NL'
	and pecs.classification_id=pec.classification_id
	and pecs.element_type_id=pet.element_type_Id
	and pet.element_type_id = piv.element_type_id
        and piv.name ='Pay Value'
     -- and piv.legislation_code='NL'
        and prv.input_value_id = piv.input_value_id
        and p_retro_period between piv.effective_start_date and piv.effective_end_date
	and pec.classification_name=p_sec_class_name
--	and ppa.payroll_action_id=nvl(p_pact_id,ppa.payroll_action_id)
	and paa.assignment_action_id= p_assact_id;

	-- (select max(paa1.assignment_action_id) from
           --                                                   pay_assignment_actions paa1
           --                                                   where
	   --                                               paa1.payroll_action_id=ppa.payroll_action_id
           --                                            and paa1.assignment_id=paa.assignment_id);

l_value number;
begin
OPEN csr_retro_bal_val;
FETCH csr_retro_bal_val INTO l_value;
CLOSE csr_retro_bal_val;
RETURN l_value;
END get_retro_sum_sec_class;
-------------------------------------------------------------------------------
-- Function : get_retro_sum_element
-- Function returns the sum of retrospective values  values for an element
-------------------------------------------------------------------------------
FUNCTION get_retro_sum_element(p_retro_period IN DATE,
                               P_input_value_id IN NUMBER,
                               p_element_type_id  IN NUMBER,
                               p_context IN VARCHAR2,
			       p_end_of_year IN VARCHAR2,
			       p_assact_id IN NUMBER)
RETURN NUMBER IS
CURSOR csr_retro_element_context IS
select 	sum(nvl(fnd_number.canonical_to_number(prv.result_value),0)) value
	from
	pay_payroll_actions ppa,
	pay_assignment_actions paa,
	pay_run_results prr,
	pay_run_result_values prv,
	pay_run_result_values prv1,
	pay_action_contexts pac,
	pay_input_values_f piv
	where
	paa.payroll_action_id=ppa.payroll_action_id
	and paa.SOURCE_ACTION_ID is not null
	and ppa.payroll_action_id = paa.payroll_action_id
	and paa.action_status='C'
	and prr.ASSIGNMENT_ACTION_ID=paa.assignment_action_id
    and paa.assignment_action_id  = pac.assignment_action_id
	and pay_nl_general.get_retro_period(prr.source_id,ppa.effective_date) = p_retro_period
    and prr.run_result_id=prv.run_result_id
	and prv.input_value_id = P_input_value_id
--    and ppa.payroll_action_id=nvl(p_pact_id,ppa.payroll_action_id)
        and prr.run_result_id=prv1.run_result_id
	AND prv1.input_value_id = piv.input_value_id
	and piv.name = 'SI Type'
    and pac.context_value   =  prv1.result_value
    and pac.context_value   =  p_context
	and ppa.effective_date
	between nvl(trunc(fnd_date.canonical_to_date(P_END_OF_YEAR),'Y'),ppa.effective_date)
	and nvl(fnd_date.canonical_to_date(P_END_OF_YEAR),ppa.effective_date)
	and ppa.effective_date between piv.effective_Start_Date and piv.effective_end_date
	and paa.assignment_action_id=p_assact_id;

CURSOR csr_retro_element IS
select 	sum(nvl(fnd_number.canonical_to_number(prv.result_value),0)) value
	from
	pay_payroll_actions ppa,
	pay_assignment_actions paa,
	pay_run_results prr,
	pay_run_result_values prv,
	pay_input_values_f  piv
    Where
	paa.payroll_action_id=ppa.payroll_action_id
	and paa.SOURCE_ACTION_ID is not null
	and ppa.payroll_action_id = paa.payroll_action_id
	and paa.action_status='C'
	and prr.ASSIGNMENT_ACTION_ID=paa.assignment_action_id
	and pay_nl_general.get_retro_period(prr.source_id,ppa.effective_date) = p_retro_period
        and prr.run_result_id=prv.run_result_id
	and prr.element_type_id = p_element_type_id
	and piv.element_type_id = p_element_type_id
	and piv.name ='Pay Value'
        and prv.input_value_id = piv.input_value_id
  --      and ppa.payroll_action_id=nvl(p_pact_id,ppa.payroll_action_id)
	and ppa.effective_date
	between nvl(trunc(fnd_date.canonical_to_date(P_END_OF_YEAR),'Y'),ppa.effective_date)
	and nvl(fnd_date.canonical_to_date(P_END_OF_YEAR),ppa.effective_date)
	and paa.assignment_action_id=p_assact_id;
l_value number;
begin
if p_context is not null then
OPEN csr_retro_element_context;
FETCH csr_retro_element_context INTO l_value;
CLOSE csr_retro_element_context;
else
OPEN csr_retro_element;
FETCH csr_retro_element INTO l_value;
CLOSE csr_retro_element;
end if;
RETURN l_value;
END get_retro_sum_element;

------------------------------------------------------------------------------
--Function :get_sum_element_pri_class
--Function returns the sum of non retrospective values for an element
--Classification
-----------------------------------------------------------------------------

FUNCTION get_sum_element_pri_class(p_effective_date IN DATE,
                            p_pri_class_name IN VARCHAR2,
			                p_assact_id IN NUMBER)
RETURN NUMBER IS
cursor csr_get_elmt_bal_val IS
select sum(nvl(fnd_number.canonical_to_number(prv.result_value),0)) value
    from
    pay_payroll_actions ppa,
    pay_assignment_actions paa,
    pay_run_results prr,
    pay_run_result_values prv,
    pay_element_types_f pet,
    pay_element_classifications pec,
    pay_input_values_f  piv
    where
    paa.payroll_action_id=ppa.payroll_action_id
    and paa.SOURCE_ACTION_ID is not null
  --  and ppa.payroll_action_id = paa.payroll_action_id
    and paa.action_status='C'
    and prr.ASSIGNMENT_ACTION_ID=paa.assignment_action_id
    and ppa.effective_date =  p_effective_date
    -- and pay_nl_general.get_retro_period(prr.source_id,ppa.effective_date) = p_retro_period
    and prr.run_result_id=prv.run_result_id
    and pet.element_type_id = prr.element_type_id
    and pet.element_type_id = piv.element_type_id
    and piv.name ='Pay Value'
    -- and piv. legislation_code='NL'
    and prv.input_value_id = piv.input_value_id
    and pec.classification_id=pet.classification_id
    and pec.legislation_code = 'NL'
    and pec.classification_name= p_pri_class_name
    and  p_effective_date between piv.effective_start_date and piv.effective_end_date
    -- and ppa.payroll_action_id= nvl(p_pact_id,ppa.payroll_action_id)
    and paa.assignment_action_id=p_assact_id;

  l_value number;
begin
OPEN csr_get_elmt_bal_val;
FETCH csr_get_elmt_bal_val INTO l_value;
CLOSE csr_get_elmt_bal_val;
RETURN l_value;
END get_sum_element_pri_class;

-----------------------------------------------------------------------------
--Function :format_number_field
--Function returns a formatted string for a number with decimal
-----------------------------------------------------------------------------
function format_number_field(p_number number,
                             p_mpy_factor number,
                             p_field_length number)
return varchar2 is
l_format_value varchar2(30);
begin
	l_format_value := lpad(p_number*p_mpy_factor,p_field_length,'0');
	return l_format_value;
end format_number_field;

-----------------------------------------------------------------------------
--Function : GET_PARAMETER
-- GET_PARAMETER  used in SQL to decode legislative parameters
-----------------------------------------------------------------------------
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
-----------------------------------------------------------------------------
-- Function :get_file_id
-- Function returns file id on the effective date
-------------------------------------------------------------------------------
FUNCTION  get_file_id(p_effective_date IN DATE) RETURN VARCHAR2 AS
  --
  CURSOR get_file_no_per_day IS
  SELECT count(*)
  FROM   pay_payroll_actions ppa
  WHERE  TRIM(PAY_NL_GENERAL.get_parameter(ppa.legislative_parameters
                                          ,'MAGTAPE_REPORT_ID'))= 'NL_PAYFILE'
  AND    action_type	    = 'M'
  AND    action_status    = 'C'
  AND    effective_date   =  p_effective_date;
  --
  l_file_id VARCHAR2(4);
  l_count   NUMBER :=0;
  --
BEGIN
  OPEN get_file_no_per_day;
    FETCH get_file_no_per_day INTO l_count;
  CLOSE get_file_no_per_day;
  RETURN (to_char(p_effective_date,'DD') ||
          lpad(to_char(mod(l_count,99)+1),2,'0')
          );
END  get_file_id;

-----------------------------------------------------------------------------
-- Function :chk_multiple_assignments
-- Function to determine the existance of multiple assignments for an employee
-------------------------------------------------------------------------------
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
-----------------------------------------------------------------------------

------------------------------------------------------------------------------
--Function :get_sum_element_sec_class
--Function returns the sum of non retrospective values for an element
--with the given Secondary Classification
-----------------------------------------------------------------------------
FUNCTION get_sum_element_sec_class(p_effective_date IN DATE,
				   p_sec_class_name IN VARCHAR2,
			           p_assact_id IN NUMBER)
RETURN NUMBER AS
cursor csr_get_elmt_bal_val is
select sum(nvl(fnd_number.canonical_to_number(prv.result_value),0)) value
    from
    pay_payroll_actions ppa,
    pay_assignment_actions paa,
    pay_run_results prr,
    pay_run_result_values prv,
    pay_element_types_f pet,
    pay_element_classifications pec,
    pay_sub_classification_rules_f pecs,
    pay_input_values_f  piv
    where
    paa.payroll_action_id=ppa.payroll_action_id
    and paa.SOURCE_ACTION_ID is not null
    and paa.action_status='C'
    and prr.ASSIGNMENT_ACTION_ID=paa.assignment_action_id
    and ppa.effective_date = p_effective_date
    and prr.run_result_id=prv.run_result_id
    and pet.element_type_id = prr.element_type_id
    and pet.element_type_id = piv.element_type_id
    and piv.name ='Pay Value'
    and prv.input_value_id = piv.input_value_id
    and pec.legislation_code = 'NL'
    and pecs.classification_id=pec.classification_id
    and pecs.element_type_id=pet.element_type_Id
    and pec.classification_name= p_sec_class_name
    and  p_effective_date between piv.effective_start_date and piv.effective_end_date
    and paa.assignment_action_id= p_assact_id;

l_value number;

Begin
OPEN csr_get_elmt_bal_val;
FETCH csr_get_elmt_bal_val INTO l_value;
CLOSE csr_get_elmt_bal_val;
RETURN l_value;

end get_sum_element_sec_class;

-----------------------------------------------------------------------------
-- Function :get_retro_status
-- Function to determine whether replacement retropay method is running
-------------------------------------------------------------------------------
FUNCTION get_retro_status(p_date_earned date,p_payroll_action_id number) return varchar2 is

l_retro_status varchar(10) := 'N';
l_date_earned_ppa date;

cursor csr_get_ppa_date is
select date_earned
from pay_payroll_actions ppa
where ppa.payroll_action_id = p_payroll_action_id;

Begin

open  csr_get_ppa_date;
fetch csr_get_ppa_date into l_date_earned_ppa;
close csr_get_ppa_date;

if p_date_earned = l_date_earned_ppa then
   l_retro_status := 'N';
else
   l_retro_status := 'Y';
end if;

Return l_retro_status;

EXCEPTION
when others then
hr_utility.trace('SQLERRM:'||substr(sqlerrm,1,200));
raise;
END get_retro_status;

-----------------------------------------------------------------------------
-- Function :get_num_payroll_periods
-- Function to get number of payroll periods in a year
-------------------------------------------------------------------------------
FUNCTION get_num_payroll_periods(p_payroll_action_id IN NUMBER)
RETURN NUMBER is

cursor csr_get_num_periods(c_payroll_action_id NUMBER) is
select max(TPERIOD.period_num) from
pay_payroll_actions PACTION
,per_time_periods TPERIOD
where PACTION.payroll_action_id = c_payroll_action_id
and TPERIOD.payroll_id = PACTION.payroll_id
and to_char(PACTION.date_earned,'YYYY') = to_char(TPERIOD.regular_payment_date,'YYYY');

pay_periods_per_year  number;

BEGIN

open csr_get_num_periods(p_payroll_action_id);
fetch csr_get_num_periods into pay_periods_per_year;
close csr_get_num_periods;

RETURN pay_periods_per_year;

END get_num_payroll_periods;

-----------------------------------------------------------------------------
-- Function :check_de_dp_dimension
-- Function to check whether Date paid or balance date dimenions to be used.
-------------------------------------------------------------------------------
FUNCTION check_de_dp_dimension(p_pay_act_id  NUMBER
                              ,p_ass_id      NUMBER
                              ,p_ass_act_id  NUMBER) RETURN VARCHAR2 IS
    --
    /*
    CURSOR csr_prev_payroll_exists(c_assignment_action_id NUMBER
                                  ,c_assignment_id        NUMBER
                                  ,c_start_date           DATE
                                  ,c_end_date             DATE)IS
    SELECT 'DP' FROM dual
    WHERE  EXISTS (SELECT 1
                   FROM   pay_assignment_actions paa1
                         ,pay_assignment_actions paa2
                         ,pay_payroll_actions ppa
                   WHERE  paa1.assignment_action_id = c_assignment_action_id
                   AND    paa2.assignment_id = c_assignment_id
                   AND    paa1.tax_unit_id = paa2.tax_unit_id
                   AND    ppa.action_type IN ('Q','R')
                   AND    ppa.action_status = 'C'
                   AND    ppa.payroll_action_id = paa2.payroll_action_id
                   AND    ppa.effective_date    < c_start_date);

    --
    CURSOR csr_diff_de_dp(c_payroll_action_id    NUMBER
                         ,c_assignment_id        NUMBER
                         ,c_start_date           DATE
                         ,c_end_date             DATE)IS
    SELECT 'DE' FROM dual
    WHERE EXISTS (SELECT 1
                  FROM   pay_assignment_actions paa
                        ,pay_payroll_actions ppa
                  WHERE  paa.assignment_id = c_assignment_id
                  AND    ppa.payroll_action_id = paa.payroll_action_id
                  AND    ppa.action_type IN ('Q','R')
                  AND    ppa.action_status in ('C','P')
                  AND    ppa.date_earned NOT BETWEEN  c_start_date AND c_end_date
                  AND    ppa.effective_date BETWEEN c_start_date AND c_end_date);
    */
    --
    CURSOR c1 (c_payroll_action_id NUMBER)IS
    SELECT ptp.start_date
          ,ptp.end_date
          ,ppa.action_type
          ,ppa.action_status
          ,ppa.date_earned
          ,ppa.business_group_id
    FROM   pay_payroll_actions ppa
          ,per_time_periods ptp
    WHERE  ppa.payroll_action_id = c_payroll_action_id
    AND    ptp.time_period_id = ppa.time_period_id;
    --
    CURSOR csr_get_all_ass(c_assignment_id  NUMBER
                          ,c_start_date     DATE
                          ,c_end_date       DATE) IS
    SELECT distinct pog2.parent_object_group_id parent_id
          ,pog2.source_id assignment_id
    FROM   pay_object_groups pog1
          ,pay_object_groups pog2
    WHERE  pog1.source_id = c_assignment_id
    AND    pog1.source_type = pog2.source_type
    AND    pog1.source_type = 'PAF'
    AND    pog1.parent_object_group_id = pog2.parent_object_group_id
    AND    (pog1.start_date <= c_end_date AND pog1.end_date >= c_start_date)
    AND    (pog2.start_date <= c_end_date AND pog2.end_date >= c_start_date);
    --
    CURSOR csr_get_late_starter_flag(c_business_group_id NUMBER) IS
    SELECT org_information7
    FROM   hr_organization_information
    WHERE  organization_id = c_business_group_id
    AND    org_information_context = 'NL_BG_INFO';
    --
    CURSOR csr_chk_element_entry(c_parent_id  NUMBER
                                ,c_eff_date   DATE) IS
    SELECT 'Y'
    FROM   dual
    WHERE  exists (SELECT 1
                   FROM   pay_object_groups pog
                         ,pay_element_entries_f peef
                         ,pay_element_types_f petf
                   WHERE  pog.parent_object_group_id = c_parent_id
                   AND    peef.assignment_id         = pog.source_id
                   AND    peef.element_type_id       = petf.element_type_id
                   AND    petf.element_name          = 'Late Hire Indicator'
                   AND    c_eff_date BETWEEN peef.effective_start_date AND peef.effective_end_date
                   AND    c_eff_date BETWEEN petf.effective_start_date AND petf.effective_end_date);
    --
    l_result VARCHAR2(5);
    l_start_date DATE;
    l_end_date DATE;
    l_type   VARCHAR2(10);
    l_status VARCHAR2(10);
    l_date_earned DATE;
    l_parent_id NUMBER;
    l_bg_id  NUMBER;
    l_late_hire_indicator VARCHAR2(10);
    l_entry_exist VARCHAR2(1);
    --
BEGIN
    --
    --HR_UTILITY.TRACE_ON(NULL,'GR');
    HR_UTILITY.TRACE('~~ Assignment_id :'||p_ass_id);
    IF g_late_hire_indicator = 'N' THEN
      HR_UTILITY.TRACE('~~ 1 Result : DP');
      RETURN 'DP';
    END IF;
    --
    OPEN  C1(p_pay_act_id);
    FETCH C1 INTO l_start_date,l_end_date,l_type,l_status,l_date_earned,l_bg_id;
    CLOSE C1;
    --
    IF NVL(g_late_hire_indicator,'X') = 'X' THEN
      OPEN  csr_get_late_starter_flag(l_bg_id);
      FETCH csr_get_late_starter_flag INTO l_late_hire_indicator;
      CLOSE csr_get_late_starter_flag;
      --
      g_late_hire_indicator := NVL(l_late_hire_indicator,'Y');
      IF g_late_hire_indicator = 'N' THEN
        HR_UTILITY.TRACE('~~ 2 Result : DP');
        RETURN 'DP';
      END IF;
    END IF;
    --
    l_result := 'DP';
    --
    l_entry_exist := NULL;
    --
    FOR i in csr_get_all_ass(p_ass_id,l_start_date,l_end_date) LOOP
        IF NVL(g_parent_id,-1) = i.parent_id
           AND g_result IS NOT NULL
           AND NVL(g_payroll_action_id,-1) = p_pay_act_id THEN
            return g_result;
        END IF;
        l_parent_id := i.parent_id;
        --
        IF l_entry_exist IS NULL THEN
          OPEN  csr_chk_element_entry(i.parent_id,l_date_earned);
          FETCH csr_chk_element_entry INTO l_entry_exist;
          CLOSE csr_chk_element_entry;
          --
          l_entry_exist := NVL(l_entry_exist,'N');
          --
          IF l_entry_exist = 'Y' THEN
            g_result := 'DE';
            g_payroll_action_id := p_pay_act_id;
            g_parent_id := l_parent_id;
            HR_UTILITY.TRACE('~~ 3 Result : '||g_result);
            RETURN g_result;
          END IF;
        END IF;
        --
	/*
	  l_result := NULL;
        --
        OPEN csr_prev_payroll_exists(p_ass_act_id,i.assignment_id,l_start_date,l_end_date);
        FETCH csr_prev_payroll_exists INTO l_result;
        CLOSE csr_prev_payroll_exists;
        --
        --
        IF l_result IS NULL THEN
            OPEN csr_diff_de_dp(p_pay_act_id,i.assignment_id,l_start_date,l_end_date);
            FETCH csr_diff_de_dp INTO l_result;
            IF csr_diff_de_dp%FOUND THEN
                g_result := 'DE';
                g_payroll_action_id := p_pay_act_id;
                g_parent_id := l_parent_id;
                CLOSE csr_diff_de_dp;
                HR_UTILITY.TRACE('~~ 4 Result : DE');
                RETURN 'DE';
            END IF;
            CLOSE csr_diff_de_dp;
        END IF;
	*/
        --
    END LOOP;
    --
    g_payroll_action_id := p_pay_act_id;
    g_parent_id := l_parent_id;
    g_result := 'DP';
    HR_UTILITY.TRACE('~~ 5 Result : '||g_result);
    RETURN l_result;
    --
END check_de_dp_dimension;
--
-----------------------------------------------------------------------------
-- Function :check_de_dp_dimension_old
-------------------------------------------------------------------------------

FUNCTION check_de_dp_dimension_old(p_pay_act_id  NUMBER
                              ,p_ass_id      NUMBER
                              ,p_ass_act_id  NUMBER) RETURN VARCHAR2 IS
    --
    CURSOR csr_prev_payroll_exists(c_assignment_action_id NUMBER
                                  ,c_assignment_id        NUMBER
                                  ,c_start_date           DATE
                                  ,c_end_date             DATE)IS
    SELECT 'DP' FROM dual
    WHERE  EXISTS (SELECT 1
                   FROM   pay_assignment_actions paa1
                         ,pay_assignment_actions paa2
                         ,pay_payroll_actions ppa
                   WHERE  paa1.assignment_action_id = c_assignment_action_id
                   AND    paa2.assignment_id = c_assignment_id
                   AND    paa1.tax_unit_id = paa2.tax_unit_id
                   AND    ppa.action_type IN ('Q','R')
                   AND    ppa.action_status = 'C'
                   AND    ppa.payroll_action_id = paa2.payroll_action_id
                   AND    ppa.effective_date    < c_start_date);

    --
    CURSOR csr_diff_de_dp(c_payroll_action_id    NUMBER
                         ,c_assignment_id        NUMBER
                         ,c_start_date           DATE
                         ,c_end_date             DATE)IS
    SELECT 'DE' FROM dual
    WHERE EXISTS (SELECT 1
                  FROM   pay_assignment_actions paa
                        ,pay_payroll_actions ppa
                  WHERE  paa.assignment_id = c_assignment_id
                  AND    ppa.payroll_action_id = paa.payroll_action_id
                  AND    ppa.action_type IN ('Q','R')
                  AND    ppa.action_status in ('C','P')
                  AND    ppa.date_earned NOT BETWEEN  c_start_date AND c_end_date
                  AND    ppa.effective_date BETWEEN c_start_date AND c_end_date);
    --
    CURSOR c1 (c_payroll_action_id NUMBER)IS
    SELECT ptp.start_date
          ,ptp.end_date
          ,ppa.action_type
          ,ppa.action_status
          ,ppa.date_earned
          ,ppa.business_group_id
    FROM   pay_payroll_actions ppa
          ,per_time_periods ptp
    WHERE  ppa.payroll_action_id = c_payroll_action_id
    AND    ptp.time_period_id = ppa.time_period_id;
    --
    CURSOR csr_get_all_ass(c_assignment_id  NUMBER
                          ,c_start_date     DATE
                          ,c_end_date       DATE) IS
    SELECT distinct pog2.parent_object_group_id parent_id
          ,pog2.source_id assignment_id
    FROM   pay_object_groups pog1
          ,pay_object_groups pog2
    WHERE  pog1.source_id = c_assignment_id
    AND    pog1.source_type = pog2.source_type
    AND    pog1.source_type = 'PAF'
    AND    pog1.parent_object_group_id = pog2.parent_object_group_id
    AND    (pog1.start_date <= c_end_date AND pog1.end_date >= c_start_date)
    AND    (pog2.start_date <= c_end_date AND pog2.end_date >= c_start_date);
    --
    CURSOR csr_get_late_starter_flag(c_business_group_id NUMBER) IS
    SELECT org_information7
    FROM   hr_organization_information
    WHERE  organization_id = c_business_group_id
    AND    org_information_context = 'NL_BG_INFO';
    --
    CURSOR csr_chk_element_entry(c_parent_id  NUMBER
                                ,c_eff_date   DATE) IS
    SELECT 'Y'
    FROM   dual
    WHERE  exists (SELECT 1
                   FROM   pay_object_groups pog
                         ,pay_element_entries_f peef
                         ,pay_element_types_f petf
                   WHERE  pog.parent_object_group_id = c_parent_id
                   AND    peef.assignment_id         = pog.source_id
                   AND    peef.element_type_id       = petf.element_type_id
                   AND    petf.element_name          = 'Late Hire Indicator'
                   AND    c_eff_date BETWEEN peef.effective_start_date AND peef.effective_end_date
                   AND    c_eff_date BETWEEN petf.effective_start_date AND petf.effective_end_date);
    --
    l_result VARCHAR2(5);
    l_start_date DATE;
    l_end_date DATE;
    l_type   VARCHAR2(10);
    l_status VARCHAR2(10);
    l_date_earned DATE;
    l_parent_id NUMBER;
    l_bg_id  NUMBER;
    l_late_hire_indicator VARCHAR2(10);
    l_entry_exist VARCHAR2(1);
    --
BEGIN
    --
    --HR_UTILITY.TRACE_ON(NULL,'GR');
    HR_UTILITY.TRACE('~~~ Assignment_id :'||p_ass_id);
    IF g_late_hire_indicator = 'N' THEN
      HR_UTILITY.TRACE('~~~ 1 Result : DP');
      RETURN 'DP';
    END IF;
    --
    OPEN  C1(p_pay_act_id);
    FETCH C1 INTO l_start_date,l_end_date,l_type,l_status,l_date_earned,l_bg_id;
    CLOSE C1;
    --
    IF NVL(g_late_hire_indicator,'X') = 'X' THEN
      OPEN  csr_get_late_starter_flag(l_bg_id);
      FETCH csr_get_late_starter_flag INTO l_late_hire_indicator;
      CLOSE csr_get_late_starter_flag;
      --
      g_late_hire_indicator := NVL(l_late_hire_indicator,'Y');
      IF g_late_hire_indicator = 'N' THEN
        HR_UTILITY.TRACE('~~~ 2 Result : DP');
        RETURN 'DP';
      END IF;
    END IF;
    --
    l_result := 'DP';
    --
    l_entry_exist := NULL;
    --
    FOR i in csr_get_all_ass(p_ass_id,l_start_date,l_end_date) LOOP
        IF NVL(g_parent_id,-1) = i.parent_id
           AND g_result IS NOT NULL
           AND NVL(g_payroll_action_id,-1) = p_pay_act_id THEN
            return g_result;
        END IF;
        l_parent_id := i.parent_id;
        --
        IF l_entry_exist IS NULL THEN
          OPEN  csr_chk_element_entry(i.parent_id,l_date_earned);
          FETCH csr_chk_element_entry INTO l_entry_exist;
          CLOSE csr_chk_element_entry;
          --
          l_entry_exist := NVL(l_entry_exist,'N');
          --
          IF l_entry_exist = 'Y' THEN
            g_result := 'DE';
            g_payroll_action_id := p_pay_act_id;
            g_parent_id := l_parent_id;
            HR_UTILITY.TRACE('~~~ 3 Result : '||g_result);
            RETURN g_result;
          END IF;
        END IF;
        --
        l_result := NULL;
        --
        OPEN csr_prev_payroll_exists(p_ass_act_id,i.assignment_id,l_start_date,l_end_date);
        FETCH csr_prev_payroll_exists INTO l_result;
        CLOSE csr_prev_payroll_exists;
        --
        --
        IF l_result IS NULL THEN
            OPEN csr_diff_de_dp(p_pay_act_id,i.assignment_id,l_start_date,l_end_date);
            FETCH csr_diff_de_dp INTO l_result;
            IF csr_diff_de_dp%FOUND THEN
                g_result := 'DE';
                g_payroll_action_id := p_pay_act_id;
                g_parent_id := l_parent_id;
                CLOSE csr_diff_de_dp;
                HR_UTILITY.TRACE('~~~ 4 Result : DE');
                RETURN 'DE';
            END IF;
            CLOSE csr_diff_de_dp;
        END IF;
        --
    END LOOP;
    --
    g_payroll_action_id := p_pay_act_id;
    g_parent_id := l_parent_id;
    g_result := 'DP';
    HR_UTILITY.TRACE('~~~ 5 Result : '||g_result);
    RETURN g_result;
    --
END check_de_dp_dimension_old;

--
-----------------------------------------------------------------------------
-- Function :check_de_dp_dimension_qtd
-- Function to check whether Date paid or balance date dimenions is to be used
-- for QTD dimensions   .
-------------------------------------------------------------------------------
FUNCTION check_de_dp_dimension_qtd(p_pay_act_id  NUMBER
                                  ,p_ass_id      NUMBER
                                  ,p_ass_act_id  NUMBER
                                  ,p_type        VARCHAR2) RETURN VARCHAR2 IS
    --
    /*
    CURSOR csr_prev_qtd_payroll_exists(c_assignment_action_id NUMBER
                                      ,c_start_date           DATE
                                      ,c_end_date             DATE)IS
    SELECT 'DP' FROM dual
    WHERE  EXISTS (SELECT 1
                   FROM   pay_assignment_actions paa1
                         ,pay_assignment_actions paa2
                         ,pay_payroll_actions ppa
                   WHERE  paa1.assignment_action_id = c_assignment_action_id
                   AND    paa2.assignment_id = paa1.assignment_id
                   AND    paa1.tax_unit_id = paa2.tax_unit_id
                   AND    ppa.action_type IN ('Q','R')
                   AND    ppa.action_status = 'C'
                   AND    ppa.payroll_action_id = paa2.payroll_action_id
                   AND    ppa.effective_date    < TRUNC(c_start_date,'Q'));
    --
    CURSOR csr_prev_lqtd_payroll_exists(c_assignment_action_id NUMBER
                                       ,c_start_date           DATE
                                       ,c_end_date             DATE)IS
    SELECT 'DP' FROM dual
    WHERE  EXISTS (SELECT 1
                   FROM   pay_assignment_actions paa1
                         ,pay_assignment_actions paa2
                         ,pay_payroll_actions ppa
                   WHERE  paa1.assignment_action_id = c_assignment_action_id
                   AND    paa2.assignment_id = paa1.assignment_id
                   AND    paa1.tax_unit_id = paa2.tax_unit_id
                   AND    ppa.action_type IN ('Q','R')
                   AND    ppa.action_status = 'C'
                   AND    ppa.payroll_action_id = paa2.payroll_action_id
                   AND    ppa.effective_date < c_start_date
                   AND    DECODE(trunc((to_number(to_char(ppa.effective_date,'IW'))-1)/12),4,3,trunc((to_number(to_char(ppa.effective_date,'IW'))-1)/12)) <>
                            DECODE(trunc((to_number(to_char(c_start_date,'IW'))-1)/12),4,3,trunc((to_number(to_char(c_start_date,'IW'))-1)/12)));
    --
    CURSOR csr_diff_de_dp_qtd(c_payroll_action_id       NUMBER
                             ,c_assignment_action_id    NUMBER
                             ,c_start_date              DATE
                             ,c_end_date                DATE)IS
    SELECT 'DE' FROM dual
    WHERE EXISTS (SELECT 1
                  FROM   pay_assignment_actions paa1
                        ,pay_assignment_actions paa2
                        ,pay_payroll_actions ppa1
                        ,pay_payroll_actions ppa2
                  WHERE  ppa1.payroll_action_id = c_payroll_action_id
                  AND    ppa1.payroll_action_id = paa1.payroll_action_id
                  AND    paa1.assignment_action_id = c_assignment_action_id
                  AND    paa1.assignment_id = paa2.assignment_id
                  AND    paa1.tax_unit_id = paa2.tax_unit_id
                  AND    ppa2.payroll_action_id = paa2.payroll_action_id
                  AND    ppa2.action_type IN ('Q','R')
                  AND    ppa2.action_status in ('C','P')
                  AND    TRUNC(ppa2.date_earned,'Q') <> TRUNC(c_start_date,'Q')
                  AND    TRUNC(ppa2.effective_date,'Q')  = TRUNC(c_start_date,'Q'));
    --
    CURSOR csr_diff_de_dp_lqtd(c_payroll_action_id      NUMBER
                              ,c_assignment_action_id   NUMBER
                              ,c_start_date             DATE
                              ,c_end_date               DATE)IS
    SELECT 'DE' FROM dual
    WHERE EXISTS (SELECT 1
                  FROM   pay_assignment_actions paa1
                        ,pay_assignment_actions paa2
                        ,pay_payroll_actions ppa1
                        ,pay_payroll_actions ppa2
                  WHERE  ppa1.payroll_action_id = c_payroll_action_id
                  AND    ppa1.payroll_action_id = paa1.payroll_action_id
                  AND    paa1.assignment_action_id = c_assignment_action_id
                  AND    paa1.assignment_id = paa2.assignment_id
                  AND    paa1.tax_unit_id = paa2.tax_unit_id
                  AND    ppa2.payroll_action_id = paa2.payroll_action_id
                  AND    ppa2.action_type IN ('Q','R')
                  AND    ppa2.action_status in ('C','P')
                  AND    DECODE(trunc((to_number(to_char(ppa2.date_earned,'IW'))-1)/12),4,3,trunc((to_number(to_char(ppa2.date_earned,'IW'))-1)/12)) <>
                            DECODE(trunc((to_number(to_char(c_start_date,'IW'))-1)/12),4,3,trunc((to_number(to_char(c_start_date,'IW'))-1)/12))
                  AND    DECODE(trunc((to_number(to_char(ppa2.effective_date,'IW'))-1)/12),4,3,trunc((to_number(to_char(ppa2.effective_date,'IW'))-1)/12)) =
                            DECODE(trunc((to_number(to_char(c_start_date,'IW'))-1)/12),4,3,trunc((to_number(to_char(c_start_date,'IW'))-1)/12)) );
	*/
    --
    CURSOR c1 (c_payroll_action_id NUMBER)IS
    SELECT ptp.start_date
          ,ptp.end_date
          ,ppa.date_earned
          ,business_group_id
    FROM   pay_payroll_actions ppa
          ,per_time_periods ptp
    WHERE  ppa.payroll_action_id = c_payroll_action_id
    AND    ptp.time_period_id = ppa.time_period_id;
    --
    CURSOR csr_chk_pog_exist(c_assignment_id  NUMBER
                            ,c_start_date     DATE
                            ,c_end_date       DATE) IS
    SELECT '1' FROM DUAL
    WHERE  EXISTS (SELECT 1
                   FROM   pay_object_groups pog1
                         ,pay_object_groups pog2
                   WHERE  pog1.source_id = c_assignment_id
                   AND    pog1.source_type = pog2.source_type
                   AND    pog1.source_type = 'PAF'
                   AND    pog1.parent_object_group_id = pog2.parent_object_group_id
                   AND    (pog1.start_date <= c_end_date AND pog1.end_date >= c_start_date)
                   AND    (pog2.start_date <= c_end_date AND pog2.end_date >= c_start_date));
    --
    CURSOR csr_get_late_starter_flag(c_business_group_id NUMBER) IS
    SELECT org_information7
    FROM   hr_organization_information
    WHERE  organization_id = c_business_group_id
    AND    org_information_context = 'NL_BG_INFO';
    --
    CURSOR csr_chk_element_entry(c_ass_id   NUMBER
                                ,c_eff_date DATE) IS
    SELECT 'Y'
    FROM   dual
    WHERE  exists (SELECT 1
                   FROM   pay_element_entries_f peef
                         ,pay_element_types_f petf
                   WHERE  peef.assignment_id         = c_ass_id
                   AND    peef.element_type_id       = petf.element_type_id
                   AND    petf.element_name          = 'Late Hire Indicator'
                   AND    c_eff_date BETWEEN peef.effective_start_date AND peef.effective_end_date
                   AND    c_eff_date BETWEEN petf.effective_start_date AND petf.effective_end_date);
    --
    l_qtd_result VARCHAR2(5);
    l_start_date DATE;
    l_end_date DATE;
    l_parent_id NUMBER;
    l_chk VARCHAR2(1);
    l_date_earned DATE;
    l_bg_id NUMBER;
    l_late_hire_indicator VARCHAR2(10);
    l_entry_exist VARCHAR2(1);
    --
BEGIN
    --
    HR_UTILITY.TRACE('~~ Assignment_id :'||p_ass_id);
    IF g_late_hire_indicator = 'N' THEN
      HR_UTILITY.TRACE('~~ 1 QResult : DP');
      RETURN 'DP';
    END IF;
    --
    OPEN  C1(p_pay_act_id);
    FETCH C1 INTO l_start_date,l_end_date,l_date_earned,l_bg_id;
    CLOSE C1;
    --
    IF NVL(g_late_hire_indicator,'X') = 'X' THEN
      OPEN  csr_get_late_starter_flag(l_bg_id);
      FETCH csr_get_late_starter_flag INTO l_late_hire_indicator;
      CLOSE csr_get_late_starter_flag;
      --
      g_late_hire_indicator := NVL(l_late_hire_indicator,'Y');
      IF g_late_hire_indicator = 'N' THEN
        HR_UTILITY.TRACE('~~ 2  QResult : DP');
        RETURN 'DP';
      END IF;
    END IF;
    --
    OPEN  csr_chk_pog_exist(p_ass_id,l_start_date,l_end_date); -- not req after BG check
    FETCH csr_chk_pog_exist INTO l_chk;
      IF csr_chk_pog_exist%NOTFOUND THEN
        g_qtd_result := 'DP';
        CLOSE csr_chk_pog_exist;
        RETURN g_qtd_result;
      END IF;
    CLOSE csr_chk_pog_exist;
    --
    l_qtd_result  := NULL;
    --
    IF g_qtd_result IS NOT NULL AND g_period_type = p_type
       AND NVL(g_assignment_id,-1) = p_ass_id AND NVL(g_payroll_action_id,-1) = p_pay_act_id  THEN
        HR_UTILITY.TRACE('~~ 3 QResult : '||g_qtd_result);
        return g_qtd_result;
    END IF;
    --
    OPEN  csr_chk_element_entry(p_ass_id,l_date_earned);
    FETCH csr_chk_element_entry INTO l_entry_exist;
    CLOSE csr_chk_element_entry;
    --
    IF NVL(l_entry_exist,'N') = 'Y' THEN
      g_payroll_action_id := p_pay_act_id;
      g_assignment_id     := p_ass_id;
      g_period_type       := p_type;
      g_qtd_result        := 'DE';
      HR_UTILITY.TRACE('~~ 4 QResult : '||g_qtd_result);
      RETURN g_qtd_result;
    END IF;
    --
    /*
    IF p_type = 'QTD' THEN
        --
        OPEN  csr_prev_qtd_payroll_exists(p_ass_act_id,l_start_date,l_end_date);
        FETCH csr_prev_qtd_payroll_exists INTO l_qtd_result;
        CLOSE csr_prev_qtd_payroll_exists;
        --
        IF l_qtd_result IS NULL THEN
            OPEN csr_diff_de_dp_qtd(p_pay_act_id,p_ass_act_id,l_start_date,l_end_date);
            FETCH csr_diff_de_dp_qtd INTO l_qtd_result;
            IF csr_diff_de_dp_qtd%FOUND THEN
                g_qtd_result  := l_qtd_result;
                CLOSE csr_diff_de_dp_qtd;
                HR_UTILITY.TRACE('~~ 5 QResult : '||g_qtd_result);
                RETURN g_qtd_result;
            END IF;
            CLOSE csr_diff_de_dp_qtd;
        END IF;
        --
    ELSE
        OPEN  csr_prev_lqtd_payroll_exists(p_ass_act_id,l_start_date,l_end_date);
        FETCH csr_prev_lqtd_payroll_exists INTO l_qtd_result;
        CLOSE csr_prev_lqtd_payroll_exists;
        --
        IF l_qtd_result IS NULL THEN
            OPEN csr_diff_de_dp_lqtd(p_pay_act_id,p_ass_act_id,l_start_date,l_end_date);
            FETCH csr_diff_de_dp_lqtd INTO l_qtd_result;
            IF csr_diff_de_dp_lqtd%FOUND THEN
                g_qtd_result := l_qtd_result;
                CLOSE csr_diff_de_dp_lqtd;
                HR_UTILITY.TRACE('~~ 6 QResult : '||g_qtd_result);
                RETURN g_qtd_result;
            END IF;
            CLOSE csr_diff_de_dp_lqtd;
        END IF;
    END IF;*/
    --
    g_payroll_action_id := p_pay_act_id;
    g_assignment_id     := p_ass_id;
    g_period_type       := p_type;
    g_qtd_result        := NVL(l_qtd_result,'DP');
    --
    HR_UTILITY.TRACE('~~ 7 QResult : '||g_qtd_result);
    RETURN g_qtd_result;
    --
END check_de_dp_dimension_qtd;
--
/*
FUNCTION check_de_dp_dimension_qtd(p_pay_act_id  NUMBER
                                  ,p_ass_id      NUMBER
                                  ,p_ass_act_id  NUMBER
                                  ,p_type        VARCHAR2) RETURN VARCHAR2 IS
    --
    CURSOR csr_prev_qtd_payroll_exists(c_assignment_action_id NUMBER
                                      ,c_start_date           DATE
                                      ,c_end_date             DATE)IS
    SELECT 'DP' FROM dual
    WHERE  EXISTS (SELECT 1
                   FROM   pay_assignment_actions paa1
                         ,pay_assignment_actions paa2
                         ,pay_payroll_actions ppa
                   WHERE  paa1.assignment_action_id = c_assignment_action_id
                   AND    paa2.assignment_id = paa1.assignment_id
                   AND    paa1.tax_unit_id = paa2.tax_unit_id
                   AND    ppa.action_type IN ('Q','R')
                   AND    ppa.action_status = 'C'
                   AND    ppa.payroll_action_id = paa2.payroll_action_id
                   AND    ppa.effective_date    < TRUNC(c_start_date,'Q'));
    --
    CURSOR csr_prev_lqtd_payroll_exists(c_assignment_action_id NUMBER
                                       ,c_start_date           DATE
                                       ,c_end_date             DATE)IS
    SELECT 'DP' FROM dual
    WHERE  EXISTS (SELECT 1
                   FROM   pay_assignment_actions paa1
                         ,pay_assignment_actions paa2
                         ,pay_payroll_actions ppa
                   WHERE  paa1.assignment_action_id = c_assignment_action_id
                   AND    paa2.assignment_id = paa1.assignment_id
                   AND    paa1.tax_unit_id = paa2.tax_unit_id
                   AND    ppa.action_type IN ('Q','R')
                   AND    ppa.action_status = 'C'
                   AND    ppa.payroll_action_id = paa2.payroll_action_id
                   AND    ppa.effective_date < c_start_date
                   AND    DECODE(trunc((to_number(to_char(ppa.effective_date,'IW'))-1)/12),4,3,trunc((to_number(to_char(ppa.effective_date,'IW'))-1)/12)) <>
                            DECODE(trunc((to_number(to_char(c_start_date,'IW'))-1)/12),4,3,trunc((to_number(to_char(c_start_date,'IW'))-1)/12)));
    --
    CURSOR csr_diff_de_dp_qtd(c_payroll_action_id       NUMBER
                             ,c_assignment_action_id    NUMBER
                             ,c_start_date              DATE
                             ,c_end_date                DATE)IS
    SELECT 'DE' FROM dual
    WHERE EXISTS (SELECT 1
                  FROM   pay_assignment_actions paa1
                        ,pay_assignment_actions paa2
                        ,pay_payroll_actions ppa1
                        ,pay_payroll_actions ppa2
                  WHERE  ppa1.payroll_action_id = c_payroll_action_id
                  AND    ppa1.payroll_action_id = paa1.payroll_action_id
                  AND    paa1.assignment_action_id = c_assignment_action_id
                  AND    paa1.assignment_id = paa2.assignment_id
                  AND    paa1.tax_unit_id = paa2.tax_unit_id
                  AND    ppa2.payroll_action_id = paa2.payroll_action_id
                  AND    ppa2.action_type IN ('Q','R')
                  AND    ppa2.action_status in ('C','P')
                  AND    TRUNC(ppa2.date_earned,'Q') <> TRUNC(c_start_date,'Q')
                  AND    TRUNC(ppa2.effective_date,'Q')  = TRUNC(c_start_date,'Q'));
    --
    CURSOR csr_diff_de_dp_lqtd(c_payroll_action_id      NUMBER
                              ,c_assignment_action_id   NUMBER
                              ,c_start_date             DATE
                              ,c_end_date               DATE)IS
    SELECT 'DE' FROM dual
    WHERE EXISTS (SELECT 1
                  FROM   pay_assignment_actions paa1
                        ,pay_assignment_actions paa2
                        ,pay_payroll_actions ppa1
                        ,pay_payroll_actions ppa2
                  WHERE  ppa1.payroll_action_id = c_payroll_action_id
                  AND    ppa1.payroll_action_id = paa1.payroll_action_id
                  AND    paa1.assignment_action_id = c_assignment_action_id
                  AND    paa1.assignment_id = paa2.assignment_id
                  AND    paa1.tax_unit_id = paa2.tax_unit_id
                  AND    ppa2.payroll_action_id = paa2.payroll_action_id
                  AND    ppa2.action_type IN ('Q','R')
                  AND    ppa2.action_status in ('C','P')
                  AND    DECODE(trunc((to_number(to_char(ppa2.date_earned,'IW'))-1)/12),4,3,trunc((to_number(to_char(ppa2.date_earned,'IW'))-1)/12)) <>
                            DECODE(trunc((to_number(to_char(c_start_date,'IW'))-1)/12),4,3,trunc((to_number(to_char(c_start_date,'IW'))-1)/12))
                  AND    DECODE(trunc((to_number(to_char(ppa2.effective_date,'IW'))-1)/12),4,3,trunc((to_number(to_char(ppa2.effective_date,'IW'))-1)/12)) =
                            DECODE(trunc((to_number(to_char(c_start_date,'IW'))-1)/12),4,3,trunc((to_number(to_char(c_start_date,'IW'))-1)/12)) );
    --
    CURSOR c1 (c_payroll_action_id NUMBER)IS
    SELECT ptp.start_date
          ,ptp.end_date
          ,ppa.date_earned
          ,business_group_id
    FROM   pay_payroll_actions ppa
          ,per_time_periods ptp
    WHERE  ppa.payroll_action_id = c_payroll_action_id
    AND    ptp.time_period_id = ppa.time_period_id;
    --
    CURSOR csr_chk_pog_exist(c_assignment_id  NUMBER
                            ,c_start_date     DATE
                            ,c_end_date       DATE) IS
    SELECT '1' FROM DUAL
    WHERE  EXISTS (SELECT 1
                   FROM   pay_object_groups pog1
                         ,pay_object_groups pog2
                   WHERE  pog1.source_id = c_assignment_id
                   AND    pog1.source_type = pog2.source_type
                   AND    pog1.source_type = 'PAF'
                   AND    pog1.parent_object_group_id = pog2.parent_object_group_id
                   AND    (pog1.start_date <= c_end_date AND pog1.end_date >= c_start_date)
                   AND    (pog2.start_date <= c_end_date AND pog2.end_date >= c_start_date));
    --
    CURSOR csr_get_late_starter_flag(c_business_group_id NUMBER) IS
    SELECT org_information7
    FROM   hr_organization_information
    WHERE  organization_id = c_business_group_id
    AND    org_information_context = 'NL_BG_INFO';
    --
    CURSOR csr_chk_element_entry(c_ass_id   NUMBER
                                ,c_eff_date DATE) IS
    SELECT 'Y'
    FROM   dual
    WHERE  exists (SELECT 1
                   FROM   pay_element_entries_f peef
                         ,pay_element_types_f petf
                   WHERE  peef.assignment_id         = c_ass_id
                   AND    peef.element_type_id       = petf.element_type_id
                   AND    petf.element_name          = 'Late Hire Indicator'
                   AND    c_eff_date BETWEEN peef.effective_start_date AND peef.effective_end_date
                   AND    c_eff_date BETWEEN petf.effective_start_date AND petf.effective_end_date);
    --
    l_qtd_result VARCHAR2(5);
    l_start_date DATE;
    l_end_date DATE;
    l_parent_id NUMBER;
    l_chk VARCHAR2(1);
    l_date_earned DATE;
    l_bg_id NUMBER;
    l_late_hire_indicator VARCHAR2(10);
    l_entry_exist VARCHAR2(1);
    --
BEGIN
    --
    HR_UTILITY.TRACE('~~ Assignment_id :'||p_ass_id);
    IF g_late_hire_indicator = 'N' THEN
      HR_UTILITY.TRACE('~~ 1 QResult : DP');
      RETURN 'DP';
    END IF;
    --
    OPEN  C1(p_pay_act_id);
    FETCH C1 INTO l_start_date,l_end_date,l_date_earned,l_bg_id;
    CLOSE C1;
    --
    IF NVL(g_late_hire_indicator,'X') = 'X' THEN
      OPEN  csr_get_late_starter_flag(l_bg_id);
      FETCH csr_get_late_starter_flag INTO l_late_hire_indicator;
      CLOSE csr_get_late_starter_flag;
      --
      g_late_hire_indicator := NVL(l_late_hire_indicator,'Y');
      IF g_late_hire_indicator = 'N' THEN
        HR_UTILITY.TRACE('~~ 2  QResult : DP');
        RETURN 'DP';
      END IF;
    END IF;
    --
    OPEN  csr_chk_pog_exist(p_ass_id,l_start_date,l_end_date); -- not req after BG check
    FETCH csr_chk_pog_exist INTO l_chk;
      IF csr_chk_pog_exist%NOTFOUND THEN
        g_qtd_result := 'DP';
        CLOSE csr_chk_pog_exist;
        RETURN g_qtd_result;
      END IF;
    CLOSE csr_chk_pog_exist;
    --
    l_qtd_result  := NULL;
    --
    IF g_qtd_result IS NOT NULL AND g_period_type = p_type
       AND NVL(g_assignment_id,-1) = p_ass_id AND NVL(g_payroll_action_id,-1) = p_pay_act_id  THEN
        HR_UTILITY.TRACE('~~ 3 QResult : '||g_qtd_result);
        return g_qtd_result;
    END IF;
    --
    OPEN  csr_chk_element_entry(p_ass_id,l_date_earned);
    FETCH csr_chk_element_entry INTO l_entry_exist;
    CLOSE csr_chk_element_entry;
    --
    IF NVL(l_entry_exist,'N') = 'Y' THEN
      g_payroll_action_id := p_pay_act_id;
      g_assignment_id     := p_ass_id;
      g_period_type       := p_type;
      g_qtd_result        := 'DE';
      HR_UTILITY.TRACE('~~ 4 QResult : '||g_qtd_result);
      RETURN g_qtd_result;
    END IF;
    --
    IF p_type = 'QTD' THEN
        --
        OPEN  csr_prev_qtd_payroll_exists(p_ass_act_id,l_start_date,l_end_date);
        FETCH csr_prev_qtd_payroll_exists INTO l_qtd_result;
        CLOSE csr_prev_qtd_payroll_exists;
        --
        IF l_qtd_result IS NULL THEN
            OPEN csr_diff_de_dp_qtd(p_pay_act_id,p_ass_act_id,l_start_date,l_end_date);
            FETCH csr_diff_de_dp_qtd INTO l_qtd_result;
            IF csr_diff_de_dp_qtd%FOUND THEN
                g_qtd_result  := l_qtd_result;
                CLOSE csr_diff_de_dp_qtd;
                HR_UTILITY.TRACE('~~ 5 QResult : '||g_qtd_result);
                RETURN g_qtd_result;
            END IF;
            CLOSE csr_diff_de_dp_qtd;
        END IF;
        --
    ELSE
        OPEN  csr_prev_lqtd_payroll_exists(p_ass_act_id,l_start_date,l_end_date);
        FETCH csr_prev_lqtd_payroll_exists INTO l_qtd_result;
        CLOSE csr_prev_lqtd_payroll_exists;
        --
        IF l_qtd_result IS NULL THEN
            OPEN csr_diff_de_dp_lqtd(p_pay_act_id,p_ass_act_id,l_start_date,l_end_date);
            FETCH csr_diff_de_dp_lqtd INTO l_qtd_result;
            IF csr_diff_de_dp_lqtd%FOUND THEN
                g_qtd_result := l_qtd_result;
                CLOSE csr_diff_de_dp_lqtd;
                HR_UTILITY.TRACE('~~ 6 QResult : '||g_qtd_result);
                RETURN g_qtd_result;
            END IF;
            CLOSE csr_diff_de_dp_lqtd;
        END IF;
    END IF;
    --
    g_payroll_action_id := p_pay_act_id;
    g_assignment_id     := p_ass_id;
    g_period_type       := p_type;
    g_qtd_result        := NVL(l_qtd_result,'DP');
    --
    HR_UTILITY.TRACE('~~ 7 QResult : '||g_qtd_result);
    RETURN g_qtd_result;
    --
END check_de_dp_dimension_qtd;*/
--
END PAY_NL_GENERAL;

/
