--------------------------------------------------------
--  DDL for Package PQP_PTY_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_PTY_RKD" AUTHID CURRENT_USER as
/* $Header: pqptyrhi.pkh 120.0.12000000.1 2007/01/16 04:29:04 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_effective_date                 in date
  ,p_datetrack_mode                 in varchar2
  ,p_validation_start_date          in date
  ,p_validation_end_date            in date
  ,p_pension_type_id                in number
  ,p_effective_start_date           in date
  ,p_effective_end_date             in date
  ,p_effective_start_date_o         in date
  ,p_effective_end_date_o           in date
  ,p_pension_type_name_o            in varchar2
  ,p_pension_category_o             in varchar2
  ,p_pension_provider_type_o        in varchar2
  ,p_salary_calculation_method_o    in varchar2
  ,p_threshold_conversion_rule_o    in varchar2
  ,p_contribution_conversion_ru_o   in varchar2
  ,p_er_annual_limit_o              in number
  ,p_ee_annual_limit_o              in number
  ,p_er_annual_salary_threshold_o   in number
  ,p_ee_annual_salary_threshold_o   in number
  ,p_object_version_number_o        in number
  ,p_business_group_id_o            in number
  ,p_legislation_code_o             in varchar2
  ,p_description_o                  in varchar2
  ,p_minimum_age_o                  in number
  ,p_ee_contribution_percent_o      in number
  ,p_maximum_age_o                  in number
  ,p_er_contribution_percent_o      in number
  ,p_ee_annual_contribution_o       in number
  ,p_er_annual_contribution_o       in number
  ,p_annual_premium_amount_o        in number
  ,p_ee_contribution_bal_type_i_o   in number
  ,p_er_contribution_bal_type_i_o   in number
  ,p_balance_init_element_type__o   in number
  ,p_ee_contribution_fixed_rate_o   in number  --added for UK
  ,p_er_contribution_fixed_rate_o   in number  --added for UK
  ,p_pty_attribute_category_o       in varchar2
  ,p_pty_attribute1_o               in varchar2
  ,p_pty_attribute2_o               in varchar2
  ,p_pty_attribute3_o               in varchar2
  ,p_pty_attribute4_o               in varchar2
  ,p_pty_attribute5_o               in varchar2
  ,p_pty_attribute6_o               in varchar2
  ,p_pty_attribute7_o               in varchar2
  ,p_pty_attribute8_o               in varchar2
  ,p_pty_attribute9_o               in varchar2
  ,p_pty_attribute10_o              in varchar2
  ,p_pty_attribute11_o              in varchar2
  ,p_pty_attribute12_o              in varchar2
  ,p_pty_attribute13_o              in varchar2
  ,p_pty_attribute14_o              in varchar2
  ,p_pty_attribute15_o              in varchar2
  ,p_pty_attribute16_o              in varchar2
  ,p_pty_attribute17_o              in varchar2
  ,p_pty_attribute18_o              in varchar2
  ,p_pty_attribute19_o              in varchar2
  ,p_pty_attribute20_o              in varchar2
  ,p_pty_information_category_o     in varchar2
  ,p_pty_information1_o             in varchar2
  ,p_pty_information2_o             in varchar2
  ,p_pty_information3_o             in varchar2
  ,p_pty_information4_o             in varchar2
  ,p_pty_information5_o             in varchar2
  ,p_pty_information6_o             in varchar2
  ,p_pty_information7_o             in varchar2
  ,p_pty_information8_o             in varchar2
  ,p_pty_information9_o             in varchar2
  ,p_pty_information10_o            in varchar2
  ,p_pty_information11_o            in varchar2
  ,p_pty_information12_o            in varchar2
  ,p_pty_information13_o            in varchar2
  ,p_pty_information14_o            in varchar2
  ,p_pty_information15_o            in varchar2
  ,p_pty_information16_o            in varchar2
  ,p_pty_information17_o            in varchar2
  ,p_pty_information18_o            in varchar2
  ,p_pty_information19_o            in varchar2
  ,p_pty_information20_o            in varchar2
  ,p_special_pension_type_code_o    in varchar2    -- added for NL Phase 2B
  ,p_pension_sub_category_o         in varchar2    -- added for NL Phase 2B
  ,p_pension_basis_calc_method_o    in varchar2    -- added for NL Phase 2B
  ,p_pension_salary_balance_o       in number      -- added for NL Phase 2B
  ,p_recurring_bonus_percent_o      in number      -- added for NL Phase 2B
  ,p_non_recur_bonus_percent_o      in number      -- added for NL Phase 2B
  ,p_recurring_bonus_balance_o      in number      -- added for NL Phase 2B
  ,p_non_recur_bonus_balance_o      in number      -- added for NL Phase 2B
  ,p_std_tax_reduction_o            in varchar2    -- added for NL Phase 2B
  ,p_spl_tax_reduction_o            in varchar2    -- added for NL Phase 2B
  ,p_sig_sal_spl_tax_reduction_o    in varchar2    -- added for NL Phase 2B
  ,p_sig_sal_non_tax_reduction_o    in varchar2    -- added for NL Phase 2B
  ,p_sig_sal_std_tax_reduction_o    in varchar2    -- added for NL Phase 2B
  ,p_sii_std_tax_reduction_o        in varchar2    -- added for NL Phase 2B
  ,p_sii_spl_tax_reduction_o        in varchar2    -- added for NL Phase 2B
  ,p_sii_non_tax_reduction_o        in varchar2    -- added for NL Phase 2B
  ,p_prev_year_bonus_include_o      in varchar2    -- added for NL Phase 2B
  ,p_recurring_bonus_period_o       in varchar2    -- added for NL Phase 2B
  ,p_non_recurring_bonus_period_o   in varchar2    -- added for NL Phase 2B
  ,p_ee_age_threshold_o             in varchar2    -- added for ABP TAR Fixes
  ,p_er_age_threshold_o             in varchar2    -- added for ABP TAR Fixes
  ,p_ee_age_contribution_o          in varchar2    -- added for ABP TAR Fixes
  ,p_er_age_contribution_o          in varchar2    -- added for ABP TAR Fixes
  );
--
end pqp_pty_rkd;

/
