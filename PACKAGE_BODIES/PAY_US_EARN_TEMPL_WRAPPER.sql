--------------------------------------------------------
--  DDL for Package Body PAY_US_EARN_TEMPL_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_EARN_TEMPL_WRAPPER" AS
/* $Header: pyuseewr.pkb 120.6 2008/04/24 13:26:34 pvelugul noship $ */
FUNCTION create_earnings_element
         (p_ele_name              in varchar2
         ,p_ele_reporting_name    in varchar2
         ,p_ele_description       in varchar2
         ,p_ele_classification    in varchar2
         ,p_ele_category          in varchar2
         ,p_ele_ot_base           in varchar2
         ,p_flsa_hours            in varchar2
         ,p_ele_processing_type   in varchar2
         ,p_ele_priority          in number
         ,p_ele_standard_link     in varchar2
         ,p_ele_calc_ff_id        in number
         ,p_ele_calc_ff_name      in varchar2
         ,p_sep_check_option      in varchar2
         ,p_dedn_proc             in varchar2
         ,p_mix_flag              in varchar2
         ,p_reduce_regular        in varchar2
         ,p_ele_eff_start_date    in date
         ,p_ele_eff_end_date      in date
         ,p_alien_supp_category   in varchar2
         ,p_bg_id                 in number
         ,p_termination_rule      in varchar2 default 'F'
         ,p_stop_reach_rule       in varchar2 default 'N'
         ,p_student_earning       IN varchar2 default 'N'
         ,p_special_input_flag    IN varchar2 default 'N'
         ,p_special_feature_flag  IN varchar2 default 'Y'
         )
   RETURN NUMBER is
   --
   CURSOR c_architecture is
   SELECT parameter_value
    FROM  pay_action_parameters
   WHERE  parameter_name = 'US_ADVANCE_EARNING_TEMPLATE';

   CURSOR c_bg_name (p_bg_id NUMBER) IS
   SELECT name
    FROM per_business_groups
   WHERE business_group_id = p_bg_id;

   CURSOR c_get_ff_id (p_formula_name VARCHAR2) is
   SELECT formula_id
     FROM ff_formulas_f
    WHERE formula_name = p_formula_name
      AND legislation_code = 'US';


   l_ele_type_id   number;
   l_proc          varchar2(80) := 'pay_us_earn_temp_wrapper';
   l_architecture  varchar2(10) := 'Y';
   l_tw_rec                PAY_ELE_TMPLT_OBJ;
   l_sub_class             pay_ele_sub_class_table;
   l_freq_rule             pay_freq_rule_table;
   l_business_group_name   VARCHAR2 (240);
   l_ele_template_id       NUMBER;
   l_ele_priority          NUMBER;
   l_ele_calc_ff_name      VARCHAR2(100);
   l_ele_calc_ff_id        NUMBER;



BEGIN
   --     HR_UTILITY.TRACE_on(NULL,'rdhingra_pyuseewr');
   --
         hr_utility.trace('p_ele_name           -->' || p_ele_name);
         hr_utility.trace('p_ele_reporting_name -->' ||  p_ele_reporting_name);
         hr_utility.trace('p_ele_description    -->' ||  p_ele_description);
         hr_utility.trace('p_ele_classification -->' || p_ele_classification);
         hr_utility.trace('p_ele_category       -->' || p_ele_category);
         hr_utility.trace('p_ele_ot_base        -->' || p_ele_ot_base);
         hr_utility.trace('p_flsa_hours         -->' || p_flsa_hours);
         hr_utility.trace('p_ele_processing_type-->' || p_ele_processing_type);
         hr_utility.trace('p_ele_priority       -->' ||  p_ele_priority);
         hr_utility.trace('p_ele_standard_link  -->' ||   p_ele_standard_link);
         hr_utility.trace('p_ele_calc_ff_id     -->' ||    p_ele_calc_ff_id);
         hr_utility.trace('p_ele_calc_ff_name   -->' ||   p_ele_calc_ff_name);
         hr_utility.trace('p_sep_check_option   -->' || p_sep_check_option);
         hr_utility.trace('p_dedn_proc          -->' ||     p_dedn_proc);
         hr_utility.trace('p_mix_flag           -->' ||      p_mix_flag);
         hr_utility.trace('p_reduce_regular     -->' ||    p_reduce_regular);
         hr_utility.trace('p_ele_eff_start_date -->' || p_ele_eff_start_date);
         hr_utility.trace('p_ele_eff_end_date   -->' || p_ele_eff_end_date);
         hr_utility.trace('p_alien_supp_category-->' ||  p_alien_supp_category);
         hr_utility.trace('p_bg_id              -->' || p_bg_id );
         hr_utility.trace('p_termination_rule   -->' ||  p_termination_rule);
         hr_utility.trace('p_stop_reach_rule    -->' ||  p_stop_reach_rule);
         hr_utility.trace('p_student_earning    -->' || p_student_earning);
         hr_utility.trace('p_special_input_flag -->' || p_special_input_flag);
         hr_utility.trace('p_special_feature_flag-->'|| p_special_feature_flag);
