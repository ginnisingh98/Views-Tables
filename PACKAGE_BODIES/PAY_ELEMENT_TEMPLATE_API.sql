--------------------------------------------------------
--  DDL for Package Body PAY_ELEMENT_TEMPLATE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ELEMENT_TEMPLATE_API" as
/* $Header: pyetmapi.pkb 120.0 2005/05/29 04:41:31 appldev noship $ */
--
-- Package Variables
--
g_debug boolean := hr_utility.debug_enabled;
g_package  varchar2(33) := '  pay_element_template_api.';
-- ----------------------------------------------------------------------------
-- |------------------------< create_user_structure >-------------------------|
-- ----------------------------------------------------------------------------
procedure create_user_structure
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_source_template_id            in     number
  ,p_base_name                     in     varchar2
  ,p_base_processing_priority      in     number   default null
  ,p_preference_info_category      in     varchar2 default null
  ,p_preference_information1       in     varchar2 default null
  ,p_preference_information2       in     varchar2 default null
  ,p_preference_information3       in     varchar2 default null
  ,p_preference_information4       in     varchar2 default null
  ,p_preference_information5       in     varchar2 default null
  ,p_preference_information6       in     varchar2 default null
  ,p_preference_information7       in     varchar2 default null
  ,p_preference_information8       in     varchar2 default null
  ,p_preference_information9       in     varchar2 default null
  ,p_preference_information10      in     varchar2 default null
  ,p_preference_information11      in     varchar2 default null
  ,p_preference_information12      in     varchar2 default null
  ,p_preference_information13      in     varchar2 default null
  ,p_preference_information14      in     varchar2 default null
  ,p_preference_information15      in     varchar2 default null
  ,p_preference_information16      in     varchar2 default null
  ,p_preference_information17      in     varchar2 default null
  ,p_preference_information18      in     varchar2 default null
  ,p_preference_information19      in     varchar2 default null
  ,p_preference_information20      in     varchar2 default null
  ,p_preference_information21      in     varchar2 default null
  ,p_preference_information22      in     varchar2 default null
  ,p_preference_information23      in     varchar2 default null
  ,p_preference_information24      in     varchar2 default null
  ,p_preference_information25      in     varchar2 default null
  ,p_preference_information26      in     varchar2 default null
  ,p_preference_information27      in     varchar2 default null
  ,p_preference_information28      in     varchar2 default null
  ,p_preference_information29      in     varchar2 default null
  ,p_preference_information30      in     varchar2 default null
  ,p_configuration_info_category   in     varchar2 default null
  ,p_configuration_information1    in     varchar2 default null
  ,p_configuration_information2    in     varchar2 default null
  ,p_configuration_information3    in     varchar2 default null
  ,p_configuration_information4    in     varchar2 default null
  ,p_configuration_information5    in     varchar2 default null
  ,p_configuration_information6    in     varchar2 default null
  ,p_configuration_information7    in     varchar2 default null
  ,p_configuration_information8    in     varchar2 default null
  ,p_configuration_information9    in     varchar2 default null
  ,p_configuration_information10   in     varchar2 default null
  ,p_configuration_information11   in     varchar2 default null
  ,p_configuration_information12   in     varchar2 default null
  ,p_configuration_information13   in     varchar2 default null
  ,p_configuration_information14   in     varchar2 default null
  ,p_configuration_information15   in     varchar2 default null
  ,p_configuration_information16   in     varchar2 default null
  ,p_configuration_information17   in     varchar2 default null
  ,p_configuration_information18   in     varchar2 default null
  ,p_configuration_information19   in     varchar2 default null
  ,p_configuration_information20   in     varchar2 default null
  ,p_configuration_information21   in     varchar2 default null
  ,p_configuration_information22   in     varchar2 default null
  ,p_configuration_information23   in     varchar2 default null
  ,p_configuration_information24   in     varchar2 default null
  ,p_configuration_information25   in     varchar2 default null
  ,p_configuration_information26   in     varchar2 default null
  ,p_configuration_information27   in     varchar2 default null
  ,p_configuration_information28   in     varchar2 default null
  ,p_configuration_information29   in     varchar2 default null
  ,p_configuration_information30   in     varchar2 default null
  ,p_prefix_reporting_name         in     varchar2 default 'N'
  ,p_allow_base_name_reuse         in     boolean  default false
  ,p_template_id                      out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_user_structure';
  l_effective_date      date;
  l_template_id         number;
  l_ovn                 number;
  l_template_type       varchar2(2000);
  -----------------------------
  -- PL/SQL template tables. --
  -----------------------------
  l_element_template    pay_etm_shd.g_rec_type;
  l_core_objects        pay_element_template_util.t_core_objects;
  l_exclusion_rules     pay_element_template_util.t_exclusion_rules;
  l_formulas            pay_element_template_util.t_formulas;
  l_balance_types       pay_element_template_util.t_balance_types;
  l_defined_balances    pay_element_template_util.t_defined_balances;
  l_element_types       pay_element_template_util.t_element_types;
  l_sub_classi_rules    pay_element_template_util.t_sub_classi_rules;
  l_balance_classis     pay_element_template_util.t_balance_classis;
  l_input_values        pay_element_template_util.t_input_values;
  l_balance_feeds       pay_element_template_util.t_balance_feeds;
  l_formula_rules       pay_element_template_util.t_formula_rules;
  l_iterative_rules     pay_element_template_util.t_iterative_rules;
  l_ele_type_usages     pay_element_template_util.t_ele_type_usages;
  l_gu_bal_exclusions   pay_element_template_util.t_gu_bal_exclusions;
  l_template_ff_usages  pay_element_template_util.t_template_ff_usages;
  l_bal_attributes      pay_element_template_util.t_bal_attributes;
