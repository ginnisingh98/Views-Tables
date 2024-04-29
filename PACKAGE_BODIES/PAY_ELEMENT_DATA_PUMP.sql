--------------------------------------------------------
--  DDL for Package Body PAY_ELEMENT_DATA_PUMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ELEMENT_DATA_PUMP" AS
/* $Header: pyeledpm.pkb 120.0 2005/05/29 04:31:38 appldev noship $ */

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
-------------------------- get_balancing_keyflex_id ---------------------------
--
-- Returns a balancing_keyflex_id and requires a user_key
--
Function get_balancing_keyflex_id
  (p_balancing_keyflex_user_key in varchar2
  )
  return number is
  --
  l_balancing_keyflex_id number;
  --
Begin
  --
  l_balancing_keyflex_id :=
  user_key_to_id( p_balancing_keyflex_user_key );
  return(l_balancing_keyflex_id);
  --
Exception
  --
  when others then
    hr_data_pump.fail('get_balancing_keyflex_id', sqlerrm,
                       p_balancing_keyflex_user_key);
    raise;
    --
End get_balancing_keyflex_id;
--
---------------------------- get_element_set_id -------------------------------
--
-- Returns an element_set_id
--
Function get_element_set_id
  (p_business_group_id number
  ,p_element_set_name  varchar2
  )
  return number is
  --
  l_element_set_id number;
  --
Begin
  --
  select els.element_set_id
    into l_element_set_id
    from pay_element_sets els
   where upper(els.element_set_name) = upper(p_element_set_name)
     and nvl(els.business_group_id,nvl(p_business_group_id,0)) =
           nvl(p_business_group_id,0);
  --
Exception
  --
  when others then
    hr_data_pump.fail('get_element_set_id', sqlerrm,
                       p_business_group_id, p_element_set_name);
    raise;
    --
End get_element_set_id;
--
-------------------------- get_element_link_ovn -------------------------------
--
-- Returns the object version number (ovn) of the element link
--
Function get_element_link_ovn
  (p_element_link_user_key in varchar2
  ,p_effective_date        in date
  )
  return number is
  --
  l_element_link_ovn number;
  --
Begin
   select pel.object_version_number
   into   l_element_link_ovn
   from   pay_element_links_f pel,
          hr_pump_batch_line_user_keys key
   where  key.user_key_value  = p_element_link_user_key
   and    pel.element_link_id = key.unique_key_id
   and    p_effective_date between
          pel.effective_start_date and pel.effective_end_date;

   return(l_element_link_ovn);
exception
when others then
   hr_data_pump.fail('get_element_link_ovn', sqlerrm, p_element_link_user_key,
                     p_effective_date);
   raise;
end get_element_link_ovn;
--
------------------------ get_link_input_value_id ------------------------------
--
-- Returns the link input value id of the element link and input value
--
Function get_link_input_value_id
  (p_element_link_user_key in varchar2
  ,p_input_value_name      in varchar
  ,p_element_name          in varchar2
  ,p_business_group_id     in number
  ,p_language_code         in varchar2
  ,p_effective_date        in date
  )
  return number is
  --
  l_input_value_id      number;
  l_link_input_value_id number;
  --
Begin
  --
  l_input_value_id := hr_pump_get.get_input_value_id
                        (p_input_value_name
                        ,p_element_name
                        ,p_business_group_id
                        ,p_effective_date
                        ,p_language_code
                        );
  --
  select liv.link_input_value_id
    into l_link_input_value_id
    from pay_link_input_values_f  liv,
         hr_pump_batch_line_user_keys key
   where key.user_key_value  = p_element_link_user_key
     and liv.element_link_id = key.unique_key_id
     and liv.input_value_id  = l_input_value_id
     and p_effective_date between liv.effective_start_date
     and liv.effective_end_date;
  return(l_link_input_value_id);
exception
  when others then
     hr_data_pump.fail('get_link_input_value_id'
                      ,sqlerrm
                      ,p_element_link_user_key
                      ,p_input_value_name
                      ,p_element_name
                      ,p_business_group_id
                      ,p_language_code
                      ,p_effective_date
                       );
   raise;
