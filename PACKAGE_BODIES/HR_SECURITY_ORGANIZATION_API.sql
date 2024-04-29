--------------------------------------------------------
--  DDL for Package Body HR_SECURITY_ORGANIZATION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SECURITY_ORGANIZATION_API" as
/* $Header: pepsoapi.pkb 115.1 2002/12/11 12:15:36 eumenyio noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'HR_SECURITY_ORGANIZATION_API.';

--
-- ----------------------------------------------------------------------------
-- |-------------------< create_security_organization >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_security_organization
  ( p_validate                  in  boolean  default false
  , p_security_profile_id	in  number
  , p_organization_id		in  number
  , p_entry_type                in  varchar2
  , p_security_organization_id  out nocopy number
  , p_object_version_number     out nocopy number
  ) is
--
-- Declare cursors and local variables
--
  l_proc                varchar2(72) := g_package||'create_security_organization';
  l_object_version_number     number;
  l_security_organization_id      number;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_security_organization;
  --
  --
  -- Call Before Process User Hook
  --
  begin
    hr_security_organization_bk1.create_security_organization_b
    (
     p_security_profile_id  => p_security_profile_id
    , p_organization_id      => p_organization_id
    , p_entry_type           => p_entry_type
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_security_organization'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  per_pso_ins.ins
    ( p_security_profile_id  	=> p_security_profile_id
    , p_organization_id      	=> p_organization_id
    , p_entry_type           	=> p_entry_type
    , p_security_organization_id=> l_security_organization_id
    , p_object_version_number   => l_object_version_number
   );
  --
  -- Call After Process User Hook
  --
  begin
    hr_security_organization_bk1.create_security_organization_b
    ( p_security_profile_id     => p_security_profile_id
    , p_organization_id         => p_organization_id
    , p_entry_type              => p_entry_type
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_security_organization'
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
  p_security_organization_id     := l_security_organization_id;
  p_object_version_number        := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_security_profile_id;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_security_organization_id   := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_security_organization_id   := null;
    p_object_version_number  := null;
    rollback to create_security_organization;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_security_organization;
--
-- ----------------------------------------------------------------------------
-- |-----------------< update_security_organization >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_security_organization
  (
      p_validate                  in  boolean  default false
    , p_security_profile_id       in  number   default hr_api.g_number
    , p_organization_id           in  number   default hr_api.g_number
    , p_entry_type                in  varchar2 default hr_api.g_varchar2
    , p_security_organization_id  in  number
    , p_object_version_number  in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'update_security_organization';
  l_object_version_number  number       := p_object_version_number;
  l_temp_ovn            number       := p_object_version_number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_security_organization;
  --
  -- Call Before Process User Hook
  --
  begin
    hr_security_organization_bk2.update_security_organization_b
    (
      p_security_profile_id     => p_security_profile_id
    , p_organization_id         => p_organization_id
    , p_entry_type              => p_entry_type
    , p_security_organization_id=> p_security_organization_id
    , p_object_version_number   => l_object_version_number
);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_security_organization'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  per_pso_upd.upd
    ( p_security_organization_id=> p_security_organization_id
    , p_security_profile_id     => p_security_profile_id
    , p_organization_id         => p_organization_id
    , p_entry_type              => p_entry_type
    , p_object_version_number   => l_object_version_number
    );
  --
  --  Call After Process User Hook
  --
  begin
     hr_security_organization_bk2.update_security_organization_a
    (
      p_security_profile_id     => p_security_profile_id
    , p_organization_id         => p_organization_id
    , p_entry_type              => p_entry_type
    , p_security_organization_id=> p_security_organization_id
    , p_object_version_number   => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_security_organization'
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
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_security_organization;
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
    p_object_version_number  := l_temp_ovn;
    rollback to update_irc_asg_status;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_security_organization;
--
-- ----------------------------------------------------------------------------
-- |-------------------< delete_security_organization >-----------------------|
-- ----------------------------------------------------------------------------
procedure delete_security_organization
  (
    p_validate                  in  boolean  default false
  , p_security_organization_id	in  number
  , p_object_version_number     in  number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc           varchar2(72) := g_package||'delete_security_organization';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_security_organization;
  --
  -- Call Before Process User Hook
  --
  begin
    hr_security_organization_bk3.delete_security_organization_b
      (
        p_security_organization_id  => p_security_organization_id
      , p_object_version_number     => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_security_organization'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  per_pso_del.del
    (p_security_organization_id  => p_security_organization_id
    ,p_object_version_number            => p_object_version_number
    );
  --
  -- Call After Process User Hook
  --
  begin
  hr_security_organization_bk3.delete_security_organization_a
      (
        p_security_organization_id  => p_security_organization_id
      , p_object_version_number     => p_object_version_number
      );
exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_security_organization'
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
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_security_organization;
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
    rollback to delete_security_organization;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_security_organization;
--
end HR_SECURITY_ORGANIZATION_API;

/
