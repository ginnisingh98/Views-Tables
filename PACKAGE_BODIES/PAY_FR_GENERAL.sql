--------------------------------------------------------
--  DDL for Package Body PAY_FR_GENERAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FR_GENERAL" as
/* $Header: pyfrgenr.pkb 120.0 2005/05/29 05:02:49 appldev noship $ */
--
g_package varchar2(30) := 'pay_fr_general';

g_summary_deductions     t_summary_deductions;
g_summary_idx number := 0;

g_deduction_rates        t_deduction_rates;

-- Added 115.15. Used to store previous run in period assignment action ID and Action Date.
-- These are set by the procedure set_prior_asg_action
g_prior_asg_action_id      number;
g_prior_pay_action_date    date;

-- global with which to cache (grand) parent asg action from within
-- initialize_payroll function.  Added to support proration w/ run types.
g_parent_asg_action_id  number;

-- +********************************************************************+
-- |                        PRIVATE FUNCTIONS                           |
-- +********************************************************************+
--
--
------------------------------------------------------------------------
-- Function GET_TABLE_INDEX
-- This function will return a unique index for a given base/band name or
-- base code name.  The function uses a standard call to
-- DBMS_UTILITY.get_hash_value this is similar to the call used in hr_bis.pkb
-- to calculate lookup cache value indexes.
--
-- This will used by the function WRITE_BASE_BANDS to calculate the PL/SQL
-- table index when populating it with the base and band values.
-- This function will also be called from the BASE_CODE functions to obtain
-- a index to store each base code in a unique PL/SQL table index.
------------------------------------------------------------------------
function get_table_index(p_input_name varchar2) return number is
--
l_hash_number number;
--
--
begin
--
  l_hash_number  :=
      DBMS_UTILITY.get_hash_value(
        p_input_name,
        1,
        1048576);
                                                    -- (2^20)
  return l_hash_number;

end get_table_index;

------------------------------------------------------------------------
-- Procedure SET_PRIOR_ASG_ACTION
------------------------------------------------------------------------
procedure set_prior_asg_action(p_date_earned     in date
                            ,p_assignment_id     in number
                            ,p_business_group_id in number
                            ,p_tax_unit_id       in number
                            ,p_orig_entry_id     in number
                            )
IS

   l_asg_action_id     number;
   l_pay_action_date   date;
   l_proc varchar2(72) := g_package||'.get_prior_asg_action';

   /* This cursor gets any other assignment action where:
      1) For the current Business Group
      2) The payroll action was complete or incomplete, and the type was Payroll Run or QuickPay.
      3) The payroll run date is in this period
      4) For the current Assignment ID
      5) For the same establishment (Tax_Unit_ID)
      6) the assignment action was complete
      7) Where the run contained 'FR_STATUTORY_DEDUCTIONS' element               */


   cursor pay_asg_act_csr is
      select  paa.assignment_action_id, ppa.effective_date
        from pay_payroll_actions    ppa
           , pay_assignment_actions paa
           , pay_run_results        prr
        where ppa.business_group_id = p_business_group_id
          and ppa.action_type in ('Q','R')
          and ppa.action_status in ('C','I')
          and ppa.effective_date between trunc(p_date_earned,'MONTH')
                and last_day(p_date_earned)
          and ppa.payroll_action_id = paa.payroll_action_id
          and paa.assignment_id = p_assignment_id
          and paa.action_status = 'C'
          and paa.tax_unit_id   = p_tax_unit_id
          and paa.assignment_action_id = prr.assignment_action_id
          and prr.source_id     = p_orig_entry_id
          and prr.source_type   = 'E';
   --
begin
   --
   hr_utility.set_location('Entered '||l_proc,5);
   hr_utility.set_location('.  Asg_ID:'||p_assignment_id||'. BG_ID:'||p_business_group_id||'. Date:'||p_date_earned,20);

   open pay_asg_act_csr;
   fetch pay_asg_act_csr into l_asg_action_id, l_pay_action_date;

   if pay_asg_act_csr%notfound then
      hr_utility.set_location('Could not find Previous payroll run this period',40);

      close pay_asg_act_csr;
      g_prior_asg_action_id := -1;
      g_prior_pay_action_date := NULL;

   else
      hr_utility.set_location('Found previous payroll run this period',60);

      close pay_asg_act_csr;
      g_prior_asg_action_id := l_asg_action_id;
      g_prior_pay_action_date := l_pay_action_date;

   end if;

end set_prior_asg_action;



function get_prior_run_result(p_element_name     in varchar2
                            ,p_input_value_name  in varchar2
                            ,p_date_earned       in date
                            ,p_assignment_id     in number
                            ,p_business_group_id in number
                            ) return varchar2
IS

   l_asg_action_id       number;
   l_pay_action_date     date;
   l_run_result_value    varchar2(60);
   l_proc varchar2(72) := g_package||'.get_prior_run_result';


   cursor pay_run_result_csr is
      select prrv.result_value
        from pay_run_results prr
           , pay_element_types_f pet
           , pay_input_values_f piv
           , pay_run_result_values prrv
        where prr.assignment_action_id = g_prior_asg_action_id
          and prr.element_type_id = pet.element_type_id
          and pet.ELEMENT_NAME = p_element_name
          and pet.legislation_code = 'FR'
          and pet.business_group_id is NULL
          and g_prior_pay_action_date between pet.effective_start_date and pet.effective_end_date
          and pet.element_type_id = piv.element_type_id
          and g_prior_pay_action_date between piv.effective_start_date and piv.effective_end_date
          and piv.name = p_input_value_name
          and piv.legislation_code = 'FR'
          and piv.business_group_id is NULL
          and prrv.input_value_id = piv.input_value_id
          and prrv.run_result_id = prr.run_result_id;
   --
begin
   --
   hr_utility.set_location('Entered '||l_proc,5);
   hr_utility.set_location('. Element='||p_element_name||'. IV='||p_input_value_name,20);

   if g_prior_asg_action_id <> -1 THEN
      /* Assignment Action was found in initalize_payroll function.
         Run cursor to get record using assignment action stored in global */
      open pay_run_result_csr;
      fetch pay_run_result_csr into l_run_result_value;

      if pay_run_result_csr%found then
         hr_utility.set_location('. Found run result value='||l_run_result_value,40);

         close pay_run_result_csr;
         return l_run_result_value;
      else
         hr_utility.set_location('. Run Result Not found',60);
         close pay_run_result_csr;
         l_run_result_value:= NULL;
      end if;
   else /* no prior runs were found this period */
      l_run_result_value := NULL;
   end if;

   return l_run_result_value;

end get_prior_run_result;


------------------------------------------------------------------------
-- Function GET_PRIOR_BASE_CODE
-- This function will be used to obtain the base code for a given
-- contribution type should a payroll action already exist this period.
------------------------------------------------------------------------
function get_prior_base_code(p_base_element in varchar2
                            ,p_date_earned       in date
                            ,p_assignment_id     in number
                            ,p_business_group_id in number) return varchar2
IS

   l_base_code_val     varchar2(10);
   l_proc varchar2(72) := g_package||'.get_prior_base_code';

   --
begin
   --
   hr_utility.set_location('Entered '||l_proc,5);
   hr_utility.set_location('.  Finding base code for element:'||p_base_element,20);

   l_base_code_val := get_prior_run_result(p_element_name => p_base_element
                            ,p_input_value_name  => 'Base_Code'
                            ,p_date_earned       => p_date_earned
                            ,p_assignment_id     => p_assignment_id
                            ,p_business_group_id => p_business_group_id);

   return l_base_code_val;

end get_prior_base_code;

------------------------------------------------------------------------
-- Function GET_BASE_NAME
-- This function will be used to determine the name of a base
-- as an input it takes a group code which is used to determine the correct base.
-- renamed to old as the seed data currently supports this method but
-- core functionality prives primary and base balance relationships
------------------------------------------------------------------------
function get_base_name(p_business_group_id in number
                      ,p_group_code        in varchar2)
                                return varchar2
is
   l_base_type     pay_user_Column_instances_f.value%type;
   l_proc varchar2(72) := g_package||'.get_base_name';
   --
begin
   --
   hr_utility.set_location('Entered '||l_proc,5);

   l_base_type := hruserdt.get_table_value(p_bus_group_id => p_business_group_id
                           ,p_table_name => 'FR_DEDUCTION_GROUPS'
                           ,p_col_name=> 'Base Balance'
                           ,p_row_value   => p_group_code);

   hr_utility.set_location('.  Base Type:'||l_base_type,20);

   return l_base_type;

   exception
      when no_data_found then
         fnd_message.set_name('PAY','PAY_74938_SD_NO_BASE_DUCT_GRP');
         fnd_message.set_token('DEDUCTION_GROUP',p_group_code);
         fnd_message.raise_error;
end get_base_name;
------------------------------------------------------------------------
-- Function GET_BASE_NAME_CU
-- This function will be used to determine the name of a base
-- type from a contribution_Usage_ID row.
------------------------------------------------------------------------
function get_base_name_CU (
                            p_business_group_id in number
                           ,p_cu_id            in number)
return varchar2
is

   l_base_type     pay_user_Column_instances_f.value%type;
   l_group_code    pay_fr_contribution_usages.group_code%TYPE;
   l_proc varchar2(72) := g_package||'.get_base_name_cu';
   --
begin
   --
   hr_utility.set_location('Entered '||l_proc,5);
   --
   l_group_code := get_group_code(p_cu_id);
   --
   l_base_type := hruserdt.get_table_value(p_bus_group_id => p_business_group_id
                           ,p_table_name => 'FR_DEDUCTION_GROUPS'
                           ,p_col_name=> 'Base Balance'
                           ,p_row_value   => l_group_code);

   hr_utility.set_location('.  Base Type:'||l_base_type,20);
   hr_utility.set_location('Leaving '||l_proc,25);
   return l_base_type;
   exception
      when no_data_found then
         fnd_message.set_name('PAY','PAY_74938_SD_NO_BASE_DUCT_GRP');
         fnd_message.set_token('DEDUCTION_GROUP',l_group_code);
         fnd_message.raise_error;
end get_base_name_CU;
------------------------------------------------------------------------
-- Function GET_GROUP_CODE
-- This function will be used to determine the group code of a given
-- row in pay_fr_contribution_usages
------------------------------------------------------------------------
function get_group_code (p_cu_id             in number)
         return varchar2
   is
   l_group_code    pay_fr_contribution_usages.group_code%TYPE;
   l_proc varchar2(72) := g_package||'.get_group_code';
   --
begin
   --
   hr_utility.set_location('Entered '||l_proc,5);
   select group_code
   into l_group_code
   from pay_fr_contribution_usages
   where contribution_usage_id = p_cu_id;
   --
   hr_utility.set_location('.  Group Code:'||l_group_code,20);
   hr_utility.set_location('Leaving '||l_proc,25);
   return l_group_code;
   exception
      when no_data_found then null; /* calling fn handles error */
end get_group_code;
------------------------------------------------------------------------
-- Function GET_BASE_VALUE
-- This function will be used to determine the value of a base
-- as an input it takes a base_type
------------------------------------------------------------------------
function get_base_value(p_base_type        in varchar2)
 				return number
is
   l_base_value    number;
   l_proc varchar2(72) := g_package||'.get_base_value';
   --
begin
   --
   hr_utility.set_location('Entered '||l_proc,5);

   hr_utility.set_location('Base Type='||p_base_type,10);

   l_base_value := g_band_table(get_table_index(p_base_type));

   hr_utility.set_location('leaving: '||l_proc||' Value='||l_base_value,30);

   return l_base_value;
   exception
      when no_data_found then
         fnd_message.set_name('PAY','PAY_74937_SD_NO_BASE_VALUE');
         fnd_message.set_token('TYPE',p_base_type);
         fnd_message.raise_error;

end get_base_value;

------------------------------------------------------------------------
-- Private Function GET_RATE_VALUE
-- This function will be used to determine the value of a rate
-- as an input it takes the rate type to determine the correct rate value.
------------------------------------------------------------------------
function get_rate_value(p_business_group_id in number
                       ,p_rate_type         in varchar2)
				return number
is
   l_rate_value number;
   l_proc varchar2(72) := g_package||'.get_rate_value';
   --
begin
   --
   hr_utility.set_location('Entered '||l_proc,5);
   hr_utility.set_location('.   Rate Type='||p_rate_type,10);

   l_rate_value := to_number(hruserdt.get_table_value(p_bus_group_id => p_business_group_id
                           ,p_table_name => 'FR_CONTRIBUTION_RATES'
			   ,p_col_name=> 'Value (EUR)'
			   ,p_row_value   => p_rate_type));

   hr_utility.set_location('Leaving: '||l_proc||'. Rate='||l_rate_value,40);

   return l_rate_value;
   exception
      when no_data_found then
         fnd_message.set_name('PAY','PAY_74935_SD_NO_RATE');
         fnd_message.set_token('RATE_TYPE',p_rate_type);
         fnd_message.raise_error;
end get_rate_value;


-- +********************************************************************+
-- |                        PUBLIC FUNCTIONS                            |
-- +********************************************************************+
--
------------------------------------------------------------------------
-- Function GET_CONTRIBUTION_USAGE
-- This function obtains a row from the pay_fr_contribution_usages table
-- It will be called from other cover functions.
------------------------------------------------------------------------
function get_contribution_usage
			(p_process_type in varchar2
			,p_element_name in varchar2
			,p_usage_type	in varchar2
                       ,p_effective_date in date
                       ,p_business_group_id in number default null)
                               return pay_fr_contribution_usages%rowtype
is

  l_contribution_row pay_fr_contribution_usages%rowtype;

   cursor contribution_usages_csr is
	select *
	from pay_fr_contribution_usages cu
	where cu.process_type = p_process_type
        and  cu.contribution_usage_type = p_usage_type
        and  p_effective_date between cu.date_from and nvl(cu.date_to,to_date('31-12-4712','DD-MM-YYYY'))
        and cu.element_name = p_element_name
        and (cu.business_group_id is NULL or cu.business_group_id = p_business_group_id);


