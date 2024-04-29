--------------------------------------------------------
--  DDL for Package Body GHR_NOAC_LAS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_NOAC_LAS_API" as
/* $Header: ghnlaapi.pkb 120.1.12010000.1 2009/03/26 10:10:34 utokachi noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ghr_noac_las_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_noac_las >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_noac_las
  (p_validate                       in  boolean   default false
  ,p_noac_la_id                     out NOCOPY number
  ,p_nature_of_action_id            in  number    default null
  ,p_lac_lookup_code                in  varchar2  default null
  ,p_enabled_flag                   in  varchar2  default null
  ,p_date_from                      in  date      default null
  ,p_date_to                        in  date      default null
  ,p_object_version_number          out NOCOPY number
  ,p_valid_first_lac_flag           in  varchar2  default null
  ,p_valid_second_lac_flag          in  varchar2  default null
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_noac_la_id ghr_noac_las.noac_la_id%TYPE;
  l_proc varchar2(72) ;
  l_object_version_number ghr_noac_las.object_version_number%TYPE;
  --
begin
  --
  l_proc := g_package||'create_noac_las';
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_noac_las;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_noac_las
    --
    ghr_noac_las_bk1.create_noac_las_b
      (
       p_nature_of_action_id            =>  p_nature_of_action_id
      ,p_lac_lookup_code                =>  p_lac_lookup_code
      ,p_enabled_flag                   =>  p_enabled_flag
      ,p_date_from                      =>  p_date_from
      ,p_date_to                        =>  p_date_to
      ,p_valid_first_lac_flag           =>  p_valid_first_lac_flag
      ,p_valid_second_lac_flag          =>  p_valid_second_lac_flag
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_noac_las'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_noac_las
    --
  end;
  --
  ghr_nla_ins.ins
    (
     p_noac_la_id                    => l_noac_la_id
    ,p_nature_of_action_id           => p_nature_of_action_id
    ,p_lac_lookup_code               => p_lac_lookup_code
    ,p_enabled_flag                  => p_enabled_flag
    ,p_date_from                     => p_date_from
    ,p_date_to                       => p_date_to
    ,p_object_version_number         => l_object_version_number
    ,p_valid_first_lac_flag          => p_valid_first_lac_flag
    ,p_valid_second_lac_flag         => p_valid_second_lac_flag
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_noac_las
    --
    ghr_noac_las_bk1.create_noac_las_a
      (
       p_noac_la_id                     =>  l_noac_la_id
      ,p_nature_of_action_id            =>  p_nature_of_action_id
      ,p_lac_lookup_code                =>  p_lac_lookup_code
      ,p_enabled_flag                   =>  p_enabled_flag
      ,p_date_from                      =>  p_date_from
      ,p_date_to                        =>  p_date_to
      ,p_object_version_number          =>  l_object_version_number
      ,p_valid_first_lac_flag           =>  p_valid_first_lac_flag
      ,p_valid_second_lac_flag          =>  p_valid_second_lac_flag
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_noac_las'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_noac_las
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
  p_noac_la_id := l_noac_la_id;
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
    ROLLBACK TO create_noac_las;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_noac_la_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_noac_las;
    p_noac_la_id := null;
    p_object_version_number  := null;
    raise;
    --
end create_noac_las;
-- ----------------------------------------------------------------------------
-- |------------------------< update_noac_las >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_noac_las
  (p_validate                       in  boolean   default false
  ,p_noac_la_id                     in  number
  ,p_nature_of_action_id            in  number    default hr_api.g_number
  ,p_lac_lookup_code                in  varchar2  default hr_api.g_varchar2
  ,p_enabled_flag                   in  varchar2  default hr_api.g_varchar2
  ,p_date_from                      in  date      default hr_api.g_date
  ,p_date_to                        in  date      default hr_api.g_date
  ,p_object_version_number          in out NOCOPY number
  ,p_valid_first_lac_flag           in  varchar2  default hr_api.g_varchar2
  ,p_valid_second_lac_flag          in  varchar2  default hr_api.g_varchar2
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) ;
  l_object_version_number ghr_noac_las.object_version_number%TYPE;
  l_obj_version_number  ghr_noac_las.object_version_number%TYPE;  -- NOCOPY Changes
  --
begin
  --
  l_proc  := g_package||'update_noac_las';
  hr_utility.set_location('Entering:'|| l_proc, 10);

  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_noac_las;
  --
  hr_utility.set_location(l_proc, 20);

  l_obj_version_number :=  p_object_version_number;
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_noac_las
    --
    ghr_noac_las_bk2.update_noac_las_b
      (
       p_noac_la_id                     =>  p_noac_la_id
      ,p_nature_of_action_id            =>  p_nature_of_action_id
      ,p_lac_lookup_code                =>  p_lac_lookup_code
      ,p_enabled_flag                   =>  p_enabled_flag
      ,p_date_from                      =>  p_date_from
      ,p_date_to                        =>  p_date_to
      ,p_object_version_number          =>  p_object_version_number
      ,p_valid_first_lac_flag           =>  p_valid_first_lac_flag
      ,p_valid_second_lac_flag          =>  p_valid_second_lac_flag
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
     p_object_version_number := l_obj_version_number; -- NOCOPY Changes
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_noac_las'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_noac_las
    --
  end;
  --
  ghr_nla_upd.upd
    (
     p_noac_la_id                    => p_noac_la_id
    ,p_nature_of_action_id           => p_nature_of_action_id
    ,p_lac_lookup_code               => p_lac_lookup_code
    ,p_enabled_flag                  => p_enabled_flag
    ,p_date_from                     => p_date_from
    ,p_date_to                       => p_date_to
    ,p_object_version_number         => l_object_version_number
    ,p_valid_first_lac_flag          => p_valid_first_lac_flag
    ,p_valid_second_lac_flag         => p_valid_second_lac_flag
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_noac_las
    --
    ghr_noac_las_bk2.update_noac_las_a
      (
       p_noac_la_id                     =>  p_noac_la_id
      ,p_nature_of_action_id            =>  p_nature_of_action_id
      ,p_lac_lookup_code                =>  p_lac_lookup_code
      ,p_enabled_flag                   =>  p_enabled_flag
      ,p_date_from                      =>  p_date_from
      ,p_date_to                        =>  p_date_to
      ,p_object_version_number          =>  l_object_version_number
      ,p_valid_first_lac_flag           =>  p_valid_first_lac_flag
      ,p_valid_second_lac_flag          =>  p_valid_second_lac_flag
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      p_object_version_number := l_obj_version_number;
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_noac_las'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_noac_las
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
    ROLLBACK TO update_noac_las;
    p_object_version_number := l_obj_version_number;
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
    ROLLBACK TO update_noac_las;
    p_object_version_number := l_obj_version_number;
    raise;
    --
end update_noac_las;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_noac_las >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_noac_las
  (p_validate                       in  boolean  default false
  ,p_noac_la_id                     in  number
  ,p_object_version_number          in out NOCOPY number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) ;
  l_object_version_number ghr_noac_las.object_version_number%TYPE;
  l_obj_version_number  ghr_noac_las.object_version_number%TYPE;
  --
begin
  --
  l_proc  := g_package||'update_noac_las';
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_noac_las;
  --
  l_obj_version_number := p_object_version_number; -- nocopy changes
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_noac_las
    --
    ghr_noac_las_bk3.delete_noac_las_b
      (
       p_noac_la_id                     =>  p_noac_la_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      p_object_version_number := l_obj_version_number;
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_noac_las'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_noac_las
    --
  end;
  --
  ghr_nla_del.del
    (
     p_noac_la_id                    => p_noac_la_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_noac_las
    --
    ghr_noac_las_bk3.delete_noac_las_a
      (
       p_noac_la_id                     =>  p_noac_la_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      p_object_version_number := l_obj_version_number;
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_noac_las'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_noac_las
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
    ROLLBACK TO delete_noac_las;
    p_object_version_number := l_obj_version_number;
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
    ROLLBACK TO delete_noac_las;
    p_object_version_number := l_obj_version_number;
    raise;
    --
end delete_noac_las;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_noac_la_id                   in     number
  ,p_object_version_number          in     number
  ) is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72);
  --
begin
  --
  l_proc := g_package||'lck';
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  ghr_nla_shd.lck
    (
      p_noac_la_id                 => p_noac_la_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ghr_noac_las_api;

/
