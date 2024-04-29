--------------------------------------------------------
--  DDL for Package Body PAY_US_DEDN_TEMPLATE_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_DEDN_TEMPLATE_WRAPPER" as
/* $Header: pytmpdde.pkb 120.1 2005/07/28 18:33:08 rpinjala noship $ */

   g_proc constant varchar2(150) := 'pay_us_dedn_template_wrapper';

-- =============================================================================
-- create_deduction_element:
-- =============================================================================
function create_deduction_element
         (p_element_name          in varchar2
         ,p_reporting_name        in varchar2
         ,p_description           in varchar2
         ,p_classification_name   in varchar2
         ,p_ben_class_id          in number
         ,p_category              in varchar2
         ,p_processing_type       in varchar2
         ,p_processing_priority   in number
         ,p_standard_link_flag    in varchar2
         ,p_processing_runtype    in varchar2
         ,p_start_rule            in varchar2
         ,p_stop_rule             in varchar2
         ,p_amount_rule           in varchar2
         ,p_series_ee_bond        in varchar2
         ,p_payroll_table         in varchar2
         ,p_paytab_column         in varchar2
         ,p_rowtype_meaning       in varchar2
         ,p_arrearage             in varchar2
         ,p_deduct_partial        in varchar2
         ,p_employer_match        in varchar2
         ,p_aftertax_component    in varchar2
         ,p_ele_eff_start_date    in date
         ,p_ele_eff_end_date      in date
         ,p_business_group_id     in number
         ,p_srs_plan_type         in varchar2
         ,p_srs_buy_back          in varchar2
         ,p_roth_contribution     in varchar2
         ,p_userra_contribution   in varchar2
         ,p_catchup_processing    in varchar2
         ,p_termination_rule      in varchar2
         )
  return number is

   l_architecture  varchar2(20);
   l_ele_type_id   number;
   l_proc          varchar2(80);
   l_upgrade_stat  varchar2(10);
   --
   -- Get the value for US_ADVANCED_WAGE_ATTACHMENT from pay_action_parameters
   --
   cursor c_architecture is
   select parameter_value
     from pay_action_parameters
    where parameter_name = 'US_ADVANCED_WAGE_ATTACHMENT';
   --
   -- Get the status of UPGRADE GARNISHMENT PROCESS Bug 3549298
   --
   cursor c_get_upg_stat(cp_business_group_id number) is
   select status
     from pay_upgrade_definitions pud,
          pay_upgrade_status pus
    where pud.short_name = 'US_INV_DEDN_UPGRADE'
      and pus.upgrade_definition_id = pud.upgrade_definition_id
      and pus.business_group_id = cp_business_group_id;

  begin
   --
   l_proc := g_proc||'.create_deduction_element';
   hr_utility.set_location('Entering: '||l_proc, 5);
   --
   -- Involuntary Deductions
   --
   if p_classification_name = 'Involuntary Deductions' then
      -- Bug 3777810
      l_architecture := null;
      l_upgrade_stat := null;

       open c_architecture;
      fetch c_architecture into l_architecture;
      close c_architecture;

       open c_get_upg_stat(p_business_group_id);
      fetch c_get_upg_stat into l_upgrade_stat;

      if c_get_upg_stat%FOUND then -- Upgrade Started
         l_architecture := 'Y';
      end if;

      close c_get_upg_stat;

      l_architecture := upper(substr(l_architecture,1,1));

      if l_architecture is not null and l_architecture = 'N' then
        -- Bug 3650283
        if p_category = 'DCIA' then
           hr_utility.set_location (l_proc,5);
           hr_utility.set_message(801,'PAY_US_DCIA_ERROR');
           hr_utility.raise_error;
        end if;
        l_ele_type_id :=
           hr_us_garn_gen.create_garnishment
           (p_garn_name           => p_element_name
           ,p_garn_reporting_name => p_reporting_name
           ,p_garn_description    => p_description
           ,p_category            => p_category
           ,p_bg_id               => p_business_group_id
           ,p_ele_eff_start_date  => p_ele_eff_start_date
           );
         hr_utility.set_location(l_proc, 15);
      else
         l_ele_type_id :=
           pay_us_user_init_dedn.create_user_init_template
           (p_ele_name                 => p_element_name
           ,p_ele_reporting_name       => p_reporting_name
           ,p_ele_description          => p_description
           ,p_ele_classification       => p_classification_name
           ,p_ele_category             => p_category
           ,p_ele_processing_type      => p_processing_type
           ,p_ele_priority             => p_processing_priority
           ,p_ele_standard_link        => p_standard_link_flag
           ,p_ele_proc_runtype         => p_processing_runtype
           ,p_ele_calc_rule            => p_amount_rule
           ,p_ele_start_rule           => p_start_rule
           ,p_ele_stop_rule            => p_stop_rule
           ,p_ele_partial_deduction    => p_deduct_partial
           ,p_ele_arrearage            => p_arrearage
           ,p_ele_eff_start_date       => p_ele_eff_start_date
           ,p_ele_eff_end_date         => p_ele_eff_end_date
           ,p_employer_match           => p_employer_match
           ,p_after_tax_component      => p_aftertax_component
           ,p_ele_srs_plan_type        => p_srs_plan_type
           ,p_ele_srs_buy_back         => p_srs_buy_back
           ,p_roth_contribution        => p_roth_contribution
           ,p_userra_contribution      => p_userra_contribution
           ,p_bg_id                    => p_business_group_id
           ,p_catchup_processing       => p_catchup_processing
           ,p_termination_rule         => p_termination_rule
           ,p_ben_class_id             => p_ben_class_id
           );
         hr_utility.set_location(l_proc, 20);
      end if;
   --
   -- Pre-Tax Deductions
   --
   elsif p_classification_name in ('Pre-Tax Deductions') then
      /*
          If the category is not in Health Care 125 and Dependent Care 125 THEN
          call the new deduction template else
          call the old deduction driver template

          Changes made by Tarun Mehra for inclusion of Def Comp 401k
          on 04-Jan-2000

          Changes made by Kumar Thirmiya for inclusion of User Defined Category
          on 28-Jun-2001

          -- old code
          -- p_category in ('E','G','Deferred Comp 403b','Deferred Comp 457')
             THEN
          -- p_category in ('E','G','D','Deferred Comp 401k','Deferred Comp
             403b','Deferred Comp 457') THEN
       */

      /* commented for bug 2400648
         Dependent Care and Health Care will be using the new template
            p_classification_name = 'Pre-Tax Deductions' AND
            p_category not in ('H','S','Health Care 125','Dependent Care 125')
      */

      l_ele_type_id :=
        pay_us_user_init_dedn.create_user_init_template
        (p_ele_name                 => p_element_name
        ,p_ele_reporting_name       => p_reporting_name
        ,p_ele_description          => p_description
        ,p_ele_classification       => p_classification_name
        ,p_ele_category             => p_category
        ,p_ele_processing_type      => p_processing_type
        ,p_ele_priority             => p_processing_priority
        ,p_ele_standard_link        => p_standard_link_flag
        ,p_ele_proc_runtype         => p_processing_runtype
        ,p_ele_calc_rule            => p_amount_rule
        ,p_ele_start_rule           => p_start_rule
        ,p_ele_stop_rule            => p_stop_rule
        ,p_ele_partial_deduction    => p_deduct_partial
        ,p_ele_arrearage            => p_arrearage
        ,p_ele_eff_start_date       => p_ele_eff_start_date
        ,p_ele_eff_end_date         => p_ele_eff_end_date
        ,p_employer_match           => p_employer_match
        ,p_after_tax_component      => p_aftertax_component
        ,p_ele_srs_plan_type        => p_srs_plan_type
        ,p_ele_srs_buy_back         => p_srs_buy_back
        ,p_roth_contribution        => p_roth_contribution
        ,p_userra_contribution      => p_userra_contribution
        ,p_bg_id                    => p_business_group_id
        ,p_catchup_processing       => p_catchup_processing
        ,p_termination_rule         => p_termination_rule
        ,p_ben_class_id             => p_ben_class_id
        );
      hr_utility.set_location(l_proc, 30);
   --
   -- Voluntary Deductions
   --
   else
      l_ele_type_id :=
        hr_user_dedn_drv.ins_deduction_template
        (p_ele_name             => p_element_name
        ,p_ele_reporting_name   => p_reporting_name
        ,p_ele_description      => p_description
        ,p_ele_classification   => p_classification_name
        ,p_ben_class_id         => p_ben_class_id
        ,p_ele_category         => p_category
        ,p_ele_processing_type  => p_processing_type
        ,p_ele_priority         => p_processing_priority
        ,p_ele_standard_link    => p_standard_link_flag
        ,p_ele_proc_runtype     => p_processing_runtype
        ,p_ele_start_rule       => p_start_rule
        ,p_ele_stop_rule        => p_stop_rule
        ,p_ele_ee_bond          => p_series_ee_bond
        ,p_ele_amount_rule      => p_amount_rule
        ,p_ele_paytab_name      => p_payroll_table
        ,p_ele_paytab_col       => p_paytab_column
        ,p_ele_paytab_row_type  => p_rowtype_meaning
        ,p_ele_arrearage        => p_arrearage
        ,p_ele_partial_dedn     => p_deduct_partial
        ,p_mix_flag             => null
        ,p_ele_er_match         => p_employer_match
        ,p_ele_at_component     => p_aftertax_component
        ,p_ele_eff_start_date   => p_ele_eff_start_date
        ,p_ele_eff_end_date     => p_ele_eff_end_date
        ,p_bg_id                => p_business_group_id
        ,p_termination_rule     => p_termination_rule
         );

      hr_utility.set_location(l_proc, 40);
      --
   end if;
   --
   return (l_ele_type_id);
   --
   hr_utility.set_location('Leaving '||l_proc, 50);
   --
