--------------------------------------------------------
--  DDL for Package Body IRC_APL_PRFL_SNAPSHOTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_APL_PRFL_SNAPSHOTS_API" as
/* $Header: irapsapi.pkb 120.0.12000000.1 2007/03/23 11:42:24 vboggava noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  irc_apl_prfl_snapshots_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_applicant_snapshot >-------------------|
-- ----------------------------------------------------------------------------
--
procedure create_applicant_snapshot
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_profile_snapshot_id           out    nocopy   number
  ,p_object_version_number         out    nocopy   number
  ) is
  --
  -- Declare cursors and local variables
  --
  -- out variables
  l_profile_snapshot_id		irc_apl_profile_snapshots.profile_snapshot_id%TYPE;
  l_object_version_number	irc_apl_profile_snapshots.object_version_number%TYPE;

  l_effective_date		date;
  l_proc			varchar2(72) := g_package||'create_applicant_snapshot';

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_applicant_snapshot;
  --
  -- Remember IN OUT parameter IN values
  --

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  hr_utility.set_location(l_proc, 20);
  --
  -- Call Before Process User Hook
  --
  begin
    irc_apl_prfl_snapshots_bk1.create_applicant_snapshot_b
      (p_effective_date                => l_effective_date
      ,p_person_id		       => p_person_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_applicant_snapshot'
        ,p_hook_type   => 'BP'
        );
  end;
  hr_utility.set_location(l_proc, 30);
  --
  -- Validation in addition to Row Handlers
  --

  --
  -- Process Logic
  --
  irc_aps_ins.ins
    (p_effective_date		=> l_effective_date
    ,p_person_id                => p_person_id
    ,p_profile_snapshot_id	=> l_profile_snapshot_id
    ,p_object_version_number	=> l_object_version_number
    );
  hr_utility.set_location(' Leaving:'||l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    irc_apl_prfl_snapshots_bk1.create_applicant_snapshot_a
      (p_effective_date		=> l_effective_date
      ,p_person_id              => p_person_id
      ,p_profile_snapshot_id	=> l_profile_snapshot_id
      ,p_object_version_number	=> l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_applicant_snapshot'
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
  p_profile_snapshot_id    := l_profile_snapshot_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_applicant_snapshot;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_profile_snapshot_id    := null;
    p_object_version_number  := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_applicant_snapshot;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_profile_snapshot_id    := null;
    p_object_version_number  := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_applicant_snapshot;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_applicant_snapshot >-------------------|
-- ----------------------------------------------------------------------------
--
procedure update_applicant_snapshot
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_profile_snapshot_id           in out nocopy   number
  ,p_object_version_number         in out nocopy   number
  ) is
  --
  -- Declare cursors and local variables
  --
  -- out variables
  l_profile_snapshot_id		irc_apl_profile_snapshots.profile_snapshot_id%TYPE;
  l_object_version_number	irc_apl_profile_snapshots.object_version_number%TYPE;

  l_effective_date		date;
  l_proc			varchar2(72) := g_package||'update_applicant_snapshot';

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_applicant_snapshot;
  --
  -- Remember IN OUT parameter IN values
  --
  l_profile_snapshot_id		:= p_profile_snapshot_id;
  l_object_version_number	:= p_object_version_number;

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  hr_utility.set_location(l_proc, 20);
  --
  -- Call Before Process User Hook
  --
  begin
    irc_apl_prfl_snapshots_bk2.update_applicant_snapshot_b
      (p_effective_date		=> l_effective_date
      ,p_person_id              => p_person_id
      ,p_profile_snapshot_id    => l_profile_snapshot_id
      ,p_object_version_number  => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_applicant_snapshot'
        ,p_hook_type   => 'BP'
        );
  end;
  hr_utility.set_location(l_proc, 30);
  --
  -- Validation in addition to Row Handlers
  --

  --
  -- Process Logic
  --
  irc_aps_upd.upd
    (p_effective_date		=> l_effective_date
    ,p_person_id                => p_person_id
    ,p_profile_snapshot_id	=> l_profile_snapshot_id
    ,p_object_version_number	=> l_object_version_number
    );
  hr_utility.set_location(' Leaving:'||l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    irc_apl_prfl_snapshots_bk2.update_applicant_snapshot_a
      (p_effective_date		=> l_effective_date
      ,p_person_id              => p_person_id
      ,p_profile_snapshot_id	=> l_profile_snapshot_id
      ,p_object_version_number	=> l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_applicant_snapshot'
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
  p_profile_snapshot_id    := l_profile_snapshot_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_applicant_snapshot;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_profile_snapshot_id    := p_profile_snapshot_id;
    p_object_version_number  := p_object_version_number;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_applicant_snapshot;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_profile_snapshot_id    := p_profile_snapshot_id;
    p_object_version_number  := p_object_version_number;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_applicant_snapshot;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_applicant_snapshot >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_applicant_snapshot
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_profile_snapshot_id           in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  -- out variables
  l_profile_snapshot_id		irc_apl_profile_snapshots.profile_snapshot_id%TYPE;
  l_object_version_number	irc_apl_profile_snapshots.object_version_number%TYPE;

  l_effective_date		date;
  l_proc			varchar2(72) := g_package||'delete_applicant_snapshot';

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_applicant_snapshot;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  l_profile_snapshot_id		:= p_profile_snapshot_id;
  l_object_version_number	:= p_object_version_number;
  --
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  hr_utility.set_location(l_proc, 20);
  --
  -- Call Before Process User Hook
  --
  begin
    irc_apl_prfl_snapshots_bk3.delete_applicant_snapshot_b
      (p_effective_date                => l_effective_date
      ,p_person_id		       => p_person_id
      ,p_profile_snapshot_id	       => l_profile_snapshot_id
      ,p_object_version_number	       => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_applicant_snapshot'
        ,p_hook_type   => 'BP'
        );
  end;
  hr_utility.set_location(l_proc, 30);
  --
  -- Validation in addition to Row Handlers
  --

  --
  -- Process Logic
  --
  irc_aps_del.del
    (p_profile_snapshot_id	=> l_profile_snapshot_id
    ,p_object_version_number	=> l_object_version_number
    );
  hr_utility.set_location(' Leaving:'||l_proc, 50);
  --
  --
  -- Call After Process User Hook
  --
  begin
    irc_apl_prfl_snapshots_bk3.delete_applicant_snapshot_a
      (p_effective_date                => l_effective_date
      ,p_person_id		       => p_person_id
      ,p_profile_snapshot_id	       => l_profile_snapshot_id
      ,p_object_version_number	       => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_applicant_snapshot'
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
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_applicant_snapshot;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_applicant_snapshot;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_applicant_snapshot;
--
end irc_apl_prfl_snapshots_api;

/
