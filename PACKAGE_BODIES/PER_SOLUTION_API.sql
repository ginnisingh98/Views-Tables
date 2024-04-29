--------------------------------------------------------
--  DDL for Package Body PER_SOLUTION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SOLUTION_API" as
/* $Header: pesolapi.pkb 115.2 2003/01/04 00:38:04 ndorai noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'PER_SOLUTION_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< CREATE_SOLUTION >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_solution
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_solution_name                 in     varchar2
  ,p_solution_type_name            in     varchar2
  ,p_description                   in     varchar2   default null
  ,p_link_to_full_description      in     varchar2   default null
  ,p_vertical                      in     varchar2   default null
  ,p_legislation_code              in     varchar2   default null
  ,p_user_id                       in     varchar2   default null
  ,p_solution_id                      out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'CREATE_SOLUTION';
  l_effective_date      date;
  l_solution_id         PER_SOLUTIONS.SOLUTION_ID%TYPE;
  l_object_version_number PER_SOLUTIONS.OBJECT_VERSION_NUMBER%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  savepoint CREATE_SOLUTION;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
    PER_SOLUTION_BK1.CREATE_SOLUTION_b
    (p_effective_date            => l_effective_date
    ,p_solution_name             => p_solution_name
    ,p_solution_type_name        => p_solution_type_name
    ,p_description               => p_description
    ,p_link_to_full_description  => p_link_to_full_description
    ,p_vertical                  => p_vertical
    ,p_legislation_code          => p_legislation_code
    ,p_user_id                   => p_user_id
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_SOLUTION_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  --
  per_sol_ins.ins
    (p_effective_date            => p_effective_date
    ,p_solution_name             => p_solution_name
    ,p_solution_type_name        => p_solution_type_name
    ,p_description               => p_description
    ,p_link_to_full_description  => p_link_to_full_description
    ,p_vertical                  => p_vertical
    ,p_legislation_code          => p_legislation_code
    ,p_user_id                   => p_user_id
    ,p_solution_id               => l_solution_id
    ,p_object_version_number     => l_object_version_number
  );
  --
  -- Call After Process User Hook
  --
  begin
    PER_SOLUTION_BK1.CREATE_SOLUTION_a
      (p_effective_date            => l_effective_date
      ,p_solution_name             => p_solution_name
      ,p_solution_type_name        => p_solution_type_name
      ,p_description               => p_description
      ,p_link_to_full_description  => p_link_to_full_description
      ,p_vertical                  => p_vertical
      ,p_legislation_code          => p_legislation_code
      ,p_user_id                   => p_user_id
      ,p_solution_id               => p_solution_id
      ,p_object_version_number     => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_SOLUTION_a'
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
  p_solution_id            := l_solution_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_SOLUTION;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_solution_id           := null;
    p_object_version_number  := null;
--
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_SOLUTION;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end CREATE_SOLUTION;
--


-- ----------------------------------------------------------------------------
-- |--------------------------< UPDATE_SOLUTION >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_solution
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_solution_id                   in     number
  ,p_solution_name                 in     varchar2
  ,p_solution_type_name            in     varchar2
  ,p_description                   in     varchar2   default hr_api.g_varchar2
  ,p_link_to_full_description      in     varchar2   default hr_api.g_varchar2
  ,p_vertical                      in     varchar2   default hr_api.g_varchar2
  ,p_legislation_code              in     varchar2   default hr_api.g_varchar2
  ,p_user_id                       in     varchar2   default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'UPDATE_SOLUTION';
  l_effective_date        date;
  l_solution_id           PER_SOLUTIONS.SOLUTION_ID%TYPE;
  l_object_version_number PER_SOLUTIONS.OBJECT_VERSION_NUMBER%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  savepoint UPDATE_SOLUTION;
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
    PER_SOLUTION_BK2.UPDATE_SOLUTION_b
      (p_effective_date            => l_effective_date
      ,p_solution_id               => p_solution_id
      ,p_object_version_number     => p_object_version_number
      ,p_solution_name             => p_solution_name
      ,p_solution_type_name        => p_solution_type_name
      ,p_description               => p_description
      ,p_link_to_full_description  => p_link_to_full_description
      ,p_vertical                  => p_vertical
      ,p_legislation_code          => p_legislation_code
      ,p_user_id                   => p_user_id
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_SOLUTION_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  --
  per_sol_upd.upd(
       p_effective_date            => l_effective_date
      ,p_solution_id               => p_solution_id
      ,p_object_version_number     => l_object_version_number
      ,p_solution_name             => p_solution_name
      ,p_solution_type_name        => p_solution_type_name
      ,p_description               => p_description
      ,p_link_to_full_description  => p_link_to_full_description
      ,p_vertical                  => p_vertical
      ,p_legislation_code          => p_legislation_code
      ,p_user_id                   => p_user_id
  );
  --
  -- Call After Process User Hook
  --
  begin
    PER_SOLUTION_BK2.UPDATE_SOLUTION_a
      (p_effective_date            => l_effective_date
      ,p_solution_id               => p_solution_id
      ,p_object_version_number     => p_object_version_number
      ,p_solution_name             => p_solution_name
      ,p_solution_type_name        => p_solution_type_name
      ,p_description               => p_description
      ,p_link_to_full_description  => p_link_to_full_description
      ,p_vertical                  => p_vertical
      ,p_legislation_code          => p_legislation_code
      ,p_user_id                   => p_user_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_SOLUTION_a'
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
    rollback to UPDATE_SOLUTION;
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
    rollback to UPDATE_SOLUTION;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end UPDATE_SOLUTION;


-- ----------------------------------------------------------------------------
-- |--------------------------< DELETE_SOLUTION >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_solution
  (p_validate                      in     boolean  default false
  ,p_solution_id                   in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'DELETE_SOLUTION';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  savepoint DELETE_SOLUTION;
  --
  -- Call Before Process User Hook
  --
  begin
    PER_SOLUTION_BK3.DELETE_SOLUTION_b
    (p_solution_id              => p_solution_id
    ,p_object_version_number    => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_SOLUTION_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  per_sol_del.del
   (p_solution_id                       => p_solution_id
   ,p_object_version_number             => p_object_version_number
  );
  --
  begin
    PER_SOLUTION_BK3.DELETE_SOLUTION_a
      (p_solution_id              => p_solution_id
      ,p_object_version_number    => p_object_version_number
       );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name => 'DELETE_SOLUTION_a'
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
    rollback to DELETE_SOLUTION;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
   rollback to DELETE_SOLUTION;
   --
   hr_utility.set_location(' Leaving:'||l_proc, 90);
   --
   raise;
   --
end DELETE_SOLUTION;

--
end per_solution_api;

/
