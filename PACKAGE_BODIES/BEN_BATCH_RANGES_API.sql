--------------------------------------------------------
--  DDL for Package Body BEN_BATCH_RANGES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BATCH_RANGES_API" as
/* $Header: beranapi.pkb 115.4 2002/12/11 11:34:54 lakrish ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_batch_ranges_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_batch_ranges >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_batch_ranges
  (p_validate                       in  boolean   default false
  ,p_range_id                       out nocopy number
  ,p_benefit_action_id              in  number    default null
  ,p_range_status_cd                in  varchar2  default null
  ,p_starting_person_action_id      in  number    default null
  ,p_ending_person_action_id        in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date) is
  --
  -- Declare cursors and local variables
  --
  l_range_id              ben_batch_ranges.range_id%TYPE;
  l_proc                  varchar2(72) := g_package||'create_batch_ranges';
  l_object_version_number ben_batch_ranges.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_batch_ranges;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  ben_ran_ins.ins
    (p_range_id                      => l_range_id
    ,p_benefit_action_id             => p_benefit_action_id
    ,p_range_status_cd               => p_range_status_cd
    ,p_starting_person_action_id     => p_starting_person_action_id
    ,p_ending_person_action_id       => p_ending_person_action_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date));
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
  p_range_id := l_range_id;
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
    ROLLBACK TO create_batch_ranges;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_range_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_batch_ranges;

    -- NOCOPY, Reset out parameters
    p_range_id := null;
    p_object_version_number  := null;

    raise;
    --
end create_batch_ranges;
-- ----------------------------------------------------------------------------
-- |------------------------< update_batch_ranges >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_batch_ranges
  (p_validate                       in boolean   default false
  ,p_range_id                       in number
  ,p_benefit_action_id              in number    default hr_api.g_number
  ,p_range_status_cd                in varchar2  default hr_api.g_varchar2
  ,p_starting_person_action_id      in number    default hr_api.g_number
  ,p_ending_person_action_id        in number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in date) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'update_batch_ranges';
  l_object_version_number ben_batch_ranges.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_batch_ranges;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  ben_ran_upd.upd
    (p_range_id                      => p_range_id
    ,p_benefit_action_id             => p_benefit_action_id
    ,p_range_status_cd               => p_range_status_cd
    ,p_starting_person_action_id     => p_starting_person_action_id
    ,p_ending_person_action_id       => p_ending_person_action_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date));
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
    ROLLBACK TO update_batch_ranges;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_batch_ranges;
    raise;
    --
end update_batch_ranges;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_batch_ranges >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_batch_ranges
  (p_validate                       in boolean  default false
  ,p_range_id                       in number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in date) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_batch_ranges';
  l_object_version_number ben_batch_ranges.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_batch_ranges;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  ben_ran_del.del
    (p_range_id                      => p_range_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date);
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
    ROLLBACK TO delete_batch_ranges;
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
    ROLLBACK TO delete_batch_ranges;
    raise;
    --
end delete_batch_ranges;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (p_range_id              in number
  ,p_object_version_number in number) is
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
  ben_ran_shd.lck
    (p_range_id                 => p_range_id
    ,p_object_version_number    => p_object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_batch_ranges_api;

/
