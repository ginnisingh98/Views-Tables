--------------------------------------------------------
--  DDL for Package Body IRC_APL_PROFILE_ACCESS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_APL_PROFILE_ACCESS_API" as
/* $Header: irapaapi.pkb 120.0.12000000.1 2007/03/23 12:08:48 vboggava noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'irc_apl_profile_access_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_apl_profile_access >-------------------|
-- ----------------------------------------------------------------------------
--
procedure create_apl_profile_access
  (p_validate                      in     boolean  default false
  ,p_person_id                     in     number
  ,p_apl_profile_access_id         in  out    nocopy   number
  ,p_object_version_number         out    nocopy   number
  ) is
  --
  --
  Cursor Chk_BG_Tracking_Enabled is
  	select 1 from per_all_assignments_f asg, per_all_people_f allper, per_all_people_f per
  	where asg.person_id = allper.person_id
  	and allper.party_id = per.party_id
  	and trunc(sysdate) between asg.effective_start_date and asg.effective_end_date
  	and trunc(sysdate) between per.effective_start_date and per.effective_end_date
  	and trunc(sysdate) between allper.effective_start_date and allper.effective_end_date
  	and asg.business_group_id in
  	   (select bginfo.organization_id from hr_organization_information bginfo
  	   where bginfo.ORG_INFORMATION_CONTEXT = 'BG Recruitment'
  	   and bginfo.org_information11 = 'Y')
	and per.person_id = irc_utilities_pkg.get_recruitment_person_id(p_person_id);
  --
  -- out variables
  l_apl_profile_access_id		irc_apl_profile_access.apl_profile_access_id%TYPE;
  l_object_version_number	irc_apl_profile_access.object_version_number%TYPE;
  l_proc			varchar2(72) := g_package||'create_apl_profile_access';
   l_cursor_ret_val              number(6);

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);

  --
  -- Issue a savepoint
  --
  savepoint create_apl_profile_access;
  --
  -- Remember IN OUT parameter IN values
  --

  --
  -- Truncate the time portion from all IN date parameters
  --

  hr_utility.set_location(l_proc, 20);
  --
  -- Call Before Process User Hook
  --
  --Comment below To be removed

  hr_utility.set_location(l_proc, 30);
  --
  -- Validation in addition to Row Handlers
  --

  --
  -- Process Logic
  --
    Open Chk_BG_Tracking_Enabled;
    Fetch Chk_BG_Tracking_Enabled Into l_cursor_ret_val;
    If Chk_BG_Tracking_Enabled%found Then
      irc_apa_ins.ins
      (p_person_id                => p_person_id
      ,p_apl_profile_access_id	=> l_apl_profile_access_id
      ,p_object_version_number	=> l_object_version_number
    );
	Close Chk_BG_Tracking_Enabled;
     End If;



  hr_utility.set_location(' Leaving:'||l_proc, 50);
  --
  -- Call After Process User Hook
  --
  --Comment below To be removed

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all IN OUT and OUT parameters with out values
  --
  p_apl_profile_access_id    := l_apl_profile_access_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_apl_profile_access;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_apl_profile_access_id    := null;
    p_object_version_number  := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_apl_profile_access;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_apl_profile_access_id    := null;
    p_object_version_number  := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_apl_profile_access;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_apl_profile_access >-------------------|
-- ----------------------------------------------------------------------------
--
procedure update_apl_profile_access
  (p_validate                      in     boolean  default false
  ,p_person_id                     in     number
  ,p_apl_profile_access_id           in out nocopy   number
  ,p_object_version_number         in out nocopy   number
  ) is
  --
  -- Declare cursors and local variables
  --
  -- out variables
  l_apl_profile_access_id		irc_apl_profile_access.apl_profile_access_id%TYPE;
  l_object_version_number		irc_apl_profile_access.object_version_number%TYPE;
  l_proc				varchar2(72) := g_package||'update_apl_profile_access';

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_apl_profile_access;
  --
  -- Remember IN OUT parameter IN values
  --
  l_apl_profile_access_id		:= p_apl_profile_access_id;
  l_object_version_number		:= p_object_version_number;

  --
  -- Truncate the time portion from all IN date parameters
  --

  hr_utility.set_location(l_proc, 20);
  --
  -- Call Before Process User Hook
  --
  begin
    irc_apl_profile_access_bk2.update_apl_profile_access_b
      (p_person_id              => p_person_id
      ,p_apl_profile_access_id    => l_apl_profile_access_id
      ,p_object_version_number  => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_apl_profile_access'
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
  irc_apa_upd.upd
    (p_person_id                => p_person_id
    ,p_apl_profile_access_id	=> l_apl_profile_access_id
    ,p_object_version_number	=> l_object_version_number
    );
  hr_utility.set_location(' Leaving:'||l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    irc_apl_profile_access_bk2.update_apl_profile_access_a
      (p_person_id              => p_person_id
      ,p_apl_profile_access_id	=> l_apl_profile_access_id
      ,p_object_version_number	=> l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_apl_profile_access'
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
  p_apl_profile_access_id    := l_apl_profile_access_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_apl_profile_access;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_apl_profile_access_id    := p_apl_profile_access_id;
    p_object_version_number  := p_object_version_number;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_apl_profile_access;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_apl_profile_access_id    := p_apl_profile_access_id;
    p_object_version_number  := p_object_version_number;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_apl_profile_access;
--

-- ----------------------------------------------------------------------------
-- |---------------------------< <delete_apl_profile_access> >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_apl_profile_access
  (p_validate				in     boolean  default false
   ,p_person_id			in     number
   ,p_apl_profile_access_id          in number
   ,p_object_version_number		in number
    ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'delete_apl_profile_access';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_apl_profile_access;
  --
  -- Truncate the time portion from all IN date parameters
  --
  -- Call Before Process User Hook
  --
  begin
    irc_apl_profile_access_bk3.delete_apl_profile_access_b
      (p_person_id		       => p_person_id
      ,p_apl_profile_access_id      => p_apl_profile_access_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_apl_profile_access'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  irc_apa_del.del
    ( p_apl_profile_access_id       => p_apl_profile_access_id
     ,p_object_version_number         => p_object_version_number
    );
  --
  -- Call After Process User Hook
  --
  begin
    irc_apl_profile_access_bk3.delete_apl_profile_access_a
      (p_person_id		       => p_person_id
      ,p_apl_profile_access_id      => p_apl_profile_access_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_apl_profile_access'
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
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_apl_profile_access;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_apl_profile_access;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_apl_profile_access;
--
end irc_apl_profile_access_api;

/
