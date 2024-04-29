--------------------------------------------------------
--  DDL for Package Body NTG_EARNINGS_TEMPLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."NTG_EARNINGS_TEMPLATE" AS
/* $Header: pyusntgf.pkb 120.2 2006/05/11 02:48:10 saikrish noship $ */

/*========================================================================
 *                        CREATE_ELE_NTG_OBJECTS
 *=======================================================================*/
FUNCTION create_ele_ntg_objects
           (p_ele_name              in varchar2
           ,p_ele_reporting_name    in varchar2
           ,p_ele_description       in varchar2     default NULL
           ,p_ele_classification    in varchar2
           ,p_ele_category          in varchar2     default NULL
           ,p_ele_processing_type   in varchar2
           ,p_ele_priority          in number       default NULL
           ,p_ele_standard_link     in varchar2     default 'N'
           ,p_ele_ot_base           in varchar2     default 'N'
           ,p_flsa_hours            in varchar2     default 'N'
           ,p_sep_check_option      in varchar2     default 'N'
           ,p_ele_eff_start_date    in date         default NULL
           ,p_ele_eff_end_date      in date         default NULL
           ,p_supp_category         in varchar2
           ,p_legislation_code      in varchar2
           ,p_bg_id                 in number
           ,p_termination_rule      in varchar2     default 'F'
           )
   RETURN NUMBER IS
   --
   TYPE   TypeNumber    IS TABLE of NUMBER INDEX BY BINARY_INTEGER;
   TYPE   TypeChar20      IS TABLE of VARCHAR2(20) INDEX BY BINARY_INTEGER;
   t_bal_id               TypeNumber;
   t_form_id              TypeNumber;
   t_ipv_id               TypeNumber;
   t_def_val              TypeChar20;
   t_we_flag              TypeChar20;
   --
   l_reserved             VARCHAR2(1) := 'N';
   l_element_type_id      number;
   l_calc_type            varchar2(100);
   l_multiple_entries     char(1) := 'Y';
   l_ovn                  number;
   l_pri_bal_id           number;
   l_pri_ele_type_id      number;
   l_ssf_ele_type_id      number;
   l_source_template_id   number;
   l_template_id          number;
   l_sf_element_type_id   number;
   l_sf_ele_obj_ver_number number;
   l_iter_formula_id      number;
   l_skip_formula         varchar2(50);
   l_ele_obj_ver_number   number;
   l_priority             number;
   l_result_name          varchar2(20);
   l_iterative_rule_type  varchar2(1);
   l_iv_id                number;
   l_insert               varchar2(1) := 'N';
   l_iter_rule_id         number;
   l_iter_rule_ovn        number;
   l_effective_start_date date;
   l_effective_end_date   date;
   l_seeded_ele_type_id      number;
   l_seeded_input_val_id     number;
   l_nextval		    number;
   l_status_pro_rule_id	    number;
   l_configuration_information2 VARCHAR2(200); --Added for bug 5219568
   --
   l_proc   varchar2(80) := 'ntg_earnings_template.create_ele_template_objects';
   --
   -- cursor to get the template id
   --
   CURSOR c_template (l_template_name varchar2) IS
   SELECT template_id
   FROM   pay_element_templates
   WHERE  template_name     = l_template_name
     AND  legislation_code  = p_legislation_code
     AND  template_type     = 'T'
     AND  business_group_id is NULL;
   --
   -- cursor to get the iterative formula id
   --
   CURSOR c_iter_formula_id IS
   SELECT formula_id
     FROM ff_formulas_f
    WHERE formula_name = 'US_ITER_GROSSUP'
      and legislation_code = 'US';
   --
   -- Cursor to get Input value to set iterative processing rule.
   --
   CURSOR c_input_value_id IS
   SELECT input_value_id, name
     FROM pay_input_values_f
    WHERE element_type_id = l_pri_ele_type_id;
   --
   --=======================================================================
   --                FUNCTION GET_OBJ_ID
   --=======================================================================
   FUNCTION get_obj_id (p_object_type   in varchar2,
                        p_object_name   in varchar2,
                        p_object_id     in number    default NULL)
   RETURN NUMBER is
     --
     l_object_id  NUMBER  := NULL;
     l_proc       VARCHAR2(60) := 'ntg_earnings_template.get_obj_id';
     --
     CURSOR c_element IS     -- Gets the element type id
     SELECT element_type_id
     FROM   pay_element_types_f
     WHERE  element_name          = p_object_name
       AND  business_group_id+0     = p_bg_id;
     --
     CURSOR c_get_ipv_id IS  -- Gets the input value id
     SELECT piv.input_value_id
     FROM   pay_input_values_f piv
     WHERE  piv.name              = p_object_name
       AND  piv.element_type_id   = p_object_id
       AND  piv.business_group_id + 0 = p_bg_id;
     --
     CURSOR c_get_bal_id IS  -- Gets the Balance type id
     SELECT balance_type_id
     FROM   pay_balance_types pbt
     WHERE  pbt.balance_name                              = p_object_name
       AND  NVL(pbt.business_group_id, p_bg_id)           = p_bg_id
       AND  NVL(pbt.legislation_code, p_legislation_code) = p_legislation_code;
     --
   BEGIN
      hr_utility.set_location('Entering: '||l_proc, 10);
      --
      IF p_object_type = 'ELEMENT' then
         FOr c_rec in c_element LOOP
            l_object_id := c_rec.element_type_id;  -- element id
         end loop;
      ELSIF p_object_type = 'BALANCE' THEN
         FOR c_rec in c_get_bal_id LOOP
            l_object_id := c_rec.balance_type_id;  -- balance id
         END LOOP;
      ELSIF p_object_type = 'IPV' THEN
         FOR c_rec in c_get_ipv_id LOOP
            l_object_id := c_rec.input_value_id;   -- input value id
         END LOOP;
      END IF;
      hr_utility.set_location('Leaving: '||l_proc, 50);
      --
      RETURN l_object_id;
   END get_obj_id;
