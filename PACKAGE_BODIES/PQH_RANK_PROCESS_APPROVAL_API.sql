--------------------------------------------------------
--  DDL for Package Body PQH_RANK_PROCESS_APPROVAL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RANK_PROCESS_APPROVAL_API" as
/* $Header: pqrapapi.pkb 120.1 2005/06/03 11:59:08 nsanghal noship $ */
--
-- Package Variables
--
g_package  constant varchar2(33) := '  PQH_RANK_PROCESS_APPROVAL_API.';
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_rank_process_approval >--------------------|
-- ----------------------------------------------------------------------------
--
procedure create_rank_process_approval
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_rank_process_approval_id      out nocopy     number
  ,p_rank_process_id               in     number
  ,p_approval_date                 in     date
  ,p_supervisor_id                 in     number  default null
  ,p_system_rank                   in     number
  ,p_population_count              in     number  default null
  ,p_proposed_rank                 in     number  default null
  ,p_object_version_number         out nocopy   number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number     number;
  l_effective_date            date;
  l_rank_process_approval_id  pqh_rank_process_approvals.rank_process_approval_id%Type;
  l_proc constant varchar2(72):= g_package||'create_rank_process_approval';
begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_RANK_PROCESS_APPROVAL;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date        := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
    pqh_rank_process_approval_bk1.create_rank_process_approval_b
      (p_effective_date                => l_effective_date
      ,p_rank_process_approval_id      => l_rank_process_approval_id
      ,p_rank_process_id               => p_rank_process_id
      ,p_approval_date                 => p_approval_date
      ,p_supervisor_id                 => p_supervisor_id
      ,p_system_rank                   => p_system_rank
      ,p_population_count              => p_population_count
      ,p_proposed_rank                 => p_proposed_rank
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_RANK_PROCESS_APPROVAL_API'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  pqh_rap_ins.ins
      (p_effective_date                => l_effective_date
      ,p_rank_process_id               => p_rank_process_id
      ,p_approval_date                 => p_approval_date
      ,p_supervisor_id                 => p_supervisor_id
      ,p_system_rank                   => p_system_rank
      ,p_population_count              => p_population_count
      ,p_proposed_rank                 => p_proposed_rank
      ,p_rank_process_approval_id      => l_rank_process_approval_id
      ,p_object_version_number         => l_object_version_number
      );

  --
  -- Call After Process User Hook
  --
  begin
    pqh_rank_process_approval_bk1.create_rank_process_approval_a
      (p_effective_date                => l_effective_date
      ,p_rank_process_id               => p_rank_process_id
      ,p_approval_date                 => p_approval_date
      ,p_supervisor_id                 => p_supervisor_id
      ,p_system_rank                   => p_system_rank
      ,p_population_count              => p_population_count
      ,p_proposed_rank                 => p_proposed_rank
      ,p_rank_process_approval_id      => l_rank_process_approval_id
      ,p_object_version_number         => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_RANK_PROCESS_APPROVAL_API'
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
  p_rank_process_approval_id  := l_rank_process_approval_id;
  p_object_version_number     := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_RANK_PROCESS_APPROVAL;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_rank_process_approval_id  := null;
    p_object_version_number     := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_RANK_PROCESS_APPROVAL;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_rank_process_approval_id  := null;
    p_object_version_number     := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_rank_process_approval;
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_rank_process_approval >--------------------|
-- ----------------------------------------------------------------------------
--
procedure update_rank_process_approval
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_rank_process_approval_id      in     number
  ,p_rank_process_id               in     number
  ,p_approval_date                 in     date
  ,p_supervisor_id                 in     number  default hr_api.g_number
  ,p_system_rank                   in     number  default hr_api.g_number
  ,p_population_count              in     number  default hr_api.g_number
  ,p_proposed_rank                 in     number  default hr_api.g_number
  ,p_object_version_number         in out nocopy   number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number    number;
  l_effective_date      date;
  l_proc constant varchar2(72):= g_package||'update_rank_process_approval';
begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  savepoint UPDATE_RANK_PROCESS_APPROVAL;
  --
  --Remember IN OUT parameter IN values
  --
  l_object_version_number := p_object_version_number;

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
    pqh_rank_process_approval_bk2.update_rank_process_approval_b
      (p_effective_date                => l_effective_date
      ,p_rank_process_approval_id      => p_rank_process_approval_id
      ,p_rank_process_id               => p_rank_process_id
      ,p_approval_date                 => p_approval_date
      ,p_supervisor_id                 => p_supervisor_id
      ,p_system_rank                   => p_system_rank
      ,p_population_count              => p_population_count
      ,p_proposed_rank                 => p_proposed_rank
      ,p_object_version_number         => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_RANK_PROCESS_APPROVAL_API'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  pqh_rap_upd.upd
      (p_effective_date                => l_effective_date
      ,p_rank_process_approval_id      => p_rank_process_approval_id
      ,p_rank_process_id               => p_rank_process_id
      ,p_approval_date                 => p_approval_date
      ,p_supervisor_id                 => p_supervisor_id
      ,p_system_rank                   => p_system_rank
      ,p_population_count              => p_population_count
      ,p_proposed_rank                 => p_proposed_rank
      ,p_object_version_number         => l_object_version_number
      );
  --
  -- Call After Process User Hook
  --
  begin
    pqh_rank_process_approval_bk2.update_rank_process_approval_a
      (p_effective_date                => l_effective_date
      ,p_rank_process_approval_id      => p_rank_process_approval_id
      ,p_rank_process_id               => p_rank_process_id
      ,p_approval_date                 => p_approval_date
      ,p_supervisor_id                 => p_supervisor_id
      ,p_system_rank                   => p_system_rank
      ,p_population_count              => p_population_count
      ,p_proposed_rank                 => p_proposed_rank
      ,p_object_version_number         => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_RANK_PROCESS_APPROVAL_API'
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
    rollback to UPDATE_RANK_PROCESS_APPROVAL;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_RANK_PROCESS_APPROVAL;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_rank_process_approval;
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_rank_process_approval >--------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_rank_process_approval
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_rank_process_approval_id      in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_effective_date      date;
  l_proc constant varchar2(72) := g_package||'delete_rank_process_approval';
begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  savepoint DELETE_RANK_PROCESS_APPROVAL;
  --
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
    pqh_rank_process_approval_bk3.delete_rank_process_approval_b
      (p_effective_date                => l_effective_date
      ,p_rank_process_approval_id      => p_rank_process_approval_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_RANK_PROCESS_APPROVAL_API'
        ,p_hook_type   => 'BP'
        );
  end;

 --
  -- Process Logic
  --
  pqh_rap_del.del
      (p_rank_process_approval_id      => p_rank_process_approval_id
      ,p_object_version_number         => p_object_version_number
      );

  --
  -- Call After Process User Hook
  --
  begin
    pqh_rank_process_approval_bk3.delete_rank_process_approval_a
      (p_effective_date                => l_effective_date
      ,p_rank_process_approval_id      => p_rank_process_approval_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_RANK_PROCESS_APPROVAL_API'
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
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);

exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_RANK_PROCESS_APPROVAL;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to DELETE_RANK_PROCESS_APPROVAL;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_rank_process_approval;
--
end pqh_rank_process_approval_api;

/