End get_link_input_value_id;
--
------------------------- get_link_input_value_ovn ----------------------------
--
-- Returns the object version number (ovn) of the element link input value
--
Function get_link_input_value_ovn
  (p_element_link_user_key in varchar2
  ,p_input_value_name      in varchar
  ,p_element_name          in varchar2
  ,p_business_group_id     in number
  ,p_language_code         in varchar2
  ,p_effective_date        in date
  )
  return number is
  --
  l_link_input_value_id  number;
  l_link_input_value_ovn number;
  --
Begin
  --
  l_link_input_value_id := get_link_input_value_id
                             (p_element_link_user_key
                             ,p_input_value_name
                             ,p_element_name
                             ,p_business_group_id
                             ,p_language_code
                             ,p_effective_date
                             );
   --
   select liv.object_version_number
     into l_link_input_value_ovn
     from pay_link_input_values_f liv
    where liv.link_input_value_id = l_link_input_value_id
      and p_effective_date between liv.effective_start_date
      and liv.effective_end_date;
   return(l_link_input_value_ovn);
exception
  when others then
    hr_data_pump.fail('get_link_input_value_ovn'
                      ,sqlerrm
                      ,p_element_link_user_key
                      ,p_input_value_name
                      ,p_element_name
                      ,p_business_group_id
                      ,p_language_code
                      ,p_effective_date
                      );
   raise;
end get_link_input_value_ovn;
-----------------------------get_classification_id-----------------------------

Function get_classification_id( p_classification_name varchar2,
 			        p_business_group_id number
                              ) RETURN NUMBER IS

	l_classification_id number;
Begin

 Select pay.classification_id
 into   l_classification_id
 From   pay_element_classifications pay,
        pay_element_classifications_tl paytl
 Where  pay.classification_id = paytl.classification_id
 and    paytl.language = userenv('LANG')
 and    pay.parent_classification_id is null
 and    nvl(pay.legislation_code,
         nvl(HR_API.RETURN_LEGISLATION_CODE(p_business_group_id),'~~nvl~~'))=
         nvl(HR_API.RETURN_LEGISLATION_CODE(p_business_group_id),'~~nvl~~')
 and    nvl(pay.business_group_id,nvl(p_business_group_id,-1)) =
                                  nvl(p_business_group_id,-1)
 and    paytl.classification_name = p_classification_name;

 RETURN(l_classification_id);

Exception
 When OTHERS Then
     hr_data_pump.fail('get_classification_id', sqlerrm,
                        p_classification_name,p_business_group_id);

     RAISE;
End get_classification_id;

------------------------------get_formula_id------------------------------------

Function get_formula_id( p_formula_Name      in varchar2,
  	  	         p_business_group_id in  number,
                         p_effective_date    in date
                       ) RETURN NUMBER IS
	l_formula_id number ;

Begin

 Select formula_id
 into   l_formula_id
 From   ff_formulas_f f1,
        ff_formula_types f2
 Where  f1.formula_type_id = f2.formula_type_id
 and    f2.formula_type_name = 'Element Skip'
 and    p_effective_date between f1.effective_start_date and
                                 f1.effective_end_date
 and  nvl(legislation_code,
       nvl(HR_API.RETURN_LEGISLATION_CODE(p_business_group_id),'~~nvl~~')) =
       nvl(HR_API.RETURN_LEGISLATION_CODE(p_business_group_id),'~~nvl~~')
 and  nvl(business_group_id,nvl(p_business_group_id,-1)) =
                            nvl(p_business_group_id,-1)
 and  upper(formula_name) = upper(p_formula_Name);

 RETURN(l_formula_id);

Exception
  When OTHERS Then
     hr_data_pump.fail('get_formula_id', sqlerrm, p_formula_Name,
              	        p_business_group_id,
                        p_effective_date);
       RAISE;
End get_formula_id;

---------------------------get_benefit_classification_id-----------------------