begin
   hr_utility.set_location('Entered pay_fr_general.get_contribution_usage',10);
   hr_utility.set_location('Obtaining row, Element='||p_element_name, 11);
   hr_utility.set_location('.       p_process_type='||p_process_type,12);
   hr_utility.set_location('.         p_usage_type='||p_usage_type,13);

   OPEN contribution_usages_csr;
   FETCH contribution_usages_csr INTO l_contribution_row;

   if contribution_usages_csr%notfound then
      CLOSE contribution_usages_csr;
      raise no_data_found;
   ELSE
      close contribution_usages_csr;
   end if;

   hr_utility.set_location('Leaving get_contribution_usage, ID:'||l_contribution_row.contribution_usage_id,100);
   return l_contribution_row;

exception
   when no_data_found then
   begin
      hr_utility.set_location('ERROR: Contribution Usage missing for:'||p_element_name,100);
      hr_utility.set_location('.      Process Type:'||p_process_type||', Usage:'||p_usage_type,110);
      fnd_message.set_name('PAY','PAY_74918_SD_NO_CNU_DATA');
      fnd_message.set_token('ET',p_element_name);
      fnd_message.set_token('PT',p_process_type);
      fnd_message.set_token('UT',p_usage_type);
      fnd_message.raise_error;
   end;
end get_contribution_usage;

------------------------------------------------------------------------
-- Private Function GET_RATE_VALUE
-- This function will be used to determine the value of a rate
-- as an input it takes the same inputs as the get_contribution_usage
-- to determine ONLY the correct rate value.
------------------------------------------------------------------------
function get_rate_value(p_assignment_id in number
 			,p_business_group_id in number default null
                        ,p_date_earned in date
                        ,p_tax_unit_id in number
			,p_element_name in varchar2
			,p_usage_type	in varchar2
			,p_override_rate in number default null) return number
is

   l_group_code            varchar2(30);
   l_rate_value            number;
   l_rate_type             varchar2(80);
   l_contribution_usage_id number;
   l_contribution_code     varchar2(30);
   l_contribution_value    number;
   l_contribution_type     varchar2(10);
   l_base_name             pay_user_Column_instances_f.value%type;
   l_code_rate_id          number;
   l_rate_category         varchar2(1);
   l_element_name          pay_fr_contribution_usages.element_name%type;

   l_contribution_usage_row pay_fr_contribution_usages%rowtype;

   l_proc varchar2(72) := g_package||'.GET_RATE_VALUE';

