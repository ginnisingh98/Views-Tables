--------------------------------------------------------
--  DDL for Package PAY_SHADOW_ELEMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SHADOW_ELEMENT_API" AUTHID CURRENT_USER as
/* $Header: pysetapi.pkh 120.0 2005/05/29 08:38:26 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_shadow_element >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API allows a shadow element to be modified before it has been used
--   to generate a row in PAY_ELEMENT_TYPES_F.
--
-- Prerequisites:
--   The shadow element must exist, and not have been used to generate an
--   element type in the core schema.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  If true, the database is not
--                                                changed. If false then the
--                                                shadow element is updated.
--   p_effective_date               Yes  date     Effective date (used for
--                                                business rule validation).
--   p_element_type_id              Yes  number   Identifies the shadow element
--                                                to be updated.
--   p_classification_name          No   varchar2 Primary classification for
--                                                this element type.
--   p_additional_entry_allowed_fla No   varchar2
--   p_adjustment_only_flag         No   varchar2
--   p_closed_for_entry_flag        No   varchar2
--   p_element_name                 No   varchar2
--   p_indirect_only_flag           No   varchar2
--   p_multiple_entries_allowed_fla No   varchar2
--   p_multiply_value_flag          No   varchar2
--   p_post_termination_rule        No   varchar2
--   p_process_in_run_flag          No   varchar2
--   p_relative_processing_priority No   number   Processing Priority relative
--                                                to Base Processing Priority
--                                                on PAY_ELEMENT_TEMPLATES row.
--   p_processing_type              No   varchar2
--   p_standard_link_flag           No   varchar2
--   p_input_currency_code          No   varchar2
--   p_output_currency_code         No   varchar2
--   p_benefit_classification_name  No   varchar2 Name of Benefit Classification
--                                                for this element type.
--   p_description                  No   varchar2
--   p_qualifying_age               No   number
--   p_qualifying_length_of_service No   number
--   p_qualifying_units             No   varchar2
--   p_reporting_name               No   varchar2
--   p_attribute_category           No   varchar2
--   p_attribute1                   No   varchar2
--   p_attribute2                   No   varchar2
--   p_attribute3                   No   varchar2
--   p_attribute4                   No   varchar2
--   p_attribute5                   No   varchar2
--   p_attribute6                   No   varchar2
--   p_attribute7                   No   varchar2
--   p_attribute8                   No   varchar2
--   p_attribute9                   No   varchar2
--   p_attribute10                  No   varchar2
--   p_attribute11                  No   varchar2
--   p_attribute12                  No   varchar2
--   p_attribute13                  No   varchar2
--   p_attribute14                  No   varchar2
--   p_attribute15                  No   varchar2
--   p_attribute16                  No   varchar2
--   p_attribute17                  No   varchar2
--   p_attribute18                  No   varchar2
--   p_attribute19                  No   varchar2
--   p_attribute20                  No   varchar2
--   p_element_information_category No   varchar2
--   p_element_information1         No   varchar2
--   p_element_information2         No   varchar2
--   p_element_information3         No   varchar2
--   p_element_information4         No   varchar2
--   p_element_information5         No   varchar2
--   p_element_information6         No   varchar2
--   p_element_information7         No   varchar2
--   p_element_information8         No   varchar2
--   p_element_information9         No   varchar2
--   p_element_information10        No   varchar2
--   p_element_information11        No   varchar2
--   p_element_information12        No   varchar2
--   p_element_information13        No   varchar2
--   p_element_information14        No   varchar2
--   p_third_party_pay_only_flag    No   varchar2
--   p_skip_formula                 No   varchar2 Name of Element Skip formula
--                                                for this element type.
--   p_payroll_formula_id           No   number   Identifies the shadow payroll
--                                                formula (PAY_SHADOW_FORMULAS)
--                                                for the shadow element.
--   p_exclusion_rule_id            No   number   Identifies the exclusion rule
--                                                (PAY_TEMPLATE_EXCLUSION_RULES)
--                                                for the shadow element.
--   p_iterative_flag               No   varchar2
--   p_iterative_priority           No   number
--   p_iterative_formula_name       No   varchar2
--   p_process_mode                 No   varchar2
--   p_grossup_flag                 No   varchar2
--   p_advance_payable              No   varchar2
--   p_advance_deduction            No   varchar2
--   p_process_advance_entry        No   varchar2
--   p_proration_group              No   varchar2 Name of Proration group for
--                                                this element type.
--   p_proration_formula            No   varchar2 Name of Proration formula
--                                                for this element type.
--   p_recalc_event_group           No   varchar2 Name of Recalculation event
--                                                group for this element type.
--   p_once_each_period_flag        No   varchar2
--
-- Post Success:
--   If p_validate is false, the shadow element is updated. Otherwise the
--   shadow element is unchanged.
--
--   Name                           Reqd Type     Description
--   p_object_version_number        Yes  number   If p_validate is false,
--                                                this is set to the updated
--                                                object version number for
--                                                the shadow element.
--                                                Not changed if p_validate is
--                                                true.
--
-- Post Failure:
--   Any work done is rolled back and an exception is raised.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_shadow_element
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_element_type_id               in     number
  ,p_classification_name           in     varchar2 default hr_api.g_varchar2
  ,p_additional_entry_allowed_fla  in     varchar2 default hr_api.g_varchar2
  ,p_adjustment_only_flag          in     varchar2 default hr_api.g_varchar2
  ,p_closed_for_entry_flag         in     varchar2 default hr_api.g_varchar2
  ,p_element_name                  in     varchar2 default hr_api.g_varchar2
  ,p_indirect_only_flag            in     varchar2 default hr_api.g_varchar2
  ,p_multiple_entries_allowed_fla  in     varchar2 default hr_api.g_varchar2
  ,p_multiply_value_flag           in     varchar2 default hr_api.g_varchar2
  ,p_post_termination_rule         in     varchar2 default hr_api.g_varchar2
  ,p_process_in_run_flag           in     varchar2 default hr_api.g_varchar2
  ,p_relative_processing_priority  in     number   default hr_api.g_number
  ,p_processing_type               in     varchar2 default hr_api.g_varchar2
  ,p_standard_link_flag            in     varchar2 default hr_api.g_varchar2
  ,p_input_currency_code           in     varchar2 default hr_api.g_varchar2
  ,p_output_currency_code          in     varchar2 default hr_api.g_varchar2
  ,p_benefit_classification_name   in     varchar2 default hr_api.g_varchar2
  ,p_description                   in     varchar2 default hr_api.g_varchar2
  ,p_qualifying_age                in     number   default hr_api.g_number
  ,p_qualifying_length_of_service  in     number   default hr_api.g_number
  ,p_qualifying_units              in     varchar2 default hr_api.g_varchar2
  ,p_reporting_name                in     varchar2 default hr_api.g_varchar2
  ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
  ,p_element_information_category  in     varchar2 default hr_api.g_varchar2
  ,p_element_information1          in     varchar2 default hr_api.g_varchar2
  ,p_element_information2          in     varchar2 default hr_api.g_varchar2
  ,p_element_information3          in     varchar2 default hr_api.g_varchar2
  ,p_element_information4          in     varchar2 default hr_api.g_varchar2
  ,p_element_information5          in     varchar2 default hr_api.g_varchar2
  ,p_element_information6          in     varchar2 default hr_api.g_varchar2
  ,p_element_information7          in     varchar2 default hr_api.g_varchar2
  ,p_element_information8          in     varchar2 default hr_api.g_varchar2
  ,p_element_information9          in     varchar2 default hr_api.g_varchar2
  ,p_element_information10         in     varchar2 default hr_api.g_varchar2
  ,p_element_information11         in     varchar2 default hr_api.g_varchar2
  ,p_element_information12         in     varchar2 default hr_api.g_varchar2
  ,p_element_information13         in     varchar2 default hr_api.g_varchar2
  ,p_element_information14         in     varchar2 default hr_api.g_varchar2
  ,p_element_information15         in     varchar2 default hr_api.g_varchar2
  ,p_element_information16         in     varchar2 default hr_api.g_varchar2
  ,p_element_information17         in     varchar2 default hr_api.g_varchar2
  ,p_element_information18         in     varchar2 default hr_api.g_varchar2
  ,p_element_information19         in     varchar2 default hr_api.g_varchar2
  ,p_element_information20         in     varchar2 default hr_api.g_varchar2
  ,p_third_party_pay_only_flag     in     varchar2 default hr_api.g_varchar2
  ,p_skip_formula                  in     varchar2 default hr_api.g_varchar2
  ,p_payroll_formula_id            in     number   default hr_api.g_number
  ,p_exclusion_rule_id             in     number   default hr_api.g_number
  ,p_iterative_flag                in     varchar2 default hr_api.g_varchar2
  ,p_iterative_priority            in     number   default hr_api.g_number
  ,p_iterative_formula_name        in     varchar2 default hr_api.g_varchar2
  ,p_process_mode                  in     varchar2 default hr_api.g_varchar2
  ,p_grossup_flag                  in     varchar2 default hr_api.g_varchar2
  ,p_advance_indicator             in     varchar2 default hr_api.g_varchar2
  ,p_advance_payable               in     varchar2 default hr_api.g_varchar2
  ,p_advance_deduction             in     varchar2 default hr_api.g_varchar2
  ,p_process_advance_entry         in     varchar2 default hr_api.g_varchar2
  ,p_proration_group               in     varchar2 default hr_api.g_varchar2
  ,p_proration_formula             in     varchar2 default hr_api.g_varchar2
  ,p_recalc_event_group            in     varchar2 default hr_api.g_varchar2
  ,p_once_each_period_flag         in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  );
--
end pay_shadow_element_api;

 

/