Function get_benefit_classification_id
            ( p_benefit_classification_name in varchar2,
	      p_business_group_id 	    in  number
            ) RETURN NUMBER IS

	l_benefit_classification_id number;
Begin
 Select benefit_classification_id
 INTO   l_benefit_classification_id
 From   ben_benefit_classifications
 Where nvl(legislation_code,
        nvl(HR_API.RETURN_LEGISLATION_CODE(p_business_group_id),'~~nvl~~'))=
        nvl(HR_API.RETURN_LEGISLATION_CODE(p_business_group_id),'~~nvl~~')
 and   nvl(business_group_id,nvl(p_business_group_id,-1)) =
                              nvl(p_business_group_id,-1)
 and   benefit_classification_name = p_benefit_classification_name ;

 RETURN (l_benefit_classification_id);

Exception
 When OTHERS Then
    hr_data_pump.fail('get_benefit_classification_id', sqlerrm,
        	       p_benefit_classification_name,
		       p_business_group_id);
    RAISE;
End get_benefit_classification_id;

---------------------------get_iterative_formula_id----------------------------

Function get_iterative_formula_id (p_iterative_formula_name in varchar2,
		        	   p_business_group_id      in number ,
		                   p_effective_date         in date
                                  ) RETURN NUMBER IS

  l_formula_id number;
Begin
 Select formula_id
 INTO   l_formula_id
 From   ff_formulas_f f1, ff_formula_types f2
 Where  f1.formula_type_id = f2.formula_type_id
 and    f2.formula_type_name = 'Net to Gross'
 and    p_effective_date  between f1.effective_start_date and
                                  f1.effective_end_date
 and  nvl(legislation_code,
       nvl(HR_API.RETURN_LEGISLATION_CODE(p_business_group_id),'~~nvl~~')) =
       nvl(HR_API.RETURN_LEGISLATION_CODE(p_business_group_id),'~~nvl~~')
 and  nvl(business_group_id,nvl(p_business_group_id,-1)) =
                            nvl(p_business_group_id,-1)
 and  upper(formula_name) = upper(p_iterative_formula_name) ;

 RETURN (l_formula_id);

Exception
 When OTHERS Then
    hr_data_pump.fail('get_iterative_formula_id', sqlerrm,
                       p_iterative_formula_name,
                       p_business_group_id,
                       p_effective_date);
      RAISE;
End get_iterative_formula_id;

------------------------------get_retro_summ_ele_id----------------------------

Function get_retro_summ_ele_id ( p_retro_summ_element_name  in varchar2,
		        	 p_business_group_id        in number ,
                                 p_effective_date           in date
                               ) RETURN NUMBER IS

  l_element_type_id number;

Begin
 Select et.element_type_id
 INTO   l_element_type_id
 From   pay_element_classifications ec, pay_element_types_f et
 Where  ec.classification_id = et.classification_id
 and    p_effective_date between et.effective_start_date and
                                       et.effective_end_date
 and  nvl(et.legislation_code,
       nvl(HR_API.RETURN_LEGISLATION_CODE(p_business_group_id),'~~nvl~~'))=
       nvl(HR_API.RETURN_LEGISLATION_CODE(p_business_group_id),'~~nvl~~')
 and  nvl(et.business_group_id, nvl(p_business_group_id,-1))  =
                                  nvl(p_business_group_id,-1)
 and  et.element_name  = p_retro_summ_element_name ;

 RETURN(l_element_type_id);

Exception
  When OTHERS Then
     hr_data_pump.fail('get_retro_summ_ele_id', sqlerrm,
                        p_retro_summ_element_name,
               	        p_business_group_id,
                        p_effective_date);
       RAISE;
End get_retro_summ_ele_id;

--------------------------------get_proration_group_id-------------------------

Function get_proration_group_id ( p_event_group_name   	in varchar2,
		        	  p_business_group_id 	in number
                                ) RETURN NUMBER IS

 l_event_group_id number;