begin
   hr_utility.set_location('Entered pay_fr_general.get_rate_type',10);
   hr_utility.set_location('Obtaining row, Element='||p_element_name, 11);
   hr_utility.set_location('.       p_process_type='||g_process_type,12);
   hr_utility.set_location('.         p_usage_type='||p_usage_type,13);
   hr_utility.set_location('.         p_date_earnd='||p_date_earned,14);
   hr_utility.set_location('.         p_assignt_id='||p_assignment_id,15);
   hr_utility.set_location('.         p_bus_grp_id='||p_business_group_id,16);
   l_contribution_usage_row:= get_contribution_usage(
			 p_process_type => g_process_type
			,p_element_name => p_element_name
			,p_usage_type	 => p_usage_type
                        ,p_effective_date => p_date_earned
                        ,p_business_group_id => p_business_group_id);

   l_group_code := l_contribution_usage_row.group_code;
   l_rate_type  := l_contribution_usage_row.rate_type;
   l_contribution_code := l_contribution_usage_row.contribution_code;
   l_contribution_usage_id := l_contribution_usage_row.contribution_usage_id;
   l_contribution_type := l_contribution_usage_row.contribution_type;
   l_code_rate_id := l_contribution_usage_row.code_rate_id;
   l_rate_category := l_contribution_usage_row.rate_category;
   l_element_name := l_contribution_usage_row.element_name;

   l_rate_value := get_cached_rate(p_assignment_id,l_contribution_usage_id, p_tax_unit_id,
                                   l_contribution_code, l_code_rate_id, l_rate_type);
   if l_rate_value is null then -- { no cached rate
      hr_utility.set_location('Entered '||l_proc,40);
      if p_override_rate is null then
        l_rate_value := get_rate_value(p_business_group_id,l_rate_type);
      else
        l_rate_value := p_override_rate;
        hr_utility.set_location('Using Override Rate Value:'||p_override_rate,80);
      end if;
      maintain_rate_cache(l_contribution_usage_id, p_tax_unit_id, l_contribution_code,
                          l_rate_value, l_code_rate_id, l_rate_type);
   end if;

   hr_utility.set_location('Leaving get_contribution_usage rate value:'||l_rate_value,100);
   return l_rate_value;

end get_rate_value;


------------------------------------------------------------------------
-- Function GET_FORMULA_INFO
-- This function is used to obtain a fast formula ID and effective_start_date.
--
-- This function will return -1 if the formula was not found,
-- otherwise the formula_id is returned
------------------------------------------------------------------------
function get_formula_info
			(p_formula_name          in varchar2
			,p_effective_date        in date
                        ,p_business_group_id     in number default -1
                        ,p_effective_start_date  out nocopy date
                        ) return number
is
  cursor csr_get_formula is
    select ff.formula_id,
         ff.effective_start_date
    from   ff_formulas_f    ff
       ,   ff_formula_types ft
    where  ft.formula_type_name = 'Oracle Payroll'
    and    ft.formula_type_id   = ff.formula_type_id
    and    ff.formula_name = p_formula_name
    and    p_effective_date between ff.effective_start_date and ff.effective_end_date
    and    nvl(ff.business_group_id,-1) = p_business_group_id
    and    nvl(ff.legislation_code,'FR') = 'FR';

   l_formula_id  number;
   l_start_date  date;

begin
   open  csr_get_formula;
   fetch csr_get_formula into l_formula_id, l_start_date;
   If csr_get_formula%found then
      p_effective_start_date := l_start_date;
   else
      /* If the formula was not found then return -1 to indicate an error */
      l_formula_id := -1;
      p_effective_start_date := to_date('01011900','DDMMYYYY');
   end if;

   close csr_get_formula;

   return l_formula_id;

end get_formula_info;


--
------------------------------------------------------------------------
-- Function SUB_CONTRIB_CODE
-- This function will determine the full contribution code by substituting
-- into the pattern contribution code the correct base code.
------------------------------------------------------------------------
function sub_contrib_code(p_contribution_type in varchar2
                         ,p_contribution_code in varchar2) return varchar2 IS
--
  l_full_code varchar2(7);
  l_base_code varchar2(4);
   l_proc varchar2(72) := g_package||'.sub_contrib_code';
   --
begin
   --
   hr_utility.set_location('Entered '||l_proc,5);

   /* Some contributions do not have a contribution code, therefore do not substitute */
   if p_contribution_code is NULL then
      return null;
   else
      /* Substitute the correct base code into the contribution code */
      If p_contribution_type in ('URSSAF','ASSEDIC','AGIRC','ARRCO') then
         /* obtain correct base code value  */
         l_base_code := g_base_code_table(get_table_index(p_contribution_type));

         IF p_contribution_type = 'URSSAF' THEN
            l_full_code := '1'|| l_base_code || substr(p_contribution_code,4,4);
         ELSIF p_contribution_type = 'ASSEDIC' THEN
            l_full_code := '2'|| l_base_code || substr(p_contribution_code,3,5);
         ELSIF p_contribution_type = 'AGIRC' THEN
            l_full_code := '3'|| l_base_code || substr(p_contribution_code,6,2);
         ELSE  /* Must be ARRCO */
            l_full_code := '4'|| l_base_code || substr(p_contribution_code,6,2);
         END IF;

         hr_utility.set_location('Leaving, code found='||l_full_code,50);
         return l_full_code;

      ELSE
         /* Contribution Type was not one of the four valid values */
         fnd_message.set_name('PAY', 'PAY_74909_CNU_BAD_CONT_TYPE');
         fnd_message.raise_error;
      END IF;
   end if;
exception
   when no_data_found then
      fnd_message.set_name('PAY','PAY_74914_SD_NO_BASE_CODE_VAL');
      fnd_message.set_token('TYPE',p_contribution_type);
      fnd_message.raise_error;

end sub_contrib_code;

------------------------------------------------------------------------
-- Function GET_PAYROLL_MESSAGE
-- This function is used to obtain a message.
-- The token parameters must be of the form 'TOKEN_NAME:TOKEN_VALUE' i.e.
-- If you want to set the value of a token called ELEMENT to FR_ER_SMID
-- the token parameter would be 'ELEMENT:FR_ER_SMID'
------------------------------------------------------------------------
function get_payroll_message
			(p_message_name      in varchar2
			,p_token1       in varchar2 default null
                        ,p_token2       in varchar2 default null
                        ,p_token3       in varchar2 default null) return varchar2
is
   l_message varchar2(2000);
   l_token_name varchar2(20);
   l_token_value varchar2(80);
   l_colon_position number;
   l_proc varchar2(72) := g_package||'.get_payroll_name';
   --
begin
   --
   hr_utility.set_location('Entered '||l_proc,5);
   hr_utility.set_location('.  Message Name: '||p_message_name,40);

   fnd_message.set_name('PAY', p_message_name);

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

   l_message := substrb(fnd_message.get,1,250);

   hr_utility.set_location('leaving '||l_proc,100);

   return l_message;
end get_payroll_message;



------------------------------------------------------------------------
-- Function INITIALIZE_PAYROLL
-- This function is used to initialise a number of global variables
-- that are used by payroll processing.
------------------------------------------------------------------------
function initialize_payroll
			(p_business_group_id in number
			,p_effective_date    in date
                        ,p_assignment_id     in number
                        ,p_tax_unit_id       in number
			,p_process_type      in varchar2
			,p_orig_entry_id     in number
			,p_asg_action_id in number
			,p_payroll_id        in number
                   	,P_ASG_HOURS         in number
                   	,p_asg_frequency     in varchar2 ) return number
is
   l_proc varchar2(72) := g_package||'.initialize_payroll';
   --
   l_parent_action_id  number;
   --
   cursor csr_parent_action is
          select nvl(nvl(act_parent.source_action_id, act_child.source_action_id),act_child.assignment_action_id)
          from  pay_assignment_actions act_child,
                pay_assignment_actions act_parent
          where act_child.assignment_action_id = p_asg_action_id
            and act_parent.assignment_action_id (+) = act_child.source_action_id;
begin
   --
   hr_utility.set_location('Entered '||l_proc,5);
   -- First check if this is a supplementary run.  Call consumed entry
   -- only on change of (grand) parent action.
   open csr_parent_action;
   fetch csr_parent_action into l_parent_action_id;
   close csr_parent_action;

   if g_parent_asg_action_id is null
   or g_parent_asg_action_id <> l_parent_action_id then
      g_parent_asg_action_id := l_parent_action_id;
      if pay_consumed_entry.consumed_entry
              (p_date_earned  => p_effective_date
              ,p_payroll_id   => p_payroll_id
              ,p_ele_entry_id => p_orig_entry_id) = 'Y'
      then
         -- return with error status
         hr_utility.set_location(' Leaving '||l_proc,10);
         return 1;
      end if;
      -- 115.46 Also clear rate cache on change of (grand) parent action
      g_deduction_rates.delete;
   end if;

   /* Set Contribution information global variables */

   /* Delete all existing values from the PL/SQL temp tables */
   g_band_table.delete;
   g_base_code_table.delete;
   g_summary_deductions.delete;
   g_summary_idx := 0;

   g_process_type      := p_process_type;

   g_monthly_hours := convert_hours(p_effective_date => p_effective_date
                                   ,p_business_group_id => p_business_group_id
                                   ,p_assignment_id  => p_assignment_id
                                   ,p_hours          => p_asg_hours
                                   ,p_from_freq_code => p_asg_frequency
                                   ,p_to_freq_code   => 'M');

   -- Ver 115.16 Added Call to set_prior_asg_action
   set_prior_asg_action(p_date_earned       => p_effective_date
                       ,p_assignment_id     => p_assignment_id
                       ,p_business_group_id => p_business_group_id
                       ,p_tax_unit_id       => p_tax_unit_id        -- Tax_Unit_id is Establishment_ID
                       ,p_orig_entry_id     => p_orig_entry_id );

   hr_utility.set_location('leaving pay_fr_general.initialize_payroll',50);
   return 0;
end initialize_payroll;


------------------------------------------------------------------------
-- Function GET_URSSAF_BASE_CODE
-- This function will obtain the base code for URSSAF contributions.
------------------------------------------------------------------------
function get_urssaf_base_code(P_ASSIGNMENT_ID             in number
                             ,P_BUSINESS_GROUP_ID         in number
                             ,p_date_earned               in date
                             ,P_ESTAB_FORMAT_NUMBER       in VARCHAR2
                             ,P_ESTAB_WORK_ACCIDENT_ORDER_NO in VARCHAR2
                                ) return varchar2
is

   l_base_code   varchar2(2);
   l_index       number;
   l_existing_row  varchar2(4);
   l_proc varchar2(72) := g_package||'.get_urssaf_base_code';
   --
begin
   --
   hr_utility.set_location('Entered '||l_proc,5);

   /* Check to see if run already exists this period and if it does obtain base_code from the input value
   of the URSSAF_BASES element */

   l_base_code := get_prior_base_code(p_base_element => 'FR_URSSAF_BASES'
                            ,p_date_earned  => p_date_earned
                            ,p_assignment_id => p_assignment_id
                            ,p_business_group_id => p_business_group_id);

   IF l_base_code is null then
      hr_utility.set_location('Estab Format No:'''||p_estab_format_number||''' ',50);
      hr_utility.set_location('Estab Wrk Accident Ord No:'''||p_estab_work_accident_order_no||''' ',51);
      l_base_code := P_ESTAB_FORMAT_NUMBER || P_ESTAB_WORK_ACCIDENT_ORDER_NO;
   ELSE
      l_base_code := substr(l_base_code,1,1)||P_ESTAB_WORK_ACCIDENT_ORDER_NO;
   END IF;

    hr_utility.set_location('URSSAF base code:'||l_base_code,20);


   /* WRITE VALUE TO PL/SQL TABLE TO BE USED BY CONTRIBUTIONS PROCESS */
   l_index := get_table_index('URSSAF');

   /* Ensure that the index has not already been used */
   begin
      l_existing_row := g_base_code_table(l_index);

      /* If a no_data_found exception did not occur then the index is
         already in use and hence an error has occured */
      fnd_message.set_name('PAY','PAY_74915_SD_NON_UNIQUE_INDEX');
      fnd_message.set_token('NAME','URSSAF');
      fnd_message.raise_error;

   exception
      when no_data_found then null; -- success, the index number has not been used
   end;

   g_base_code_table(l_index) := l_base_code;

   hr_utility.set_location('URSSAF base code written to PL/SQL table',50);

   return l_base_code;

end get_urssaf_base_code;


------------------------------------------------------------------------
-- Function GET_ASSEDIC_BASE_CODE
-- This function will obtain the base code for ASSEDIC contributions.
------------------------------------------------------------------------
function get_assedic_base_code(p_assignment_id            in number
                             ,P_BUSINESS_GROUP_ID         in number
                             ,p_date_earned               in date
                              ,P_ESTAB_ASSEDIC_ORDER_NUMBER in varchar2
                             )  return varchar2
is
--
   l_base_code   varchar2(1);
   l_existing_row varchar2(4);
   l_index        number;
   l_proc varchar2(72) := g_package||'.get_assedic_base_code';
   --
begin
   --
   hr_utility.set_location('Entered '||l_proc,5);

   /* Check to see if run already exists this period and if it does obtain base_code
   from the input value of the ASSEDIC_BASES element */

   l_base_code := get_prior_base_code(p_base_element => 'FR_ASSEDIC_BASES'
                            ,p_date_earned  => p_date_earned
                            ,p_assignment_id => p_assignment_id
                            ,p_business_group_id => p_business_group_id);

   IF l_base_code is null then
      l_base_code := P_ESTAB_ASSEDIC_ORDER_NUMBER;

   END IF;

    hr_utility.set_location('ASSEDIC base code:'||l_base_code,20);


   /* WRITE VALUE TO PL/SQL TABLE TO BE USED BY CONTRIBUTIONS PROCESS */
   l_index := get_table_index('ASSEDIC');

   /* Ensure that the index has not already been used */
   begin
      l_existing_row := g_base_code_table(l_index);

      /* If a no_data_found exception did not occur then the index is
         already in use and hence an error has occured */
      fnd_message.set_name('PAY','PAY_74915_SD_NON_UNIQUE_INDEX');
      fnd_message.set_token('NAME','ASSEDIC');
      fnd_message.raise_error;

   exception
      when no_data_found then null; -- success, the index number has not been used
   end;

   g_base_code_table(l_index) := l_base_code;

   hr_utility.set_location('ASSEDIC base code written to PL/SQL table',50);


   return l_base_code;

end get_assedic_base_code;


------------------------------------------------------------------------
-- Function GET_PENSION_BASE_CODE
-- This function will obtain the base code for PENSION contributions, it
-- handles both AGRIC and ARRCO base code because as a parameter
-- the provider type must be passed in.
------------------------------------------------------------------------
function get_pension_base_code(p_establishment_id  in number
                     ,p_assignment_id              in number
                     ,P_BUSINESS_GROUP_ID          in number
                     ,p_date_earned                in date
                     ,p_emp_pension_provider_id    in number
                     ,p_provider_type              in varchar2
	             ,p_emp_pension_category       in varchar2
   	             ) return varchar2
is

   cursor estab_pen_prvs_csr is
      select oi1.org_information4 order_number
      from hr_organization_information oi1
      where oi1.organization_id = p_establishment_id
      and oi1.org_information_context = 'FR_ESTAB_PE_PRVS'
      and oi1.org_information1 = p_emp_pension_provider_id;

   cursor estab_default_pen_prvs_csr is
      select oi1.org_information4 order_number
      from hr_organization_information oi1
         , hr_organization_information oi2
      where oi1.organization_id = p_establishment_id
      and oi1.org_information_context = 'FR_ESTAB_PE_PRVS'
      and oi1.org_information3 = 'Y'
      and oi1.org_information1 = oi2.organization_id
      and oi2.org_information2 = p_provider_type
      and oi2.org_information_context = 'FR_PE_PRV_INFO';


   l_order_number varchar2(20);
   l_provider_id  number;
   l_base_code    varchar2(4);
   l_existing_row varchar2(4);
   l_index        number;
--
begin
   hr_utility.set_location('Entered get_pension_base_code, TYPE='||p_provider_type,10);

   /* Check to see if run already exists this period and if it does obtain base_code from the input value
   of the BASES element */

   l_base_code := get_prior_base_code(p_base_element => 'FR_'||p_provider_type||'_BASES'
                            ,p_date_earned  => p_date_earned
                            ,p_assignment_id => p_assignment_id
                            ,p_business_group_id => p_business_group_id);

   IF l_base_code is null then
      /* No previous run found so obtain the latest information */

      IF p_emp_pension_provider_id <> -1 THEN
            hr_utility.set_location('Provider set on Pension Element is:'||p_emp_pension_provider_id,15);
            hr_utility.set_location('Establishment ='||p_establishment_id,15);
            /* The provider has been set on the Pension Information Element
            therefore obtain the estab info for that provider */

            open estab_pen_prvs_csr;
            fetch estab_pen_prvs_csr into l_order_number;

            if estab_pen_prvs_csr%notfound then
               close estab_pen_prvs_csr;
               fnd_message.set_name('PAY','PAY_74926_SD_BAD_PEN_PRVS');
               fnd_message.set_token('TYPE',p_provider_type);
               fnd_message.raise_error;
            else
               close estab_pen_prvs_csr;
            end if;
            hr_utility.set_location('Order Number Found:'||l_order_number,20);

      ELSE  /* find the default pension provider from the estab eit i.e. Provider not set on Pension element*/

            hr_utility.set_location('About to obtain default pension provider from Estab:'||p_establishment_id,30);

            open estab_default_pen_prvs_csr;
            fetch estab_default_pen_prvs_csr into l_order_number;

            if estab_default_pen_prvs_csr%notfound then
               close estab_default_pen_prvs_csr;
               /* Raise Application error as no default provider could be found */
               fnd_message.set_name('PAY','PAY_74917_SD_NO_DFLT_PEN_PRVS');
               fnd_message.set_token('TYPE',p_provider_type);
               fnd_message.raise_error;
            else
               /* Check that only one default was set - i.e. no more records should be found */
               fetch estab_default_pen_prvs_csr into l_order_number;

               if estab_default_pen_prvs_csr%found then
                  close estab_default_pen_prvs_csr;
                  /* If a row was found then an error has occured */
                  fnd_message.set_name('PAY','PAY_74916_SD_BAD_DFLT_PEN_PRVS');
                  fnd_message.set_token('TYPE',p_provider_type);
                  fnd_message.raise_error;
               ELSE
                  hr_utility.set_location('Order Number Found:'||l_order_number,39);
                  close estab_default_pen_prvs_csr;
               end if;
            end if;
      END IF;  /* end of obtaining default provider */

      l_base_code := l_order_number || p_emp_pension_category;

   END IF; /* End of section that obtain new values if previous run was not found */

   /* WRITE VALUE TO PL/SQL TABLE TO BE USED BY CONTRIBUTIONS PROCESS */
   l_index := get_table_index(p_provider_type);

   /* Ensure that the index has not already been used */
   begin
      l_existing_row := g_base_code_table(l_index);

      /* If a no_data_found exception did not occur then the index is
         already in use and hence an error has occured */
      fnd_message.set_name('PAY','PAY_74915_SD_NON_UNIQUE_INDEX');
      fnd_message.set_token('NAME',p_provider_type);
      fnd_message.raise_error;

   exception
      when no_data_found then null; -- success, the index number has not been used before
   end;

   g_base_code_table(l_index) := l_base_code;

   hr_utility.set_location(p_provider_type||' base code written to PL/SQL table',50);


   return l_base_code;

end get_pension_base_code;


------------------------------------------------------------------------
-- Function GET_CONTRIBUTION_BAND
-- This will be used to retrieve the URSSAF, ASSEDIC, ARRCO and AGIRC
-- band values (excluding GMP_BAND).
------------------------------------------------------------------------
function get_contribution_band(
                 p_business_group_id in number
		,p_band_type       in varchar2
   		,p_ytd_ss_ceiling  in number
   		,p_ytd_base        in number
		,p_ytd_band        in number
   		) return number
is
   l_band_low_value	number;
   l_band_high_value	number;
   l_ytd_low_value	number;
   l_ytd_high_value	number;
   l_run_band           number;
--
begin
   hr_utility.set_location('Entered get_contribution_band, band_type= '||p_band_type,0);
   hr_utility.set_location('SS_ceiling_YTD: '||p_ytd_ss_ceiling||', ytd_base:'||p_ytd_base||', ytd_band: '||p_ytd_band,1);

   l_band_low_value := to_number(hruserdt.get_table_value(p_bus_group_id => p_business_group_id
                           ,p_table_name => 'FR_CONTRIBUTION_BANDS'
			   ,p_col_name=> 'LOW_VALUE'
			   ,p_row_value   => p_band_type));
   hr_utility.set_location('Low value found= '||l_band_low_value,4);

   l_band_high_value := to_number(hruserdt.get_table_value(p_bus_group_id => p_business_group_id
                           ,p_table_name =>  'FR_CONTRIBUTION_BANDS'
			   ,p_col_name=> 'HIGH_VALUE'
			   ,p_row_value   => p_band_type));
   hr_utility.set_location('High value found= '||l_band_high_value,6);

   --
   l_ytd_low_value := p_ytd_ss_ceiling * l_band_low_value;
   l_ytd_high_value := p_ytd_ss_ceiling * l_band_high_value;

   --
   if p_ytd_base < l_ytd_low_value then
       l_run_band := -1 * p_ytd_band;
   else if l_ytd_low_value <= p_ytd_base and p_ytd_base  <= l_ytd_high_value then
            l_run_band := p_ytd_base  - p_ytd_band - l_ytd_low_value;
        else
            l_run_band := l_ytd_high_value - p_ytd_band - l_ytd_low_value;
        end if;
   end if;

   l_run_band := round(l_run_band,2);

   hr_utility.set_location('Band: '||p_band_type||' Value calculated= '||l_run_band,8);
   --
   return l_run_band;
end get_contribution_band;


------------------------------------------------------------------------
-- Function GET_GMP_BAND
-- This will be used to retrieve the GMP band value
------------------------------------------------------------------------
function get_gmp_band(p_ytd_gmp_ceiling in number
                         ,p_ytd_gmp_band       in number
                         ,p_ytd_p3_band        in number
                         ,p_run_p3_band        in number) return number

IS
     l_new_ytd_p3_band  number;
     l_ytd_gmp_value    number;
     l_run_gmp_band     number;
begin
    hr_utility.set_location('Entered pay_fr_general.get_gmp_band',10);

    hr_utility.set_location('YTD GMP ceiling:'||p_ytd_gmp_ceiling,25);
    l_new_ytd_p3_band := p_ytd_p3_band + p_run_p3_band;
    hr_utility.set_location('YTD P3 band:'||l_new_ytd_p3_band,30);

    if p_ytd_gmp_ceiling > l_new_ytd_p3_band then
       l_ytd_gmp_value := p_ytd_gmp_ceiling - l_new_ytd_p3_band;
    else
       l_ytd_gmp_value := 0;
    end if;

    hr_utility.set_location('YTD GMP band:'||l_ytd_gmp_value,35);

    l_run_gmp_band := l_ytd_gmp_value - p_ytd_gmp_band;

    l_run_gmp_band := round(l_run_gmp_band,2);

    hr_utility.set_location('GMP Band Run Value calculated: '||l_run_gmp_band,50);

    return l_run_gmp_band;
end get_gmp_band;


------------------------------------------------------------------------
-- Function GET_SALARY_TAX_BAND
-- This will be used to retrieve the Salary Tax band values
------------------------------------------------------------------------
function get_salary_tax_band(p_business_group_id    in number,
                                p_band_type         in varchar2,
                                p_ptd_base          in number,
                                p_ptd_band          in number) return number
is
   l_low_value number;
   l_high_value number;
   l_run_band   number;

begin
   --
   hr_utility.set_location('Entered fr_get_salary_tax_band, band_type= '||p_band_type,10);
   hr_utility.set_location('Base PTD='||p_ptd_base||', Band PTD='||p_ptd_band,15);

   l_low_value := to_number(hruserdt.get_table_value(p_bus_group_id => p_business_group_id
                           ,p_table_name => 'FR_CONTRIBUTION_BANDS'
			   ,p_col_name=> 'LOW_VALUE'
			   ,p_row_value   => p_band_type));
   l_high_value := to_number(hruserdt.get_table_value(p_bus_group_id => p_business_group_id
                           ,p_table_name => 'FR_CONTRIBUTION_BANDS'
			   ,p_col_name=> 'HIGH_VALUE'
			   ,p_row_value   => p_band_type));
   hr_utility.set_location('low band='||l_low_value||', high_band='||l_high_value,20);


   l_low_value  := l_low_value / 12;
   l_high_value := l_high_value / 12;
   --
   hr_utility.set_location('low band='||l_low_value||', high_band='||l_high_value,20);
   if p_ptd_base < l_low_value then
	l_run_band :=0;
   elsif p_ptd_base < l_high_value then
        l_run_band := p_ptd_base - p_ptd_band - l_low_value;
   else
        l_run_band := l_high_value - p_ptd_band - l_low_value;
   end if;

   l_run_band := round(l_run_band,2);

   hr_utility.set_location('Band Value: '||l_run_band,50);

   return l_run_band;
--
end get_salary_tax_band;

------------------------------------------------------------------------
-- Function WRITE_BASE_BAND
-- This will be used to store a base or band value in a PL/SQL table
-- to enable the value to be easily obtained later in the payroll process
------------------------------------------------------------------------
function WRITE_BASE_BANDS(p_name in varchar2
                            ,p_value in number) return number
is
   l_index         number;
   l_existing_row  number;
begin
   l_index := get_table_index(p_name);

   /* Ensure that the band index has not already been used */
   begin
      l_existing_row := g_band_table(l_index);

      /* If a no_data_found exception did not occur then the index is
         already in use and hence an error has occured */
      fnd_message.set_name('PAY','PAY_74915_SD_NON_UNIQUE_INDEX');
      fnd_message.set_token('NAME',p_name);
      fnd_message.raise_error;

      return 1;  --Return 1 to indicate an error occured

   exception
      when no_data_found then null; -- success, the index number has not been used already
   end;

   g_band_table(l_index) := p_value;

   hr_utility.set_location('WRITE_BASE_BAND: '||p_name||', value: '||p_value||', Index: '||l_index,500);

   return 0;  -- Return 0 to indicate success
end write_base_bands;

------------------------------------------------------------------------
-- Function WRITE_CALENDAR_DAYS_WORKED
-- This will be used to store the value of calendar days worked,
-- as determined in the formula FR_SS_CEILING.  The value is stored in a
-- global so that it can be used in GET_GMP_BAND for pro-ration
------------------------------------------------------------------------
function WRITE_CALENDAR_DAYS_WORKED(p_calendar_days_worked in number) return number
is

begin
   g_calendar_days_worked := p_calendar_days_worked;
   return 0;  -- Indicates success
end write_calendar_days_worked;

------------------------------------------------------------------------
-- Function READ_CALENDAR_DAYS_WORKED
-- This will be used to read the value of calendar days worked,
-- this value is stored as a package variable
------------------------------------------------------------------------
function READ_CALENDAR_DAYS_WORKED return number
is

begin
   --
   return pay_fr_general.g_calendar_days_worked;
   --
end read_calendar_days_worked;

------------------------------------------------------------------------
-- Function GET_DAYS_OVER_PENSION_LIMIT
-- This function obtains the number of days in the month that are
-- over the annual absence days limit.
------------------------------------------------------------------------
function get_days_over_pension_limit(p_assignment_id          in number
                                     ,p_business_group_id     in number
                                     ,p_pay_period_start_date in date
                                     ,p_pay_period_end_date   in date
                                     ,p_abs_days_limit        in number) return number
is
   l_proc varchar2(72) := g_package||'.get_days_over_pension_limit';
   l_days_over_limit        number;
   l_start_of_cal_year      date;
   l_non_abs_day            date;
   l_num_rolling_abs_days   number;
   l_start_cal_year      date;
   l_start_prev_cal_year date;
   l_non_abs_day_prev_yr    date;
   l_debug_number           number;

   function get_non_absence_day(p_start_of_year     in date
                               ,p_assignment_id     in number
                               ,p_business_group_id in number)  return date
   is
      l_first_absence_day date;
   /* The absence records to consider should only be those that feed
      the sickness days absence balance */
   cursor first_sickness_abs_csr is
      select min(paa.date_start)
      from pay_balance_types pbt
         , pay_balance_feeds_f pbf
         , pay_input_values_f piv
         , pay_element_types_f pet
         , pay_element_entries_f pee
         , pay_element_links_f pel
         , per_absence_attendances paa
      where pbt.balance_name = 'FR_SICKNESS_ABSENCE_DAYS'
        and pbt.business_group_id IS NULL
        and pbt.legislation_code = 'FR'
        and pbt.balance_type_id = pbf.balance_type_id
        and pbf.input_value_id = piv.input_value_id
        and pbf.business_group_id = p_business_group_id
        and piv.element_type_id = pet.element_type_id
        and pet.element_type_id = pel.element_type_id
        and pet.business_group_id = p_business_group_id
        and pel.element_link_id = pee.element_link_id
        and pee.assignment_id = p_assignment_id
        and pee.creator_type = 'A'
        and pee.creator_id = paa.absence_attendance_id
        and paa.date_start > p_start_of_year
        and pbf.effective_start_date <= pee.effective_start_date
        and pbf.effective_end_date >= pee.effective_end_date;

   begin

      /* This function will obtain the 1st absence in the year that does not span the year end
         boundary.    It will then return the day prior to this.
         Even though this is not the first non absence day.  This date is acceptable because all we are
         really interested in is the fact that no absence occurred up to that point in the year */

      open first_sickness_abs_csr;
      fetch first_sickness_abs_csr into l_first_absence_day;

      if first_sickness_abs_csr%notfound then
         hr_utility.set_location('Could not find any absence in year starting:'||to_char(p_start_of_year),10);

         close first_sickness_abs_csr;
         return p_start_of_year;
      else
         hr_utility.set_location('First Absence found was:'||to_char(l_first_absence_day),20);
         l_first_absence_day := l_first_absence_day -1;
         hr_utility.set_location('Prior day was:'||to_char(l_first_absence_day),30);

         close first_sickness_abs_csr;
         return l_first_absence_day;
      end if;

   end get_non_absence_day;

   function get_abs_days(p_from_date         in date
                        ,p_to_date           in date
                        ,p_assignment_id     in number
                        ,p_business_group_id in number) return number
   is
      l_abs_days number;
   /* The absence records to consider should only be those that feed
      the sickness days absence balance */
   cursor count_sickness_abs_csr is
      select /*+ USE_NL(pbt pee pee2) */
           sum(paa.absence_days)
      from pay_balance_types pbt
         , pay_balance_feeds_f pbf
         , pay_input_values_f piv
         , pay_element_types_f pet
         , pay_element_entries_f pee
         , pay_element_links_f pel
         , per_absence_attendances paa
         , pay_element_entries_f pee2
         , pay_element_links_f pel2
         , pay_element_types_f pet2
      where pbt.balance_name = 'FR_SICKNESS_ABSENCE_DAYS'
        and pbt.business_group_id IS NULL
        and pbt.legislation_code = 'FR'
        and pbt.balance_type_id = pbf.balance_type_id
        and pbf.input_value_id = piv.input_value_id
        and pbf.business_group_id = p_business_group_id
        and piv.element_type_id = pet.element_type_id
        and pet.element_type_id = pel.element_type_id
        and pet.business_group_id = p_business_group_id
        and pet.effective_start_date <= p_from_date
        and pet.effective_end_date >= p_to_date
        and pel.element_link_id = pee.element_link_id
        and pee.assignment_id = p_assignment_id
        and pee.creator_type = 'A'
        and pee.creator_id = paa.absence_attendance_id
        and paa.date_start >= p_from_date
        and paa.date_end <= p_to_date
        and pbf.effective_start_date <= pee.effective_start_date
        and pbf.effective_end_date >= pee.effective_end_date
        /* Added to ensure that absences where employee is ARRCO are excluded */
        and paa.date_start between pee2.effective_start_date and pee2.effective_end_date
        and pee2.assignment_id = p_assignment_id
        and pee2.entry_type = 'E'
        and pee2.creator_type = 'F'
        and pee2.element_link_id = pel2.element_link_id
        and paa.date_start between pel2.effective_start_date and pel2.effective_end_date
        and pel2.element_type_id = pet2.element_type_id
        and paa.date_start between pet2.effective_start_date and pet2.effective_end_date
        and pet2.element_name = 'FR_PENSION'
        and pet2.legislation_code = 'FR'
        and 'Y' = hruserdt.get_table_value(p_business_group_id
                            , 'FR_APEC_AGIRC', 'AGIRC'
                            , pee2.entry_information1, paa.date_start);

   begin
      hr_utility.set_location('Entered get_abs_days, ASG_ID:'||p_assignment_id||', BG_ID:'||p_business_group_id,10);
      hr_utility.set_location('.  From:'||p_from_date||', To:'||p_to_date,20);

      open count_sickness_abs_csr;
      fetch count_sickness_abs_csr into l_abs_days;

      if count_sickness_abs_csr%notfound then
         hr_utility.set_location('Could not find any absence in period:'||p_from_date||', To:'||p_to_date,10);

         close count_sickness_abs_csr;
         l_abs_days := 0;
      else
         hr_utility.set_location('Found Absence days='||l_abs_days,20);
         close count_sickness_abs_csr;
      end if;

      return l_abs_days;

   end get_abs_days;
--
begin
   --
   hr_utility.set_location('Entered '||l_proc,5);
   hr_utility.set_location('Abs Days Limit:'||p_abs_days_limit,10);

   /* Get the start of the year and the day where no absences exist up to */
   l_start_cal_year := trunc(p_pay_period_start_date,'YEAR');

   hr_utility.set_location('Start of Payroll Year: '||l_start_cal_year,10);

   l_non_abs_day := get_non_absence_day(p_start_of_year     => l_start_cal_year,
                                       p_assignment_id     => p_assignment_id,
                                       p_business_group_id => p_business_group_id);
   hr_utility.set_location('First non absence day: '||l_non_abs_day,20);

   if l_non_abs_day < p_pay_period_start_date then
      hr_utility.set_location('Rolling Year Has been rest',30);
      /* The rolling year has been reset prior to this period.  Therefore get the
         absence day count from the sart of the new rolling period to the end
         of this month */
      l_num_rolling_abs_days := get_abs_days(p_from_date     => l_non_abs_day,
                                            p_to_date       => p_pay_period_end_date,
                                            p_assignment_id => p_assignment_id,
                                            p_business_group_id => p_business_group_id);
   else
      hr_utility.set_location('Still in Rolling year',40);
      /* Otherwise the rolling year is still continuing from the previous year.
         Therefore get the rolling absence count start from the previous years first
         absence. Up to whichever occurs first of, the end of the payroll period or
         the first non absence day this year. */
      l_start_prev_cal_year := add_months(l_start_cal_year,-12);

      l_non_abs_day_prev_yr := get_non_absence_day(p_start_of_year     => l_start_prev_cal_year
                                                  ,p_assignment_id     => p_assignment_id
                                                  ,p_business_group_id => p_business_group_id);
      hr_utility.set_location('Previous year first non absence day: '||l_non_abs_day_prev_yr,50);

      l_num_rolling_abs_days := get_abs_days(p_from_date     => l_non_abs_day_prev_yr
                                            ,p_to_date       => least(l_non_abs_day,p_pay_period_end_date)
                                            ,p_assignment_id => p_assignment_id
                                            ,p_business_group_id => p_business_group_id);
      hr_utility.set_location('Rolling year absence days: '||l_num_rolling_abs_days,60);

   end if;



   if l_num_rolling_abs_days > p_abs_days_limit then

      l_days_over_limit := l_num_rolling_abs_days - p_abs_days_limit;

   else
      l_days_over_limit := 0;
   end if;

   hr_utility.set_location('Days over Limit: '||l_days_over_limit,200);
   return l_days_over_limit;

end get_days_over_pension_limit;


------------------------------------------------------------------------
-- Function GET_CONTRIBUTION_INFO
-- This will be used to obtain all the information about a given contribution element
-- i.e. Contribution amount, base value, rate value, usage_id an contribution code.
------------------------------------------------------------------------

function get_contribution_info( p_assignment_id          in number
				,p_business_group_id     in number
                                ,p_date_earned           in date
                                ,p_tax_unit_id           in number
                                ,p_element_name 	 IN varchar2
				,p_usage_type    	 IN varchar2
				,p_base 		 OUT NOCOPY number
				,p_rate 		 OUT NOCOPY number
				,p_contribution_code 	 IN OUT NOCOPY varchar2
				,p_contribution_usage_id OUT NOCOPY number
                                ,p_override_rate        in number default null) return number
is
   l_group_code            varchar2(30);
   l_rate_value            number;
   l_rate_type             varchar2(80);
   l_contribution_usage_id number;
   l_contribution_code     varchar2(30);
   l_contribution_value    number;
   l_contribution_type     varchar2(10);
   l_base_name             pay_user_Column_instances_f.value%type;
   l_code_rate_id          number;
   l_rate_category         varchar2(1);
   l_element_name          pay_fr_contribution_usages.element_name%type;

   l_contribution_usage_row pay_fr_contribution_usages%rowtype := get_contribution_usage(
			 p_process_type => g_process_type
			,p_element_name => p_element_name
			,p_usage_type	 => p_usage_type
                        ,p_effective_date => p_date_earned
                        ,p_business_group_id => p_business_group_id);


  l_proc varchar2(72) := g_package||'.GET_CONTRIBUTION_INFO';
  --
begin
   --
   hr_utility.set_location('Entered '||l_proc,5);
   hr_utility.set_location('.  Element: '||p_element_name,10);

   l_group_code := l_contribution_usage_row.group_code;
   l_rate_type  := l_contribution_usage_row.rate_type;
   l_contribution_code := l_contribution_usage_row.contribution_code;
   l_contribution_usage_id := l_contribution_usage_row.contribution_usage_id;
   l_contribution_type := l_contribution_usage_row.contribution_type;
   l_code_rate_id := l_contribution_usage_row.code_rate_id;
   l_rate_category := l_contribution_usage_row.rate_category;
   l_element_name := l_contribution_usage_row.element_name;

   hr_utility.set_location('.    group code:'||l_group_code,20);
   hr_utility.set_location('.     rate type:'||l_rate_type,25);

   /* Call function to substitute base code into contribution code */
   if l_contribution_code is not null then
      l_contribution_code := sub_contrib_code(
                                p_contribution_type => l_contribution_type
                               ,p_contribution_code => l_contribution_code);
   elsif p_contribution_code is not null then
      -- use template code passed in, with extra validation
      l_contribution_code := substitute_code(p_contribution_code);
   end if;
   hr_utility.set_location('.  Contribution code:'||l_contribution_code,28);

   l_base_name := get_base_name(p_business_group_id, l_group_code);

   hr_utility.set_location('.  Base_name ='||l_base_name,35);

   p_base := get_base_value(l_base_name);

   -- check to see if this rate has been used for this assignment in previous subruns
   -- for this assignment, establishment, process_type if so use that rate rather
   -- rederiving the rate for the current contribution.

   l_rate_value := get_cached_rate(p_assignment_id,l_contribution_usage_id, p_tax_unit_id,
                                   l_contribution_code, l_code_rate_id, l_rate_type);
   if l_rate_value is null then -- { no cached rate
      hr_utility.set_location('Entered '||l_proc,40);
      if p_override_rate is null then
      l_rate_value := get_rate_value(p_business_group_id,l_rate_type);
      else
      l_rate_value := p_override_rate;
      hr_utility.set_location('Using Override Rate Value:'||p_override_rate,80);
      end if;
      maintain_rate_cache(l_contribution_usage_id, p_tax_unit_id, l_contribution_code,
                          l_rate_value, l_code_rate_id, l_rate_type);
   end if;

   /* Round all money values to 2 d.p.   */
   l_contribution_value := round(p_base * (l_rate_value /100),2);


   p_rate := l_rate_value;
   p_contribution_usage_id := l_contribution_usage_id;
   p_contribution_code := l_contribution_code;

   -- output this line to g_summary_deductions plsql table
   hr_utility.set_location('calling maintain_summary_deduction. code_rate_id:'||to_char(l_code_rate_id),90);
   maintain_summary_deduction(
			  p_rate => l_rate_value
			, p_base_type => ltrim(l_base_name)
			, p_base => p_base
			, p_contribution_code => l_contribution_code
			, p_contribution_usage_id => l_contribution_usage_id
			, p_rate_type => ltrim(l_rate_type)
			, p_pay_value => l_contribution_value
			, p_rate_category => l_rate_category
			, p_user_column_instance_id => null
			, p_code_rate_id => l_code_rate_id
                        , p_element_name => l_element_name
			);


   hr_utility.set_location('Leaving '||l_proc||'. Value='||l_contribution_value,100);
   --hr_utility.set_location('Leaving '||l_proc||'. base='||to_char(p_base),101);
   --hr_utility.set_location('Leaving '||l_proc||'. rate='||to_char(p_rate),102);
   --hr_utility.set_location('Leaving '||l_proc||'. contribution_code='||p_contribution_code,103);
   --hr_utility.set_location('Leaving '||l_proc||'. contribution_usage_id='||to_char(p_contribution_usage_id),104);
   --hr_utility.set_location('Leaving '||l_proc||'. asg_id='||to_char(p_assignment_id),105);
   --hr_utility.set_location('Leaving '||l_proc||'. bg_id='||to_char(p_business_group_id),106);
   --hr_utility.set_location('Leaving '||l_proc||'. date_earned='||to_char(p_date_earned),107);
   --hr_utility.set_location('Leaving '||l_proc||'. element='||p_element_name,108);
   --hr_utility.set_location('Leaving '||l_proc||'. usage_type='||p_usage_type,109);

   return l_contribution_value;
end get_contribution_info;

function get_contribution_info(p_assignment_id         in number
                              ,p_business_group_id     in number
                              ,p_date_earned           in date
                              ,p_tax_unit_id           in number
                              ,p_element_name 	       IN varchar2
                              ,p_usage_type    	       IN varchar2
                              ,p_base 		       OUT NOCOPY number
                              ,p_rate 		       OUT NOCOPY number
                              ,p_contribution_usage_id OUT NOCOPY number
                              ,p_override_rate         in number default null)
return number
is
  l_contribution_code  pay_fr_contribution_usages.contribution_code%TYPE:=null;
begin
  return get_contribution_info(p_assignment_id
                              ,p_business_group_id
                              ,p_date_earned
                              ,p_tax_unit_id
                              ,p_element_name
                              ,p_usage_type
                              ,p_base
                              ,p_rate
                              ,l_contribution_code
                              ,p_contribution_usage_id
                              ,p_override_rate);
end get_contribution_info;
------------------------------------------------------------------------
-- Function GET_WORK_ACCIDENT_CONTRIBUTION
-- This will be used to obtain all the information about the given contribution element
-- i.e. Contribution amount, base value, rate value, usage_id an contribution code.
-- V115.16 Added parameters P_ASSIGNMENT_ID and P_RATE_TYPE so that previous run in period
-- rate_type can be determined and returned back to formula.
------------------------------------------------------------------------
function GET_WORK_ACCIDENT_CONTRIBUTION(P_ASSIGNMENT_ID            in number
                                       ,P_BUSINESS_GROUP_ID        in number
                                       ,P_DATE_EARNED              in date
                                       ,P_TAX_UNIT_ID              in number
                                       ,P_ELEMENT_NAME             IN varchar2
                                       ,P_USAGE_TYPE               IN varchar2
                                       ,P_RISK_CODE                in Varchar2
                                       ,P_BASE                     out nocopy number
                                       ,P_RATE                     out nocopy number
                                       ,P_RATE_TYPE                out nocopy varchar2
                                       ,P_CONTRIBUTION_CODE        out nocopy varchar2
                                       ,P_CONTRIBUTION_USAGE_ID    out nocopy number
                                       ,P_REDUCTION_PERCENT        in number default null) return number
is


   l_group_code         varchar2(30);
   l_contribution_value number;
   l_rate_value         number;
   l_contribution_usage_id number;
   l_contribution_code  varchar2(30);
   l_contribution_type  varchar2(10);
   l_base_name          varchar2(30);
   l_risk_code          varchar2(30);
   l_user_column_instance_id number;
   l_user_row_id number;
   l_rate_category      varchar2(1);
   l_element_name       pay_fr_contribution_usages.element_name%type;

   l_contribution_usage_row pay_fr_contribution_usages%rowtype := get_contribution_usage(
			 p_process_type => g_process_type
			,p_element_name => p_element_name
			,p_usage_type	 => p_usage_type
                       ,p_effective_date => p_date_earned);

  l_proc varchar2(72) := g_package||'.GET_WORK_ACCIDENT_CONTRIBUTION';
  --
begin
   --
   hr_utility.set_location('Entered '||l_proc,5);

   hr_utility.set_location('.  element name='||p_element_name,10);

   l_group_code := l_contribution_usage_row.group_code;
   l_contribution_code := l_contribution_usage_row.contribution_code;
   l_contribution_usage_id := l_contribution_usage_row.contribution_usage_id;
   l_contribution_type := l_contribution_usage_row.contribution_type;
   l_rate_category := l_contribution_usage_row.rate_category;
   l_risk_code := p_risk_code;
   l_element_name := l_contribution_usage_row.element_name;

   /* Call function to substitute base code into contribution code */
   l_contribution_code := sub_contrib_code(p_contribution_type => l_contribution_type
                                          ,p_contribution_code => l_contribution_code);

   hr_utility.set_location('Found element info.code:'||l_contribution_code,20);
   hr_utility.set_location('.    group code:'||l_group_code,30);

   -- check to see if this rate has been used for this assignment in previous subruns
   -- for this assignment, establishment, process_type if so use that rate rather
   -- rederiving the rate for the current contribution.

   l_rate_value := get_cached_rate(p_assignment_id,l_contribution_usage_id, p_tax_unit_id,
                                   l_contribution_code, l_user_column_instance_id, l_risk_code);
   if l_rate_value is null then -- { no cached rate
      hr_utility.set_location('Entered '||l_proc,40);

   begin
      l_rate_value := get_table_rate(p_bus_group_id => p_business_group_id
                           ,p_table_name => 'FR_WORK_ACCIDENT_RATES'
			   ,p_row_value   => l_risk_code
                           ,p_user_column_instance_id => l_user_column_instance_id
                           ,p_user_row_id => l_user_row_id);
   exception
      when no_data_found then
         fnd_message.set_name('PAY','PAY_74933_SD_NO_WRK_ACC_RATE');
         fnd_message.set_token('RISK_CODE',l_risk_code);
         fnd_message.raise_error;
   end;
   maintain_rate_cache(l_contribution_usage_id, p_tax_unit_id, l_contribution_code,
                          l_rate_value,l_user_column_instance_id, l_risk_code);
   end if; -- } no cached rate
   hr_utility.set_location('Rate value: '||l_rate_value,40);
   hr_utility.set_location('l_contribution_code: '||l_contribution_code,40);

   l_base_name := get_base_name(p_business_group_id, l_group_code);

   p_base := get_base_value(l_base_name);

  /* Reduce the rate value by the reduction amount.  Used for Part Time Rebate reduction */
   if p_reduction_percent is not null then
        l_rate_value := l_rate_value * ((100-p_reduction_percent) /100);
        hr_utility.set_location('reduced Rate value: '||l_rate_value,42);
   end if;

   l_contribution_value := round(p_base * (l_rate_value /100),2);

   p_rate := l_rate_value;
   p_rate_type := l_risk_code;
   p_contribution_usage_id := l_contribution_usage_id;
   p_contribution_code := l_contribution_code;

   -- output this line to g_summary_deductions plsql table
   hr_utility.set_location('calling maintain_summary_deduction. user_col_instance_id:'||to_char(l_user_column_instance_id),90);
   maintain_summary_deduction(
			  p_rate => l_rate_value
			, p_base_type => l_base_name
			, p_base => p_base
			, p_contribution_code => l_contribution_code
			, p_contribution_usage_id => l_contribution_usage_id
			, p_rate_type => p_rate_type
			, p_pay_value => l_contribution_value
			, p_rate_category => 'W'
			, p_user_column_instance_id => l_user_column_instance_id
			, p_code_rate_id => null
                        , p_element_name => l_element_name
			);

   hr_utility.set_location('Leaving '||l_proc||'. Value='||l_contribution_value,100);

   return l_contribution_value;

end get_work_accident_contribution;


------------------------------------------------------------------------
-- Function GET_TRANSPORT_TAX_CONTRIBUTION
-- This will be used to obtain all the information about the given contribution element
-- i.e. Contribution amount, base value, rate value, usage_id an contribution code.
------------------------------------------------------------------------
function GET_TRANSPORT_TAX_CONTRIBUTION(P_ASSIGNMENT_ID in NUMBER
				       ,P_BUSINESS_GROUP_ID    in number
                                       ,p_date_earned          in date
 				       ,P_TAX_UNIT_ID          in number
                                       ,P_ELEMENT_NAME         in varchar2
                                       ,P_USAGE_TYPE           IN varchar2
                                       ,P_TRANSPORT_TAX_REGION in varchar2
                                       ,P_REDUCTION            in number
                                       ,P_BASE                 out nocopy number
                                       ,P_RATE                 out nocopy number
                                       ,P_CONTRIBUTION_CODE     out nocopy varchar2
                                       ,P_CONTRIBUTION_USAGE_ID out nocopy number) return number
is

   l_group_code         varchar2(30);
   l_contribution_value number;
   l_rate_value         number;
   l_contribution_usage_id number;
   l_contribution_code  varchar2(30);
   l_contribution_type  varchar2(10);
   l_base_name          varchar2(30);
   l_user_column_instance_id number;
   l_user_row_id        number;
   l_rate_category      varchar2(1);
   l_element_name       pay_element_types_f.element_name%type;
   l_transport_tax_region varchar2(80);

   l_contribution_usage_row pay_fr_contribution_usages%rowtype := get_contribution_usage(
			p_process_type => g_process_type
			,p_element_name => p_element_name
			,p_usage_type	 => p_usage_type
                       ,p_effective_date => p_date_earned);

  l_proc varchar2(72) := g_package||'.GET_TRANSPORT_TAX_CONTRIBUTION';
  --
begin
   --
   hr_utility.set_location('Entered '||l_proc,5);

   l_group_code := l_contribution_usage_row.group_code;
   l_contribution_code := l_contribution_usage_row.contribution_code;
   l_contribution_usage_id := l_contribution_usage_row.contribution_usage_id;
   l_contribution_type := l_contribution_usage_row.contribution_type;
   l_rate_category := l_contribution_usage_row.rate_category;
   l_element_name  := l_contribution_usage_row.element_name;
   l_transport_tax_region := p_transport_tax_region;

   hr_utility.set_location('element info code:'||l_contribution_code,20);
   hr_utility.set_location('.    group code:'||l_group_code,30);
   hr_utility.set_location('Transport Tax Region:'||p_transport_tax_region,40);
   hr_utility.set_location('Transport Tax Reduction:'||p_reduction,41);

   /* Call function to substitute base code into contribution code */
   l_contribution_code := sub_contrib_code(p_contribution_type => l_contribution_type
                                          ,p_contribution_code => l_contribution_code);

   -- check to see if this rate has been used for this assignment in previous subruns
   -- for this assignment, establishment if so use that rate rather
   -- rederiving the rate for the current contribution.

   l_rate_value := get_cached_rate(p_assignment_id,l_contribution_usage_id, p_tax_unit_id,
                                   l_contribution_code, l_user_column_instance_id, l_transport_tax_region);
   if l_rate_value is null then -- { no cached rate
      hr_utility.set_location('Entered '||l_proc,50);


   	begin
   	l_rate_value := get_table_rate(p_bus_group_id => p_business_group_id
                           ,p_table_name  => 'FR_TRANSPORT_TAX_RATES'
			   ,p_row_value   => p_transport_tax_region
                           ,p_user_row_id => l_user_row_id
                           ,p_user_column_instance_id => l_user_column_instance_id);
  	 exception
      		when no_data_found then
         	fnd_message.set_name('PAY','PAY_74934_SD_NO_TRNS_TAX_RATE');
         	fnd_message.set_token('TRNS_TAX_REGION',p_transport_tax_region);
         	fnd_message.raise_error;
  	 end;
   	maintain_rate_cache(l_contribution_usage_id, p_tax_unit_id, l_contribution_code,
        	                  l_rate_value,l_user_column_instance_id, l_transport_tax_region);
   end if; -- } no cached rate

   hr_utility.set_location('Rate value: '||l_rate_value,60);

   if p_reduction <> 0 then
        l_rate_value := l_rate_value * ((100-p_reduction) /100);
        hr_utility.set_location('reduced Rate value: '||l_rate_value,65);
   end if;

   l_base_name := get_base_name(p_business_group_id, l_group_code);

   p_base := get_base_value(l_base_name);

   l_contribution_value := round(p_base * (l_rate_value /100),2);

   p_rate := l_rate_value;
   p_contribution_usage_id := l_contribution_usage_id;
   p_contribution_code := l_contribution_code;

   hr_utility.set_location('Leaving '||l_proc||'. Value='||l_contribution_value,100);

   -- output this line to g_summary_deductions plsql table
   hr_utility.set_location('calling maintain_summary_deduction. user_col_instance_id:'||to_char(l_user_column_instance_id),90);
   maintain_summary_deduction(
			  p_rate => l_rate_value
			, p_base_type => l_base_name
			, p_base => p_base
			, p_contribution_code => l_contribution_code
			, p_contribution_usage_id => l_contribution_usage_id
			, p_rate_type => p_transport_tax_region
			, p_pay_value => l_contribution_value
			, p_rate_category => 'T'
			, p_user_column_instance_id => l_user_column_instance_id
			, p_code_rate_id => null
                        , p_element_name => l_element_name
			);

   return l_contribution_value;

end get_transport_tax_contribution;

------------------------------------------------------------------------
-- Function GET_FIXED_VALUE_CONTRIBUTION
-- Some contributions are paid at a fixed value and therefore do not have a rate
-- or base.  Only the value and contribution usage id and code are obtained
------------------------------------------------------------------------
function get_fixed_value_contribution(P_BUSINESS_GROUP_ID    in number
                                ,p_date_earned          in date
                                ,p_element_name          IN varchar2
                                ,p_usage_type    	 IN varchar2
				,p_contribution_code 	 OUT NOCOPY varchar2
				,p_contribution_usage_id OUT NOCOPY number) return number
is
   l_rate_value            number;
   l_rate_type             varchar2(80);
   l_contribution_usage_id number;
   l_contribution_code     varchar2(30);
   l_contribution_type    varchar2(10);

   l_contribution_usage_row pay_fr_contribution_usages%rowtype := get_contribution_usage(
                         p_business_group_id    => p_business_group_id
			,p_process_type 	=> g_process_type
			,p_element_name 	=> p_element_name
			,p_usage_type	 	=> p_usage_type
                        ,p_effective_date 	=> p_date_earned);

  l_proc varchar2(72) := g_package||'.get_fixed_value_contribution';
  --
begin
   --
   hr_utility.set_location('Entered '||l_proc,5);

   l_rate_type := l_contribution_usage_row.rate_type;
   l_contribution_code := l_contribution_usage_row.contribution_code;
   l_contribution_usage_id := l_contribution_usage_row.contribution_usage_id;
   l_contribution_type := l_contribution_usage_row.contribution_type;

   /* Call function to substitute base code into contribution code */
   l_contribution_code := sub_contrib_code(p_contribution_type => l_contribution_type
                                          ,p_contribution_code => l_contribution_code);

   hr_utility.set_location('Found element info.code:'||l_contribution_code,15);
   hr_utility.set_location('.     rate type:'||l_rate_type,25);

   l_rate_value := get_rate_value(p_business_group_id,l_rate_type);

   p_contribution_usage_id := l_contribution_usage_id;
   p_contribution_code := l_contribution_code;

   hr_utility.set_location('Leaving '||l_proc||'. Value='||l_rate_value,100);

   return l_rate_value;
end get_fixed_value_contribution;

------------------------------------------------------------------------
-- Function GET_REDUCED_CONTRIBUTION
-- This function is used to obtain contribution information for those
-- contributions that can be reduced by a given reduction percentage
------------------------------------------------------------------------
function get_reduced_contribution(P_BUSINESS_GROUP_ID    in number
                                ,p_date_earned          in date
                                ,P_ELEMENT_NAME IN varchar2
				,P_USAGE_TYPE IN varchar2
                                ,p_reduction  in number
                                ,P_BASE out nocopy number
                                ,P_RATE out nocopy number
                                ,P_CONTRIBUTION_CODE in out nocopy varchar2
                                ,P_CONTRIBUTION_USAGE_ID out nocopy number) return number
is
   l_group_code           varchar2(30);
   l_contribution_value   number;
   l_rate_value           number;
   l_rate_type            varchar2(80);
   l_contribution_code     varchar2(30);
   l_contribution_usage_id number;
   l_contribution_type     varchar2(10);
   l_base_name             varchar2(30);

   l_contribution_usage_row pay_fr_contribution_usages%rowtype := get_contribution_usage(
			 p_process_type => g_process_type
			,p_element_name => p_element_name
			,p_usage_type	 => p_usage_type
                       ,p_effective_date => p_date_earned);

  l_proc varchar2(72) := g_package||'.get_reduced_contribution';
  --
begin
   --
   hr_utility.set_location('Entered '||l_proc,5);

   hr_utility.set_location('. element:'||p_element_name,10);

   l_group_code := l_contribution_usage_row.group_code;
   l_rate_type := l_contribution_usage_row.rate_type;
   l_contribution_code := l_contribution_usage_row.contribution_code;
   l_contribution_usage_id := l_contribution_usage_row.contribution_usage_id;
   l_contribution_type := l_contribution_usage_row.contribution_type;

   /* Call function to substitute base code into contribution code */
   if l_contribution_code is not null then
      l_contribution_code := sub_contrib_code(
                                p_contribution_type => l_contribution_type
                               ,p_contribution_code => l_contribution_code);
   elsif p_contribution_code is not null then
      -- use template code passed in, with extra validation
      l_contribution_code := substitute_code(p_contribution_code);
   end if;

   hr_utility.set_location('Found element info.code:'||l_contribution_code,20);
   hr_utility.set_location('.    Rate type:'||l_rate_type,25);
   hr_utility.set_location('.    Group code:'||l_group_code,30);


   l_base_name := get_base_name(p_business_group_id, l_group_code);

   p_base := get_base_value(l_base_name);

   l_rate_value := get_rate_value(p_business_group_id,l_rate_type);

   /* Reduce the rate value by the reduction amount i.e. Post the reduced rate value */
   if p_reduction <> 0 then
        l_rate_value := l_rate_value * ((100-p_reduction) /100);
        hr_utility.set_location('reduced Rate value: '||l_rate_value,45);
   end if;

   l_contribution_value := round(p_base * (l_rate_value /100),2);

   p_rate := l_rate_value;
   p_contribution_usage_id := l_contribution_usage_id;
   p_contribution_code := l_contribution_code;

   hr_utility.set_location('Leaving '||l_proc||'. Value='||l_contribution_value,100);

   return l_contribution_value;

end get_reduced_contribution;

function get_reduced_contribution(P_BUSINESS_GROUP_ID    in number
                                ,p_date_earned          in date
                                ,P_ELEMENT_NAME IN varchar2
				,P_USAGE_TYPE IN varchar2
                                ,p_reduction  in number
                                ,P_BASE out nocopy number
                                ,P_RATE out nocopy number
                                ,P_CONTRIBUTION_USAGE_ID out nocopy number)
return number
is
  l_contribution_code  pay_fr_contribution_usages.contribution_code%TYPE:=null;
begin
  return get_reduced_contribution(p_business_group_id
                                ,p_date_earned
                                ,p_element_name
				,p_usage_type
                                ,p_reduction
                                ,p_base
                                ,p_rate
                                ,l_contribution_code
                                ,p_contribution_usage_id);
end get_reduced_contribution;
------------------------------------------------------------------------
-- Function CONVERT_HOURS
------------------------------------------------------------------------
function convert_hours(p_effective_date         in date
                      ,p_business_group_id      in number
                      ,p_assignment_id          in number
                      ,p_hours          	in number
                      ,p_from_freq_code 	in varchar2
                      ,p_to_freq_code   	in varchar2) return number
IS
--
  l_hours_in_days   	number;
  l_hours_in_weeks  	number;
  l_hours_in_months 	number;
  l_hours_in_years  	number;
  l_hours_in_day 	number := 7;
  l_days_in_week	number := 5;
  l_months_in_year	number := 12;
  l_weeks_in_year   	number := 52;
  l_weeks_in_month	number := l_weeks_in_year/l_months_in_year;
  l_inputs              ff_exec.inputs_t;
  l_outputs             ff_exec.outputs_t;
  l_formula_id		number;
  l_start_date		date;
  l_hourly_value        number;
  --
  l_proc varchar2(72) := g_package||'.convert_hours';
  --
--
begin
  --
  hr_utility.set_location('Entered '||l_proc,8);
  --
  /* Check if a user formula exists - if it does then use values from that, otherwise use defaults
      set above */
  --
  /* This function call returns -1 if the formula was not found */
  l_formula_id := get_formula_info
			(p_formula_name   => 'USER_CONVERT_HOURS'
			,p_effective_date => p_effective_date
                        ,p_business_group_id  => p_business_group_id
                        ,p_effective_start_date => l_start_date);

  If l_formula_id <> -1 then
     -- Initialise the formula
     ff_exec.init_formula (l_formula_id,
                           l_start_date,
                           l_inputs,
                           l_outputs);
     --
     -- populate input parameters
     for i in l_inputs.first..l_inputs.last loop
         if l_inputs(i).name = 'HOURS' then
            l_inputs(i).value := p_hours;
         elsif l_inputs(i).name = 'FROM_FREQ_CODE' then
            l_inputs(i).value := p_from_freq_code;
         elsif l_inputs(i).name = 'TO_FREQ_CODE' then
            l_inputs(i).value := p_to_freq_code;
         elsif l_inputs(i).name = 'DATE_EARNED' then
            l_inputs(i).value := fnd_date.date_to_canonical(p_effective_date);
         elsif l_inputs(i).name = 'ASSIGNMENT_ID' then
            l_inputs(i).value := p_assignment_id;
         else
            hr_utility.set_location('ERROR value = '||l_inputs(i).name ,7);
         end if;
     end loop;
     --
     hr_utility.set_location(' Prior to execute the formula',8);
     ff_exec.run_formula (l_inputs
                         ,l_outputs);
     --
     hr_utility.set_location(' End run formula',9);
     --
     for l_out_cnt in l_outputs.first..l_outputs.last loop
         if l_outputs(l_out_cnt).name = 'P_HOURLY_VALUE' then
            l_hourly_value := l_outputs(l_out_cnt).value;
         end if;
     end loop;
     --
     return l_hourly_value;
     --
  Else
     --
     if p_from_freq_code = 'D' then
        l_hours_in_days   	:= p_hours;
        l_hours_in_weeks  	:= p_hours*l_days_in_week;
        l_hours_in_months 	:= l_hours_in_weeks*l_weeks_in_month;
        l_hours_in_years  	:= l_hours_in_months*l_months_in_year;
     elsif p_from_freq_code = 'W' then
        l_hours_in_weeks  	:= p_hours;
        l_hours_in_months 	:= l_hours_in_weeks*l_weeks_in_month;
        l_hours_in_years  	:= l_hours_in_months*l_months_in_year;
        l_hours_in_days   	:= l_hours_in_weeks/l_days_in_week;
     elsif p_from_freq_code = 'M' then
        l_hours_in_months 	:= p_hours;
        l_hours_in_years  	:= l_hours_in_months*l_months_in_year;
        l_hours_in_weeks  	:= l_hours_in_months/l_weeks_in_month;
        l_hours_in_days   	:= l_hours_in_weeks/l_days_in_week;
     elsif p_from_freq_code = 'Y' then
        l_hours_in_years  	:= p_hours;
        l_hours_in_months 	:= l_hours_in_years*l_months_in_year;
        l_hours_in_weeks  	:= l_hours_in_months/l_weeks_in_month;
        l_hours_in_days   	:= l_hours_in_weeks/l_days_in_week;
     else
        fnd_message.set_name('PAY','PAY_74922_SD_BAD_CONV_HRS_FREQ');
        fnd_message.set_token('FREQ',p_from_freq_code);
        fnd_message.raise_error;
        hr_utility.set_location('Error - p_from_freq_code not recognised',10);
     end if;
     --
  End If;
  --
  hr_utility.set_location('Leaving '||l_proc,100);
  --
  if p_to_freq_code = 'D' then
     return l_hours_in_day;
  elsif p_to_freq_code = 'W' then
     return l_hours_in_weeks;
  elsif p_to_freq_code = 'M' then
     return l_hours_in_months;
  elsif p_to_freq_code = 'Y' then
     return l_hours_in_years;
  end if;
  --
end convert_hours;
--
------------------------------------------------------------------------
-- Function GET_MONTHLY_HOURS
-- This function determines returns global g_monthly_hours
-- which has been set in function initialize_payroll
------------------------------------------------------------------------
function get_monthly_hours return number is
begin
  --
  return pay_fr_general.g_monthly_hours;
  --
end get_monthly_hours;
--
------------------------------------------------------------------------
-- Function GET_PAY_RATE
-- This function determines whether a user defined formula passed in as a
-- parameter exists, if it does it executes it to retrieve the
-- hourly rate.
-- Otherwise it determines the hourly rate from the employees salary basis
-- record (using the normal working hours to determine an hourly rate).
------------------------------------------------------------------------
function get_pay_rate(p_assignment_id in number
                     ,p_business_group_id in number
                     ,p_effective_date in date
                     ,p_formula varchar2 default 'FR_USER_HOURLY_RATE'
                     ,p_parameter_list varchar2 default null) return number is
l_hourly_rate number;
l_pay_rate number;
l_pay_basis varchar2(30);
l_normal_hours number;
l_frequency varchar2(30);
--
l_list varchar2(2000);
l_param varchar2(2000);
l_param_end number;
j number;
--
TYPE param_rec_type is RECORD
(name varchar2(200)
,value varchar2(200));
--
TYPE param_tab_type is TABLE of param_rec_type index by BINARY_INTEGER;
--
param_tab param_tab_type;
--

--
l_inputs                ff_exec.inputs_t;
l_outputs               ff_exec.outputs_t;
l_formula_id          number;
l_start_date          date;
--
l_proc varchar2(72) := g_package||'.get_pay_rate';
--

cursor c_pay_rate is
select ee.screen_entry_value
,      b.pay_basis
-- commented as part of time analysis changes
--,    a.normal_hours
--,    a.frequency
,      decode(pcf.ctr_information12, 'HOUR', fnd_number.canonical_to_number(pcf.ctr_information11), a.normal_hours) normal_hours
,      decode(pcf.ctr_information12, 'HOUR', pcf.ctr_information13, a.frequency) frequency
from pay_element_entry_values_f ee
,    pay_element_entries_f e
,    per_all_assignments_f a
,    per_pay_bases b
--
,    per_contracts_f pcf
--
where a.assignment_id = p_assignment_id
and a.assignment_id = e.assignment_id
and e.element_entry_id = ee.element_entry_id
and ee.input_value_id = b.input_value_id
and a.pay_basis_id = b.pay_basis_id
and b.pay_basis in ('HOURLY','MONTHLY','ANNUAL')
--
and pcf.contract_id = a.contract_id
--
and p_effective_date between a.effective_start_date and a.effective_end_date
and p_effective_date between e.effective_start_date and e.effective_end_date
and p_effective_date between ee.effective_start_date and ee.effective_end_date
--
and p_effective_date between pcf.effective_start_date and pcf.effective_end_date;
--
begin
  hr_utility.set_location(l_proc,10);
--
/* If there is a formula in the business group named FR_USER_HOURLY_RATE then this will be used */
--
    /* This function call returns -1 if the formula was not found */
  l_formula_id := get_formula_info
			(p_formula_name   => p_formula
			,p_effective_date => p_effective_date
                        ,p_business_group_id  => p_business_group_id
                        ,p_effective_start_date => l_start_date);

  If l_formula_id <> -1 then
  hr_utility.set_location(l_proc,20);
     -- IF parameter list is not null Extract parameters from parameter list
     -- Parameters are in the format P1=P1_VALUE,P2=P2_VALUE
     --
     if p_parameter_list is not null then
        j := 1;
        l_list := p_parameter_list;
        while true loop   -- loop while list is not null
        if length(l_list) > 0 then
           l_param_end := instr(l_list,',');
           if l_param_end > 0 then -- this is not the last parameter
              l_param := substr(l_list,1,l_param_end);
              l_list := substr(l_list,l_param_end+1,length(l_list));
           else -- last parameter
              l_param := l_list||',';
              l_list := null;
           end if;
           l_param := substr(l_param,1,length(l_param)-1);
           param_tab(j).name := substr(l_param,1,instr(l_param,'=')-1);
           param_tab(j).value :=
                  substr(l_param,instr(l_param,'=')+1,length(l_param));
hr_utility.trace(p_formula||' '|| param_tab(j).name||' '||param_tab(j).value);
        else
           exit;
        end if;
        j := j + 1;
        end loop;
     end if;
     -- Initialise the formula
     ff_exec.init_formula (l_formula_id,
                           l_start_date,
                           l_inputs,
                           l_outputs);
     --
     -- populate input parameters
    if (l_inputs.first is not null) and (l_inputs.last is not null) then
       for i in l_inputs.first..l_inputs.last loop
          if l_inputs(i).name = 'ASSIGNMENT_ID' then
             l_inputs(i).value := p_assignment_id;
          elsif l_inputs(i).name = 'DATE_EARNED' then
             l_inputs(i).value := fnd_date.date_to_canonical(p_effective_date);
          elsif l_inputs(i).name = 'BUSINESS_GROUP_ID' then
             l_inputs(i).value := p_business_group_id;
          end if;
          if j > 1 then
             for x in 1..j-1 loop
                 if l_inputs(i).name = param_tab(x).name then
                    l_inputs(i).value := param_tab(x).value;
                    exit;
                 end if;
             end loop;
          end if;
       end loop;
    end if;
     --
     hr_utility.set_location(' Prior to execute the formula',8);
  hr_utility.set_location(l_proc,30);
     ff_exec.run_formula (l_inputs
                         ,l_outputs);
     --
  hr_utility.set_location(l_proc,40);
     hr_utility.set_location(' End run formula',9);
     --
     for l_out_cnt in l_outputs.first..l_outputs.last loop
         if l_outputs(l_out_cnt).name = 'HOURLY_PAY_RATE' then
            l_hourly_rate := l_outputs(l_out_cnt).value;
         end if;
     end loop;
     --
  else
     /* User formula not found so try to derive the hourly rate from Salary Admin */
     --
     hr_utility.set_location(l_proc,50);
     --
     open c_pay_rate;
     fetch c_pay_rate into l_pay_rate,
                           l_pay_basis,
                           l_normal_hours,
                           l_frequency;
     if c_pay_rate%found then
     close c_pay_rate;
     if l_pay_basis = 'HOURLY' then
        --
        hr_utility.set_location(l_proc,60);
        --
        l_hourly_rate := l_pay_rate;
        --
     elsif l_pay_basis = 'MONTHLY' then
        --
        hr_utility.set_location(l_proc,70);
        --
        /* Convert the normal working hours into a monthly figure so that
           it can be compared with the Monthly salary basis */
        --
        if l_normal_hours is not null and l_frequency is not null then
           l_normal_hours := pay_fr_general.convert_hours(p_effective_date
                                      ,p_business_group_id
                                      ,p_assignment_id
                                      ,l_normal_hours
                                      ,l_frequency
                                      ,'M');
           l_hourly_rate := l_pay_rate / l_normal_hours;
        end if;
        --
     elsif l_pay_basis = 'ANNUAL' then
        --
        hr_utility.set_location(l_proc,80);
        --
        /* Convert the normal working hours into an annual figure so that
           it can be compared with the Annual salary basis */
        --
        if l_normal_hours is not null and l_frequency is not null then
           l_normal_hours := pay_fr_general.convert_hours(p_effective_date
                                      ,p_business_group_id
                                      ,p_assignment_id
                                      ,l_normal_hours
                                      ,l_frequency
                                      ,'Y');
           l_hourly_rate := l_pay_rate / l_normal_hours;
        end if;
     end if;
     --
     else -- c_pay_rate%notfound
        hr_utility.set_location(l_proc,90);
        close c_pay_rate;
     end if;
 end if; -- Formula_ID <> -1
--
/* If the hourly rate is not null then return it otherwise raise an error */
--
  if l_hourly_rate is not null then
     return l_hourly_rate;
  else
        hr_utility.set_location(l_proc,100);
        fnd_message.set_name('PAY','PAY_HOURLY_RATE_NOT_DERIVED');
        fnd_message.raise_error;
  end if;
end get_pay_rate;
--
------------------------------------------------------------------------
-- Function GET_PREV_START_END
-- This function determines the start and end date of the previous
-- period - these dates are assigned to global variable. They should only
-- be set whenever the payroll action id has changed.
------------------------------------------------------------------------
function get_prev_start_end (p_payroll_action_id in     number
                            ,p_start_date        in out nocopy date
                            ,p_end_date          in out nocopy date) return number is
--
  cursor csr_get_time_period is
    select ptp2.start_date,
           ptp2.end_date
    from   per_time_periods ptp,
           pay_payroll_actions ppa,
           per_time_periods ptp2
    where  ppa.date_earned BETWEEN ptp.START_DATE and ptp.END_DATE
      and  ppa.payroll_action_id = p_payroll_action_id
      and  ptp.payroll_id = ppa.payroll_id
      and  ptp2.end_date = ptp.start_date - 1
      and  ptp2.payroll_id = ppa.payroll_id;
--
  l_proc varchar2(72) := g_package||'.get_prev_start_end';
--
begin
  --
  hr_utility.set_location('Entering '||l_proc,10);
  --
  if p_payroll_action_id <> nvl(pay_fr_general.g_payroll_action_id,-1) then
     --
     open csr_get_time_period;
     fetch csr_get_time_period into p_start_date,p_end_date;
     if csr_get_time_period%found then
        pay_fr_general.g_payroll_action_id := p_payroll_action_id;
        close csr_get_time_period;
        return 0;
     else
        close csr_get_time_period;
        return 1;
     end if;
     --
  else
     return 0;
  end if;
  --
end get_prev_start_end;
--

------------------------------------------------------------------------
-- Function SUBSTITUTE_CODE
-- A function that can be called from fast formula.  It will call
-- sub_contrib_code if a valid contribution code is passed into this function
------------------------------------------------------------------------
function substitute_code(p_contribution_code in varchar2) return varchar2
IS
--
   l_code_prefix       varchar2(1);
   l_code_error_mesg   varchar2(30) := 'VALID';
   l_contrib_code      varchar2(30);
   l_proc varchar2(72) := g_package||'.substitute_code';
   --
begin
   --
   hr_utility.set_location('Entered '||l_proc,5);
   --
   l_code_prefix := SUBSTR(p_contribution_code,1,1);

   if l_code_prefix = '3' then
      if substr(p_contribution_code,2,4) = 'XXXX' then
         l_contrib_code := sub_contrib_code(p_contribution_type => 'AGIRC'
                                  ,p_contribution_code => p_contribution_code);
      else
         l_code_error_mesg := 'PAY_74906_CNU_BAD_AGIRC';
      end if;
   elsif l_code_prefix = '4' then
      if substr(p_contribution_code,2,4) = 'XXXX' then
         l_contrib_code := sub_contrib_code(p_contribution_type => 'ARRCO'
                                  ,p_contribution_code => p_contribution_code);
      else
         l_code_error_mesg := 'PAY_74907_CNU_BAD_ARRCO';
      end if;
   elsif l_code_prefix = '1' then
      if substr(p_contribution_code,2,2) = 'XX' then
         l_contrib_code := sub_contrib_code(p_contribution_type => 'URSSAF'
                                  ,p_contribution_code => p_contribution_code);
      else
         l_code_error_mesg := 'PAY_74904_CNU_BAD_URSSAF';
      end if;
   elsif l_code_prefix = '2' then
      if substr(p_contribution_code,2,1) = 'X' then
         l_contrib_code := sub_contrib_code(p_contribution_type => 'ASSEDIC'
                                  ,p_contribution_code => p_contribution_code);
      else
         l_code_error_mesg := 'PAY_74905_CNU_BAD_ASSEDIC';
      end if;
   else   /* code is other type and cannot be substituted or is null */
      l_contrib_code := p_contribution_code;
   end if;


   if l_code_error_mesg = 'VALID' then
      return l_contrib_code;
   else
      hr_utility.set_location('Error:'||l_code_error_mesg,100);
      fnd_message.set_name('PAY',l_code_error_mesg);
      fnd_message.raise_error;
   end if;

end substitute_code;
--
------------------------------------------------------------------------
-- Function FORMAT_NAME
-- A function that can be called from the Absence Report to format name.
------------------------------------------------------------------------
Function format_name(p_employee_id   IN  NUMBER) RETURN VARCHAR2
IS
   l_formatted_name varchar2(200);
   l_last_name varchar2(100);
   l_first_name varchar2(100);
   l_maiden_name varchar2(100);
   l_sex varchar2(3);
   l_marital_status varchar2(3);

   -- Cursor to fetch Sex and Marital Status of Employee
   CURSOR csr_person_info IS
     SELECT first_name,last_name,per_information1,sex,marital_status
     FROM per_all_people_f
     WHERE person_id = p_employee_id
     AND per_information_category ='FR';
   --
BEGIN

   OPEN csr_person_info;
   FETCH csr_person_info INTO l_first_name,l_last_name,l_maiden_name,l_sex,l_marital_status ;
   CLOSE csr_person_info;

   l_formatted_name := l_last_name||' '||l_first_name;

   IF l_sex = 'F' THEN

      IF l_marital_status = 'M' THEN  		-- Married
          l_formatted_name := l_maiden_name||' '||hr_general.decode_lookup('NAME_TRANSLATIONS','FR_EPOUSE')||' '||l_last_name||' '||l_first_name;

      ELSIF l_marital_status = 'W' THEN 	-- Widowed
          l_formatted_name := l_maiden_name ||' '||hr_general.decode_lookup('NAME_TRANSLATIONS','FR_VEUVE')||' '||l_last_name||' '||l_first_name;

      ELSE

          IF l_last_name = l_maiden_name THEN
              l_formatted_name := l_last_name||' '||l_first_name;
          ELSE
              l_formatted_name := l_maiden_name||' '||hr_general.decode_lookup('NAME_TRANSLATIONS','FR_NOM_D''USAGE') ||' '||l_last_name||' '||l_first_name;
          END IF;

       END IF;
  END IF;
  RETURN l_formatted_name;
END format_name;

-----------------------------------------------------------------------
-- Function FR_ROLLING_BALANCE
-- function to return rolling balance values
----------------------------------------------------------------------
Function fr_rolling_balance (p_assignment_id in number,
    		             p_balance_name in varchar2,
    		             p_balance_start_date in date,
    		             p_balance_end_date in date) return number
IS
Cursor csr_def_bal_id IS
   SELECT pdb.defined_balance_id
   FROM   pay_balance_types pbt,
          pay_balance_dimensions pbd,
          pay_defined_balances pdb
   WHERE  pdb.balance_type_id = pbt.balance_type_id
   AND    pdb.balance_dimension_id = pbd.balance_dimension_id
   AND    pbt.balance_name = p_balance_name
   AND    pbd.database_item_suffix = '_ASG_PTD'
   AND    pdb.legislation_code = 'FR';
--
l_defined_balance_id number;
l_start number := to_char(p_balance_start_date,'J');
l_end number := to_char(p_balance_end_date,'J');
i number        := 0;
l_value number  := 0;
l_proc               varchar2(72) := g_package||'fr_rolling_balance';

BEGIN
   hr_utility.set_location('Entering:'|| l_proc,10);
   open csr_def_bal_id;
   fetch csr_def_bal_id into l_defined_balance_id;
   close csr_def_bal_id;
   --
   while add_months(p_balance_start_date,i) <= p_balance_end_date loop
       BEGIN
         l_value := l_value +
                         pay_balance_pkg.get_value
                         (l_defined_balance_id
                         ,p_assignment_id
                         ,add_months(p_balance_start_date,i+1)-1);

       EXCEPTION
         WHEN NO_DATA_FOUND THEN  --Bug #2651568
         l_value := 0;
       END;
       i := i + 1;
       hr_utility.set_location(' BAL VAL='||l_value, 60);
     end loop;
     hr_utility.set_location(' FINAL BAL VAL='||l_value, 60);
   hr_utility.set_location(' Leaving:'||l_proc, 70);
   return l_value;

END;
---------------------------------------------------------------------
FUNCTION GET_SUMMARY_DEDUCTION
  (
     p_rate                     OUT NOCOPY NUMBER
   , p_base                     OUT NOCOPY NUMBER
   , p_contribution_code        OUT NOCOPY VARCHAR2
   , p_contribution_usage_id    OUT NOCOPY NUMBER
   , p_pay_value                OUT NOCOPY NUMBER
  )  return varchar2 is
-- function called from formula to fetch the next row from t_summary_deductions table
-- to return as results
l_proc               varchar2(72) := g_package||'.get_summary_deduction';
begin
hr_utility.set_location('Entering:'|| l_proc, 10);
   begin
   if g_summary_idx = 0 then p_pay_value := 0;
                        else p_pay_value := nvl(g_summary_deductions(g_summary_idx).pay_value,0);
      end if;
   g_summary_idx := g_summary_idx + 1;
   p_rate := g_summary_deductions(g_summary_idx).rate;
   p_base := g_summary_deductions(g_summary_idx).base;
   p_contribution_code := g_summary_deductions(g_summary_idx).contribution_code;
   p_contribution_usage_id := g_summary_deductions(g_summary_idx).contribution_usage_id;
   exception when no_data_found then
   hr_utility.set_location('No data found '|| l_proc, 20);
             p_rate := 0 ;
             p_base := 0;
             p_contribution_code := ' ';
             p_contribution_usage_id := 0;
   end;

hr_utility.trace('GET_SUMMARY_DEDUCTION.g_summary_idx:'||to_char(g_summary_idx));
hr_utility.trace('GET_SUMMARY_DEDUCTION.g_summary_deductions.last:'||to_char(g_summary_deductions.last));
hr_utility.trace('GET_SUMMARY_DEDUCTION.p_rate:'||to_char(p_rate));
hr_utility.trace('GET_SUMMARY_DEDUCTION.p_base:'||to_char(p_base));
hr_utility.trace('GET_SUMMARY_DEDUCTION.p_contribution_code:'||p_contribution_code);
hr_utility.trace('GET_SUMMARY_DEDUCTION.p_contribution_usage_id:'||to_char(p_contribution_usage_id));
hr_utility.trace('GET_SUMMARY_DEDUCTION.p_pay_value:'||to_char(p_pay_value));
-- if this is the last row in the table return a Y to stop processing, the indirect return is for the
-- next row so that context aren't changed the direct return is for index - 1 so test that
if g_summary_idx   = nvl(g_summary_deductions.last + 1,g_summary_idx ) then return 'Y';
   else return 'N';
end if;


hr_utility.set_location('Entering:'|| l_proc, 90);

end GET_SUMMARY_DEDUCTION;

PROCEDURE MAINTAIN_SUMMARY_DEDUCTION
  (
     p_rate                     IN NUMBER
   , p_base_type                IN VARCHAR2
   , p_base                     IN NUMBER
   , p_contribution_code        IN VARCHAR2
   , p_contribution_usage_id    IN NUMBER
   , p_rate_type                IN VARCHAR2
   , p_pay_value                IN NUMBER
   , p_rate_category            IN VARCHAR2
   , p_user_column_instance_id  IN NUMBER
   , p_code_rate_id             IN NUMBER
   , p_element_name             IN VARCHAR2
) is
-- check that this row doesn't already exist on the g_summary_deductions table
-- matching on base_type,  base and contribution code
-- if it does exist add the pay_value, rate and contribution_usage_id to that row
-- contribution_usage_id to add in the 2 to the power code_rate_id
-- if it doesn't exist then add as a new row.
-- special handling for Work Accident, Travel Tax rate identinfied by pay_fr_contribution_usages.rate_category
-- 'W', 'A' the contribution_usage_id for
-- work accident is set from the user_column_instance_id of udt  -
-- currently
l_proc               varchar2(72) := g_package||'.maintain_summary_deduction';
l_idx NUMBER := 0;
l_action varchar2(1) := 'I';

begin
-- the contribution_usage_id parameter is pay_fr_contribution_usages.contribution_usage_id
-- fetch the rate_category and rate_code_id from pay_fr_contribution_usages

-- loop through the table to see if the row already exists
-- for the matching row add in the pay_value, rate and the exponent value
-- error condition ?  analysis talks about trapping duplicate deduction

-- if it doen't exists then add new row
--
-- the only deductions going into summary table are rate based deductions
-- also T(ransport tax) and W(ork accident) are just inserted on the table - don't need to check
-- whether a row exists already
hr_utility.set_location('Entering:'|| l_proc, 10);

if p_rate <> 0 and p_base <> 0 and p_contribution_code is not null then -- { record summary

 if p_rate_category = 'C' then
    -- 115.48 This means the contribution code is not held on
    -- pay_fr_contribution_usages.  Insert into the table with
    -- contribution_usage_id set to -1*contribution_usage_id
    -- to allow the pay_fr_contribution_usages row to be identified later.
    hr_utility.set_location(l_proc, 20);
    l_idx := nvl(g_summary_deductions.last,0) + 1;
    g_summary_deductions(l_idx).base_type := p_base_type;
    g_summary_deductions(l_idx).base := p_base;
    g_summary_deductions(l_idx).Contribution_usage_id_type :=  p_rate_category;
    g_summary_deductions(l_idx).contribution_usage_id:=
                                                      -p_contribution_usage_id;
    g_summary_deductions(l_idx).pay_value := p_pay_value;
    g_summary_deductions(l_idx).rate_type := p_rate_type;
    g_summary_deductions(l_idx).rate := p_rate;
    g_summary_deductions(l_idx).contribution_code := p_contribution_code;
    g_summary_deductions(l_idx).retro := null;
 elsif p_rate_category not in ('T','W') then                     -- { code_rate_id deductions
hr_utility.set_location('Entering:'|| l_proc, 30);
    if p_code_rate_id is null then
         hr_utility.trace('No CODE_RATE_ID for p_contribution_usage_id:'||to_char(p_contribution_usage_id));
         fnd_message.set_name('PAY','PAY_75069_NO_CODE_RATE_ID');
         fnd_message.set_token('ELEMENT_NAME',p_element_name);
         fnd_message.raise_error;
    else  -- { all columns exists
--FOR 1 to nvl(g_summary_deductions.last,0)
    if g_summary_deductions.FIRST is not null then -- { empty table
        LOOP
        hr_utility.set_location('Entering:'|| l_proc, 40);
        l_idx := l_idx + 1;

        exit when l_action = 'U' or l_idx > nvl(g_summary_deductions.last,0);

        if g_summary_deductions(l_idx).base_type = p_base_type
        and g_summary_deductions(l_idx).base      = p_base
        and g_summary_deductions(l_idx).contribution_code = p_contribution_code
        and g_summary_deductions(l_idx).Contribution_usage_id_type =
                                                                p_rate_category
        then -- { matched row
                hr_utility.set_location('Entering:'|| l_proc, 50);
                l_action := 'U' ;
                g_summary_deductions(l_idx).rate := g_summary_deductions(l_idx).rate + p_rate;
                g_summary_deductions(l_idx).pay_value := g_summary_deductions(l_idx).pay_value + p_pay_value;
                g_summary_deductions(l_idx).contribution_usage_id := g_summary_deductions(l_idx).contribution_usage_id
                                                                 + power(2,p_code_rate_id);
        end if; -- } matched row

        end LOOP;

     end if; -- } empty table
--    if there wasn't a row to update then insert
    if l_action <> 'U' then -- { insert row
       hr_utility.set_location(l_proc, 60);
       l_idx := nvl(g_summary_deductions.last,0) + 1;
       g_summary_deductions(l_idx).base_type := p_base_type;
       g_summary_deductions(l_idx).base := p_base;
       g_summary_deductions(l_idx).Contribution_usage_id_type:=p_rate_category;
       g_summary_deductions(l_idx).contribution_usage_id := power(2,p_code_rate_id);
       g_summary_deductions(l_idx).pay_value := p_pay_value;
       g_summary_deductions(l_idx).rate_type := p_rate_type;
       g_summary_deductions(l_idx).rate := p_rate;
       g_summary_deductions(l_idx).contribution_code := p_contribution_code;
       g_summary_deductions(l_idx).retro := null;
     end if;  -- } insert row
  end if; -- } columns exist
  else -- }{ end code_rate_id, start user_column_instance_id
-- for T(ransport tax) and W(ork accident) deductions insert into the table with
-- contribution_usage_id set to user_column_instance_id
       hr_utility.set_location(l_proc, 70);
       l_idx := nvl(g_summary_deductions.last,0) + 1;
       hr_utility.trace('l_idx:'||to_char(l_idx));
       g_summary_deductions(l_idx).base_type := p_base_type;
       g_summary_deductions(l_idx).base := p_base;
       g_summary_deductions(l_idx).Contribution_usage_id_type := p_rate_category;
       g_summary_deductions(l_idx).contribution_usage_id := p_user_column_instance_id;
       g_summary_deductions(l_idx).pay_value := p_pay_value;
       g_summary_deductions(l_idx).rate_type := p_rate_type;
       g_summary_deductions(l_idx).rate := p_rate;
       g_summary_deductions(l_idx).contribution_code := p_contribution_code;
       g_summary_deductions(l_idx).retro := null;
  end if;  -- } code_rate_id deduction
end if; -- } record summary

       hr_utility.set_location('Leaving:'|| l_proc, 90);

end maintain_summary_deduction;

PROCEDURE MAINTAIN_RATE_CACHE
  (
     p_contribution_usage_id    IN NUMBER
   , p_tax_unit_id              IN NUMBER
   , p_contribution_code        IN VARCHAR2
   , p_rate_value               IN NUMBER
   , p_user_column_instance_id  IN NUMBER
   , p_risk_code                IN VARCHAR2
) is
-- insert into t_deduction_rates the current rate being used for this assignment
-- for a given contribution usage row.  Note that sometimes the variable component
-- of the contribution_code could change in a subsequent run of the same deduction
-- for the same assignment therefore to contribution code is also cached. If the
-- cached rate is used then the cached contribution code is used.
l_proc               varchar2(72) := g_package||'.maintain_rate_cache';
l_idx NUMBER := 0;

begin
hr_utility.set_location('Entering:'|| l_proc, 10);

       l_idx := nvl(g_deduction_rates.last,0) + 1;

       hr_utility.trace('p_contribution_usage_id:'||to_char(p_contribution_usage_id)||' l_idx:'||to_char(l_idx));

       g_deduction_rates(l_idx).contribution_usage_id := p_contribution_usage_id;
       g_deduction_rates(l_idx).tax_unit_id := p_tax_unit_id;
       g_deduction_rates(l_idx).contribution_code := p_contribution_code;
       g_deduction_rates(l_idx).rate := p_rate_value ;
       g_deduction_rates(l_idx).user_column_instance_id := p_user_column_instance_id ;
       g_deduction_rates(l_idx).risk_code := p_rate_value ;

       hr_utility.set_location('Leaving:'|| l_proc, 90);

end maintain_rate_cache;

FUNCTION GET_CACHED_RATE
  (
     p_assignment_id            IN NUMBER
   , p_contribution_usage_id    IN NUMBER
   , p_tax_unit_id              IN NUMBER
   , p_contribution_code        IN OUT nocopy VARCHAR2
   , p_user_column_instance_id  IN OUT nocopy NUMBER
   , p_risk_code                IN OUT nocopy VARCHAR2
) return number is
-- loop through g_deduction_rates plsql table to see if the rate has been
-- cached for this contribution_usage_id, tax_unit_id.  If it exists return
-- the cached rate with its contribution_code
l_proc               varchar2(72) := g_package||'.get_cached_rate';
l_idx NUMBER := 0;
l_rate number;
l_contribution_code VARCHAR2(30);

begin
-- the contribution_usage_id parameter is
-- pay_fr_contribution_usages.contribution_usage_id

hr_utility.set_location('Entering:'|| l_proc, 10);
    -- 115.46 Rate cache is now cleared on change of (grand) parent action
    -- within initialize_payroll()
    l_rate := NULL;

    if g_deduction_rates.FIRST is not null then -- { empty table
        LOOP
        -- hr_utility.set_location(l_proc||' loop:'||to_char(l_idx+1)||' thru deduction_rates table', 40);
        l_idx := l_idx + 1;

        exit when l_idx > nvl(g_deduction_rates.last,0) or l_rate is not null;

        if g_deduction_rates(l_idx).contribution_usage_id = p_contribution_usage_id and
           g_deduction_rates(l_idx).tax_unit_id      = p_tax_unit_id
                then -- { matched row
                hr_utility.set_location(l_proc||' rate in cache', 50);
                l_rate :=  g_deduction_rates(l_idx).rate ;
                p_contribution_code := g_deduction_rates(l_idx).contribution_code;
                p_user_column_instance_id := g_deduction_rates(l_idx).user_column_instance_id;
                p_risk_code := g_deduction_rates(l_idx).risk_code;

        end if; -- } matched row

        end LOOP;

     end if; -- } empty table
                hr_utility.set_location('leaving:'|| l_proc, 90);
RETURN l_rate;
end get_cached_rate;
--
Function get_table_rate (p_bus_group_id in number,
                         p_table_name in varchar2,
                         p_row_value in varchar2,
                         p_user_row_id             out NOCOPY number,
                         p_user_column_instance_id out NOCOPY number )
                         return number is
    l_effective_date date;
    l_table_id          pay_user_tables.user_table_id%type;
    l_value             pay_user_column_instances_f.value%type;
    l_user_column_instance_id pay_user_column_instances_f.user_column_instance_id%type;
    l_user_row_id 	pay_user_column_instances_f.user_row_id%type;
    l_proc              varchar2(72) := g_package||'.get_table_rate';


    --
    cursor csr_get_rate is

        select  CINST.value,
                CINST.user_column_instance_id,
                CINST.user_row_id
        from    pay_user_column_instances        CINST
        ,       pay_user_columns                 C
        ,       pay_user_rows                    R
        ,       pay_user_tables                  TAB
        where   TAB.user_table_name              = p_table_name
        and     C.user_table_id                  = TAB.user_table_id
        and     nvl (C.business_group_id,
                     p_bus_group_id)            = p_bus_group_id
        and     nvl (C.legislation_code,
                     'FR')                 = 'FR'
        and     C.user_column_name       = 'RATE'
        and     CINST.user_column_id             = C.user_column_id
        and     R.user_table_id                  = TAB.user_table_id
        and     nvl (R.business_group_id,
                     p_bus_group_id)             = p_bus_group_id
        and     nvl (R.legislation_code,
                     'FR')                 = 'FR'
        and     p_row_value = R.row_low_range_or_name
        and     CINST.user_row_id                = R.user_row_id
        and     nvl (CINST.business_group_id,
                     p_bus_group_id)             = p_bus_group_id
        and     nvl (CINST.legislation_code,
                     'FR')                 = 'FR';
        --
begin
        open csr_get_rate;
        fetch csr_get_rate into l_value, l_user_column_instance_id, l_user_row_id;
        close csr_get_rate;

        p_user_column_instance_id := l_user_column_instance_id;
        p_user_row_id  := l_user_row_id;
        return to_number(l_value);
      end;


FUNCTION COUNT_SUMMARY_DEDUCTIONS
    return number is
-- function called from formula to check that t_summary_deductions table
-- is not empty.  If not it contains rows then these need to be returned as
-- FR_SUMMARY_DEDUCTION results.
l_proc               varchar2(72) := g_package||'.count_summary_deductions';
l_count              number;

begin
hr_utility.set_location('Entering:'|| l_proc, 10);
   l_count :=  nvl(g_summary_deductions.count,0);
   hr_utility.trace('g_summary_deductions.count: '|| to_char(l_count));
   return l_count;

hr_utility.set_location('leaving:'|| l_proc, 90);

end COUNT_SUMMARY_DEDUCTIONS;

------------------------------------------------------------------------
end PAY_FR_GENERAL;

/
