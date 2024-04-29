--------------------------------------------------------
--  DDL for Package Body IRC_LOCATION_CRITERIA_VAL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_LOCATION_CRITERIA_VAL_API" as
/* $Header: irlcvapi.pkb 120.0 2005/10/03 14:58:42 rbanda noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  IRC_LOCATION_CRITERIA_VAL_API.';
--
-- ----------------------------------------------------------------------------
-- |-------------------< CREATE_LOCATION_CRITERIA >---------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_LOCATION_CRITERIA
  (p_validate                      in     boolean  default false
  ,p_search_criteria_id            in     number
  ,p_derived_locale                in     varchar2
  ,p_location_criteria_value_id       out nocopy   number
  ,p_object_version_number            out nocopy   number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'CREATE_LOCATION_CRITERIA';
  l_object_version_number irc_location_criteria_values.object_version_number%TYPE;
  l_location_criteria_value_id irc_location_criteria_values.location_criteria_value_id%TYPE;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_LOCATION_CRITERIA;
  --
  -- Call Before Process User Hook
  --
  begin
    IRC_LOCATION_CRITERIA_VAL_BK1.CREATE_LOCATION_CRITERIA_B
      (p_search_criteria_id            => p_search_criteria_id
      ,p_derived_locale                => p_derived_locale
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_LOCATION_CRITERIA'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  irc_lcv_ins.ins
    (p_search_criteria_id            => p_search_criteria_id
    ,p_derived_locale                => p_derived_locale
    ,p_location_criteria_value_id    => l_location_criteria_value_id
    ,p_object_version_number         => l_object_version_number
    );
  --
  -- Call After Process User Hook
  --
  begin
    IRC_LOCATION_CRITERIA_VAL_BK1.CREATE_LOCATION_CRITERIA_A
      (p_location_criteria_value_id    => l_location_criteria_value_id
      ,p_search_criteria_id            => p_search_criteria_id
      ,p_derived_locale                => p_derived_locale
      ,p_object_version_number         => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_LOCATION_CRITERIA'
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
  p_location_criteria_value_id  := l_location_criteria_value_id;
  p_object_version_number       := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_LOCATION_CRITERIA;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_location_criteria_value_id  := null;
    p_object_version_number       := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_LOCATION_CRITERIA;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_location_criteria_value_id  := null;
    p_object_version_number       := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end CREATE_LOCATION_CRITERIA;
--
-- ----------------------------------------------------------------------------
-- |-----------------< DELETE_LOCATION_CRITERIA >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_LOCATION_CRITERIA
  (p_validate                      in     boolean  default false
  ,p_location_criteria_value_id    in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'DELETE_LOCATION_CRITERIA';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_LOCATION_CRITERIA;
  --
  -- Call Before Process User Hook
  --
  begin
    IRC_LOCATION_CRITERIA_VAL_BK2.DELETE_LOCATION_CRITERIA_B
      (p_location_criteria_value_id    => p_location_criteria_value_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_LOCATION_CRITERIA'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  irc_lcv_del.del
    (p_location_criteria_value_id    => p_location_criteria_value_id
    ,p_object_version_number         => p_object_version_number
    );
  --
  -- Call After Process User Hook
  --
  begin
    IRC_LOCATION_CRITERIA_VAL_BK2.DELETE_LOCATION_CRITERIA_A
      (p_location_criteria_value_id    => p_location_criteria_value_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_LOCATION_CRITERIA'
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
    rollback to DELETE_LOCATION_CRITERIA;
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
    rollback to DELETE_LOCATION_CRITERIA;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end DELETE_LOCATION_CRITERIA;
--
end IRC_LOCATION_CRITERIA_VAL_API;

/
