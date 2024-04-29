--------------------------------------------------------
--  DDL for Package Body PQH_CRITERIA_RATE_FACTORS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_CRITERIA_RATE_FACTORS_API" as
/* $Header: pqcrfapi.pkb 120.0 2005/10/06 14:52:22 srajakum noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'PQH_CRITERIA_RATE_FACTORS_API.';
--
-- ----------------------------------------------------------------------------
-- |------------------------<create_criteria_rate_factor >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_criteria_rate_factor
  (p_validate                      in     boolean   default false
  ,p_effective_date                in     date
  ,p_criteria_rate_factor_id          out nocopy number
  ,p_criteria_rate_defn_id         in     number
  ,p_parent_criteria_rate_defn_id  in     number
  ,p_parent_rate_matrix_id         in     number    default null
  ,p_business_group_id             in     number    default null
  ,p_legislation_code              in     varchar2  default null
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_effective_date      date;
  l_criteria_rate_factor_id  PQH_CRITERIA_RATE_FACTORS.criteria_rate_factor_id%TYPE;
  l_object_version_number PQH_CRITERIA_RATE_FACTORS.object_version_number%TYPE;
  l_proc                varchar2(72) := g_package||'create_criteria_rate_factor';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_criteria_rate_factor;
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

/* HEADER
create_criteria_rate_factor_b
 (p_effective_date                in     date
  ,p_criteria_rate_defn_id         in     number
  ,p_parent_criteria_rate_defn_id  in     number
  ,p_parent_rate_matrix_id         in     number
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  );
*/

-- CALL BY NAME

  PQH_CRITERIA_RATE_FACTORS_BK1.create_criteria_rate_factor_b
  (p_effective_date                 => l_effective_date
  ,p_criteria_rate_defn_id          => p_criteria_rate_defn_id
  ,p_parent_criteria_rate_defn_id   => p_parent_criteria_rate_defn_id
  ,p_parent_rate_matrix_id          => p_parent_rate_matrix_id
  ,p_business_group_id              => p_business_group_id
  ,p_legislation_code               => p_legislation_code
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_criteria_rate_factor'
        ,p_hook_type   => 'BP'
        );
  end;


  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
