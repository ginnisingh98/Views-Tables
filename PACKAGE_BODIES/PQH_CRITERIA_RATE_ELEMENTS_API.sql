--------------------------------------------------------
--  DDL for Package Body PQH_CRITERIA_RATE_ELEMENTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_CRITERIA_RATE_ELEMENTS_API" as
/* $Header: pqcreapi.pkb 120.0 2005/10/06 14:51:48 srajakum noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'PQH_CRITERIA_RATE_ELEMENTS_API.';
--
-- ----------------------------------------------------------------------------
-- |------------------------<create_criteria_rate_element >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_criteria_rate_element
  (p_validate                     in     boolean   default false
  ,p_effective_date               in     date
  ,p_criteria_rate_element_id        out nocopy number
  ,p_criteria_rate_defn_id        in     number
  ,p_element_type_id              in     number
  ,p_input_value_id               in     number
  ,p_business_group_id            in     number    default null
  ,p_legislation_code             in     varchar2  default null
  ,p_object_version_number          out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_effective_date      date;
  l_criteria_rate_element_id  PQH_CRITERIA_RATE_ELEMENTS.criteria_rate_element_id%TYPE;
  l_object_version_number PQH_CRITERIA_RATE_ELEMENTS.object_version_number%TYPE;
  l_proc                varchar2(72) := g_package||'create_criteria_rate_element';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_criteria_rate_element;
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

/*  Header

procedure create_criteria_rate_element_b
 ( p_effective_date               in     date
  ,p_criteria_rate_defn_id        in     number
  ,p_element_type_id              in     number
  ,p_input_value_id               in     number
  ,p_business_group_id            in     number
  ,p_legislation_code             in     varchar2
  );
--

*/

  PQH_CRITERIA_RATE_ELEMENTS_BK1.create_criteria_rate_element_b
  (p_effective_date                 => l_effective_date
  ,p_criteria_rate_defn_id          => p_criteria_rate_defn_id
  ,p_element_type_id 		    => p_element_type_id
  ,p_input_value_id 		    => p_input_value_id
  ,p_business_group_id              => p_business_group_id
  ,p_legislation_code               => p_legislation_code
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_criteria_rate_element'
        ,p_hook_type   => 'BP'
        );
  end;


  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
PQH_CRE_INS.ins
  (
   p_criteria_rate_defn_id          => p_criteria_rate_defn_id
  ,p_element_type_id 		    => p_element_type_id
  ,p_input_value_id 		    => p_input_value_id
  ,p_business_group_id              => p_business_group_id
  ,p_legislation_code               => p_legislation_code
  ,p_criteria_rate_element_id       => l_criteria_rate_element_id
  ,p_object_version_number          => l_object_version_number
  );


  --
  -- Call After Process User Hook
  --
 /* HEADER
 procedure create_criteria_rate_element_a
 (
   p_effective_date               in     date
  ,p_criteria_rate_element_id     in     number
  ,p_criteria_rate_defn_id        in     number
  ,p_element_type_id              in     number
  ,p_input_value_id               in     number
  ,p_business_group_id            in     number
  ,p_legislation_code             in     varchar2
  ,p_object_version_number        in     number
 );
 */


  begin
  PQH_CRITERIA_RATE_ELEMENTS_BK1.create_criteria_rate_element_a
  (p_effective_date                 => l_effective_date
  ,p_criteria_rate_defn_id          => p_criteria_rate_defn_id
  ,p_element_type_id 		    => p_element_type_id
  ,p_input_value_id 		    => p_input_value_id
  ,p_business_group_id              => p_business_group_id
  ,p_legislation_code               => p_legislation_code
  ,p_criteria_rate_element_id       => l_criteria_rate_element_id
  ,p_object_version_number          => l_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_criteria_rate_element'
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
	p_criteria_rate_element_id := l_criteria_rate_element_id;
	p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_criteria_rate_element;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
	p_criteria_rate_element_id := null;
	p_object_version_number := null;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_criteria_rate_element;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
	p_criteria_rate_element_id := null;
	p_object_version_number := null;

	hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_criteria_rate_element;



--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_criteria_rate_element >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_criteria_rate_element
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_criteria_rate_element_id     in     number
  ,p_criteria_rate_defn_id        in     number    default hr_api.g_number
  ,p_element_type_id              in     number    default hr_api.g_number
  ,p_input_value_id               in     number    default hr_api.g_number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  )is
  --
  -- Declare cursors and local variables
  --
  l_effective_date      date;
  l_proc                varchar2(72) := g_package||'update_criteria_rate_element';
  l_object_version_number PQH_CRITERIA_RATE_ELEMENTS.object_version_number%TYPE;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_criteria_rate_element;
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
procedure update_criteria_rate_element_b
 (
   p_effective_date               in     date
  ,p_criteria_rate_element_id     in     number
  ,p_criteria_rate_defn_id        in     number
  ,p_element_type_id              in     number
  ,p_input_value_id               in     number
  ,p_business_group_id            in     number
  ,p_legislation_code             in     varchar2
  ,p_object_version_number        in     number
  );
