--------------------------------------------------------
--  DDL for Package Body PQP_EARNINGS_TEMPLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_EARNINGS_TEMPLATE" AS
/* $Header: pqeetdrv.pkb 120.2 2006/08/29 10:50:00 jdevasah noship $ */


/*========================================================================
*  Declare the global variables
*=======================================================================*/
g_bg_id             number;
g_legislation_code  varchar2(60);

/*========================================================================
 *                        CREATE_ELE_TEMPLATE_OBJECTS
 *=======================================================================*/
FUNCTION create_ele_template_objects
           (p_ele_name              in varchar2
           ,p_ele_reporting_name    in varchar2
           ,p_ele_description       in varchar2     default NULL
           ,p_ele_classification    in varchar2
           ,p_ele_category          in varchar2     default NULL
           ,p_ele_processing_type   in varchar2
           ,p_ele_priority          in number       default NULL
           ,p_ele_standard_link     in varchar2     default 'N'
           ,p_ele_ot_base           in varchar2     default 'N'
           ,p_flsa_hours            in varchar2
           ,p_ele_calc_ff_name      in varchar2
           ,p_sep_check_option      in varchar2     default 'N'
           ,p_dedn_proc             in varchar2
           ,p_reduce_regular        in varchar2     default 'N'
           ,p_ele_eff_start_date    in date         default NULL
           ,p_ele_eff_end_date      in date         default NULL
           ,p_supp_category         in varchar2
           ,p_legislation_code      in varchar2
           ,p_bg_id                 in number
           ,p_termination_rule      in varchar2     default 'F'
           )
   RETURN NUMBER IS
   --
   TYPE   TypeIdNumber    IS TABLE of NUMBER INDEX BY BINARY_INTEGER;
   TYPE   TypeIdChar      IS TABLE of VARCHAR2(10) INDEX BY BINARY_INTEGER;
   t_bal_id               TypeIdNumber;
   t_form_id              TypeIdNumber;
   t_ipv_id               TypeIdNumber;
   t_def_val              TypeIdChar;
   t_we_flag              TypeIdChar;
   --
   l_addl_bal_id          number;
   l_element_type_id      number;
   l_calc_type            varchar2(30);
   l_cat_bal_type_id      number;
   l_category_bal_name    varchar2(60);
   l_config2_amt          char(1) := 'N';
   l_config3_perc         char(1) := 'N';
   l_config4_hr           char(1) := 'N';
   l_config5_hrm          char(1) := 'N';
   l_hours_bal_id         number;
   l_ipv_id               number;
   l_multiple_entries     char(1) := 'N';
   l_ovn                  number;
   l_pri_bal_id           number;
   l_pri_ele_type_id      number;
   l_repl_bal_id          number;
   l_si_ele_type_id       number;
   l_asf_ele_type_id      number;
   l_ssf_ele_type_id      number;
   l_source_template_id   number;
   l_supp_bal_id          number;
   l_template_id          number;
   --
   l_proc   varchar2(80) := 'pqp_earnings_template.create_ele_template_objects';

   l_asg_gre_run_dim_id    pay_balance_dimensions.balance_dimension_id%TYPE;

   --
   -- cursor to fetch the new element type id
   --
   CURSOR c_element (c_ele_name varchar2) is
   SELECT element_type_id, object_version_number
   FROM   pay_shadow_element_types
   WHERE  template_id    = l_template_id
     AND  element_name   = c_ele_name;
   --
   -- cursor to get the template id
   --
   CURSOR c_template (l_template_name varchar2)  is
   SELECT template_id
   FROM   pay_element_templates
   WHERE  template_name     = l_template_name
     AND  legislation_code  = p_legislation_code
     AND  template_type     = 'T'
     AND  business_group_id is NULL;
   --
   -- cursor to get the alien category balance name
   --
   CURSOR c_cat_bal_name IS
   SELECT meaning
   FROM   hr_lookups
   WHERE  lookup_type = 'PQP_US_ALIEN_INCOME_BALANCE'
     AND  lookup_code = p_ele_category;
   --
   -- cursor to get the validation formula id
   --
   --CURSOR c_get_formula_id IS
   --SELECT formula_id
   --FROM   ff_formulas_f
   --WHERE  formula_name = 'JURISDICTION_VALIDATION'
   --  AND  p_ele_eff_start_date BETWEEN
   --       effective_start_date AND effective_end_date;


     /* Added the following cursor - tmehra for the balance architecture changes
        as per US Payroll Team request - 02-APR-03
     */

     CURSOR get_asg_gre_run_dim_id IS
     SELECT balance_dimension_id
       FROM pay_balance_dimensions
      WHERE dimension_name   = 'Assignment within Government Reporting Entity Run'
        AND legislation_code = 'US';

   --
