--------------------------------------------------------
--  DDL for Package Body PAY_ELEMENT_TYPE_USAGE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ELEMENT_TYPE_USAGE_API" as
/* $Header: pyetuapi.pkb 115.4 2003/02/07 08:32:06 prsundar noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pay_element_type_usage_api.';
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_element_type_usage  >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_element_type_usage
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_run_type_id                   in     number
  ,p_element_type_id               in     number
  ,p_inclusion_flag		   in     varchar2 default 'N'
  ,p_business_group_id             in     number   default null
  ,p_legislation_code              in     varchar2 default null
  ,p_usage_type			   in     varchar2 default null
  ,p_element_type_usage_id            out nocopy number
  ,p_object_version_number            out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_element_type_usage';
  l_effective_date      date;
  --
  -- Declare OUT variables
  --
  l_element_type_usage_id  pay_element_type_usages_f.element_type_usage_id%TYPE;
  l_object_version_number  pay_element_type_usages_f.object_version_number%TYPE;
  l_effective_start_date   pay_element_type_usages_f.effective_start_date%TYPE;
  l_effective_end_date     pay_element_type_usages_f.effective_end_date%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_element_type_usage;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  hr_utility.set_location(l_proc, 20);
  --
  -- Call Before Process User Hook
  --
  begin
    pay_element_type_usage_bk1.create_element_type_usage_b
      (p_effective_date                => l_effective_date
      ,p_run_type_id                   => p_run_type_id
      ,p_element_type_id               => p_element_type_id
      ,p_inclusion_flag		       => p_inclusion_flag
      ,p_business_group_id             => p_business_group_id
      ,p_legislation_code              => p_legislation_code
      ,p_usage_type		       => p_usage_type
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_element_type_usage_b'
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
    pay_etu_ins.ins
       (p_effective_date              => l_effective_date
       ,p_run_type_id                 => p_run_type_id
       ,p_element_type_id             => p_element_type_id
       ,p_inclusion_flag	      => p_inclusion_flag
       ,p_business_group_id           => p_business_group_id
       ,p_legislation_code            => p_legislation_code
       ,p_usage_type		      => p_usage_type
       ,p_element_type_usage_id       => l_element_type_usage_id
       ,p_object_version_number       => l_object_version_number
       ,p_effective_start_date        => l_effective_start_date
       ,p_effective_end_date          => l_effective_end_date
       );
    --
    hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    pay_element_type_usage_bk1.create_element_type_usage_a
      (p_effective_date                => l_effective_date
      ,p_run_type_id                   => p_run_type_id
      ,p_element_type_id               => p_element_type_id
      ,p_inclusion_flag		       => p_inclusion_flag
      ,p_business_group_id             => p_business_group_id
      ,p_legislation_code              => p_legislation_code
      ,p_usage_type		       => p_usage_type
      ,p_element_type_usage_id         => l_element_type_usage_id
      ,p_object_version_number         => l_object_version_number
      ,p_effective_start_date          => l_effective_start_date
      ,p_effective_end_date            => l_effective_end_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_element_type_usage_a'
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
  p_element_type_usage_id  := l_element_type_usage_id;
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
    rollback to create_element_type_usage;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_element_type_usage_id  := null;
    p_object_version_number  := null;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_element_type_usage;
    p_element_type_usage_id := null;
    p_object_version_number := null;
    p_effective_start_date  := null;
    p_effective_end_date    := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_element_type_usage;
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_element_type_usage  >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_element_type_usage
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_update_mode         in     varchar2
  ,p_inclusion_flag		   in     varchar2 default hr_api.g_varchar2
  ,p_element_type_usage_id         in     number
  ,p_object_version_number         in out nocopy number
  ,p_business_group_id             in     number   default hr_api.g_number
  ,p_legislation_code              in     varchar2 default hr_api.g_varchar2
  ,p_usage_type			   in     varchar2 default hr_api.g_varchar2
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'update_element_type_usage';
  l_effective_date      date;
  --
  -- Declare OUT variables
  --
  l_effective_start_date   pay_element_type_usages_f.effective_start_date%TYPE;
  l_effective_end_date     pay_element_type_usages_f.effective_end_date%TYPE;
  --
  -- Declare IN OUT variables
  --
  l_object_version_number  pay_element_type_usages_f.object_version_number%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint and assign IN OUT parameters to local variables
  --
  l_object_version_number  := p_object_version_number;
  savepoint update_element_type_usage;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  hr_utility.set_location(l_proc, 20);
  --
  -- Call Before Process User Hook
  --
  begin
    pay_element_type_usage_bk2.update_element_type_usage_b
      (p_effective_date                => l_effective_date
      ,p_datetrack_update_mode         => p_datetrack_update_mode
      ,p_inclusion_flag		       => p_inclusion_flag
      ,p_element_type_usage_id         => p_element_type_usage_id
      ,p_object_version_number         => p_object_version_number
      ,p_business_group_id             => p_business_group_id
      ,p_legislation_code              => p_legislation_code
      ,p_usage_type		       => p_usage_type
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_element_type_usage_b'
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
    pay_etu_upd.upd
       (p_effective_date              => l_effective_date
       ,p_datetrack_mode              => p_datetrack_update_mode
       ,p_inclusion_flag	      => p_inclusion_flag
       ,p_element_type_usage_id       => p_element_type_usage_id
       ,p_usage_type		      => p_usage_type
       ,p_object_version_number       => p_object_version_number
       ,p_effective_start_date        => l_effective_start_date
       ,p_effective_end_date          => l_effective_end_date
       );
    --
    hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    pay_element_type_usage_bk2.update_element_type_usage_a
      (p_effective_date                => l_effective_date
      ,p_datetrack_update_mode         => p_datetrack_update_mode
      ,p_inclusion_flag		       => p_inclusion_flag
      ,p_element_type_usage_id         => p_element_type_usage_id
      ,p_object_version_number         => p_object_version_number
      ,p_business_group_id             => p_business_group_id
      ,p_legislation_code              => p_legislation_code
      ,p_usage_type		       => p_usage_type
      ,p_effective_start_date          => l_effective_start_date
      ,p_effective_end_date            => l_effective_end_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_element_type_usage_a'
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
  p_object_version_number  := p_object_version_number;
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
    rollback to update_element_type_usage;
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
    rollback to update_element_type_usage;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_element_type_usage;
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_element_type_usage  >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_element_type_usage
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_delete_mode         in     varchar2
  ,p_element_type_usage_id         in     number
  ,p_object_version_number         in out nocopy number
  ,p_business_group_id             in     number   default hr_api.g_number
  ,p_legislation_code              in     varchar2 default hr_api.g_varchar2
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'delete_element_type_usage';
  l_effective_date      date;
  --
  -- Declare OUT variables
  --
  l_effective_start_date   pay_element_type_usages_f.effective_start_date%TYPE;
  l_effective_end_date     pay_element_type_usages_f.effective_end_date%TYPE;
  --
  -- Declare IN OUT variables
  --
  l_object_version_number  pay_element_type_usages_f.object_version_number%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint and assign IN OUT parameters to local variables
  --
  l_object_version_number  := p_object_version_number;
  savepoint delete_element_type_usage;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  hr_utility.set_location(l_proc, 20);
  --
  -- Call Before Process User Hook
  --
  begin
    pay_element_type_usage_bk3.delete_element_type_usage_b
      (p_effective_date                => l_effective_date
      ,p_datetrack_delete_mode         => p_datetrack_delete_mode
      ,p_element_type_usage_id         => p_element_type_usage_id
      ,p_object_version_number         => p_object_version_number
      ,p_business_group_id             => p_business_group_id
      ,p_legislation_code              => p_legislation_code
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_element_type_usage_b'
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
    pay_etu_del.del
       (p_effective_date              => l_effective_date
       ,p_datetrack_mode              => p_datetrack_delete_mode
       ,p_element_type_usage_id       => p_element_type_usage_id
       ,p_object_version_number       => p_object_version_number
       ,p_effective_start_date        => l_effective_start_date
       ,p_effective_end_date          => l_effective_end_date
       );
    --
    hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    pay_element_type_usage_bk3.delete_element_type_usage_a
      (p_effective_date                => l_effective_date
      ,p_datetrack_delete_mode         => p_datetrack_delete_mode
      ,p_element_type_usage_id         => p_element_type_usage_id
      ,p_object_version_number         => p_object_version_number
      ,p_business_group_id             => p_business_group_id
      ,p_legislation_code              => p_legislation_code
      ,p_effective_start_date          => l_effective_start_date
      ,p_effective_end_date            => l_effective_end_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_element_type_usage_a'
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
  p_object_version_number  := p_object_version_number;
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
    rollback to delete_element_type_usage;
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
    rollback to delete_element_type_usage;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_element_type_usage;
--
end pay_element_type_usage_api;

/
