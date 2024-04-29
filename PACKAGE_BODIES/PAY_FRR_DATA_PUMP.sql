--------------------------------------------------------
--  DDL for Package Body PAY_FRR_DATA_PUMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FRR_DATA_PUMP" AS
/* $Header: pyfrrdpm.pkb 115.2 2003/04/09 06:56:36 scchakra noship $ */
--
------------------------- get_source_element_type_id --------------------------
--
-- This is a private function and returns the element type id.
--
Function get_source_element_type_id
  (p_element_name      in varchar2
  ,p_business_group_id in number
  ,p_language_code     in varchar2
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
   where et_tl.element_name = p_element_name
     and (et.business_group_id + 0 = p_business_group_id
          or (et.business_group_id is null
              and et.legislation_code = hr_api.return_legislation_code(p_business_group_id)
	  ))
     and et_tl.element_type_id = et.element_type_id
     and et_tl.language        = p_language_code;
  --
  return (l_element_type_id);
Exception
when others then
   hr_data_pump.fail('get_source_element_type_id', sqlerrm, p_element_name,
                     p_business_group_id, p_language_code);
   raise;
End get_source_element_type_id;
--
--------------------------- get_ass_status_typ_id -----------------------------
--
-- This is a private function and returns the assignment status type id.
--
Function get_ass_status_typ_id
  (p_user_status          in varchar2
  ,p_business_group_id    in number
  ,p_language_code        in varchar2
  )
  return number is
--
l_ass_status_typ_id per_ass_status_type_amends.assignment_status_type_id%type;
--
Begin
  If p_user_status is not null
     and (hr_general.decode_lookup('NAME_TRANSLATIONS','STANDARD')
          <> p_user_status) then
    --
    select pas.assignment_status_type_id
      into l_ass_status_typ_id
      from per_assignment_status_types_tl pastl
          ,per_assignment_status_types pas
          ,per_ass_status_type_amends asta
     where pas.assignment_status_type_id = pastl.assignment_status_type_id
       and pastl.language = p_language_code
       and nvl(asta.user_status,pastl.user_status) = p_user_status
       and asta.assignment_status_type_id(+) = pas.assignment_status_type_id
       and asta.business_group_id(+) = p_business_group_id
       and nvl(pas.business_group_id,nvl(p_business_group_id,0))
           = nvl(p_business_group_id,0)
       and nvl(pas.legislation_code
	      ,nvl(hr_api.return_legislation_code(p_business_group_id),' '))
           = nvl(hr_api.return_legislation_code(p_business_group_id),' ');
    --
  End If;
  --
  return(l_ass_status_typ_id);
Exception
when others then
   hr_data_pump.fail('get_ass_status_typ_id', sqlerrm, p_user_status,
                     p_business_group_id, p_language_code);
   raise;

End get_ass_status_typ_id;
--
------------------------ get_status_processing_rule_id ------------------------
--
-- Returns the status processing rule id.
--
Function get_status_processing_rule_id
  (p_source_element_name  in varchar2
  ,p_user_status          in varchar2
  ,p_effective_date       in date
  ,p_business_group_id    in number
  ,p_language_code        in varchar2
  )
  return number is
--
l_element_type_id   pay_status_processing_rules.element_type_id%type;
l_ass_status_typ_id pay_status_processing_rules.assignment_status_type_id%type;
l_spr_id            pay_status_processing_rules.status_processing_rule_id%type;
--
Begin

  l_element_type_id := get_source_element_type_id
                         (p_source_element_name
			 ,p_business_group_id
			 ,p_language_code
			 );
  l_ass_status_typ_id := get_ass_status_typ_id
                           (p_user_status
			   ,p_business_group_id
			   ,p_language_code
			   );
  Begin
    select status_processing_rule_id
      into l_spr_id
      from pay_status_processing_rules_f spr
     where spr.element_type_id = l_element_type_id
       and p_effective_date between spr.effective_start_date
       and spr.effective_end_date
       and (spr.business_group_id + 0 = p_business_group_id
            or (spr.business_group_id is null
                and spr.legislation_code = hr_api.return_legislation_code(p_business_group_id)
	    ))
       and nvl(spr.assignment_status_type_id,-1) = nvl(l_ass_status_typ_id,-1);
    --
    return(l_spr_id);
  Exception
    when others then
    hr_data_pump.fail('get_status_processing_rule_id'
                     ,sqlerrm
		     ,p_source_element_name
                     ,p_user_status
                     ,p_effective_date
                     ,p_business_group_id
		     ,p_language_code);
    raise;
  End;
End get_status_processing_rule_id;
--
----------------------------- get_element_type_id -----------------------------
--
-- Returns the element type id
--
Function get_element_type_id
  (p_element_name         in varchar2
  ,p_business_group_id    in number
  ,p_language_code        in varchar2
  )
  return number is
--
l_element_type_id pay_element_types_f.element_type_id%type;
--
Begin
  l_element_type_id := get_source_element_type_id
                           (p_element_name
            		   ,p_business_group_id
			   ,p_language_code
			   );
  return (l_element_type_id);
Exception
when others then
   hr_data_pump.fail('get_element_type_id', sqlerrm, p_element_name,
                     p_business_group_id, p_language_code);
   raise;
End get_element_type_id;
--
------------------------------ get_input_value_id -----------------------------
--
-- Returns the input value id.
--
Function get_input_value_id
  (p_data_pump_always_call in varchar2
  ,p_input_value_name      in varchar2
  ,p_source_element_name   in varchar2
  ,p_element_name          in varchar2
  ,p_result_rule_type      in varchar2
  ,p_business_group_id     in number
  ,p_effective_date        in date
  ,p_language_code         in varchar2
  )
  return number is
--
l_input_value_id pay_input_values_f.input_value_id%type;
--
Begin
  --
  -- Specific parameters are NULL
  --
  If p_input_value_name is null or p_source_element_name is null
     or p_result_rule_type is null then
    return null;
  End If;
  --
  -- Specific parameters have HR_API defaults
  --
  If p_input_value_name = hr_api.g_varchar2 or p_source_element_name = hr_api.g_varchar2
     or p_result_rule_type = hr_api.g_varchar2 then
     return hr_api.g_number;
  End If;
  --
  If p_result_rule_type = 'D' then
    l_input_value_id := hr_pump_get.get_input_value_id
                          (p_input_value_name
                          ,p_source_element_name
                          ,p_business_group_id
                          ,p_effective_date
                          ,p_language_code
                          );
  Else
    If p_element_name is null then
      return null;
    Elsif p_element_name = hr_api.g_varchar2 then
      return hr_api.g_number;
    Else
      l_input_value_id := hr_pump_get.get_input_value_id
                            (p_input_value_name
                            ,p_element_name
                            ,p_business_group_id
                            ,p_effective_date
                            ,p_language_code
                            );
    End If;
  End If;
  return (l_input_value_id);
--
Exception
when others then
   hr_data_pump.fail('get_input_value_id'
                    ,sqlerrm
                    ,p_input_value_name
		    ,p_source_element_name
		    ,p_element_name
		    ,p_result_rule_type
		    ,p_business_group_id
		    ,p_effective_date
		    ,p_language_code);
   raise;

End get_input_value_id;
--
------------------------- get_formula_result_rule_ovn -------------------------
--
-- Returns the object version number of the formula result rule and requires a
-- user key.
--
Function get_formula_result_rule_ovn
  (p_formula_result_rule_user_key in varchar2
  ,p_effective_date               in date
  )
  return number is
--
  l_frr_ovn number;
--
Begin
  select frr.object_version_number
    into l_frr_ovn
    from pay_formula_result_rules_f frr,
         hr_pump_batch_line_user_keys key
   where key.user_key_value  = p_formula_result_rule_user_key
     and frr.formula_result_rule_id = key.unique_key_id
     and p_effective_date between frr.effective_start_date
     and frr.effective_end_date;
  --
  return(l_frr_ovn);
exception
when others then
   hr_data_pump.fail('get_formula_result_rule_ovn'
                     ,sqlerrm
		     ,p_formula_result_rule_user_key
                     ,p_effective_date);
   raise;
End get_formula_result_rule_ovn;
--
-------------------------- get_formula_result_rule_id -------------------------
--
-- Returns a formula_result_rule_id and requires a user_key.
--
function get_formula_result_rule_id
(
   p_formula_result_rule_user_key in varchar2
) return number is
   l_formula_result_rule_id number;
begin
   l_formula_result_rule_id := pay_element_data_pump.user_key_to_id
                          (p_formula_result_rule_user_key);
   return(l_formula_result_rule_id);
exception
when others then
   hr_data_pump.fail('get_formula_result_rule_id', sqlerrm, p_formula_result_rule_user_key);
   raise;
end get_formula_result_rule_id;
--
END pay_frr_data_pump;

/
