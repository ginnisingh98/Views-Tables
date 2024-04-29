--------------------------------------------------------
--  DDL for Package Body PQH_RT_MATRIX_NODE_VALUES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RT_MATRIX_NODE_VALUES_API" as
/* $Header: pqrmvapi.pkb 120.3 2005/07/13 04:53:01 srenukun noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'PQH_RT_MATRIX_NODE_VALUES_API.';
--
-- ----------------------------------------------------------------------------
-- |------------------------<create_rt_matrix_node_value >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_rt_matrix_node_value
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_NODE_VALUE_ID                 out nocopy number
  ,p_RATE_MATRIX_NODE_ID           in number
  ,p_SHORT_CODE                    in varchar2
  ,p_CHAR_VALUE1                   in varchar2  default null
  ,p_CHAR_VALUE2                   in varchar2  default null
  ,p_CHAR_VALUE3                   in varchar2  default null
  ,p_CHAR_VALUE4                   in varchar2  default null
  ,p_NUMBER_VALUE1                 in number  default null
  ,p_NUMBER_VALUE2                 in number  default null
  ,p_NUMBER_VALUE3                 in number  default null
  ,p_NUMBER_VALUE4                 in number  default null
  ,p_DATE_VALUE1                   in date default null
  ,p_DATE_VALUE2                   in date default null
  ,p_DATE_VALUE3                   in date default null
  ,p_DATE_VALUE4                   in date default null
  ,p_BUSINESS_GROUP_ID             in number    default null
  ,p_LEGISLATION_CODE              in varchar2    default null
  ,p_object_version_number           out nocopy number
  )
is
  --
  -- Declare cursors and local variables
  --
  l_effective_date      date;
  l_node_value_id  PQH_RT_MATRIX_NODE_VALUES.node_value_id%TYPE;
  l_object_version_number PQH_RT_MATRIX_NODE_VALUES.object_version_number%TYPE;
  l_proc                varchar2(72) := g_package||'create_rate_matrix_node';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_rt_matrix_node_value;
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
PQH_RT_MATRIX_NODE_VALUES_BK1.create_rt_matrix_node_value_b
  (p_effective_date               => l_effective_date
  ,p_RATE_MATRIX_NODE_ID           => p_rate_matrix_node_id
  ,p_SHORT_CODE                    => p_short_code
  ,p_CHAR_VALUE1                   => p_char_value1
  ,p_CHAR_VALUE2                   => p_char_value2
  ,p_CHAR_VALUE3                   => p_char_value3
  ,p_CHAR_VALUE4                   => p_char_value4
  ,p_NUMBER_VALUE1                 => p_number_value1
  ,p_NUMBER_VALUE2                 => p_number_value2
  ,p_NUMBER_VALUE3                 => p_number_value3
  ,p_NUMBER_VALUE4                 => p_number_value4
  ,p_DATE_VALUE1                   => p_date_value1
  ,p_DATE_VALUE2                   => p_date_value2
  ,p_DATE_VALUE3                   => p_date_value3
  ,p_DATE_VALUE4                   => p_date_value4
  ,p_BUSINESS_GROUP_ID             => p_business_group_id
  ,p_LEGISLATION_CODE              => p_legislation_code
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_rt_matrix_node_value'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
  PQH_RMV_INS.ins
  (p_rate_matrix_node_id           => p_RATE_MATRIX_NODE_ID
  ,p_short_code                    => p_short_code
  ,p_char_value1                    => p_char_value1
  ,p_char_value2                    => p_char_value2
  ,p_char_value3                    => p_char_value3
  ,p_char_value4                    => p_char_value4
  ,p_number_value1                  => p_number_value1
  ,p_number_value2                  => p_number_value2
  ,p_number_value3                  => p_number_value3
  ,p_number_value4                  => p_number_value4
  ,p_date_value1                    => p_date_value1
  ,p_date_value2                    => p_date_value2
  ,p_date_value3                    => p_date_value3
  ,p_date_value4                    => p_date_value4
  ,p_business_group_id              => p_business_Group_id
  ,p_legislation_code               => p_legislation_code
  ,p_node_value_id                 => l_node_value_id
  ,p_object_version_number          =>l_object_version_number
  );


  --
  -- Call After Process User Hook
  --
  begin
PQH_RT_MATRIX_NODE_VALUES_BK1.create_rt_matrix_node_value_a
  (p_effective_date               => p_effective_date
  ,p_NODE_VALUE_ID                 =>l_node_value_id
  ,p_RATE_MATRIX_NODE_ID           => p_rate_matrix_node_id
  ,p_SHORT_CODE                    => p_short_code
  ,p_char_value1                    => p_char_value1
  ,p_char_value2                    => p_char_value2
  ,p_char_value3                    => p_char_value3
  ,p_char_value4                    => p_char_value4
  ,p_number_value1                  => p_number_value1
  ,p_number_value2                  => p_number_value2
  ,p_number_value3                  => p_number_value3
  ,p_number_value4                  => p_number_value4
  ,p_date_value1                    => p_date_value1
  ,p_date_value2                    => p_date_value2
  ,p_date_value3                    => p_date_value3
  ,p_date_value4                    => p_date_value4
  ,p_BUSINESS_GROUP_ID             => p_business_group_id
  ,p_LEGISLATION_CODE              => p_legislation_code
  ,p_object_version_number          => l_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_rt_matrix_node_value'
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
	p_node_VALUE_id := l_node_value_id;
	p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_rt_matrix_node_value;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
	p_NODE_VALUE_ID := null;
	p_object_version_number := null;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_rt_matrix_node_value;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
	p_NODE_VALUE_ID := null;
	p_object_version_number := null;

	hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_rt_matrix_node_value;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_rt_matrix_node_value>--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_rt_matrix_node_value
  (p_validate                     in     boolean  default false
  ,p_effective_date                in     date
  ,p_NODE_VALUE_ID                 in number
  ,p_RATE_MATRIX_NODE_ID           in number
  ,p_SHORT_CODE                    in varchar2
  ,p_CHAR_VALUE1                   in varchar2  default hr_api.g_varchar2
  ,p_CHAR_VALUE2                   in varchar2  default hr_api.g_varchar2
  ,p_CHAR_VALUE3                   in varchar2  default hr_api.g_varchar2
  ,p_CHAR_VALUE4                   in varchar2  default hr_api.g_varchar2
  ,p_NUMBER_VALUE1                 in number  default hr_api.g_number
  ,p_NUMBER_VALUE2                 in number  default hr_api.g_number
  ,p_NUMBER_VALUE3                 in number  default hr_api.g_number
  ,p_NUMBER_VALUE4                 in number  default hr_api.g_number
  ,p_DATE_VALUE1                   in date default hr_api.g_date
  ,p_DATE_VALUE2                   in date default hr_api.g_date
  ,p_DATE_VALUE3                   in date default hr_api.g_date
  ,p_DATE_VALUE4                   in date default hr_api.g_date
  ,p_BUSINESS_GROUP_ID             in number default hr_api.g_number
  ,p_LEGISLATION_CODE              in varchar2  default hr_api.g_varchar2
  ,p_object_version_number           in out nocopy number
  )
 is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number PQH_RT_MATRIX_NODE_VALUES.object_version_number%TYPE;
  l_effective_date      date;
  l_proc                varchar2(72) := g_package||'update_rt_matrix_node_value';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_rt_matrix_node_value;
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
PQH_RT_MATRIX_NODE_VALUES_BK2.update_rt_matrix_node_value_b
  (p_effective_date               => l_effective_date
  ,p_NODE_VALUE_ID                 =>p_node_value_id
  ,p_RATE_MATRIX_NODE_ID           => p_rate_matrix_node_id
  ,p_SHORT_CODE                    => p_short_code
  ,p_CHAR_VALUE1                   => p_char_value1
  ,p_CHAR_VALUE2                   => p_char_value2
  ,p_CHAR_VALUE3                   => p_char_value3
  ,p_CHAR_VALUE4                   => p_char_value4
  ,p_NUMBER_VALUE1                 => p_number_value1
  ,p_NUMBER_VALUE2                 => p_number_value2
  ,p_NUMBER_VALUE3                 => p_number_value3
  ,p_NUMBER_VALUE4                 => p_number_value4
  ,p_DATE_VALUE1                   => p_date_value1
  ,p_DATE_VALUE2                   => p_date_value2
  ,p_DATE_VALUE3                   => p_date_value3
  ,p_DATE_VALUE4                   => p_date_value4
  ,p_BUSINESS_GROUP_ID             => p_business_group_id
  ,p_LEGISLATION_CODE              => p_legislation_code
  ,p_object_version_number          => l_object_version_number
  );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_rt_matrix_node_value'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
PQH_RMV_UPD.upd
  (p_node_value_id                => p_node_value_id
  ,p_object_version_number        => l_object_version_number
  ,p_RATE_MATRIX_NODE_ID           => p_rate_matrix_node_id
  ,p_SHORT_CODE                    => p_short_code
  ,p_CHAR_VALUE1                   => p_char_value1
  ,p_CHAR_VALUE2                   => p_char_value2
  ,p_CHAR_VALUE3                   => p_char_value3
  ,p_CHAR_VALUE4                   => p_char_value4
  ,p_NUMBER_VALUE1                 => p_number_value1
  ,p_NUMBER_VALUE2                 => p_number_value2
  ,p_NUMBER_VALUE3                 => p_number_value3
  ,p_NUMBER_VALUE4                 => p_number_value4
  ,p_DATE_VALUE1                   => p_date_value1
  ,p_DATE_VALUE2                   => p_date_value2
  ,p_DATE_VALUE3                   => p_date_value3
  ,p_DATE_VALUE4                   => p_date_value4
  ,p_BUSINESS_GROUP_ID             => p_business_group_id
  ,p_LEGISLATION_CODE              => p_legislation_code
  );


  --
  -- Call After Process User Hook
  --
  begin
PQH_RT_MATRIX_NODE_VALUES_BK2.update_rt_matrix_node_value_a
  (p_effective_date               => l_effective_date
  ,p_NODE_VALUE_ID                 =>p_node_value_id
  ,p_RATE_MATRIX_NODE_ID           => p_rate_matrix_node_id
  ,p_SHORT_CODE                    => p_short_code
  ,p_CHAR_VALUE1                   => p_char_value1
  ,p_CHAR_VALUE2                   => p_char_value2
  ,p_CHAR_VALUE3                   => p_char_value3
  ,p_CHAR_VALUE4                   => p_char_value4
  ,p_NUMBER_VALUE1                 => p_number_value1
  ,p_NUMBER_VALUE2                 => p_number_value2
  ,p_NUMBER_VALUE3                 => p_number_value3
  ,p_NUMBER_VALUE4                 => p_number_value4
  ,p_DATE_VALUE1                   => p_date_value1
  ,p_DATE_VALUE2                   => p_date_value2
  ,p_DATE_VALUE3                   => p_date_value3
  ,p_DATE_VALUE4                   => p_date_value4
  ,p_BUSINESS_GROUP_ID             => p_business_group_id
  ,p_LEGISLATION_CODE              => p_legislation_code
  ,p_object_version_number          => l_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_rt_matrix_node_value'
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
    rollback to update_rt_matrix_node_value;
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
    rollback to update_rt_matrix_node_value;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
  p_object_version_number  := p_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_rt_matrix_node_value;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_rt_matrix_node_value>--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_rt_matrix_node_value
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_NODE_VALUE_ID	  	   in     number
  ,p_object_version_number         in     number
  )
is
  --
  -- Declare cursors and local variables
  --
  l_effective_date      date;
  l_proc                varchar2(72) := g_package||'delete_rt_matrix_node_value';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_rt_matrix_node_value;
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
   PQH_RT_MATRIX_NODE_VALUES_BK3.delete_rt_matrix_node_value_b
  (p_effective_date                => l_effective_date
  ,p_NODE_value_ID  		  => p_node_value_id
  ,p_object_version_number         => p_object_version_number
  );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_rt_matrix_node_value'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
PQH_RMV_DEL.del
  (p_node_value_id                        => p_node_value_id
  ,p_object_version_number                => p_object_version_number
  );


  --
  -- Call After Process User Hook
  --
  begin
  PQH_RT_MATRIX_NODE_VALUES_BK3.delete_rt_matrix_node_value_a
  (p_effective_date                => l_effective_date
  ,p_NODE_value_ID  		  => p_node_value_id
  ,p_object_version_number         => p_object_version_number
  );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_rt_matrix_node_value'
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
    rollback to delete_rt_matrix_node_value;
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
    rollback to delete_rt_matrix_node_value;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_rt_matrix_node_value;
--
end PQH_RT_MATRIX_NODE_VALUES_API;

/
