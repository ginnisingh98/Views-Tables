--------------------------------------------------------
--  DDL for Package Body PAY_BAL_ATTRIB_DEFINITION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BAL_ATTRIB_DEFINITION_API" as
/* $Header: pyatdapi.pkb 115.3 2003/05/28 18:45:53 rthirlby noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  PAY_BAL_ATTRIB_DEFINITION_API.';
--
-- ----------------------------------------------------------------------------
-- |-------------------< create_bal_attrib_definition >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_bal_attrib_definition
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_attribute_name                in     varchar2
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2 default null
  ,p_alterable                     in     varchar2 default null
  ,p_user_attribute_name           in     varchar2 default null
  ,p_attribute_id                     out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc           varchar2(72) := g_package||'create_bal_attrib_definition';
  l_effective_date date;
  --
  -- Declare OUT variables
  --
  l_attribute_id     pay_bal_attribute_definitions.attribute_id%type;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_bal_attrib_definition;
  --
  -- Truncate the time portion from all IN date parameters
  --
    l_effective_date := trunc(p_effective_date);
    --
    hr_utility.set_location(l_proc, 20);
  --
  -- Call Before Process User Hook
  --
  begin
    PAY_BAL_ATTRIB_DEFINITION_BK1.create_bal_attrib_definition_b
      (p_effective_date                => l_effective_date
      ,p_attribute_name                => p_attribute_name
      ,p_business_group_id             => p_business_group_id
      ,p_legislation_code              => p_legislation_code
      ,p_alterable                     => p_alterable
      ,p_user_attribute_name           => p_user_attribute_name
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_bal_attrib_definition'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  hr_utility.set_location(l_proc, 25);
  --
  -- Validation in addition to Row Handlers
  --
  -- Process Logic
  --
    pay_bad_ins.ins
       (p_effective_date      => l_effective_date
       ,p_attribute_name      => p_attribute_name
       ,p_alterable           => p_alterable
       ,p_legislation_code    => p_legislation_code
       ,p_business_group_id   => p_business_group_id
       ,p_user_attribute_name => p_user_attribute_name
       ,p_attribute_id        => l_attribute_id
       );
    --
    hr_utility.set_location(l_proc, 30);
  --
  -- Call After Process User Hook
  --
  begin
    PAY_BAL_ATTRIB_DEFINITION_BK1.create_bal_attrib_definition_a
      (p_effective_date                => l_effective_date
      ,p_attribute_name                => p_attribute_name
      ,p_business_group_id             => p_business_group_id
      ,p_legislation_code              => p_legislation_code
      ,p_alterable                     => p_alterable
      ,p_user_attribute_name           => p_user_attribute_name
      ,p_attribute_id                  => l_attribute_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_bal_attrib_definition'
        ,p_hook_type   => 'AP'
        );
  end;
  --
    hr_utility.set_location(l_proc, 40);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_attribute_id           := l_attribute_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_bal_attrib_definition;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_attribute_id             := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_bal_attrib_definition;
    p_attribute_id             := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_bal_attrib_definition;
--
-- ----------------------------------------------------------------------------
-- |-------------------< delete_bal_attrib_definition >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_bal_attrib_definition
  (p_validate                      in     boolean  default false
  ,p_attribute_id                  in     number
  ,p_business_group_id             in     number   default null
  ,p_legislation_code              in     varchar2 default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc           varchar2(72) := g_package||'delete_bal_attrib_definition';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_bal_attrib_definition;
  --
    hr_utility.set_location(l_proc, 20);
  --
  -- Call Before Process User Hook
  --
  begin
    PAY_BAL_ATTRIB_DEFINITION_BK2.delete_bal_attrib_definition_b
      (p_attribute_id                  => p_attribute_id
      ,p_business_group_id             => p_business_group_id
      ,p_legislation_code              => p_legislation_code
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_bal_attrib_definition'
        ,p_hook_type   => 'BP'
        );
  end;
  hr_utility.set_location(l_proc, 25);
  --
  -- Validation in addition to Row Handlers
  --
  -- Process Logic
  --
    pay_bad_del.del
       (p_attribute_id    => p_attribute_id
       );
    --
    hr_utility.set_location(l_proc, 30);
  --
  -- Call After Process User Hook
  --
  begin
    PAY_BAL_ATTRIB_DEFINITION_BK2.delete_bal_attrib_definition_a
      (p_attribute_id                  => p_attribute_id
      ,p_business_group_id             => p_business_group_id
      ,p_legislation_code              => p_legislation_code
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_bal_attrib_definition'
        ,p_hook_type   => 'AP'
        );
  end;
  --
    hr_utility.set_location(l_proc, 40);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_bal_attrib_definition;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_bal_attrib_definition;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_bal_attrib_definition;
--
end PAY_BAL_ATTRIB_DEFINITION_API;

/
