--------------------------------------------------------
--  DDL for Package Body HR_AUTHORIA_MAPPING_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_AUTHORIA_MAPPING_API" as
/* $Header: hrammapi.pkb 115.2 2002/11/29 09:59:57 apholt noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'HR_AUTHORIA_MAPPING_API.';
--
-- ----------------------------------------------------------------------------
-- |----------------------------< CREATE_AUTHORIA_MAPPING >-------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_AUTHORIA_MAPPING
  (p_validate                      in     boolean  default false
  ,p_pl_id                         in     number
  ,p_plip_id                       in     number  default null
  ,p_open_enrollment_flag          in     varchar2
  ,p_target_page                   in     varchar2
  ,p_authoria_mapping_id              out NOCOPY number
  ,p_object_version_number            out NOCOPY number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'CREATE_AUTHORIA_MAPPING';
  l_authoria_mapping_id   number(15);
  l_object_version_number number(9);
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_AUTHORIA_MAPPING;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --
  -- Call Before Process User Hook
  --
  begin
    HR_AUTHORIA_MAPPING_BK1.CREATE_AUTHORIA_MAPPING_b
    (
     p_pl_id                         => p_pl_id
    ,p_plip_id                       => p_plip_id
    ,p_open_enrollment_flag          => p_open_enrollment_flag
    ,p_target_page                   => p_target_page
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_AUTHORIA_MAPPING'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
    hr_amm_ins.ins
    (
     p_pl_id                         => p_pl_id
    ,p_open_enrollment_flag          => p_open_enrollment_flag
    ,p_target_page                   => p_target_page
    ,p_plip_id                       => p_plip_id
    ,p_authoria_mapping_id           => l_authoria_mapping_id
    ,p_object_version_number         => l_object_version_number
    );
  --
  -- Call After Process User Hook
  --
  begin
    HR_AUTHORIA_MAPPING_BK1.CREATE_AUTHORIA_MAPPING_a
    (
     p_pl_id                         => p_pl_id
    ,p_plip_id                       => p_plip_id
    ,p_open_enrollment_flag          => p_open_enrollment_flag
    ,p_target_page                   => p_target_page
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_AUTHORIA_MAPPING'
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
  p_authoria_mapping_id    := l_authoria_mapping_id;
  p_object_version_number  := l_object_version_number;
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_AUTHORIA_MAPPING;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_authoria_mapping_id            := null;
    p_object_version_number          := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_AUTHORIA_MAPPING;
    --
    --Set OUT parameters for NOCOPY
    --
    p_authoria_mapping_id            := null;
    p_object_version_number          := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end CREATE_AUTHORIA_MAPPING;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< UPDATE_AUTHORIA_MAPPING >-------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_AUTHORIA_MAPPING
  (p_validate                      in     boolean  default false
  ,p_target_page                   in     varchar2
  ,p_authoria_mapping_id           in     number
  ,p_pl_id                         in     number
  ,p_plip_id                       in     number  default HR_API.G_number
  ,p_open_enrollment_flag          in     varchar2
  ,p_object_version_number         in out NOCOPY number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'UPDATE_AUTHORIA_MAPPING';
  l_object_version_number number(9);
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_AUTHORIA_MAPPING;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --
  -- Call Before Process User Hook
  --
  begin
    HR_AUTHORIA_MAPPING_BK2.UPDATE_AUTHORIA_MAPPING_b
    (
     p_authoria_mapping_id           => p_authoria_mapping_id
    ,p_pl_id                         => p_pl_id
    ,p_plip_id                       => p_plip_id
    ,p_open_enrollment_flag          => p_open_enrollment_flag
    ,p_target_page                   => p_target_page
    ,p_object_version_number         => p_object_version_number
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_AUTHORIA_MAPPING'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
    hr_amm_upd.upd
    (
     p_pl_id                         => p_pl_id
    ,p_open_enrollment_flag          => p_open_enrollment_flag
    ,p_target_page                   => p_target_page
    ,p_plip_id                       => p_plip_id
    ,p_authoria_mapping_id           => p_authoria_mapping_id
    ,p_object_version_number         => l_object_version_number
    );
  --
  -- Call After Process User Hook
  --
  begin
    HR_AUTHORIA_MAPPING_BK2.UPDATE_AUTHORIA_MAPPING_a
    (
     p_authoria_mapping_id           => p_authoria_mapping_id
    ,p_pl_id                         => p_pl_id
    ,p_plip_id                       => p_plip_id
    ,p_open_enrollment_flag          => p_open_enrollment_flag
    ,p_target_page                   => p_target_page
    ,p_object_version_number         => p_object_version_number
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_AUTHORIA_MAPPING'
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
  p_object_version_number  := l_object_version_number;
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_AUTHORIA_MAPPING;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_AUTHORIA_MAPPING;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end UPDATE_AUTHORIA_MAPPING;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< DELETE_AUTHORIA_MAPPING >-------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_AUTHORIA_MAPPING
  (p_validate                      in     boolean  default false
  ,p_authoria_mapping_id           in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||
                                               'DELETE_AUTHORIA_MAPPING';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_AUTHORIA_MAPPING;

  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
    HR_AUTHORIA_MAPPING_BK3.DELETE_AUTHORIA_MAPPING_b
    (p_authoria_mapping_id           => p_authoria_mapping_id
    ,p_object_version_number         => p_object_version_number
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_AUTHORIA_MAPPING'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
    hr_amm_del.del
    (p_authoria_mapping_id           => p_authoria_mapping_id
    ,p_object_version_number         => p_object_version_number
    );
  --
  -- Call After Process User Hook
  --
  begin
    HR_AUTHORIA_MAPPING_BK3.DELETE_AUTHORIA_MAPPING_a
    (p_authoria_mapping_id           => p_authoria_mapping_id
    ,p_object_version_number         => p_object_version_number
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_AUTHORIA_MAPPING'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_AUTHORIA_MAPPING;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to DELETE_AUTHORIA_MAPPING;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end DELETE_AUTHORIA_MAPPING;
--
--

end HR_AUTHORIA_MAPPING_API;

/