Begin
 Select event_group_id
 INTO   l_event_group_id
 From   pay_event_groups peg
 Where  peg.event_group_type = 'P'
 and (peg.legislation_code =
                     HR_API.RETURN_LEGISLATION_CODE(p_business_group_id)
        or ( peg.legislation_code is null  and
             peg.business_group_id = p_business_group_id)
        or ( peg.legislation_code is null  and
             peg.business_group_id is null))
 and     event_group_name =  p_event_group_name;

 RETURN(l_event_group_id);

Exception
 When OTHERS Then
   hr_data_pump.fail('get_proration_group_id', sqlerrm,
                      p_event_group_name,
                      p_business_group_id);
   RAISE;
End get_proration_group_id;

----------------------------get_proration_formula_id---------------------------

Function get_proration_formula_id( p_proration_formula_Name in  varchar2,
	    	  	           p_business_group_id      in  number,
	                           p_effective_date         in  date
                                 ) RETURN NUMBER IS
  l_formula_id number ;

Begin

 Select formula_id
 INTO   l_formula_id
 From   ff_formulas_f f1, ff_formula_types f2
 Where  f1.formula_type_id   = f2.formula_type_id
 and    f2.formula_type_name = 'Payroll Run Proration'
 and    p_effective_date between f1.effective_start_date and
                                       f1.effective_end_date
 and  nvl(legislation_code,
       nvl(HR_API.RETURN_LEGISLATION_CODE(p_business_group_id),'~~nvl~~'))=
       nvl(HR_API.RETURN_LEGISLATION_CODE(p_business_group_id),'~~nvl~~')
 and  nvl(business_group_id,nvl(p_business_group_id,-1)) =
                            nvl(p_business_group_id,-1)
 and  upper(formula_name) = upper(p_proration_formula_Name) ;

 RETURN(l_formula_id);

Exception
 When OTHERS Then
    hr_data_pump.fail('get_proration_formula_id', sqlerrm,
                       p_proration_formula_Name, p_business_group_id,
                       p_effective_date);
       RAISE;
End get_proration_formula_id;

-----------------------------get_recalc_event_group_id------------------------

Function get_recalc_event_group_id( p_recalc_event_group_name in  varchar2,
	    	  	            p_business_group_id       in  number
                                  ) RETURN NUMBER IS
  l_event_group_id number ;

Begin

 Select event_group_id
 INTO   l_event_group_id
 From   pay_event_groups
 Where  event_group_type  = 'R'
 and (legislation_code = HR_API.RETURN_LEGISLATION_CODE(p_business_group_id)
        or ( legislation_code is null  and
             business_group_id = p_business_group_id)
        or ( legislation_code is null  and
             business_group_id is null))
 and    event_group_name  = p_recalc_event_group_name;


 RETURN(l_event_group_id);

Exception
 When OTHERS Then
   hr_data_pump.fail('get_recalc_event_group_id', sqlerrm,
                      p_recalc_event_group_name, p_business_group_id);

   RAISE;
End get_recalc_event_group_id;

----------------------------get_element_type_ovn-------------------------------

Function get_element_type_ovn ( p_element_type_user_key in varchar2,
                                p_effective_date        in date
                              ) return number is
  --
  l_element_type_ovn number;
  --
Begin
   Select pet.object_version_number
   into   l_element_type_ovn
   From   pay_element_types_f pet,
          hr_pump_batch_line_user_keys key
   Where  key.user_key_value  = p_element_type_user_key
   and    pet.element_type_id = key.unique_key_id
   and    p_effective_date between
          pet.effective_start_date and pet.effective_end_date;

   return(l_element_type_ovn);

Exception
When others Then
   hr_data_pump.fail('get_element_type_ovn', sqlerrm,
                      p_element_type_user_key,
                      p_effective_date);
   raise;
end get_element_type_ovn;

-----------------------------get_input_value_ovn-------------------------------
Function get_input_value_ovn ( p_element_type_user_key in varchar2,
                               p_existing_input_name   in varchar2,
                               p_business_group_id in number,
                               p_effective_date    in date,
                               p_language_code     in varchar2
                             ) return number is
  --
  l_input_value_ovn number;
  l_input_value_id  number;
  --
