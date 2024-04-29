--------------------------------------------------------
--  DDL for Package Body BEN_BATCH_RATE_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BATCH_RATE_INFO_API" as
/* $Header: bebriapi.pkb 120.0 2005/05/28 00:51:24 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_batch_rate_info_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_batch_rate_info >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_batch_rate_info
  (p_validate                       in  boolean   default false
  ,p_batch_rt_id                    out nocopy number
  ,p_benefit_action_id              in  number    default null
  ,p_person_id                      in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_oipl_id                        in  number    default null
  ,p_bnft_rt_typ_cd                 in  varchar2  default null
  ,p_dflt_flag                      in  varchar2  default null
  ,p_val                            in  number    default null
  ,p_old_val                        in  number    default null
  ,p_tx_typ_cd                      in  varchar2  default null
  ,p_acty_typ_cd                    in  varchar2  default null
  ,p_mn_elcn_val                    in  number    default null
  ,p_mx_elcn_val                    in  number    default null
  ,p_incrmt_elcn_val                in  number    default null
  ,p_dflt_val                       in  number    default null
  ,p_rt_strt_dt                     in  date      default null
  ,p_business_group_id              in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_enrt_cvg_strt_dt               in  date      default null
  ,p_enrt_cvg_thru_dt               in  date      default null
  ,p_actn_cd                        in  varchar2  default null
  ,p_close_actn_itm_dt              in  date      default null
  ,p_effective_date                 in  date) is
  --
  -- Declare cursors and local variables
  --
  l_batch_rt_id ben_batch_rate_info.batch_rt_id%TYPE;
  l_proc varchar2(72) := g_package||'create_batch_rate_info';
  l_object_version_number ben_batch_rate_info.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_batch_rate_info;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_batch_rate_info
    --
    ben_batch_rate_info_bk1.create_batch_rate_info_b
      (p_benefit_action_id              =>  p_benefit_action_id
      ,p_person_id                      =>  p_person_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_pl_id                          =>  p_pl_id
      ,p_oipl_id                        =>  p_oipl_id
      ,p_bnft_rt_typ_cd                 =>  p_bnft_rt_typ_cd
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_val                            =>  p_val
      ,p_old_val                        =>  p_old_val
      ,p_tx_typ_cd                      =>  p_tx_typ_cd
      ,p_acty_typ_cd                    =>  p_acty_typ_cd
      ,p_mn_elcn_val                    =>  p_mn_elcn_val
      ,p_mx_elcn_val                    =>  p_mx_elcn_val
      ,p_incrmt_elcn_val                =>  p_incrmt_elcn_val
      ,p_dflt_val                       =>  p_dflt_val
      ,p_rt_strt_dt                     =>  p_rt_strt_dt
      ,p_business_group_id              =>  p_business_group_id
      ,p_enrt_cvg_strt_dt               =>  p_enrt_cvg_strt_dt
      ,p_enrt_cvg_thru_dt               =>  p_enrt_cvg_thru_dt
      ,p_actn_cd                        =>  p_actn_cd
      ,p_close_actn_itm_dt              =>  p_close_actn_itm_dt
      ,p_effective_date                 =>  trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_batch_rate_info'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of create_batch_rate_info
    --
  end;
  --
  ben_bri_ins.ins
    (p_batch_rt_id                   => l_batch_rt_id
    ,p_benefit_action_id             => p_benefit_action_id
    ,p_person_id                     => p_person_id
    ,p_pgm_id                        => p_pgm_id
    ,p_pl_id                         => p_pl_id
    ,p_oipl_id                       => p_oipl_id
    ,p_bnft_rt_typ_cd                => p_bnft_rt_typ_cd
    ,p_dflt_flag                     => p_dflt_flag
    ,p_val                           => p_val
    ,p_old_val                       => p_old_val
    ,p_tx_typ_cd                     => p_tx_typ_cd
    ,p_acty_typ_cd                   => p_acty_typ_cd
    ,p_mn_elcn_val                   => p_mn_elcn_val
    ,p_mx_elcn_val                   => p_mx_elcn_val
    ,p_incrmt_elcn_val               => p_incrmt_elcn_val
    ,p_dflt_val                      => p_dflt_val
    ,p_rt_strt_dt                    => p_rt_strt_dt
    ,p_business_group_id             => p_business_group_id
    ,p_object_version_number         => l_object_version_number
    ,p_enrt_cvg_strt_dt              => p_enrt_cvg_strt_dt
    ,p_enrt_cvg_thru_dt              => p_enrt_cvg_thru_dt
    ,p_actn_cd                       => p_actn_cd
    ,p_close_actn_itm_dt             => p_close_actn_itm_dt
    ,p_effective_date                => trunc(p_effective_date));
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_batch_rate_info
    --
    ben_batch_rate_info_bk1.create_batch_rate_info_a
      (p_batch_rt_id                    =>  l_batch_rt_id
      ,p_benefit_action_id              =>  p_benefit_action_id
      ,p_person_id                      =>  p_person_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_pl_id                          =>  p_pl_id
      ,p_oipl_id                        =>  p_oipl_id
      ,p_bnft_rt_typ_cd                 =>  p_bnft_rt_typ_cd
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_val                            =>  p_val
      ,p_old_val                        =>  p_old_val
      ,p_tx_typ_cd                      =>  p_tx_typ_cd
      ,p_acty_typ_cd                    =>  p_acty_typ_cd
      ,p_mn_elcn_val                    =>  p_mn_elcn_val
      ,p_mx_elcn_val                    =>  p_mx_elcn_val
      ,p_incrmt_elcn_val                =>  p_incrmt_elcn_val
      ,p_dflt_val                       =>  p_dflt_val
      ,p_rt_strt_dt                     =>  p_rt_strt_dt
      ,p_business_group_id              =>  p_business_group_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_enrt_cvg_strt_dt               =>  p_enrt_cvg_strt_dt
      ,p_enrt_cvg_thru_dt               =>  p_enrt_cvg_thru_dt
      ,p_actn_cd                        =>  p_actn_cd
      ,p_close_actn_itm_dt              =>  p_close_actn_itm_dt
      ,p_effective_date                 =>  trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_batch_rate_info'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of create_batch_rate_info
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
  p_batch_rt_id := l_batch_rt_id;
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
    ROLLBACK TO create_batch_rate_info;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_batch_rt_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_batch_rt_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
    ROLLBACK TO create_batch_rate_info;
    raise;
    --
end create_batch_rate_info;
-- ----------------------------------------------------------------------------
-- |------------------------< update_batch_rate_info >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_batch_rate_info
  (p_validate                       in  boolean   default false
  ,p_batch_rt_id                    in  number
  ,p_benefit_action_id              in  number    default hr_api.g_number
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_pgm_id                         in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_oipl_id                        in  number    default hr_api.g_number
  ,p_bnft_rt_typ_cd                 in  varchar2  default hr_api.g_varchar2
  ,p_dflt_flag                      in  varchar2  default hr_api.g_varchar2
  ,p_val                            in  number    default hr_api.g_number
  ,p_old_val                        in  number    default hr_api.g_number
  ,p_tx_typ_cd                      in  varchar2  default hr_api.g_varchar2
  ,p_acty_typ_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_mn_elcn_val                    in  number    default hr_api.g_number
  ,p_mx_elcn_val                    in  number    default hr_api.g_number
  ,p_incrmt_elcn_val                in  number    default hr_api.g_number
  ,p_dflt_val                       in  number    default hr_api.g_number
  ,p_rt_strt_dt                     in  date      default hr_api.g_date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_enrt_cvg_strt_dt               in  date      default hr_api.g_date
  ,p_enrt_cvg_thru_dt               in  date      default hr_api.g_date
  ,p_actn_cd                        in  varchar2  default hr_api.g_varchar2
  ,p_close_actn_itm_dt              in  date      default hr_api.g_date
  ,p_effective_date                 in  date) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_batch_rate_info';
  l_object_version_number ben_batch_rate_info.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_batch_rate_info;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_batch_rate_info
    --
    ben_batch_rate_info_bk2.update_batch_rate_info_b
      (p_batch_rt_id                    =>  p_batch_rt_id
      ,p_benefit_action_id              =>  p_benefit_action_id
      ,p_person_id                      =>  p_person_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_pl_id                          =>  p_pl_id
      ,p_oipl_id                        =>  p_oipl_id
      ,p_bnft_rt_typ_cd                 =>  p_bnft_rt_typ_cd
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_val                            =>  p_val
      ,p_old_val                        =>  p_old_val
      ,p_tx_typ_cd                      =>  p_tx_typ_cd
      ,p_acty_typ_cd                    =>  p_acty_typ_cd
      ,p_mn_elcn_val                    =>  p_mn_elcn_val
      ,p_mx_elcn_val                    =>  p_mx_elcn_val
      ,p_incrmt_elcn_val                =>  p_incrmt_elcn_val
      ,p_dflt_val                       =>  p_dflt_val
      ,p_rt_strt_dt                     =>  p_rt_strt_dt
      ,p_business_group_id              =>  p_business_group_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_enrt_cvg_strt_dt               =>  p_enrt_cvg_strt_dt
      ,p_enrt_cvg_thru_dt               =>  p_enrt_cvg_thru_dt
      ,p_actn_cd                        =>  p_actn_cd
      ,p_close_actn_itm_dt              =>  p_close_actn_itm_dt
      ,p_effective_date                 =>  trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_batch_rate_info'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of update_batch_rate_info
    --
  end;
  --
  ben_bri_upd.upd
    (p_batch_rt_id                   => p_batch_rt_id
    ,p_benefit_action_id             => p_benefit_action_id
    ,p_person_id                     => p_person_id
    ,p_pgm_id                        => p_pgm_id
    ,p_pl_id                         => p_pl_id
    ,p_oipl_id                       => p_oipl_id
    ,p_bnft_rt_typ_cd                => p_bnft_rt_typ_cd
    ,p_dflt_flag                     => p_dflt_flag
    ,p_val                           => p_val
    ,p_old_val                       => p_old_val
    ,p_tx_typ_cd                     => p_tx_typ_cd
    ,p_acty_typ_cd                   => p_acty_typ_cd
    ,p_mn_elcn_val                   => p_mn_elcn_val
    ,p_mx_elcn_val                   => p_mx_elcn_val
    ,p_incrmt_elcn_val               => p_incrmt_elcn_val
    ,p_dflt_val                      => p_dflt_val
    ,p_rt_strt_dt                    => p_rt_strt_dt
    ,p_business_group_id             => p_business_group_id
    ,p_object_version_number         => l_object_version_number
    ,p_enrt_cvg_strt_dt              => p_enrt_cvg_strt_dt
    ,p_enrt_cvg_thru_dt              => p_enrt_cvg_thru_dt
    ,p_actn_cd                       => p_actn_cd
    ,p_close_actn_itm_dt             => p_close_actn_itm_dt
    ,p_effective_date                => trunc(p_effective_date));
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_batch_rate_info
    --
    ben_batch_rate_info_bk2.update_batch_rate_info_a
      (p_batch_rt_id                    =>  p_batch_rt_id
      ,p_benefit_action_id              =>  p_benefit_action_id
      ,p_person_id                      =>  p_person_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_pl_id                          =>  p_pl_id
      ,p_oipl_id                        =>  p_oipl_id
      ,p_bnft_rt_typ_cd                 =>  p_bnft_rt_typ_cd
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_val                            =>  p_val
      ,p_old_val                        =>  p_old_val
      ,p_tx_typ_cd                      =>  p_tx_typ_cd
      ,p_acty_typ_cd                    =>  p_acty_typ_cd
      ,p_mn_elcn_val                    =>  p_mn_elcn_val
      ,p_mx_elcn_val                    =>  p_mx_elcn_val
      ,p_incrmt_elcn_val                =>  p_incrmt_elcn_val
      ,p_dflt_val                       =>  p_dflt_val
      ,p_rt_strt_dt                     =>  p_rt_strt_dt
      ,p_business_group_id              =>  p_business_group_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_enrt_cvg_strt_dt               =>  p_enrt_cvg_strt_dt
      ,p_enrt_cvg_thru_dt               =>  p_enrt_cvg_thru_dt
      ,p_actn_cd                        =>  p_actn_cd
      ,p_close_actn_itm_dt              =>  p_close_actn_itm_dt
      ,p_effective_date                 =>  trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_batch_rate_info'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of update_batch_rate_info
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
    ROLLBACK TO update_batch_rate_info;
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
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
    ROLLBACK TO update_batch_rate_info;
    raise;
    --
end update_batch_rate_info;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_batch_rate_info >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_batch_rate_info
  (p_validate                       in  boolean  default false
  ,p_batch_rt_id                    in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_batch_rate_info';
  l_object_version_number ben_batch_rate_info.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_batch_rate_info;
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
    -- Start of API User Hook for the before hook of delete_batch_rate_info
    --
    ben_batch_rate_info_bk3.delete_batch_rate_info_b
      (p_batch_rt_id                    =>  p_batch_rt_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_batch_rate_info'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of delete_batch_rate_info
    --
  end;
  --
  ben_bri_del.del
    (p_batch_rt_id                   => p_batch_rt_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date);
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_batch_rate_info
    --
    ben_batch_rate_info_bk3.delete_batch_rate_info_a
      (p_batch_rt_id                    =>  p_batch_rt_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_batch_rate_info'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of delete_batch_rate_info
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
    ROLLBACK TO delete_batch_rate_info;
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
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
    ROLLBACK TO delete_batch_rate_info;
    raise;
    --
end delete_batch_rate_info;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (p_batch_rt_id                   in     number
  ,p_object_version_number         in     number) is
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
  ben_bri_shd.lck
    (p_batch_rt_id                => p_batch_rt_id
    ,p_object_version_number      => p_object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_batch_rate_info_api;

/