PQH_CRF_INS.ins
  (
  p_criteria_rate_defn_id          => p_criteria_rate_defn_id
  ,p_parent_criteria_rate_defn_id   => p_parent_criteria_rate_defn_id
  ,p_parent_rate_matrix_id          => p_parent_rate_matrix_id
  ,p_business_group_id              => p_business_group_id
  ,p_legislation_code               => p_legislation_code
  ,p_criteria_rate_factor_id       =>  l_criteria_rate_factor_id
  ,p_object_version_number          => l_object_version_number
  );


  --
  -- Call After Process User Hook
  --
 /* HEADER
 procedure create_criteria_rate_factor_a
  (p_effective_date                in     date
  ,p_criteria_rate_factor_id       in     number
  ,p_criteria_rate_defn_id         in     number
  ,p_parent_criteria_rate_defn_id  in     number
  ,p_parent_rate_matrix_id         in     number
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  ,p_object_version_number         in     number
  );
 */


  begin
    PQH_CRITERIA_RATE_FACTORS_BK1.create_criteria_rate_factor_a
  (p_effective_date                 => l_effective_date
  ,p_criteria_rate_defn_id          => p_criteria_rate_defn_id
  ,p_parent_criteria_rate_defn_id   => p_parent_criteria_rate_defn_id
  ,p_parent_rate_matrix_id          => p_parent_rate_matrix_id
  ,p_business_group_id              => p_business_group_id
  ,p_legislation_code               => p_legislation_code
  ,p_criteria_rate_factor_id       =>  l_criteria_rate_factor_id
  ,p_object_version_number          => l_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_criteria_rate_factor'
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
	p_criteria_rate_factor_id := l_criteria_rate_factor_id;
	p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_criteria_rate_factor;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
	p_criteria_rate_factor_id := null;
	p_object_version_number := null;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_criteria_rate_factor;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
	p_criteria_rate_factor_id := null;
	p_object_version_number := null;

	hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_criteria_rate_factor;



--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_criteria_rate_factor >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_criteria_rate_factor
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_criteria_rate_factor_id       in     number
  ,p_criteria_rate_defn_id         in     number    default hr_api.g_number
  ,p_parent_criteria_rate_defn_id  in     number    default hr_api.g_number
  ,p_parent_rate_matrix_id         in     number    default hr_api.g_number
  ,p_business_group_id             in     number    default hr_api.g_number
  ,p_legislation_code              in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  )is
  --
  -- Declare cursors and local variables
  --
  l_effective_date      date;
  l_proc                varchar2(72) := g_package||'update_criteria_rate_factor';
  l_object_version_number PQH_CRITERIA_RATE_FACTORS.object_version_number%TYPE;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_criteria_rate_factor;
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

 /* HEADER
procedure update_criteria_rate_factor_b
 ( p_effective_date                in     date
  ,p_criteria_rate_factor_id       in     number
  ,p_criteria_rate_defn_id         in     number
  ,p_parent_criteria_rate_defn_id  in     number
  ,p_parent_rate_matrix_id         in     number
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  ,p_object_version_number         in     number
  );
*/

  begin
  PQH_CRITERIA_RATE_FACTORS_BK2.update_criteria_rate_factor_b
  (p_effective_date                 => l_effective_date
  ,p_criteria_rate_factor_id        => p_criteria_rate_factor_id
  ,p_criteria_rate_defn_id          => p_criteria_rate_defn_id
  ,p_parent_criteria_rate_defn_id   => p_parent_criteria_rate_defn_id
  ,p_parent_rate_matrix_id          => p_parent_rate_matrix_id
  ,p_business_group_id              => p_business_group_id
  ,p_legislation_code               => p_legislation_code
  ,p_object_version_number          => l_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_criteria_rate_factor'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
PQH_CRF_UPD.upd
  (
   p_criteria_rate_factor_id        => p_criteria_rate_factor_id
  ,p_criteria_rate_defn_id          => p_criteria_rate_defn_id
  ,p_parent_criteria_rate_defn_id   => p_parent_criteria_rate_defn_id
  ,p_parent_rate_matrix_id          => p_parent_rate_matrix_id
  ,p_business_group_id              => p_business_group_id
  ,p_legislation_code               => p_legislation_code
  ,p_object_version_number          => l_object_version_number
  );

  --
  -- Call After Process User Hook
  --
  begin
  PQH_CRITERIA_RATE_FACTORS_BK2.update_criteria_rate_factor_a
  (p_effective_date                 => l_effective_date
  ,p_criteria_rate_factor_id        => p_criteria_rate_factor_id
  ,p_criteria_rate_defn_id          => p_criteria_rate_defn_id
  ,p_parent_criteria_rate_defn_id   => p_parent_criteria_rate_defn_id
  ,p_parent_rate_matrix_id          => p_parent_rate_matrix_id
  ,p_business_group_id              => p_business_group_id
  ,p_legislation_code               => p_legislation_code
  ,p_object_version_number          => l_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_criteria_rate_factor'
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
    rollback to update_criteria_rate_factor;
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
    rollback to update_criteria_rate_factor;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
  p_object_version_number  := p_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_criteria_rate_factor;


--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_criteria_rate_factor >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_criteria_rate_factor
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_criteria_rate_factor_id       in 		number
  ,p_object_version_number         in 		number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_effective_date      date;
  l_proc                varchar2(72) := g_package||'delete_criteria_rate_factor';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_criteria_rate_factor;
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
    PQH_CRITERIA_RATE_FACTORS_BK3.delete_criteria_rate_factor_b
      (p_effective_date                => l_effective_date
	  ,p_criteria_rate_factor_id   => p_criteria_rate_factor_id
	  ,p_object_version_number     => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_criteria_rate_factor'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
    PQH_CRF_DEL.del
  (
   p_criteria_rate_factor_id              =>p_criteria_rate_factor_id
  ,p_object_version_number                =>p_object_version_number
  );


  --
  -- Call After Process User Hook
  --
  begin
    PQH_CRITERIA_RATE_FACTORS_BK3.delete_criteria_rate_factor_a
      (p_effective_date                => l_effective_date
	  ,p_criteria_rate_factor_id   => p_criteria_rate_factor_id
	  ,p_object_version_number     => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_criteria_rate_factor'
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
    rollback to delete_criteria_rate_factor;
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
    rollback to delete_criteria_rate_factor;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_criteria_rate_factor;
--
--
end PQH_CRITERIA_RATE_FACTORS_API;

/
