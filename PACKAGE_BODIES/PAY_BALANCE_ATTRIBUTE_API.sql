--------------------------------------------------------
--  DDL for Package Body PAY_BALANCE_ATTRIBUTE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BALANCE_ATTRIBUTE_API" as
/* $Header: pypbaapi.pkb 115.1 2002/12/11 15:11:03 exjones noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  PAY_BALANCE_ATTRIBUTE_API.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_balance_attribute >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_balance_attribute
  (p_validate                      in            boolean  default false
  ,p_attribute_id                  in            number
  ,p_defined_balance_id            in            number
  ,p_business_group_id             in            number
  ,p_legislation_code              in            varchar2 default null
  ,p_balance_attribute_id             out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc           varchar2(72) := g_package||'create_balance_attribute';
  --
  -- Declare OUT variables
  --
  l_balance_attribute_id     pay_balance_attributes.balance_attribute_id%type;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_balance_attribute;
  --
  -- Truncate the time portion from all IN date parameters
  --
    hr_utility.set_location(l_proc, 20);
  --
  -- Call Before Process User Hook
  --
  begin
    PAY_BALANCE_ATTRIBUTE_BK1.create_balance_attribute_b
      (p_attribute_id                  => p_attribute_id
      ,p_defined_balance_id            => p_defined_balance_id
      ,p_business_group_id             => p_business_group_id
      ,p_legislation_code              => p_legislation_code
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_balance_attribute'
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
    pay_pba_ins.ins
       (p_attribute_id         => p_attribute_id
       ,p_defined_balance_id   => p_defined_balance_id
       ,p_legislation_code     => p_legislation_code
       ,p_business_group_id    => p_business_group_id
       ,p_balance_attribute_id => l_balance_attribute_id
       );
    --
    hr_utility.set_location(l_proc, 30);
  --
  -- Call After Process User Hook
  --
  begin
    PAY_BALANCE_ATTRIBUTE_BK1.create_balance_attribute_a
      (p_attribute_id                  => p_attribute_id
      ,p_defined_balance_id            => p_defined_balance_id
      ,p_business_group_id             => p_business_group_id
      ,p_legislation_code              => p_legislation_code
      ,p_balance_attribute_id          => l_balance_attribute_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_balance_attribute'
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
  p_balance_attribute_id           := l_balance_attribute_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_balance_attribute;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_balance_attribute_id             := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_balance_attribute;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_balance_attribute;
--
-- ----------------------------------------------------------------------------
-- |----------------< delete_balance_attribute >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_balance_attribute
  (p_validate                      in     boolean  default false
  ,p_balance_attribute_id          in     number
  ,p_business_group_id             in     number   default null
  ,p_legislation_code              in     varchar2 default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc           varchar2(72) := g_package||'delete_balance_attribute';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_balance_attribute;
  --
    hr_utility.set_location(l_proc, 20);
  --
  -- Call Before Process User Hook
  --
  begin
    PAY_BALANCE_ATTRIBUTE_BK2.delete_balance_attribute_b
      (p_balance_attribute_id          => p_balance_attribute_id
      ,p_business_group_id             => p_business_group_id
      ,p_legislation_code              => p_legislation_code
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_balance_attribute'
        ,p_hook_type   => 'BP'
        );
  end;
  hr_utility.set_location(l_proc, 25);
  --
  -- Validation in addition to Row Handlers
  --
  -- Process Logic
  --
    pay_pba_del.del
       (p_balance_attribute_id    => p_balance_attribute_id
       );
    --
    hr_utility.set_location(l_proc, 30);
  --
  -- Call After Process User Hook
  --
  begin
    PAY_BALANCE_ATTRIBUTE_BK2.delete_balance_attribute_a
      (p_balance_attribute_id          => p_balance_attribute_id
      ,p_business_group_id             => p_business_group_id
      ,p_legislation_code              => p_legislation_code
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_balance_attribute'
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
    rollback to delete_balance_attribute;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_balance_attribute;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_balance_attribute;
--
end PAY_BALANCE_ATTRIBUTE_API;

/