------------------------------------------------------------------------------
--  MAIN FUNCTION
------------------------------------------------------------------------------
BEGIN
   hr_utility.set_location('Entering : '||l_proc, 10);
   --
   -- Set the global variables
   --
   g_bg_id            := p_bg_id;
   g_legislation_code := p_legislation_code;
   --
   -- Set session date and Source template id
   --
   pay_db_pay_setup.set_session_date(nvl(p_ele_eff_start_date, sysdate));
   --
   -- get the template id
   --
   FOR c_rec IN c_template('Alien Earning') LOOP
      l_source_template_id := c_rec.template_id;
   END LOOP;
   --
   hr_utility.set_location(l_proc, 20);
   --------------------------------------------
   -- Create the user Structure
   --------------------------------------------
   -- The Configuration Flex segments for the Exclusion Rules are as follows:
   -- Config1 - Xclude SI and SF elements if ele_processing_type='N'
   -- Config2 - Xclude objects if calc type is Not Amount
   -- Config3 - Xclude objects if calc type is Not Percentage
   -- Config4 - Xclude objects if calc type is Not Rate * Hours
   -- Config5 - Xclude objects if calc type is Not Rate * Hours with a multiple
   -- Config6 - Xclude objects if FLSA hours is not checked
   -- Config7 - Xclude objects if overtime base is not checked
   --
   -- set the appropriate exclusion rules
   --
   IF SUBSTR(p_ele_calc_ff_name,1,11) = 'FLAT_AMOUNT' THEN
      l_config2_amt  := 'Y';
      l_calc_type    := 'FLAT_AMOUNT';
   ELSIF SUBSTR(p_ele_calc_ff_name,1,26) = 'PERCENTAGE_OF_REG_EARNINGS' THEN
      l_config3_perc := 'Y';
      l_calc_type    := 'PERCENTAGE';
   ELSIF SUBSTR(p_ele_calc_ff_name,1,21) = 'HOURS_X_RATE_MULTIPLE' THEN
      l_config4_hr   := 'Y';
      l_config5_hrm  := 'Y';
      l_calc_type    := 'HOURS_X_RATE';
   ELSIF SUBSTR(p_ele_calc_ff_name,1,12) = 'HOURS_X_RATE' THEN
      l_config4_hr   := 'Y';
      l_calc_type    := 'HOURS_X_RATE';
   END IF;
   --
   hr_utility.set_location(l_proc, 60);
   --
   pay_element_template_api.create_user_structure
      (p_validate                      =>     false
      ,p_effective_date                =>     p_ele_eff_start_date
      ,p_business_group_id             =>     p_bg_id
      ,p_source_template_id            =>     l_source_template_id
      ,p_base_name                     =>     p_ele_name
      ,p_base_processing_priority      =>     p_ele_priority
      ,p_configuration_information1    =>     p_ele_processing_type
      ,p_configuration_information2    =>     l_config2_amt
      ,p_configuration_information3    =>     l_config3_perc
      ,p_configuration_information4    =>     l_config4_hr
      ,p_configuration_information5    =>     l_config5_hrm
      ,p_configuration_information6    =>     p_flsa_hours
      ,p_configuration_information7    =>     p_ele_ot_base
      ,p_template_id                   =>     l_template_id
      ,p_object_version_number         =>     l_ovn );
   --
   hr_utility.set_location(l_proc, 80);
   -----------------------------------------------------------
   -- Update Base shadow Element with user-specified details
   -----------------------------------------------------------
   FOR c_rec in c_element ( p_ele_name ) LOOP
      l_element_type_id  := c_rec.element_type_id;
      l_ovn              := c_rec.object_version_number;
   END LOOP;
   --
   IF p_ele_processing_type = 'N' THEN
      l_multiple_entries := 'Y';
   END IF;
   --
   pay_shadow_element_api.update_shadow_element
     (p_validate                     => false
     ,p_effective_date               => p_ele_eff_start_date
     ,p_element_type_id              => l_element_type_id
     ,p_description                  => p_ele_description
     ,p_reporting_name               => p_ele_reporting_name
     ,p_processing_type              => nvl(p_ele_processing_type, hr_api.g_varchar2)
     ,p_standard_link_flag           => nvl(p_ele_standard_link, hr_api.g_varchar2)
     ,p_multiple_entries_allowed_fla => l_multiple_entries
     ,p_post_termination_rule        => p_termination_rule
     ,p_element_information1         => nvl(p_ele_category, hr_api.g_varchar2)
     ,p_element_information8         => p_ele_ot_base
     ,p_element_information11        => p_flsa_hours
     ,p_object_version_number        => l_ovn
     );
   hr_utility.set_location(l_proc, 90);
   ------------------------------------------------------------------
   -- Update user-specified details on Supp Special Features Element.
   ------------------------------------------------------------------
   FOR c1_rec in c_element ( p_ele_name||' Supp SF') LOOP
      l_element_type_id := c1_rec.element_type_id;
      l_ovn             := c1_rec.object_version_number;
      --
      pay_shadow_element_api.update_shadow_element
        (p_validate                => false
        ,p_effective_date          => p_ele_eff_start_date
        ,p_element_type_id         => l_element_type_id
        ,p_description             => 'Supp. SF element for:'||p_ele_name
        ,p_reporting_name          => NVL(p_ele_reporting_name,p_ele_name)||':Supp SF'  -- bug 5470399
        ,p_post_termination_rule   => p_termination_rule
        ,p_element_information1    => nvl(p_supp_category, hr_api.g_varchar2)
        ,p_element_information8    => p_ele_ot_base
        ,p_object_version_number   => l_ovn
        );
   END LOOP;
   hr_utility.set_location(l_proc, 100);
   -------------------------------------------------------------------
   -- Update user-specified details on Alien Special Features Element.
   -------------------------------------------------------------------
   FOR c1_rec in c_element ( p_ele_name||' Alien SF') LOOP
      l_element_type_id := c1_rec.element_type_id;
      l_ovn             := c1_rec.object_version_number;
      --
      pay_shadow_element_api.update_shadow_element
        (p_validate                => false
        ,p_effective_date          => p_ele_eff_start_date
        ,p_element_type_id         => l_element_type_id
        ,p_description             => 'Alien SF element for:'||p_ele_name
        ,p_post_termination_rule   => p_termination_rule
        ,p_element_information1    => nvl(p_ele_category, hr_api.g_varchar2)
        ,p_element_information8    => p_ele_ot_base
        ,p_object_version_number   => l_ovn
        );
   END LOOP;
   hr_utility.set_location(l_proc, 110);
   --------------------------------------------------------------------
   -- Update user-specified Classification Special Inputs if it exists.
   --------------------------------------------------------------------
   IF p_ele_processing_type = 'R' THEN
      FOR c1_rec in c_element ( p_ele_name||' Special Inputs' ) LOOP
         l_element_type_id := c1_rec.element_type_id;
         l_ovn             := c1_rec.object_version_number;
      END LOOP;
      pay_shadow_element_api.update_shadow_element
       (p_validate                 => false
       ,p_effective_date           => p_ele_eff_start_date
       ,p_element_type_id          => l_element_type_id
       ,p_description              => 'Generated Special Inputs element for:'
                                      ||p_ele_name
       ,p_post_termination_rule    => p_termination_rule
       ,p_element_information1     => nvl(p_ele_category, hr_api.g_varchar2)
       ,p_element_information8     => p_ele_ot_base
       ,p_object_version_number    => l_ovn
       );
   END IF;
   --
   hr_utility.set_location(l_proc, 120);
   ------------------------------------------------------------
   -- Generate Core Objects
   ------------------------------------------------------------
   pay_element_template_api.generate_part1
         (p_validate               =>     false
         ,p_effective_date         =>     p_ele_eff_start_date
         ,p_hr_only                =>     false
         ,p_hr_to_payroll          =>     false
         ,p_template_id            =>     l_template_id);
   --
   hr_utility.set_location(l_proc, 130);
   --
   --  Add logic to generate part2 only if payroll is installed
   --
   pay_element_template_api.generate_part2
         (p_validate               =>     false
         ,p_effective_date         =>     p_ele_eff_start_date
         ,p_template_id            =>     l_template_id);
   hr_utility.set_location(l_proc, 140);
   --
   -------------------------------------------------------------------
   -- Get Element and Balance Id's to update the Further Information
   -------------------------------------------------------------------
   l_pri_bal_id       := get_obj_id('BAL', p_ele_name);
   l_addl_bal_id      := get_obj_id('BAL', p_ele_name||' Additional Amount');
   l_repl_bal_id      := get_obj_id('BAL', p_ele_name||' Replacement Amount');
   l_hours_bal_id     := get_obj_id('BAL', p_ele_name||' Hours');
   l_supp_bal_id      := get_obj_id('BAL', p_ele_name||' Supp');
   l_pri_ele_type_id  := get_obj_id('ELE', p_ele_name);
   l_si_ele_type_id   := get_obj_id('ELE',p_ele_name||' Special Inputs');
   l_ssf_ele_type_id  := get_obj_id('ELE',p_ele_name||' Supp SF');
   l_asf_ele_type_id  := get_obj_id('ELE',p_ele_name||' Alien SF');
   --
   UPDATE pay_element_types_f
   SET    element_information10 = l_pri_bal_id
         ,element_information12 = l_hours_bal_id
         ,element_information13 = p_reduce_regular
         ,element_information14 = p_supp_category
         ,element_information16 = l_addl_bal_id
         ,element_information17 = l_repl_bal_id
         ,element_information18 = l_si_ele_type_id
         ,element_information19 = l_ssf_ele_type_id
         ,element_information20 = l_calc_type
   WHERE  element_type_id       = l_pri_ele_type_id
     AND  business_group_id     = p_bg_id;


   /* Get the _ASG_GRE_RUN dimension id */

   FOR crec IN get_asg_gre_run_dim_id
   LOOP

     l_asg_gre_run_dim_id := crec.balance_dimension_id;

   END LOOP;

   /* The following update statement has been added by tmehra
      for the balance architecture changes as per the US Payroll Team
   */

   /*This statement is commented as per US Payroll team advice
     due to performance issue */
  /* Bug 3651755 : This update is not required. The category def will take
   care of creating balance with save run balances to 'Yes'*/
   /*UPDATE pay_defined_balances
      SET save_run_balance         = 'Y'
    WHERE balance_type_id          = l_pri_bal_id
      AND balance_dimension_id     = l_asg_gre_run_dim_id
      AND  business_group_id       = p_bg_id;*/
   --

   --
   hr_utility.set_location(l_proc, 150);
   --------------------------------------------------------------------
   -- Update the Further Information for the Alien Supplemental element
   --------------------------------------------------------------------
   l_supp_bal_id      := get_obj_id('BAL', p_ele_name||' Supp');
   --
   UPDATE pay_element_types_f
   SET    element_information10 = l_supp_bal_id
   WHERE  element_type_id       = l_ssf_ele_type_id
     AND  business_group_id     = p_bg_id;

   /* The following update statement has been added by tmehra
      for the balance architecture changes as per the US Payroll Team
   */

  /*This statement is commented as per US Payroll team advice
     due to performance issue */
  /* Bug 3651755 : This update is not required. The category def will take
   care of creating balance with save run balances to 'Yes'*/

  /* UPDATE pay_defined_balances
      SET save_run_balance         = 'Y'
    WHERE balance_type_id          = l_supp_bal_id
      AND balance_dimension_id     = l_asg_gre_run_dim_id
      AND  business_group_id       = p_bg_id;*/


   -----------------------------------------------------
   -- Create balance feeds for the Supp category
   -----------------------------------------------------
   -- creating it here and not in the templates as it is
   -- illegal to create these feeds according to core rules.
   --
   FOR c_rec in c_cat_bal_name LOOP
      l_category_bal_name := c_rec.meaning;
   END LOOP;
   --
   t_ipv_id(1)  := get_obj_id('IPV', 'Pay Value', l_pri_ele_type_id);
   t_bal_id(1)  := get_obj_id('BAL', l_category_bal_name); -- category balance
   t_ipv_id(2)  := get_obj_id('IPV', 'Alien CITY', l_ssf_ele_type_id);
   t_bal_id(2)  := get_obj_id('BAL', 'Supp Earnings for CITY');
   t_ipv_id(3)  := t_ipv_id(2);
   t_bal_id(3)  := get_obj_id('BAL', 'Supp Earnings CITY');
   t_ipv_id(4)  := t_ipv_id(2);
   t_bal_id(4)  := get_obj_id('BAL', 'Supp Earnings for NWCITY');
   t_ipv_id(5)  := get_obj_id('IPV', 'Alien COUNTY', l_ssf_ele_type_id);
   t_bal_id(5)  := get_obj_id('BAL', 'Supp Earnings for COUNTY');
   t_ipv_id(6)  := t_ipv_id(5);
   t_bal_id(6)  := get_obj_id('BAL', 'Supp Earnings for NWCOUNTY');
   t_ipv_id(7)  := get_obj_id('IPV', 'Alien FUTA', l_ssf_ele_type_id);
   t_bal_id(7)  := get_obj_id('BAL', 'Supplemental Earnings for FUTA');
   t_ipv_id(8)  := get_obj_id('IPV', 'Alien Medicare', l_ssf_ele_type_id);
   t_bal_id(8)  := get_obj_id('BAL', 'Supplemental Earnings for Medicare');
   t_ipv_id(9)  := get_obj_id('IPV', 'Alien SCHOOL', l_ssf_ele_type_id);
   t_bal_id(9)  := get_obj_id('BAL', 'Supp Earnings for SCHOOL');
   t_ipv_id(10) := t_ipv_id(9);
   t_bal_id(10) := get_obj_id('BAL', 'Supp Earnings for NWSCHOOL');
   t_ipv_id(11) := get_obj_id('IPV', 'Alien SDI', l_ssf_ele_type_id);
   t_bal_id(11) := get_obj_id('BAL', 'Supplemental Earnings for SDI');
   t_ipv_id(12) := get_obj_id('IPV', 'Alien SS', l_ssf_ele_type_id);
   t_bal_id(12) := get_obj_id('BAL', 'Supplemental Earnings for SS');
   t_ipv_id(13) := get_obj_id('IPV', 'Alien SUI', l_ssf_ele_type_id);
   t_bal_id(13) := get_obj_id('BAL', 'Supplemental Earnings for SUI');
   t_ipv_id(14) := get_obj_id('IPV', 'Alien SIT', l_ssf_ele_type_id);
   t_bal_id(14) := get_obj_id('BAL', 'Supplemental Earnings for SIT');
   t_ipv_id(15) := t_ipv_id(14);
   t_bal_id(15) := get_obj_id('BAL', 'Supplemental Earnings for NWSIT');
   t_ipv_id(16) := get_obj_id('IPV', 'Alien SUPP', l_ssf_ele_type_id);
   t_bal_id(16) := get_obj_id('BAL', 'Supplemental Earnings');
   t_ipv_id(17) := get_obj_id('IPV', 'Alien SIT 1042s', l_ssf_ele_type_id);
   t_bal_id(17) := get_obj_id('BAL', 'Alien 1042s for SIT');
   t_ipv_id(18) := get_obj_id('IPV', 'Alien SIT 1042s', l_ssf_ele_type_id);
   t_bal_id(18) := get_obj_id('BAL', 'Alien 1042s for NWSIT');
   --
   hr_utility.set_location(l_proc, 160);
   FOR i in 1..18 LOOP
      hr_balances.ins_balance_feed(
            p_option                      => 'INS_MANUAL_FEED',
            p_input_value_id              => t_ipv_id(i),
            p_element_type_id             => NULL,
            p_primary_classification_id   => NULL,
            p_sub_classification_id       => NULL,
            p_sub_classification_rule_id  => NULL,
            p_balance_type_id             => t_bal_id(i),
            p_scale                       => '1',
            p_session_date                => p_ele_eff_start_date,
            p_business_group              => p_bg_id,
            p_legislation_code            => NULL,
            p_mode                        => 'USER');
   END LOOP;
   hr_utility.set_location(l_proc, 170);
   -------------------------------------------------------------------
   -- Update Input values with default values, validation formula etc.
   -------------------------------------------------------------------
   t_ipv_id(1)  := get_obj_id('IPV', 'Deduction Processing', l_pri_ele_type_id);
   t_form_id(1) := NULL;
   t_we_flag(1) := NULL;
   t_def_val(1) := p_dedn_proc;
   t_ipv_id(2)  := get_obj_id('IPV', 'Separate Check', l_pri_ele_type_id);
   t_form_id(2) := NULL;
   t_we_flag(2) := NULL;
   t_def_val(2) := p_sep_check_option;
   --
   -- Not using Jurisdiction as the functionality is removed currently
   --
   -- t_ipv_id(3)  := get_obj_id('IPV', 'Jurisdiction', l_pri_ele_type_id);
   -- FOR c_rec in c_get_formula_id LOOP
   --   t_form_id(3) := c_rec.formula_id; -- get the jurisdiction val formula
   -- END LOOP;
   -- t_we_flag(3) := 'E';  -- warning or error flag
   -- t_def_val(3) := NULL; -- default value
   --
   hr_utility.set_location(l_proc, 170);
   FOR i in 1..2 LOOP
      UPDATE pay_input_values_f
      SET    formula_id       = t_form_id(i)
            ,warning_or_error = t_we_flag(i)
            ,default_value    = t_def_val(i)
      WHERE  input_value_id   = t_ipv_id(i);
   END LOOP;
   -------------------------------------------------------------------
   -- Create the balance feeds for FLSA Hours and Reduce Regular
   -------------------------------------------------------------------
   hr_utility.set_location(l_proc, 180);
   add_flsa_reduce_reg_feeds
         (p_ele_ot_base        => p_ele_ot_base
         ,p_flsa_hours         => p_flsa_hours
         ,p_reduce_regular     => p_reduce_regular
         ,p_pri_ele_type_id    => l_pri_ele_type_id
         ,p_ssf_ele_type_id    => l_ssf_ele_type_id
         ,p_asf_ele_type_id    => l_asf_ele_type_id
         ,p_ele_eff_start_date => p_ele_eff_start_date );
   --
   hr_utility.set_location('Leaving: '||l_proc, 200);
   -------------------------
   RETURN l_pri_ele_type_id;
   -------------------------
