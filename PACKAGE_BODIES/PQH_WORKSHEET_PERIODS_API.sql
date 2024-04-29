--------------------------------------------------------
--  DDL for Package Body PQH_WORKSHEET_PERIODS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_WORKSHEET_PERIODS_API" as
/* $Header: pqwprapi.pkb 115.3 2002/12/06 23:50:10 rpasapul noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pqh_WORKSHEET_PERIODS_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_WORKSHEET_PERIOD >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_WORKSHEET_PERIOD
  (p_validate                       in  boolean   default false
  ,p_worksheet_period_id            out nocopy number
  ,p_end_time_period_id             in  number
  ,p_worksheet_detail_id            in  number
  ,p_budget_unit1_percent           in  number    default null
  ,p_budget_unit2_percent           in  number    default null
  ,p_budget_unit3_percent           in  number    default null
  ,p_budget_unit1_value             in  number    default null
  ,p_budget_unit2_value             in  number    default null
  ,p_budget_unit3_value             in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_budget_unit1_value_type_cd     in  varchar2  default null
  ,p_budget_unit2_value_type_cd     in  varchar2  default null
  ,p_budget_unit3_value_type_cd     in  varchar2  default null
  ,p_start_time_period_id           in  number
  ,p_budget_unit3_available         in  number    default null
  ,p_budget_unit2_available         in  number    default null
  ,p_budget_unit1_available         in  number    default null
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_worksheet_period_id pqh_worksheet_periods.worksheet_period_id%TYPE;
  l_proc varchar2(72) := g_package||'create_WORKSHEET_PERIOD';
  l_object_version_number pqh_worksheet_periods.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_WORKSHEET_PERIOD;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_WORKSHEET_PERIOD
    --
    pqh_WORKSHEET_PERIODS_bk1.create_WORKSHEET_PERIOD_b
      (
       p_end_time_period_id             =>  p_end_time_period_id
      ,p_worksheet_detail_id            =>  p_worksheet_detail_id
      ,p_budget_unit1_percent           =>  p_budget_unit1_percent
      ,p_budget_unit2_percent           =>  p_budget_unit2_percent
      ,p_budget_unit3_percent           =>  p_budget_unit3_percent
      ,p_budget_unit1_value             =>  p_budget_unit1_value
      ,p_budget_unit2_value             =>  p_budget_unit2_value
      ,p_budget_unit3_value             =>  p_budget_unit3_value
      ,p_budget_unit1_value_type_cd     =>  p_budget_unit1_value_type_cd
      ,p_budget_unit2_value_type_cd     =>  p_budget_unit2_value_type_cd
      ,p_budget_unit3_value_type_cd     =>  p_budget_unit3_value_type_cd
      ,p_start_time_period_id           =>  p_start_time_period_id
      ,p_budget_unit3_available         =>  p_budget_unit3_available
      ,p_budget_unit2_available         =>  p_budget_unit2_available
      ,p_budget_unit1_available         =>  p_budget_unit1_available
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_WORKSHEET_PERIOD'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_WORKSHEET_PERIOD
    --
  end;
  --
  pqh_wpr_ins.ins
    (
     p_worksheet_period_id           => l_worksheet_period_id
    ,p_end_time_period_id            => p_end_time_period_id
    ,p_worksheet_detail_id           => p_worksheet_detail_id
    ,p_budget_unit1_percent          => p_budget_unit1_percent
    ,p_budget_unit2_percent          => p_budget_unit2_percent
    ,p_budget_unit3_percent          => p_budget_unit3_percent
    ,p_budget_unit1_value            => p_budget_unit1_value
    ,p_budget_unit2_value            => p_budget_unit2_value
    ,p_budget_unit3_value            => p_budget_unit3_value
    ,p_object_version_number         => l_object_version_number
    ,p_budget_unit1_value_type_cd    => p_budget_unit1_value_type_cd
    ,p_budget_unit2_value_type_cd    => p_budget_unit2_value_type_cd
    ,p_budget_unit3_value_type_cd    => p_budget_unit3_value_type_cd
    ,p_start_time_period_id          => p_start_time_period_id
    ,p_budget_unit3_available        => p_budget_unit3_available
    ,p_budget_unit2_available        => p_budget_unit2_available
    ,p_budget_unit1_available        => p_budget_unit1_available
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_WORKSHEET_PERIOD
    --
    pqh_WORKSHEET_PERIODS_bk1.create_WORKSHEET_PERIOD_a
      (
       p_worksheet_period_id            =>  l_worksheet_period_id
      ,p_end_time_period_id             =>  p_end_time_period_id
      ,p_worksheet_detail_id            =>  p_worksheet_detail_id
      ,p_budget_unit1_percent           =>  p_budget_unit1_percent
      ,p_budget_unit2_percent           =>  p_budget_unit2_percent
      ,p_budget_unit3_percent           =>  p_budget_unit3_percent
      ,p_budget_unit1_value             =>  p_budget_unit1_value
      ,p_budget_unit2_value             =>  p_budget_unit2_value
      ,p_budget_unit3_value             =>  p_budget_unit3_value
      ,p_object_version_number          =>  l_object_version_number
      ,p_budget_unit1_value_type_cd     =>  p_budget_unit1_value_type_cd
      ,p_budget_unit2_value_type_cd     =>  p_budget_unit2_value_type_cd
      ,p_budget_unit3_value_type_cd     =>  p_budget_unit3_value_type_cd
      ,p_start_time_period_id           =>  p_start_time_period_id
      ,p_budget_unit3_available         =>  p_budget_unit3_available
      ,p_budget_unit2_available         =>  p_budget_unit2_available
      ,p_budget_unit1_available         =>  p_budget_unit1_available
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_WORKSHEET_PERIOD'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_WORKSHEET_PERIOD
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_worksheet_period_id := l_worksheet_period_id;
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_WORKSHEET_PERIOD;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_worksheet_period_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
      p_worksheet_period_id := null;
    p_object_version_number  := null;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_WORKSHEET_PERIOD;
    raise;
    --
end create_WORKSHEET_PERIOD;
-- ----------------------------------------------------------------------------
-- |------------------------< update_WORKSHEET_PERIOD >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_WORKSHEET_PERIOD
  (p_validate                       in  boolean   default false
  ,p_worksheet_period_id            in  number
  ,p_end_time_period_id             in  number    default hr_api.g_number
  ,p_worksheet_detail_id            in  number    default hr_api.g_number
  ,p_budget_unit1_percent           in  number    default hr_api.g_number
  ,p_budget_unit2_percent           in  number    default hr_api.g_number
  ,p_budget_unit3_percent           in  number    default hr_api.g_number
  ,p_budget_unit1_value             in  number    default hr_api.g_number
  ,p_budget_unit2_value             in  number    default hr_api.g_number
  ,p_budget_unit3_value             in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_budget_unit1_value_type_cd     in  varchar2  default hr_api.g_varchar2
  ,p_budget_unit2_value_type_cd     in  varchar2  default hr_api.g_varchar2
  ,p_budget_unit3_value_type_cd     in  varchar2  default hr_api.g_varchar2
  ,p_start_time_period_id           in  number    default hr_api.g_number
  ,p_budget_unit3_available         in  number    default hr_api.g_number
  ,p_budget_unit2_available         in  number    default hr_api.g_number
  ,p_budget_unit1_available         in  number    default hr_api.g_number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_WORKSHEET_PERIOD';
  l_object_version_number pqh_worksheet_periods.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_WORKSHEET_PERIOD;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_WORKSHEET_PERIOD
    --
    pqh_WORKSHEET_PERIODS_bk2.update_WORKSHEET_PERIOD_b
      (
       p_worksheet_period_id            =>  p_worksheet_period_id
      ,p_end_time_period_id             =>  p_end_time_period_id
      ,p_worksheet_detail_id            =>  p_worksheet_detail_id
      ,p_budget_unit1_percent           =>  p_budget_unit1_percent
      ,p_budget_unit2_percent           =>  p_budget_unit2_percent
      ,p_budget_unit3_percent           =>  p_budget_unit3_percent
      ,p_budget_unit1_value             =>  p_budget_unit1_value
      ,p_budget_unit2_value             =>  p_budget_unit2_value
      ,p_budget_unit3_value             =>  p_budget_unit3_value
      ,p_object_version_number          =>  p_object_version_number
      ,p_budget_unit1_value_type_cd     =>  p_budget_unit1_value_type_cd
      ,p_budget_unit2_value_type_cd     =>  p_budget_unit2_value_type_cd
      ,p_budget_unit3_value_type_cd     =>  p_budget_unit3_value_type_cd
      ,p_start_time_period_id           =>  p_start_time_period_id
      ,p_budget_unit3_available         =>  p_budget_unit3_available
      ,p_budget_unit2_available         =>  p_budget_unit2_available
      ,p_budget_unit1_available         =>  p_budget_unit1_available
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_WORKSHEET_PERIOD'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_WORKSHEET_PERIOD
    --
  end;
  --
  pqh_wpr_upd.upd
    (
     p_worksheet_period_id           => p_worksheet_period_id
    ,p_end_time_period_id            => p_end_time_period_id
    ,p_worksheet_detail_id           => p_worksheet_detail_id
    ,p_budget_unit1_percent          => p_budget_unit1_percent
    ,p_budget_unit2_percent          => p_budget_unit2_percent
    ,p_budget_unit3_percent          => p_budget_unit3_percent
    ,p_budget_unit1_value            => p_budget_unit1_value
    ,p_budget_unit2_value            => p_budget_unit2_value
    ,p_budget_unit3_value            => p_budget_unit3_value
    ,p_object_version_number         => l_object_version_number
    ,p_budget_unit1_value_type_cd    => p_budget_unit1_value_type_cd
    ,p_budget_unit2_value_type_cd    => p_budget_unit2_value_type_cd
    ,p_budget_unit3_value_type_cd    => p_budget_unit3_value_type_cd
    ,p_start_time_period_id          => p_start_time_period_id
    ,p_budget_unit3_available        => p_budget_unit3_available
    ,p_budget_unit2_available        => p_budget_unit2_available
    ,p_budget_unit1_available        => p_budget_unit1_available
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_WORKSHEET_PERIOD
    --
    pqh_WORKSHEET_PERIODS_bk2.update_WORKSHEET_PERIOD_a
      (
       p_worksheet_period_id            =>  p_worksheet_period_id
      ,p_end_time_period_id             =>  p_end_time_period_id
      ,p_worksheet_detail_id            =>  p_worksheet_detail_id
      ,p_budget_unit1_percent           =>  p_budget_unit1_percent
      ,p_budget_unit2_percent           =>  p_budget_unit2_percent
      ,p_budget_unit3_percent           =>  p_budget_unit3_percent
      ,p_budget_unit1_value             =>  p_budget_unit1_value
      ,p_budget_unit2_value             =>  p_budget_unit2_value
      ,p_budget_unit3_value             =>  p_budget_unit3_value
      ,p_object_version_number          =>  l_object_version_number
      ,p_budget_unit1_value_type_cd     =>  p_budget_unit1_value_type_cd
      ,p_budget_unit2_value_type_cd     =>  p_budget_unit2_value_type_cd
      ,p_budget_unit3_value_type_cd     =>  p_budget_unit3_value_type_cd
      ,p_start_time_period_id           =>  p_start_time_period_id
      ,p_budget_unit3_available         =>  p_budget_unit3_available
      ,p_budget_unit2_available         =>  p_budget_unit2_available
      ,p_budget_unit1_available         =>  p_budget_unit1_available
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_WORKSHEET_PERIOD'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_WORKSHEET_PERIOD
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_WORKSHEET_PERIOD;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    p_object_version_number := l_object_version_number;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_WORKSHEET_PERIOD;
    raise;
    --
end update_WORKSHEET_PERIOD;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_WORKSHEET_PERIOD >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_WORKSHEET_PERIOD
  (p_validate                       in  boolean  default false
  ,p_worksheet_period_id            in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_WORKSHEET_PERIOD';
  l_object_version_number pqh_worksheet_periods.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_WORKSHEET_PERIOD;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_WORKSHEET_PERIOD
    --
    pqh_WORKSHEET_PERIODS_bk3.delete_WORKSHEET_PERIOD_b
      (
       p_worksheet_period_id            =>  p_worksheet_period_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_WORKSHEET_PERIOD'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_WORKSHEET_PERIOD
    --
  end;
  --
  pqh_wpr_del.del
    (
     p_worksheet_period_id           => p_worksheet_period_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_WORKSHEET_PERIOD
    --
    pqh_WORKSHEET_PERIODS_bk3.delete_WORKSHEET_PERIOD_a
      (
       p_worksheet_period_id            =>  p_worksheet_period_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_WORKSHEET_PERIOD'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_WORKSHEET_PERIOD
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_WORKSHEET_PERIOD;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_WORKSHEET_PERIOD;
    raise;
    --
end delete_WORKSHEET_PERIOD;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_worksheet_period_id                   in     number
  ,p_object_version_number          in     number
  ) is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'lck';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  pqh_wpr_shd.lck
    (
      p_worksheet_period_id                 => p_worksheet_period_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end pqh_WORKSHEET_PERIODS_api;

/
