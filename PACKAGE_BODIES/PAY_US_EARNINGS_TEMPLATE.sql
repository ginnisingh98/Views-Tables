--------------------------------------------------------
--  DDL for Package Body PAY_US_EARNINGS_TEMPLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_EARNINGS_TEMPLATE" AS
/* $Header: payusearningtemp.pkb 120.0.12010000.1 2008/07/27 21:55:06 appldev ship $ */
-- =======================================================================
--  DECLARE THE GLOBAL variables
-- =======================================================================
g_bg_id             NUMBER;
g_legislation_code  VARCHAR2(60);
-- =======================================================================
--                        CREATE_ELE_TEMPLATE_OBJECTS
-- =======================================================================
FUNCTION create_ele_template_objects
           (p_ele_name              IN VARCHAR2
           ,p_ele_reporting_name    IN VARCHAR2
           ,p_ele_description       IN VARCHAR2     DEFAULT NULL
           ,p_ele_classification    IN VARCHAR2
           ,p_ele_category          IN VARCHAR2     DEFAULT NULL
           ,p_ele_processing_type   IN VARCHAR2
           ,p_ele_priority          IN NUMBER       DEFAULT NULL
           ,p_ele_standard_link     IN VARCHAR2     DEFAULT 'N'
           ,p_ele_ot_base           IN VARCHAR2     DEFAULT 'N'
           ,p_flsa_hours            IN VARCHAR2
           ,p_ele_calc_ff_name      IN VARCHAR2
           ,p_sep_check_option      IN VARCHAR2     DEFAULT 'N'
           ,p_dedn_proc             IN VARCHAR2
           ,p_reduce_regular        IN VARCHAR2     DEFAULT 'N'
           ,p_ele_eff_start_date    IN DATE         DEFAULT NULL
           ,p_ele_eff_end_date      IN DATE         DEFAULT NULL
           ,p_supp_category         IN VARCHAR2
           ,p_legislation_code      IN VARCHAR2
           ,p_bg_id                 IN NUMBER
           ,p_termination_rule      IN VARCHAR2     DEFAULT 'F'
           ,p_stop_reach_rule       IN VARCHAR2     DEFAULT 'N'
           ,p_student_earning       IN VARCHAR2     DEFAULT 'N'
           ,p_special_input_flag    IN VARCHAR2     DEFAULT 'N'
           ,p_special_feature_flag  IN VARCHAR2     DEFAULT 'Y'
           )
   RETURN NUMBER IS
   --
   TYPE   TypeIdNumber    IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   TYPE   TypeIdChar      IS TABLE OF VARCHAR2(10) INDEX BY BINARY_INTEGER;

   t_bal_id               TypeIdNumber;
   t_form_id              TypeIdNumber;
   t_ipv_id               TypeIdNumber;
   t_def_val              TypeIdChar;
   t_we_flag              TypeIdChar;
   l_asg_gre_run_dim_id   pay_balance_dimensions.balance_dimension_id%TYPE;

   l_config2_amt          CHAR(1) := 'N';
   l_config3_perc         CHAR(1) := 'N';
   l_config4_hr           CHAR(1) := 'N';
   l_config5_hrm          CHAR(1) := 'N';
   l_config2_NR_amt       CHAR(1);
   l_config2_RSI_amt      CHAR(1);
   l_config3_NR_perc      CHAR(1);
   l_config3_RSI_perc     CHAR(1);
   l_config4_NR_hr        CHAR(1);
   l_config4_RSI_hr       CHAR(1);
   l_multiple_entries     CHAR(1) := 'N';

   l_hours_bal_id         NUMBER;
   l_ipv_id               NUMBER;
   l_ovn                  NUMBER;
   l_pri_bal_id           NUMBER;
   l_pri_ele_type_id      NUMBER;
   l_repl_bal_id          NUMBER;
   l_si_ele_type_id       NUMBER;
   l_sf_ele_type_id       NUMBER;
   l_ssf_ele_type_id      NUMBER;
   l_source_template_id   NUMBER;
   l_supp_bal_id          NUMBER;
   l_template_id          NUMBER;
   l_counter              NUMBER;
   l_addl_bal_id          NUMBER;
   l_element_type_id      NUMBER;
   l_si_rel_priority      NUMBER;
   l_sf_rel_priority      NUMBER;
   l_element_priority     NUMBER;
   l_hr_ele_id            NUMBER;
   l_hr_iv_id             NUMBER;
   l_rr_id                NUMBER;
   l_stat_proc_rule_id    NUMBER;
   l_cat_bal_type_id      NUMBER;
   l_ele_type_usages      VARCHAR2(1);
   l_calc_type            VARCHAR2(30);
   l_category_bal_name    VARCHAR2(60);
   l_temp_ele_name        VARCHAR2(255);
   l_template_name        VARCHAR2(50);
   l_proc                 VARCHAR2(80)   := 'pay_us_earnings_template.create_ele_template_objects';
   l_info_category        VARCHAR2(50);
   l_skip_formula         VARCHAR2(50);
   l_si_flag              VARCHAR2(1)    := 'Y';
   l_sf_flag              VARCHAR2(1)    := 'N';
   l_sf_iv_flag           VARCHAR2(1);
   l_se_iv_flag           VARCHAR2(1);
   l_stop_reach_flag      VARCHAR2(1);
   l_reg_earning_flag     VARCHAR2(1)    := 'N';
   l_supp_earn_flag       VARCHAR2(1)    := 'N';
   l_red_reg_hour_xrule_flag VARCHAR2(1) := 'N';

   l_formula_text1        LONG;
   l_formula_text2        LONG;
   --
   -- cursor to fetch the new element type id
   --
   CURSOR c_element(p_ele_name    VARCHAR2,
                    p_template_id NUMBER) IS
   SELECT element_type_id,
          object_version_number
   FROM   pay_shadow_element_types
   WHERE  element_name = p_ele_name
   AND    template_id  = p_template_id;
   --
   -- cursor to get the template id
   --
   CURSOR c_template(p_template_name VARCHAR2)  IS
   SELECT template_id
   FROM   pay_element_templates
   WHERE  template_name    = p_template_name
   AND    legislation_code = p_legislation_code
   AND    template_type    = 'T'
   AND    business_group_id IS NULL;

  -- Added the following cursor - tmehra for the balance architecture changes
  -- AS per US Payroll Team request

   CURSOR get_asg_gre_run_dim_id IS
   SELECT balance_dimension_id
   FROM pay_balance_dimensions
   WHERE dimension_name = 'Assignment within Government Reporting Entity Run'
   AND legislation_code = 'US';

   CURSOR c_get_shadow_formula(p_formula_name IN VARCHAR) IS
   SELECT formula_text
   FROM   pay_shadow_formulas
   WHERE  formula_name = p_formula_name;

   CURSOR c_ele_priority(p_classification_name IN VARCHAR2) IS
   SELECT default_priority
   FROM   pay_element_classifications
   WHERE  classification_name = p_classification_name;

   CURSOR c_ele(p_element_name IN VARCHAR2) IS
   SELECT element_type_id
   FROM   pay_element_types_f
   WHERE  upper(element_name) = upper(p_element_name)
   AND    legislation_code = 'US';

   CURSOR c_inp_val(p_input_val_name IN VARCHAR2,
                    p_element_type_id IN NUMBER) IS
   SELECT input_value_id
   FROM   pay_input_values_f
   WHERE  element_type_id = p_element_type_id
   AND    upper(NAME) = upper(p_input_val_name);

   CURSOR c_pspr(p_element_type_id IN NUMBER,
                 p_bg_id           IN NUMBER,
                 p_assgn_status_id IN NUMBER) IS
   SELECT status_processing_rule_id
   FROM   pay_status_processing_rules_f
   WHERE  element_type_id = p_element_type_id
   AND    business_group_id = p_bg_id;
  -- AND    assignment_status_type_id = p_assgn_status_id;

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
   hr_utility.set_location(l_proc, 20);
   -------------------
   -- Set session date
   -------------------
   pay_db_pay_setup.set_session_date(nvl(p_ele_eff_start_date, sysdate));
   hr_utility.set_location(l_proc, 30);
   -- IMPORTANT NOTE :
   -- The skip rules are removed from all the earnings. This have been
   -- replaced with entry in pay_element_type_usages table and c code
   -- changes.This Changes are made to imporve the performance of the payroll
   -- run. It was observed that loading of the Formula takes longer time
   -- The script pypusetd.sql seeds the element type usages. For all
   -- Regular earning and Imputed earnings we rows will be added in
   -- pay_elememnt_type_usages table so that this element will not
   -- be run in supplement run. Both BASE ELEMENT and SPECIAL INPUT
   -- element will be not be processed.
   -- local variable l_ele_type_usages controls the exclusion rules

   -------------------------
   -- Determine the priority
   -------------------------
   FOR c_ep IN c_ele_priority(p_ele_classification)
   LOOP
        l_element_priority := c_ep.default_priority;
   END LOOP;
   IF (p_ele_classification = 'Earnings') THEN
        l_si_rel_priority := -249;
        l_sf_rel_priority := 250;
        l_info_category   := 'US_EARNINGS';
        l_skip_formula := NULL;
    ELSIF (p_ele_classification = 'Supplemental Earnings') THEN
        l_si_rel_priority := -499;
        l_sf_rel_priority := 500;
        l_info_category   := 'US_SUPPLEMENTAL EARNINGS';
        l_ele_type_usages := 'N';
        l_skip_formula   := NULL;
    ELSIF (p_ele_classification = 'Imputed Earnings') THEN
        l_si_rel_priority := -249;
        l_sf_rel_priority := 250;
        l_info_category   := 'US_IMPUTED_EARNINGS';
        l_skip_formula    := NULL;
    ELSIF (p_ele_classification = 'Non-payroll Payments') THEN
        l_si_rel_priority := -249;
        l_sf_rel_priority := 250;
        l_info_category := 'US_NON-PAYROLL PAYMENTS';
        l_skip_formula := NULL;
        l_ele_type_usages := 'N';
    END IF;
    IF p_ele_priority IS NOT NULL THEN
        l_element_priority := p_ele_priority;
    END IF;
    hr_utility.set_location(l_proc, 40);
   --------------------------------------------
   -- set the appropriate exclusion rules
   --------------------------------------------
   -- The Configuration Flex segments for the Exclusion Rules are as follows:
   -- Config1 - Xclude SI and SF elements IF ele_processing_type='N'
   -- Config2 - Xclude objects IF calc type is Not Amount
   -- Config3 - Xclude objects IF calc type is Not Percentage
   -- Config4 - Xclude objects IF calc type is Not Rate * Hours
   -- Config5 - Xclude objects IF calc type is Not Rate * Hours with a multiple
   -- Config6 - Xclude objects IF FLSA hours is not checked
   -- Config7 - Xclude objects IF overtime base is not checked
   -- Config8 -
   -- Config9 -
   -- Config10 -
   -- Config11 -
   -- Config12 -
   -- Config13 -
   -- Config14 -
   -- Config15 -
   -- Config16 -
   -- Config17 -
   -- Config18 -
   -- Config19 -
   -- Config20 -
   -- Config22 - Element type usages exlusion rule. dont enter anyting for supplemental earning element
   IF (p_ele_category = 'REG') THEN
       l_reg_earning_flag := 'Y';
   END IF;
   IF (p_ele_classification = 'Supplemental Earnings') THEN
       l_supp_earn_flag := 'Y';
       l_ele_type_usages := 'N';
   END IF;

   IF (SUBSTR(p_ele_calc_ff_name,1,11) = 'FLAT_AMOUNT') THEN
      l_config2_amt  := 'Y';
      l_calc_type    := 'FLAT_AMOUNT';
   ELSIF (SUBSTR(p_ele_calc_ff_name,1,26) = 'PERCENTAGE_OF_REG_EARNINGS') THEN
      l_config3_perc := 'Y';
      l_calc_type    := 'PERCENTAGE';
   ELSIF (SUBSTR(p_ele_calc_ff_name,1,21) = 'HOURS_X_RATE_MULTIPLE') THEN
      l_config4_hr   := 'Y';
      l_config5_hrm  := 'Y';
      l_calc_type    := 'HOURS_X_RATE';
   ELSIF (SUBSTR(p_ele_calc_ff_name,1,12) = 'HOURS_X_RATE') THEN
      l_config4_hr   := 'Y';
      l_config5_hrm  := 'N';
      l_calc_type    := 'HOURS_X_RATE';
   END IF;

   hr_utility.set_location(l_proc,  50);

   l_si_flag := 'Y';
   IF ((p_ele_processing_type = 'N'
   -- AND p_termination_rule <> 'L'
       ) OR
      p_special_input_flag = 'N')  THEN
       l_si_flag := 'N';
   END IF;

   IF (p_special_feature_flag = 'Y') THEN
       l_sf_flag    := 'Y';
       l_sf_iv_flag := 'N';
   ELSE
       l_sf_flag    := 'N';
       l_sf_iv_flag := 'Y';
   END IF;
   l_se_iv_flag      := 'N';
   l_stop_reach_flag := 'N';

   IF (p_student_earning = 'Y') THEN
       l_sf_flag         := 'Y';
       l_se_iv_flag      := 'Y';
       l_sf_iv_flag      := 'N';
       l_stop_reach_flag := 'Y';
   --    l_multiple_entries :='N';
   END IF;
   IF (p_stop_reach_rule = 'Y') THEN
       l_stop_reach_flag := 'Y';
   END IF;
   hr_utility.set_location(l_proc,  60);

   l_config2_NR_amt   := 'N';
   l_config2_RSI_amt  := 'N';
   l_config3_NR_perc  := 'N';
   l_config3_RSI_perc := 'N';
   l_config4_NR_hr    := 'N';
   l_config4_RSI_hr   := 'N';

   IF (l_si_flag = 'Y') THEN
       IF (l_config2_amt = 'Y') THEN
           l_config2_RSI_amt := 'Y';
       elsIF (l_config3_perc = 'Y') THEN
           l_config3_RSI_perc := 'Y';
       elsIF (l_config5_hrm  = 'Y') THEN
           l_config4_RSI_hr := 'Y';
       elsIF (l_config4_hr   = 'Y') THEN
           l_config4_RSI_hr := 'Y';
       END IF;
   ELSE
       IF (l_config2_amt  = 'Y') THEN
           l_config2_NR_amt := 'Y';
       elsIF (l_config3_perc = 'Y') THEN
           l_config3_NR_perc := 'Y';
       elsIF (l_config5_hrm  = 'Y') THEN
           l_config4_NR_hr := 'Y';
       elsIF (l_config4_hr   = 'Y') THEN
           l_config4_NR_hr := 'Y';
       END IF;
   END IF;
   l_red_reg_hour_xrule_flag := 'N';
   IF (l_config4_hr = 'Y' ) THEN
       l_red_reg_hour_xrule_flag := 'Y';
   END IF;
   IF (p_reduce_regular = 'Y') THEN
       l_red_reg_hour_xrule_flag := 'N';
   END IF;

   hr_utility.set_location(l_proc, 70);
   ----------------------
   -- get the template id
   ----------------------
   l_template_name := 'US Earnings';
   l_temp_ele_name := p_ele_name ;

   FOR c_rec IN c_template(l_template_name) LOOP
      l_source_template_id := c_rec.template_id;
   END LOOP;

   hr_utility.set_location(l_proc, 70);

   pay_element_template_api.create_user_structure
      (p_validate                      =>     FALSE
      ,p_effective_date                =>     p_ele_eff_start_date
      ,p_business_group_id             =>     p_bg_id
      ,p_source_template_id            =>     l_source_template_id
      ,p_base_name                     =>     p_ele_name
      ,p_base_processing_priority      =>     l_element_priority
      ,p_configuration_info_category   =>     p_ele_category
      ,p_configuration_information1    =>     l_si_flag -- p_processing_type
      ,p_configuration_information2    =>     l_config2_amt
      ,p_configuration_information3    =>     l_config3_perc
      ,p_configuration_information4    =>     l_config4_hr
      ,p_configuration_information5    =>     l_config5_hrm
      ,p_configuration_information6    =>     p_flsa_hours
      ,p_configuration_information7    =>     p_ele_ot_base
      ,p_configuration_information8    =>     l_sf_flag
      ,p_configuration_information9    =>     l_sf_iv_flag
      ,p_configuration_information10   =>     l_se_iv_flag
      ,p_configuration_information11   =>     l_reg_earning_flag
      ,p_configuration_information12   =>     l_supp_earn_flag
      ,p_configuration_information13   =>     p_reduce_regular
      ,p_configuration_information14   =>     l_red_reg_hour_xrule_flag
      ,p_configuration_information15   =>     l_config2_NR_amt
      ,p_configuration_information16   =>     l_config2_RSI_amt
      ,p_configuration_information17   =>     l_config3_NR_perc
      ,p_configuration_information18   =>     l_config3_RSI_perc
      ,p_configuration_information19   =>     l_config4_NR_hr
      ,p_configuration_information20   =>     l_config4_RSI_hr
      ,p_configuration_information21   =>     l_stop_reach_flag
      ,p_configuration_information22   =>     l_ele_type_usages
      ,p_configuration_information23   =>     p_ele_processing_type
      ,p_template_id                   =>     l_template_id
      ,p_object_version_number         =>     l_ovn );

   hr_utility.set_location(l_proc, 80);
   -----------------------------------------------------------
   -- Update Base shadow Element with user-specified details
   -----------------------------------------------------------
   FOR c_rec IN c_element(l_temp_ele_name,
                          l_template_id)
   LOOP
       l_element_type_id  := c_rec.element_type_id;
       l_ovn              := c_rec.object_version_number;
   END LOOP;
   IF p_ele_processing_type = 'N' THEN
       l_multiple_entries := 'Y';
   END IF;
   hr_utility.set_location(l_proc, 90);

   pay_shadow_element_api.update_shadow_element
     (p_validate                     => FALSE
     ,p_effective_date               => p_ele_eff_start_date
     ,p_element_type_id              => l_element_type_id
     ,p_element_name                 => p_ele_name
     ,p_classification_name          => p_ele_classification
     ,p_description                  => p_ele_description
     ,p_reporting_name               => p_ele_reporting_name
     ,p_processing_type              => NVL(p_ele_processing_type,
                                                  hr_api.g_varchar2)
     ,p_standard_link_flag           => NVL(p_ele_standard_link,
                                                  hr_api.g_varchar2)
     ,p_multiple_entries_allowed_fla => l_multiple_entries
     ,p_post_termination_rule        => p_termination_rule
     , p_skip_formula                => l_skip_formula
     ,p_element_information_category => l_info_category --'US_SUPPLEMENTAL EARNINGS'
     ,p_element_information1         => NVL(p_ele_category, hr_api.g_varchar2)
     ,p_element_information8         => NVL(p_ele_ot_base, hr_api.g_varchar2)
     ,p_element_information11        => NVL(p_flsa_hours, hr_api.g_varchar2)
     ,p_element_information13        => NVL(p_reduce_regular, hr_api.g_varchar2)
     ,p_element_information14        => NVL(p_special_input_flag, hr_api.g_varchar2)
     ,p_element_information15        => NVL(p_stop_reach_rule, hr_api.g_varchar2)
     ,p_object_version_number        => l_ovn
     );

   hr_utility.set_location(l_proc, 100);
   -------------------------------------------------------------------
   -- Update user-specified details on Special Features Element.
   -------------------------------------------------------------------
    IF (l_sf_flag = 'Y') THEN
        FOR c1_rec IN c_element(p_ele_name ||' Special Features', l_template_id)
        LOOP
            l_element_type_id := c1_rec.element_type_id;
            l_ovn             := c1_rec.object_version_number;

            pay_shadow_element_api.update_shadow_element
                (p_validate              => FALSE
                ,p_reporting_name        => p_ele_reporting_name||' SF'
                ,p_classification_name   => p_ele_classification
                ,p_effective_date        => p_ele_eff_start_date
                ,p_element_type_id       => l_element_type_id
                ,p_description           => 'Special Features element for '||
				                                          p_ele_name
                ,p_relative_processing_priority =>l_sf_rel_priority
                ,p_element_information_category => l_info_category
                ,p_element_information1  => NVL(p_ele_category, hr_api.g_varchar2)
                ,p_element_information8  => NVL(p_ele_ot_base, hr_api.g_varchar2)
                ,p_object_version_number => l_ovn
            );
        END LOOP;
   END IF;
   hr_utility.set_location(l_proc, 110);
   --------------------------------------------------------------------
   -- Update user-specified Classification Special Inputs IF it exists.
   --------------------------------------------------------------------
   IF (l_si_flag  = 'Y') THEN
       FOR c1_rec IN c_element ( p_ele_name||' Special Inputs', l_template_id )
	   LOOP
           l_element_type_id := c1_rec.element_type_id;
           l_ovn             := c1_rec.object_version_number;
       END LOOP;
       pay_shadow_element_api.update_shadow_element
          (p_validate                 => FALSE
          ,p_reporting_name           => p_ele_reporting_name ||' SI'
          ,p_classification_name      => p_ele_classification
          ,p_effective_date           => p_ele_eff_start_date
          ,p_element_type_id          => l_element_type_id
          ,p_description              => 'Special Inputs element for '||
		                                      p_ele_name
          ,p_relative_processing_priority => l_si_rel_priority
          ,p_element_information_category => l_info_category
          ,p_element_information1     => NVL(p_ele_category, hr_api.g_varchar2)
          ,p_element_information8     => NVL(p_ele_ot_base, hr_api.g_varchar2)
          ,p_object_version_number    => l_ovn
         );
   END IF;
   hr_utility.set_location(l_proc, 120);
   ------------------------------------------------------------
   -- Generate Core Objects
   ------------------------------------------------------------
   pay_element_template_api.generate_part1
         (p_validate               =>     FALSE
         ,p_effective_date         =>     p_ele_eff_start_date
         ,p_hr_only                =>     FALSE
         ,p_hr_to_payroll          =>     FALSE
         ,p_template_id            =>     l_template_id);
   --
   hr_utility.set_location(l_proc, 130);
   --
   --  Add logic to generate part2 only IF payroll is installed
   --
   pay_element_template_api.generate_part2
         (p_validate               =>     FALSE
         ,p_effective_date         =>     p_ele_eff_start_date
         ,p_template_id            =>     l_template_id);
   hr_utility.set_location(l_proc, 140);
   --
   -------------------------------------------------------------------
   -- Get Element and Balance Id's to update the Further Information
   -------------------------------------------------------------------
   l_pri_bal_id       := get_obj_id('BAL', p_ele_name);
   l_addl_bal_id      := get_obj_id('BAL', p_ele_name||' Additional');
   l_repl_bal_id      := get_obj_id('BAL', p_ele_name||' Replacement');
   l_hours_bal_id     := get_obj_id('BAL', p_ele_name||' Hours');

   l_pri_ele_type_id  := get_obj_id('ELE', p_ele_name);
   l_si_ele_type_id   := get_obj_id('ELE', p_ele_name||' Special Inputs');
   l_sf_ele_type_id   := get_obj_id('ELE', p_ele_name||' Speacial Features');

   hr_utility.set_location(l_proc, 150);

   UPDATE pay_element_types_f
   SET    element_name           = p_ele_name
          ,element_information10 = l_pri_bal_id
          ,element_information12 = l_hours_bal_id
   WHERE  element_type_id       = l_pri_ele_type_id
   AND    business_group_id     = p_bg_id;

   hr_utility.set_location(l_proc, 160);

 -------------------------------------------------------------------
   -- Update Input values with default values, validation formula etc.
   -------------------------------------------------------------------
   t_ipv_id(1)  := get_obj_id('IPV', 'Deduction Processing', l_pri_ele_type_id);   t_form_id(1) := NULL;
   t_we_flag(1) := NULL;
   t_def_val(1) := p_dedn_proc;
   t_ipv_id(2)  := get_obj_id('IPV', 'Separate Check', l_pri_ele_type_id);
   t_form_id(2) := NULL;
   t_we_flag(2) := NULL;
   t_def_val(2) := p_sep_check_option;
   --
   hr_utility.set_location(l_proc, 170);
   FOR i in 1..2 LOOP
      UPDATE pay_input_values_f
      SET    formula_id       = t_form_id(i)
            ,warning_or_error = t_we_flag(i)
            ,default_value    = t_def_val(i)
      WHERE  input_value_id   = t_ipv_id(i);
   END LOOP;



   ------------------------------------
   -- Get the _ASG_GRE_RUN dimension id
   ------------------------------------

   FOR crec IN get_asg_gre_run_dim_id
   LOOP
       l_asg_gre_run_dim_id := crec.balance_dimension_id;
   END LOOP;
   --
   hr_utility.set_location(l_proc, 175);

   FOR c_rec IN c_ele('Hours by Rate')
   LOOP
       l_hr_ele_id := c_rec.element_type_id;
   END LOOP;
   FOR c_rec IN c_inp_val('Element Type Id', l_hr_ele_id)
   LOOP
       l_hr_iv_id := c_rec.input_value_id;
   END LOOP;
   hr_utility.set_location(l_proc, 180);
    IF (l_config4_hr = 'Y') THEN
        FOR c_rec IN c_pspr(p_element_type_id => l_pri_ele_type_id,
                            p_bg_id           => p_bg_id         ,
                            p_assgn_status_id => NULL)
        LOOP
            l_stat_proc_rule_id := c_rec.status_processing_rule_id;
        END LOOP;
        hr_utility.set_location(l_proc, 190);
        l_rr_id := pay_formula_results.ins_form_res_rule (
            p_business_group_id         => p_bg_id,
            p_legislation_code          => NULL,
            p_effective_start_date      => p_ele_eff_start_date,
            p_effective_end_date        => NULL,
            p_status_processing_rule_id => l_stat_proc_rule_id,
            p_element_type_id           => l_hr_ele_id,
            p_input_value_id            => l_hr_iv_id,
            p_result_name               => 'ELEMENT_TYPE_ID_PASSED',
            p_result_rule_type          => 'I',
            p_severity_level            => NULL);
        hr_utility.set_location(l_proc, 200);
        FOR c_rec IN c_inp_val('Hours', l_hr_ele_id)
        LOOP
            l_hr_iv_id := c_rec.input_value_id;
        END LOOP;
        hr_utility.set_location(l_proc, 210);
        l_rr_id := pay_formula_results.ins_form_res_rule (
            p_business_group_id             => p_bg_id,
            p_legislation_code              => NULL,
            p_effective_start_date          => p_ele_eff_start_date,
            p_effective_end_date            => NULL,
            p_status_processing_rule_id     => l_stat_proc_rule_id,
            p_element_type_id               => l_hr_ele_id,
            p_input_value_id                => l_hr_iv_id,
            p_result_name                   => 'HOURS_PASSED',
            p_result_rule_type              => 'I',
            p_severity_level                => NULL);
        hr_utility.set_location(l_proc, 220);
        IF (l_config5_hrm = 'Y') THEN
            FOR c_rec IN c_inp_val('Multiple', l_hr_ele_id)
            LOOP
                l_hr_iv_id := c_rec.input_value_id;
            END LOOP;
            hr_utility.set_location(l_proc, 230);

            l_rr_id := pay_formula_results.ins_form_res_rule (
                         p_business_group_id             => p_bg_id,
                         p_legislation_code              => NULL,
                         p_effective_start_date          => p_ele_eff_start_date,
                         p_effective_end_date            => NULL,
                         p_status_processing_rule_id     => l_stat_proc_rule_id,
                         p_element_type_id               => l_hr_ele_id,
                         p_input_value_id                => l_hr_iv_id,
                         p_result_name                   => 'MULTIPLE_PASSED',
                         p_result_rule_type              => 'I',
                         p_severity_level                => NULL);
        END IF;
        hr_utility.set_location(l_proc, 240);
        FOR c_rec IN c_inp_val('Rate', l_hr_ele_id)
        LOOP
            l_hr_iv_id := c_rec.input_value_id;
        END LOOP;
        hr_utility.set_location(l_proc, 250);
        l_rr_id := pay_formula_results.ins_form_res_rule (
                       p_business_group_id             => p_bg_id,
                       p_legislation_code              => NULL,
                       p_effective_start_date          => p_ele_eff_start_date,
                       p_effective_end_date            => NULL,
                       p_status_processing_rule_id     => l_stat_proc_rule_id,
                       p_element_type_id               => l_hr_ele_id,
                       p_input_value_id                => l_hr_iv_id,
                       p_result_name                   => 'RATE_PASSED',
                       p_result_rule_type              => 'I',
                       p_severity_level                => NULL);
        hr_utility.set_location(l_proc, 260);
    END IF;
    hr_utility.set_location('Leaving : '||l_proc, 290);
   -------------------------
   RETURN l_pri_ele_type_id;
   -------------------------