END create_ele_template_objects;
--
--
--=======================================================================
--                FUNCTION GET_OBJ_ID
--=======================================================================
FUNCTION get_obj_id (p_object_type   in varchar2
                    ,p_object_name   in varchar2
                    ,p_object_id     in number    default NULL )
RETURN NUMBER is
   --
   l_object_id  NUMBER  := NULL;
   l_proc       VARCHAR2(60) := 'pqp_earnings_template.get_obj_id';
   --
   CURSOR c_element IS     -- Gets the element type id
   SELECT element_type_id
   FROM   pay_element_types_f
   WHERE  element_name          = p_object_name
     AND  business_group_id     = g_bg_id;
   --
   CURSOR c_get_ipv_id IS  -- Gets the input value id
   SELECT piv.input_value_id
   FROM   pay_input_values_f piv
   WHERE  piv.name              = p_object_name
     AND  piv.element_type_id   = p_object_id
     AND  piv.business_group_id = g_bg_id;
   --
   CURSOR c_get_bal_id IS  -- Gets the Balance type id
   SELECT balance_type_id
   FROM   pay_balance_types pbt
   WHERE  pbt.balance_name                              = p_object_name
     AND  NVL(pbt.business_group_id, g_bg_id)           = g_bg_id
     AND  NVL(pbt.legislation_code, g_legislation_code) = g_legislation_code;
   --
