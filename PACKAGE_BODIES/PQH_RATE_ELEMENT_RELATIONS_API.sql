--------------------------------------------------------
--  DDL for Package Body PQH_RATE_ELEMENT_RELATIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RATE_ELEMENT_RELATIONS_API" as
/* $Header: pqrerapi.pkb 120.0 2005/10/06 14:53:06 srajakum noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'PQH_RATE_ELEMENT_RELATIONS_API.';
--
-- ----------------------------------------------------------------------------
-- |------------------------<create_rate_element_relation >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_rate_element_relation
  (p_validate                     in     boolean   default false
  ,p_effective_date               in     date
  ,p_rate_element_relation_id     in out nocopy number
  ,p_criteria_rate_element_id     in     number
  ,p_relation_type_cd             in     varchar2
  ,p_rel_element_type_id          in     number
  ,p_rel_input_value_id           in     number    default null
  ,p_business_group_id            in     number    default null
  ,p_legislation_code             in     varchar2  default null
  ,p_object_version_number           out nocopy number
  )is

  --
  -- Declare cursors and local variables
  --
  l_effective_date      date;
  l_rate_element_relation_id  PQH_RATE_ELEMENT_RELATIONS.rate_element_relation_id%TYPE;
  l_object_version_number PQH_RATE_ELEMENT_RELATIONS.object_version_number%TYPE;
  l_proc                varchar2(72) := g_package||'create_rate_element_relation';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_rate_element_relation;
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

procedure create_rate_element_relation_b
 (
   p_effective_date               in     date
  ,p_criteria_rate_element_id     in     number
  ,p_relation_type_cd             in     varchar2
  ,p_rel_element_type_id          in     number
  ,p_rel_input_value_id           in     number
  ,p_business_group_id            in     number
  ,p_legislation_code             in     varchar2
  )

*/

  PQH_RATE_ELEMENT_RELATIONS_BK1.create_rate_element_relation_b
  (p_effective_date                 => l_effective_date
  ,p_criteria_rate_element_id       => p_criteria_rate_element_id
  ,p_relation_type_cd		    => p_relation_type_cd
  ,p_rel_element_type_id	    => p_rel_element_type_id
  ,p_rel_input_value_id 	    => p_rel_input_value_id
  ,p_business_group_id		    => p_business_group_id
  ,p_legislation_code               => p_legislation_code
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_rate_element_relation'
        ,p_hook_type   => 'BP'
        );
  end;


  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
