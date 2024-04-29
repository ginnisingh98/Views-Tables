--------------------------------------------------------
--  DDL for Package Body HR_ASG_BUDGET_VALUE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ASG_BUDGET_VALUE_API" as
/* $Header: peabvapi.pkb 115.6 2002/12/18 04:59:31 raranjan noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'HR_ASG_BUDGET_VALUE_API';
--
-- ----------------------------------------------------------------------------
-- |----------------------< CREATE_ASG_BUDGET_VALUE >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_ASG_BUDGET_VALUE
 (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_assignment_id                 in     number
  ,p_unit                          in     varchar2
  ,p_value                         in     number
  ,p_request_id                    in     number   default null
  ,p_program_application_id        in     number   default null
  ,p_program_id                    in     number   default null
  ,p_program_update_date           in     date     default null
  ,p_last_update_date              in     date     default null
  ,p_last_updated_by               in     number   default null
  ,p_last_update_login             in     number   default null
  ,p_created_by                    in     number   default null
  ,p_creation_date                 in     date     default null
  ,p_object_version_number         out nocopy    number
  ,p_assignment_budget_value_id    out nocopy    number
 ) is
  --
  -- Declare cursors and local variables
  --
  l_assignment_budget_value_id  number;
  l_object_version_number       number;
  l_effective_start_date        date;
  l_effective_end_date          date;
  l_proc                varchar2(72) := g_package||'CREATE_ASG_BUDGET_VALUE';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_ASG_BUDGET_VALUE;
  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
    HR_ASG_BUDGET_VALUE_BK1.CREATE_ASG_BUDGET_VALUE_b
      (p_validate                 => p_validate
      ,p_effective_date            => p_effective_date
      ,p_business_group_id         => p_business_group_id
      ,p_assignment_id             => p_assignment_id
      ,p_unit                      => p_unit
      ,p_value                     => p_value
      ,p_request_id                => p_request_id
      ,p_program_application_id    => p_program_application_id
      ,p_program_id                => p_program_id
      ,p_program_update_date       => p_program_update_date
      ,p_last_update_date          => p_last_update_date
      ,p_last_updated_by           => p_last_updated_by
      ,p_last_update_login         => p_last_update_login
      ,p_created_by                => p_created_by
      ,p_creation_date             => p_creation_date
);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ASG_BUDGET_VALUE'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
per_abv_ins.ins
  (p_effective_date                => p_effective_date
  ,p_business_group_id             => p_business_group_id
  ,p_assignment_id                 => p_assignment_id
  ,p_unit                          => p_unit
  ,p_value                         => p_value
  ,p_request_id                    => p_request_id
  ,p_program_application_id        => p_program_application_id
  ,p_program_id                    => p_program_id
  ,p_program_update_date           => p_program_update_date
  ,p_effective_start_date          => l_effective_start_date
  ,p_effective_end_date            => l_effective_end_date
  ,p_assignment_budget_value_id    => l_assignment_budget_value_id
  ,p_object_version_number         => p_object_version_number
  );



  --
  -- Process Logic
  --



  --
  -- Call After Process User Hook
  --
  begin
    HR_ASG_BUDGET_VALUE_BK1.CREATE_ASG_BUDGET_VALUE_a
      (p_effective_date            => p_effective_date
      ,p_business_group_id         => p_business_group_id
      ,p_assignment_id             => p_assignment_id
      ,p_unit                      => p_unit
      ,p_value                     => p_value
      ,p_request_id                => p_request_id
      ,p_program_application_id    => p_program_application_id
      ,p_program_id                => p_program_id
      ,p_program_update_date       => p_program_update_date
      ,p_last_update_date          => p_last_update_date
      ,p_last_updated_by           => p_last_updated_by
      ,p_last_update_login         => p_last_update_login
      ,p_created_by                => p_created_by
      ,p_creation_date             => p_creation_date
      ,p_assignment_budget_value_id=> l_assignment_budget_value_id
      ,p_effective_start_date      => l_effective_start_date
      ,p_effective_end_date        => l_effective_end_date
      ,p_object_version_number     => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ASG_BUDGET_VALUE'
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
  p_assignment_budget_value_id      := l_assignment_budget_value_id;
  p_object_version_number           := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_ASG_BUDGET_VALUE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_assignment_budget_value_id                     := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_object_version_number := null;
    p_assignment_budget_value_id := null;

    rollback to CREATE_ASG_BUDGET_VALUE;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end CREATE_ASG_BUDGET_VALUE;
--
-- ----------------------------------------------------------------------------
-- |----------------------< UPDATE_ASG_BUDGET_VALUE >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_ASG_BUDGET_VALUE
  (p_validate                      in     boolean default false
  ,p_assignment_budget_value_id    in     number
  ,p_effective_date                in     date
  ,p_datetrack_mode                in     varchar2
  ,p_business_group_id             in     number   default hr_api.g_number
  ,p_unit                          in     varchar2 default hr_api.g_varchar2
  ,p_value                         in     number   default hr_api.g_number
  ,p_request_id                    in     number   default hr_api.g_number
  ,p_program_application_id        in     number   default hr_api.g_number
  ,p_program_id                    in     number   default hr_api.g_number
  ,p_program_update_date           in     date     default hr_api.g_date
  ,p_last_update_date              in     date     default hr_api.g_date
  ,p_last_updated_by               in     number   default hr_api.g_number
  ,p_last_update_login             in     number   default hr_api.g_number
  ,p_created_by                    in     number   default hr_api.g_number
  ,p_creation_date                 in     date     default hr_api.g_date
  ,p_object_version_number         in out nocopy number
 ) is
  --
  -- Declare cursors and local variables
  --
  l_effective_start_date        date;
  l_effective_end_date          date;
  l_assignment_budget_value_id  number;
  l_proc                varchar2(72) := g_package||'UPDATE_ASG_BUDGET_VALUE';
  --
  lv_object_version_number      number := p_object_version_number ;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_ASG_BUDGET_VALUE;
  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
    HR_ASG_BUDGET_VALUE_BK2.UPDATE_ASG_BUDGET_VALUE_b
      (p_effective_date            => p_effective_date
      ,p_assignment_budget_value_id=> p_assignment_budget_value_id
      ,p_business_group_id         => p_business_group_id
      ,p_unit                      => p_unit
      ,p_value                     => p_value
      ,p_request_id                => p_request_id
      ,p_program_application_id    => p_program_application_id
      ,p_program_id                => p_program_id
      ,p_program_update_date       => p_program_update_date
      ,p_last_update_date          => p_last_update_date
      ,p_last_updated_by           => p_last_updated_by
      ,p_last_update_login         => p_last_update_login
      ,p_created_by                => p_created_by
      ,p_creation_date             => p_creation_date
      ,p_datetrack_mode            => p_datetrack_mode
      ,p_object_version_number     => p_object_version_number
);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ASG_BUDGET_VALUE'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
per_abv_upd.upd
  (p_effective_date                => p_effective_date
  ,p_datetrack_mode                => p_datetrack_mode
  ,p_assignment_budget_value_id    => p_assignment_budget_value_id
  ,p_unit                          => p_unit
  ,p_value                         => p_value
  ,p_request_id                    => p_request_id
  ,p_program_application_id        => p_program_application_id
  ,p_program_id                    => p_program_id
  ,p_program_update_date           => p_program_update_date
  ,p_effective_start_date          => l_effective_start_date
  ,p_effective_end_date            => l_effective_end_date
  ,p_object_version_number         => p_object_version_number
  );
  --
  -- Call After Process User Hook
  --
  begin
    HR_ASG_BUDGET_VALUE_BK2.UPDATE_ASG_BUDGET_VALUE_a
      (p_effective_date            => p_effective_date
      ,p_datetrack_mode            => p_datetrack_mode
      ,p_business_group_id         => p_business_group_id
      ,p_unit                      => p_unit
      ,p_value                     => p_value
      ,p_request_id                => p_request_id
      ,p_program_application_id    => p_program_application_id
      ,p_program_id                => p_program_id
      ,p_program_update_date       => p_program_update_date
      ,p_last_update_date          => p_last_update_date
      ,p_last_updated_by           => p_last_updated_by
      ,p_last_update_login         => p_last_update_login
      ,p_created_by                => p_created_by
      ,p_creation_date             => p_creation_date
      ,p_assignment_budget_value_id=> p_assignment_budget_value_id
      ,p_effective_start_date          => l_effective_start_date
      ,p_effective_end_date            => l_effective_end_date
      ,p_object_version_number         => p_object_version_number
       );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ASG_BUDGET_VALUE'
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
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_ASG_BUDGET_VALUE;
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
    p_object_version_number     := lv_object_version_number ;

    rollback to UPDATE_ASG_BUDGET_VALUE;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end UPDATE_ASG_BUDGET_VALUE;
--


-- ----------------------------------------------------------------------------
-- |----------------------< DELETE_ASG_BUDGET_VALUE >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_ASG_BUDGET_VALUE
 (p_validate                       in     boolean  default false
  ,p_assignment_budget_value_id    in     number
  ,p_effective_date                in     date
  ,p_datetrack_mode                in     varchar2
  ,p_object_version_number         in out nocopy number
 ) is
  --
  -- Declare cursors and local variables
  --
  l_effective_start_date        date;
  l_effective_end_date          date;
  l_object_version_number       number(9);
  l_proc                varchar2(72) := g_package||'DELETE_ASG_BUDGET_VALUE';
  --
  lv_object_version_number      number := p_object_version_number ;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);

  --
  -- Issue a savepoint
  --
  savepoint DELETE_ASG_BUDGET_VALUE;
  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
    HR_ASG_BUDGET_VALUE_BK3.DELETE_ASG_BUDGET_VALUE_b
      (p_assignment_budget_value_id=> p_assignment_budget_value_id
      ,p_datetrack_mode            => p_datetrack_mode
      ,p_effective_date            => p_effective_date
      ,p_object_version_number     => p_object_version_number);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ASG_BUDGET_VALUE'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
l_object_version_number := p_object_version_number;
per_abv_del.del
  (p_effective_date                => p_effective_date
  ,p_datetrack_mode                => p_datetrack_mode
  ,p_assignment_budget_value_id    => p_assignment_budget_value_id
  ,p_effective_start_date          => l_effective_start_date
  ,p_effective_end_date            => l_effective_end_date
  ,p_object_version_number         => l_object_version_number);
  --
  -- Call After Process User Hook
  --
  begin
    HR_ASG_BUDGET_VALUE_BK3.DELETE_ASG_BUDGET_VALUE_a
      (p_effective_date             => p_effective_date
      ,p_datetrack_mode             => p_datetrack_mode
      ,p_assignment_budget_value_id => p_assignment_budget_value_id
      ,p_effective_start_date       => l_effective_start_date
      ,p_effective_end_date         => l_effective_end_date
      ,p_object_version_number      => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ASG_BUDGET_VALUE'
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
  --
  p_object_version_number := l_object_version_number;
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_ASG_BUDGET_VALUE;
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
    p_object_version_number     := lv_object_version_number ;

    rollback to DELETE_ASG_BUDGET_VALUE;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end DELETE_ASG_BUDGET_VALUE;
--


end HR_ASG_BUDGET_VALUE_API;

/
