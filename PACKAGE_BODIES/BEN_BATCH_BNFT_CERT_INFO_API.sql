--------------------------------------------------------
--  DDL for Package Body BEN_BATCH_BNFT_CERT_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BATCH_BNFT_CERT_INFO_API" as
/* $Header: bebciapi.pkb 115.4 2002/12/16 10:30:08 rpgupta ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_batch_bnft_cert_info_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_batch_bnft_cert_info >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_batch_bnft_cert_info
  (p_validate                       in  boolean   default false
  ,p_batch_benft_cert_id            out nocopy number
  ,p_benefit_action_id              in  number    default null
  ,p_person_id                      in  number    default null
  ,p_actn_typ_id                    in  number    default null
  ,p_typ_cd                         in  varchar2  default null
  ,p_enrt_ctfn_recd_dt              in  date      default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_batch_benft_cert_id ben_batch_bnft_cert_info.batch_benft_cert_id%TYPE;
  l_proc varchar2(72) := g_package||'create_batch_bnft_cert_info';
  l_object_version_number ben_batch_bnft_cert_info.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_batch_bnft_cert_info;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_batch_bnft_cert_info
    --
    ben_batch_bnft_cert_info_bk1.create_batch_bnft_cert_info_b
      (
       p_benefit_action_id              =>  p_benefit_action_id
      ,p_person_id                      =>  p_person_id
      ,p_actn_typ_id                    =>  p_actn_typ_id
      ,p_typ_cd                         =>  p_typ_cd
      ,p_enrt_ctfn_recd_dt              =>  p_enrt_ctfn_recd_dt
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_batch_bnft_cert_info'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_batch_bnft_cert_info
    --
  end;
  --
  ben_bci_ins.ins
    (
     p_batch_benft_cert_id           => l_batch_benft_cert_id
    ,p_benefit_action_id             => p_benefit_action_id
    ,p_person_id                     => p_person_id
    ,p_actn_typ_id                   => p_actn_typ_id
    ,p_typ_cd                        => p_typ_cd
    ,p_enrt_ctfn_recd_dt             => p_enrt_ctfn_recd_dt
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_batch_bnft_cert_info
    --
    ben_batch_bnft_cert_info_bk1.create_batch_bnft_cert_info_a
      (
       p_batch_benft_cert_id            =>  l_batch_benft_cert_id
      ,p_benefit_action_id              =>  p_benefit_action_id
      ,p_person_id                      =>  p_person_id
      ,p_actn_typ_id                    =>  p_actn_typ_id
      ,p_typ_cd                         =>  p_typ_cd
      ,p_enrt_ctfn_recd_dt              =>  p_enrt_ctfn_recd_dt
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_batch_bnft_cert_info'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_batch_bnft_cert_info
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
  p_batch_benft_cert_id := l_batch_benft_cert_id;
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
    ROLLBACK TO create_batch_bnft_cert_info;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_batch_benft_cert_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_batch_bnft_cert_info;
    p_batch_benft_cert_id := null;--nocopy change
    p_object_version_number  := null; --nocopy change
    raise;
    --
end create_batch_bnft_cert_info;
-- ----------------------------------------------------------------------------
-- |------------------------< update_batch_bnft_cert_info >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_batch_bnft_cert_info
  (p_validate                       in  boolean   default false
  ,p_batch_benft_cert_id            in  number
  ,p_benefit_action_id              in  number    default hr_api.g_number
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_actn_typ_id                    in  number    default hr_api.g_number
  ,p_typ_cd                         in  varchar2  default hr_api.g_varchar2
  ,p_enrt_ctfn_recd_dt              in  date      default hr_api.g_date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_batch_bnft_cert_info';
  l_object_version_number ben_batch_bnft_cert_info.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_batch_bnft_cert_info;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_batch_bnft_cert_info
    --
    ben_batch_bnft_cert_info_bk2.update_batch_bnft_cert_info_b
      (
       p_batch_benft_cert_id            =>  p_batch_benft_cert_id
      ,p_benefit_action_id              =>  p_benefit_action_id
      ,p_person_id                      =>  p_person_id
      ,p_actn_typ_id                    =>  p_actn_typ_id
      ,p_typ_cd                         =>  p_typ_cd
      ,p_enrt_ctfn_recd_dt              =>  p_enrt_ctfn_recd_dt
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_batch_bnft_cert_info'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_batch_bnft_cert_info
    --
  end;
  --
  ben_bci_upd.upd
    (
     p_batch_benft_cert_id           => p_batch_benft_cert_id
    ,p_benefit_action_id             => p_benefit_action_id
    ,p_person_id                     => p_person_id
    ,p_actn_typ_id                   => p_actn_typ_id
    ,p_typ_cd                        => p_typ_cd
    ,p_enrt_ctfn_recd_dt             => p_enrt_ctfn_recd_dt
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_batch_bnft_cert_info
    --
    ben_batch_bnft_cert_info_bk2.update_batch_bnft_cert_info_a
      (
       p_batch_benft_cert_id            =>  p_batch_benft_cert_id
      ,p_benefit_action_id              =>  p_benefit_action_id
      ,p_person_id                      =>  p_person_id
      ,p_actn_typ_id                    =>  p_actn_typ_id
      ,p_typ_cd                         =>  p_typ_cd
      ,p_enrt_ctfn_recd_dt              =>  p_enrt_ctfn_recd_dt
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_batch_bnft_cert_info'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_batch_bnft_cert_info
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
    ROLLBACK TO update_batch_bnft_cert_info;
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
    ROLLBACK TO update_batch_bnft_cert_info;

    raise;
    --
end update_batch_bnft_cert_info;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_batch_bnft_cert_info >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_batch_bnft_cert_info
  (p_validate                       in  boolean  default false
  ,p_batch_benft_cert_id            in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_batch_bnft_cert_info';
  l_object_version_number ben_batch_bnft_cert_info.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_batch_bnft_cert_info;
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
    -- Start of API User Hook for the before hook of delete_batch_bnft_cert_info
    --
    ben_batch_bnft_cert_info_bk3.delete_batch_bnft_cert_info_b
      (
       p_batch_benft_cert_id            =>  p_batch_benft_cert_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_batch_bnft_cert_info'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_batch_bnft_cert_info
    --
  end;
  --
  ben_bci_del.del
    (
     p_batch_benft_cert_id           => p_batch_benft_cert_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_batch_bnft_cert_info
    --
    ben_batch_bnft_cert_info_bk3.delete_batch_bnft_cert_info_a
      (
       p_batch_benft_cert_id            =>  p_batch_benft_cert_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_batch_bnft_cert_info'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_batch_bnft_cert_info
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
    ROLLBACK TO delete_batch_bnft_cert_info;
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
    ROLLBACK TO delete_batch_bnft_cert_info;

    raise;
    --
end delete_batch_bnft_cert_info;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_batch_benft_cert_id                   in     number
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
  ben_bci_shd.lck
    (
      p_batch_benft_cert_id                 => p_batch_benft_cert_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_batch_bnft_cert_info_api;

/