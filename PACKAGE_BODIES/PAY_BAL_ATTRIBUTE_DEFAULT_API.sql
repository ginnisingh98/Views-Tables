--------------------------------------------------------
--  DDL for Package Body PAY_BAL_ATTRIBUTE_DEFAULT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BAL_ATTRIBUTE_DEFAULT_API" as
/* $Header: pypbdapi.pkb 115.1 2002/12/11 15:11:55 exjones noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  PAY_BAL_ATTRIBUTE_DEFAULT_API.';
--
-- ----------------------------------------------------------------------------
-- |----------------< create_bal_attribute_default >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_bal_attribute_default
  (p_validate                      in     boolean  default false
  ,p_balance_category_id           in     number
  ,p_balance_dimension_id          in     number
  ,p_attribute_id                  in     number
  ,p_business_group_id             in     number   default null
  ,p_legislation_code              in     varchar2 default null
  ,p_bal_attribute_default_id         out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc           varchar2(72) := g_package||'create_bal_attribute_default';
  --
  -- Declare OUT variables
  --
  l_bal_attribute_default_id pay_bal_attribute_defaults.bal_attribute_default_id%type;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_bal_attribute_default;
  --
  -- Truncate the time portion from all IN date parameters
  --
    hr_utility.set_location(l_proc, 20);
  --
  -- Call Before Process User Hook
  --
  begin
    PAY_BAL_ATTRIBUTE_DEFAULT_BK1.create_bal_attribute_default_b
      (p_balance_category_id           => p_balance_category_id
      ,p_balance_dimension_id          => p_balance_dimension_id
      ,p_attribute_id                  => p_attribute_id
      ,p_business_group_id             => p_business_group_id
      ,p_legislation_code              => p_legislation_code
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_bal_attribute_default'
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
    pay_pbd_ins.ins
       (p_attribute_id             => p_attribute_id
       ,p_balance_dimension_id     => p_balance_dimension_id
       ,p_balance_category_id      => p_balance_category_id
       ,p_legislation_code         => p_legislation_code
       ,p_business_group_id        => p_business_group_id
       ,p_bal_attribute_default_id => l_bal_attribute_default_id
       );
    --
    hr_utility.set_location(l_proc, 30);
  --
  -- Call After Process User Hook
  --
  begin
    PAY_BAL_ATTRIBUTE_DEFAULT_BK1.create_bal_attribute_default_a
      (p_balance_category_id      => p_balance_category_id
      ,p_balance_dimension_id     => p_balance_dimension_id
      ,p_attribute_id             => p_attribute_id
      ,p_business_group_id        => p_business_group_id
      ,p_legislation_code         => p_legislation_code
      ,p_bal_attribute_default_id => l_bal_attribute_default_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_bal_attribute_default'
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
  p_bal_attribute_default_id     := l_bal_attribute_default_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_bal_attribute_default;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_bal_attribute_default_id := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_bal_attribute_default;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_bal_attribute_default;
--
-- ----------------------------------------------------------------------------
-- |----------------< delete_bal_attribute_default >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_bal_attribute_default
  (p_validate                      in     boolean  default false
  ,p_bal_attribute_default_id      in     number
  ,p_business_group_id             in     number   default null
  ,p_legislation_code              in     varchar2 default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc           varchar2(72) := g_package||'create_bal_attribute_default';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_bal_attribute_default;
  --
    hr_utility.set_location(l_proc, 20);
  --
  -- Call Before Process User Hook
  --
  begin
    PAY_BAL_ATTRIBUTE_DEFAULT_BK2.delete_bal_attribute_default_b
      (p_bal_attribute_default_id      => p_bal_attribute_default_id
      ,p_business_group_id             => p_business_group_id
      ,p_legislation_code              => p_legislation_code
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_bal_attribute_default'
        ,p_hook_type   => 'BP'
        );
  end;
  hr_utility.set_location(l_proc, 25);
  --
  -- Validation in addition to Row Handlers
  --
  -- Process Logic
  --
    pay_pbd_del.del
       (p_bal_attribute_default_id    => p_bal_attribute_default_id
       );
    --
    hr_utility.set_location(l_proc, 30);
  --
  -- Call After Process User Hook
  --
  begin
    PAY_BAL_ATTRIBUTE_DEFAULT_BK2.delete_bal_attribute_default_a
      (p_bal_attribute_default_id      => p_bal_attribute_default_id
      ,p_business_group_id             => p_business_group_id
      ,p_legislation_code              => p_legislation_code
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_bal_attribute_default'
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
    rollback to delete_bal_attribute_default;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_bal_attribute_default;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_bal_attribute_default;
--
end PAY_BAL_ATTRIBUTE_DEFAULT_API;

/