BEGIN
   hr_utility.set_location('Entering: '||l_proc, 10);
   --
   IF p_object_type = 'ELE' then
      FOR c_rec in c_element LOOP
         l_object_id := c_rec.element_type_id;  -- element id
      END LOOP;
   ELSIF p_object_type = 'BAL' THEN
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
--===========================================================================
-- Add_Flsa_Reduce_Reg_Feeds procedure
--===========================================================================
PROCEDURE add_flsa_reduce_reg_feeds
         (p_ele_ot_base        in varchar2
         ,p_flsa_hours         in varchar2
         ,p_reduce_regular     in varchar2
         ,p_pri_ele_type_id    in number
         ,p_ssf_ele_type_id    in number
         ,p_asf_ele_type_id    in number
         ,p_ele_eff_start_date in date
         ) IS
   --
   l_proc  VARCHAR2(60):= 'pqp_earnings_template.add_flsa_reduce_reg_feeds';
   TYPE   TypeIdNumber IS TABLE of NUMBER INDEX BY BINARY_INTEGER;
   t_bal_id            TypeIdNumber;
   t_ipv_id            TypeIdNumber;
   t_scale             TypeIdNumber;
   l_count             number := 0;
   l_ipv_id            number;
   --
   CURSOR get_reg_feeds IS
   SELECT distinct pbf.balance_type_id
   FROM   pay_balance_feeds_f pbf,
          pay_balance_types   pbt
   WHERE  p_ele_eff_start_date BETWEEN pbf.effective_start_date
                                   AND pbf.effective_end_date
     AND  ((pbt.business_group_id is NULL AND pbt.legislation_code = 'US')
       OR (pbt.business_group_id = g_bg_id AND pbt.legislation_code is NULL))
     AND  pbt.balance_name not in ('FLSA Earnings', 'FLSA Hours')
     AND  pbt.balance_type_id = pbf.balance_type_id
     AND  pbf.input_value_id IN
          (SELECT piv.input_value_id
           FROM   pay_element_types_f pet,
                  pay_input_values_f  piv
           WHERE  pet.element_name IN ('Regular Salary', 'Regular Wages')
             AND  p_ele_eff_start_date BETWEEN pet.effective_start_date
                                           AND pet.effective_end_date
             AND  pet.business_group_id is NULL
             AND  pet.legislation_code = 'US'
             AND  piv.element_type_id  = pet.element_type_id
             AND  piv.name             = 'Pay Value'
             AND  p_ele_eff_start_date BETWEEN piv.effective_start_date
                                           AND piv.effective_end_date
             AND  piv.business_group_id is NULL
             AND  piv.legislation_code = 'US') ;
   --