END create_deduction_element;
--
--
-- =============================================================================
-- delete_deduction_element: To delete a user created template.
-- =============================================================================
PROCEDURE delete_deduction_element
         (p_business_group_id       in  number
         ,p_element_type_id         in  number
         ,p_element_name            in  varchar2
         ,p_classification_name     in  varchar2
         ,p_category                in  varchar2
         ,p_processing_priority     in  number
         ,p_amount_rule             in  varchar2
         ,p_series_ee_bond          in  varchar2
         ,p_arrearage               in  varchar2
         ,p_stop_rule               in  varchar2
         ,p_calculation_ele_id      in  number
         ,p_vol_dedns_baltype_id    in  number
         ,p_primary_baltype_id      in  number
         ,p_accrued_baltype_id      in  number
         ,p_arrears_baltype_id      in  number
         ,p_not_taken_baltype_id    in  number
         ,p_tobondpurch_baltype_id  in  number
         ,p_able_baltype_id         in  number
         ,p_additional_baltype_id   in  number
         ,p_replacement_baltype_id  in  number
         ,p_special_inputs_ele_id   in  number
         ,p_special_features_ele_id in  number
         ,p_verifier_ele_id         in  number
         ,p_eff_start_date          in  date
         ,p_eff_end_date            in  date
         ) IS
   --
   l_proc           varchar2(80);
   l_template_based number;
   --
   cursor c1 is
   select template_id
     from pay_element_templates
    where base_name         = p_element_name
      and business_group_id = p_business_group_id
      and template_type     = 'U';
   --
   cursor c2 is
   select element_type_extra_info_id
         ,object_version_number
     from pay_element_type_extra_info
    where element_type_id          = p_element_type_id
      and information_type         = 'PQP_US_PRE_TAX_DEDUCTIONS'
      and eei_information_category = 'PQP_US_PRE_TAX_DEDUCTIONS';
   --
  begin
   l_proc := g_proc||'.delete_deduction_element';
   hr_utility.set_location('Entering: '||l_proc, 5);

   if p_classification_name = 'Pre-Tax Deductions' then
      for c1_rec in c1 loop
          l_template_based := c1_rec.template_id;
      end loop;
   end if;
   hr_utility.set_location(l_proc, 10);
   --
   if p_classification_name = 'Involuntary Deductions' then
      --
      hr_us_garn_gen.delete_dedn
     (p_business_group_id  => p_business_group_id
     ,p_ele_type_id        => p_element_type_id
     ,p_ele_name           => p_element_name
     ,p_ele_priority       => p_processing_priority
     ,p_ele_info_10        => p_primary_baltype_id
     ,p_ele_info_11        => p_accrued_baltype_id
     ,p_ele_info_12        => p_arrears_baltype_id
     ,p_ele_info_13        => p_not_taken_baltype_id
     ,p_ele_info_14        => p_tobondpurch_baltype_id
     ,p_ele_info_15        => p_able_baltype_id
     ,p_ele_info_16        => p_additional_baltype_id
     ,p_ele_info_17        => p_replacement_baltype_id
     ,p_ele_info_18        => p_special_inputs_ele_id
     ,p_ele_info_19        => p_special_features_ele_id
     ,p_ele_info_20        => p_verifier_ele_id
     ,p_ele_info_5         => p_calculation_ele_id
     ,p_ele_info_8         => p_vol_dedns_baltype_id
     ,p_del_sess_date      => p_eff_start_date
     ,p_del_val_start_date => p_eff_start_date
     ,p_del_val_end_date   => p_eff_end_date
      );
      --
      hr_utility.set_location(l_proc, 20);
      --
   elsif p_classification_name = 'Pre-Tax Deductions' and
         l_template_based is not null then

      pay_us_user_init_dedn.delete_user_init_template
     (p_business_group_id  => p_business_group_id
     ,p_ele_type_id        => p_element_type_id
     ,p_ele_name           => p_element_name
     ,p_effective_date     => p_eff_start_date
      );
     -- Delete entry for Catch-up Processing (if present)
     -- from pay_element_type_extra_info table.
     for c2_rec in c2 loop
         pay_element_extra_info_api.delete_element_extra_info
        (p_validate                   => false
        ,p_element_type_extra_info_id => c2_rec.element_type_extra_info_id
        ,p_object_version_number      => c2_rec.object_version_number
            );
     end loop;
     --
     hr_utility.set_location(l_proc, 30);
     --
   else
      hr_user_init_dedn.do_deletions
     (p_business_group_id  => p_business_group_id
     ,p_ele_type_id        => p_element_type_id
     ,p_ele_name           => p_element_name
     ,p_ele_priority       => p_processing_priority
     ,p_ele_amount_rule    => p_amount_rule
     ,p_ele_ee_bond        => p_series_ee_bond
     ,p_ele_arrearage      => p_arrearage
     ,p_ele_stop_rule      => p_stop_rule
     ,p_ele_info_10        => p_primary_baltype_id
     ,p_ele_info_11        => p_accrued_baltype_id
     ,p_ele_info_12        => p_arrears_baltype_id
     ,p_ele_info_13        => p_not_taken_baltype_id
     ,p_ele_info_14        => p_tobondpurch_baltype_id
     ,p_ele_info_15        => p_able_baltype_id
     ,p_ele_info_16        => p_additional_baltype_id
     ,p_ele_info_17        => p_replacement_baltype_id
     ,p_ele_info_18        => p_special_inputs_ele_id
     ,p_ele_info_19        => p_special_features_ele_id
     ,p_ele_info_20        => p_verifier_ele_id
     ,p_del_sess_date      => p_eff_start_date
     ,p_del_val_start_date => p_eff_start_date
     ,p_del_val_end_date   => p_eff_end_date);
     --
     hr_utility.set_location(l_proc, 40);
   end if;
   --
   hr_utility.set_location('Leaving '||l_proc, 50);
   --
  end delete_deduction_element;
--
--
END pay_us_dedn_template_wrapper;

/
