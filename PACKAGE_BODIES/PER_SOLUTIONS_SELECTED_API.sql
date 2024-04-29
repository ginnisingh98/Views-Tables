--------------------------------------------------------
--  DDL for Package Body PER_SOLUTIONS_SELECTED_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SOLUTIONS_SELECTED_API" as
/* $Header: pesosapi.pkb 115.2 2003/01/04 00:38:14 ndorai noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'PER_SOLUTIONS_SELECTED_API.';
--
-- ----------------------------------------------------------------------------
-- |---------------------< CREATE_SOLUTIONS_SELECTED >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_solutions_selected
  (p_validate                      in     boolean  default false
  ,p_solution_id                   in     number
  ,p_solution_set_name             in     varchar2
  ,p_user_id                       in     number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'CREATE_SOLUTIONS_SELECTED';
  l_effective_date      date;
  l_solution_id         PER_SOLUTIONS_SELECTED.SOLUTION_ID%TYPE;
  l_solution_set_name   PER_SOLUTIONS_SELECTED.SOLUTION_SET_NAME%TYPE;
  l_user_id             PER_SOLUTIONS_SELECTED.USER_ID%TYPE;
  l_object_version_number PER_SOLUTIONS_SELECTED.OBJECT_VERSION_NUMBER%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  savepoint CREATE_SOLUTIONS_SELECTED;
  --
  -- Register user key values
  --
  per_sos_ins.set_base_key_value
    (p_solution_id       => p_solution_id
    ,p_solution_set_name => p_solution_set_name
    ,p_user_id           => p_user_id
    );
  --
  -- Truncate the time portion from all IN date parameters
  --
  -- Call Before Process User Hook
  --
  begin
    PER_SOLUTIONS_SELECTED_BK1.CREATE_SOLUTIONS_SELECTED_b
    (p_solution_id               => p_solution_id
    ,p_solution_set_name         => p_solution_set_name
    ,p_user_id                   => p_user_id
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_SOLUTIONS_SELECTED_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  --
  per_sos_ins.ins
    (p_solution_id               => l_solution_id
    ,p_solution_set_name         => l_solution_set_name
    ,p_user_id                   => l_user_id
    ,p_object_version_number     => l_object_version_number
  );
  --
  -- Call After Process User Hook
  --
  begin
    PER_SOLUTIONS_SELECTED_BK1.CREATE_SOLUTIONS_SELECTED_a
      (p_solution_id               => p_solution_id
      ,p_solution_set_name         => p_solution_set_name
      ,p_user_id                   => p_user_id
      ,p_object_version_number     => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_SOLUTIONS_SELECTED_a'
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
    rollback to CREATE_SOLUTIONS_SELECTED;
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
    rollback to CREATE_SOLUTIONS_SELECTED;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end CREATE_SOLUTIONS_SELECTED;
--


-- ----------------------------------------------------------------------------
-- |--------------------< UPDATE_SOLUTIONS_SELECTED >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_solutions_selected
  (p_validate                      in     boolean  default false
  ,p_solution_id                   in     number
  ,p_solution_set_name             in     varchar2
  ,p_user_id                       in     number
  ,p_object_version_number         in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'UPDATE_SOLUTIONS_SELECTED';
  l_effective_date        date;
  l_object_version_number PER_SOLUTIONS_SELECTED.OBJECT_VERSION_NUMBER%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  savepoint UPDATE_SOLUTIONS_SELECTED;
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
    PER_SOLUTIONS_SELECTED_BK2.UPDATE_SOLUTIONS_SELECTED_b
      (p_object_version_number     => p_object_version_number
      ,p_solution_id               => p_solution_id
      ,p_solution_set_name         => p_solution_set_name
      ,p_user_id                   => p_user_id
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_SOLUTIONS_SELECTED_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  --
  per_sos_upd.upd
      (p_object_version_number     => l_object_version_number
      ,p_solution_id               => p_solution_id
      ,p_solution_set_name         => p_solution_set_name
      ,p_user_id                   => p_user_id
  );
  --
  -- Call After Process User Hook
  --
  begin
    PER_SOLUTIONS_SELECTED_BK2.UPDATE_SOLUTIONS_SELECTED_a
      (p_object_version_number     => p_object_version_number
      ,p_solution_id               => p_solution_id
      ,p_solution_set_name         => p_solution_set_name
      ,p_user_id                   => p_user_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_SOLUTIONS_SELECTED_a'
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
    rollback to UPDATE_SOLUTIONS_SELECTED;
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
    rollback to UPDATE_SOLUTIONS_SELECTED;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end UPDATE_SOLUTIONS_SELECTED;


-- ----------------------------------------------------------------------------
-- |--------------------< DELETE_SOLUTIONS_SELECTED >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_solutions_selected
  (p_validate                      in     boolean  default false
  ,p_solution_id                   in     number
  ,p_solution_set_name             in     varchar2
  ,p_user_id                       in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'DELETE_SOLUTIONS_SELECTED';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  savepoint DELETE_SOLUTIONS_SELECTED;
  --
  -- Call Before Process User Hook
  --
  begin
    PER_SOLUTIONS_SELECTED_BK3.DELETE_SOLUTIONS_SELECTED_b
    (p_solution_id              => p_solution_id
    ,p_solution_set_name        => p_solution_set_name
    ,p_user_id                  => p_user_id
    ,p_object_version_number    => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_SOLUTIONS_SELECTED_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  per_sos_del.del
   (p_solution_id               => p_solution_id
   ,p_solution_set_name         => p_solution_set_name
   ,p_user_id                   => p_user_id
   ,p_object_version_number     => p_object_version_number
  );
  --
  begin
    PER_SOLUTIONS_SELECTED_BK3.DELETE_SOLUTIONS_SELECTED_a
      (p_solution_id              => p_solution_id
      ,p_solution_set_name        => p_solution_set_name
      ,p_user_id                  => p_user_id
      ,p_object_version_number    => p_object_version_number
       );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name => 'DELETE_SOLUTIONS_SELECTED_a'
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
    rollback to DELETE_SOLUTIONS_SELECTED;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
   rollback to DELETE_SOLUTIONS_SELECTED;
   --
   hr_utility.set_location(' Leaving:'||l_proc, 90);
   --
   raise;
   --
end DELETE_SOLUTIONS_SELECTED;

--
end per_solutions_selected_api;

/