-- =======================================================================
--  Initialize THE GLOBAL variables
-- =======================================================================

         g_ele_type_id        := NULL;



   /* Check if element is used without using new tempelate
      architecture  */

   open c_architecture;
   fetch c_architecture into l_architecture;
   close c_architecture;
   l_architecture :=   upper(substr(l_architecture,1,1));

   l_proc := l_proc||'.create_earnings_element';
   hr_utility.trace('Value of arch is ' || l_architecture);

   -- Correctly Set the formula name depending on the formula passed from
   -- the Earnings form
   IF p_ele_processing_type = 'R' THEN
--      IF p_ele_calc_ff_name = 'Flat Amount' THEN
      IF p_ele_calc_ff_id = 1 THEN
          l_ele_calc_ff_name := 'FLAT_AMOUNT_RECUR_V2';
--      ELSIF p_ele_calc_ff_name = 'Percent of Earnings' THEN
      ELSIF p_ele_calc_ff_id = 2 THEN
          l_ele_calc_ff_name := 'PERCENTAGE_OF_REG_EARNINGS_RECUR_V2';
--      ELSIF p_ele_calc_ff_name = 'Hours * Rate * Factor' THEN
      ELSIF p_ele_calc_ff_id = 3 THEN
          l_ele_calc_ff_name := 'HOURS_X_RATE_MULTIPLE_RECUR_V2';
--      ELSIF p_ele_calc_ff_name = 'Premium' THEN
      ELSIF p_ele_calc_ff_id = 4 THEN
          l_ele_calc_ff_name := 'PREMIUM_RECUR_V2';
          l_architecture := 'Y';
      END IF;
   ELSE
--      IF p_ele_calc_ff_name = 'Flat Amount' THEN
      IF p_ele_calc_ff_id = 1 THEN
          l_ele_calc_ff_name := 'FLAT_AMOUNT_NONRECUR_V2';
--      ELSIF p_ele_calc_ff_name = 'Percent of Earnings' THEN
      ELSIF p_ele_calc_ff_id = 2 THEN
          l_ele_calc_ff_name := 'PERCENTAGE_OF_REG_EARNINGS_NONRECUR_V2';
--      ELSIF p_ele_calc_ff_name = 'Hours * Rate * Factor' THEN
      ELSIF p_ele_calc_ff_id = 3 THEN
          l_ele_calc_ff_name := 'HOURS_X_RATE_MULTIPLE_NONRECUR_V2';