---------------------------------------------------------------------------------
---------------------------------- MAIN FUNCTION --------------------------------
---------------------------------------------------------------------------------
BEGIN
--   hr_utility.trace_on('Y','ELISA');

   hr_utility.set_location('Entering : '||l_proc, 10);
   --
   -- Set session date and Source template id
   --
   pay_db_pay_setup.set_session_date(nvl(p_ele_eff_start_date, sysdate));
   --
   -- Check Element Name
   --
   hr_utility.set_location(l_proc, 15);
   --
   BEGIN
   select 'Y'
   into l_reserved
   from pay_balance_types
   where p_ele_name = balance_name -- Bug 3350067
   and nvl(legislation_code, 'US') = 'US'
   and nvl(business_group_id, p_bg_id) = p_bg_id;

   EXCEPTION WHEN NO_DATA_FOUND THEN
      l_reserved := 'N';

   END;

   if l_reserved = 'Y' then
      hr_utility.set_location(l_proc,16);
      hr_utility.set_message(801,'HR_7564_ALL_RES_WORDS');
      hr_utility.raise_error;
   end if;

   hr_utility.set_location(l_proc, 20);
   --
   -- Set Skip Rules
   --
   if p_ele_classification = 'Supplemental Earnings' then
     l_skip_formula     := 'SUPPLEMENTAL_EARNINGS';
--     l_calc_type        := 'GROSSUP_FLAT_AMOUNT_NONRECUR_V2';
   elsif p_ele_classification = 'Earnings' then
     l_skip_formula     := 'REGULAR_EARNINGS';
