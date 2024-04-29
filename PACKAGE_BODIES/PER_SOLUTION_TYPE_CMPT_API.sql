--------------------------------------------------------
--  DDL for Package Body PER_SOLUTION_TYPE_CMPT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SOLUTION_TYPE_CMPT_API" as
/* $Header: pestcapi.pkb 120.0 2005/05/31 21:56:50 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'PER_SOLUTION_TYPE_CMPT_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------< CREATE_SOLUTION_TYPE_CMPT >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_solution_type_cmpt
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_component_name                in     varchar2
  ,p_solution_type_name            in     varchar2
  ,p_legislation_code              in     varchar2
  ,p_api_name                      in     varchar2  default null
  ,p_parent_component_name         in     varchar2  default null
  ,p_updateable                    in     varchar2  default null
  ,p_extensible                    in     varchar2  default null
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'CREATE_SOLUTION_TYPE_CMPT';
  l_effective_date      date;
  l_component_name      PER_SOLUTION_TYPE_CMPTS.COMPONENT_NAME%TYPE;
  l_solution_type_name  PER_SOLUTION_TYPE_CMPTS.SOLUTION_TYPE_NAME%TYPE;
  l_legislation_code    PER_SOLUTION_TYPE_CMPTS.LEGISLATION_CODE%TYPE;
  l_object_version_number PER_SOLUTION_TYPE_CMPTS.OBJECT_VERSION_NUMBER%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  savepoint CREATE_SOLUTION_TYPE_CMPT;
  --
  -- Register user key values
  --
  per_stc_ins.set_base_key_value
    (p_component_name     => p_component_name
    ,p_solution_type_name => p_solution_type_name
    ,p_legislation_code   => p_legislation_code
    );
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
    PER_SOLUTION_TYPE_CMPT_BK1.CREATE_SOLUTION_TYPE_CMPT_b
    (p_effective_date            => l_effective_date
    ,p_component_name            => p_component_name
    ,p_solution_type_name        => p_solution_type_name
    ,p_legislation_code          => p_legislation_code
    ,p_api_name                  => p_api_name
    ,p_parent_component_name     => p_parent_component_name
    ,p_updateable                => p_updateable
    ,p_extensible                => p_extensible
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_SOLUTION_TYPE_CMPT_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  --
  per_stc_ins.ins
    (p_effective_date            => l_effective_date
    ,p_component_name            => l_component_name
    ,p_solution_type_name        => l_solution_type_name
    ,p_legislation_code          => l_legislation_code
    ,p_api_name                  => p_api_name
    ,p_parent_component_name     => p_parent_component_name
    ,p_updateable                => p_updateable
    ,p_extensible                => p_extensible
    ,p_object_version_number     => l_object_version_number
  );
  --
  -- Call After Process User Hook
  --
  begin
    PER_SOLUTION_TYPE_CMPT_BK1.CREATE_SOLUTION_TYPE_CMPT_a
      (p_effective_date            => l_effective_date
      ,p_component_name            => p_component_name
      ,p_solution_type_name        => p_solution_type_name
      ,p_legislation_code          => p_legislation_code
      ,p_api_name                  => p_api_name
      ,p_parent_component_name     => p_parent_component_name
      ,p_updateable                => p_updateable
      ,p_extensible                => p_extensible
      ,p_object_version_number     => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_SOLUTION_TYPE_CMPT_a'
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
    rollback to CREATE_SOLUTION_TYPE_CMPT;
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
    rollback to CREATE_SOLUTION_TYPE_CMPT;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end CREATE_SOLUTION_TYPE_CMPT;
--


-- ----------------------------------------------------------------------------
-- |--------------------< UPDATE_SOLUTION_TYPE_CMPT >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_solution_type_cmpt
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_component_name                in     varchar2
  ,p_solution_type_name            in     varchar2
  ,p_legislation_code              in     varchar2
  ,p_api_name                      in     varchar2  default hr_api.g_varchar2
  ,p_parent_component_name         in     varchar2  default hr_api.g_varchar2
  ,p_updateable                    in     varchar2  default hr_api.g_varchar2
  ,p_extensible                    in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'UPDATE_SOLUTION_TYPE_CMPT';
  l_effective_date        date;
  l_object_version_number PER_SOLUTION_TYPE_CMPTS.OBJECT_VERSION_NUMBER%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  savepoint UPDATE_SOLUTION_TYPE_CMPT;
  --
  -- Store initial value for OVN in out parameter.
  --
  l_object_version_number := p_object_version_number;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
    PER_SOLUTION_TYPE_CMPT_BK2.UPDATE_SOLUTION_TYPE_CMPT_b
      (p_effective_date            => l_effective_date
      ,p_object_version_number     => p_object_version_number
      ,p_component_name            => p_component_name
      ,p_solution_type_name        => p_solution_type_name
      ,p_legislation_code          => p_legislation_code
      ,p_api_name                  => p_api_name
      ,p_parent_component_name     => p_parent_component_name
      ,p_updateable                => p_updateable
      ,p_extensible                => p_extensible
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_SOLUTION_TYPE_CMPT_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  --
  per_stc_upd.upd(
       p_effective_date            => l_effective_date
      ,p_object_version_number     => l_object_version_number
      ,p_component_name            => p_component_name
      ,p_solution_type_name        => p_solution_type_name
      ,p_legislation_code          => p_legislation_code
      ,p_api_name                  => p_api_name
      ,p_parent_component_name     => p_parent_component_name
      ,p_updateable                => p_updateable
      ,p_extensible                => p_extensible
  );
  --
  -- Call After Process User Hook
  --
  begin
    PER_SOLUTION_TYPE_CMPT_BK2.UPDATE_SOLUTION_TYPE_CMPT_a
      (p_effective_date            => l_effective_date
      ,p_object_version_number     => p_object_version_number
      ,p_component_name            => p_component_name
      ,p_solution_type_name        => p_solution_type_name
      ,p_legislation_code          => p_legislation_code
      ,p_api_name                  => p_api_name
      ,p_parent_component_name     => p_parent_component_name
      ,p_updateable                => p_updateable
      ,p_extensible                => p_extensible
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_SOLUTION_TYPE_CMPT_a'
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
    rollback to UPDATE_SOLUTION_TYPE_CMPT;
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
    rollback to UPDATE_SOLUTION_TYPE_CMPT;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end UPDATE_SOLUTION_TYPE_CMPT;


-- ----------------------------------------------------------------------------
-- |--------------------< DELETE_SOLUTION_TYPE_CMPT >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_solution_type_cmpt
  (p_validate                      in     boolean  default false
  ,p_component_name                in     varchar2
  ,p_solution_type_name            in     varchar2
  ,p_legislation_code              in     varchar2
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'DELETE_SOLUTION_TYPE_CMPT';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  savepoint DELETE_SOLUTION_TYPE_CMPT;
  --
  -- Call Before Process User Hook
  --
  begin
    PER_SOLUTION_TYPE_CMPT_BK3.DELETE_SOLUTION_TYPE_CMPT_b
    (p_component_name           => p_component_name
    ,p_solution_type_name       => p_solution_type_name
    ,p_legislation_code         => p_legislation_code
    ,p_object_version_number    => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_SOLUTION_TYPE_CMPT_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  per_stc_del.del
   (p_component_name                    => p_component_name
   ,p_solution_type_name                => p_solution_type_name
   ,p_legislation_code                  => p_legislation_code
   ,p_object_version_number             => p_object_version_number
  );
  --
  begin
    PER_SOLUTION_TYPE_CMPT_BK3.DELETE_SOLUTION_TYPE_CMPT_a
      (p_component_name           => p_component_name
      ,p_solution_type_name       => p_solution_type_name
      ,p_legislation_code         => p_legislation_code
      ,p_object_version_number    => p_object_version_number
       );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name => 'DELETE_SOLUTION_TYPE_CMPT_a'
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
    rollback to DELETE_SOLUTION_TYPE_CMPT;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
   rollback to DELETE_SOLUTION_TYPE_CMPT;
   --
   hr_utility.set_location(' Leaving:'||l_proc, 90);
   --
   raise;
   --
end DELETE_SOLUTION_TYPE_CMPT;

--
end per_solution_type_cmpt_api;

/