Begin

   l_input_value_id :=  get_input_value_id
                            (p_element_type_user_key,
                             p_existing_input_name   ,
                             p_business_group_id ,
                             p_effective_date   ,
                             p_language_code
                            ) ;

   Select piv.object_version_number
   into   l_input_value_ovn
   From   pay_input_values_f piv
   Where  piv.input_value_id  = l_input_value_id
   and    p_effective_date between
          piv.effective_start_date and piv.effective_end_date;

   return(l_input_value_ovn);

Exception
When others Then
   hr_data_pump.fail('get_input_value_ovn', sqlerrm,
                      p_element_type_user_key,p_existing_input_name,
                      p_business_group_id,
                      p_effective_date,p_language_code);
   raise;

end get_input_value_ovn;
----------------------------get_element_type_id--------------------------------

Function get_element_type_id (p_element_type_user_key in varchar2
                             )
                             return number is

  l_element_type_user_key number;
Begin

  l_element_type_user_key := user_key_to_id(p_element_type_user_key);

  return(l_element_type_user_key);
--
Exception
    When OTHERS Then
    hr_data_pump.fail('get_element_type_id', sqlerrm,
                       p_element_type_user_key);
    RAISE;
End get_element_type_id;

----------------------------get_input_value_formula_id------------------------

Function  get_input_value_formula_id ( p_input_formula_name in varchar2,
 	      	  	               p_business_group_id  in number,
                                       p_effective_date     in date
                                     ) RETURN NUMBER IS

  l_formula_id number;

Begin
 Select formula_id
 INTO   l_formula_id
 From   ff_formulas_f ff,
        ff_formula_types ft
 Where nvl(ff.legislation_code,
        nvl(HR_API.RETURN_LEGISLATION_CODE(p_business_group_id),'~~nvl~~'))=
        nvl(HR_API.RETURN_LEGISLATION_CODE(p_business_group_id),'~~nvl~~')
 and    nvl(ff.business_group_id, nvl(p_business_group_id,-1)) =
                                  nvl(p_business_group_id,-1)
 and    p_effective_date between ff.effective_start_date and
                                 ff.effective_end_date
 and    ff.formula_type_id = ft.formula_type_id
 and    upper (ft.formula_type_name) = 'ELEMENT INPUT VALIDATION'
 and    upper(formula_name) = upper(p_input_formula_name) ;

  RETURN(l_formula_id);

Exception
 When OTHERS Then
      hr_data_pump.fail('get_input_value_formula_id', sqlerrm,
                         p_input_formula_name,
                         p_business_group_id,p_effective_date);
       RAISE;
End  get_input_value_formula_id;

-----------------------------get_input_value_id-----------------------------

Function get_input_value_id (p_element_type_user_key in varchar2,
                             p_existing_input_name   in varchar2,
                             p_business_group_id in number,
                             p_effective_date    in date,
                             p_language_code     in varchar2
                            )
                             return number is

  l_input_value_id   number;
  l_element_name     pay_element_types_f_tl.ELEMENT_NAME%type;

Begin
   select pettl.element_name
   into   l_element_name
   from   pay_element_types_f pet,
          pay_element_types_f_tl pettl,
          hr_pump_batch_line_user_keys
   where  pettl.language = p_language_code
   and    pet.element_type_id = pettl.element_type_id
   and    p_effective_date  between
          pet.effective_start_date and pet.effective_end_date
  and   pet.element_type_id = unique_key_id
  and   user_key_value      = p_element_type_user_key ;

  l_input_value_id  := hr_pump_get.get_input_value_id
                                        (p_existing_input_name,
                                         l_element_name ,
                                         p_business_group_id ,
                                         p_effective_date ,
                                         p_language_code );

  return(l_input_value_id);

Exception
    When OTHERS Then
    hr_data_pump.fail('get_input_value_id', sqlerrm,
                       p_element_type_user_key,p_existing_input_name,
                       p_business_group_id , p_effective_date,
                       p_language_code
                      );
    RAISE;
End get_input_value_id;
--
END pay_element_data_pump ;

/