--     l_calc_type        := 'GROSSUP_FLAT_AMOUNT_NONRECUR_V2';
   end if;
   --
   -- get the template id
   --
   OPEN c_template('Net To Gross Earning');
   FETCH c_template into l_source_template_id;
   CLOSE c_template;
   --
   -- Default element processing priority
   --
   if p_ele_priority is null then
    if p_ele_classification = 'Supplemental Earnings' then
       l_priority := 2500;
    elsif p_ele_classification = 'Earnings' then
       l_priority := 1750;
    elsif p_ele_classification = 'Imputed Earnings' then
       l_priority := 3250;
    end if;
   end if;


   --------------------------------------------
   -- Create the user Structure
   --------------------------------------------
   --
   hr_utility.set_location(l_proc, 60);
   --
   -- This procedure replaces <base name> with actual
   -- element name that the user passed and creates
   -- all elements in user schema (in template tables).
   --
   --Added for bug 5219568
   IF p_ele_classification = 'Supplemental Earnings' AND p_supp_category = 'CM' THEN
     l_configuration_information2 := 'Y';
   ELSE
     l_configuration_information2 := 'N';
   END IF;

   pay_element_template_api.create_user_structure
      (p_validate                      =>     false
      ,p_effective_date                =>     p_ele_eff_start_date
      ,p_business_group_id             =>     p_bg_id
      ,p_source_template_id            =>     l_source_template_id
      ,p_base_name                     =>     p_ele_name
      ,p_base_processing_priority      =>     l_priority
      ,p_configuration_information1    =>     p_ele_processing_type
      ,p_configuration_information2    =>     l_configuration_information2
      ,p_configuration_information11   =>     p_sep_check_option
      ,p_template_id                   =>     l_template_id
      ,p_object_version_number         =>     l_ovn );
   --
   hr_utility.set_location(l_proc, 80);
--
---------------------- Get Element Type ID of new Template -----------------
--
select element_type_id, object_version_number
into   l_element_type_id, l_ele_obj_ver_number
from   pay_shadow_element_types
where  template_id = l_template_id
and    element_name = p_ele_name;
--
/*
select element_type_id, object_version_number
into   l_sf_element_type_id, l_sf_ele_obj_ver_number
from   pay_shadow_element_types
where  template_id = l_template_id
and    element_name = p_ele_name||' Special Features';
*/
 -----------------------------------------------------------
 -- Update Base shadow Element with user-specified details
 -----------------------------------------------------------
        --
        --IF p_ele_processing_type = 'N' THEN
        -- l_multiple_entries := 'N';
        --END IF;
   --
   pay_shadow_element_api.update_shadow_element
     (p_validate                     => false
     ,p_effective_date               => p_ele_eff_start_date
     ,p_element_type_id              => l_element_type_id
     ,p_classification_name          => nvl(p_ele_classification, hr_api.g_varchar2)
     ,p_description                  => p_ele_description
     ,p_reporting_name               => p_ele_reporting_name
     ,p_element_information_category => nvl(upper(p_legislation_code||'_'||
                                        p_ele_classification), hr_api.g_varchar2)
     ,p_element_information1         => nvl(p_supp_category, hr_api.g_varchar2)
     --,p_element_information10        => l_pri_bal_id /* done later */
     ,p_processing_type              => nvl(p_ele_processing_type, hr_api.g_varchar2)
     ,p_standard_link_flag           => nvl(p_ele_standard_link, hr_api.g_varchar2)
     ,p_skip_formula                 => l_skip_formula
     ,p_object_version_number        => l_ele_obj_ver_number
     );
   hr_utility.set_location(l_proc, 90);

/*  NO SPECIAL FEATURES FOR NTG

   ------------------------------------------------------------------
   -- Update user-specified details on Special Features Element.
   ------------------------------------------------------------------
      --
      pay_shadow_element_api.update_shadow_element
        (p_validate                => false
        ,p_effective_date          => p_ele_eff_start_date
        ,p_element_type_id         => l_sf_element_type_id
        ,p_classification_name     => nvl(p_ele_classification, hr_api.g_varchar2)
        ,p_description             => 'SF element for '||p_ele_name
        ,p_element_information_category => nvl(upper(p_legislation_code||'_'||
                                        p_ele_classification), hr_api.g_varchar2)
        ,p_processing_type         => nvl(p_ele_processing_type, hr_api.g_varchar2)
        ,p_object_version_number   => l_sf_ele_obj_ver_number
        );
*/
   ------------------------------------------------------------
   -- Generate Core Objects
   ------------------------------------------------------------
   hr_utility.set_location(l_proc, 120);

   pay_element_template_api.generate_part1
         (p_validate               =>     false
         ,p_effective_date         =>     p_ele_eff_start_date
         ,p_hr_only                =>     false
         ,p_hr_to_payroll          =>     false
         ,p_template_id            =>     l_template_id);
   --
   hr_utility.set_location(l_proc, 130);
   --
   if (hr_utility.chk_product_install('Oracle Payroll','US')) then
      pay_element_template_api.generate_part2
         (p_validate               =>     false
         ,p_effective_date         =>     p_ele_eff_start_date
         ,p_template_id            =>     l_template_id);
   end if;
   hr_utility.set_location(l_proc, 140);
   --
   -------------------------------------------------------------------
   -- Get Element and Balance Id's to update the Further Information
   -------------------------------------------------------------------
   l_pri_bal_id       := get_obj_id('BALANCE', p_ele_name); /* primay balance */
   l_pri_ele_type_id  := get_obj_id('ELEMENT', p_ele_name);