--      ELSIF p_ele_calc_ff_name = 'Premium' THEN
      ELSIF p_ele_calc_ff_id = 4 THEN
          l_ele_calc_ff_name := 'PREMIUM_NONRECUR_V2';
          l_architecture := 'Y';
      END IF;
   END IF; /* IF p_ele_processing_type = 'R' */


   -- Get the formula ID associated with the above formuls
   open c_get_ff_id(l_ele_calc_ff_name);
   fetch c_get_ff_id into l_ele_calc_ff_id;
   close c_get_ff_id;

   l_ele_calc_ff_id := nvl(l_ele_calc_ff_id, 1);

   --
     IF p_ele_classification = 'Alien/Expat Earnings' THEN
      --
      l_ele_type_id := pqp_earnings_template.create_ele_template_objects
          (p_ele_name            =>  p_ele_name
          ,p_ele_reporting_name  =>  p_ele_reporting_name
          ,p_ele_description     =>  p_ele_description
          ,p_ele_classification  =>  p_ele_classification
          ,p_ele_category        =>  p_ele_category
          ,p_ele_processing_type =>  p_ele_processing_type
          ,p_ele_priority        =>  p_ele_priority
          ,p_ele_standard_link   =>  p_ele_standard_link
          ,p_ele_ot_base         =>  p_ele_ot_base
          ,p_flsa_hours          =>  p_flsa_hours
          ,p_ele_calc_ff_name    =>  l_ele_calc_ff_name
          ,p_sep_check_option    =>  p_sep_check_option
          ,p_dedn_proc           =>  p_dedn_proc
          ,p_reduce_regular      =>  p_reduce_regular
          ,p_ele_eff_start_date  =>  p_ele_eff_start_date
          ,p_ele_eff_end_date    =>  p_ele_eff_end_date
          ,p_supp_category       =>  p_alien_supp_category
          ,p_legislation_code    =>  'US'
          ,p_bg_id               =>  p_bg_id
          ,p_termination_rule      => p_termination_rule

          );
        hr_utility.set_location(l_proc, 20);

   ELSE /* Not Alien/Expat Earnings */

   IF NVL(l_architecture,'Y') =  'N' THEN
      --
      l_ele_type_id := hr_user_init_earn.do_insertions
         (p_ele_name              => p_ele_name
         ,p_ele_reporting_name    => p_ele_reporting_name
         ,p_ele_description       => p_ele_description
         ,p_ele_classification    => p_ele_classification
         ,p_ele_category          => p_ele_category
         ,p_ele_ot_base           => p_ele_ot_base
         ,p_flsa_hours            => p_flsa_hours
         ,p_ele_processing_type   => p_ele_processing_type
         ,p_ele_priority          => p_ele_priority
         ,p_ele_standard_link     => p_ele_standard_link
         ,p_ele_calc_ff_id        => l_ele_calc_ff_id
         ,p_ele_calc_ff_name      => l_ele_calc_ff_name
         ,p_sep_check_option      => p_sep_check_option
         ,p_dedn_proc             => p_dedn_proc
         ,p_mix_flag              => p_mix_flag
         ,p_reduce_regular        => p_reduce_regular
         ,p_ele_eff_start_date    => p_ele_eff_start_date
         ,p_ele_eff_end_date      => p_ele_eff_end_date
         ,p_bg_id                 => p_bg_id
         ,p_termination_rule      => p_termination_rule
         );
         hr_utility.set_location(l_proc, 30);
      --
       ELSE  /* Architecture */

      hr_utility.set_location('10. Start of new template call',10);

   l_tw_rec := PAY_ELE_TMPLT_OBJ(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                 NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                 NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                 NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                 NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                 NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                 NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                 NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                 NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                 NULL,NULL,NULL,NULL,NULL,NULL);

   l_sub_class := pay_ele_sub_class_table(NULL);
   l_freq_rule := pay_freq_rule_table(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);


      OPEN c_bg_name (p_bg_id);
      hr_utility.trace('102. Start of new template call'  );
      FETCH c_bg_name
      INTO l_tw_rec.business_group_name;
      hr_utility.trace('105. Start of new template call');
      CLOSE c_bg_name;

      /* Priority to be kept as 1526 for
         all reduce regular elements
	 all Regular Non-worked category elements
      */
      IF ((p_reduce_regular = 'Y') OR (p_ele_category = 'RN')) THEN
         l_ele_priority := 1526;
      ELSE
         l_ele_priority := p_ele_priority;
      END IF;

      hr_utility.trace('11. Start of new template call');
      -- FLSA Changes
      -- Need to modify the IF condition to include all Calculation
      -- rules for FLSA
      IF ((SUBSTR (l_ele_calc_ff_name, 1, 7) = 'PREMIUM') OR
          (SUBSTR (l_ele_calc_ff_name, 1, 12) = 'HOURS_X_RATE')
          ) THEN
