--------------------------------------------------------
--  DDL for Package Body PQH_ATTRIBUTE_RANGES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_ATTRIBUTE_RANGES_API" as
/* $Header: pqrngapi.pkb 115.8 2002/12/06 18:08:24 rpasapul noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pqh_ATTRIBUTE_RANGES_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_ATTRIBUTE_RANGE >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ATTRIBUTE_RANGE
  (p_validate                       in  boolean   default false
  ,p_attribute_range_id             out nocopy number
  ,p_approver_flag                  in  varchar2  default null
  ,p_enable_flag                    in  varchar2  default 'Y'
  ,p_delete_flag                    in  varchar2  default null
  ,p_assignment_id                  in  number    default null
  ,p_attribute_id                   in  number    default null
  ,p_from_char                      in  varchar2  default null
  ,p_from_date                      in  date      default null
  ,p_from_number                    in  number    default null
  ,p_position_id                    in  number    default null
  ,p_range_name                     in  varchar2
  ,p_routing_category_id            in  number
  ,p_routing_list_member_id         in  number    default null
  ,p_to_char                        in  varchar2  default null
  ,p_to_date                        in  date      default null
  ,p_to_number                      in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_attribute_range_id pqh_attribute_ranges.attribute_range_id%TYPE;
  l_proc varchar2(72) := g_package||'create_ATTRIBUTE_RANGE';
  l_object_version_number pqh_attribute_ranges.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_ATTRIBUTE_RANGE;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_ATTRIBUTE_RANGE
    --
    pqh_ATTRIBUTE_RANGES_bk1.create_ATTRIBUTE_RANGE_b
      (
       p_approver_flag                  =>  p_approver_flag
      ,p_enable_flag                  =>  p_enable_flag
      ,p_delete_flag                  =>  p_delete_flag
      ,p_assignment_id                  =>  p_assignment_id
      ,p_attribute_id                   =>  p_attribute_id
      ,p_from_char                      =>  p_from_char
      ,p_from_date                      =>  p_from_date
      ,p_from_number                    =>  p_from_number
      ,p_position_id                    =>  p_position_id
      ,p_range_name                     =>  p_range_name
      ,p_routing_category_id            =>  p_routing_category_id
      ,p_routing_list_member_id         =>  p_routing_list_member_id
      ,p_to_char                        =>  p_to_char
      ,p_to_date                        =>  p_to_date
      ,p_to_number                      =>  p_to_number
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_ATTRIBUTE_RANGE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_ATTRIBUTE_RANGE
    --
  end;
  --
  pqh_rng_ins.ins
    (
     p_attribute_range_id            => l_attribute_range_id
    ,p_approver_flag                 => p_approver_flag
      ,p_enable_flag                  =>  p_enable_flag
      ,p_delete_flag                  =>  p_delete_flag
    ,p_assignment_id                 => p_assignment_id
    ,p_attribute_id                  => p_attribute_id
    ,p_from_char                     => p_from_char
    ,p_from_date                     => p_from_date
    ,p_from_number                   => p_from_number
    ,p_position_id                   => p_position_id
    ,p_range_name                    => p_range_name
    ,p_routing_category_id           => p_routing_category_id
    ,p_routing_list_member_id        => p_routing_list_member_id
    ,p_to_char                       => p_to_char
    ,p_to_date                       => p_to_date
    ,p_to_number                     => p_to_number
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_ATTRIBUTE_RANGE
    --
    pqh_ATTRIBUTE_RANGES_bk1.create_ATTRIBUTE_RANGE_a
      (
       p_attribute_range_id             =>  l_attribute_range_id
      ,p_approver_flag                  =>  p_approver_flag
      ,p_enable_flag                  =>  p_enable_flag
      ,p_delete_flag                  =>  p_delete_flag
      ,p_assignment_id                  =>  p_assignment_id
      ,p_attribute_id                   =>  p_attribute_id
      ,p_from_char                      =>  p_from_char
      ,p_from_date                      =>  p_from_date
      ,p_from_number                    =>  p_from_number
      ,p_position_id                    =>  p_position_id
      ,p_range_name                     =>  p_range_name
      ,p_routing_category_id            =>  p_routing_category_id
      ,p_routing_list_member_id         =>  p_routing_list_member_id
      ,p_to_char                        =>  p_to_char
      ,p_to_date                        =>  p_to_date
      ,p_to_number                      =>  p_to_number
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ATTRIBUTE_RANGE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_ATTRIBUTE_RANGE
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
  p_attribute_range_id := l_attribute_range_id;
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
    ROLLBACK TO create_ATTRIBUTE_RANGE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_attribute_range_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
      p_attribute_range_id := null;
    p_object_version_number  := null;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_ATTRIBUTE_RANGE;
    raise;
    --
end create_ATTRIBUTE_RANGE;
-- ----------------------------------------------------------------------------
-- |------------------------< update_ATTRIBUTE_RANGE >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ATTRIBUTE_RANGE
  (p_validate                       in  boolean   default false
  ,p_attribute_range_id             in  number
  ,p_approver_flag                  in  varchar2  default hr_api.g_varchar2
  ,p_enable_flag                  in  varchar2  default hr_api.g_varchar2
  ,p_delete_flag                  in  varchar2  default hr_api.g_varchar2
  ,p_assignment_id                  in  number    default hr_api.g_number
  ,p_attribute_id                   in  number    default hr_api.g_number
  ,p_from_char                      in  varchar2  default hr_api.g_varchar2
  ,p_from_date                      in  date      default hr_api.g_date
  ,p_from_number                    in  number    default hr_api.g_number
  ,p_position_id                    in  number    default hr_api.g_number
  ,p_range_name                     in  varchar2  default hr_api.g_varchar2
  ,p_routing_category_id            in  number    default hr_api.g_number
  ,p_routing_list_member_id         in  number    default hr_api.g_number
  ,p_to_char                        in  varchar2  default hr_api.g_varchar2
  ,p_to_date                        in  date      default hr_api.g_date
  ,p_to_number                      in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_ATTRIBUTE_RANGE';
  l_object_version_number pqh_attribute_ranges.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_ATTRIBUTE_RANGE;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_ATTRIBUTE_RANGE
    --
    pqh_ATTRIBUTE_RANGES_bk2.update_ATTRIBUTE_RANGE_b
      (
       p_attribute_range_id             =>  p_attribute_range_id
      ,p_approver_flag                  =>  p_approver_flag
      ,p_enable_flag                  =>  p_enable_flag
      ,p_delete_flag                  =>  p_delete_flag
      ,p_assignment_id                  =>  p_assignment_id
      ,p_attribute_id                   =>  p_attribute_id
      ,p_from_char                      =>  p_from_char
      ,p_from_date                      =>  p_from_date
      ,p_from_number                    =>  p_from_number
      ,p_position_id                    =>  p_position_id
      ,p_range_name                     =>  p_range_name
      ,p_routing_category_id            =>  p_routing_category_id
      ,p_routing_list_member_id         =>  p_routing_list_member_id
      ,p_to_char                        =>  p_to_char
      ,p_to_date                        =>  p_to_date
      ,p_to_number                      =>  p_to_number
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ATTRIBUTE_RANGE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_ATTRIBUTE_RANGE
    --
  end;
  --
  pqh_rng_upd.upd
    (
     p_attribute_range_id            => p_attribute_range_id
    ,p_approver_flag                 => p_approver_flag
      ,p_enable_flag                  =>  p_enable_flag
      ,p_delete_flag                  =>  p_delete_flag
    ,p_assignment_id                 => p_assignment_id
    ,p_attribute_id                  => p_attribute_id
    ,p_from_char                     => p_from_char
    ,p_from_date                     => p_from_date
    ,p_from_number                   => p_from_number
    ,p_position_id                   => p_position_id
    ,p_range_name                    => p_range_name
    ,p_routing_category_id           => p_routing_category_id
    ,p_routing_list_member_id        => p_routing_list_member_id
    ,p_to_char                       => p_to_char
    ,p_to_date                       => p_to_date
    ,p_to_number                     => p_to_number
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_ATTRIBUTE_RANGE
    --
    pqh_ATTRIBUTE_RANGES_bk2.update_ATTRIBUTE_RANGE_a
      (
       p_attribute_range_id             =>  p_attribute_range_id
      ,p_approver_flag                  =>  p_approver_flag
      ,p_enable_flag                  =>  p_enable_flag
      ,p_delete_flag                  =>  p_delete_flag
      ,p_assignment_id                  =>  p_assignment_id
      ,p_attribute_id                   =>  p_attribute_id
      ,p_from_char                      =>  p_from_char
      ,p_from_date                      =>  p_from_date
      ,p_from_number                    =>  p_from_number
      ,p_position_id                    =>  p_position_id
      ,p_range_name                     =>  p_range_name
      ,p_routing_category_id            =>  p_routing_category_id
      ,p_routing_list_member_id         =>  p_routing_list_member_id
      ,p_to_char                        =>  p_to_char
      ,p_to_date                        =>  p_to_date
      ,p_to_number                      =>  p_to_number
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ATTRIBUTE_RANGE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_ATTRIBUTE_RANGE
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
    ROLLBACK TO update_ATTRIBUTE_RANGE;
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
    ROLLBACK TO update_ATTRIBUTE_RANGE;
    raise;
    --
end update_ATTRIBUTE_RANGE;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_ATTRIBUTE_RANGE >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ATTRIBUTE_RANGE
  (p_validate                       in  boolean  default false
  ,p_attribute_range_id             in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_ATTRIBUTE_RANGE';
  l_object_version_number pqh_attribute_ranges.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_ATTRIBUTE_RANGE;
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
    -- Start of API User Hook for the before hook of delete_ATTRIBUTE_RANGE
    --
    pqh_ATTRIBUTE_RANGES_bk3.delete_ATTRIBUTE_RANGE_b
      (
       p_attribute_range_id             =>  p_attribute_range_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ATTRIBUTE_RANGE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_ATTRIBUTE_RANGE
    --
  end;
  --
  pqh_rng_del.del
    (
     p_attribute_range_id            => p_attribute_range_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_ATTRIBUTE_RANGE
    --
    pqh_ATTRIBUTE_RANGES_bk3.delete_ATTRIBUTE_RANGE_a
      (
       p_attribute_range_id             =>  p_attribute_range_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ATTRIBUTE_RANGE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_ATTRIBUTE_RANGE
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
    ROLLBACK TO delete_ATTRIBUTE_RANGE;
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
    ROLLBACK TO delete_ATTRIBUTE_RANGE;
    raise;
    --
end delete_ATTRIBUTE_RANGE;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_attribute_range_id                   in     number
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
  pqh_rng_shd.lck
    (
      p_attribute_range_id                 => p_attribute_range_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end pqh_ATTRIBUTE_RANGES_api;

/