PQH_RER_INS.ins
  (p_effective_date 			=> p_effective_date
  ,p_criteria_rate_element_id       => p_criteria_rate_element_id
  ,p_relation_type_cd		    => p_relation_type_cd
  ,p_rel_element_type_id	    => p_rel_element_type_id
  ,p_rel_input_value_id 	    => p_rel_input_value_id
  ,p_business_group_id		    => p_business_group_id
  ,p_legislation_code               => p_legislation_code
  ,p_rate_element_relation_id       => l_rate_element_relation_id
  ,p_object_version_number          => l_object_version_number
  );


  --
  -- Call After Process User Hook
  --
 /* HEADER
 procedure create_rate_element_relation_a
 (
   p_effective_date               in     date
  ,p_rate_element_relation_id     in     number
  ,p_criteria_rate_element_id     in     number
  ,p_relation_type_cd             in     varchar2
  ,p_rel_element_type_id          in     number
  ,p_rel_input_value_id           in     number
  ,p_business_group_id            in     number
  ,p_legislation_code             in     varchar2
  ,p_object_version_number        in     number
  );
 */


  begin
  PQH_RATE_ELEMENT_RELATIONS_BK1.create_rate_element_relation_a
  (
   p_effective_date                 => l_effective_date
  ,p_criteria_rate_element_id       => p_criteria_rate_element_id
  ,p_relation_type_cd		    => p_relation_type_cd
  ,p_rel_element_type_id	    => p_rel_element_type_id
  ,p_rel_input_value_id 	    => p_rel_input_value_id
  ,p_business_group_id		    => p_business_group_id
  ,p_legislation_code               => p_legislation_code
  ,p_rate_element_relation_id       => l_rate_element_relation_id
  ,p_object_version_number          => l_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_rate_element_relation'
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
	p_rate_element_relation_id := l_rate_element_relation_id;
	p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_rate_element_relation;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
	p_rate_element_relation_id := null;
	p_object_version_number := null;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_rate_element_relation;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
	p_rate_element_relation_id := null;
	p_object_version_number := null;

	hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_rate_element_relation;



--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_rate_element_relation >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_rate_element_relation
  (p_validate                     in     boolean   default false
  ,p_effective_date               in     date
  ,p_rate_element_relation_id     in     number
  ,p_criteria_rate_element_id     in     number    default hr_api.g_number
  ,p_relation_type_cd             in     varchar2  default hr_api.g_varchar2
  ,p_rel_element_type_id          in     number    default hr_api.g_number
  ,p_rel_input_value_id           in     number    default hr_api.g_number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  )is
  --
  -- Declare cursors and local variables
  --
  l_effective_date      date;
  l_proc                varchar2(72) := g_package||'update_rate_element_relation';
  l_object_version_number PQH_RATE_ELEMENT_RELATIONS.object_version_number%TYPE;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_rate_element_relation;
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
--
procedure update_rate_element_relation_b
 (
   p_effective_date               in     date
  ,p_rate_element_relation_id     in     number
  ,p_criteria_rate_element_id     in     number
  ,p_relation_type_cd             in     varchar2
  ,p_rel_element_type_id          in     number
  ,p_rel_input_value_id           in     number
  ,p_business_group_id            in     number
  ,p_legislation_code             in     varchar2
  ,p_object_version_number        in     number
  );
*/

  begin
  PQH_RATE_ELEMENT_RELATIONS_BK2.update_rate_element_relation_b
  (
   p_effective_date                 => l_effective_date
  ,p_criteria_rate_element_id       => p_criteria_rate_element_id
  ,p_relation_type_cd		    => p_relation_type_cd
  ,p_rel_element_type_id	    => p_rel_element_type_id
  ,p_rel_input_value_id 	    => p_rel_input_value_id
  ,p_business_group_id		    => p_business_group_id
  ,p_legislation_code               => p_legislation_code
  ,p_rate_element_relation_id       => p_rate_element_relation_id
  ,p_object_version_number          => l_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_rate_element_relation'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
PQH_RER_UPD.upd
  (p_effective_date				=> p_effective_date
  ,p_criteria_rate_element_id       => p_criteria_rate_element_id
  ,p_relation_type_cd		    => p_relation_type_cd
  ,p_rel_element_type_id	    => p_rel_element_type_id
  ,p_rel_input_value_id 	    => p_rel_input_value_id
  ,p_business_group_id		    => p_business_group_id
  ,p_legislation_code               => p_legislation_code
  ,p_rate_element_relation_id       => p_rate_element_relation_id
  ,p_object_version_number          => l_object_version_number
  );

  --
  -- Call After Process User Hook
  --
  begin
  PQH_RATE_ELEMENT_RELATIONS_BK2.update_rate_element_relation_a
  (
   p_effective_date                 => l_effective_date
  ,p_criteria_rate_element_id       => p_criteria_rate_element_id
  ,p_relation_type_cd		    => p_relation_type_cd
  ,p_rel_element_type_id	    => p_rel_element_type_id
  ,p_rel_input_value_id 	    => p_rel_input_value_id
  ,p_business_group_id		    => p_business_group_id
  ,p_legislation_code               => p_legislation_code
  ,p_rate_element_relation_id       => p_rate_element_relation_id
  ,p_object_version_number          => l_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_rate_element_relation'
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
    rollback to update_rate_element_relation;
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
    rollback to update_rate_element_relation;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
  p_object_version_number  := p_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_rate_element_relation;


--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_rate_element_relation >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_rate_element_relation
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_rate_element_relation_id       in 		number
  ,p_object_version_number         in 		number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_effective_date      date;
  l_proc                varchar2(72) := g_package||'delete_rate_element_relation';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_rate_element_relation;
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
    PQH_RATE_ELEMENT_RELATIONS_BK3.delete_rate_element_relation_b
    (	   p_effective_date                => l_effective_date
	  ,p_rate_element_relation_id        => p_rate_element_relation_id
	  ,p_object_version_number     => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_rate_element_relation'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
    PQH_RER_DEL.del
  (
   p_rate_element_relation_id              =>p_rate_element_relation_id
  ,p_object_version_number                =>p_object_version_number
  );


  --
  -- Call After Process User Hook
  --
  begin
    PQH_RATE_ELEMENT_RELATIONS_BK3.delete_rate_element_relation_a
      (p_effective_date                => l_effective_date
	  ,p_rate_element_relation_id   => p_rate_element_relation_id
	  ,p_object_version_number     => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_rate_element_relation'
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
    rollback to delete_rate_element_relation;
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
    rollback to delete_rate_element_relation;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_rate_element_relation;
--
--
end PQH_RATE_ELEMENT_RELATIONS_API;

/