begin
  --
  -- Set the ALLOW_BASE_NAME_REUSE flag.
  --
  pay_etm_shd.g_allow_base_name_reuse := p_allow_base_name_reuse;
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint create_user_structure;
  if g_debug then
     hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Check mandatory arguments.
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'p_effective_date',
     p_argument_value => p_effective_date);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'p_business_group_id',
     p_argument_value => p_business_group_id);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'p_source_template_id',
     p_argument_value => p_source_template_id);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'p_base_name',
     p_argument_value => p_base_name);
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  if g_debug then
     hr_utility.set_location(l_proc, 30);
  end if;
  --
  -- Validation in addition to Row Handlers
  --
  -- Process Logic
  --
  l_template_type :=
  pay_element_template_util.get_template_type(p_source_template_id);
  if l_template_type is null or l_template_type <> 'T' then
    hr_utility.set_message(801, 'PAY_50057_BAD_SOURCE_TEMPLATE');
    hr_utility.raise_error;
  end if;
  --
  if g_debug then
     hr_utility.set_location(l_proc, 50);
  end if;
  pay_element_template_util.create_plsql_template
  (p_lock                         => false
  ,p_template_id                  => p_source_template_id
  ,p_element_template             => l_element_template
  ,p_core_objects                 => l_core_objects
  ,p_exclusion_rules              => l_exclusion_rules
  ,p_formulas                     => l_formulas
  ,p_balance_types                => l_balance_types
  ,p_defined_balances             => l_defined_balances
  ,p_element_types                => l_element_types
  ,p_sub_classi_rules             => l_sub_classi_rules
  ,p_balance_classis              => l_balance_classis
  ,p_input_values                 => l_input_values
  ,p_balance_feeds                => l_balance_feeds
  ,p_formula_rules                => l_formula_rules
  ,p_iterative_rules              => l_iterative_rules
  ,p_ele_type_usages              => l_ele_type_usages
  ,p_gu_bal_exclusions            => l_gu_bal_exclusions
  ,p_template_ff_usages           => l_template_ff_usages
  ,p_bal_attributes               => l_bal_attributes
  );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 51);
  end if;
  pay_element_template_util.create_plsql_user_structure
  (p_business_group_id            => p_business_group_id
  ,p_base_name                    => p_base_name
  ,p_base_processing_priority     => p_base_processing_priority
  ,p_preference_info_category     => p_preference_info_category
  ,p_preference_information1      => p_preference_information1
  ,p_preference_information2      => p_preference_information2
  ,p_preference_information3      => p_preference_information3
  ,p_preference_information4      => p_preference_information4
  ,p_preference_information5      => p_preference_information5
  ,p_preference_information6      => p_preference_information6
  ,p_preference_information7      => p_preference_information7
  ,p_preference_information8      => p_preference_information8
  ,p_preference_information9      => p_preference_information9
  ,p_preference_information10     => p_preference_information10
  ,p_preference_information11     => p_preference_information11
  ,p_preference_information12     => p_preference_information12
  ,p_preference_information13     => p_preference_information13
  ,p_preference_information14     => p_preference_information14
  ,p_preference_information15     => p_preference_information15
  ,p_preference_information16     => p_preference_information16
  ,p_preference_information17     => p_preference_information17
  ,p_preference_information18     => p_preference_information18
  ,p_preference_information19     => p_preference_information19
  ,p_preference_information20     => p_preference_information20
  ,p_preference_information21     => p_preference_information21
  ,p_preference_information22     => p_preference_information22
  ,p_preference_information23     => p_preference_information23
  ,p_preference_information24     => p_preference_information24
  ,p_preference_information25     => p_preference_information25
  ,p_preference_information26     => p_preference_information26
  ,p_preference_information27     => p_preference_information27
  ,p_preference_information28     => p_preference_information28
  ,p_preference_information29     => p_preference_information29
  ,p_preference_information30     => p_preference_information30
  ,p_configuration_info_category  => p_configuration_info_category
  ,p_configuration_information1   => p_configuration_information1
  ,p_configuration_information2   => p_configuration_information2
  ,p_configuration_information3   => p_configuration_information3
  ,p_configuration_information4   => p_configuration_information4
  ,p_configuration_information5   => p_configuration_information5
  ,p_configuration_information6   => p_configuration_information6
  ,p_configuration_information7   => p_configuration_information7
  ,p_configuration_information8   => p_configuration_information8
  ,p_configuration_information9   => p_configuration_information9
  ,p_configuration_information10  => p_configuration_information10
  ,p_configuration_information11  => p_configuration_information11
  ,p_configuration_information12  => p_configuration_information12
  ,p_configuration_information13  => p_configuration_information13
  ,p_configuration_information14  => p_configuration_information14
  ,p_configuration_information15  => p_configuration_information15
  ,p_configuration_information16  => p_configuration_information16
  ,p_configuration_information17  => p_configuration_information17
  ,p_configuration_information18  => p_configuration_information18
  ,p_configuration_information19  => p_configuration_information19
  ,p_configuration_information20  => p_configuration_information20
  ,p_configuration_information21  => p_configuration_information21
  ,p_configuration_information22  => p_configuration_information22
  ,p_configuration_information23  => p_configuration_information23
  ,p_configuration_information24  => p_configuration_information24
  ,p_configuration_information25  => p_configuration_information25
  ,p_configuration_information26  => p_configuration_information26
  ,p_configuration_information27  => p_configuration_information27
  ,p_configuration_information28  => p_configuration_information28
  ,p_configuration_information29  => p_configuration_information29
  ,p_configuration_information30  => p_configuration_information30
  ,p_prefix_reporting_name        => p_prefix_reporting_name
  ,p_element_template             => l_element_template
  ,p_exclusion_rules              => l_exclusion_rules
  ,p_formulas                     => l_formulas
  ,p_balance_types                => l_balance_types
  ,p_defined_balances             => l_defined_balances
  ,p_element_types                => l_element_types
  ,p_sub_classi_rules             => l_sub_classi_rules
  ,p_balance_classis              => l_balance_classis
  ,p_input_values                 => l_input_values
  ,p_balance_feeds                => l_balance_feeds
  ,p_formula_rules                => l_formula_rules
  ,p_iterative_rules              => l_iterative_rules
  ,p_ele_type_usages              => l_ele_type_usages
  ,p_gu_bal_exclusions            => l_gu_bal_exclusions
  ,p_template_ff_usages           => l_template_ff_usages
  ,p_bal_attributes               => l_bal_attributes
  );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 52);
  end if;
  pay_element_template_util.plsql_to_db_template
  (p_effective_date               => p_effective_date
  ,p_element_template             => l_element_template
  ,p_exclusion_rules              => l_exclusion_rules
  ,p_formulas                     => l_formulas
  ,p_balance_types                => l_balance_types
  ,p_defined_balances             => l_defined_balances
  ,p_element_types                => l_element_types
  ,p_sub_classi_rules             => l_sub_classi_rules
  ,p_balance_classis              => l_balance_classis
  ,p_input_values                 => l_input_values
  ,p_balance_feeds                => l_balance_feeds
  ,p_formula_rules                => l_formula_rules
  ,p_iterative_rules              => l_iterative_rules
  ,p_ele_type_usages              => l_ele_type_usages
  ,p_gu_bal_exclusions            => l_gu_bal_exclusions
  ,p_bal_attributes               => l_bal_attributes
  ,p_template_id                  => l_template_id
  ,p_object_version_number        => l_ovn
  );
  --
  -- Call After Process User Hook
  --
  if g_debug then
     hr_utility.set_location(l_proc, 60);
  end if;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_template_id            := l_template_id;
  p_object_version_number  := l_ovn;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_user_structure;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_template_id            := null;
    p_object_version_number  := null;
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_user_structure;
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    p_template_id           := null;
    p_object_version_number := null;
    raise;