--   l_ssf_ele_type_id  := get_obj_id('ELEMENT',p_ele_name||' Special Features');

   --
   -- Get Iterative formula
   --
   OPEN c_iter_formula_id;
   FETCH c_iter_formula_id into l_iter_formula_id;
    IF c_iter_formula_id%NOTFOUND then
      hr_utility.set_location(l_proc, 145);
      hr_utility.set_message(800,'ITERATIVE FORMULA NOT FOUND');
      hr_utility.raise_error;
    END IF;
   CLOSE c_iter_formula_id;
   ----------------------------------------------
   -- Set iterative formula and Termination Rule
   ----------------------------------------------
   UPDATE pay_element_types_f
   SET    element_information10 = l_pri_bal_id,
          iterative_formula_id  = l_iter_formula_id,
          iterative_flag        = 'Y',
          iterative_priority    =  5 ,
          grossup_flag          = 'Y',
          process_mode          = 'S',
          post_termination_rule = p_termination_rule
   WHERE  element_type_id       = l_pri_ele_type_id
     AND  business_group_id + 0 = p_bg_id;
   ---------------------------------
   -- Set iterative processing rules
   ---------------------------------
   FOR c_iv_rec in c_input_value_id LOOP

       IF     c_iv_rec.name = 'Additional Amount'
       then   l_result_name := 'ADDITIONAL_AMOUNT';
              l_iterative_rule_type := 'A';
              l_iv_id := c_iv_rec.input_value_id;
              l_insert := 'Y';

       elsif  c_iv_rec.name = 'Low Gross'
         then l_result_name := 'LOW_GROSS';
              l_iterative_rule_type := 'A';
              l_iv_id := c_iv_rec.input_value_id;
              l_insert := 'Y';

       elsif  c_iv_rec.name = 'High Gross'
         then l_result_name := 'HIGH_GROSS';
              l_iterative_rule_type := 'A';
              l_iv_id := c_iv_rec.input_value_id;
              l_insert := 'Y';

       elsif  c_iv_rec.name = 'Remainder'
         then l_result_name := 'REMAINDER';
              l_iterative_rule_type := 'A';
              l_iv_id := c_iv_rec.input_value_id;
              l_insert := 'Y';

       elsif c_iv_rec.name = 'Pay Value'
        -- Using any other Input Value to insert Stopper.
        then  l_result_name := 'STOPPER';
              l_iterative_rule_type := 'S';
              l_iv_id := NULL;
              l_insert := 'Y';
       end if;

       IF l_insert = 'Y' THEN

     hr_utility.set_location('p_ele_eff_start_date = '||p_ele_eff_start_date, 149);

         pay_iterative_rules_api.create_iterative_rule
           (
             p_effective_date        => p_ele_eff_start_date
            ,p_element_type_id       => l_pri_ele_type_id
            ,p_result_name           => l_result_name
            ,p_iterative_rule_type   => l_iterative_rule_type
            ,p_input_value_id        => l_iv_id
            ,p_severity_level        => NULL
            ,p_business_group_id     => p_bg_id
            ,p_legislation_code      => 'US'
            ,p_iterative_rule_id     => l_iter_rule_id
            ,p_object_version_number => l_iter_rule_ovn
            ,p_effective_start_date  => l_effective_start_date
            ,p_effective_end_date    => l_effective_end_date
           );
        END IF;
      l_insert := 'N';
   END LOOP;

   --
   hr_utility.set_location(l_proc, 150);
   -------------------------------------------------------------------
   -- Update Input values with default values, validation formula etc.
   -------------------------------------------------------------------
   t_ipv_id(1)  := get_obj_id('IPV', 'Separate Check', l_pri_ele_type_id);
   t_form_id(1) := NULL;
   t_we_flag(1) := NULL;
   t_def_val(1) := p_sep_check_option;

   hr_utility.set_location('Leaving: '||l_proc, 170);
   FOR i in 1..1 LOOP
      UPDATE pay_input_values_f
      SET    formula_id       = t_form_id(i)
            ,warning_or_error = t_we_flag(i)
            ,default_value    = t_def_val(i)
      WHERE  input_value_id   = t_ipv_id(i);
   END LOOP;

   hr_utility.set_location('Leaving: '||l_proc, 175);

   --
   hr_utility.set_location('Leaving: '||l_proc, 180);

      -- Amount needs to feed the Seeded element (FIT_GROSSUP_ADJUSTMENT)
      -- of Input Value	Amount.
      -- Thus need to get the element_type_id of the seeded element
      -- and input_value_id of Amount from the seeded element.
	hr_utility.set_location('select element type id', 136);

      Select element_type_id
        into l_seeded_ele_type_id
        from pay_element_types_f
       where upper(element_name) = 'FIT_GROSSUP_ADJUSTMENT'
         and legislation_code = 'US';

	hr_utility.set_location('element type id' || l_seeded_ele_type_id , 137);
      Select input_value_id
        into l_seeded_input_val_id
        from pay_input_values_f
       where element_type_id = l_seeded_ele_type_id
         and upper(name) = 'AMOUNT';

      select pay_formula_result_rules_s.nextval
	into l_nextval
	from dual;

      select status_processing_rule_id
	into l_status_pro_rule_id
	from pay_status_processing_rules_f
	where element_type_id = l_pri_ele_type_id;
	--and legislation_code = 'US';


      insert into pay_formula_result_rules_f
	(formula_result_rule_id,
	 effective_start_date,
	 effective_end_date,
	 business_group_id,
	 legislation_code,
	 element_type_id,
	 status_processing_rule_id,
	 result_name,
	 result_rule_type,
	 input_value_id,
	 last_update_date,
	 last_updated_by,
	 last_update_login,
	 created_by,
	 creation_date)
       values
	(l_nextval,
	 trunc(TO_DATE('0001/01/01', 'YYYY/MM/DD')),
	 trunc(TO_DATE('4712/12/31', 'YYYY/MM/DD')),
	 p_bg_id,
	 decode(p_bg_id,NULL,'US',NULL),
	 l_seeded_ele_type_id,
	 l_status_pro_rule_id,
	 'AMOUNT',
	 'I',
	 l_seeded_input_val_id,
	 sysdate,
	 -1,
	 -1,
	 -1,
	 sysdate);



   -------------------------
   RETURN l_pri_ele_type_id;
   -------------------------

END create_ele_ntg_objects;
--
--===========================================================================
--                             Deletion procedure
--===========================================================================
--
PROCEDURE delete_user_template_objects
           (p_business_group_id     in number
           ,p_ele_name              in varchar2
           ) IS
  --
  l_template_id   NUMBER(9);
  --
  l_proc  VARCHAR2(60) := 'ntg_earnings_template.delete_ele_template_objects';
  --
  CURSOR c1 is
  SELECT template_id
  FROM   pay_element_templates
  WHERE  base_name         = p_ele_name
    AND  business_group_id + 0 = p_business_group_id
    AND  template_type     = 'U';
--
BEGIN
   --
   hr_utility.set_location('Entering :'||l_proc, 10);
   for c1_rec in c1 loop
       l_template_id := c1_rec.template_id;
   end loop;
   --
   pay_element_template_api.delete_user_structure
     (p_validate                =>   false
     ,p_drop_formula_packages   =>   true
     ,p_template_id             =>   l_template_id);
   hr_utility.set_location('Leaving :'||l_proc, 50);
   --
END delete_user_template_objects;
--
END ntg_earnings_template;

/
