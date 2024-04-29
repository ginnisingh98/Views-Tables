--------------------------------------------------------
--  DDL for Package Body PAY_RUN_TYPE_ORG_METHOD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_RUN_TYPE_ORG_METHOD_API" as
/* $Header: pyromapi.pkb 115.2 2002/12/09 15:00:43 divicker noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  PAY_RUN_TYPE_ORG_METHOD_API.';
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_run_type_org_method >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_run_type_org_method
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_run_type_id                   in     number
  ,p_org_payment_method_id         in     number
  ,p_priority                      in     number
  ,p_percentage                    in     number   default null
  ,p_amount                        in     number   default null
  ,p_business_group_id             in     number   default null
  ,p_legislation_code              in     varchar2 default null
  ,p_run_type_org_method_id           out nocopy number
  ,p_object_version_number            out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'create_run_type_org_method';
  l_effective_date      date;
  --
  -- Declare OUT variables
  --
  l_run_type_org_method_id  pay_run_type_org_methods_f.run_type_org_method_id%TYPE;
  l_object_version_number   pay_run_type_org_methods_f.object_version_number%TYPE;
  l_effective_start_date    pay_run_type_org_methods_f.effective_start_date%TYPE;
  l_effective_end_date      pay_run_type_org_methods_f.effective_end_date%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_run_type_org_method;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  hr_utility.set_location('Entering:'|| l_proc, 20);
  --
  -- Call Before Process User Hook
  --
  begin
    pay_run_type_org_method_bk1.create_run_type_org_method_b
      (p_effective_date                => p_effective_date
      ,p_run_type_id                   => p_run_type_id
      ,p_org_payment_method_id         => p_org_payment_method_id
      ,p_priority                      => p_priority
      ,p_percentage                    => p_percentage
      ,p_amount                        => p_amount
      ,p_business_group_id             => p_business_group_id
      ,p_legislation_code              => p_legislation_code
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_run_type_org_method'
        ,p_hook_type   => 'BP'
        );
  end;
  hr_utility.set_location('Entering:'|| l_proc, 30);
  --
  -- Validation in addition to Row Handlers
  --
  hr_utility.set_location('Entering:'|| l_proc, 40);
  --
  -- Process Logic
  --
  -- Call the row handler
  --
    pay_rom_ins.ins
       (p_effective_date               => l_effective_date
       ,p_run_type_id                  => p_run_type_id
       ,p_org_payment_method_id        => p_org_payment_method_id
       ,p_priority                     => p_priority
       ,p_percentage                   => p_percentage
       ,p_amount                       => p_amount
       ,p_business_group_id            => p_business_group_id
       ,p_legislation_code             => p_legislation_code
       ,p_run_type_org_method_id       => l_run_type_org_method_id
       ,p_object_version_number        => l_object_version_number
       ,p_effective_start_date         => l_effective_start_date
       ,p_effective_end_date           => l_effective_end_date
       );
    --
    hr_utility.set_location('Entering:'|| l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    pay_run_type_org_method_bk1.create_run_type_org_method_a
      (p_effective_date                => p_effective_date
      ,p_run_type_id                   => p_run_type_id
      ,p_org_payment_method_id         => p_org_payment_method_id
      ,p_priority                      => p_priority
      ,p_percentage                    => p_percentage
      ,p_amount                        => p_amount
      ,p_business_group_id             => p_business_group_id
      ,p_legislation_code              => p_legislation_code
      ,p_run_type_org_method_id        => l_run_type_org_method_id
      ,p_object_version_number         => l_object_version_number
      ,p_effective_start_date          => l_effective_start_date
      ,p_effective_end_date            => l_effective_end_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_run_type_org_method'
        ,p_hook_type   => 'AP'
        );
  end;
  hr_utility.set_location('Entering:'|| l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_run_type_org_method_id := l_run_type_org_method_id;
  p_object_version_number  := l_object_version_number;
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_run_type_org_method;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_run_type_org_method_id := null;
    p_object_version_number  := null;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_run_type_org_method;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_run_type_org_method_id := null;
    p_object_version_number  := null;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_run_type_org_method;
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_run_type_org_method >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_run_type_org_method
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_update_mode         in     varchar2
  ,p_run_type_org_method_id        in     number
  ,p_object_version_number         in out nocopy number
  ,p_priority                      in     number   default hr_api.g_number
  ,p_percentage                    in     number   default hr_api.g_number
  ,p_amount                        in     number   default hr_api.g_number
  ,p_business_group_id             in     number   default hr_api.g_number
  ,p_legislation_code              in     varchar2 default hr_api.g_varchar2
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'update_run_type_org_method';
  l_effective_date      date;
  --
  -- Declare OUT variables
  --
  l_effective_start_date    pay_run_type_org_methods_f.effective_start_date%TYPE;
  l_effective_end_date      pay_run_type_org_methods_f.effective_end_date%TYPE;
  --
  -- Declare IN OUT variables
  --
  l_object_version_number   pay_run_type_org_methods_f.object_version_number%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint and assign IN OUT parameters to local variables.
  --
  l_object_version_number := p_object_version_number;
  savepoint update_run_type_org_method;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  hr_utility.set_location('Entering:'|| l_proc, 20);
  --
  -- Call Before Process User Hook
  --
  begin
    pay_run_type_org_method_bk2.update_run_type_org_method_b
      (p_effective_date                => p_effective_date
      ,p_datetrack_update_mode         => p_datetrack_update_mode
      ,p_run_type_org_method_id        => p_run_type_org_method_id
      ,p_object_version_number         => l_object_version_number
      ,p_priority                      => p_priority
      ,p_percentage                    => p_percentage
      ,p_amount                        => p_amount
      ,p_business_group_id             => p_business_group_id
      ,p_legislation_code              => p_legislation_code
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_run_type_org_method'
        ,p_hook_type   => 'BP'
        );
  end;
  hr_utility.set_location('Entering:'|| l_proc, 30);
  --
  -- Validation in addition to Row Handlers
  --
  hr_utility.set_location('Entering:'|| l_proc, 40);
  --
  -- Process Logic
  --
  -- Call the row handler
  --
    pay_rom_upd.upd
       (p_effective_date               => l_effective_date
       ,p_datetrack_mode               => p_datetrack_update_mode
       ,p_run_type_org_method_id       => p_run_type_org_method_id
       ,p_object_version_number        => l_object_version_number
       ,p_priority                     => p_priority
       ,p_percentage                   => p_percentage
       ,p_amount                       => p_amount
       ,p_effective_start_date         => l_effective_start_date
       ,p_effective_end_date           => l_effective_end_date
       );
    --
    hr_utility.set_location('Entering:'|| l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    pay_run_type_org_method_bk2.update_run_type_org_method_a
      (p_effective_date                => p_effective_date
      ,p_datetrack_update_mode         => p_datetrack_update_mode
      ,p_run_type_org_method_id        => p_run_type_org_method_id
      ,p_object_version_number         => l_object_version_number
      ,p_priority                      => p_priority
      ,p_percentage                    => p_percentage
      ,p_amount                        => p_amount
      ,p_business_group_id             => p_business_group_id
      ,p_legislation_code              => p_legislation_code
      ,p_effective_start_date          => l_effective_start_date
      ,p_effective_end_date            => l_effective_end_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_run_type_org_method'
        ,p_hook_type   => 'AP'
        );
  end;
  hr_utility.set_location('Entering:'|| l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_object_version_number  := l_object_version_number;
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_run_type_org_method;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := p_object_version_number;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_run_type_org_method;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number  := l_object_version_number;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_run_type_org_method;
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_run_type_org_method >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_run_type_org_method
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_delete_mode         in     varchar2
  ,p_run_type_org_method_id        in     number
  ,p_object_version_number         in out nocopy number
  ,p_business_group_id             in     number   default null
  ,p_legislation_code              in     varchar2 default null
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'delete_run_type_org_method';
  l_effective_date      date;
  --
  -- Declare OUT variables
  --
  l_effective_start_date    pay_run_type_org_methods_f.effective_start_date%TYPE;
  l_effective_end_date      pay_run_type_org_methods_f.effective_end_date%TYPE;
  --
  -- Declare IN OUT variables
  --
  l_object_version_number   pay_run_type_org_methods_f.object_version_number%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint and assign IN OUT parameters to local variables.
  --
  l_object_version_number := p_object_version_number;
  savepoint delete_run_type_org_method;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  hr_utility.set_location('Entering:'|| l_proc, 20);
  --
  -- Call Before Process User Hook
  --
  begin
    pay_run_type_org_method_bk3.delete_run_type_org_method_b
      (p_effective_date                => p_effective_date
      ,p_datetrack_delete_mode         => p_datetrack_delete_mode
      ,p_run_type_org_method_id        => p_run_type_org_method_id
      ,p_object_version_number         => l_object_version_number
      ,p_business_group_id             => p_business_group_id
      ,p_legislation_code              => p_legislation_code
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_run_type_org_method'
        ,p_hook_type   => 'BP'
        );
  end;
  hr_utility.set_location('Entering:'|| l_proc, 30);
  --
  -- Validation in addition to Row Handlers
  --
  hr_utility.set_location('Entering:'|| l_proc, 40);
  --
  -- Process Logic
  --
  -- Call the row handler
  --
    pay_rom_del.del
       (p_effective_date               => l_effective_date
       ,p_datetrack_mode               => p_datetrack_delete_mode
       ,p_run_type_org_method_id       => p_run_type_org_method_id
       ,p_object_version_number        => l_object_version_number
       ,p_effective_start_date         => l_effective_start_date
       ,p_effective_end_date           => l_effective_end_date
       );
    --
    hr_utility.set_location('Entering:'|| l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    pay_run_type_org_method_bk3.delete_run_type_org_method_a
      (p_effective_date                => p_effective_date
      ,p_datetrack_delete_mode         => p_datetrack_delete_mode
      ,p_run_type_org_method_id        => p_run_type_org_method_id
      ,p_object_version_number         => l_object_version_number
      ,p_business_group_id             => p_business_group_id
      ,p_legislation_code              => p_legislation_code
      ,p_effective_start_date          => l_effective_start_date
      ,p_effective_end_date            => l_effective_end_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_run_type_org_method'
        ,p_hook_type   => 'AP'
        );
  end;
  hr_utility.set_location('Entering:'|| l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_object_version_number  := l_object_version_number;
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_run_type_org_method;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := p_object_version_number;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_run_type_org_method;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number  := l_object_version_number;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_run_type_org_method;
--
end PAY_RUN_TYPE_ORG_METHOD_API;

/
