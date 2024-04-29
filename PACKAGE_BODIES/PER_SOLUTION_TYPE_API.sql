--------------------------------------------------------
--  DDL for Package Body PER_SOLUTION_TYPE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SOLUTION_TYPE_API" as
/* $Header: pesltapi.pkb 115.2 2003/01/04 00:37:18 ndorai noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'PER_SOLUTION_TYPE_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< CREATE_SOLUTION_TYPE >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_solution_type
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_solution_type_name            in     varchar2
  ,p_solution_category             in     varchar2   default null
  ,p_updateable                    in     varchar2   default null
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'CREATE_SOLUTION_TYPE';
  l_effective_date      date;
  l_solution_type_name  PER_SOLUTION_TYPES.SOLUTION_TYPE_NAME%TYPE;
  l_object_version_number PER_SOLUTION_TYPES.OBJECT_VERSION_NUMBER%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  savepoint CREATE_SOLUTION_TYPE;
  --
  -- Register user key values
  --
  per_slt_ins.set_base_key_value
    (p_solution_type_name => p_solution_type_name
    );
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
    PER_SOLUTION_TYPE_BK1.CREATE_SOLUTION_TYPE_b
    (p_effective_date            => l_effective_date
    ,p_solution_type_name        => p_solution_type_name
    ,p_solution_category         => p_solution_category
    ,p_updateable                => p_updateable
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_SOLUTION_TYPE_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  --
  per_slt_ins.ins
    (p_effective_date            => l_effective_date
    ,p_solution_type_name        => l_solution_type_name
    ,p_solution_category         => p_solution_category
    ,p_updateable                => p_updateable
    ,p_object_version_number     => l_object_version_number
  );
  --
  -- Call After Process User Hook
  --
  begin
    PER_SOLUTION_TYPE_BK1.CREATE_SOLUTION_TYPE_a
      (p_effective_date            => l_effective_date
      ,p_solution_type_name        => p_solution_type_name
      ,p_solution_category         => p_solution_category
      ,p_updateable                => p_updateable
      ,p_object_version_number     => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_SOLUTION_TYPE_a'
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
    rollback to CREATE_SOLUTION_TYPE;
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
    rollback to CREATE_SOLUTION_TYPE;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end CREATE_SOLUTION_TYPE;
--


-- ----------------------------------------------------------------------------
-- |-----------------------< UPDATE_SOLUTION_TYPE >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_solution_type
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_solution_type_name            in     varchar2
  ,p_solution_category             in     varchar2   default hr_api.g_varchar2
  ,p_updateable                    in     varchar2   default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'UPDATE_SOLUTION_TYPE';
  l_effective_date        date;
  l_object_version_number PER_SOLUTION_TYPES.OBJECT_VERSION_NUMBER%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  savepoint UPDATE_SOLUTION_TYPE;
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
    PER_SOLUTION_TYPE_BK2.UPDATE_SOLUTION_TYPE_b
      (p_effective_date            => l_effective_date
      ,p_object_version_number     => p_object_version_number
      ,p_solution_type_name        => p_solution_type_name
      ,p_solution_category         => p_solution_category
      ,p_updateable                => p_updateable
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_SOLUTION_TYPE_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  --
  per_slt_upd.upd(
       p_effective_date            => l_effective_date
      ,p_object_version_number     => l_object_version_number
      ,p_solution_type_name        => p_solution_type_name
      ,p_solution_category         => p_solution_category
      ,p_updateable                => p_updateable
  );
  --
  -- Call After Process User Hook
  --
  begin
    PER_SOLUTION_TYPE_BK2.UPDATE_SOLUTION_TYPE_a
      (p_effective_date            => l_effective_date
      ,p_object_version_number     => p_object_version_number
      ,p_solution_type_name        => p_solution_type_name
      ,p_solution_category         => p_solution_category
      ,p_updateable                => p_updateable
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_SOLUTION_TYPE_a'
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
    rollback to UPDATE_SOLUTION_TYPE;
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
    rollback to UPDATE_SOLUTION_TYPE;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end UPDATE_SOLUTION_TYPE;


-- ----------------------------------------------------------------------------
-- |-----------------------< DELETE_SOLUTION_TYPE >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_solution_type
  (p_validate                      in     boolean  default false
  ,p_solution_type_name            in     varchar2
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'DELETE_SOLUTION_TYPE';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  savepoint DELETE_SOLUTION_TYPE;
  --
  -- Call Before Process User Hook
  --
  begin
    PER_SOLUTION_TYPE_BK3.DELETE_SOLUTION_TYPE_b
    (p_solution_type_name       => p_solution_type_name
    ,p_object_version_number    => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_SOLUTION_TYPE_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  per_slt_del.del
   (p_solution_type_name                => p_solution_type_name
   ,p_object_version_number             => p_object_version_number
  );
  --
  begin
    PER_SOLUTION_TYPE_BK3.DELETE_SOLUTION_TYPE_a
      (p_solution_type_name       => p_solution_type_name
      ,p_object_version_number    => p_object_version_number
       );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name => 'DELETE_SOLUTION_TYPE_a'
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
    rollback to DELETE_SOLUTION_TYPE;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
   rollback to DELETE_SOLUTION_TYPE;
   --
   hr_utility.set_location(' Leaving:'||l_proc, 90);
   --
   raise;
   --
end DELETE_SOLUTION_TYPE;

--
end per_solution_type_api;

/