--         hr_utility.trace_on(NULL, 'FLSA');
         hr_utility.trace('Using FLSA template');
         hr_utility.trace('p_ele_category = ' ||p_ele_category );
         hr_utility.trace('p_reduce_regular = ' || p_reduce_regular);
         hr_utility.trace('p_flsa_hours = ' || p_flsa_hours);
         hr_utility.trace('p_ele_ot_base = ' || p_ele_ot_base);
         hr_utility.trace('p_ele_processing_type = ' || p_ele_processing_type);
         hr_utility.trace('p_ele_eff_start_date = ' || p_ele_eff_start_date);
         hr_utility.trace('p_ele_classification = ' || p_ele_classification);
         hr_utility.trace('p_ele_name = ' || p_ele_name);
         hr_utility.trace('p_ele_calc_ff_name = ' || l_ele_calc_ff_name);
         hr_utility.trace('p_student_earning = ' || p_student_earning);
         hr_utility.trace('p_dedn_proc = ' || p_dedn_proc);
         hr_utility.trace('p_ele_priority = ' || p_ele_priority);
         hr_utility.trace('p_sep_check_option = ' || p_sep_check_option);
         hr_utility.trace('p_special_input_flag = ' || p_special_input_flag);
         hr_utility.trace('p_stop_reach_rule = ' || p_stop_reach_rule);
         hr_utility.trace('p_ele_processing_type = ' || p_ele_processing_type);
         hr_utility.trace('p_ele_standard_link = ' || p_ele_standard_link);
         hr_utility.trace('p_termination_rule = ' || p_termination_rule);

         IF (SUBSTR (l_ele_calc_ff_name, 1, 7) = 'PREMIUM') THEN
         -- Modifying the Priority of PREMIUM Elements
            l_ele_priority := 3300;
         END IF;


         l_tw_rec.calculation_rule := 'US FLSA ' || p_ele_classification;
         l_tw_rec.configuration_info_category      := p_ele_category;
         l_tw_rec.configuration_information5       := nvl(p_reduce_regular
                                                         ,'N');
         l_tw_rec.configuration_information6       := nvl(p_flsa_hours, 'N');
         l_tw_rec.configuration_information7       := nvl(p_ele_ot_base, 'N');
         l_tw_rec.configuration_information8       := nvl(p_ele_processing_type
                                                         ,'N');
         l_tw_rec.effective_date                   := p_ele_eff_start_date;
         l_tw_rec.element_classification           := p_ele_classification;
         l_tw_rec.element_description              := p_ele_description;
         l_tw_rec.element_name                     := p_ele_name;
         l_tw_rec.input_currency_code              := 'USD';
         l_tw_rec.legislation_code                 := 'US';
         l_tw_rec.multiple_entries_allowed         := 'N';
         l_tw_rec.preference_information1          := l_ele_calc_ff_name;
         l_tw_rec.preference_information2          := nvl(p_student_earning,'N');
         l_tw_rec.preference_information3          := 'Y';
         l_tw_rec.preference_information4          := p_ele_eff_end_date;
         l_tw_rec.preference_information5          := NULL;
         l_tw_rec.preference_information6          := p_dedn_proc;
         l_tw_rec.preference_information8          := p_sep_check_option;
         l_tw_rec.preference_information10         := 'Y';
         l_tw_rec.preference_information14         := nvl(p_special_input_flag,'N');
         l_tw_rec.preference_information15         := nvl(p_stop_reach_rule,'N');
         l_tw_rec.proc_once_pay_period             := 'Y';
         l_tw_rec.process_mode                     := 'N';
         l_tw_rec.processing_priority              := l_ele_priority;
         l_tw_rec.processing_type                  := nvl(p_ele_processing_type
                                                         ,'N');
         l_tw_rec.reporting_name                   := nvl(p_ele_reporting_name,p_ele_name);
         l_tw_rec.standard_link                    := p_ele_standard_link;
         l_tw_rec.termination_rule                 := p_termination_rule;
      ELSE
         hr_utility.trace('Using US Earnings template');
         l_tw_rec.calculation_rule                 := 'US ' || p_ele_classification;
         l_tw_rec.configuration_info_category      := p_ele_category;
         l_tw_rec.configuration_information1       := 'Y';
         l_tw_rec.configuration_information2       := 'N';
         l_tw_rec.configuration_information3       := 'N';
         l_tw_rec.configuration_information7       := nvl(p_ele_ot_base, 'N');
         l_tw_rec.configuration_information8       := 'N';
         l_tw_rec.configuration_information11      := 'N';
         l_tw_rec.configuration_information12      := 'N';
         l_tw_rec.configuration_information13      := nvl(p_reduce_regular
                                                         ,'N');
         l_tw_rec.configuration_information23      := nvl(p_ele_processing_type
                                                         ,'N');
         l_tw_rec.effective_date                   := p_ele_eff_start_date;
         l_tw_rec.element_classification           := p_ele_classification;
         l_tw_rec.element_description              := p_ele_description;
         l_tw_rec.element_name                     := p_ele_name;
         l_tw_rec.input_currency_code              := 'USD';
         l_tw_rec.legislation_code                 := 'US';
         l_tw_rec.multiple_entries_allowed         := 'N';
         l_tw_rec.preference_information1          := l_ele_calc_ff_name;
         l_tw_rec.preference_information2          := nvl(p_student_earning,'N');
         l_tw_rec.preference_information3          := 'Y';
         l_tw_rec.preference_information4          := p_ele_eff_end_date;
         l_tw_rec.preference_information5          := NULL;
         l_tw_rec.preference_information6          := p_dedn_proc;
         l_tw_rec.preference_information8          := p_sep_check_option;
         l_tw_rec.preference_information10         := 'Y';
         l_tw_rec.preference_information14         := nvl(p_special_input_flag,'N');
         l_tw_rec.preference_information15         := nvl(p_stop_reach_rule,'N');
         l_tw_rec.proc_once_pay_period             := 'Y';
         l_tw_rec.process_mode                     := 'N';
         l_tw_rec.processing_priority              := l_ele_priority;
         l_tw_rec.processing_type                  := NVL(p_ele_processing_type
                                                          ,'N');
         l_tw_rec.reporting_name                   := nvl(p_ele_reporting_name,p_ele_name);
         l_tw_rec.standard_link                    := p_ele_standard_link;
         l_tw_rec.termination_rule                 := p_termination_rule;
      END IF;

      hr_utility.trace('20. Calling pay_us_earnings_template.create_element');

      /* New Call */
      pay_element_template_user_init.create_element
                     (p_validate           => FALSE,
                      p_save_for_later     => 'N',
                      p_rec                => l_tw_rec,
                      p_sub_class          => l_sub_class,
                      p_freq_rule          => l_freq_rule,
                      p_ele_template_id    => l_ele_template_id
                     );
       l_ele_type_id := g_ele_type_id;


          /* Currently Special Feature flag is always 'Y' */
          /*l_ele_type_id :=
          pay_us_earnings_template.create_ele_template_objects
          (p_ele_name              => p_ele_name
          ,p_ele_reporting_name    => p_ele_reporting_name
          ,p_ele_description       => p_ele_description
          ,p_ele_classification    => p_ele_classification
          ,p_ele_category          => p_ele_category
          ,p_ele_processing_type   => p_ele_processing_type
          ,p_ele_priority          => p_ele_priority
          ,p_ele_standard_link     => p_ele_standard_link
          ,p_ele_ot_base           => p_ele_ot_base
          ,p_flsa_hours            => p_flsa_hours
       --   ,p_ele_calc_ff_id      => p_ele_calc_ff_id
          ,p_ele_calc_ff_name      => p_ele_calc_ff_name
          ,p_sep_check_option      => p_sep_check_option
          ,p_dedn_proc             => p_dedn_proc
          ,p_reduce_regular        => p_reduce_regular
      --    ,p_mix_flag            => p_mix_flag
          ,p_ele_eff_start_date    => p_ele_eff_start_date
          ,p_ele_eff_end_date      => p_ele_eff_end_date
          ,p_supp_category         =>  NULL
          ,p_legislation_code      => 'US'
          ,p_bg_id                 => p_bg_id
          ,p_termination_rule      => p_termination_rule
          ,p_stop_reach_rule       => p_stop_reach_rule
          ,p_student_earning       => p_student_earning
          ,p_special_input_flag    => p_special_input_flag
          ,p_special_feature_flag  => 'Y'
          );*/

          hr_utility.set_location(l_proc, 35);
      END IF; /* architecture */
