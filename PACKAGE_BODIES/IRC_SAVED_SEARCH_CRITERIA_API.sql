--------------------------------------------------------
--  DDL for Package Body IRC_SAVED_SEARCH_CRITERIA_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_SAVED_SEARCH_CRITERIA_API" as
/* $Header: irissapi.pkb 120.0.12000000.1 2007/03/23 11:17:59 vboggava noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'irc_saved_search_criteria_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_search_criteria >-------------------|
-- ----------------------------------------------------------------------------
--
procedure create_search_criteria
  (p_validate                      in     boolean  default false
  ,p_vacancy_id                     in     number
  ,p_saved_search_criteria_id           out    nocopy   number
  ,p_object_version_number         out    nocopy   number
  ) is
  --
  --
   Cursor Chk_BG_Tracking_Enabled is
	select NVL(bginfo.ORG_INFORMATION11,'N')
	from HR_ORGANIZATION_INFORMATION bginfo ,per_all_vacancies vac
	where bginfo.ORG_INFORMATION_CONTEXT = 'BG Recruitment'
	and bginfo.organization_id = vac.business_group_id
	and vac.vacancy_id = p_vacancy_id;
  --
  -- out variables
  l_saved_search_criteria_id		irc_saved_search_criteria.saved_search_criteria_id%TYPE;
  l_object_version_number	irc_saved_search_criteria.object_version_number%TYPE;
  l_proc			varchar2(72) := g_package||'create_search_criteria';
  l_cursor_ret_val              varchar2(10) := 'N';

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);


  --
  -- Issue a savepoint
  --
  savepoint create_search_criteria;
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
  -- Call insert search criteria only if vacancy id is not null and
  -- the vacancy BG has got Applicant tracking enbabled
  If p_vacancy_id Is Not Null Then
	Open Chk_BG_Tracking_Enabled;
	Fetch Chk_BG_Tracking_Enabled Into l_cursor_ret_val;
	If Chk_BG_Tracking_Enabled%found Then
		Close Chk_BG_Tracking_Enabled;
	End If;
	If l_cursor_ret_val='Y' Then
		irc_iss_ins.ins
		(p_vacancy_id                => p_vacancy_id
		,p_saved_search_criteria_id	=> l_saved_search_criteria_id
		,p_object_version_number	=> l_object_version_number
		);
	End If;

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
  p_saved_search_criteria_id    := l_saved_search_criteria_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_search_criteria;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_saved_search_criteria_id    := null;
    p_object_version_number  := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_search_criteria;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_saved_search_criteria_id    := null;
    p_object_version_number  := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_search_criteria;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_search_criteria >-------------------|
-- ----------------------------------------------------------------------------
--
procedure update_search_criteria
  (p_validate                      in     boolean  default false
  ,p_vacancy_id                     in     number
  ,p_saved_search_criteria_id           in out nocopy   number
  ,p_object_version_number         in out nocopy   number
  ) is
  --
  -- Declare cursors and local variables
  --
  -- out variables
  l_saved_search_criteria_id		irc_saved_search_criteria.saved_search_criteria_id%TYPE;
  l_object_version_number		irc_saved_search_criteria.object_version_number%TYPE;
  l_proc				varchar2(72) := g_package||'update_search_criteria';

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_search_criteria;
  --
  -- Remember IN OUT parameter IN values
  --
  l_saved_search_criteria_id		:= p_saved_search_criteria_id;
  l_object_version_number		:= p_object_version_number;

  --
  -- Truncate the time portion from all IN date parameters
  --

  hr_utility.set_location(l_proc, 20);
  --
  -- Call Before Process User Hook
  --
  begin
    irc_saved_search_criteria_bk2.update_search_criteria_b
      (p_vacancy_id              => p_vacancy_id
      ,p_saved_search_criteria_id    => l_saved_search_criteria_id
      ,p_object_version_number  => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_search_criteria'
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
  irc_iss_upd.upd
    (p_vacancy_id                => p_vacancy_id
    ,p_saved_search_criteria_id	=> l_saved_search_criteria_id
    ,p_object_version_number	=> l_object_version_number
    );
  hr_utility.set_location(' Leaving:'||l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    irc_saved_search_criteria_bk2.update_search_criteria_a
      (p_vacancy_id              => p_vacancy_id
      ,p_saved_search_criteria_id	=> l_saved_search_criteria_id
      ,p_object_version_number	=> l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_search_criteria'
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
  p_saved_search_criteria_id    := l_saved_search_criteria_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_search_criteria;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_saved_search_criteria_id    := p_saved_search_criteria_id;
    p_object_version_number  := p_object_version_number;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_search_criteria;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_saved_search_criteria_id    := p_saved_search_criteria_id;
    p_object_version_number  := p_object_version_number;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_search_criteria;
--

-- ----------------------------------------------------------------------------
-- |---------------------------< <delete_search_criteria> >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_search_criteria
  (p_validate				in     boolean  default false
   ,p_vacancy_id			in     number
   ,p_saved_search_criteria_id          in     number
   ,p_object_version_number		in     number
    ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'delete_search_criteria';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_search_criteria;
  --
  -- Truncate the time portion from all IN date parameters
  --
  -- Call Before Process User Hook
  --
  begin
    irc_saved_search_criteria_bk3.delete_search_criteria_b
      (p_vacancy_id		       => p_vacancy_id
      ,p_saved_search_criteria_id      => p_saved_search_criteria_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_search_criteria'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  irc_iss_del.del
    ( p_saved_search_criteria_id       => p_saved_search_criteria_id
     ,p_object_version_number         => p_object_version_number
    );
  --
  -- Call After Process User Hook
  --
  begin
    irc_saved_search_criteria_bk3.delete_search_criteria_a
      (p_vacancy_id		       => p_vacancy_id
      ,p_saved_search_criteria_id      => p_saved_search_criteria_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_search_criteria'
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
    rollback to delete_search_criteria;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_search_criteria;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_search_criteria;
--
end irc_saved_search_criteria_api;

/
