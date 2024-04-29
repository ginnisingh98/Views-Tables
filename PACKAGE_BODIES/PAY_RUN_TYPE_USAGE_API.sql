--------------------------------------------------------
--  DDL for Package Body PAY_RUN_TYPE_USAGE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_RUN_TYPE_USAGE_API" as
/* $Header: pyrtuapi.pkb 115.2 2002/12/09 15:07:08 divicker noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pay_run_type_usage_api.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_run_type_usage >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_run_type_usage
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_parent_run_type_id            in     number
  ,p_child_run_type_id             in     number
  ,p_sequence                      in     number
  ,p_business_group_id             in     number   default null
  ,p_legislation_code              in     varchar2 default null
  ,p_run_type_usage_id                out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_run_type_usage';
  l_effective_date      date;
  --
  -- Declare OUT variables
  --
  l_run_type_usage_id        pay_run_type_usages_f.run_type_usage_id%TYPE;
  l_object_version_number    pay_run_type_usages_f.object_version_number%TYPE;
  l_effective_start_date     pay_run_type_usages_f.effective_start_date%TYPE;
  l_effective_end_date       pay_run_type_usages_f.effective_end_date%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_run_type_usage;
  --
  -- Truncate the time portion from all IN date parameters
  --
    l_effective_date := trunc(p_effective_date);
    hr_utility.set_location(l_proc, 20);
  --
  -- Call Before Process User Hook
  --
  begin
    pay_run_type_usage_bk1.create_run_type_usage_b
      (p_effective_date                => l_effective_date
      ,p_parent_run_type_id            => p_parent_run_type_id
      ,p_child_run_type_id             => p_child_run_type_id
      ,p_sequence                      => p_sequence
      ,p_business_group_id             => p_business_group_id
      ,p_legislation_code              => p_legislation_code
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_run_type_usage'
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
  -- Call the row handler
  --
    pay_rtu_ins.ins
       (p_effective_date         => l_effective_date
       ,p_parent_run_type_id     => p_parent_run_type_id
       ,p_child_run_type_id      => p_child_run_type_id
       ,p_sequence               => p_sequence
       ,p_business_group_id      => p_business_group_id
       ,p_legislation_code       => p_legislation_code
       ,p_run_type_usage_id      => l_run_type_usage_id
       ,p_object_version_number  => l_object_version_number
       ,p_effective_start_date   => l_effective_start_date
       ,p_effective_end_date     => l_effective_end_date
       );
    --
    hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    pay_run_type_usage_bk1.create_run_type_usage_a
      (p_effective_date         => l_effective_date
      ,p_parent_run_type_id     => p_parent_run_type_id
      ,p_child_run_type_id      => p_child_run_type_id
      ,p_sequence               => p_sequence
      ,p_business_group_id      => p_business_group_id
      ,p_legislation_code       => p_legislation_code
      ,p_run_type_usage_id      => l_run_type_usage_id
      ,p_effective_start_date   => l_effective_start_date
      ,p_effective_end_date     => l_effective_end_date
      ,p_object_version_number  => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_run_type_usage'
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
  p_run_type_usage_id      := l_run_type_usage_id;
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_date;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_run_type_usage;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_run_type_usage_id      := null;
    p_object_version_number  := null;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_run_type_usage;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_run_type_usage_id      := null;
    p_object_version_number  := null;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_run_type_usage;
-- ----------------------------------------------------------------------------
-- |------------------------< update_run_type_usage >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_run_type_usage
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_update_mode         in     varchar2
  ,p_run_type_usage_id             in     number
  ,p_object_version_number         in out nocopy number
  ,p_sequence                      in     number   default hr_api.g_number
  ,p_business_group_id             in     number   default hr_api.g_number
  ,p_legislation_code              in     varchar2 default hr_api.g_varchar2
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'update_run_type_usage';
  l_effective_date       date;
  --
  -- Declare OUT variables
  --
  l_effective_start_date     pay_run_type_usages_f.effective_start_date%TYPE;
  l_effective_end_date       pay_run_type_usages_f.effective_end_date%TYPE;
  --
  -- Declare IN OUT variable
  --
  l_object_version_number    pay_run_type_usages_f.object_version_number%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  l_object_version_number := p_object_version_number;
  savepoint update_run_type_usage;
  --
  -- Truncate the time portion from all IN date parameters
  --
    l_effective_date := trunc(p_effective_date);
    hr_utility.set_location(l_proc, 20);
  --
  -- Call Before Process User Hook
  --
  begin
    pay_run_type_usage_bk2.update_run_type_usage_b
      (p_effective_date                => l_effective_date
      ,p_datetrack_update_mode         => p_datetrack_update_mode
      ,p_run_type_usage_id             => p_run_type_usage_id
      ,p_object_version_number         => p_object_version_number
      ,p_sequence                      => p_sequence
      ,p_business_group_id             => p_business_group_id
      ,p_legislation_code              => p_legislation_code
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_run_type_usage'
        ,p_hook_type   => 'BP'
        );
  end;
  hr_utility.set_location(l_proc, 30);
  --
  -- Validation in addition to Row Handlers
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- call the row handler
  --
    pay_rtu_upd.upd
       (p_effective_date              => l_effective_date
       ,p_datetrack_mode              => p_datetrack_update_mode
       ,p_run_type_usage_id           => p_run_type_usage_id
       ,p_object_version_number       => p_object_version_number
       ,p_sequence                    => p_sequence
       ,p_effective_start_date        => l_effective_start_date
       ,p_effective_end_date          => l_effective_end_date
       );
    --
    hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    pay_run_type_usage_bk2.update_run_type_usage_a
      (p_effective_date                => l_effective_date
      ,p_datetrack_update_mode         => p_datetrack_update_mode
      ,p_run_type_usage_id             => p_run_type_usage_id
      ,p_object_version_number         => p_object_version_number
      ,p_sequence                      => p_sequence
      ,p_business_group_id             => p_business_group_id
      ,p_legislation_code              => p_legislation_code
      ,p_effective_start_date          => l_effective_start_date
      ,p_effective_end_date            => l_effective_end_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_run_type_usage'
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
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_date;
  p_object_version_number  := p_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_run_type_usage;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_run_type_usage;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number  := l_object_version_number;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_run_type_usage;
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_run_type_usage >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_run_type_usage
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_delete_mode         in     varchar2
  ,p_run_type_usage_id             in     number
  ,p_object_version_number         in out nocopy number
  ,p_business_group_id             in     number   default hr_api.g_number
  ,p_legislation_code              in     varchar2 default hr_api.g_varchar2
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'delete_run_type_usage';
  l_effective_date      date;
  --
  -- Declare OUT variables
  --
  l_effective_start_date pay_run_type_usages_f.effective_start_date%type;
  l_effective_end_date   pay_run_type_usages_f.effective_end_date%type;
  l_object_version_number pay_run_type_usages_f.object_version_number%type;
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint
  --
  savepoint delete_run_type_usage;
  l_object_version_number := p_object_version_number;
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- Truncate the time portion from all IN date parameters
  --
    l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
    pay_run_type_usage_bk3.delete_run_type_usage_b
      (p_effective_date                => l_effective_date
      ,p_datetrack_delete_mode         => p_datetrack_delete_mode
      ,p_run_type_usage_id             => p_run_type_usage_id
      ,p_object_version_number         => p_object_version_number
      ,p_business_group_id             => p_business_group_id
      ,p_legislation_code              => p_legislation_code
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_run_type_usage'
        ,p_hook_type   => 'BP'
        );
  end;
  hr_utility.set_location(l_proc, 20);
  --
  -- Validation in addition to Row Handlers
  --
    hr_utility.set_location(l_proc, 30);
  --
  -- Process Logic
  --
  -- Call the row handler to delete the run_type
  --
    pay_rtu_del.del
      (p_effective_date            => l_effective_date
      ,p_datetrack_mode            => p_datetrack_delete_mode
      ,p_run_type_usage_id         => p_run_type_usage_id
      ,p_object_version_number     => p_object_version_number
      ,p_effective_start_date      => l_effective_start_date
      ,p_effective_end_date        => l_effective_end_date
      );
   --
   hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    pay_run_type_usage_bk3.delete_run_type_usage_a
      (p_effective_date                => l_effective_date
      ,p_datetrack_delete_mode         => p_datetrack_delete_mode
      ,p_run_type_usage_id             => p_run_type_usage_id
      ,p_object_version_number         => p_object_version_number
      ,p_business_group_id             => p_business_group_id
      ,p_legislation_code              => p_legislation_code
      ,p_effective_start_date          => l_effective_start_date
      ,p_effective_end_date            => l_effective_end_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_run_type_usage'
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
  -- Set out parameters
  --
    p_object_version_number := p_object_version_number;
    p_effective_start_date  := l_effective_start_date;
    p_effective_end_date    := l_effective_end_date;
    --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_run_type_usage;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number := l_object_version_number;
    p_effective_start_date  := null;
    p_effective_end_date    := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_run_type_usage;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number := l_object_version_number;
    p_effective_start_date  := null;
    p_effective_end_date    := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_run_type_usage;
--
end pay_run_type_usage_api;

/