end create_user_structure;
-- ----------------------------------------------------------------------------
-- |---------------------------< generate_part1 >-----------------------------|
-- ----------------------------------------------------------------------------
procedure generate_part1
  (p_validate                      in     boolean default false
  ,p_effective_date                in     date
  ,p_hr_only                       in     boolean default false
  ,p_hr_to_payroll                 in     boolean default false
  ,p_template_id                   in     number
  ) is
  l_proc                varchar2(72) := g_package||'generate_part1';
  l_effective_date      date;
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint generate_part1;
  if g_debug then
     hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Check mandatory arguments.
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'p_effective_date',
     p_argument_value => p_effective_date);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'p_template_id',
     p_argument_value => p_template_id);
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  if g_debug then
     hr_utility.set_location(l_proc, 30);
  end if;
  --
  -- Validation in addition to Row Handlers
  --
  -- Process Logic
  --
  if g_debug then
     hr_utility.set_location(l_proc, 50);
  end if;
  pay_element_template_gen.generate_part1
  (p_effective_date               => l_effective_date
  ,p_hr_only                      => p_hr_only
  ,p_hr_to_payroll                => p_hr_to_payroll
  ,p_template_id                  => p_template_id
  );
  --
  -- Call After Process User Hook
  --
  if g_debug then
     hr_utility.set_location(l_proc, 60);
  end if;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 70);
    end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to generate_part1;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to generate_part1;
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    raise;
end generate_part1;
-- ----------------------------------------------------------------------------
-- |---------------------------< generate_part2 >-----------------------------|
-- ----------------------------------------------------------------------------
procedure generate_part2
  (p_validate                      in     boolean default false
  ,p_effective_date                in     date
  ,p_template_id                   in     number
  ) is
  l_proc                varchar2(72) := g_package||'generate_part2';
  l_effective_date      date;
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint generate_part2;
  if g_debug then
     hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Check mandatory arguments.
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'p_effective_date',
     p_argument_value => p_effective_date);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'p_template_id',
     p_argument_value => p_template_id);
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  if g_debug then
     hr_utility.set_location(l_proc, 30);
  end if;
  --
  -- Validation in addition to Row Handlers
  --
  -- Process Logic
  --
  if g_debug then
     hr_utility.set_location(l_proc, 50);
  end if;
  pay_element_template_gen.generate_part2
  (p_effective_date               => l_effective_date
  ,p_template_id                  => p_template_id
  );
  --
  -- Call After Process User Hook
  --
  if g_debug then
     hr_utility.set_location(l_proc, 60);
  end if;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 70);
    end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to generate_part2;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to generate_part2;
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    raise;
end generate_part2;
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_template >----------------------------|
-- ----------------------------------------------------------------------------
procedure delete_template
  (p_validate                      in     boolean default false
  ,p_template_id                   in     number
  ) is
  l_proc                varchar2(72) := g_package||'delete_template';
  l_effective_date      date;
  -----------------------------
  -- PL/SQL template tables. --
  -----------------------------
  l_element_template    pay_etm_shd.g_rec_type;
  l_core_objects        pay_element_template_util.t_core_objects;
  l_exclusion_rules     pay_element_template_util.t_exclusion_rules;
  l_formulas            pay_element_template_util.t_formulas;
  l_balance_types       pay_element_template_util.t_balance_types;
  l_defined_balances    pay_element_template_util.t_defined_balances;
  l_element_types       pay_element_template_util.t_element_types;
  l_sub_classi_rules    pay_element_template_util.t_sub_classi_rules;
  l_balance_classis     pay_element_template_util.t_balance_classis;
  l_input_values        pay_element_template_util.t_input_values;
  l_balance_feeds       pay_element_template_util.t_balance_feeds;
  l_formula_rules       pay_element_template_util.t_formula_rules;
  l_iterative_rules     pay_element_template_util.t_iterative_rules;
  l_ele_type_usages     pay_element_template_util.t_ele_type_usages;
  l_gu_bal_exclusions   pay_element_template_util.t_gu_bal_exclusions;
  l_template_ff_usages  pay_element_template_util.t_template_ff_usages;
  l_bal_attributes      pay_element_template_util.t_bal_attributes;
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint delete_template;
  if g_debug then
     hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Check mandatory arguments.
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'p_template_id',
     p_argument_value => p_template_id);
  --
  -- Truncate the time portion from all IN date parameters
  --
  --
  -- Call Before Process User Hook
  --
  if g_debug then
     hr_utility.set_location(l_proc, 30);
  end if;
  --
  -- Validation in addition to Row Handlers
  --
  -- Process Logic
  --
  if g_debug then
     hr_utility.set_location(l_proc, 50);
  end if;
  pay_element_template_util.create_plsql_template
  (p_lock                         => true
  ,p_template_id                  => p_template_id
  ,p_element_template             => l_element_template
  ,p_core_objects                 => l_core_objects
  ,p_exclusion_rules              => l_exclusion_rules
  ,p_formulas                     => l_formulas
  ,p_balance_types                => l_balance_types
  ,p_defined_balances             => l_defined_balances
  ,p_element_types                => l_element_types
  ,p_sub_classi_rules             => l_sub_classi_rules
  ,p_balance_classis              => l_balance_classis
  ,p_input_values                 => l_input_values
  ,p_balance_feeds                => l_balance_feeds
  ,p_formula_rules                => l_formula_rules
  ,p_iterative_rules              => l_iterative_rules
  ,p_ele_type_usages              => l_ele_type_usages
  ,p_gu_bal_exclusions            => l_gu_bal_exclusions
  ,p_template_ff_usages           => l_template_ff_usages
  ,p_bal_attributes               => l_bal_attributes
  );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 55);
  end if;
  pay_element_template_util.delete_template
  (p_template_id     => p_template_id
  ,p_formulas        => l_formulas
  ,p_delete_formulas => false
  );
  --
  -- Call After Process User Hook
  --
  if g_debug then
     hr_utility.set_location(l_proc, 60);
  end if;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 70);
    end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_template;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_template;
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    raise;
end delete_template;
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_user_structure >----------------------|
-- ----------------------------------------------------------------------------
procedure delete_user_structure
  (p_validate                      in     boolean default false
  ,p_drop_formula_packages         in     boolean
  ,p_template_id                   in     number
  ) is
  l_proc                  varchar2(72) := g_package||'delete_user_structure';
  l_effective_date        date;
  l_drop_formula_packages boolean;
  -----------------------------
  -- PL/SQL template tables. --
  -----------------------------
  l_element_template    pay_etm_shd.g_rec_type;
  l_core_objects        pay_element_template_util.t_core_objects;
  l_exclusion_rules     pay_element_template_util.t_exclusion_rules;
  l_formulas            pay_element_template_util.t_formulas;
  l_balance_types       pay_element_template_util.t_balance_types;
  l_defined_balances    pay_element_template_util.t_defined_balances;
  l_element_types       pay_element_template_util.t_element_types;
  l_sub_classi_rules    pay_element_template_util.t_sub_classi_rules;
  l_balance_classis     pay_element_template_util.t_balance_classis;
  l_input_values        pay_element_template_util.t_input_values;
  l_balance_feeds       pay_element_template_util.t_balance_feeds;
  l_formula_rules       pay_element_template_util.t_formula_rules;
  l_iterative_rules     pay_element_template_util.t_iterative_rules;
  l_ele_type_usages     pay_element_template_util.t_ele_type_usages;
  l_gu_bal_exclusions   pay_element_template_util.t_gu_bal_exclusions;
  l_template_ff_usages  pay_element_template_util.t_template_ff_usages;
  l_bal_attributes      pay_element_template_util.t_bal_attributes;
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint delete_template;
  if g_debug then
     hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Check mandatory arguments.
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'p_template_id',
     p_argument_value => p_template_id);
  --
  -- Truncate the time portion from all IN date parameters
  --
  --
  -- Call Before Process User Hook
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Validation in addition to Row Handlers
  --
  -- Process Logic
  --
  if g_debug then
     hr_utility.set_location(l_proc, 50);
  end if;
  pay_element_template_util.create_plsql_template
  (p_lock                         => true
  ,p_template_id                  => p_template_id
  ,p_element_template             => l_element_template
  ,p_core_objects                 => l_core_objects
  ,p_exclusion_rules              => l_exclusion_rules
  ,p_formulas                     => l_formulas
  ,p_balance_types                => l_balance_types
  ,p_defined_balances             => l_defined_balances
  ,p_element_types                => l_element_types
  ,p_sub_classi_rules             => l_sub_classi_rules
  ,p_balance_classis              => l_balance_classis
  ,p_input_values                 => l_input_values
  ,p_balance_feeds                => l_balance_feeds
  ,p_formula_rules                => l_formula_rules
  ,p_iterative_rules              => l_iterative_rules
  ,p_ele_type_usages              => l_ele_type_usages
  ,p_gu_bal_exclusions            => l_gu_bal_exclusions
  ,p_template_ff_usages           => l_template_ff_usages
  ,p_bal_attributes               => l_bal_attributes
  );
  --
  -- Zap the generated objects. Don't drop formula packages if
  -- p_validate is true.
  --
  if g_debug then
     hr_utility.set_location(l_proc, 51);
  end if;
  l_drop_formula_packages := not p_validate and p_drop_formula_packages;
  pay_element_template_gen.zap_core_objects
  (p_all_core_objects             => l_core_objects
  ,p_drop_formula_packages        => l_drop_formula_packages
  );
  --
  -- Delete the template.
  --
  if g_debug then
     hr_utility.set_location(l_proc, 52);
  end if;
  pay_element_template_util.delete_template
  (p_template_id     => p_template_id
  ,p_formulas        => l_formulas
  ,p_delete_formulas => true
  );
  --
  -- Call After Process User Hook
  --
  if g_debug then
    hr_utility.set_location(l_proc, 60);
  end if;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_template;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_template;
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    raise;
end delete_user_structure;
--
end pay_element_template_api;

/
