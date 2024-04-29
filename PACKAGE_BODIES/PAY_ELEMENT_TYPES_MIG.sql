--------------------------------------------------------
--  DDL for Package Body PAY_ELEMENT_TYPES_MIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ELEMENT_TYPES_MIG" as
/* $Header: pyetpmpi.pkb 120.1.12010000.2 2008/08/06 07:13:10 ubhat ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  PAY_ELEMENT_TYPES_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< CREATE_ELEMENT_TYPE >-------------------------|
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
  ,p_comment_id			             out nocopy number
  ,p_processing_priority_warning     out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                	varchar2(72):=g_package||'CREATE_ELEMENT_TYPE';
  l_effective_date		date;
  l_effective_start_date        date;
  l_effective_end_date          date;
  l_processing_priority_warning boolean;
  l_non_payments_flag		varchar2(30);
  l_contributions_used		varchar2(30);
  l_generate_db_items_flag      varchar2(30);
  l_default_val_warning		boolean;
  l_min_max_warning		boolean;
  l_pay_basis_warning		boolean;
  l_formula_warning		boolean;
  l_assignment_id_warning       boolean;
  l_iv_effective_start_date 	date;
  l_iv_effective_end_date	date;
  l_display_sequence		number(1) := 0;
  l_element_type_id             pay_element_types_f.element_type_id%type;
  l_object_version_number       pay_element_types_f.object_version_number%type;
  l_comment_id     		pay_element_types_f.comment_id%type;
  l_input_currency_code		pay_element_types_f.input_currency_code%type;
  l_output_currency_code	pay_element_types_f.output_currency_code%type;
  l_default_priority		pay_element_types_f.processing_priority%type;
  l_processing_priority		pay_element_types_f.processing_priority%type;
  l_input_value_id		pay_input_values_f.input_value_id%type;
  l_iv_object_version_number    pay_input_values_f.object_version_number%type;
  l_formula_message             fnd_new_messages.message_text%type;
  l_language_code               pay_element_types_f_tl.language%type;

  --
  Cursor c_non_payments
  is
    select non_payments_flag, default_priority
      from pay_element_classifications
     where classification_id = p_classification_id;

  Cursor c_contributions_used
  is
    select contributions_used
      from ben_benefit_classifications
     where benefit_classification_id = p_benefit_classification_id;

  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_ELEMENT_TYPE;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Validate the language parameter. l_language_code should be passed to
  -- functions instead of p_language_code from now on, to allow an IN OUT
  -- parameter to be passed through.
  --
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  --
  --
  -- Call Before Process User Hook
  --
  begin
    PAY_ELEMENT_TYPES_BK1.CREATE_ELEMENT_TYPE_b
      (p_effective_date                 =>   l_effective_date
      ,p_classification_id              =>   p_classification_id
      ,p_element_name                   =>   p_element_name
      ,p_business_group_id              =>   p_business_group_id
      ,p_legislation_code               =>   p_legislation_code
      ,p_formula_id                     =>   p_formula_id
      ,p_input_currency_code            =>   p_input_currency_code
      ,p_output_currency_code           =>   p_output_currency_code
      ,p_benefit_classification_id      =>   p_benefit_classification_id
      ,p_additional_entry_allowed_fla   =>   p_additional_entry_allowed_fla
      ,p_adjustment_only_flag           =>   p_adjustment_only_flag
      ,p_closed_for_entry_flag          =>   p_closed_for_entry_flag
      ,p_reporting_name                 =>   p_reporting_name
      ,p_description                    =>   p_description
      ,p_indirect_only_flag             =>   p_indirect_only_flag
      ,p_multiple_entries_allowed_fla   =>   p_multiple_entries_allowed_fla
      ,p_multiply_value_flag            =>   p_multiply_value_flag
      ,p_post_termination_rule          =>   p_post_termination_rule
      ,p_process_in_run_flag            =>   p_process_in_run_flag
      ,p_processing_priority            =>   p_processing_priority
      ,p_processing_type                =>   p_processing_type
      ,p_standard_link_flag             =>   p_standard_link_flag
      ,p_comments                       =>   p_comments
      ,p_legislation_subgroup           =>   p_legislation_subgroup
      ,p_qualifying_age                 =>   p_qualifying_age
      ,p_qualifying_length_of_service   =>   p_qualifying_length_of_service
      ,p_qualifying_units               =>   p_qualifying_units
      ,p_attribute_category             =>   p_attribute_category
      ,p_attribute1                     =>   p_attribute1
      ,p_attribute2                     =>   p_attribute2
      ,p_attribute3                     =>   p_attribute3
      ,p_attribute4                     =>   p_attribute4
      ,p_attribute5                     =>   p_attribute5
      ,p_attribute6                     =>   p_attribute6
      ,p_attribute7                     =>   p_attribute7
      ,p_attribute8                     =>   p_attribute8
      ,p_attribute9                     =>   p_attribute9
      ,p_attribute10                    =>   p_attribute10
      ,p_attribute11                    =>   p_attribute11
      ,p_attribute12                    =>   p_attribute12
      ,p_attribute13                    =>   p_attribute13
      ,p_attribute14                    =>   p_attribute14
      ,p_attribute15                    =>   p_attribute15
      ,p_attribute16                    =>   p_attribute16
      ,p_attribute17                    =>   p_attribute17
      ,p_attribute18                    =>   p_attribute18
      ,p_attribute19                    =>   p_attribute19
      ,p_attribute20                    =>   p_attribute20
      ,p_element_information_category   =>   p_element_information_category
      ,p_element_information1           =>   p_element_information1
      ,p_element_information2           =>   p_element_information2
      ,p_element_information3           =>   p_element_information3
      ,p_element_information4           =>   p_element_information4
      ,p_element_information5           =>   p_element_information5
      ,p_element_information6           =>   p_element_information6
      ,p_element_information7           =>   p_element_information7
      ,p_element_information8           =>   p_element_information8
      ,p_element_information9           =>   p_element_information9
      ,p_element_information10          =>   p_element_information10
      ,p_element_information11          =>   p_element_information11
      ,p_element_information12          =>   p_element_information12
      ,p_element_information13          =>   p_element_information13
      ,p_element_information14          =>   p_element_information14
      ,p_element_information15          =>   p_element_information15
      ,p_element_information16          =>   p_element_information16
      ,p_element_information17          =>   p_element_information17
      ,p_element_information18          =>   p_element_information18
      ,p_element_information19          =>   p_element_information19
      ,p_element_information20          =>   p_element_information20
      ,p_third_party_pay_only_flag      =>   p_third_party_pay_only_flag
      ,p_iterative_flag                 =>   p_iterative_flag
      ,p_iterative_formula_id           =>   p_iterative_formula_id
      ,p_iterative_priority             =>   p_iterative_priority
      ,p_creator_type                   =>   p_creator_type
      ,p_retro_summ_ele_id              =>   p_retro_summ_ele_id
      ,p_grossup_flag                   =>   p_grossup_flag
      ,p_process_mode                   =>   p_process_mode
      ,p_advance_indicator              =>   p_advance_indicator
      ,p_advance_payable                =>   p_advance_payable
      ,p_advance_deduction              =>   p_advance_deduction
      ,p_process_advance_entry          =>   p_process_advance_entry
      ,p_proration_group_id             =>   p_proration_group_id
      ,p_proration_formula_id           =>   p_proration_formula_id
      ,p_recalc_event_group_id 	   	    =>   p_recalc_event_group_id
      ,p_default_uom			        =>   p_default_uom
      ,p_once_each_period_flag          =>   p_once_each_period_flag
      ,p_language_code                  =>   l_language_code
      ,p_time_definition_type           =>   p_time_definition_type
      ,p_time_definition_id             =>   p_time_definition_id
      ,p_advance_element_type_id        =>   p_advance_element_type_id
      ,p_deduction_element_type_id      =>   p_deduction_element_type_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ELEMENT_TYPE'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  Open c_non_payments;
  Fetch c_non_payments into l_non_payments_flag, l_default_priority;
  Close c_non_payments;
  --
  -- Default Processing Priority from the element classification
  --
  If p_processing_priority is null Then
    l_processing_priority := l_default_priority;
  Else
    l_processing_priority := p_processing_priority;
  End If;
  --
  -- Process Logic
  --
  pay_etp_ins_nd.ins
    (p_effective_date               	=>    l_effective_date
    ,p_classification_id            	=>    p_classification_id
    ,p_additional_entry_allowed_fla  	=>    p_additional_entry_allowed_fla
    ,p_adjustment_only_flag         	=>    p_adjustment_only_flag
    ,p_closed_for_entry_flag        	=>    p_closed_for_entry_flag
    ,p_element_name                 	=>    p_element_name
    ,p_indirect_only_flag           	=>    p_indirect_only_flag
    ,p_multiple_entries_allowed_fla 	=>    p_multiple_entries_allowed_fla
    ,p_multiply_value_flag          	=>    p_multiply_value_flag
    ,p_post_termination_rule        	=>    p_post_termination_rule
    ,p_process_in_run_flag          	=>    p_process_in_run_flag
    ,p_processing_priority          	=>    l_processing_priority
    ,p_processing_type              	=>    p_processing_type
    ,p_standard_link_flag           	=>    p_standard_link_flag
    ,p_business_group_id            	=>    p_business_group_id
    ,p_legislation_code             	=>    p_legislation_code
    ,p_formula_id                   	=>    p_formula_id
    ,p_input_currency_code          	=>    p_input_currency_code
    ,p_output_currency_code         	=>    p_output_currency_code
    ,p_benefit_classification_id    	=>    p_benefit_classification_id
    ,p_comments                     	=>    p_comments
    ,p_description                  	=>    p_description
    ,p_legislation_subgroup         	=>    p_legislation_subgroup
    ,p_qualifying_age               	=>    p_qualifying_age
    ,p_qualifying_length_of_service 	=>    p_qualifying_length_of_service
    ,p_qualifying_units             	=>    p_qualifying_units
    ,p_reporting_name               	=>    p_reporting_name
    ,p_attribute_category           	=>    p_attribute_category
    ,p_attribute1                   	=>    p_attribute1
    ,p_attribute2                   	=>    p_attribute2
    ,p_attribute3                   	=>    p_attribute3
    ,p_attribute4                   	=>    p_attribute4
    ,p_attribute5                   	=>    p_attribute5
    ,p_attribute6                   	=>    p_attribute6
    ,p_attribute7                   	=>    p_attribute7
    ,p_attribute8                   	=>    p_attribute8
    ,p_attribute9                   	=>    p_attribute9
    ,p_attribute10                  	=>    p_attribute10
    ,p_attribute11                  	=>    p_attribute11
    ,p_attribute12                  	=>    p_attribute12
    ,p_attribute13                  	=>    p_attribute13
    ,p_attribute14                  	=>    p_attribute14
    ,p_attribute15                  	=>    p_attribute15
    ,p_attribute16                  	=>    p_attribute16
    ,p_attribute17                  	=>    p_attribute17
    ,p_attribute18                  	=>    p_attribute18
    ,p_attribute19                  	=>    p_attribute19
    ,p_attribute20                  	=>    p_attribute20
    ,p_element_information_category 	=>    p_element_information_category
    ,p_element_information1         	=>    p_element_information1
    ,p_element_information2         	=>    p_element_information2
    ,p_element_information3         	=>    p_element_information3
    ,p_element_information4         	=>    p_element_information4
    ,p_element_information5         	=>    p_element_information5
    ,p_element_information6         	=>    p_element_information6
    ,p_element_information7         	=>    p_element_information7
    ,p_element_information8         	=>    p_element_information8
    ,p_element_information9         	=>    p_element_information9
    ,p_element_information10        	=>    p_element_information10
    ,p_element_information11        	=>    p_element_information11
    ,p_element_information12        	=>    p_element_information12
    ,p_element_information13        	=>    p_element_information13
    ,p_element_information14        	=>    p_element_information14
    ,p_element_information15        	=>    p_element_information15
    ,p_element_information16        	=>    p_element_information16
    ,p_element_information17        	=>    p_element_information17
    ,p_element_information18        	=>    p_element_information18
    ,p_element_information19        	=>    p_element_information19
    ,p_element_information20        	=>    p_element_information20
    ,p_third_party_pay_only_flag    	=>    p_third_party_pay_only_flag
    ,p_iterative_flag               	=>    p_iterative_flag
    ,p_iterative_formula_id         	=>    p_iterative_formula_id
    ,p_iterative_priority           	=>    p_iterative_priority
    ,p_creator_type                 	=>    p_creator_type
    ,p_retro_summ_ele_id            	=>    p_retro_summ_ele_id
    ,p_grossup_flag                 	=>    p_grossup_flag
    ,p_process_mode                 	=>    p_process_mode
    ,p_advance_indicator            	=>    p_advance_indicator
    ,p_advance_payable              	=>    p_advance_payable
    ,p_advance_deduction            	=>    p_advance_deduction
    ,p_process_advance_entry        	=>    p_process_advance_entry
    ,p_proration_group_id           	=>    p_proration_group_id
    ,p_proration_formula_id             =>    p_proration_formula_id
    ,p_recalc_event_group_id 	   	    =>    p_recalc_event_group_id
    ,p_once_each_period_flag            =>    p_once_each_period_flag
    ,p_time_definition_type             =>    p_time_definition_type
    ,p_time_definition_id               =>    p_time_definition_id
    ,p_element_type_id              	=>    l_element_type_id
    ,p_object_version_number        	=>    l_object_version_number
    ,p_effective_start_date         	=>    l_effective_start_date
    ,p_effective_end_date           	=>    l_effective_end_date
    ,p_comment_id    		        	=>    l_comment_id
    ,p_processing_priority_warning	    =>    l_processing_priority_warning
    );

  --
  -- Create default entries in pay_element_types_f_tl table
  --
  pay_ett_ins.ins_tl
    (p_language_code                =>  l_language_code
    ,p_element_type_id              =>  l_element_type_id
    ,p_element_name                 =>  p_element_name
    ,p_reporting_name               =>  p_reporting_name
    ,p_description                  =>  p_description
    );
  --
  -- Create element DB items on the entity horizon
  --
  hrdyndbi.create_element_type_dict(l_element_type_id,
                                    l_effective_start_date);


  If (p_process_in_run_flag = 'Y' and nvl(l_non_payments_flag,'Y') = 'N') Then
    --
    -- Create default input value
    --
    -- Bug 4445125. generate_db_items_flag must be always 'Y' for
    -- default input value.
    --
      l_generate_db_items_flag := 'Y';
    --
    l_display_sequence := l_display_sequence + 1;
    --
    pay_input_value_api.create_input_value
      (p_validate		 => false
      ,p_effective_date          => l_effective_date
      ,p_element_type_id         => l_element_type_id
      ,p_name                    => 'Pay Value'
      ,p_uom                     => 'M'
      ,p_display_sequence        => l_display_sequence
      ,p_generate_db_items_flag  => l_generate_db_items_flag
      ,p_input_value_id	         => l_input_value_id
      ,p_object_version_number   => l_iv_object_version_number
      ,p_effective_start_date    => l_iv_effective_start_date
      ,p_effective_end_date      => l_iv_effective_end_date
      ,p_default_val_warning     => l_default_val_warning
      ,p_min_max_warning         => l_min_max_warning
      ,p_pay_basis_warning	 => l_pay_basis_warning
      ,p_formula_warning	 => l_formula_warning
      ,p_assignment_id_warning   => l_assignment_id_warning
      ,p_formula_message         => l_formula_message
      );
    --
  End If;
  --
  Open c_contributions_used;
  Fetch c_contributions_used into l_contributions_used;
  Close c_contributions_used;
  --
  If nvl(l_contributions_used,'N') = 'Y' Then
    --
    -- Create default benefit input values for type A benefit plans
    --
    pay_input_value_api.create_input_value
      (p_validate		 => false
      ,p_effective_date          => l_effective_date
      ,p_element_type_id         => l_element_type_id
      ,p_name                    => 'Coverage'
      ,p_uom                     => 'C'
      ,p_display_sequence        => (l_display_sequence + 1)
      ,p_generate_db_items_flag  => 'Y'
      ,p_hot_default_flag        => 'N'
      ,p_input_value_id	         => l_input_value_id
      ,p_object_version_number   => l_iv_object_version_number
      ,p_effective_start_date    => l_iv_effective_start_date
      ,p_effective_end_date      => l_iv_effective_end_date
      ,p_default_val_warning     => l_default_val_warning
      ,p_min_max_warning         => l_min_max_warning
      ,p_pay_basis_warning	 => l_pay_basis_warning
      ,p_formula_warning	 => l_formula_warning
      ,p_assignment_id_warning   => l_assignment_id_warning
      ,p_formula_message         => l_formula_message
      );
	--
    pay_input_value_api.create_input_value
      (p_validate		 => false
      ,p_effective_date          => l_effective_date
      ,p_element_type_id         => l_element_type_id
      ,p_name                    => 'ER Contr'
      ,p_uom                     => p_default_uom
      ,p_display_sequence        => (l_display_sequence + 2)
      ,p_generate_db_items_flag  => 'Y'
      ,p_hot_default_flag        => 'N'
      ,p_input_value_id	         => l_input_value_id
      ,p_object_version_number   => l_iv_object_version_number
      ,p_effective_start_date    => l_iv_effective_start_date
      ,p_effective_end_date      => l_iv_effective_end_date
      ,p_default_val_warning     => l_default_val_warning
      ,p_min_max_warning         => l_min_max_warning
      ,p_pay_basis_warning	 => l_pay_basis_warning
      ,p_formula_warning	 => l_formula_warning
      ,p_assignment_id_warning   => l_assignment_id_warning
      ,p_formula_message         => l_formula_message
      );
	--
    pay_input_value_api.create_input_value
      (p_validate		 => false
      ,p_effective_date          => l_effective_date
      ,p_element_type_id         => l_element_type_id
      ,p_name                    => 'EE Contr'
      ,p_uom                     => p_default_uom
      ,p_display_sequence        => (l_display_sequence + 3)
      ,p_generate_db_items_flag  => 'Y'
      ,p_hot_default_flag        => 'N'
      ,p_input_value_id	         => l_input_value_id
      ,p_object_version_number   => l_iv_object_version_number
      ,p_effective_start_date    => l_iv_effective_start_date
      ,p_effective_end_date      => l_iv_effective_end_date
      ,p_default_val_warning     => l_default_val_warning
      ,p_min_max_warning         => l_min_max_warning
      ,p_pay_basis_warning	 => l_pay_basis_warning
      ,p_formula_warning	 => l_formula_warning
      ,p_assignment_id_warning   => l_assignment_id_warning
      ,p_formula_message         => l_formula_message
      );
	--
  End If;
  --
  -- Create sub-classification rules
  --
  pay_sub_class_rules_pkg.insert_defaults
    (l_element_type_id
    ,p_classification_id
    ,l_effective_start_date
    ,l_effective_end_date
    ,p_business_group_id
    ,null);
  --
  -- Populate the retro component usages for the element type.
  --
  pay_retro_comp_usage_internal.populate_retro_comp_usages
    (p_effective_date                => l_effective_date
    ,p_element_type_id               => l_element_type_id
    );
--
  --
  -- Call After Process User Hook
  --
  begin
    PAY_ELEMENT_TYPES_BK1.CREATE_ELEMENT_TYPE_a
      (p_effective_date                 =>   p_effective_date
      ,p_classification_id              =>   p_classification_id
      ,p_element_name                   =>   p_element_name
      ,p_business_group_id              =>   p_business_group_id
      ,p_legislation_code               =>   p_legislation_code
      ,p_formula_id                     =>   p_formula_id
      ,p_input_currency_code            =>   l_input_currency_code
      ,p_output_currency_code           =>   l_output_currency_code
      ,p_benefit_classification_id      =>   p_benefit_classification_id
      ,p_additional_entry_allowed_fla   =>   p_additional_entry_allowed_fla
      ,p_adjustment_only_flag           =>   p_adjustment_only_flag
      ,p_closed_for_entry_flag          =>   p_closed_for_entry_flag
      ,p_reporting_name                 =>   p_reporting_name
      ,p_description                    =>   p_description
      ,p_indirect_only_flag             =>   p_indirect_only_flag
      ,p_multiple_entries_allowed_fla   =>   p_multiple_entries_allowed_fla
      ,p_multiply_value_flag            =>   p_multiply_value_flag
      ,p_post_termination_rule          =>   p_post_termination_rule
      ,p_process_in_run_flag            =>   p_process_in_run_flag
      ,p_processing_priority            =>   l_processing_priority
      ,p_processing_type                =>   p_processing_type
      ,p_standard_link_flag             =>   p_standard_link_flag
      ,p_comments                       =>   p_comments
      ,p_legislation_subgroup           =>   p_legislation_subgroup
      ,p_qualifying_age                 =>   p_qualifying_age
      ,p_qualifying_length_of_service   =>   p_qualifying_length_of_service
      ,p_qualifying_units               =>   p_qualifying_units
      ,p_attribute_category             =>   p_attribute_category
      ,p_attribute1                     =>   p_attribute1
      ,p_attribute2                     =>   p_attribute2
      ,p_attribute3                     =>   p_attribute3
      ,p_attribute4                     =>   p_attribute4
      ,p_attribute5                     =>   p_attribute5
      ,p_attribute6                     =>   p_attribute6
      ,p_attribute7                     =>   p_attribute7
      ,p_attribute8                     =>   p_attribute8
      ,p_attribute9                     =>   p_attribute9
      ,p_attribute10                    =>   p_attribute10
      ,p_attribute11                    =>   p_attribute11
      ,p_attribute12                    =>   p_attribute12
      ,p_attribute13                    =>   p_attribute13
      ,p_attribute14                    =>   p_attribute14
      ,p_attribute15                    =>   p_attribute15
      ,p_attribute16                    =>   p_attribute16
      ,p_attribute17                    =>   p_attribute17
      ,p_attribute18                    =>   p_attribute18
      ,p_attribute19                    =>   p_attribute19
      ,p_attribute20                    =>   p_attribute20
      ,p_element_information_category   =>   p_element_information_category
      ,p_element_information1           =>   p_element_information1
      ,p_element_information2           =>   p_element_information2
      ,p_element_information3           =>   p_element_information3
      ,p_element_information4           =>   p_element_information4
      ,p_element_information5           =>   p_element_information5
      ,p_element_information6           =>   p_element_information6
      ,p_element_information7           =>   p_element_information7
      ,p_element_information8           =>   p_element_information8
      ,p_element_information9           =>   p_element_information9
      ,p_element_information10          =>   p_element_information10
      ,p_element_information11          =>   p_element_information11
      ,p_element_information12          =>   p_element_information12
      ,p_element_information13          =>   p_element_information13
      ,p_element_information14          =>   p_element_information14
      ,p_element_information15          =>   p_element_information15
      ,p_element_information16          =>   p_element_information16
      ,p_element_information17          =>   p_element_information17
      ,p_element_information18          =>   p_element_information18
      ,p_element_information19          =>   p_element_information19
      ,p_element_information20          =>   p_element_information20
      ,p_third_party_pay_only_flag      =>   p_third_party_pay_only_flag
      ,p_iterative_flag                 =>   p_iterative_flag
      ,p_iterative_formula_id           =>   p_iterative_formula_id
      ,p_iterative_priority             =>   p_iterative_priority
      ,p_creator_type                   =>   p_creator_type
      ,p_retro_summ_ele_id              =>   p_retro_summ_ele_id
      ,p_grossup_flag                   =>   p_grossup_flag
      ,p_process_mode                   =>   p_process_mode
      ,p_advance_indicator              =>   p_advance_indicator
      ,p_advance_payable                =>   p_advance_payable
      ,p_advance_deduction              =>   p_advance_deduction
      ,p_process_advance_entry          =>   p_process_advance_entry
      ,p_proration_group_id             =>   p_proration_group_id
      ,p_proration_formula_id           =>   p_proration_formula_id
      ,p_recalc_event_group_id 	        =>   p_recalc_event_group_id
      ,p_default_uom		            =>   p_default_uom
      ,p_once_each_period_flag          =>   p_once_each_period_flag
      ,p_language_code                  =>   l_language_code
      ,p_time_definition_type           =>   p_time_definition_type
      ,p_time_definition_id             =>   p_time_definition_id
      ,p_advance_element_type_id        =>   p_advance_element_type_id
      ,p_deduction_element_type_id      =>   p_deduction_element_type_id
      ,p_element_type_id                =>   l_element_type_id
      ,p_effective_start_date       	=>   l_effective_start_date
      ,p_effective_end_date         	=>   l_effective_end_date
      ,p_object_version_number      	=>   l_object_version_number
      ,p_comment_id			            =>   l_comment_id
      ,p_processing_priority_warning	=>   l_processing_priority_warning
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ELEMENT_TYPE'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_element_type_id             := l_element_type_id;
  p_effective_start_date        := l_effective_start_date;
  p_effective_end_date          := l_effective_end_date;
  p_object_version_number      	:= l_object_version_number;
  p_comment_id			:= l_comment_id;
  p_processing_priority_warning	:= l_processing_priority_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_ELEMENT_TYPE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_element_type_id          	  := null;
    p_object_version_number  	  := null;
    p_effective_start_date   	  := null;
    p_effective_end_date     	  := null;
    p_comment_id	          := null;
    p_processing_priority_warning := l_processing_priority_warning;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_ELEMENT_TYPE;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end CREATE_ELEMENT_TYPE;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< UPDATE_ELEMENT_TYPE >-------------------------|
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
  ,p_recalc_event_group_id 	         in	    number   default hr_api.g_number
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
  ,p_time_definition_type            in     varchar2 default hr_api.g_varchar2
  ,p_time_definition_id              in     number   default hr_api.g_number
  ,p_effective_start_date               out nocopy date
  ,p_effective_end_date                 out nocopy date
  ,p_comment_id                         out nocopy number
  ,p_processing_priority_warning        out nocopy boolean
  ,p_element_name_warning               out nocopy boolean
  ,p_element_name_change_warning        out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc               		varchar2(72):=g_package||'UPDATE_ELEMENT_TYPE';
  l_effective_date		date;
  l_effective_start_date        date;
  l_effective_end_date          date;
  l_processing_priority_warning boolean;
  l_element_name_warning        boolean;
  l_element_name_change_warning boolean;
  l_rowcount			number;
  l_datetrack_update_mode	varchar2(30) := p_datetrack_update_mode;
  l_object_version_number       pay_element_types_f.object_version_number%type;
  l_comment_id     		pay_element_types_f.comment_id%type;
  l_old_rec			pay_element_types_f%rowtype;
  l_current_rec                 pay_element_types_f_tl%rowtype;
  l_base_element_name           pay_element_types_f.element_name%type;
  l_recreate_db_items           varchar2(1) := 'N';
  l_language_code               pay_element_types_f_tl.language%type;


  Cursor c_old_rec (v_effective_date date)
  is
    select etp.*
      from pay_element_types_f etp
     where element_type_id = p_element_type_id
       and nvl(v_effective_date,effective_start_date) >= effective_start_date
       and nvl(v_effective_date,effective_end_date) <= effective_end_date;
  --
  CURSOR elem_cursor (p_language_code in varchar2)
  IS
    SELECT source_lang, element_name, element_type_id
      FROM pay_element_types_f_tl ett
     WHERE ett.element_type_id = p_element_type_id
       AND ett.language = nvl(p_language_code,ett.language);

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_ELEMENT_TYPE;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date        := trunc(p_effective_date);
  l_object_version_number := p_object_version_number;
  --
  -- Validate the language parameter. l_language_code should be passed to
  -- functions instead of p_language_code from now on, to allow an IN OUT
  -- parameter to be passed through.
  --
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  --
  l_element_name_warning := false;
  l_element_name_change_warning := false;
  --
  -- Call Before Process User Hook
  --
  begin
    PAY_ELEMENT_TYPES_BK2.UPDATE_ELEMENT_TYPE_b
     (p_effective_date                  =>   l_effective_date
     ,p_datetrack_update_mode		=>   p_datetrack_update_mode
     ,p_element_type_id        	        =>   p_element_type_id
     ,p_object_version_number  		=>   l_object_version_number
     ,p_formula_id                  	=>   p_formula_id
     ,p_benefit_classification_id   	=>   p_benefit_classification_id
     ,p_additional_entry_allowed_fla    =>   p_additional_entry_allowed_fla
     ,p_adjustment_only_flag        	=>   p_adjustment_only_flag
     ,p_closed_for_entry_flag       	=>   p_closed_for_entry_flag
     ,p_element_name                	=>   p_element_name
     ,p_reporting_name              	=>   p_reporting_name
     ,p_description                 	=>   p_description
     ,p_indirect_only_flag          	=>   p_indirect_only_flag
     ,p_multiple_entries_allowed_fla    =>   p_multiple_entries_allowed_fla
     ,p_multiply_value_flag         	=>   p_multiply_value_flag
     ,p_post_termination_rule       	=>   p_post_termination_rule
     ,p_process_in_run_flag         	=>   p_process_in_run_flag
     ,p_processing_priority         	=>   p_processing_priority
     ,p_standard_link_flag          	=>   p_standard_link_flag
     ,p_comments                    	=>   p_comments
     ,p_qualifying_age              	=>   p_qualifying_age
     ,p_qualifying_length_of_service    =>   p_qualifying_length_of_service
     ,p_qualifying_units            	=>   p_qualifying_units
     ,p_attribute_category          	=>   p_attribute_category
     ,p_attribute1                  	=>   p_attribute1
     ,p_attribute2                  	=>   p_attribute2
     ,p_attribute3                  	=>   p_attribute3
     ,p_attribute4                  	=>   p_attribute4
     ,p_attribute5                  	=>   p_attribute5
     ,p_attribute6                  	=>   p_attribute6
     ,p_attribute7                  	=>   p_attribute7
     ,p_attribute8                  	=>   p_attribute8
     ,p_attribute9                  	=>   p_attribute9
     ,p_attribute10                 	=>   p_attribute10
     ,p_attribute11                 	=>   p_attribute11
     ,p_attribute12                 	=>   p_attribute12
     ,p_attribute13                 	=>   p_attribute13
     ,p_attribute14                 	=>   p_attribute14
     ,p_attribute15                 	=>   p_attribute15
     ,p_attribute16                 	=>   p_attribute16
     ,p_attribute17                 	=>   p_attribute17
     ,p_attribute18                 	=>   p_attribute18
     ,p_attribute19                 	=>   p_attribute19
     ,p_attribute20                 	=>   p_attribute20
     ,p_element_information_category    =>   p_element_information_category
     ,p_element_information1        	=>   p_element_information1
     ,p_element_information2        	=>   p_element_information2
     ,p_element_information3        	=>   p_element_information3
     ,p_element_information4        	=>   p_element_information4
     ,p_element_information5        	=>   p_element_information5
     ,p_element_information6        	=>   p_element_information6
     ,p_element_information7        	=>   p_element_information7
     ,p_element_information8        	=>   p_element_information8
     ,p_element_information9        	=>   p_element_information9
     ,p_element_information10       	=>   p_element_information10
     ,p_element_information11       	=>   p_element_information11
     ,p_element_information12       	=>   p_element_information12
     ,p_element_information13       	=>   p_element_information13
     ,p_element_information14       	=>   p_element_information14
     ,p_element_information15       	=>   p_element_information15
     ,p_element_information16       	=>   p_element_information16
     ,p_element_information17       	=>   p_element_information17
     ,p_element_information18       	=>   p_element_information18
     ,p_element_information19       	=>   p_element_information19
     ,p_element_information20       	=>   p_element_information20
     ,p_third_party_pay_only_flag   	=>   p_third_party_pay_only_flag
     ,p_iterative_flag              	=>   p_iterative_flag
     ,p_iterative_formula_id        	=>   p_iterative_formula_id
     ,p_iterative_priority          	=>   p_iterative_priority
     ,p_creator_type                	=>   p_creator_type
     ,p_retro_summ_ele_id           	=>   p_retro_summ_ele_id
     ,p_grossup_flag                	=>   p_grossup_flag
     ,p_process_mode                	=>   p_process_mode
     ,p_advance_indicator           	=>   p_advance_indicator
     ,p_advance_payable             	=>   p_advance_payable
     ,p_advance_deduction           	=>   p_advance_deduction
     ,p_process_advance_entry       	=>   p_process_advance_entry
     ,p_proration_group_id          	=>   p_proration_group_id
     ,p_proration_formula_id        	=>   p_proration_formula_id
     ,p_recalc_event_group_id 		    =>   p_recalc_event_group_id
     ,p_once_each_period_flag           =>   p_once_each_period_flag
     ,p_language_code                   =>   l_language_code
     ,p_time_definition_type            =>   p_time_definition_type
     ,p_time_definition_id              =>   p_time_definition_id
     ,p_advance_element_type_id         =>   p_advance_element_type_id
     ,p_deduction_element_type_id       =>   p_deduction_element_type_id
     );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ELEMENT_TYPE'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  Open c_old_rec(l_effective_date);
  Fetch c_old_rec into l_old_rec;
  If c_old_rec%notfound then
    Close c_old_rec;
    --
    -- The primary key is invalid therefore we must error
    --
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  End If;
  Close c_old_rec;
  --
  -- Enforce datetrack mode to 'CORRECTION' if certain columns are updated.
  --
  If (
     (p_element_name <> hr_api.g_varchar2 and
      p_element_name <> l_old_rec.element_name)
     or
     (p_reporting_name <> hr_api.g_varchar2 and
      p_reporting_name <> l_old_rec.reporting_name)
     or
     (p_indirect_only_flag <> hr_api.g_varchar2 and
      p_indirect_only_flag <> l_old_rec.indirect_only_flag)
     or
     (p_additional_entry_allowed_fla <> hr_api.g_varchar2 and
      p_additional_entry_allowed_fla <>
      l_old_rec.additional_entry_allowed_flag)
     or
     (p_standard_link_flag <> hr_api.g_varchar2 and
      p_standard_link_flag <> l_old_rec.standard_link_flag)
     or
     (p_adjustment_only_flag <> hr_api.g_varchar2 and
      p_adjustment_only_flag <> l_old_rec.adjustment_only_flag)
     or
     (p_post_termination_rule <> hr_api.g_varchar2 and
      p_post_termination_rule <> l_old_rec.post_termination_rule)
     or
     (p_process_in_run_flag <> hr_api.g_varchar2 and
      p_process_in_run_flag <> l_old_rec.process_in_run_flag)
     or
     (p_third_party_pay_only_flag <> hr_api.g_varchar2 and
      p_third_party_pay_only_flag <> l_old_rec.third_party_pay_only_flag)
     or
     (p_once_each_period_flag <> hr_api.g_varchar2 and
      p_once_each_period_flag <> l_old_rec.once_each_period_flag)
     ) Then
    --
    Open c_old_rec(null);
    Loop
      Fetch c_old_rec into l_old_rec;
      Exit When c_old_rec%notfound;
    End Loop;
    l_rowcount := c_old_rec%rowcount;
    Close c_old_rec;
    --
    If l_rowcount > 1 then
    --
    -- Update not allowed if element has already been date-effectively
    -- updated.
    --
      fnd_message.set_name('PAY', 'PAY_34151_ELE_NO_DATE_UPD');
      fnd_message.raise_error;
    End If;
    --
    If nvl(p_datetrack_update_mode,hr_api.g_correction)
  	   <> hr_api.g_correction Then
      l_datetrack_update_mode := hr_api.g_correction;
    End if;
    --
  End If;
  --
  l_base_element_name := l_old_rec.element_name;
  --
  -- Fetch the TL row for the userenv language
  --
  Open elem_cursor(l_language_code);
  Fetch elem_cursor into l_current_rec.source_lang,
                         l_current_rec.element_name,
			 l_current_rec.element_type_id;
  Close elem_cursor;
  --
  If (p_element_name <> hr_api.g_varchar2 and
      p_element_name <> l_current_rec.element_name) then
    --
    -- Fetch all the TL rows for the element
    --
    for elem_record in elem_cursor (null)
    loop
      if l_current_rec.element_name = elem_record.element_name then
        if elem_record.source_lang = l_language_code then
          l_base_element_name := p_element_name;
	  l_recreate_db_items := 'Y';
        else
	  l_element_name_warning := true;
        end if;
      end if;
    end loop;
    --
    l_element_name_change_warning := true;
    --
  End If;
  --
  --
  -- Process Logic
  --
  pay_etp_upd_nd.upd
    (p_effective_date               	=>	 l_effective_date
    ,p_datetrack_mode               	=>	 l_datetrack_update_mode
    ,p_element_type_id              	=>	 p_element_type_id
    ,p_object_version_number        	=>	 l_object_version_number
    ,p_additional_entry_allowed_fla 	=>	 p_additional_entry_allowed_fla
    ,p_adjustment_only_flag         	=>	 p_adjustment_only_flag
    ,p_closed_for_entry_flag        	=>	 p_closed_for_entry_flag
    ,p_element_name                 	=>	 l_base_element_name
    ,p_indirect_only_flag           	=>	 p_indirect_only_flag
    ,p_multiple_entries_allowed_fla 	=>	 p_multiple_entries_allowed_fla
    ,p_multiply_value_flag          	=>	 p_multiply_value_flag
    ,p_post_termination_rule        	=>	 p_post_termination_rule
    ,p_process_in_run_flag          	=>	 p_process_in_run_flag
    ,p_processing_priority          	=>	 p_processing_priority
    ,p_standard_link_flag           	=>	 p_standard_link_flag
    ,p_formula_id                   	=>	 p_formula_id
    ,p_benefit_classification_id    	=>	 p_benefit_classification_id
    ,p_description                  	=>	 p_description
    ,p_qualifying_age               	=>	 p_qualifying_age
    ,p_qualifying_length_of_service 	=>	 p_qualifying_length_of_service
    ,p_qualifying_units             	=>	 p_qualifying_units
    ,p_reporting_name               	=>	 p_reporting_name
    ,p_attribute_category           	=>	 p_attribute_category
    ,p_attribute1                   	=>	 p_attribute1
    ,p_attribute2                   	=>	 p_attribute2
    ,p_attribute3                   	=>	 p_attribute3
    ,p_attribute4                   	=>	 p_attribute4
    ,p_attribute5                   	=>	 p_attribute5
    ,p_attribute6                   	=>	 p_attribute6
    ,p_attribute7                   	=>	 p_attribute7
    ,p_attribute8                   	=>	 p_attribute8
    ,p_attribute9                   	=>	 p_attribute9
    ,p_attribute10                  	=>	 p_attribute10
    ,p_attribute11                  	=>	 p_attribute11
    ,p_attribute12                  	=>	 p_attribute12
    ,p_attribute13                  	=>	 p_attribute13
    ,p_attribute14                  	=>	 p_attribute14
    ,p_attribute15                  	=>	 p_attribute15
    ,p_attribute16                  	=>	 p_attribute16
    ,p_attribute17                  	=>	 p_attribute17
    ,p_attribute18                  	=>	 p_attribute18
    ,p_attribute19                  	=>	 p_attribute19
    ,p_attribute20                  	=>	 p_attribute20
    ,p_element_information_category 	=>	 p_element_information_category
    ,p_element_information1         	=>	 p_element_information1
    ,p_element_information2         	=>	 p_element_information2
    ,p_element_information3         	=>	 p_element_information3
    ,p_element_information4         	=>	 p_element_information4
    ,p_element_information5         	=>	 p_element_information5
    ,p_element_information6         	=>	 p_element_information6
    ,p_element_information7         	=>	 p_element_information7
    ,p_element_information8         	=>	 p_element_information8
    ,p_element_information9         	=>	 p_element_information9
    ,p_element_information10        	=>	 p_element_information10
    ,p_element_information11        	=>	 p_element_information11
    ,p_element_information12        	=>	 p_element_information12
    ,p_element_information13        	=>	 p_element_information13
    ,p_element_information14        	=>	 p_element_information14
    ,p_element_information15        	=>	 p_element_information15
    ,p_element_information16        	=>	 p_element_information16
    ,p_element_information17        	=>	 p_element_information17
    ,p_element_information18        	=>	 p_element_information18
    ,p_element_information19        	=>	 p_element_information19
    ,p_element_information20        	=>	 p_element_information20
    ,p_third_party_pay_only_flag    	=>	 p_third_party_pay_only_flag
    ,p_iterative_flag               	=>	 p_iterative_flag
    ,p_iterative_formula_id         	=>	 p_iterative_formula_id
    ,p_iterative_priority           	=>	 p_iterative_priority
    ,p_creator_type                 	=>	 p_creator_type
    ,p_retro_summ_ele_id            	=>	 p_retro_summ_ele_id
    ,p_grossup_flag                 	=>	 p_grossup_flag
    ,p_process_mode                 	=>	 p_process_mode
    ,p_advance_indicator            	=>	 p_advance_indicator
    ,p_advance_payable              	=>	 p_advance_payable
    ,p_advance_deduction            	=>	 p_advance_deduction
    ,p_process_advance_entry        	=>	 p_process_advance_entry
    ,p_proration_group_id           	=>	 p_proration_group_id
    ,p_proration_formula_id         	=>	 p_proration_formula_id
    ,p_recalc_event_group_id        	=>	 p_recalc_event_group_id
    ,p_once_each_period_flag            =>   p_once_each_period_flag
    ,p_time_definition_type             =>   p_time_definition_type
    ,p_time_definition_id               =>   p_time_definition_id
    ,p_effective_start_date         	=>	 l_effective_start_date
    ,p_effective_end_date           	=>	 l_effective_end_date
    ,p_comment_id                   	=>	 l_comment_id
    ,p_processing_priority_warning	=>       l_processing_priority_warning
    );

  --
  -- Update the translation table values
  --
  pay_ett_upd.upd_tl
    (p_language_code    => l_language_code
    ,p_element_type_id  => p_element_type_id
    ,p_element_name     => p_element_name
    ,p_reporting_name   => p_reporting_name
    ,p_description      => p_description
    );

  -- If the element name is updated then drop and recreate DB items
  --
  If l_recreate_db_items = 'Y' then
    pay_element_types_pkg.recreate_db_items
      (p_element_type_id,
       l_effective_date);
  End If;

  -- If the Multiple Entries Allowed is updated then Re-create all the input
  -- value DB items for the element.
  --
  If nvl(p_multiple_entries_allowed_fla,hr_api.g_varchar2)
     <> hr_api.g_varchar2 Then
    pay_input_values_pkg.recreate_db_items(p_element_type_id);
  End If;
  --
  -- Call After Process User Hook
  --
  begin
    PAY_ELEMENT_TYPES_BK2.UPDATE_ELEMENT_TYPE_a
     (p_effective_date                  =>   l_effective_date
     ,p_datetrack_update_mode		=>   l_datetrack_update_mode
     ,p_element_type_id        	        =>   p_element_type_id
     ,p_object_version_number  		=>   l_object_version_number
     ,p_formula_id                  	=>   p_formula_id
     ,p_benefit_classification_id   	=>   p_benefit_classification_id
     ,p_additional_entry_allowed_fla    =>   p_additional_entry_allowed_fla
     ,p_adjustment_only_flag        	=>   p_adjustment_only_flag
     ,p_closed_for_entry_flag       	=>   p_closed_for_entry_flag
     ,p_element_name                	=>   p_element_name
     ,p_reporting_name              	=>   p_reporting_name
     ,p_description                 	=>   p_description
     ,p_indirect_only_flag          	=>   p_indirect_only_flag
     ,p_multiple_entries_allowed_fla    =>   p_multiple_entries_allowed_fla
     ,p_multiply_value_flag         	=>   p_multiply_value_flag
     ,p_post_termination_rule       	=>   p_post_termination_rule
     ,p_process_in_run_flag         	=>   p_process_in_run_flag
     ,p_processing_priority         	=>   p_processing_priority
     ,p_standard_link_flag          	=>   p_standard_link_flag
     ,p_comments                    	=>   p_comments
     ,p_comment_id			            =>   l_comment_id
     ,p_qualifying_age              	=>   p_qualifying_age
     ,p_qualifying_length_of_service    =>   p_qualifying_length_of_service
     ,p_qualifying_units            	=>   p_qualifying_units
     ,p_attribute_category          	=>   p_attribute_category
     ,p_attribute1                  	=>   p_attribute1
     ,p_attribute2                  	=>   p_attribute2
     ,p_attribute3                  	=>   p_attribute3
     ,p_attribute4                  	=>   p_attribute4
     ,p_attribute5                  	=>   p_attribute5
     ,p_attribute6                  	=>   p_attribute6
     ,p_attribute7                  	=>   p_attribute7
     ,p_attribute8                  	=>   p_attribute8
     ,p_attribute9                  	=>   p_attribute9
     ,p_attribute10                 	=>   p_attribute10
     ,p_attribute11                 	=>   p_attribute11
     ,p_attribute12                 	=>   p_attribute12
     ,p_attribute13                 	=>   p_attribute13
     ,p_attribute14                 	=>   p_attribute14
     ,p_attribute15                 	=>   p_attribute15
     ,p_attribute16                 	=>   p_attribute16
     ,p_attribute17                 	=>   p_attribute17
     ,p_attribute18                 	=>   p_attribute18
     ,p_attribute19                 	=>   p_attribute19
     ,p_attribute20                 	=>   p_attribute20
     ,p_element_information_category    =>   p_element_information_category
     ,p_element_information1        	=>   p_element_information1
     ,p_element_information2        	=>   p_element_information2
     ,p_element_information3        	=>   p_element_information3
     ,p_element_information4        	=>   p_element_information4
     ,p_element_information5        	=>   p_element_information5
     ,p_element_information6        	=>   p_element_information6
     ,p_element_information7        	=>   p_element_information7
     ,p_element_information8        	=>   p_element_information8
     ,p_element_information9        	=>   p_element_information9
     ,p_element_information10       	=>   p_element_information10
     ,p_element_information11       	=>   p_element_information11
     ,p_element_information12       	=>   p_element_information12
     ,p_element_information13       	=>   p_element_information13
     ,p_element_information14       	=>   p_element_information14
     ,p_element_information15       	=>   p_element_information15
     ,p_element_information16       	=>   p_element_information16
     ,p_element_information17       	=>   p_element_information17
     ,p_element_information18       	=>   p_element_information18
     ,p_element_information19       	=>   p_element_information19
     ,p_element_information20       	=>   p_element_information20
     ,p_third_party_pay_only_flag   	=>   p_third_party_pay_only_flag
     ,p_iterative_flag              	=>   p_iterative_flag
     ,p_iterative_formula_id        	=>   p_iterative_formula_id
     ,p_iterative_priority          	=>   p_iterative_priority
     ,p_creator_type                	=>   p_creator_type
     ,p_retro_summ_ele_id           	=>   p_retro_summ_ele_id
     ,p_grossup_flag                	=>   p_grossup_flag
     ,p_process_mode                	=>   p_process_mode
     ,p_advance_indicator           	=>   p_advance_indicator
     ,p_advance_payable             	=>   p_advance_payable
     ,p_advance_deduction           	=>   p_advance_deduction
     ,p_process_advance_entry       	=>   p_process_advance_entry
     ,p_proration_group_id          	=>   p_proration_group_id
     ,p_proration_formula_id        	=>   p_proration_formula_id
     ,p_recalc_event_group_id 	    	=>   p_recalc_event_group_id
     ,p_once_each_period_flag           =>   p_once_each_period_flag
     ,p_language_code                   =>   l_language_code
     ,p_time_definition_type            =>   p_time_definition_type
     ,p_time_definition_id              =>   p_time_definition_id
     ,p_advance_element_type_id         =>   p_advance_element_type_id
     ,p_deduction_element_type_id       =>   p_deduction_element_type_id
     ,p_effective_start_date            =>   l_effective_start_date
     ,p_effective_end_date            	=>   l_effective_end_date
     ,p_processing_priority_warning     =>   l_processing_priority_warning
     ,p_element_name_warning            =>   l_element_name_warning
     ,p_element_name_change_warning     =>   l_element_name_change_warning
     );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ELEMENT_TYPE'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_effective_start_date        := l_effective_start_date;
  p_effective_end_date          := l_effective_end_date;
  p_object_version_number      	:= l_object_version_number;
  p_comment_id			:= l_comment_id;
  p_processing_priority_warning	:= l_processing_priority_warning;
  p_element_name_warning        := l_element_name_warning;
  p_element_name_change_warning := l_element_name_change_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_ELEMENT_TYPE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_start_date        := null;
    p_effective_end_date          := null;
    p_object_version_number       := null;
    p_comment_id		  := null;
    p_processing_priority_warning := l_processing_priority_warning;
    p_element_name_warning        := l_element_name_warning;
    p_element_name_change_warning := l_element_name_change_warning;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_ELEMENT_TYPE;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end UPDATE_ELEMENT_TYPE;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< DELETE_ELEMENT_TYPE >-------------------------|
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
  ,p_balance_feeds_warning              out nocopy boolean
  ,p_processing_rules_warning           out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                	varchar2(72):=g_package||'DELETE_ELEMENT_TYP';
  l_effective_date		date;
  l_effective_start_date        date;
  l_effective_end_date          date;
  l_balance_feeds_warning 	boolean;
  l_processing_rules_warning    boolean;
  l_object_version_number       pay_element_types_f.object_version_number%type;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_ELEMENT_TYPE;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date	  := trunc(p_effective_date);
  l_object_version_number := p_object_version_number;
  --
  -- Call Before Process User Hook
  --
  begin
    PAY_ELEMENT_TYPES_BK3.DELETE_ELEMENT_TYPE_b
      (p_effective_date              =>  l_effective_date
      ,p_datetrack_delete_mode       =>  p_datetrack_delete_mode
      ,p_element_type_id             =>  p_element_type_id
      ,p_object_version_number       =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ELEMENT_TYPE'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

  --
  -- Process Logic
  --
  pay_etp_del_nd.del
    (p_effective_date		=>  l_effective_date
    ,p_datetrack_mode 		=>  p_datetrack_delete_mode
    ,p_element_type_id		=>  p_element_type_id
    ,p_object_version_number    =>  l_object_version_number
    ,p_effective_start_date     =>  l_effective_start_date
    ,p_effective_end_date       =>  l_effective_end_date
    ,p_balance_feeds_warning    =>  l_balance_feeds_warning
    ,p_processing_rules_warning =>  l_processing_rules_warning
    );

  --
  -- Call After Process User Hook
  --
  begin
    PAY_ELEMENT_TYPES_BK3.DELETE_ELEMENT_TYPE_a
      (p_effective_date              =>  p_effective_date
      ,p_datetrack_delete_mode       =>  p_datetrack_delete_mode
      ,p_element_type_id             =>  p_element_type_id
      ,p_object_version_number       =>  l_object_version_number
      ,p_effective_start_date        =>  l_effective_start_date
      ,p_effective_end_date          =>  l_effective_end_date
      ,p_balance_feeds_warning       =>  l_balance_feeds_warning
      ,p_processing_rules_warning    =>  l_processing_rules_warning
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ELEMENT_TYPE'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_effective_start_date        := l_effective_start_date;
  p_effective_end_date          := l_effective_end_date;
  p_object_version_number      	:= l_object_version_number;
  p_balance_feeds_warning	    := l_balance_feeds_warning;
  p_processing_rules_warning	:= l_processing_rules_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_ELEMENT_TYPE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_start_date        := null;
    p_effective_end_date          := null;
    p_object_version_number       := null;
    p_balance_feeds_warning	  := l_balance_feeds_warning;
    p_processing_rules_warning	  := l_processing_rules_warning;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to DELETE_ELEMENT_TYPE;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end DELETE_ELEMENT_TYPE;
--

end PAY_ELEMENT_TYPES_MIG;

/
