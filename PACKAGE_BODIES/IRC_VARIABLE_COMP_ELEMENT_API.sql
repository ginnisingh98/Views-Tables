--------------------------------------------------------
--  DDL for Package Body IRC_VARIABLE_COMP_ELEMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_VARIABLE_COMP_ELEMENT_API" as
/* $Header: irvceapi.pkb 120.0 2005/07/26 15:19:06 mbocutt noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  IRC_VARIABLE_COMP_ELEMENT_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------< CREATE_VARIABLE_COMPENSATION >----------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_VARIABLE_COMPENSATION
 (p_validate               in     boolean  default false
 ,p_vacancy_id             in	  number
 ,p_variable_comp_lookup   in     varchar2
 ,p_effective_date         in     date
 ,p_object_version_number    out nocopy  number
 ) is
  --
  -- Declare cursors and local variables
  --

  l_proc  varchar2(72) := g_package||'CREATE_VARIABLE_COMPENSATION';
  l_object_version_number  number;
  l_effective_date         date;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_VARIABLE_COMPENSATION;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
    IRC_VARIABLE_COMP_ELEMENT_BK1.CREATE_VARIABLE_COMPENSATION_B
      (p_vacancy_id           => p_vacancy_id
      ,p_variable_comp_lookup => p_variable_comp_lookup
      ,p_effective_date       => l_effective_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_VARIABLE_COMPENSATION'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  -- Process Logic
  --
  irc_vce_ins.ins(
   p_effective_date        =>  l_effective_date
  ,p_vacancy_id            =>  p_vacancy_id
  ,p_variable_comp_lookup  =>  p_variable_comp_lookup
  ,p_object_version_number =>  l_object_version_number
  );
  --
  -- Call After Process User Hook
  --
  begin
    IRC_VARIABLE_COMP_ELEMENT_BK1.CREATE_VARIABLE_COMPENSATION_A
      (p_vacancy_id            => p_vacancy_id
      ,p_variable_comp_lookup  => p_variable_comp_lookup
      ,p_effective_date        => l_effective_date
      ,p_object_version_number => l_object_version_number
     );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_VARIABLE_COMPENSATION'
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
     p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_VARIABLE_COMPENSATION;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    p_object_version_number := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_object_version_number := null;
    rollback to CREATE_VARIABLE_COMPENSATION;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end CREATE_VARIABLE_COMPENSATION;
--
-- ----------------------------------------------------------------------------
-- |--------------------< DELETE_VARIABLE_COMPENSATION >----------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_VARIABLE_COMPENSATION
  (p_validate              in   boolean  default false
  ,p_vacancy_id            in   number
  ,p_variable_comp_lookup  in   varchar2
  ,p_object_version_number in   number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc  varchar2(72) := g_package||'DELETE_VARIABLE_COMPENSATION';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_VARIABLE_COMPENSATION;
  --
  -- Truncate the time portion from all IN date parameters
  --
  -- Call Before Process User Hook
  --
  begin
    IRC_VARIABLE_COMP_ELEMENT_BK2.DELETE_VARIABLE_COMPENSATION_B
      (p_vacancy_id            => p_vacancy_id
      ,p_variable_comp_lookup  => p_variable_comp_lookup
      ,p_object_version_number => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_VARIABLE_COMPENSATION'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  -- Process Logic
  --
     irc_vce_del.del
       (p_vacancy_id              =>  p_vacancy_id
       ,p_variable_comp_lookup    => p_variable_comp_lookup
       ,p_object_version_number   => p_object_version_number
       );
  --
  -- Call After Process User Hook
  --
  begin
    IRC_VARIABLE_COMP_ELEMENT_BK2.DELETE_VARIABLE_COMPENSATION_A
      (p_vacancy_id               => p_vacancy_id
      ,p_variable_comp_lookup     => p_variable_comp_lookup
      ,p_object_version_number    => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_VARIABLE_COMPENSATION'
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
  -- No output Parameters.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_VARIABLE_COMPENSATION;
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
    rollback to DELETE_VARIABLE_COMPENSATION;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end DELETE_VARIABLE_COMPENSATION;
--
end IRC_VARIABLE_COMP_ELEMENT_API;

/
