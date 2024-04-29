--------------------------------------------------------
--  DDL for Package PQP_PENSION_TYPES_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_PENSION_TYPES_SWI" AUTHID CURRENT_USER As
/* $Header: pqptyswi.pkh 120.0.12000000.1 2007/01/16 04:29:10 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |--------------------------< create_pension_type >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqp_pension_types_api.create_pension_type
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
Procedure Create_Pension_Type
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_pension_type_name            in     varchar2
  ,p_pension_category             in     varchar2
  ,p_pension_provider_type        in     varchar2  default null
  ,p_salary_calculation_method    in     varchar2  default null
  ,p_threshold_conversion_rule    in     varchar2  default null
  ,p_contribution_conversion_rule in     varchar2  default null
  ,p_er_annual_limit              in     number    default null
  ,p_ee_annual_limit              in     number    default null
  ,p_er_annual_salary_threshold   in     number	   default null
  ,p_ee_annual_salary_threshold   in     number    default null
  ,p_business_group_id            in     number    default null
  ,p_legislation_code             in     varchar2  default null
  ,p_description                  in     varchar2  default null
  ,p_minimum_age                  in     number    default null
  ,p_ee_contribution_percent      in     number    default null
  ,p_maximum_age                  in     number    default null
  ,p_er_contribution_percent      in     number    default null
  ,p_ee_annual_contribution       in     number    default null
  ,p_er_annual_contribution       in     number    default null
  ,p_annual_premium_amount        in     number    default null
  ,p_ee_contribution_bal_type_id  in     number    default null
  ,p_er_contribution_bal_type_id  in     number    default null
  ,p_balance_init_element_type_id in     number    default null
  ,p_ee_contribution_fixed_rate   in     number    default null --added for UK
  ,p_er_contribution_fixed_rate   in     number    default null --added for UK
  ,p_pty_attribute_category       in     varchar2  default null
  ,p_pty_attribute1               in     varchar2  default null
  ,p_pty_attribute2               in     varchar2  default null
  ,p_pty_attribute3               in     varchar2  default null
  ,p_pty_attribute4               in     varchar2  default null
  ,p_pty_attribute5               in     varchar2  default null
  ,p_pty_attribute6               in     varchar2  default null
  ,p_pty_attribute7               in     varchar2  default null
  ,p_pty_attribute8               in     varchar2  default null
  ,p_pty_attribute9               in     varchar2  default null
  ,p_pty_attribute10              in     varchar2  default null
  ,p_pty_attribute11              in     varchar2  default null
  ,p_pty_attribute12              in     varchar2  default null
  ,p_pty_attribute13              in     varchar2  default null
  ,p_pty_attribute14              in     varchar2  default null
  ,p_pty_attribute15              in     varchar2  default null
  ,p_pty_attribute16              in     varchar2  default null
  ,p_pty_attribute17              in     varchar2  default null
  ,p_pty_attribute18              in     varchar2  default null
  ,p_pty_attribute19              in     varchar2  default null
  ,p_pty_attribute20              in     varchar2  default null
  ,p_pty_information_category     in     varchar2  default null
  ,p_pty_information1             in     varchar2  default null
  ,p_pty_information2             in     varchar2  default null
  ,p_pty_information3             in     varchar2  default null
  ,p_pty_information4             in     varchar2  default null
  ,p_pty_information5             in     varchar2  default null
  ,p_pty_information6             in     varchar2  default null
  ,p_pty_information7             in     varchar2  default null
  ,p_pty_information8             in     varchar2  default null
  ,p_pty_information9             in     varchar2  default null
  ,p_pty_information10            in     varchar2  default null
  ,p_pty_information11            in     varchar2  default null
  ,p_pty_information12            in     varchar2  default null
  ,p_pty_information13            in     varchar2  default null
  ,p_pty_information14            in     varchar2  default null
  ,p_pty_information15            in     varchar2  default null
  ,p_pty_information16            in     varchar2  default null
  ,p_pty_information17            in     varchar2  default null
  ,p_pty_information18            in     varchar2  default null
  ,p_pty_information19            in     varchar2  default null
  ,p_pty_information20            in     varchar2  default null
  ,p_special_pension_type_code    in     varchar2  default null  -- added for NL Phase 2B
  ,p_pension_sub_category         in     varchar2  default null  -- added for NL Phase 2B
  ,p_pension_basis_calc_method    in     varchar2  default null  -- added for NL Phase 2B
  ,p_pension_salary_balance       in     number    default null  -- added for NL Phase 2B
  ,p_recurring_bonus_percent      in     number    default null  -- added for NL Phase 2B
  ,p_non_recurring_bonus_percent  in     number    default null  -- added for NL Phase 2B
  ,p_recurring_bonus_balance      in     number    default null  -- added for NL Phase 2B
  ,p_non_recurring_bonus_balance  in     number    default null  -- added for NL Phase 2B
  ,p_std_tax_reduction            in     varchar2  default null  -- added for NL Phase 2B
  ,p_spl_tax_reduction            in     varchar2  default null  -- added for NL Phase 2B
  ,p_sig_sal_spl_tax_reduction    in     varchar2  default null  -- added for NL Phase 2B
  ,p_sig_sal_non_tax_reduction    in     varchar2  default null  -- added for NL Phase 2B
  ,p_sig_sal_std_tax_reduction    in     varchar2  default null  -- added for NL Phase 2B
  ,p_sii_std_tax_reduction        in     varchar2  default null  -- added for NL Phase 2B
  ,p_sii_spl_tax_reduction        in     varchar2  default null  -- added for NL Phase 2B
  ,p_sii_non_tax_reduction        in     varchar2  default null  -- added for NL Phase 2B
  ,p_previous_year_bonus_included in     varchar2  default null  -- added for NL Phase 2B
  ,p_recurring_bonus_period       in     varchar2  default null  -- added for NL Phase 2B
  ,p_non_recurring_bonus_period   in     varchar2  default null  -- added for NL Phase 2B
  ,p_ee_age_threshold             in     varchar2  default null  -- added for ABP TAR Fixes
  ,p_er_age_threshold             in     varchar2  default null  -- added for ABP TAR Fixes
  ,p_ee_age_contribution          in     varchar2  default null  -- added for ABP TAR Fixes
  ,p_er_age_contribution          in     varchar2  default null  -- added for ABP TAR Fixes
  ,p_pension_type_id              out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_api_warning                     out nocopy varchar2
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |--------------------------< Delete_Pension_Type >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqp_pension_types_api.delete_pension_type
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
Procedure Delete_Pension_Type
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_pension_type_id              in     number
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  ,p_api_warning                     out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |--------------------------< Update_Pension_Type >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqp_pension_types_api.update_pension_type
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
Procedure Update_Pension_Type
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_pension_type_id              in     number
  ,p_object_version_number        in out nocopy number
  ,p_pension_type_name            in     varchar2  default hr_api.g_varchar2
  ,p_pension_category             in     varchar2  default hr_api.g_varchar2
  ,p_pension_provider_type        in     varchar2  default hr_api.g_varchar2
  ,p_salary_calculation_method    in     varchar2  default hr_api.g_varchar2
  ,p_threshold_conversion_rule    in     varchar2  default hr_api.g_varchar2
  ,p_contribution_conversion_rule in     varchar2  default hr_api.g_varchar2
  ,p_er_annual_limit              in     number    default hr_api.g_number
  ,p_ee_annual_limit              in     number    default hr_api.g_number
  ,p_er_annual_salary_threshold   in     number    default hr_api.g_number
  ,p_ee_annual_salary_threshold   in     number    default hr_api.g_number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_minimum_age                  in     number    default hr_api.g_number
  ,p_ee_contribution_percent      in     number    default hr_api.g_number
  ,p_maximum_age                  in     number    default hr_api.g_number
  ,p_er_contribution_percent      in     number    default hr_api.g_number
  ,p_ee_annual_contribution       in     number    default hr_api.g_number
  ,p_er_annual_contribution       in     number    default hr_api.g_number
  ,p_annual_premium_amount        in     number    default hr_api.g_number
  ,p_ee_contribution_bal_type_id  in     number    default hr_api.g_number
  ,p_er_contribution_bal_type_id  in     number    default hr_api.g_number
  ,p_balance_init_element_type_id in     number    default hr_api.g_number
  ,p_ee_contribution_fixed_rate   in     number    default hr_api.g_number --added for UK
  ,p_er_contribution_fixed_rate   in     number    default hr_api.g_number --added for UK
  ,p_pty_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_pty_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_pty_information1             in     varchar2  default hr_api.g_varchar2
  ,p_pty_information2             in     varchar2  default hr_api.g_varchar2
  ,p_pty_information3             in     varchar2  default hr_api.g_varchar2
  ,p_pty_information4             in     varchar2  default hr_api.g_varchar2
  ,p_pty_information5             in     varchar2  default hr_api.g_varchar2
  ,p_pty_information6             in     varchar2  default hr_api.g_varchar2
  ,p_pty_information7             in     varchar2  default hr_api.g_varchar2
  ,p_pty_information8             in     varchar2  default hr_api.g_varchar2
  ,p_pty_information9             in     varchar2  default hr_api.g_varchar2
  ,p_pty_information10            in     varchar2  default hr_api.g_varchar2
  ,p_pty_information11            in     varchar2  default hr_api.g_varchar2
  ,p_pty_information12            in     varchar2  default hr_api.g_varchar2
  ,p_pty_information13            in     varchar2  default hr_api.g_varchar2
  ,p_pty_information14            in     varchar2  default hr_api.g_varchar2
  ,p_pty_information15            in     varchar2  default hr_api.g_varchar2
  ,p_pty_information16            in     varchar2  default hr_api.g_varchar2
  ,p_pty_information17            in     varchar2  default hr_api.g_varchar2
  ,p_pty_information18            in     varchar2  default hr_api.g_varchar2
  ,p_pty_information19            in     varchar2  default hr_api.g_varchar2
  ,p_pty_information20            in     varchar2  default hr_api.g_varchar2
  ,p_special_pension_type_code    in     varchar2  default hr_api.g_varchar2  -- added for NL Phase 2B
  ,p_pension_sub_category         in     varchar2  default hr_api.g_varchar2  -- added for NL Phase 2B
  ,p_pension_basis_calc_method    in     varchar2  default hr_api.g_varchar2  -- added for NL Phase 2B
  ,p_pension_salary_balance       in     number    default hr_api.g_number    -- added for NL Phase 2B
  ,p_recurring_bonus_percent      in     number    default hr_api.g_number    -- added for NL Phase 2B
  ,p_non_recurring_bonus_percent  in     number    default hr_api.g_number    -- added for NL Phase 2B
  ,p_recurring_bonus_balance      in     number    default hr_api.g_number    -- added for NL Phase 2B
  ,p_non_recurring_bonus_balance  in     number    default hr_api.g_number    -- added for NL Phase 2B
  ,p_std_tax_reduction            in     varchar2  default hr_api.g_varchar2  -- added for NL Phase 2B
  ,p_spl_tax_reduction            in     varchar2  default hr_api.g_varchar2  -- added for NL Phase 2B
  ,p_sig_sal_spl_tax_reduction    in     varchar2  default hr_api.g_varchar2  -- added for NL Phase 2B
  ,p_sig_sal_non_tax_reduction    in     varchar2  default hr_api.g_varchar2  -- added for NL Phase 2B
  ,p_sig_sal_std_tax_reduction    in     varchar2  default hr_api.g_varchar2  -- added for NL Phase 2B
  ,p_sii_std_tax_reduction        in     varchar2  default hr_api.g_varchar2  -- added for NL Phase 2B
  ,p_sii_spl_tax_reduction        in     varchar2  default hr_api.g_varchar2  -- added for NL Phase 2B
  ,p_sii_non_tax_reduction        in     varchar2  default hr_api.g_varchar2  -- added for NL Phase 2B
  ,p_previous_year_bonus_included in     varchar2  default hr_api.g_varchar2  -- added for NL Phase 2B
  ,p_recurring_bonus_period       in     varchar2  default hr_api.g_varchar2  -- added for NL Phase 2B
  ,p_non_recurring_bonus_period   in     varchar2  default hr_api.g_varchar2  -- added for NL Phase 2B
  ,p_ee_age_threshold             in     varchar2  default hr_api.g_varchar2  -- added for ABP TAR Fixes
  ,p_er_age_threshold             in     varchar2  default hr_api.g_varchar2  -- added for ABP TAR Fixes
  ,p_ee_age_contribution          in     varchar2  default hr_api.g_varchar2  -- added for ABP TAR Fixes
  ,p_er_age_contribution          in     varchar2  default hr_api.g_varchar2  -- added for ABP TAR Fixes
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  ,p_api_warning                     out nocopy varchar2
  );
end PQP_Pension_Types_swi;

 

/
