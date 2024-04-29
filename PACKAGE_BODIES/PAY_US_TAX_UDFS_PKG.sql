--------------------------------------------------------
--  DDL for Package Body PAY_US_TAX_UDFS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_TAX_UDFS_PKG" AS
/* $Header: pyustudf.pkb 115.3 2004/06/24 10:58:21 ppanda noship $ */


FUNCTION get_altrnt_flat_rate_calc_meth(p_assignment_action_id in number,
                                        p_state_code           in varchar2)
RETURN VARCHAR2 IS

ln_calc_method varchar2(30) := 'NO_METHOD';

/* get_altrnt_flat_rate_calc_meth will return the first
   calculation method found for the given state
*/

BEGIN /* get_alternate_flat_rate_calc_method */

     hr_utility.trace('get_alternate_flat_rate_calc_method');


     if etei_data_val.COUNT = 0  then
        ln_calc_method := 'NO_METHOD';
     else
       for i in etei_data_val.FIRST .. etei_data_val.LAST loop

          if ( p_state_code           = etei_data_val(i).state_code and
               p_assignment_action_id = etei_data_val(1).asg_act_id
             ) then
               ln_calc_method := etei_data_val(i).calc_method;
               exit;
          end if;
       end loop;

     end if;

     hr_utility.trace('Value of Calc Method is : ' || ln_calc_method);

     return ln_calc_method;

END get_altrnt_flat_rate_calc_meth;


FUNCTION store_data( p_assignment_action_id in number,
                     p_element_type_id      in number,
                     p_state_code           in varchar2,
                     p_calc_method          in varchar2)
RETURN NUMBER IS

  ln_return            number;
  ln_cnt               number;
  ln_found             number;
  ln_element_type_id   pay_element_types_f.element_type_id%TYPE;
  lv_level             fnd_lookup_values.meaning%TYPE;
  lv_state_code        pay_us_states.state_code%TYPE;
  lv_calc_method       fnd_lookup_values.lookup_code%TYPE;


begin

  hr_utility.trace('In store_data ');
  hr_utility.trace('asg_act_id         = '||p_assignment_action_id);
  hr_utility.trace('Element Type Id(1) = '||p_element_type_id);
  hr_utility.trace('lv_state_code      = '||p_state_code);
  hr_utility.trace('lv_calc_method     = '||p_calc_method);

  ln_found := 0;
  ln_cnt := etei_data_val.COUNT +1;
  hr_utility.trace('ln_cnt  = '||ln_cnt);

  if etei_data_val.COUNT > 0 then

     if (p_assignment_action_id <> etei_data_val(1).asg_act_id)then
        hr_utility.trace('Flushing table and Inserting ');
        etei_data_val.DELETE;
        etei_data_val(1).asg_act_id  := p_assignment_action_id;
        etei_data_val(1).ele_type_id := p_element_type_id;
        etei_data_val(1).state_code  := p_state_code;
        etei_data_val(1).calc_method := p_calc_method;
     else
        for i in etei_data_val.FIRST .. etei_data_val.LAST loop

           if (p_element_type_id = etei_data_val(i).ele_type_id) then
              if p_state_code <> etei_data_val(i).state_code then
                 ln_found := 0;
              else
                 ln_found := 1;
              end if;
           else
              ln_found := 0;
           end if;

           if ln_found = 1 then
              exit;
           end if;

        end loop;

        if ln_found = 0 then
           etei_data_val(ln_cnt).asg_act_id  := p_assignment_action_id;
           etei_data_val(ln_cnt).ele_type_id := p_element_type_id;
           etei_data_val(ln_cnt).state_code  := p_state_code;
           etei_data_val(ln_cnt).calc_method := p_calc_method;
        end if;
     end if;
  else

     hr_utility.trace('First time Inserting ');
     etei_data_val(1).asg_act_id  := p_assignment_action_id;
     etei_data_val(1).ele_type_id := p_element_type_id;
     etei_data_val(1).state_code  := p_state_code;
     etei_data_val(1).calc_method := p_calc_method;

  end if;

  return etei_data_val.COUNT;
end store_data;

FUNCTION set_altrnt_flat_rate_calc_meth(
                                   p_assignment_action_id in number,
                                   p_element_type_id      in number,
                                   p_date_earned          in date,
                                   p_state_code           in varchar2 default 'NOT_APPLICABLE',
                                   p_calc_method          in varchar2 default 'NOT_APPLICABLE')
RETURN NUMBER IS

   ln_return   number;

   cursor c_get_element_extra_info is
      select pet.element_type_id,
             petei.EEI_INFORMATION2,
             petei.EEI_INFORMATION4,
             petei.EEI_INFORMATION5
        from pay_element_types_f pet,
             pay_element_type_extra_info petei
       where pet.element_type_id    = p_element_type_id
         and p_date_earned            between pet.effective_start_date
                                          and pet.effective_end_date
         and petei.INFORMATION_TYPE = 'PAY_US_TAX_CALCULATION_METHOD'
         and petei.element_type_id  = pet.element_type_id;


  ln_element_type_id pay_element_types_f.element_type_id%TYPE;
  lv_level           fnd_lookup_values.meaning%TYPE;
  lv_state_code      pay_us_states.state_code%TYPE;
  lv_calc_method     fnd_lookup_values.lookup_code%TYPE;

/* set_altrnt_flat_rate_calc_meth will set the following
   information : Assignment Action Id , Element Type Id,
   State Code and Calculation Method.
   We will insert records in a plsql table for an assignment action id
   one or more element type id and for each element type id
   one or more state code and calculation method.
*/
ln_extra_info_count  number := 0;

BEGIN /* set_altrnt_flat_rate_calc_meth */

   hr_utility.trace('In set_altrnt_flat_rate_calc_meth');

   if (p_state_code  = 'NOT_APPLICABLE' AND
       p_calc_method = 'NOT_APPLICABLE') then

        for c1_rec in c_get_element_extra_info loop
            ln_extra_info_count := ln_extra_info_count + 1;
            if c_get_element_extra_info%notfound then
               --
               -- Purge the pl/sql table if alternate supplemetal method defined for an element
               --
               if (ln_extra_info_count = 1 and
                  etei_data_val.COUNT > 0)
               then
                  etei_data_val.DELETE;
               end if;
               --End of purge
               hr_utility.trace('State Code and Claculation Method Not Found for an Element');
               exit;
            end if;

            ln_element_type_id  := c1_rec.element_type_id;
            lv_level            := c1_rec.EEI_INFORMATION2;
            lv_state_code       := c1_rec.EEI_INFORMATION4;
            lv_calc_method      := c1_rec.EEI_INFORMATION5;

            if lv_level = 'Federal' then
               lv_state_code := '00';
            end if;

            ln_return := store_data(p_assignment_action_id,
                                    p_element_type_id,
                                    lv_state_code,
                                    lv_calc_method);
       end loop;
   else
       lv_state_code := p_state_code;
       lv_calc_method := p_calc_method;

       ln_return := store_data(p_assignment_action_id,
                               p_element_type_id,
                               lv_state_code,
                               lv_calc_method);
   end if;
   return ln_return;
exception when others then
   return 0;

END set_altrnt_flat_rate_calc_meth; /* set_altrnt_flat_rate_calc_meth */

END pay_us_tax_udfs_pkg;


/
