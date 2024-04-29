--------------------------------------------------------
--  DDL for Package Body IRC_PROF_AREA_CRITERIA_VAL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_PROF_AREA_CRITERIA_VAL_API" as
/* $Header: irpcvapi.pkb 120.0 2005/10/03 14:58:56 rbanda noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  IRC_PROF_AREA_CRITERIA_VAL_API.';
--
-- ----------------------------------------------------------------------------
-- |-------------------< CREATE_PROF_AREA_CRITERIA >---------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_PROF_AREA_CRITERIA
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_search_criteria_id            in     number
  ,p_professional_area             in     varchar2
  ,p_prof_area_criteria_value_id      out nocopy   number
  ,p_object_version_number            out nocopy   number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'CREATE_PROF_AREA_CRITERIA';
  l_effective_date      date;
  l_object_version_number irc_prof_area_criteria_values.object_version_number%TYPE;
  l_prof_area_criteria_value_id irc_prof_area_criteria_values.prof_area_criteria_value_id%TYPE;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_PROF_AREA_CRITERIA;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
    IRC_PROF_AREA_CRITERIA_VAL_BK1.CREATE_PROF_AREA_CRITERIA_B
      (p_effective_date                => l_effective_date
      ,p_search_criteria_id            => p_search_criteria_id
      ,p_professional_area             => p_professional_area
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PROF_AREA_CRITERIA'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  irc_pcv_ins.ins
    (p_effective_date                => l_effective_date
    ,p_search_criteria_id            => p_search_criteria_id
    ,p_professional_area             => p_professional_area
    ,p_prof_area_criteria_value_id   => l_prof_area_criteria_value_id
    ,p_object_version_number         => l_object_version_number
    );
  --
  -- Call After Process User Hook
  --
  begin
    IRC_PROF_AREA_CRITERIA_VAL_BK1.CREATE_PROF_AREA_CRITERIA_A
      (p_effective_date                => l_effective_date
      ,p_prof_area_criteria_value_id   => l_prof_area_criteria_value_id
      ,p_search_criteria_id            => p_search_criteria_id
      ,p_professional_area             => p_professional_area
      ,p_object_version_number         => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PROF_AREA_CRITERIA'
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
  p_prof_area_criteria_value_id := l_prof_area_criteria_value_id;
  p_object_version_number       := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_PROF_AREA_CRITERIA;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_prof_area_criteria_value_id := null;
    p_object_version_number       := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_PROF_AREA_CRITERIA;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_prof_area_criteria_value_id := null;
    p_object_version_number       := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end CREATE_PROF_AREA_CRITERIA;
--
-- ----------------------------------------------------------------------------
-- |-----------------< DELETE_PROF_AREA_CRITERIA >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_PROF_AREA_CRITERIA
  (p_validate                      in     boolean  default false
  ,p_prof_area_criteria_value_id   in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'DELETE_PROF_AREA_CRITERIA';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_PROF_AREA_CRITERIA;
  --
  -- Call Before Process User Hook
  --
  begin
    IRC_PROF_AREA_CRITERIA_VAL_BK2.DELETE_PROF_AREA_CRITERIA_B
      (p_prof_area_criteria_value_id   => p_prof_area_criteria_value_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PROF_AREA_CRITERIA'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  irc_pcv_del.del
    (p_prof_area_criteria_value_id   => p_prof_area_criteria_value_id
    ,p_object_version_number         => p_object_version_number
    );
  --
  -- Call After Process User Hook
  --
  begin
    IRC_PROF_AREA_CRITERIA_VAL_BK2.DELETE_PROF_AREA_CRITERIA_A
      (p_prof_area_criteria_value_id   => p_prof_area_criteria_value_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PROF_AREA_CRITERIA'
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
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_PROF_AREA_CRITERIA;
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
    rollback to DELETE_PROF_AREA_CRITERIA;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end DELETE_PROF_AREA_CRITERIA;
--
end IRC_PROF_AREA_CRITERIA_VAL_API;

/
