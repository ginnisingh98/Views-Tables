--------------------------------------------------------
--  DDL for Package Body PAY_BALANCE_TYPES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BALANCE_TYPES_API" as
/* $Header: pybltapi.pkb 120.0 2005/05/29 03:20:37 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  PAY_BALANCE_TYPES_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< CREATE_BAL_TYPE >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_bal_type
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_language_code                 in     varchar2 Default hr_api.userenv_lang
  ,p_balance_name                  in     varchar2
  ,p_balance_uom                   in     varchar2
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2 default null
  ,p_currency_code                 in     varchar2 default null
  ,p_assignment_remuneration_flag  in     varchar2 default 'N'
  ,p_comments                      in     varchar2 default null
  ,p_legislation_subgroup          in     varchar2 default null
  ,p_reporting_name                in     varchar2 default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in	  varchar2 default null
  ,p_attribute2                    in	  varchar2 default null
  ,p_attribute3                    in	  varchar2 default null
  ,p_attribute4                    in	  varchar2 default null
  ,p_attribute5                    in	  varchar2 default null
  ,p_attribute6                    in	  varchar2 default null
  ,p_attribute7                    in	  varchar2 default null
  ,p_attribute8                    in	  varchar2 default null
  ,p_attribute9                    in	  varchar2 default null
  ,p_attribute10                   in	  varchar2 default null
  ,p_attribute11                   in	  varchar2 default null
  ,p_attribute12                   in	  varchar2 default null
  ,p_attribute13                   in	  varchar2 default null
  ,p_attribute14                   in	  varchar2 default null
  ,p_attribute15                   in	  varchar2 default null
  ,p_attribute16                   in	  varchar2 default null
  ,p_attribute17                   in	  varchar2 default null
  ,p_attribute18                   in	  varchar2 default null
  ,p_attribute19                   in	  varchar2 default null
  ,p_attribute20                   in	  varchar2 default null
  ,p_jurisdiction_level            in     number   default null
  ,p_tax_type                      in     varchar2 default null
  ,p_balance_category_id           in     number   default null
  ,p_base_balance_type_id          in     number   default null
  ,p_input_value_id                in     number   default null
  ,p_balance_type_id                  out nocopy   number
  ,p_object_version_number            out nocopy   number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_in_out_parameter          number;
  l_effective_date            date;
  l_balance_type_id	      pay_balance_types.balance_type_id%type;
  l_object_version_number     pay_balance_types.object_version_number%type;
  l_default_currency_code     pay_balance_types.currency_code%type;
  l_proc                      varchar2(72) := g_package||'create_bal_type';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_BAL_TYPE;
  --
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Validation in addition to Row Handlers
  --
  -- assign default value to currency

  hr_utility.set_location('Entering:'|| l_proc, 20);

   if (p_balance_uom = 'M' and p_currency_code is null) then
      -- Get the default currency based on the legislation
      --
      BEGIN
         l_default_currency_code :=
	                  hr_general.default_currency_code(p_legislation_code);

      EXCEPTION
         WHEN others THEN
            IF sqlcode = -20001 THEN
            -- No default currency available from the legislation so
            -- get the default currency based on the business group
	    --
            l_default_currency_code :=
	            hr_general.default_currency_code(p_business_group_id);
	    END IF;
      END;
  else
      l_default_currency_code := p_currency_code;
  end if;
  --
  hr_utility.set_location('Entering:'|| l_proc, 30);
  --
  -- Call Before Process User Hook
  --
  begin
    PAY_BALANCE_TYPES_BK1.create_bal_type_b
      (p_effective_date			=>   l_effective_date
      ,p_language_code			=>   p_language_code
      ,p_balance_name			=>   p_balance_name
      ,p_balance_uom			=>   p_balance_uom
      ,p_business_group_id		=>   p_business_group_id
      ,p_legislation_code		=>   p_legislation_code
      ,p_currency_code			=>   l_default_currency_code
      ,p_assignment_remuneration_flag   =>   p_assignment_remuneration_flag
      ,p_comments			=>   p_comments
      ,p_legislation_subgroup		=>   p_legislation_subgroup
      ,p_reporting_name			=>   p_reporting_name
      ,p_attribute_category		=>   p_attribute_category
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
      ,p_jurisdiction_level             =>   p_jurisdiction_level
      ,p_tax_type                       =>   p_tax_type
      ,p_balance_category_id            =>   p_balance_category_id
      ,p_base_balance_type_id           =>   p_base_balance_type_id
      ,p_input_value_id                 =>   p_input_value_id
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_BAL_TYPE'
        ,p_hook_type   => 'BP'
        );
  end;
  --
    hr_utility.set_location('Entering:'|| l_proc, 40);
  --
  -- Process Logic
  --
     pay_blt_ins.ins
      (p_effective_date                 =>   l_effective_date
      ,p_assignment_remuneration_flag   =>   p_assignment_remuneration_flag
      ,p_balance_uom                    =>   p_balance_uom
      ,p_business_group_id              =>   p_business_group_id
      ,p_legislation_code               =>   p_legislation_code
      ,p_currency_code                  =>   l_default_currency_code
      ,p_balance_name                   =>   p_balance_name
      ,p_comments                       =>   p_comments
      ,p_legislation_subgroup           =>   p_legislation_subgroup
      ,p_reporting_name                 =>   p_reporting_name
      ,p_attribute_category		=>   p_attribute_category
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
      ,p_jurisdiction_level             =>   p_jurisdiction_level
      ,p_tax_type                       =>   p_tax_type
      ,p_balance_category_id            =>   p_balance_category_id
      ,p_base_balance_type_id           =>   p_base_balance_type_id
      ,p_input_value_id                 =>   p_input_value_id
      ,p_balance_type_id                =>   l_balance_type_id
      ,p_object_version_number          =>   l_object_version_number
   );
  --
    hr_utility.set_location('Entering:'|| l_proc, 50);
  --
  -- Create default entries in pay_balance_types_tl table
  --
  pay_btt_ins.ins_tl
  (p_language_code                =>  p_language_code
  ,p_balance_type_id              =>  l_balance_type_id
  ,p_balance_name                 =>  p_balance_name
  ,p_reporting_name               =>  p_reporting_name
  );
  --
  -- Call After Process User Hook
  --
  --
    hr_utility.set_location('Entering:'|| l_proc, 60);
  --
  begin
    PAY_BALANCE_TYPES_BK1.create_bal_type_a
      (p_effective_date                 =>   l_effective_date
      ,p_language_code			=>   p_language_code
      ,p_balance_name			=>   p_balance_name
      ,p_balance_uom			=>   p_balance_uom
      ,p_business_group_id		=>   p_business_group_id
      ,p_legislation_code		=>   p_legislation_code
      ,p_currency_code			=>   l_default_currency_code
      ,p_assignment_remuneration_flag   =>   p_assignment_remuneration_flag
      ,p_comments			=>   p_comments
      ,p_legislation_subgroup		=>   p_legislation_subgroup
      ,p_reporting_name			=>   p_reporting_name
      ,p_attribute_category		=>   p_attribute_category
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
      ,p_jurisdiction_level             =>   p_jurisdiction_level
      ,p_tax_type                       =>   p_tax_type
      ,p_balance_category_id            =>   p_balance_category_id
      ,p_base_balance_type_id           =>   p_base_balance_type_id
      ,p_input_value_id                 =>   p_input_value_id
      ,p_balance_type_id                =>   l_balance_type_id
      ,p_object_version_number          =>   l_object_version_number
   );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_BAL_TYPE'
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
  -- Set all IN OUT and OUT parameters with out values
  --
  p_balance_type_id        := l_balance_type_id;
  p_object_version_number  := l_object_version_number;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_BAL_TYPE;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_balance_type_id        := null;
    p_object_version_number  := null;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_BAL_TYPE;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_balance_type_id        := null;
    p_object_version_number  := null;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end CREATE_BAL_TYPE;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< UPDATE_BAL_TYPE >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_bal_type
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_language_code                 in     varchar2 Default hr_api.userenv_lang
  ,p_balance_type_id               in     number
  ,p_object_version_number         in out nocopy   number
  ,p_balance_name                  in     varchar2 default hr_api.g_varchar2
  ,p_balance_uom                   in     varchar2 default hr_api.g_varchar2
  ,p_currency_code                 in     varchar2 default hr_api.g_varchar2
  ,p_assignment_remuneration_flag  in     varchar2 default hr_api.g_varchar2
  ,p_comments                      in     varchar2 default hr_api.g_varchar2
  ,p_reporting_name                in     varchar2 default hr_api.g_varchar2
  ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                    in	  varchar2 default hr_api.g_varchar2
  ,p_attribute2                    in	  varchar2 default hr_api.g_varchar2
  ,p_attribute3                    in	  varchar2 default hr_api.g_varchar2
  ,p_attribute4                    in	  varchar2 default hr_api.g_varchar2
  ,p_attribute5                    in	  varchar2 default hr_api.g_varchar2
  ,p_attribute6                    in	  varchar2 default hr_api.g_varchar2
  ,p_attribute7                    in	  varchar2 default hr_api.g_varchar2
  ,p_attribute8                    in	  varchar2 default hr_api.g_varchar2
  ,p_attribute9                    in	  varchar2 default hr_api.g_varchar2
  ,p_attribute10                   in	  varchar2 default hr_api.g_varchar2
  ,p_attribute11                   in	  varchar2 default hr_api.g_varchar2
  ,p_attribute12                   in	  varchar2 default hr_api.g_varchar2
  ,p_attribute13                   in	  varchar2 default hr_api.g_varchar2
  ,p_attribute14                   in	  varchar2 default hr_api.g_varchar2
  ,p_attribute15                   in	  varchar2 default hr_api.g_varchar2
  ,p_attribute16                   in	  varchar2 default hr_api.g_varchar2
  ,p_attribute17                   in	  varchar2 default hr_api.g_varchar2
  ,p_attribute18                   in	  varchar2 default hr_api.g_varchar2
  ,p_attribute19                   in	  varchar2 default hr_api.g_varchar2
  ,p_attribute20                   in	  varchar2 default hr_api.g_varchar2
  ,p_balance_category_id           in     number   default hr_api.g_number
  ,p_base_balance_type_id          in     number   default hr_api.g_number
  ,p_input_value_id                in     number   default hr_api.g_number
  ,p_balance_name_warning             out nocopy   number
  ) is
  --
   -- Declare cursors and local variables
  --
  cursor csr_derived_values
  is
  select business_group_id,legislation_code,legislation_subgroup
  from pay_balance_types
  where balance_type_id = p_balance_type_id;


  l_business_group_id       pay_balance_types.business_group_id%type;
  l_legislation_code        pay_balance_types.legislation_code%type;
  l_legislation_subgroup    pay_balance_types.legislation_subgroup%type;
  l_object_version_number   pay_balance_types.object_version_number%type;
  l_default_currency_code   pay_balance_types.currency_code%type;
  l_balance_name_warning    number;
  l_effective_date          date;
  l_proc                    varchar2(72) := g_package||'UPDATE_BAL_TYPE';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_BAL_TYPE;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number := p_object_version_number;

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  --
    hr_utility.set_location('Entering:'|| l_proc, 20);
  --
  --
  -- Call Before Process User Hook
  --
  begin
    PAY_BALANCE_TYPES_BK2.update_bal_type_b
      (p_effective_date                 =>   l_effective_date
      ,p_language_code                  =>   p_language_code
      ,p_balance_type_id                =>   p_balance_type_id
      ,p_object_version_number          =>   l_object_version_number
      ,p_balance_name                   =>   p_balance_name
      ,p_balance_uom                    =>   p_balance_uom
      ,p_currency_code                  =>   p_currency_code
      ,p_assignment_remuneration_flag   =>   p_assignment_remuneration_flag
      ,p_comments                       =>   p_comments
      ,p_reporting_name                 =>   p_reporting_name
      ,p_attribute_category		=>   p_attribute_category
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
      ,p_balance_category_id            =>   p_balance_category_id
      ,p_base_balance_type_id           =>   p_base_balance_type_id
      ,p_input_value_id                 =>   p_input_value_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_BAL_TYPE'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
    hr_utility.set_location('Entering:'|| l_proc, 30);
  --
  --
  open csr_derived_values;
  fetch csr_derived_values into l_business_group_id,l_legislation_code,
                            l_legislation_subgroup;
  close csr_derived_values;
  --
  --
    hr_utility.set_location('Entering:'|| l_proc, 40);
  --
  -- assign default value to currency
  if (p_balance_uom = 'M' and p_currency_code is null) then
      -- Get the default currency based on the legislation
      --
      BEGIN
         l_default_currency_code :=
	                  hr_general.default_currency_code(l_legislation_code);
      EXCEPTION
         WHEN others THEN
            IF sqlcode = -20001 THEN
            -- No default currency available from the legislation so
            -- get the default currency based on the business group
	    --
            l_default_currency_code :=
	            hr_general.default_currency_code(l_business_group_id);
	    END IF;
      END;
  else
      l_default_currency_code := p_currency_code;
  end if;
  --
    hr_utility.set_location('Entering:'|| l_proc, 50);
  --
  --
  -- Process Logic
  --
  pay_blt_upd.upd
     ( p_effective_date                 =>   l_effective_date
      ,p_balance_type_id                =>   p_balance_type_id
      ,p_object_version_number          =>   l_object_version_number
      ,p_assignment_remuneration_flag   =>   p_assignment_remuneration_flag
      ,p_balance_uom                    =>   p_balance_uom
      ,p_business_group_id              =>   l_business_group_id
      ,p_legislation_code               =>   l_legislation_code
      ,p_currency_code                  =>   l_default_currency_code
      ,p_balance_name                   =>   p_balance_name
      ,p_comments                       =>   p_comments
      ,p_legislation_subgroup           =>   l_legislation_subgroup
      ,p_reporting_name                 =>   p_reporting_name
      ,p_attribute_category		=>   p_attribute_category
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
      ,p_balance_category_id            =>   p_balance_category_id
      ,p_base_balance_type_id           =>   p_base_balance_type_id
      ,p_input_value_id                 =>   p_input_value_id
      ,p_balance_name_warning           =>   l_balance_name_warning
   );
  --
    hr_utility.set_location('Entering:'|| l_proc, 60);
  --
  --
  -- Update the translation table values
  --
   pay_btt_upd.upd_tl
     (p_language_code                 => p_language_code
     ,p_balance_type_id               => p_balance_type_id
     ,p_balance_name                  => p_balance_name
     ,p_reporting_name                => p_reporting_name
     );

  --
  --
    hr_utility.set_location('Entering:'|| l_proc, 70);
  --
  --
  -- Call After Process User Hook
  --
  begin
    PAY_BALANCE_TYPES_BK2.update_bal_type_a
      (p_effective_date                 =>   l_effective_date
      ,p_language_code			=>   p_language_code
      ,p_balance_type_id                =>   p_balance_type_id
      ,p_object_version_number          =>   l_object_version_number
      ,p_balance_name			=>   p_balance_name
      ,p_balance_uom			=>   p_balance_uom
      ,p_currency_code                  =>   l_default_currency_code
      ,p_assignment_remuneration_flag   =>   p_assignment_remuneration_flag
      ,p_comments			=>   p_comments
      ,p_reporting_name			=>   p_reporting_name
      ,p_attribute_category		=>   p_attribute_category
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
      ,p_balance_category_id            =>   p_balance_category_id
      ,p_base_balance_type_id           =>   p_base_balance_type_id
      ,p_input_value_id                 =>   p_input_value_id
      ,p_balance_name_warning           =>   l_balance_name_warning
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_BAL_TYPE'
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
  -- Set all IN OUT and OUT parameters with out values
  --
  p_object_version_number  := l_object_version_number;
  p_balance_name_warning   := l_balance_name_warning;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 80);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_BAL_TYPE;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    p_balance_name_warning   := l_balance_name_warning;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_BAL_TYPE;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --

    p_object_version_number  := null;
    p_balance_name_warning   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 100);
    raise;
end UPDATE_BAL_TYPE;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< DELETE_BAL_TYPE >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_BAL_TYPE
  (p_validate                      in     boolean  default false
  ,p_balance_type_id               in     number
  ,p_object_version_number         in out nocopy   number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number   number;
  l_proc                    varchar2(72) := g_package||'DELETE_BAL_TYPE';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_BAL_TYPE;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number := p_object_version_number;

  --
    hr_utility.set_location('Entering:'|| l_proc, 20);
  --
  --
  -- Call Before Process User Hook
  --
  begin
    PAY_BALANCE_TYPES_BK3.delete_bal_type_b
      (p_balance_type_id            => p_balance_type_id
      ,p_object_version_number      => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_BAL_TYPE'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
    hr_utility.set_location('Entering:'|| l_proc, 30);
  --
  --
  -- Process Logic
  --
  pay_blt_del.del
  (p_balance_type_id                      => p_balance_type_id
  ,p_object_version_number                => l_object_version_number
  );
  --
  -- delete from translation table
  --
  --
    hr_utility.set_location('Entering:'|| l_proc, 40);
  --
  pay_btt_del.del_tl
  (p_balance_type_id                      => p_balance_type_id
  ,p_associated_column1                   => null
  );
  --
    --
    hr_utility.set_location('Entering:'|| l_proc, 50);
  --
  --
  -- Call After Process User Hook
  --
  begin
    PAY_BALANCE_TYPES_BK3.delete_bal_type_a
      (p_balance_type_id            => p_balance_type_id
      ,p_object_version_number      => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_BAL_TYPE'
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
  -- Set all IN OUT and OUT parameters with out values
  --
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_BAL_TYPE;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to DELETE_BAL_TYPE;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --

    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end DELETE_BAL_TYPE;
--
end PAY_BALANCE_TYPES_API;

/
