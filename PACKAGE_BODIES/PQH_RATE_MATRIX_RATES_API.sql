--------------------------------------------------------
--  DDL for Package Body PQH_RATE_MATRIX_RATES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RATE_MATRIX_RATES_API" as
/* $Header: pqrmrapi.pkb 120.2 2005/07/13 04:52:56 srenukun noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'PQH_RATE_MATRIX_RATES_API.';
--
-- ----------------------------------------------------------------------------
-- |------------------------create_rate_matrix_rate >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_rate_matrix_rate
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_rate_matrix_rate_id           out nocopy number
  ,p_EFFECTIVE_START_DATE          out nocopy date
  ,p_EFFECTIVE_END_DATE            out nocopy date
  ,p_RATE_MATRIX_NODE_ID           in number
  ,p_CRITERIA_RATE_DEFN_ID         in number
  ,p_MIN_RATE_VALUE                in NUMBER default null
  ,p_MAX_RATE_VALUE                in NUMBER default null
  ,p_MID_RATE_VALUE                in NUMBER default null
  ,p_RATE_VALUE                    in NUMBER
  ,p_BUSINESS_GROUP_ID             in NUMBER default null
  ,p_LEGISLATION_CODE              in VARCHAR2 default null
  ,p_object_version_number           out nocopy number
  )
is
  --
  -- Declare cursors and local variables
  --
  l_effective_date           date;
  l_rate_matrix_rate_id      pqh_rate_matrix_rates_f.rate_matrix_rate_id%type;
  l_object_version_number    pqh_rate_matrix_rates_f.object_version_number%type;
  l_effective_start_date     pqh_rate_matrix_rates_f.effective_start_date%TYPE;
  l_effective_end_date       pqh_rate_matrix_rates_f.effective_end_date%TYPE;
  l_proc                     varchar2(72) := g_package||'create_rate_matrix_rate';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_rate_matrix_rate;
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
PQH_RATE_MATRIX_RATES_BK1.create_rate_matrix_rate_b
  (p_effective_date                => p_effective_date
  ,p_EFFECTIVE_START_DATE          => p_effective_start_date
  ,p_EFFECTIVE_END_DATE            => p_effective_end_date
  ,p_RATE_MATRIX_NODE_ID           => p_rate_matrix_node_id
  ,p_CRITERIA_RATE_DEFN_ID         => p_CRITERIA_RATE_DEFN_ID
  ,p_MIN_RATE_VALUE                => p_MIN_RATE_VALUE
  ,p_MAX_RATE_VALUE                => p_MAX_RATE_VALUE
  ,p_MID_RATE_VALUE                => p_MID_RATE_VALUE
  ,p_RATE_VALUE                    => p_rate_value
  ,p_BUSINESS_GROUP_ID             => p_business_group_id
  ,p_LEGISLATION_CODE              => p_legislation_code
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_rate_matrix_rate'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
  pqh_rmr_ins.ins
  (p_effective_date                 => l_effective_date
  ,p_rate_matrix_node_id            => p_rate_matrix_node_id
  ,p_criteria_rate_defn_id          => p_criteria_rate_defn_id
  ,p_rate_value                     => p_rate_value
  ,p_min_rate_value                 => p_min_rate_value
  ,p_max_rate_value                 => p_max_rate_value
  ,p_mid_rate_value                 => p_mid_rate_value
  ,p_business_group_id              => p_business_group_id
  ,p_legislation_code               => p_legislation_code
  ,p_rate_matrix_rate_id            => l_rate_matrix_rate_id
  ,p_object_version_number          => l_object_version_number
  ,p_effective_start_date           => l_effective_start_date
  ,p_effective_end_date             => l_effective_end_date
  );

  --
  -- Call After Process User Hook
  --
  begin
PQH_RATE_MATRIX_RATES_BK1.create_rate_matrix_rate_a
  (p_effective_date                => l_effective_date
  ,p_rate_matrix_rate_id           => l_rate_matrix_rate_id
  ,p_EFFECTIVE_START_DATE          => l_effective_start_date
  ,p_EFFECTIVE_END_DATE            => l_effective_end_date
  ,p_RATE_MATRIX_NODE_ID           => p_rate_matrix_node_id
  ,p_CRITERIA_RATE_DEFN_ID         => p_CRITERIA_RATE_DEFN_ID
  ,p_MIN_RATE_VALUE                => p_MIN_RATE_VALUE
  ,p_MAX_RATE_VALUE                => p_MAX_RATE_VALUE
  ,p_MID_RATE_VALUE                => p_MID_RATE_VALUE
  ,p_RATE_VALUE                    => p_rate_value
  ,p_BUSINESS_GROUP_ID             => p_business_group_id
  ,p_LEGISLATION_CODE              => p_legislation_code
  ,p_object_version_number         => l_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_rate_matrix_rate'
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
  p_rate_matrix_rate_id := l_rate_matrix_rate_id;
  p_effective_start_date := l_effective_start_date;
  p_effective_end_date := l_effective_end_date;
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_rate_matrix_rate;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_rate_matrix_rate_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_rate_matrix_rate;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_rate_matrix_rate_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_rate_matrix_rate;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_rate_matrix_rate--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_rate_matrix_rate
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_mode                in  varchar2
  ,p_RATE_MATRIX_RATE_ID           in number
  ,p_EFFECTIVE_START_DATE          out nocopy date
  ,p_EFFECTIVE_END_DATE            out nocopy date
  ,p_RATE_MATRIX_NODE_ID           in number
  ,p_CRITERIA_RATE_DEFN_ID         in number
  ,p_MIN_RATE_VALUE                in NUMBER default hr_api.g_number
  ,p_MAX_RATE_VALUE                in NUMBER default hr_api.g_number
  ,p_MID_RATE_VALUE                in NUMBER default hr_api.g_number
  ,p_RATE_VALUE                    in NUMBER
  ,p_BUSINESS_GROUP_ID             in NUMBER default hr_api.g_number
  ,p_LEGISLATION_CODE              in VARCHAR2 default hr_api.g_varchar2
  ,p_object_version_number         in  out nocopy number
  )
 is
  --
  -- Declare cursors and local variables
  --
  l_effective_date      date;
  l_object_version_number    pqh_rate_matrix_rates_f.object_version_number%type;
  l_effective_start_date     pqh_rate_matrix_rates_f.effective_start_date%TYPE;
  l_effective_end_date       pqh_rate_matrix_rates_f.effective_end_date%TYPE;
  l_proc                varchar2(72) := g_package||'update_rate_matrix_rate';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_rate_matrix_rate;
  --
  -- Remember IN OUT parameter IN values
  --


  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  l_object_version_number  := p_object_version_number;

  --
  -- Call Before Process User Hook
  --
  begin
PQH_RATE_MATRIX_RATES_BK2.update_rate_matrix_rate_b
  (p_effective_date                => p_effective_date
  ,p_rate_matrix_rate_id           => p_rate_matrix_rate_id
  ,p_RATE_MATRIX_NODE_ID           => p_rate_matrix_node_id
  ,p_CRITERIA_RATE_DEFN_ID         => p_CRITERIA_RATE_DEFN_ID
  ,p_MIN_RATE_VALUE                => p_MIN_RATE_VALUE
  ,p_MAX_RATE_VALUE                => p_MAX_RATE_VALUE
  ,p_MID_RATE_VALUE                => p_MID_RATE_VALUE
  ,p_RATE_VALUE                    => p_rate_value
  ,p_BUSINESS_GROUP_ID             => p_business_group_id
  ,p_LEGISLATION_CODE              => p_legislation_code
  ,p_object_version_number         => p_object_version_number
  );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_rate_matrix_rate'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
  pqh_rmr_upd.upd
  (p_effective_date                 => l_effective_date
  ,p_datetrack_mode                => p_datetrack_mode
  ,p_rate_matrix_node_id            => p_rate_matrix_node_id
  ,p_criteria_rate_defn_id          => p_criteria_rate_defn_id
  ,p_rate_value                     => p_rate_value
  ,p_min_rate_value                 => p_min_rate_value
  ,p_max_rate_value                 => p_max_rate_value
  ,p_mid_rate_value                 => p_mid_rate_value
  ,p_business_group_id              => p_business_group_id
  ,p_legislation_code               => p_legislation_code
  ,p_rate_matrix_rate_id            => p_rate_matrix_rate_id
  ,p_object_version_number          => l_object_version_number
  ,p_effective_start_date           => l_effective_start_date
  ,p_effective_end_date             => l_effective_end_date
  );



  --
  -- Call After Process User Hook
  --
  begin
PQH_RATE_MATRIX_RATES_BK2.update_rate_matrix_rate_a
  (p_effective_date                => p_effective_date
  ,p_rate_matrix_rate_id           => p_rate_matrix_rate_id
  ,p_EFFECTIVE_START_DATE          => l_effective_start_date
  ,p_EFFECTIVE_END_DATE            => l_effective_end_date
  ,p_RATE_MATRIX_NODE_ID           => p_rate_matrix_node_id
  ,p_CRITERIA_RATE_DEFN_ID         => p_CRITERIA_RATE_DEFN_ID
  ,p_MIN_RATE_VALUE                => p_MIN_RATE_VALUE
  ,p_MAX_RATE_VALUE                => p_MAX_RATE_VALUE
  ,p_MID_RATE_VALUE                => p_MID_RATE_VALUE
  ,p_RATE_VALUE                    => p_rate_value
  ,p_BUSINESS_GROUP_ID             => p_business_group_id
  ,p_LEGISLATION_CODE              => p_legislation_code
  ,p_object_version_number         => l_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_rate_matrix_rate'
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
  p_object_version_number := l_object_version_number;
  p_effective_start_date := l_effective_start_date;
  p_effective_end_date := l_effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_rate_matrix_rate;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_rate_matrix_rate;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_rate_matrix_rate;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_rate_matrix_rate>--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_rate_matrix_rate
  (p_validate                      in     boolean  default false
  ,p_rate_matrix_rate_ID	   in     number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2)
is
  --
  -- Declare cursors and local variables
  --
  l_effective_date      date;
  l_object_version_number    pqh_rate_matrix_rates_f.object_version_number%type;
  l_effective_start_date     pqh_rate_matrix_rates_f.effective_start_date%TYPE;
  l_effective_end_date       pqh_rate_matrix_rates_f.effective_end_date%TYPE;
  l_proc                varchar2(72) := g_package||'delete_rate_matrix_rate';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_rate_matrix_rate;
  --
  -- Remember IN OUT parameter IN values
  --

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  l_object_version_number := p_object_version_number;

  --
  -- Call Before Process User Hook
  --
  begin

 PQH_RATE_MATRIX_RATES_BK3.delete_rate_matrix_rate_b
  (p_effective_date                => l_effective_date
  ,p_rate_matrix_rate_ID      => p_rate_matrix_rate_ID
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
  pqh_rmr_del.del
  (
     p_rate_matrix_rate_id           => p_rate_matrix_rate_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );



  --
  -- Call After Process User Hook
  --
  begin
 PQH_RATE_MATRIX_RATES_BK3.delete_rate_matrix_rate_a
  (p_effective_date                => l_effective_date
  ,p_rate_matrix_rate_ID      => p_rate_matrix_rate_ID
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
    rollback to delete_rate_matrix_rate;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_start_date := null;
    p_effective_end_date := null;
   hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_rate_matrix_rate;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_rate_matrix_rate;
--
end PQH_RATE_MATRIX_RATES_API;

/
