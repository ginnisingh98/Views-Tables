--------------------------------------------------------
--  DDL for Package Body PER_SOLUTION_CMPT_NAME_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SOLUTION_CMPT_NAME_API" as
/* $Header: pescnapi.pkb 115.2 2003/01/04 00:35:41 ndorai noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'PER_SOLUTION_CMPT_NAME_API.';
--
-- ----------------------------------------------------------------------------
-- |---------------------< CREATE_SOLUTION_CMPT_NAME >------------------------|
-- ----------------------------------------------------------------------------
--
--
procedure create_solution_cmpt_name
  (p_validate                      in     boolean   default false
  ,p_solution_id                   in     number
  ,p_component_name                in     varchar2
  ,p_solution_type_name            in     varchar2
  ,p_name                          in     varchar2  default null
  ,p_template_file                 in     varchar2
  ,p_object_version_number            out nocopy number
  ) is
--
begin
  create_solution_cmpt_name
    (p_validate              => p_validate
    ,p_solution_id           => p_solution_id
    ,p_component_name        => p_component_name
    ,p_solution_type_name    => p_solution_type_name
    ,p_name                  => p_name
    ,p_object_version_number => p_object_version_number
    );
end create_solution_cmpt_name;
--
--
procedure create_solution_cmpt_name
  (p_validate                      in     boolean  default false
  ,p_solution_id                   in     number
  ,p_component_name                in     varchar2
  ,p_solution_type_name            in     varchar2
  ,p_name                          in     varchar2   default null
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'CREATE_SOLUTION_CMPT_NAME';
  l_effective_date      date;
  l_solution_id         PER_SOLUTION_CMPT_NAMES.SOLUTION_ID%TYPE;
  l_component_name      PER_SOLUTION_CMPT_NAMES.COMPONENT_NAME%TYPE;
  l_solution_type_name  PER_SOLUTION_CMPT_NAMES.SOLUTION_TYPE_NAME%TYPE;
  l_object_version_number PER_SOLUTION_CMPT_NAMES.OBJECT_VERSION_NUMBER%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  savepoint CREATE_SOLUTION_CMPT_NAME;
  --
  -- Register user key values
  --
  per_scn_ins.set_base_key_value
    (p_solution_id               => p_solution_id
    ,p_component_name            => p_component_name
    ,p_solution_type_name        => p_solution_type_name
    );
  --
  -- Truncate the time portion from all IN date parameters
  --
  -- Call Before Process User Hook
  --
  begin
    PER_SOLUTION_CMPT_NAME_BK1.CREATE_SOLUTION_CMPT_NAME_b
    (p_solution_id               => p_solution_id
    ,p_component_name            => p_component_name
    ,p_solution_type_name        => p_solution_type_name
    ,p_name                      => p_name
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_SOLUTION_CMPT_NAME_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  --
  per_scn_ins.ins
    (p_solution_id               => l_solution_id
    ,p_component_name            => l_component_name
    ,p_solution_type_name        => l_solution_type_name
    ,p_name                      => p_name
    ,p_object_version_number     => l_object_version_number
  );
  --
  -- Call After Process User Hook
  --
  begin
    PER_SOLUTION_CMPT_NAME_BK1.CREATE_SOLUTION_CMPT_NAME_a
      (p_solution_id               => p_solution_id
      ,p_component_name            => p_component_name
      ,p_solution_type_name        => p_solution_type_name
      ,p_name                      => p_name
      ,p_object_version_number     => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_SOLUTION_CMPT_NAME_a'
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
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_SOLUTION_CMPT_NAME;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
--
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_SOLUTION_CMPT_NAME;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end CREATE_SOLUTION_CMPT_NAME;
--


-- ----------------------------------------------------------------------------
-- |--------------------< UPDATE_SOLUTION_CMPT_NAME >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_solution_cmpt_name
  (p_validate                      in     boolean  default false
  ,p_solution_id                   in     number
  ,p_component_name                in     varchar2
  ,p_solution_type_name            in     varchar2
  ,p_name                          in     varchar2   default hr_api.g_varchar2
  ,p_template_file                 in     varchar2
  ,p_object_version_number         in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                 varchar2(72) := g_package||'UPDATE_SOLUTION_CMPT_NAME';
  l_effective_date       date;
  l_object_version_number PER_SOLUTION_CMPT_NAMES.OBJECT_VERSION_NUMBER%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  savepoint UPDATE_SOLUTION_CMPT_NAME;
  --
  -- Store initial value for OVN in out parameter.
  --
  l_object_version_number := p_object_version_number;
  --
  -- Truncate the time portion from all IN date parameters
  --
  -- Call Before Process User Hook
  --
  begin
    PER_SOLUTION_CMPT_NAME_BK2.UPDATE_SOLUTION_CMPT_NAME_b
      (p_object_version_number     => p_object_version_number
      ,p_solution_id               => p_solution_id
      ,p_component_name            => p_component_name
      ,p_solution_type_name        => p_solution_type_name
      ,p_name                      => p_name
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_SOLUTION_CMPT_NAME_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  --
  per_scn_upd.upd
      (p_object_version_number     => l_object_version_number
      ,p_solution_id               => p_solution_id
      ,p_component_name            => p_component_name
      ,p_solution_type_name        => p_solution_type_name
      ,p_name                      => p_name
      );
  --
  -- Call After Process User Hook
  --
  begin
    PER_SOLUTION_CMPT_NAME_BK2.UPDATE_SOLUTION_CMPT_NAME_a
      (p_object_version_number     => p_object_version_number
      ,p_solution_id               => p_solution_id
      ,p_component_name            => p_component_name
      ,p_solution_type_name        => p_solution_type_name
      ,p_name                      => p_name
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_SOLUTION_CMPT_NAME_a'
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
  --
  -- Set all output arguments
  --
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_SOLUTION_CMPT_NAME;
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
    rollback to UPDATE_SOLUTION_CMPT_NAME;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end UPDATE_SOLUTION_CMPT_NAME;


-- ----------------------------------------------------------------------------
-- |--------------------< DELETE_SOLUTION_CMPT_NAME >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_solution_cmpt_name
  (p_validate                      in     boolean  default false
  ,p_solution_id                   in     number
  ,p_component_name                in     varchar2
  ,p_solution_type_name            in     varchar2
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'DELETE_SOLUTION_CMPT_NAME';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  savepoint DELETE_SOLUTION_CMPT_NAME;
  --
  -- Call Before Process User Hook
  --
  begin
    PER_SOLUTION_CMPT_NAME_BK3.DELETE_SOLUTION_CMPT_NAME_b
    (p_solution_id        => p_solution_id
    ,p_component_name     => p_component_name
    ,p_solution_type_name => p_solution_type_name
    ,p_object_version_number => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_SOLUTION_CMPT_NAME_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  per_scn_del.del
    (p_solution_id        => p_solution_id
    ,p_component_name     => p_component_name
    ,p_solution_type_name => p_solution_type_name
    ,p_object_version_number => p_object_version_number
  );
  --
  begin
    PER_SOLUTION_CMPT_NAME_BK3.DELETE_SOLUTION_CMPT_NAME_a
      (p_solution_id            => p_solution_id
      ,p_component_name         => p_component_name
      ,p_solution_type_name     => p_solution_type_name
      ,p_object_version_number  => p_object_version_number
       );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name => 'DELETE_SOLUTION_CMPT_NAME_a'
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
    rollback to DELETE_SOLUTION_CMPT_NAME;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
   rollback to DELETE_SOLUTION_CMPT_NAME;
   --
   hr_utility.set_location(' Leaving:'||l_proc, 90);
   --
   raise;
   --
end DELETE_SOLUTION_CMPT_NAME;

--
end per_solution_cmpt_name_api;

/
