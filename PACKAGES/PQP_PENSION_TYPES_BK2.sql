--------------------------------------------------------
--  DDL for Package PQP_PENSION_TYPES_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_PENSION_TYPES_BK2" AUTHID CURRENT_USER As
/* $Header: pqptyapi.pkh 120.1.12000000.1 2007/01/16 04:28:57 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< Update_Pension_Type_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure Update_Pension_Type_b
  (p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_pension_type_id              in     number
  ,p_object_version_number        in     number
  ,p_pension_type_name            in     varchar2
  ,p_pension_category             in     varchar2
  ,p_pension_provider_type        in     varchar2
  ,p_salary_calculation_method    in     varchar2
  ,p_threshold_conversion_rule    in     varchar2
  ,p_contribution_conversion_rule in     varchar2
  ,p_er_annual_limit              in     number
  ,p_ee_annual_limit              in     number
  ,p_er_annual_salary_threshold   in     number
  ,p_ee_annual_salary_threshold   in     number
  ,p_business_group_id            in     number
  ,p_legislation_code             in     varchar2
  ,p_description                  in     varchar2
  ,p_minimum_age                  in     number
  ,p_ee_contribution_percent      in     number
  ,p_maximum_age                  in     number
  ,p_er_contribution_percent      in     number
  ,p_ee_annual_contribution       in     number
  ,p_er_annual_contribution       in     number
  ,p_annual_premium_amount        in     number
  ,p_ee_contribution_bal_type_id  in     number
  ,p_er_contribution_bal_type_id  in     number
  ,p_balance_init_element_type_id in     number
  ,p_ee_contribution_fixed_rate   in     number --added for UK
  ,p_er_contribution_fixed_rate   in     number --added for UK
  ,p_pty_attribute_category       in     varchar2
  ,p_pty_attribute1               in     varchar2
  ,p_pty_attribute2               in     varchar2
  ,p_pty_attribute3               in     varchar2
  ,p_pty_attribute4               in     varchar2
  ,p_pty_attribute5               in     varchar2
  ,p_pty_attribute6               in     varchar2
  ,p_pty_attribute7               in     varchar2
  ,p_pty_attribute8               in     varchar2
  ,p_pty_attribute9               in     varchar2
  ,p_pty_attribute10              in     varchar2
  ,p_pty_attribute11              in     varchar2
  ,p_pty_attribute12              in     varchar2
  ,p_pty_attribute13              in     varchar2
  ,p_pty_attribute14              in     varchar2
  ,p_pty_attribute15              in     varchar2
  ,p_pty_attribute16              in     varchar2
  ,p_pty_attribute17              in     varchar2
  ,p_pty_attribute18              in     varchar2
  ,p_pty_attribute19              in     varchar2
  ,p_pty_attribute20              in     varchar2
  ,p_pty_information_category     in     varchar2
  ,p_pty_information1             in     varchar2
  ,p_pty_information2             in     varchar2
  ,p_pty_information3             in     varchar2
  ,p_pty_information4             in     varchar2
  ,p_pty_information5             in     varchar2
  ,p_pty_information6             in     varchar2
  ,p_pty_information7             in     varchar2
  ,p_pty_information8             in     varchar2
  ,p_pty_information9             in     varchar2
  ,p_pty_information10            in     varchar2
  ,p_pty_information11            in     varchar2
  ,p_pty_information12            in     varchar2
  ,p_pty_information13            in     varchar2
  ,p_pty_information14            in     varchar2
  ,p_pty_information15            in     varchar2
  ,p_pty_information16            in     varchar2
  ,p_pty_information17            in     varchar2
  ,p_pty_information18            in     varchar2
  ,p_pty_information19            in     varchar2
  ,p_pty_information20            in     varchar2
  ,p_special_pension_type_code    in     varchar2    -- added for NL Phase 2B
  ,p_pension_sub_category         in     varchar2    -- added for NL Phase 2B
  ,p_pension_basis_calc_method    in     varchar2    -- added for NL Phase 2B
  ,p_pension_salary_balance       in     number      -- added for NL Phase 2B
  ,p_recurring_bonus_percent      in     number      -- added for NL Phase 2B
  ,p_non_recurring_bonus_percent  in     number      -- added for NL Phase 2B
  ,p_recurring_bonus_balance      in     number      -- added for NL Phase 2B
  ,p_non_recurring_bonus_balance  in     number      -- added for NL Phase 2B
  ,p_std_tax_reduction            in     varchar2    -- added for NL Phase 2B
  ,p_spl_tax_reduction            in     varchar2    -- added for NL Phase 2B
  ,p_sig_sal_spl_tax_reduction    in     varchar2    -- added for NL Phase 2B
  ,p_sig_sal_non_tax_reduction    in     varchar2    -- added for NL Phase 2B
  ,p_sig_sal_std_tax_reduction    in     varchar2    -- added for NL Phase 2B
  ,p_sii_std_tax_reduction        in     varchar2    -- added for NL Phase 2B
  ,p_sii_spl_tax_reduction        in     varchar2    -- added for NL Phase 2B
  ,p_sii_non_tax_reduction        in     varchar2    -- added for NL Phase 2B
  ,p_previous_year_bonus_included in     varchar2    -- added for NL Phase 2B
  ,p_recurring_bonus_period       in     varchar2    -- added for NL Phase 2B
  ,p_non_recurring_bonus_period   in     varchar2    -- added for NL Phase 2B
  ,p_ee_age_threshold             in     varchar2    -- added for ABP TAR fixes
  ,p_er_age_threshold             in     varchar2    -- added for ABP TAR fixes
  ,p_ee_age_contribution          in     varchar2    -- added for ABP TAR fixes
  ,p_er_age_contribution          in     varchar2    -- added for ABP TAR fixes
  );

-- ----------------------------------------------------------------------------
-- |-------------------------< Update_Pension_Type_a >-------------------------|
-- ----------------------------------------------------------------------------
--
Procedure Update_Pension_Type_a
  (p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_pension_type_id              in     number
  ,p_object_version_number        in     number
  ,p_pension_type_name            in     varchar2
  ,p_pension_category             in     varchar2
  ,p_pension_provider_type        in     varchar2
  ,p_salary_calculation_method    in     varchar2
  ,p_threshold_conversion_rule    in     varchar2
  ,p_contribution_conversion_rule in     varchar2
  ,p_er_annual_limit              in     number
  ,p_ee_annual_limit              in     number
  ,p_er_annual_salary_threshold   in     number
  ,p_ee_annual_salary_threshold   in     number
  ,p_business_group_id            in     number
  ,p_legislation_code             in     varchar2
  ,p_description                  in     varchar2
  ,p_minimum_age                  in     number
  ,p_ee_contribution_percent      in     number
  ,p_maximum_age                  in     number
  ,p_er_contribution_percent      in     number
  ,p_ee_annual_contribution       in     number
  ,p_er_annual_contribution       in     number
  ,p_annual_premium_amount        in     number
  ,p_ee_contribution_bal_type_id  in     number
  ,p_er_contribution_bal_type_id  in     number
  ,p_balance_init_element_type_id in     number
  ,p_ee_contribution_fixed_rate   in     number --added for UK
  ,p_er_contribution_fixed_rate   in     number --added for UK
  ,p_pty_attribute_category       in     varchar2
  ,p_pty_attribute1               in     varchar2
  ,p_pty_attribute2               in     varchar2
  ,p_pty_attribute3               in     varchar2
  ,p_pty_attribute4               in     varchar2
  ,p_pty_attribute5               in     varchar2
  ,p_pty_attribute6               in     varchar2
  ,p_pty_attribute7               in     varchar2
  ,p_pty_attribute8               in     varchar2
  ,p_pty_attribute9               in     varchar2
  ,p_pty_attribute10              in     varchar2
  ,p_pty_attribute11              in     varchar2
  ,p_pty_attribute12              in     varchar2
  ,p_pty_attribute13              in     varchar2
  ,p_pty_attribute14              in     varchar2
  ,p_pty_attribute15              in     varchar2
  ,p_pty_attribute16              in     varchar2
  ,p_pty_attribute17              in     varchar2
  ,p_pty_attribute18              in     varchar2
  ,p_pty_attribute19              in     varchar2
  ,p_pty_attribute20              in     varchar2
  ,p_pty_information_category     in     varchar2
  ,p_pty_information1             in     varchar2
  ,p_pty_information2             in     varchar2
  ,p_pty_information3             in     varchar2
  ,p_pty_information4             in     varchar2
  ,p_pty_information5             in     varchar2
  ,p_pty_information6             in     varchar2
  ,p_pty_information7             in     varchar2
  ,p_pty_information8             in     varchar2
  ,p_pty_information9             in     varchar2
  ,p_pty_information10            in     varchar2
  ,p_pty_information11            in     varchar2
  ,p_pty_information12            in     varchar2
  ,p_pty_information13            in     varchar2
  ,p_pty_information14            in     varchar2
  ,p_pty_information15            in     varchar2
  ,p_pty_information16            in     varchar2
  ,p_pty_information17            in     varchar2
  ,p_pty_information18            in     varchar2
  ,p_pty_information19            in     varchar2
  ,p_pty_information20            in     varchar2
  ,p_special_pension_type_code    in     varchar2    -- added for NL Phase 2B
  ,p_pension_sub_category         in     varchar2    -- added for NL Phase 2B
  ,p_pension_basis_calc_method    in     varchar2    -- added for NL Phase 2B
  ,p_pension_salary_balance       in     number      -- added for NL Phase 2B
  ,p_recurring_bonus_percent      in     number      -- added for NL Phase 2B
  ,p_non_recurring_bonus_percent  in     number      -- added for NL Phase 2B
  ,p_recurring_bonus_balance      in     number      -- added for NL Phase 2B
  ,p_non_recurring_bonus_balance  in     number      -- added for NL Phase 2B
  ,p_std_tax_reduction            in     varchar2    -- added for NL Phase 2B
  ,p_spl_tax_reduction            in     varchar2    -- added for NL Phase 2B
  ,p_sig_sal_spl_tax_reduction    in     varchar2    -- added for NL Phase 2B
  ,p_sig_sal_non_tax_reduction    in     varchar2    -- added for NL Phase 2B
  ,p_sig_sal_std_tax_reduction    in     varchar2    -- added for NL Phase 2B
  ,p_sii_std_tax_reduction        in     varchar2    -- added for NL Phase 2B
  ,p_sii_spl_tax_reduction        in     varchar2    -- added for NL Phase 2B
  ,p_sii_non_tax_reduction        in     varchar2    -- added for NL Phase 2B
  ,p_previous_year_bonus_included in     varchar2    -- added for NL Phase 2B
  ,p_recurring_bonus_period       in     varchar2    -- added for NL Phase 2B
  ,p_non_recurring_bonus_period   in     varchar2    -- added for NL Phase 2B
  ,p_ee_age_threshold             in     varchar2    -- added for ABP TAR fixes
  ,p_er_age_threshold             in     varchar2    -- added for ABP TAR fixes
  ,p_ee_age_contribution          in     varchar2    -- added for ABP TAR fixes
  ,p_er_age_contribution          in     varchar2    -- added for ABP TAR fixes
  ,p_effective_start_date         in     date
  ,p_effective_end_date           in     date
  );
--
End PQP_Pension_Types_BK2;

 

/
