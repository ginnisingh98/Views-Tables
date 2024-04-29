--------------------------------------------------------
--  DDL for Package Body PAY_PROCESSING_RULE_DATA_PUMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PROCESSING_RULE_DATA_PUMP" AS
/* $Header: pypprdpm.pkb 115.10 2004/02/25 21:48:19 adkumar noship $ */

------------------------------ user_key_to_id ---------------------------------
--
-- Returns an ID value from hr_pump_batch_line_user_keys alone.
-- Utility function to get _ID functions.
--
Function user_key_to_id(p_user_key_value in varchar2)
  return number is
   l_id number;
Begin
   select unique_key_id
   into   l_id
   from   hr_pump_batch_line_user_keys
   where  user_key_value = p_user_key_value;
   return(l_id);
End user_key_to_id;
--

----------------------------- get_element_type_id -----------------------------
--
-- Returns the element type id
--
Function get_element_type_id
  (p_element_name         in varchar2
  ,p_business_group_id    in number
  ,p_language_code        in varchar2
  ,p_effective_date       in date
  )
  return number is
--
l_element_type_id pay_element_types_f.element_type_id%type;
--
Begin


  select et.element_type_id
    into l_element_type_id
    from pay_element_types_f et,
         pay_element_types_f_tl et_tl
   where  et_tl.element_type_id = et.element_type_id
    and   et_tl.element_name = p_element_name
    and   p_effective_date between et.effective_start_date and
                                 et.effective_end_date
    and  nvl(legislation_code,
         nvl(HR_API.RETURN_LEGISLATION_CODE(p_business_group_id),'~~nvl~~')) =
         nvl(HR_API.RETURN_LEGISLATION_CODE(p_business_group_id),'~~nvl~~')
    and  nvl(business_group_id,nvl(p_business_group_id,-1)) =
				  nvl(p_business_group_id,-1)
    and  et_tl.language        = p_language_code;
  --
  return (l_element_type_id);
Exception
when others then
   hr_data_pump.fail('get_element_type_id', sqlerrm, p_element_name,
                     p_business_group_id, p_language_code,p_effective_date);
   raise;
End get_element_type_id;
--
------------------------------get_formula_id------------------------------------
--
--  Return the formula id.
--

Function get_formula_id( p_formula_Name      in varchar2,
  	  	         p_business_group_id in  number
                       ) return number is
	l_formula_id number ;

Begin

 Select distinct formula_id
 into   l_formula_id
 From   ff_formulas_f f1,
        ff_formula_types f2
 Where  f2.formula_type_id = f1.formula_type_id
 and    f2.formula_type_name in('Oracle Payroll' , 'Balance Adjustment')
 and    UPPER(f1.formula_name) = UPPER(p_formula_Name)
 and   nvl(f1.legislation_code,
       nvl(HR_API.RETURN_LEGISLATION_CODE(p_business_group_id),'~~nvl~~')) =
       nvl(HR_API.RETURN_LEGISLATION_CODE(p_business_group_id),'~~nvl~~')
 and   nvl(f1.business_group_id,nvl(p_business_group_id,-1)) =
                            nvl(p_business_group_id,-1) ;


 RETURN(l_formula_id);

Exception
  When OTHERS Then
     hr_data_pump.fail('get_formula_id', sqlerrm, p_formula_Name,
              	        p_business_group_id);
       RAISE;
End get_formula_id;
--
--
--------------------------- get_assignment_status_type_id -----------------------------
--
-- Returns the assignment status type id.
--
Function get_assignment_status_type_id
  (p_assignment_status    in varchar2
  ,p_business_group_id    in number
  ,p_language_code        in varchar2
  ,p_effective_date       in date
  )
  return number is
--
l_ass_status_typ_id	per_assignment_status_types.assignment_status_type_id%type;

invalid_status_stnd      exception;
invalid_status_badjust   exception;
l_message		 varchar2(10000);
l_lookup                 hr_lookups.lookup_code%type;
l_meaning                hr_lookups.meaning%type;
l_standard_lookup        hr_lookups.meaning%type;
l_balance_lookup	 hr_lookups.meaning%type;

