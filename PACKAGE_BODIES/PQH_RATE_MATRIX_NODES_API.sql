--------------------------------------------------------
--  DDL for Package Body PQH_RATE_MATRIX_NODES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RATE_MATRIX_NODES_API" as
/* $Header: pqrmnapi.pkb 120.1 2005/07/13 04:52:50 srenukun noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'PQH_RATE_MATRIX_NODES_API.';
--
-- ----------------------------------------------------------------------------
-- |------------------------<create_rate_matrix_node >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_rate_matrix_node
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_rate_matrix_node_id            out nocopy   number
  ,p_short_code                     in   varchar2
  ,p_pl_id                          in   number
  ,p_level_number                   in   number
  ,p_criteria_short_code            in   varchar2 default null
  ,p_node_name                      in   varchar2
  ,p_parent_node_id                 in   number   default null
  ,p_eligy_prfl_id                  in   number   default null
  ,p_business_group_id              in   number   default null
  ,p_legislation_code               in   varchar2 default null
  ,p_object_version_number          out nocopy number
  )is
  --
  -- Declare cursors and local variables
  --
  l_effective_date      date;
  l_rate_matrix_node_id  PQH_RATE_MATRIX_NODES.rate_matrix_node_id%TYPE;
  l_object_version_number PQH_RATE_MATRIX_NODES.object_version_number%TYPE;
  l_proc                varchar2(72) := g_package||'create_rate_matrix_node';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_rate_matrix_node;
  --
  -- Remember IN OUT parameter IN values
  --

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
   PQH_RATE_MATRIX_NODES_BK1.create_rate_matrix_node_b
  (p_effective_date               => l_effective_date
  ,p_short_code                     => p_short_code
  ,p_pl_id                          => p_pl_id
  ,p_level_number                   => p_level_number
  ,p_criteria_short_code            => p_criteria_short_code
  ,p_node_name                      => p_node_name
  ,p_parent_node_id                 => p_parent_node_id
  ,p_eligy_prfl_id                  => p_eligy_prfl_id
  ,p_business_group_id              => p_business_group_id
  ,p_legislation_code               => p_legislation_code
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_rate_matrix_node'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
PQH_RMN_INS.ins
  (p_short_code                     => p_short_code
  ,p_level_number                   => p_level_number
  ,p_criteria_short_code            => p_criteria_short_code
  ,p_node_name                      => p_node_name
  ,p_pl_id                          => p_pl_id
  ,p_parent_node_id                 => p_parent_node_id
  ,p_eligy_prfl_id                  => p_eligy_prfl_id
  ,p_business_group_id              => p_business_group_id
  ,p_legislation_code               => p_legislation_code
  ,p_rate_matrix_node_id            => l_rate_matrix_node_id
  ,p_object_version_number          => l_object_version_number
  );


  --
  -- Call After Process User Hook
  --
  begin
    PQH_RATE_MATRIX_NODES_BK1.create_rate_matrix_node_a
  (p_effective_date               => l_effective_date
  ,p_rate_matrix_node_id            =>l_rate_matrix_node_id
  ,p_short_code                     => p_short_code
  ,p_pl_id                          => p_pl_id
  ,p_level_number                   => p_level_number
  ,p_criteria_short_code            => p_criteria_short_code
  ,p_node_name                      => p_node_name
  ,p_parent_node_id                 => p_parent_node_id
  ,p_eligy_prfl_id                  => p_eligy_prfl_id
  ,p_business_group_id              => p_business_group_id
  ,p_legislation_code               => p_legislation_code
  ,p_object_version_number          => l_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_rate_matrix_node'
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
	p_rate_matrix_node_id := l_rate_matrix_node_id;
	p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_rate_matrix_node;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
	p_rate_matrix_node_id := null;
	p_object_version_number := null;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_rate_matrix_node;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
	p_rate_matrix_node_id := null;
	p_object_version_number := null;

	hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_rate_matrix_node;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_rate_matrix_node >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_rate_matrix_node
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_rate_matrix_node_id            in   number
  ,p_short_code                     in   varchar2
  ,p_pl_id                          in   number
  ,p_level_number                   in   number
  ,p_criteria_short_code            in   varchar2 default null
  ,p_node_name                      in   varchar2
  ,p_parent_node_id                 in   number   default null
  ,p_eligy_prfl_id                  in   number   default null
  ,p_business_group_id              in   number   default null
  ,p_legislation_code               in   varchar2 default null
  ,p_object_version_number          in   out nocopy number
  )is
  --
  -- Declare cursors and local variables
  --
  l_effective_date      date;
  l_proc                varchar2(72) := g_package||'update_rate_matrix_node';
  l_object_version_number PQH_RATE_MATRIX_NODES.object_version_number%TYPE;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_rate_matrix_node;
  --
  -- Remember IN OUT parameter IN values
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
    PQH_RATE_MATRIX_NODES_BK2.update_rate_matrix_node_b
  (p_effective_date               =>  l_effective_date
  ,p_rate_matrix_node_id            => p_rate_matrix_node_id
  ,p_short_code                     => p_short_code
  ,p_pl_id                          => p_pl_id
  ,p_level_number                   => p_level_number
  ,p_criteria_short_code            => p_criteria_short_code
  ,p_node_name                      => p_node_name
  ,p_parent_node_id                 => p_parent_node_id
  ,p_eligy_prfl_id                  => p_eligy_prfl_id
  ,p_business_group_id              => p_business_group_id
  ,p_legislation_code               => p_legislation_code
  ,p_object_version_number          => l_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_rate_matrix_node'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
PQH_RMN_UPD.upd
  (p_rate_matrix_node_id            => p_rate_matrix_node_id
  ,p_object_version_number          => l_object_version_number
  ,p_short_code                     => p_short_code
  ,p_level_number                   => p_level_number
  ,p_criteria_short_code            => p_criteria_short_code
  ,p_node_name                      => p_node_name
  ,p_pl_id                          => p_pl_id
  ,p_parent_node_id                 => p_parent_node_id
  ,p_eligy_prfl_id                  => p_eligy_prfl_id
  ,p_business_group_id              => p_business_group_id
  ,p_legislation_code               => p_legislation_code
  );

  --
  -- Call After Process User Hook
  --
  begin
    PQH_RATE_MATRIX_NODES_BK2.update_rate_matrix_node_a
  (p_effective_date               =>  l_effective_date
  ,p_rate_matrix_node_id            => p_rate_matrix_node_id
  ,p_short_code                     => p_short_code
  ,p_pl_id                          => p_pl_id
  ,p_level_number                   => p_level_number
  ,p_criteria_short_code            => p_criteria_short_code
  ,p_node_name                      => p_node_name
  ,p_parent_node_id                 => p_parent_node_id
  ,p_eligy_prfl_id                  => p_eligy_prfl_id
  ,p_business_group_id              => p_business_group_id
  ,p_legislation_code               => p_legislation_code
  ,p_object_version_number          => l_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_rate_matrix_node'
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
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_rate_matrix_node;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
      p_object_version_number  := p_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_rate_matrix_node;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
  p_object_version_number  := p_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_rate_matrix_node;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_rate_matrix_node >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_rate_matrix_node
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_rate_matrix_node_id           in 		number
  ,p_object_version_number         in 		number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_effective_date      date;
  l_proc                varchar2(72) := g_package||'delete_rate_matrix_node';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_rate_matrix_node;
  --
  -- Remember IN OUT parameter IN values
  --

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
    PQH_RATE_MATRIX_NODES_BK3.delete_rate_matrix_node_b
      (p_effective_date                => l_effective_date
	  ,p_rate_matrix_node_id           => p_rate_matrix_node_id
	  ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_rate_matrix_node'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
    PQH_RMN_DEL.del
  (p_rate_matrix_node_id                  =>p_rate_matrix_node_id
  ,p_object_version_number                =>p_object_version_number
  );


  --
  -- Call After Process User Hook
  --
  begin
    PQH_RATE_MATRIX_NODES_BK3.delete_rate_matrix_node_a
      (p_effective_date                => l_effective_date
	  ,p_rate_matrix_node_id           => p_rate_matrix_node_id
	  ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_rate_matrix_node'
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
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_rate_matrix_node;
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
    rollback to delete_rate_matrix_node;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_rate_matrix_node;
--
--
end PQH_RATE_MATRIX_NODES_API;

/
