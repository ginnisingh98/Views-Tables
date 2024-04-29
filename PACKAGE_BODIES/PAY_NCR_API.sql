--------------------------------------------------------
--  DDL for Package Body PAY_NCR_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NCR_API" as
/* $Header: pyncrapi.pkb 120.0 2005/05/29 06:51:38 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := ' pay_ncr_api. ';
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_pay_net_calc_rule >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_pay_net_calc_rule
  (p_validate                      in            boolean  default false
  ,p_business_group_id             in            number
  ,p_accrual_plan_id               in            number
  ,p_input_value_id                in            number
  ,p_add_or_subtract               in            varchar2
  ,p_date_input_value_id           in            number   default null
  ,p_net_calculation_rule_id          out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                    varchar2(72) := g_package||'create_pay_net_calc_rule';
  l_object_version_number   number;
  l_net_calculation_rule_id number;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_pay_net_calc_rule;
  hr_utility.set_location(l_proc, 20);

  --
  -- Call Before Process User Hook
  --
  begin
    pay_net_calc_rule_bk1.create_pay_net_calc_rule_b
      (p_business_group_id   => p_business_group_id
      ,p_accrual_plan_id     => p_accrual_plan_id
      ,p_input_value_id      => p_input_value_id
      ,p_add_or_subtract     => p_add_or_subtract
      ,p_date_input_value_id => p_date_input_value_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_pay_net_calc_rule'
        ,p_hook_type   => 'BP'
        );
  end;
  hr_utility.set_location(l_proc, 30);
  --
  -- Validation in addition to Row Handlers
  --



  hr_utility.set_location(l_proc, 40);
  --
  -- Process Logic
  --

  pay_ncr_ins.ins (
       p_net_calculation_rule_id => l_net_calculation_rule_id,
       p_accrual_plan_id         => p_accrual_plan_id,
       p_business_group_id       => p_business_group_id,
       p_input_value_id          => p_input_value_id,
       p_add_or_subtract         => p_add_or_subtract,
       p_date_input_value_id     => p_date_input_value_id,
       p_object_version_number   => l_object_version_number
       );


  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    pay_net_calc_rule_bk1.create_pay_net_calc_rule_a
      (p_business_group_id       => p_business_group_id
      ,p_accrual_plan_id         => p_accrual_plan_id
      ,p_input_value_id          => p_input_value_id
      ,p_add_or_subtract         => p_add_or_subtract
      ,p_date_input_value_id     => p_date_input_value_id
      ,p_net_calculation_rule_id => l_net_calculation_rule_id
      ,p_object_version_number   => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_pay_net_calc_rule'
        ,p_hook_type   => 'AP'
        );
  end;
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_net_calculation_rule_id := l_net_calculation_rule_id;
  p_object_version_number   := l_object_version_number;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_pay_net_calc_rule;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_net_calculation_rule_id := null;
    p_object_version_number   := null;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_pay_net_calc_rule;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_pay_net_calc_rule;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_pay_net_calc_rule >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_pay_net_calc_rule
  (p_validate                      in     boolean  default false
  ,p_net_calculation_rule_id       in     number
  ,p_accrual_plan_id               in     number   default hr_api.g_number
  ,p_input_value_id                in     number   default hr_api.g_number
  ,p_add_or_subtract               in     varchar2 default hr_api.g_varchar2
  ,p_date_input_value_id           in     number   default hr_api.g_number
  ,p_object_version_number         in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                    varchar2(72) := g_package||'update_pay_net_calc_rule';
  l_object_version_number   number;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_pay_net_calc_rule;
  hr_utility.set_location(l_proc, 20);

  --
  -- Call Before Process User Hook
  --
  begin
    pay_net_calc_rule_bk2.update_pay_net_calc_rule_b
      (p_net_calculation_rule_id => p_net_calculation_rule_id
      ,p_accrual_plan_id         => p_accrual_plan_id
      ,p_input_value_id          => p_input_value_id
      ,p_add_or_subtract         => p_add_or_subtract
      ,p_date_input_value_id     => p_date_input_value_id
      ,p_object_version_number   => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_pay_net_calc_rule'
        ,p_hook_type   => 'BP'
        );
  end;
  hr_utility.set_location(l_proc, 30);
  --
  -- Validation in addition to Row Handlers
  --



  hr_utility.set_location(l_proc, 40);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;

  pay_ncr_upd.upd (
       p_net_calculation_rule_id => p_net_calculation_rule_id,
       p_accrual_plan_id         => p_accrual_plan_id,
       p_input_value_id          => p_input_value_id,
       p_add_or_subtract         => p_add_or_subtract,
       p_date_input_value_id     => p_date_input_value_id,
       p_object_version_number   => l_object_version_number
       );


  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    pay_net_calc_rule_bk2.update_pay_net_calc_rule_a
      (p_net_calculation_rule_id => p_net_calculation_rule_id
      ,p_accrual_plan_id         => p_accrual_plan_id
      ,p_input_value_id          => p_input_value_id
      ,p_add_or_subtract         => p_add_or_subtract
      ,p_date_input_value_id     => p_date_input_value_id
      ,p_object_version_number   => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_pay_net_calc_rule'
        ,p_hook_type   => 'AP'
        );
  end;
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --

  p_object_version_number   := l_object_version_number;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_pay_net_calc_rule;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --

    p_object_version_number   := null;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_pay_net_calc_rule;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_pay_net_calc_rule;
--

-- ----------------------------------------------------------------------------
-- |-----------------------< delete_pay_net_calc_rule >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pay_net_calc_rule
  (p_validate                      in     boolean  default false
  ,p_net_calculation_rule_id       in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                    varchar2(72) := g_package||'delete_pay_net_calc_rule';

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_pay_net_calc_rule;
  hr_utility.set_location(l_proc, 20);

  --
  -- Call Before Process User Hook
  --
  begin
    pay_net_calc_rule_bk3.delete_pay_net_calc_rule_b
      (p_net_calculation_rule_id => p_net_calculation_rule_id
      ,p_object_version_number   => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_pay_net_calc_rule'
        ,p_hook_type   => 'BP'
        );
  end;
  hr_utility.set_location(l_proc, 30);
  --
  -- Validation in addition to Row Handlers
  --



  hr_utility.set_location(l_proc, 40);
  --
  -- Process Logic
  --

  pay_ncr_del.del (
       p_net_calculation_rule_id => p_net_calculation_rule_id,
       p_object_version_number   => p_object_version_number
       );


  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    pay_net_calc_rule_bk3.delete_pay_net_calc_rule_a
      (p_net_calculation_rule_id => p_net_calculation_rule_id
      ,p_object_version_number   => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_pay_net_calc_rule'
        ,p_hook_type   => 'AP'
        );
  end;
  hr_utility.set_location(l_proc, 60);
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
    rollback to delete_pay_net_calc_rule;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --


    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_pay_net_calc_rule;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_pay_net_calc_rule;
--
end pay_ncr_api;

/