*/

  begin
  PQH_CRITERIA_RATE_ELEMENTS_BK2.update_criteria_rate_element_b
  (p_effective_date                 => l_effective_date
  ,p_criteria_rate_element_id        => p_criteria_rate_element_id
  ,p_criteria_rate_defn_id          => p_criteria_rate_defn_id
  ,p_element_type_id 		    => p_element_type_id
  ,p_input_value_id 		    => p_input_value_id
  ,p_business_group_id              => p_business_group_id
  ,p_legislation_code               => p_legislation_code
  ,p_object_version_number          => l_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_criteria_rate_element'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
PQH_CRE_UPD.upd
  (
   p_criteria_rate_element_id        => p_criteria_rate_element_id
  ,p_criteria_rate_defn_id          => p_criteria_rate_defn_id
  ,p_element_type_id 		    => p_element_type_id
  ,p_input_value_id 		    => p_input_value_id
  ,p_business_group_id              => p_business_group_id
  ,p_legislation_code               => p_legislation_code
  ,p_object_version_number          => l_object_version_number
  );

  --
  -- Call After Process User Hook
  --
  begin
  PQH_CRITERIA_RATE_ELEMENTS_BK2.update_criteria_rate_element_a
  (p_effective_date                 => l_effective_date
  ,p_criteria_rate_element_id        => p_criteria_rate_element_id
  ,p_criteria_rate_defn_id          => p_criteria_rate_defn_id
  ,p_element_type_id 		    => p_element_type_id
  ,p_input_value_id 		    => p_input_value_id
  ,p_business_group_id              => p_business_group_id
  ,p_legislation_code               => p_legislation_code
  ,p_object_version_number          => l_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_criteria_rate_element'
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
    rollback to update_criteria_rate_element;
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
    rollback to update_criteria_rate_element;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
  p_object_version_number  := p_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_criteria_rate_element;


--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_criteria_rate_element >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_criteria_rate_element
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_criteria_rate_element_id       in 		number
  ,p_object_version_number         in 		number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_effective_date      date;
  l_proc                varchar2(72) := g_package||'delete_criteria_rate_element';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_criteria_rate_element;
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
    PQH_CRITERIA_RATE_ELEMENTS_BK3.delete_criteria_rate_element_b
      (p_effective_date                => l_effective_date
	  ,p_criteria_rate_element_id   => p_criteria_rate_element_id
	  ,p_object_version_number     => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_criteria_rate_element'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
    PQH_CRE_DEL.del
  (
   p_criteria_rate_element_id              =>p_criteria_rate_element_id
  ,p_object_version_number                =>p_object_version_number
  );


  --
  -- Call After Process User Hook
  --
  begin
    PQH_CRITERIA_RATE_ELEMENTS_BK3.delete_criteria_rate_element_a
      (p_effective_date                => l_effective_date
	  ,p_criteria_rate_element_id   => p_criteria_rate_element_id
	  ,p_object_version_number     => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_criteria_rate_element'
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
    rollback to delete_criteria_rate_element;
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
    rollback to delete_criteria_rate_element;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_criteria_rate_element;
--
--
end PQH_CRITERIA_RATE_ELEMENTS_API;

/
