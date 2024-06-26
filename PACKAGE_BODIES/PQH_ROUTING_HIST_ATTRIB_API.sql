--------------------------------------------------------
--  DDL for Package Body PQH_ROUTING_HIST_ATTRIB_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_ROUTING_HIST_ATTRIB_API" as
/* $Header: pqrhaapi.pkb 115.2 2002/12/06 18:07:47 rpasapul noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pqh_routing_hist_attrib_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_routing_hist_attrib >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_routing_hist_attrib
  (p_validate                       in  boolean   default false
  ,p_routing_hist_attrib_id         out nocopy number
  ,p_routing_history_id             in  number    default null
  ,p_attribute_id                   in  number    default null
  ,p_from_char                      in  varchar2  default null
  ,p_from_date                      in  date      default null
  ,p_from_number                    in  number    default null
  ,p_to_char                        in  varchar2  default null
  ,p_to_date                        in  date      default null
  ,p_to_number                      in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_range_type_cd                  in  varchar2  default null
  ,p_value_date                     in  date      default null
  ,p_value_number                   in  number    default null
  ,p_value_char                     in  varchar2  default null
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_routing_hist_attrib_id pqh_routing_hist_attribs.routing_hist_attrib_id%TYPE;
  l_proc varchar2(72) := g_package||'create_routing_hist_attrib';
  l_object_version_number pqh_routing_hist_attribs.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_routing_hist_attrib;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_routing_hist_attrib
    --
    pqh_routing_hist_attrib_bk1.create_routing_hist_attrib_b
      (
       p_routing_history_id             =>  p_routing_history_id
      ,p_attribute_id                   =>  p_attribute_id
      ,p_from_char                      =>  p_from_char
      ,p_from_date                      =>  p_from_date
      ,p_from_number                    =>  p_from_number
      ,p_to_char                        =>  p_to_char
      ,p_to_date                        =>  p_to_date
      ,p_to_number                      =>  p_to_number
      ,p_range_type_cd                  =>  p_range_type_cd
      ,p_value_date                     =>  p_value_date
      ,p_value_number                   =>  p_value_number
      ,p_value_char                     =>  p_value_char
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_ROUTING_HIST_ATTRIB'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_routing_hist_attrib
    --
  end;
  --
  pqh_rha_ins.ins
    (
     p_routing_hist_attrib_id        => l_routing_hist_attrib_id
    ,p_routing_history_id            => p_routing_history_id
    ,p_attribute_id                  => p_attribute_id
    ,p_from_char                     => p_from_char
    ,p_from_date                     => p_from_date
    ,p_from_number                   => p_from_number
    ,p_to_char                       => p_to_char
    ,p_to_date                       => p_to_date
    ,p_to_number                     => p_to_number
    ,p_object_version_number         => l_object_version_number
    ,p_range_type_cd                 => p_range_type_cd
    ,p_value_date                    => p_value_date
    ,p_value_number                  => p_value_number
    ,p_value_char                    => p_value_char
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_routing_hist_attrib
    --
    pqh_routing_hist_attrib_bk1.create_routing_hist_attrib_a
      (
       p_routing_hist_attrib_id         =>  l_routing_hist_attrib_id
      ,p_routing_history_id             =>  p_routing_history_id
      ,p_attribute_id                   =>  p_attribute_id
      ,p_from_char                      =>  p_from_char
      ,p_from_date                      =>  p_from_date
      ,p_from_number                    =>  p_from_number
      ,p_to_char                        =>  p_to_char
      ,p_to_date                        =>  p_to_date
      ,p_to_number                      =>  p_to_number
      ,p_object_version_number          =>  l_object_version_number
      ,p_range_type_cd                  =>  p_range_type_cd
      ,p_value_date                     =>  p_value_date
      ,p_value_number                   =>  p_value_number
      ,p_value_char                     =>  p_value_char
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ROUTING_HIST_ATTRIB'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_routing_hist_attrib
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
  p_routing_hist_attrib_id := l_routing_hist_attrib_id;
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
    ROLLBACK TO create_routing_hist_attrib;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_routing_hist_attrib_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
      p_routing_hist_attrib_id := null;
    p_object_version_number  := null;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_routing_hist_attrib;
    raise;
    --
end create_routing_hist_attrib;
-- ----------------------------------------------------------------------------
-- |------------------------< update_routing_hist_attrib >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_routing_hist_attrib
  (p_validate                       in  boolean   default false
  ,p_routing_hist_attrib_id         in  number
  ,p_routing_history_id             in  number    default hr_api.g_number
  ,p_attribute_id                   in  number    default hr_api.g_number
  ,p_from_char                      in  varchar2  default hr_api.g_varchar2
  ,p_from_date                      in  date      default hr_api.g_date
  ,p_from_number                    in  number    default hr_api.g_number
  ,p_to_char                        in  varchar2  default hr_api.g_varchar2
  ,p_to_date                        in  date      default hr_api.g_date
  ,p_to_number                      in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_range_type_cd                  in  varchar2  default hr_api.g_varchar2
  ,p_value_date                     in  date      default hr_api.g_date
  ,p_value_number                   in  number    default hr_api.g_number
  ,p_value_char                     in  varchar2  default hr_api.g_varchar2
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_routing_hist_attrib';
  l_object_version_number pqh_routing_hist_attribs.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_routing_hist_attrib;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_routing_hist_attrib
    --
    pqh_routing_hist_attrib_bk2.update_routing_hist_attrib_b
      (
       p_routing_hist_attrib_id         =>  p_routing_hist_attrib_id
      ,p_routing_history_id             =>  p_routing_history_id
      ,p_attribute_id                   =>  p_attribute_id
      ,p_from_char                      =>  p_from_char
      ,p_from_date                      =>  p_from_date
      ,p_from_number                    =>  p_from_number
      ,p_to_char                        =>  p_to_char
      ,p_to_date                        =>  p_to_date
      ,p_to_number                      =>  p_to_number
      ,p_object_version_number          =>  p_object_version_number
      ,p_range_type_cd                  =>  p_range_type_cd
      ,p_value_date                     =>  p_value_date
      ,p_value_number                   =>  p_value_number
      ,p_value_char                     =>  p_value_char
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ROUTING_HIST_ATTRIB'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_routing_hist_attrib
    --
  end;
  --
  pqh_rha_upd.upd
    (
     p_routing_hist_attrib_id        => p_routing_hist_attrib_id
    ,p_routing_history_id            => p_routing_history_id
    ,p_attribute_id                  => p_attribute_id
    ,p_from_char                     => p_from_char
    ,p_from_date                     => p_from_date
    ,p_from_number                   => p_from_number
    ,p_to_char                       => p_to_char
    ,p_to_date                       => p_to_date
    ,p_to_number                     => p_to_number
    ,p_object_version_number         => l_object_version_number
    ,p_range_type_cd                 => p_range_type_cd
    ,p_value_date                    => p_value_date
    ,p_value_number                  => p_value_number
    ,p_value_char                    => p_value_char
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_routing_hist_attrib
    --
    pqh_routing_hist_attrib_bk2.update_routing_hist_attrib_a
      (
       p_routing_hist_attrib_id         =>  p_routing_hist_attrib_id
      ,p_routing_history_id             =>  p_routing_history_id
      ,p_attribute_id                   =>  p_attribute_id
      ,p_from_char                      =>  p_from_char
      ,p_from_date                      =>  p_from_date
      ,p_from_number                    =>  p_from_number
      ,p_to_char                        =>  p_to_char
      ,p_to_date                        =>  p_to_date
      ,p_to_number                      =>  p_to_number
      ,p_object_version_number          =>  l_object_version_number
      ,p_range_type_cd                  =>  p_range_type_cd
      ,p_value_date                     =>  p_value_date
      ,p_value_number                   =>  p_value_number
      ,p_value_char                     =>  p_value_char
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ROUTING_HIST_ATTRIB'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_routing_hist_attrib
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
    ROLLBACK TO update_routing_hist_attrib;
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
    ROLLBACK TO update_routing_hist_attrib;
    raise;
    --
end update_routing_hist_attrib;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_routing_hist_attrib >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_routing_hist_attrib
  (p_validate                       in  boolean  default false
  ,p_routing_hist_attrib_id         in  number
  ,p_object_version_number          in number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_routing_hist_attrib';
  l_object_version_number pqh_routing_hist_attribs.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_routing_hist_attrib;
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
    -- Start of API User Hook for the before hook of delete_routing_hist_attrib
    --
    pqh_routing_hist_attrib_bk3.delete_routing_hist_attrib_b
      (
       p_routing_hist_attrib_id         =>  p_routing_hist_attrib_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ROUTING_HIST_ATTRIB'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_routing_hist_attrib
    --
  end;
  --
  pqh_rha_del.del
    (
     p_routing_hist_attrib_id        => p_routing_hist_attrib_id
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_routing_hist_attrib
    --
    pqh_routing_hist_attrib_bk3.delete_routing_hist_attrib_a
      (
       p_routing_hist_attrib_id         =>  p_routing_hist_attrib_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ROUTING_HIST_ATTRIB'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_routing_hist_attrib
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
    ROLLBACK TO delete_routing_hist_attrib;
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
    ROLLBACK TO delete_routing_hist_attrib;
    raise;
    --
end delete_routing_hist_attrib;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_routing_hist_attrib_id                   in     number
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
  pqh_rha_shd.lck
    (
      p_routing_hist_attrib_id                 => p_routing_hist_attrib_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end pqh_routing_hist_attrib_api;

/
