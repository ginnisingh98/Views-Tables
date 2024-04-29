--------------------------------------------------------
--  DDL for Package Body BEN_CWB_PERSON_TASKS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CWB_PERSON_TASKS_API" as
/* $Header: bectkapi.pkb 120.0 2005/05/28 01:25:07 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  BEN_CWB_PERSON_TASKS_API.';
g_debug boolean := hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_person_task >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_person_task
  (p_validate                      in     boolean  default false
  ,p_group_per_in_ler_id           in     number
  ,p_task_id                       in     number
  ,p_group_pl_id                   in     number
  ,p_lf_evt_ocrd_dt                in     date
  ,p_status_cd                     in     varchar2 default null
  ,p_access_cd                     in     varchar2 default null
  ,p_task_last_update_date         in     date     default null
  ,p_task_last_update_by           in     number   default null
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number number;
  --
  l_proc                varchar2(72) := g_package||'create_person_task';
begin
  if g_debug then
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint create_person_task;
  --
  -- Call Before Process User Hook
  --
  begin
    ben_cwb_person_tasks_bk1.create_person_task_b
          (p_group_per_in_ler_id      => p_group_per_in_ler_id
          ,p_task_id                  => p_task_id
          ,p_group_pl_id              => p_group_pl_id
          ,p_lf_evt_ocrd_dt           => p_lf_evt_ocrd_dt
          ,p_status_cd                => p_status_cd
          ,p_access_cd                => p_access_cd
	  ,p_task_last_update_date    => p_task_last_update_date
	  ,p_task_last_update_by      => p_task_last_update_by
          );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PERSON_TASK'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

  --
  -- Process Logic
  --
  ben_ctk_ins.ins
   (p_group_per_in_ler_id      => p_group_per_in_ler_id
   ,p_task_id                  => p_task_id
   ,p_group_pl_id              => p_group_pl_id
   ,p_lf_evt_ocrd_dt           => p_lf_evt_ocrd_dt
   ,p_status_cd                => p_status_cd
   ,p_access_cd                => p_access_cd
   ,p_task_last_update_date    => p_task_last_update_date
   ,p_task_last_update_by      => p_task_last_update_by
   ,p_object_version_number    => l_object_version_number
   );
  --
  -- Call After Process User Hook
  --
  begin
    ben_cwb_person_tasks_bk1.create_person_task_a
          (p_group_per_in_ler_id      => p_group_per_in_ler_id
          ,p_task_id                  => p_task_id
          ,p_group_pl_id              => p_group_pl_id
          ,p_lf_evt_ocrd_dt           => p_lf_evt_ocrd_dt
          ,p_status_cd                => p_status_cd
          ,p_access_cd                => p_access_cd
          ,p_task_last_update_date    => p_task_last_update_date
          ,p_task_last_update_by      => p_task_last_update_by
          ,p_object_version_number    => l_object_version_number
          );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PERSON_TASK'
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
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_person_task;
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_person_task;
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    raise;
end create_person_task;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_person_task >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_person_task
  (p_validate                      in     boolean  default false
  ,p_group_per_in_ler_id           in     number
  ,p_task_id                       in     number
  ,p_group_pl_id                   in     number   default hr_api.g_number
  ,p_lf_evt_ocrd_dt                in     date     default hr_api.g_date
  ,p_status_cd                     in     varchar2 default hr_api.g_varchar2
  ,p_access_cd                     in     varchar2 default hr_api.g_varchar2
  ,p_task_last_update_date         in     date     default hr_api.g_date
  ,p_task_last_update_by           in     number   default hr_api.g_number
  ,p_object_version_number         in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number number;
  --
  l_proc                varchar2(72) := g_package||'update_person_task';
  --
begin
  if g_debug then
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  l_object_version_number := p_object_version_number;
  --
  -- Issue a savepoint
  --
  savepoint update_person_task;
  --
  -- Call Before Process User Hook
  --
  begin
    ben_cwb_person_tasks_bk2.update_person_task_b
          (p_group_per_in_ler_id      => p_group_per_in_ler_id
          ,p_task_id                  => p_task_id
          ,p_group_pl_id              => p_group_pl_id
          ,p_lf_evt_ocrd_dt           => p_lf_evt_ocrd_dt
          ,p_status_cd                => p_status_cd
          ,p_access_cd                => p_access_cd
          ,p_task_last_update_date    => p_task_last_update_date
          ,p_task_last_update_by      => p_task_last_update_by
          ,p_object_version_number    => l_object_version_number
          );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PERSON_TASK'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

  --
  -- Process Logic
  --
  ben_ctk_upd.upd
   (p_group_per_in_ler_id      => p_group_per_in_ler_id
   ,p_task_id                  => p_task_id
   ,p_group_pl_id              => p_group_pl_id
   ,p_lf_evt_ocrd_dt           => p_lf_evt_ocrd_dt
   ,p_status_cd                => p_status_cd
   ,p_access_cd                => p_access_cd
   ,p_task_last_update_date    => p_task_last_update_date
   ,p_task_last_update_by      => p_task_last_update_by
   ,p_object_version_number    => l_object_version_number
   );
  --
  -- Call After Process User Hook
  --
  begin
    ben_cwb_person_tasks_bk2.update_person_task_a
          (p_group_per_in_ler_id      => p_group_per_in_ler_id
          ,p_task_id                  => p_task_id
          ,p_group_pl_id              => p_group_pl_id
          ,p_lf_evt_ocrd_dt           => p_lf_evt_ocrd_dt
          ,p_status_cd                => p_status_cd
          ,p_access_cd                => p_access_cd
          ,p_task_last_update_date    => p_task_last_update_date
          ,p_task_last_update_by      => p_task_last_update_by
          ,p_object_version_number    => l_object_version_number
          );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PERSON_TASK'
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
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_person_task;
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_person_task;
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    raise;
end update_person_task;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_person_task >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_person_task
  (p_validate                      in     boolean  default false
  ,p_group_per_in_ler_id           in     number
  ,p_task_id            in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'delete_person_task';
  --
begin
  if g_debug then
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint delete_person_task;
  --
  -- Call Before Process User Hook
  --
  begin
    ben_cwb_person_tasks_bk3.delete_person_task_b
          (p_group_per_in_ler_id      => p_group_per_in_ler_id
          ,p_task_id                  => p_task_id
          ,p_object_version_number    => p_object_version_number
          );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PERSON_TASK'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

  --
  -- Process Logic
  --
  ben_ctk_del.del
   (p_group_per_in_ler_id      => p_group_per_in_ler_id
   ,p_task_id                  => p_task_id
   ,p_object_version_number    => p_object_version_number
   );
  --
  -- Call After Process User Hook
  --
  begin
    ben_cwb_person_tasks_bk3.delete_person_task_a
          (p_group_per_in_ler_id      => p_group_per_in_ler_id
          ,p_task_id                  => p_task_id
          ,p_object_version_number    => p_object_version_number
          );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PERSON_TASK'
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
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_person_task;
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_person_task;
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    raise;
end delete_person_task;
--
--
end ben_cwb_person_tasks_api;

/
