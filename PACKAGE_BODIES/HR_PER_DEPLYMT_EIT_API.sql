--------------------------------------------------------
--  DDL for Package Body HR_PER_DEPLYMT_EIT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PER_DEPLYMT_EIT_API" as
/* $Header: hrpdeapi.pkb 120.0 2005/09/23 06:44:39 adhunter noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  HR_PER_DEPLYMT_EIT_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_per_deplymt_eit >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_per_deplymt_eit
  (p_validate                         in     boolean  default false
  ,p_person_deployment_id             in     number
  ,p_person_extra_info_id             in     number
  ,p_per_deplymt_eit_id               out nocopy   number
  ,p_object_version_number            out nocopy   number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_per_deplymt_eit_id    number;
  l_object_version_number number;
  l_proc                varchar2(72) := g_package||'create_per_deplymt_eit';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_per_deplymt_eit;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Truncate the time portion from all IN date parameters
  --
  --
  -- Call Before Process User Hook
  --
  begin
    hr_per_deplymt_eit_bk1.create_per_deplymt_eit_b
      (p_person_deployment_id          => p_person_deployment_id
      ,p_person_extra_info_id          => p_person_extra_info_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PER_DEPLYMT_EIT'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

  --
  -- Process Logic
  --
  hr_pde_ins.ins
     (p_person_deployment_id           => p_person_deployment_id
     ,p_person_extra_info_id           => p_person_extra_info_id
     ,p_person_deplymt_eit_id          => l_per_deplymt_eit_id
     ,p_object_version_number          => l_object_version_number
     );
  --
  -- Call After Process User Hook
  --
  begin
    hr_per_deplymt_eit_bk1.create_per_deplymt_eit_a
      (p_person_deployment_id          => p_person_deployment_id
      ,p_person_extra_info_id          => p_person_extra_info_id
      ,p_per_deplymt_eit_id            => l_per_deplymt_eit_id
      ,p_object_version_number         => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PER_DEPLYMT_EIT'
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
  p_per_deplymt_eit_id     := l_per_deplymt_eit_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_per_deplymt_eit;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_per_deplymt_eit_id     := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_per_deplymt_eit;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_per_deplymt_eit_id     := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end CREATE_PER_DEPLYMT_EIT;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_per_deplymt_eit >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_per_deplymt_eit
  (p_validate                      in     boolean  default false
  ,p_per_deplymt_eit_id            in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'delete_per_deplymt_eit';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_per_deplymt_eit;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Truncate the time portion from all IN date parameters
  --
  --
  -- Call Before Process User Hook
  --
  begin
    hr_per_deplymt_eit_bk2.delete_per_deplymt_eit_b
      (p_per_deplymt_eit_id            => p_per_deplymt_eit_id
      ,p_object_version_number          => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PER_DEPLYMT_EIT'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

  --
  -- Process Logic
  --
  hr_pde_del.del
     (p_person_deplymt_eit_id          => p_per_deplymt_eit_id
     ,p_object_version_number          => p_object_version_number
     );
  --
  -- Call After Process User Hook
  --
  begin
    hr_per_deplymt_eit_bk2.delete_per_deplymt_eit_a
      (p_per_deplymt_eit_id            => p_per_deplymt_eit_id
      ,p_object_version_number          => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PER_DEPLYMT_EIT'
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
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_per_deplymt_eit;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_per_deplymt_eit;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end DELETE_PER_DEPLYMT_EIT;
--
end HR_PER_DEPLYMT_EIT_API;

/