BEGIN
   --
   hr_utility.set_location(l_proc, 60);
   IF p_flsa_hours = 'Y' THEN
      -- create balance feeds for FLSA hours
      hr_utility.set_location(l_proc, 60);
      l_count := l_count + 1;
      t_ipv_id(l_count) := get_obj_id('IPV', 'Hours',  p_pri_ele_type_id);
      t_bal_id(l_count) := get_obj_id('BAL', 'FLSA Hours');
      t_scale(l_count)  := 1;
   END IF;
   IF p_ele_ot_base  = 'Y' THEN
      -- create balance feeds for FLSA Earnings
      l_count := l_count + 1;
      t_ipv_id(l_count) := get_obj_id('IPV', 'Pay Value', p_pri_ele_type_id);
      t_bal_id(l_count) := get_obj_id('BAL', 'FLSA Earnings');
      t_scale(l_count)  := 1;
      --
      l_count := l_count + 1;
      t_ipv_id(l_count) := get_obj_id('IPV', 'Pay Value', p_ssf_ele_type_id);
      t_bal_id(l_count) := get_obj_id('BAL', 'FLSA Earnings');
      t_scale(l_count)  := 1;
   END IF;
   IF p_reduce_regular = 'Y' THEN
      -- create balance feeds for Reduce Reg Hours input value
      l_count := l_count + 1;
      t_ipv_id(l_count) := get_obj_id('IPV', 'Reduce Reg Hours', p_asf_ele_type_id);
      t_bal_id(l_count) := get_obj_id('BAL', 'Regular Hours Worked');
      t_scale(l_count)  := -1;
      --
      l_count := l_count + 1;
      t_ipv_id(l_count) := get_obj_id('IPV', 'Reduce Reg Hours', p_asf_ele_type_id);
      t_bal_id(l_count) := get_obj_id('BAL', 'Regular Salary Hours');
      t_scale(l_count)  := -1;
      --
      l_count := l_count + 1;
      t_ipv_id(l_count) := get_obj_id('IPV', 'Reduce Reg Hours', p_asf_ele_type_id);
      t_bal_id(l_count) := get_obj_id('BAL', 'Regular Wages Hours');
      t_scale(l_count)  := -1;
      --
      -- create balance feeds for Reduce Reg Earnings input value
      --
      l_ipv_id := get_obj_id('IPV', 'Reduce Reg Pay', p_asf_ele_type_id);
      FOR c_rec1 IN get_reg_feeds LOOP
         l_count           := l_count + 1;
         t_ipv_id(l_count) := l_ipv_id;
         t_bal_id(l_count) := c_rec1.balance_type_id;
         t_scale(l_count)  := -1;
      END LOOP;
      --
   END IF;
   --
   FOR i in 1..l_count LOOP
       hr_balances.ins_balance_feed(
            p_option                      => 'INS_MANUAL_FEED',
            p_input_value_id              => t_ipv_id(i),
            p_element_type_id             => NULL,
            p_primary_classification_id   => NULL,
            p_sub_classification_id       => NULL,
            p_sub_classification_rule_id  => NULL,
            p_balance_type_id             => t_bal_id(i),
            p_scale                       => t_scale(i),
            p_session_date                => p_ele_eff_start_date,
            p_business_group              => g_bg_id,
            p_legislation_code            => NULL,
            p_mode                        => 'USER');
   END LOOP;
   hr_utility.set_location(l_proc, 70);
   --
END add_flsa_reduce_reg_feeds;
--===========================================================================
--                             Deletion procedure
--===========================================================================
PROCEDURE delete_ele_template_objects
           (p_business_group_id     in number
           ,p_ele_type_id           in number
           ,p_ele_name              in varchar2
           ,p_effective_date		in date
           ) IS
   --
   l_template_id   NUMBER(9);
   --
   l_proc  VARCHAR2(60) := 'pqp_earnings_template.delete_ele_template_objects';
   --
   CURSOR c1 is
   SELECT template_id
   FROM   pay_template_core_objects
   WHERE  core_object_type = 'ET'
     AND  core_object_id   = p_ele_type_id;

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
END delete_ele_template_objects;
--
END pqp_earnings_template;

/