cursor c_lookup_type is
   Select lookup_code, meaning
   from  hr_lookups
   Where lookup_type = 'NAME_TRANSLATIONS'
     and lookup_code in ('STANDARD','BAL_ADJUST');

Begin
--
 open c_lookup_type;
  loop
  fetch c_lookup_type into l_lookup,l_meaning;
  exit when c_lookup_type%notfound;
  if l_lookup = 'STANDARD' then
     l_standard_lookup := l_meaning;
  elsif l_lookup = 'BAL_ADJUST' then
     l_balance_lookup := l_meaning;
  end if;
  end loop;
  close c_lookup_type;

  --
  if (UPPER(p_assignment_status) = nvl(UPPER(l_standard_lookup),'-1')) then
     raise invalid_status_stnd;
  elsif (UPPER(p_assignment_status) = nvl(UPPER(l_balance_lookup),'-1')) then
     raise invalid_status_badjust;
  else
     select astp.assignment_status_type_id
      into l_ass_status_typ_id
      from   per_assignment_status_types_tl astpl,
             per_assignment_status_types astp
      where astpl.assignment_status_type_id = astp.assignment_status_type_id
        and UPPER(astpl.user_status) = UPPER(p_assignment_status)
        and nvl(astp.business_group_id,nvl(p_business_group_id,0))
           = nvl(p_business_group_id,0)
        and nvl(astp.legislation_code
	      ,nvl(hr_api.return_legislation_code(p_business_group_id),' '))
           = nvl(hr_api.return_legislation_code(p_business_group_id),' ');
    --
    return(l_ass_status_typ_id);
  end if;
  --
Exception
 when invalid_status_stnd then
    fnd_message.set_name('PAY', 'PAY_33697_SPR_STND_MISMATCH');
    l_message := fnd_message.get;
    hr_data_pump.fail('get_assignment_status_type_id', l_message);
    raise;
 when invalid_status_badjust then
    fnd_message.set_name('PAY', 'PAY_33698_SPR_BADJUST_MISMATCH');
    l_message := fnd_message.get;
    hr_data_pump.fail('get_assignment_status_type_id', l_message);
    raise;
  when others then
   hr_data_pump.fail('get_assignment_status_type_id', sqlerrm, p_assignment_status,
          p_business_group_id, p_language_code,p_effective_date);
   raise;

End get_assignment_status_type_id;
--
------------------------- get_status_processing_rule_ovn -------------------------
--
-- Returns the object version number of the status processing rule and requires a
-- user key.
--
Function get_status_processing_rule_ovn
  (p_status_process_rule_user_key in varchar2
  ,p_effective_date               in date
  )
  return number is
--
  l_spr_ovn number;
--
Begin
  select spr.object_version_number
    into l_spr_ovn
    from pay_status_processing_rules_f spr,
         hr_pump_batch_line_user_keys key
   where key.user_key_value  = p_status_process_rule_user_key
     and spr.status_processing_rule_id = key.unique_key_id
     and p_effective_date between spr.effective_start_date
     and spr.effective_end_date;
  --
  return(l_spr_ovn);
exception
when others then
   hr_data_pump.fail('get_status_processing_rule_ovn'
                     ,sqlerrm
		     ,p_status_process_rule_user_key
                     ,p_effective_date);
   raise;
End get_status_processing_rule_ovn;
--
-------------------------- get_status_processing_rule_id -------------------------
--
-- Returns a status_processing_rule_id and requires a user_key.
--
function get_status_processing_rule_id
(
   p_status_process_rule_user_key in varchar2
) return number is
   l_status_processing_rule_id number;
begin
   l_status_processing_rule_id := user_key_to_id(p_status_process_rule_user_key);
   return(l_status_processing_rule_id);
exception
when others then
   hr_data_pump.fail('get_status_processing_rule_id', sqlerrm, p_status_process_rule_user_key);
   raise;
end get_status_processing_rule_id;
--
END pay_processing_rule_data_pump ;

/