END IF; /* Alien/Expat Earnings */


   --
   RETURN (l_ele_type_id);
   --
   hr_utility.set_location('Leaving '||l_proc, 50);
   --
  -- HR_UTILITY.TRACE_OFF;
END create_earnings_element;




-------------------------------------------------------------------------------
--                      DELETE_EARNINGS_ELEMENT
-------------------------------------------------------------------------------
PROCEDURE delete_earnings_element
                       (p_business_group_id       in number
                       ,p_ele_type_id             in number
                       ,p_ele_name                in varchar2
                       ,p_ele_priority            in number
                       ,p_ele_primary_baltype_id  in varchar2     default null
                       ,p_ele_info_12             in varchar2     default null
                       ,p_session_date            in date
                       ,p_eff_start_date          in date
                       ,p_eff_end_date            in date
                       ,p_ele_classification      in varchar2
) IS
--
   l_proc           varchar2(80) := 'pay_us_earn_temp_wrapper';
   l_template_based number;
   l_template_id number;

CURSOR c1 is
   SELECT template_id
   FROM   pay_element_templates
   WHERE  base_name         = p_ele_name
     AND  business_group_id = p_business_group_id
     AND  template_type     = 'U';

BEGIN
   --
  -- HR_UTILITY.TRACE_on(NULL,'rdhingra_pyuseewr');
  open c1;
  fetch  c1 into l_template_id;
  Close c1;

  l_proc := l_proc||'.delete_earnings_element';
  hr_utility.set_location('Entering: '||l_proc, 10);
   --

  g_ele_type_id := p_ele_type_id;


  IF l_template_id is NOT NULL THEN
  /*    pay_us_earnings_template.delete_ele_template_objects
           (p_business_group_id  => p_business_group_id
           ,p_ele_type_id        => p_ele_type_id
           ,p_ele_name           => p_ele_name
           ,p_effective_date     => p_eff_start_date
           );
  */
      hr_utility.trace('Calling global package for delete');
      PAY_ELEMENT_TEMPLATE_USER_INIT.delete_element
      (
        p_validate => FALSE
       ,p_template_id => l_template_id
      );
      hr_utility.set_location(l_proc, 20);
      --
   ELSE
     -- call the old template deletion procedure
     hr_user_init_earn.do_deletions
           (p_business_group_id  => p_business_group_id
           ,p_ele_type_id        => p_ele_type_id
           ,p_ele_name           => p_ele_name
           ,p_ele_priority       => p_ele_priority
           ,p_ele_info_10        => p_ele_primary_baltype_id
           ,p_ele_info_12        => p_ele_info_12  -- p_ele_hours_baltype_id
           ,p_del_sess_date      => p_session_date
           ,p_del_val_start_date => p_eff_start_date
           ,p_del_val_end_date   => NULL
           );
      hr_utility.set_location(l_proc, 40);
      --
   END IF;
   --
   hr_utility.set_location('Leaving '||l_proc, 50);
   --
END delete_earnings_element;
--
--
END pay_us_earn_templ_wrapper;


/
