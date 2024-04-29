--------------------------------------------------------
--  DDL for Package PAY_ELEMENT_TYPES_MIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ELEMENT_TYPES_MIG" AUTHID CURRENT_USER as
/* $Header: pyetpmpi.pkh 120.1.12010000.2 2008/08/06 07:13:21 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_element_type >------------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_ELEMENT_TYPE
  (p_validate                        in  boolean  default false
  ,p_effective_date                  in  date
  ,p_classification_id               in  number
  ,p_element_name                    in  varchar2
  ,p_input_currency_code             in  varchar2
  ,p_output_currency_code            in  varchar2
  ,p_multiple_entries_allowed_fla    in  varchar2
  ,p_processing_type                 in  varchar2
  ,p_business_group_id               in  number   default null
  ,p_legislation_code                in  varchar2 default null
  ,p_formula_id                      in  number   default null
  ,p_benefit_classification_id       in  number   default null
  ,p_additional_entry_allowed_fla    in  varchar2 default 'N'
  ,p_adjustment_only_flag            in  varchar2 default 'N'
  ,p_closed_for_entry_flag           in  varchar2 default 'N'
  ,p_reporting_name                  in  varchar2 default null
  ,p_description                     in  varchar2 default null
  ,p_indirect_only_flag              in  varchar2 default 'N'
  ,p_multiply_value_flag             in  varchar2 default 'N'
  ,p_post_termination_rule           in  varchar2 default 'L'
  ,p_process_in_run_flag             in  varchar2 default 'Y'
  ,p_processing_priority             in  number   default null
  ,p_standard_link_flag              in  varchar2 default 'N'
  ,p_comments                        in  varchar2 default null
  ,p_third_party_pay_only_flag       in	 varchar2 default null
  ,p_iterative_flag                  in	 varchar2 default null
  ,p_iterative_formula_id            in	 number	  default null
  ,p_iterative_priority              in	 number	  default null
  ,p_creator_type                    in	 varchar2 default null
  ,p_retro_summ_ele_id               in  number   default null
  ,p_grossup_flag                    in	 varchar2 default null
  ,p_process_mode                    in	 varchar2 default null
  ,p_advance_indicator               in	 varchar2 default null
  ,p_advance_payable                 in	 varchar2 default null
  ,p_advance_deduction               in	 varchar2 default null
  ,p_process_advance_entry           in	 varchar2 default null
  ,p_proration_group_id              in	 number	  default null
  ,p_proration_formula_id            in	 number	  default null
  ,p_recalc_event_group_id 	         in  number	  default null
  ,p_legislation_subgroup            in  varchar2 default null
  ,p_qualifying_age                  in  number   default null
  ,p_qualifying_length_of_service    in  number   default null
  ,p_qualifying_units                in  varchar2 default null
  ,p_advance_element_type_id         in  number   default null
  ,p_deduction_element_type_id       in  number   default null
  ,p_attribute_category              in  varchar2 default null
  ,p_attribute1                      in	 varchar2 default null
  ,p_attribute2                      in	 varchar2 default null
  ,p_attribute3                      in	 varchar2 default null
  ,p_attribute4                      in	 varchar2 default null
  ,p_attribute5                      in	 varchar2 default null
  ,p_attribute6                      in	 varchar2 default null
  ,p_attribute7                      in	 varchar2 default null
  ,p_attribute8                      in	 varchar2 default null
  ,p_attribute9                      in	 varchar2 default null
  ,p_attribute10                     in	 varchar2 default null
  ,p_attribute11                     in	 varchar2 default null
  ,p_attribute12                     in	 varchar2 default null
  ,p_attribute13                     in	 varchar2 default null
  ,p_attribute14                     in	 varchar2 default null
  ,p_attribute15                     in	 varchar2 default null
  ,p_attribute16                     in	 varchar2 default null
  ,p_attribute17                     in	 varchar2 default null
  ,p_attribute18                     in	 varchar2 default null
  ,p_attribute19                     in	 varchar2 default null
  ,p_attribute20                     in	 varchar2 default null
  ,p_element_information_category    in	 varchar2 default null
  ,p_element_information1            in	 varchar2 default null
  ,p_element_information2            in	 varchar2 default null
  ,p_element_information3            in	 varchar2 default null
  ,p_element_information4            in	 varchar2 default null
  ,p_element_information5            in	 varchar2 default null
  ,p_element_information6            in	 varchar2 default null
  ,p_element_information7            in	 varchar2 default null
  ,p_element_information8            in	 varchar2 default null
  ,p_element_information9            in	 varchar2 default null
  ,p_element_information10           in	 varchar2 default null
  ,p_element_information11           in	 varchar2 default null
  ,p_element_information12           in	 varchar2 default null
  ,p_element_information13           in	 varchar2 default null
  ,p_element_information14           in	 varchar2 default null
  ,p_element_information15           in	 varchar2 default null
  ,p_element_information16           in	 varchar2 default null
  ,p_element_information17           in	 varchar2 default null
  ,p_element_information18           in	 varchar2 default null
  ,p_element_information19           in	 varchar2 default null
  ,p_element_information20           in	 varchar2 default null
  ,p_default_uom		     in  varchar2 default null
  ,p_once_each_period_flag           in  varchar2 default 'N'
  ,p_language_code                   in  varchar2 default hr_api.userenv_lang
  ,p_time_definition_type        in  varchar2 default null
  ,p_time_definition_id          in  number   default null
  ,p_element_type_id                 out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_object_version_number           out nocopy number
  ,p_comment_id			     out nocopy number
  ,p_processing_priority_warning     out nocopy boolean
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_element_type >------------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_ELEMENT_TYPE
  (p_validate                        in     boolean  default false
  ,p_effective_date                  in     date
  ,p_datetrack_update_mode	     in     varchar2
  ,p_element_type_id        	     in     number
  ,p_object_version_number  	     in out nocopy number
  ,p_formula_id                      in     number   default hr_api.g_number
  ,p_benefit_classification_id       in     number   default hr_api.g_number
  ,p_additional_entry_allowed_fla    in     varchar2 default hr_api.g_varchar2
  ,p_adjustment_only_flag            in     varchar2 default hr_api.g_varchar2
  ,p_closed_for_entry_flag           in     varchar2 default hr_api.g_varchar2
  ,p_element_name                    in	    varchar2 default hr_api.g_varchar2
  ,p_reporting_name                  in     varchar2 default hr_api.g_varchar2
  ,p_description                     in     varchar2 default hr_api.g_varchar2
  ,p_indirect_only_flag              in     varchar2 default hr_api.g_varchar2
  ,p_multiple_entries_allowed_fla    in     varchar2 default hr_api.g_varchar2
  ,p_multiply_value_flag             in     varchar2 default hr_api.g_varchar2
  ,p_post_termination_rule           in     varchar2 default hr_api.g_varchar2
  ,p_process_in_run_flag             in     varchar2 default hr_api.g_varchar2
  ,p_processing_priority             in     number   default hr_api.g_number
  ,p_standard_link_flag              in     varchar2 default hr_api.g_varchar2
  ,p_comments                        in     varchar2 default hr_api.g_varchar2
  ,p_third_party_pay_only_flag       in	    varchar2 default hr_api.g_varchar2
  ,p_iterative_flag                  in	    varchar2 default hr_api.g_varchar2
  ,p_iterative_formula_id            in	    number   default hr_api.g_number
  ,p_iterative_priority              in	    number   default hr_api.g_number
  ,p_creator_type                    in	    varchar2 default hr_api.g_varchar2
  ,p_retro_summ_ele_id               in     number   default hr_api.g_number
  ,p_grossup_flag                    in	    varchar2 default hr_api.g_varchar2
  ,p_process_mode                    in	    varchar2 default hr_api.g_varchar2
  ,p_advance_indicator               in	    varchar2 default hr_api.g_varchar2
  ,p_advance_payable                 in	    varchar2 default hr_api.g_varchar2
  ,p_advance_deduction               in	    varchar2 default hr_api.g_varchar2
  ,p_process_advance_entry           in	    varchar2 default hr_api.g_varchar2
  ,p_proration_group_id              in	    number   default hr_api.g_number
  ,p_proration_formula_id            in	    number   default hr_api.g_number
  ,p_recalc_event_group_id 	     in	    number   default hr_api.g_number
  ,p_qualifying_age                  in     number   default hr_api.g_number
  ,p_qualifying_length_of_service    in     number   default hr_api.g_number
  ,p_qualifying_units                in     varchar2 default hr_api.g_varchar2
  ,p_advance_element_type_id         in     number   default hr_api.g_number
  ,p_deduction_element_type_id       in     number   default hr_api.g_number
  ,p_attribute_category              in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                      in	    varchar2 default hr_api.g_varchar2
  ,p_attribute2                      in	    varchar2 default hr_api.g_varchar2
  ,p_attribute3                      in	    varchar2 default hr_api.g_varchar2
  ,p_attribute4                      in	    varchar2 default hr_api.g_varchar2
  ,p_attribute5                      in	    varchar2 default hr_api.g_varchar2
  ,p_attribute6                      in	    varchar2 default hr_api.g_varchar2
  ,p_attribute7                      in	    varchar2 default hr_api.g_varchar2
  ,p_attribute8                      in	    varchar2 default hr_api.g_varchar2
  ,p_attribute9                      in	    varchar2 default hr_api.g_varchar2
  ,p_attribute10                     in	    varchar2 default hr_api.g_varchar2
  ,p_attribute11                     in	    varchar2 default hr_api.g_varchar2
  ,p_attribute12                     in	    varchar2 default hr_api.g_varchar2
  ,p_attribute13                     in	    varchar2 default hr_api.g_varchar2
  ,p_attribute14                     in	    varchar2 default hr_api.g_varchar2
  ,p_attribute15                     in	    varchar2 default hr_api.g_varchar2
  ,p_attribute16                     in	    varchar2 default hr_api.g_varchar2
  ,p_attribute17                     in	    varchar2 default hr_api.g_varchar2
  ,p_attribute18                     in	    varchar2 default hr_api.g_varchar2
  ,p_attribute19                     in	    varchar2 default hr_api.g_varchar2
  ,p_attribute20                     in	    varchar2 default hr_api.g_varchar2
  ,p_element_information_category    in	    varchar2 default hr_api.g_varchar2
  ,p_element_information1            in	    varchar2 default hr_api.g_varchar2
  ,p_element_information2            in	    varchar2 default hr_api.g_varchar2
  ,p_element_information3            in	    varchar2 default hr_api.g_varchar2
  ,p_element_information4            in	    varchar2 default hr_api.g_varchar2
  ,p_element_information5            in	    varchar2 default hr_api.g_varchar2
  ,p_element_information6            in	    varchar2 default hr_api.g_varchar2
  ,p_element_information7            in	    varchar2 default hr_api.g_varchar2
  ,p_element_information8            in	    varchar2 default hr_api.g_varchar2
  ,p_element_information9            in	    varchar2 default hr_api.g_varchar2
  ,p_element_information10           in	    varchar2 default hr_api.g_varchar2
  ,p_element_information11           in	    varchar2 default hr_api.g_varchar2
  ,p_element_information12           in	    varchar2 default hr_api.g_varchar2
  ,p_element_information13           in	    varchar2 default hr_api.g_varchar2
  ,p_element_information14           in	    varchar2 default hr_api.g_varchar2
  ,p_element_information15           in	    varchar2 default hr_api.g_varchar2
  ,p_element_information16           in	    varchar2 default hr_api.g_varchar2
  ,p_element_information17           in	    varchar2 default hr_api.g_varchar2
  ,p_element_information18           in	    varchar2 default hr_api.g_varchar2
  ,p_element_information19           in	    varchar2 default hr_api.g_varchar2
  ,p_element_information20           in	    varchar2 default hr_api.g_varchar2
  ,p_once_each_period_flag           in     varchar2 default hr_api.g_varchar2
  ,p_language_code                   in     varchar2 default hr_api.userenv_lang
  ,p_time_definition_type        in     varchar2 default hr_api.g_varchar2
  ,p_time_definition_id          in     number   default hr_api.g_number
  ,p_effective_start_date               out nocopy date
  ,p_effective_end_date                 out nocopy date
  ,p_comment_id                         out nocopy number
  ,p_processing_priority_warning        out nocopy boolean
  ,p_element_name_warning               out nocopy boolean
  ,p_element_name_change_warning        out nocopy boolean
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_element_type >------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_ELEMENT_TYPE
  (p_validate                        in     boolean default false
  ,p_effective_date                  in     date
  ,p_datetrack_delete_mode           in     varchar2
  ,p_element_type_id                 in     number
  ,p_object_version_number           in out nocopy number
  ,p_effective_start_date               out nocopy date
  ,p_effective_end_date                 out nocopy date
  ,p_balance_feeds_warning	        out nocopy boolean
  ,p_processing_rules_warning  	        out nocopy boolean
  );

end PAY_ELEMENT_TYPES_MIG;

/