END create_ele_template_objects;
--=======================================================================
--                FUNCTION GET_OBJ_ID
--=======================================================================
FUNCTION get_obj_id (p_object_type   IN VARCHAR2
                    ,p_object_name   IN VARCHAR2
                    ,p_object_id     IN NUMBER    DEFAULT NULL )
RETURN NUMBER IS
   --
   l_object_id  NUMBER  := NULL;
   l_proc       VARCHAR2(60) := 'pay_us_earnings_template.get_obj_id';
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
   WHERE  piv.NAME              = p_object_name
   AND  piv.element_type_id   = p_object_id
   AND  piv.business_group_id = g_bg_id;
   --
   CURSOR c_get_bal_id IS  -- Gets the Balance type id
   SELECT balance_type_id
   FROM   pay_balance_types pbt
   WHERE  pbt.balance_name                            = p_object_name
   AND  NVL(pbt.business_group_id, g_bg_id)           = g_bg_id
   AND  NVL(pbt.legislation_code, g_legislation_code) = g_legislation_code;
   --
BEGIN
   hr_utility.set_location('Entering: '||l_proc, 10);
   --
   IF p_object_type = 'ELE' THEN
      FOR c_rec IN c_element LOOP
         l_object_id := c_rec.element_type_id;  -- element id
      END LOOP;
   ELSIF p_object_type = 'BAL' THEN
      FOR c_rec IN c_get_bal_id LOOP
         l_object_id := c_rec.balance_type_id;  -- balance id
      END LOOP;
   ELSIF p_object_type = 'IPV' THEN
      FOR c_rec IN c_get_ipv_id LOOP
         l_object_id := c_rec.input_value_id;   -- input value id
      END LOOP;
   END IF;
   hr_utility.set_location('Leaving: '||l_proc, 50);
   --
   RETURN l_object_id;
END get_obj_id;
--===========================================================================
--  Deletion procedure -- AG This can be reused.
--===========================================================================
PROCEDURE delete_ele_template_objects
           (p_business_group_id     IN NUMBER
           ,p_ele_type_id           IN NUMBER
           ,p_ele_name              IN VARCHAR2
           ,p_effective_date		IN DATE
           ) IS
   --
   l_template_id   NUMBER(9);
   --
   l_proc  VARCHAR2(60) := 'pay_earnings_template.delete_ele_template_objects';
   --
   CURSOR c1 IS
   SELECT template_id
   FROM   pay_element_templates
   WHERE  base_name         = p_ele_name
   AND  business_group_id = p_business_group_id
   AND  template_type     = 'U';
--
BEGIN
   --
   hr_utility.set_location('Entering :'||l_proc, 10);
   FOR c1_rec IN c1 LOOP
       l_template_id := c1_rec.template_id;
   END LOOP;
   --
   pay_element_template_api.delete_user_structure
     (p_validate                =>   FALSE
     ,p_drop_formula_packages   =>   TRUE
     ,p_template_id             =>   l_template_id);
   hr_utility.set_location('Leaving :'||l_proc, 50);
   --
END delete_ele_template_objects;
END pay_us_earnings_template;

/
