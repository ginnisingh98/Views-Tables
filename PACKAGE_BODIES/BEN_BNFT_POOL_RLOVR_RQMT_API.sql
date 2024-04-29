--------------------------------------------------------
--  DDL for Package Body BEN_BNFT_POOL_RLOVR_RQMT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BNFT_POOL_RLOVR_RQMT_API" as
/* $Header: bebprapi.pkb 120.0 2005/05/28 00:48:57 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_Bnft_Pool_Rlovr_Rqmt_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Bnft_Pool_Rlovr_Rqmt >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_Bnft_Pool_Rlovr_Rqmt
  (p_validate                       in  boolean   default false
  ,p_bnft_pool_rlovr_rqmt_id        out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_no_mn_rlovr_pct_dfnd_flag      in  varchar2  default 'N'
  ,p_no_mx_rlovr_pct_dfnd_flag      in  varchar2  default 'N'
  ,p_no_mn_rlovr_val_dfnd_flag      in  varchar2  default 'N'
  ,p_no_mx_rlovr_val_dfnd_flag      in  varchar2  default 'N'
  ,p_rlovr_val_incrmt_num           in  number    default null
  ,p_rlovr_val_rl                   in  number    default null
  ,p_mn_rlovr_val                   in  number    default null
  ,p_mx_rlovr_val                   in  number    default null
  ,p_val_rndg_cd                    in  varchar2  default null
  ,p_val_rndg_rl                    in  number    default null
  ,p_pct_rndg_cd                    in  varchar2  default null
  ,p_pct_rndg_rl                    in  number    default null
  ,p_prtt_elig_rlovr_rl             in  number    default null
  ,p_mx_rchd_dflt_ordr_num          in  number    default null
  ,p_pct_rlovr_incrmt_num           in  number    default null
  ,p_mn_rlovr_pct_num               in  number    default null
  ,p_mx_rlovr_pct_num               in  number    default null
  ,p_crs_rlovr_procg_cd             in  varchar2  default null
  ,p_mx_pct_ttl_crs_cn_roll_num     in  number    default null
  ,p_bnft_prvdr_pool_id             in  number    default null
  ,p_acty_base_rt_id                in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_bpr_attribute_category         in  varchar2  default null
  ,p_bpr_attribute1                 in  varchar2  default null
  ,p_bpr_attribute2                 in  varchar2  default null
  ,p_bpr_attribute3                 in  varchar2  default null
  ,p_bpr_attribute4                 in  varchar2  default null
  ,p_bpr_attribute5                 in  varchar2  default null
  ,p_bpr_attribute6                 in  varchar2  default null
  ,p_bpr_attribute7                 in  varchar2  default null
  ,p_bpr_attribute8                 in  varchar2  default null
  ,p_bpr_attribute9                 in  varchar2  default null
  ,p_bpr_attribute10                in  varchar2  default null
  ,p_bpr_attribute11                in  varchar2  default null
  ,p_bpr_attribute12                in  varchar2  default null
  ,p_bpr_attribute13                in  varchar2  default null
  ,p_bpr_attribute14                in  varchar2  default null
  ,p_bpr_attribute15                in  varchar2  default null
  ,p_bpr_attribute16                in  varchar2  default null
  ,p_bpr_attribute17                in  varchar2  default null
  ,p_bpr_attribute18                in  varchar2  default null
  ,p_bpr_attribute19                in  varchar2  default null
  ,p_bpr_attribute20                in  varchar2  default null
  ,p_bpr_attribute21                in  varchar2  default null
  ,p_bpr_attribute22                in  varchar2  default null
  ,p_bpr_attribute23                in  varchar2  default null
  ,p_bpr_attribute24                in  varchar2  default null
  ,p_bpr_attribute25                in  varchar2  default null
  ,p_bpr_attribute26                in  varchar2  default null
  ,p_bpr_attribute27                in  varchar2  default null
  ,p_bpr_attribute28                in  varchar2  default null
  ,p_bpr_attribute29                in  varchar2  default null
  ,p_bpr_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_bnft_pool_rlovr_rqmt_id ben_bnft_pool_rlovr_rqmt_f.bnft_pool_rlovr_rqmt_id%TYPE;
  l_effective_start_date ben_bnft_pool_rlovr_rqmt_f.effective_start_date%TYPE;
  l_effective_end_date ben_bnft_pool_rlovr_rqmt_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_Bnft_Pool_Rlovr_Rqmt';
  l_object_version_number ben_bnft_pool_rlovr_rqmt_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_Bnft_Pool_Rlovr_Rqmt;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_Bnft_Pool_Rlovr_Rqmt
    --
    ben_Bnft_Pool_Rlovr_Rqmt_bk1.create_Bnft_Pool_Rlovr_Rqmt_b
      (
       p_no_mn_rlovr_pct_dfnd_flag      =>  p_no_mn_rlovr_pct_dfnd_flag
      ,p_no_mx_rlovr_pct_dfnd_flag      =>  p_no_mx_rlovr_pct_dfnd_flag
      ,p_no_mn_rlovr_val_dfnd_flag      =>  p_no_mn_rlovr_val_dfnd_flag
      ,p_no_mx_rlovr_val_dfnd_flag      =>  p_no_mx_rlovr_val_dfnd_flag
      ,p_rlovr_val_incrmt_num           =>  p_rlovr_val_incrmt_num
      ,p_rlovr_val_rl                   =>  p_rlovr_val_rl
      ,p_mn_rlovr_val                   =>  p_mn_rlovr_val
      ,p_mx_rlovr_val                   =>  p_mx_rlovr_val
      ,p_val_rndg_cd                    =>  p_val_rndg_cd
      ,p_val_rndg_rl                    =>  p_val_rndg_rl
      ,p_pct_rndg_cd                    =>  p_pct_rndg_cd
      ,p_pct_rndg_rl                    =>  p_pct_rndg_rl
      ,p_prtt_elig_rlovr_rl             =>  p_prtt_elig_rlovr_rl
      ,p_mx_rchd_dflt_ordr_num          =>  p_mx_rchd_dflt_ordr_num
      ,p_pct_rlovr_incrmt_num           =>  p_pct_rlovr_incrmt_num
      ,p_mn_rlovr_pct_num               =>  p_mn_rlovr_pct_num
      ,p_mx_rlovr_pct_num               =>  p_mx_rlovr_pct_num
      ,p_crs_rlovr_procg_cd             =>  p_crs_rlovr_procg_cd
      ,p_mx_pct_ttl_crs_cn_roll_num     =>  p_mx_pct_ttl_crs_cn_roll_num
      ,p_bnft_prvdr_pool_id             =>  p_bnft_prvdr_pool_id
      ,p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_bpr_attribute_category         =>  p_bpr_attribute_category
      ,p_bpr_attribute1                 =>  p_bpr_attribute1
      ,p_bpr_attribute2                 =>  p_bpr_attribute2
      ,p_bpr_attribute3                 =>  p_bpr_attribute3
      ,p_bpr_attribute4                 =>  p_bpr_attribute4
      ,p_bpr_attribute5                 =>  p_bpr_attribute5
      ,p_bpr_attribute6                 =>  p_bpr_attribute6
      ,p_bpr_attribute7                 =>  p_bpr_attribute7
      ,p_bpr_attribute8                 =>  p_bpr_attribute8
      ,p_bpr_attribute9                 =>  p_bpr_attribute9
      ,p_bpr_attribute10                =>  p_bpr_attribute10
      ,p_bpr_attribute11                =>  p_bpr_attribute11
      ,p_bpr_attribute12                =>  p_bpr_attribute12
      ,p_bpr_attribute13                =>  p_bpr_attribute13
      ,p_bpr_attribute14                =>  p_bpr_attribute14
      ,p_bpr_attribute15                =>  p_bpr_attribute15
      ,p_bpr_attribute16                =>  p_bpr_attribute16
      ,p_bpr_attribute17                =>  p_bpr_attribute17
      ,p_bpr_attribute18                =>  p_bpr_attribute18
      ,p_bpr_attribute19                =>  p_bpr_attribute19
      ,p_bpr_attribute20                =>  p_bpr_attribute20
      ,p_bpr_attribute21                =>  p_bpr_attribute21
      ,p_bpr_attribute22                =>  p_bpr_attribute22
      ,p_bpr_attribute23                =>  p_bpr_attribute23
      ,p_bpr_attribute24                =>  p_bpr_attribute24
      ,p_bpr_attribute25                =>  p_bpr_attribute25
      ,p_bpr_attribute26                =>  p_bpr_attribute26
      ,p_bpr_attribute27                =>  p_bpr_attribute27
      ,p_bpr_attribute28                =>  p_bpr_attribute28
      ,p_bpr_attribute29                =>  p_bpr_attribute29
      ,p_bpr_attribute30                =>  p_bpr_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_Bnft_Pool_Rlovr_Rqmt'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_Bnft_Pool_Rlovr_Rqmt
    --
  end;
  --
  ben_bpr_ins.ins
    (
     p_bnft_pool_rlovr_rqmt_id       => l_bnft_pool_rlovr_rqmt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_no_mn_rlovr_pct_dfnd_flag     => p_no_mn_rlovr_pct_dfnd_flag
    ,p_no_mx_rlovr_pct_dfnd_flag     => p_no_mx_rlovr_pct_dfnd_flag
    ,p_no_mn_rlovr_val_dfnd_flag     => p_no_mn_rlovr_val_dfnd_flag
    ,p_no_mx_rlovr_val_dfnd_flag     => p_no_mx_rlovr_val_dfnd_flag
    ,p_rlovr_val_incrmt_num          => p_rlovr_val_incrmt_num
    ,p_rlovr_val_rl                  => p_rlovr_val_rl
    ,p_mn_rlovr_val                  => p_mn_rlovr_val
    ,p_mx_rlovr_val                  => p_mx_rlovr_val
    ,p_val_rndg_cd                   => p_val_rndg_cd
    ,p_val_rndg_rl                   => p_val_rndg_rl
    ,p_pct_rndg_cd                   => p_pct_rndg_cd
    ,p_pct_rndg_rl                   => p_pct_rndg_rl
    ,p_prtt_elig_rlovr_rl            => p_prtt_elig_rlovr_rl
    ,p_mx_rchd_dflt_ordr_num         => p_mx_rchd_dflt_ordr_num
    ,p_pct_rlovr_incrmt_num          => p_pct_rlovr_incrmt_num
    ,p_mn_rlovr_pct_num              => p_mn_rlovr_pct_num
    ,p_mx_rlovr_pct_num              => p_mx_rlovr_pct_num
    ,p_crs_rlovr_procg_cd            => p_crs_rlovr_procg_cd
    ,p_mx_pct_ttl_crs_cn_roll_num    => p_mx_pct_ttl_crs_cn_roll_num
    ,p_bnft_prvdr_pool_id            => p_bnft_prvdr_pool_id
    ,p_acty_base_rt_id               => p_acty_base_rt_id
    ,p_business_group_id             => p_business_group_id
    ,p_bpr_attribute_category        => p_bpr_attribute_category
    ,p_bpr_attribute1                => p_bpr_attribute1
    ,p_bpr_attribute2                => p_bpr_attribute2
    ,p_bpr_attribute3                => p_bpr_attribute3
    ,p_bpr_attribute4                => p_bpr_attribute4
    ,p_bpr_attribute5                => p_bpr_attribute5
    ,p_bpr_attribute6                => p_bpr_attribute6
    ,p_bpr_attribute7                => p_bpr_attribute7
    ,p_bpr_attribute8                => p_bpr_attribute8
    ,p_bpr_attribute9                => p_bpr_attribute9
    ,p_bpr_attribute10               => p_bpr_attribute10
    ,p_bpr_attribute11               => p_bpr_attribute11
    ,p_bpr_attribute12               => p_bpr_attribute12
    ,p_bpr_attribute13               => p_bpr_attribute13
    ,p_bpr_attribute14               => p_bpr_attribute14
    ,p_bpr_attribute15               => p_bpr_attribute15
    ,p_bpr_attribute16               => p_bpr_attribute16
    ,p_bpr_attribute17               => p_bpr_attribute17
    ,p_bpr_attribute18               => p_bpr_attribute18
    ,p_bpr_attribute19               => p_bpr_attribute19
    ,p_bpr_attribute20               => p_bpr_attribute20
    ,p_bpr_attribute21               => p_bpr_attribute21
    ,p_bpr_attribute22               => p_bpr_attribute22
    ,p_bpr_attribute23               => p_bpr_attribute23
    ,p_bpr_attribute24               => p_bpr_attribute24
    ,p_bpr_attribute25               => p_bpr_attribute25
    ,p_bpr_attribute26               => p_bpr_attribute26
    ,p_bpr_attribute27               => p_bpr_attribute27
    ,p_bpr_attribute28               => p_bpr_attribute28
    ,p_bpr_attribute29               => p_bpr_attribute29
    ,p_bpr_attribute30               => p_bpr_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_Bnft_Pool_Rlovr_Rqmt
    --
    ben_Bnft_Pool_Rlovr_Rqmt_bk1.create_Bnft_Pool_Rlovr_Rqmt_a
      (
       p_bnft_pool_rlovr_rqmt_id        =>  l_bnft_pool_rlovr_rqmt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_no_mn_rlovr_pct_dfnd_flag      =>  p_no_mn_rlovr_pct_dfnd_flag
      ,p_no_mx_rlovr_pct_dfnd_flag      =>  p_no_mx_rlovr_pct_dfnd_flag
      ,p_no_mn_rlovr_val_dfnd_flag      =>  p_no_mn_rlovr_val_dfnd_flag
      ,p_no_mx_rlovr_val_dfnd_flag      =>  p_no_mx_rlovr_val_dfnd_flag
      ,p_rlovr_val_incrmt_num           =>  p_rlovr_val_incrmt_num
      ,p_rlovr_val_rl                   =>  p_rlovr_val_rl
      ,p_mn_rlovr_val                   =>  p_mn_rlovr_val
      ,p_mx_rlovr_val                   =>  p_mx_rlovr_val
      ,p_val_rndg_cd                    =>  p_val_rndg_cd
      ,p_val_rndg_rl                    =>  p_val_rndg_rl
      ,p_pct_rndg_cd                    =>  p_pct_rndg_cd
      ,p_pct_rndg_rl                    =>  p_pct_rndg_rl
      ,p_prtt_elig_rlovr_rl             =>  p_prtt_elig_rlovr_rl
      ,p_mx_rchd_dflt_ordr_num          =>  p_mx_rchd_dflt_ordr_num
      ,p_pct_rlovr_incrmt_num           =>  p_pct_rlovr_incrmt_num
      ,p_mn_rlovr_pct_num               =>  p_mn_rlovr_pct_num
      ,p_mx_rlovr_pct_num               =>  p_mx_rlovr_pct_num
      ,p_crs_rlovr_procg_cd             =>  p_crs_rlovr_procg_cd
      ,p_mx_pct_ttl_crs_cn_roll_num     =>  p_mx_pct_ttl_crs_cn_roll_num
      ,p_bnft_prvdr_pool_id             =>  p_bnft_prvdr_pool_id
      ,p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_bpr_attribute_category         =>  p_bpr_attribute_category
      ,p_bpr_attribute1                 =>  p_bpr_attribute1
      ,p_bpr_attribute2                 =>  p_bpr_attribute2
      ,p_bpr_attribute3                 =>  p_bpr_attribute3
      ,p_bpr_attribute4                 =>  p_bpr_attribute4
      ,p_bpr_attribute5                 =>  p_bpr_attribute5
      ,p_bpr_attribute6                 =>  p_bpr_attribute6
      ,p_bpr_attribute7                 =>  p_bpr_attribute7
      ,p_bpr_attribute8                 =>  p_bpr_attribute8
      ,p_bpr_attribute9                 =>  p_bpr_attribute9
      ,p_bpr_attribute10                =>  p_bpr_attribute10
      ,p_bpr_attribute11                =>  p_bpr_attribute11
      ,p_bpr_attribute12                =>  p_bpr_attribute12
      ,p_bpr_attribute13                =>  p_bpr_attribute13
      ,p_bpr_attribute14                =>  p_bpr_attribute14
      ,p_bpr_attribute15                =>  p_bpr_attribute15
      ,p_bpr_attribute16                =>  p_bpr_attribute16
      ,p_bpr_attribute17                =>  p_bpr_attribute17
      ,p_bpr_attribute18                =>  p_bpr_attribute18
      ,p_bpr_attribute19                =>  p_bpr_attribute19
      ,p_bpr_attribute20                =>  p_bpr_attribute20
      ,p_bpr_attribute21                =>  p_bpr_attribute21
      ,p_bpr_attribute22                =>  p_bpr_attribute22
      ,p_bpr_attribute23                =>  p_bpr_attribute23
      ,p_bpr_attribute24                =>  p_bpr_attribute24
      ,p_bpr_attribute25                =>  p_bpr_attribute25
      ,p_bpr_attribute26                =>  p_bpr_attribute26
      ,p_bpr_attribute27                =>  p_bpr_attribute27
      ,p_bpr_attribute28                =>  p_bpr_attribute28
      ,p_bpr_attribute29                =>  p_bpr_attribute29
      ,p_bpr_attribute30                =>  p_bpr_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_Bnft_Pool_Rlovr_Rqmt'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_Bnft_Pool_Rlovr_Rqmt
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
  p_bnft_pool_rlovr_rqmt_id := l_bnft_pool_rlovr_rqmt_id;
  p_effective_start_date := l_effective_start_date;
  p_effective_end_date := l_effective_end_date;
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
    ROLLBACK TO create_Bnft_Pool_Rlovr_Rqmt;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_bnft_pool_rlovr_rqmt_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_Bnft_Pool_Rlovr_Rqmt;
    raise;
    --
end create_Bnft_Pool_Rlovr_Rqmt;
-- ----------------------------------------------------------------------------
-- |------------------------< update_Bnft_Pool_Rlovr_Rqmt >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_Bnft_Pool_Rlovr_Rqmt
  (p_validate                       in  boolean   default false
  ,p_bnft_pool_rlovr_rqmt_id        in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_no_mn_rlovr_pct_dfnd_flag      in  varchar2  default hr_api.g_varchar2
  ,p_no_mx_rlovr_pct_dfnd_flag      in  varchar2  default hr_api.g_varchar2
  ,p_no_mn_rlovr_val_dfnd_flag      in  varchar2  default hr_api.g_varchar2
  ,p_no_mx_rlovr_val_dfnd_flag      in  varchar2  default hr_api.g_varchar2
  ,p_rlovr_val_incrmt_num           in  number    default hr_api.g_number
  ,p_rlovr_val_rl                   in  number    default hr_api.g_number
  ,p_mn_rlovr_val                   in  number    default hr_api.g_number
  ,p_mx_rlovr_val                   in  number    default hr_api.g_number
  ,p_val_rndg_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_val_rndg_rl                    in  number    default hr_api.g_number
  ,p_pct_rndg_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_pct_rndg_rl                    in  number    default hr_api.g_number
  ,p_prtt_elig_rlovr_rl             in  number    default hr_api.g_number
  ,p_mx_rchd_dflt_ordr_num          in  number    default hr_api.g_number
  ,p_pct_rlovr_incrmt_num           in  number    default hr_api.g_number
  ,p_mn_rlovr_pct_num               in  number    default hr_api.g_number
  ,p_mx_rlovr_pct_num               in  number    default hr_api.g_number
  ,p_crs_rlovr_procg_cd             in  varchar2  default hr_api.g_varchar2
  ,p_mx_pct_ttl_crs_cn_roll_num     in  number    default hr_api.g_number
  ,p_bnft_prvdr_pool_id             in  number    default hr_api.g_number
  ,p_acty_base_rt_id                in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_bpr_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_bpr_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_bpr_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_bpr_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_bpr_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_bpr_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_bpr_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_bpr_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_bpr_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_bpr_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_bpr_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_bpr_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_bpr_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_bpr_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_bpr_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_bpr_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_bpr_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_bpr_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_bpr_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_bpr_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_bpr_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_bpr_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_bpr_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_bpr_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_bpr_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_bpr_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_bpr_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_bpr_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_bpr_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_bpr_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_bpr_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Bnft_Pool_Rlovr_Rqmt';
  l_object_version_number ben_bnft_pool_rlovr_rqmt_f.object_version_number%TYPE;
  l_effective_start_date ben_bnft_pool_rlovr_rqmt_f.effective_start_date%TYPE;
  l_effective_end_date ben_bnft_pool_rlovr_rqmt_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_Bnft_Pool_Rlovr_Rqmt;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_Bnft_Pool_Rlovr_Rqmt
    --
    ben_Bnft_Pool_Rlovr_Rqmt_bk2.update_Bnft_Pool_Rlovr_Rqmt_b
      (
       p_bnft_pool_rlovr_rqmt_id        =>  p_bnft_pool_rlovr_rqmt_id
      ,p_no_mn_rlovr_pct_dfnd_flag      =>  p_no_mn_rlovr_pct_dfnd_flag
      ,p_no_mx_rlovr_pct_dfnd_flag      =>  p_no_mx_rlovr_pct_dfnd_flag
      ,p_no_mn_rlovr_val_dfnd_flag      =>  p_no_mn_rlovr_val_dfnd_flag
      ,p_no_mx_rlovr_val_dfnd_flag      =>  p_no_mx_rlovr_val_dfnd_flag
      ,p_rlovr_val_incrmt_num           =>  p_rlovr_val_incrmt_num
      ,p_rlovr_val_rl                   =>  p_rlovr_val_rl
      ,p_mn_rlovr_val                   =>  p_mn_rlovr_val
      ,p_mx_rlovr_val                   =>  p_mx_rlovr_val
      ,p_val_rndg_cd                    =>  p_val_rndg_cd
      ,p_val_rndg_rl                    =>  p_val_rndg_rl
      ,p_pct_rndg_cd                    =>  p_pct_rndg_cd
      ,p_pct_rndg_rl                    =>  p_pct_rndg_rl
      ,p_prtt_elig_rlovr_rl             =>  p_prtt_elig_rlovr_rl
      ,p_mx_rchd_dflt_ordr_num          =>  p_mx_rchd_dflt_ordr_num
      ,p_pct_rlovr_incrmt_num           =>  p_pct_rlovr_incrmt_num
      ,p_mn_rlovr_pct_num               =>  p_mn_rlovr_pct_num
      ,p_mx_rlovr_pct_num               =>  p_mx_rlovr_pct_num
      ,p_crs_rlovr_procg_cd             =>  p_crs_rlovr_procg_cd
      ,p_mx_pct_ttl_crs_cn_roll_num     =>  p_mx_pct_ttl_crs_cn_roll_num
      ,p_bnft_prvdr_pool_id             =>  p_bnft_prvdr_pool_id
      ,p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_bpr_attribute_category         =>  p_bpr_attribute_category
      ,p_bpr_attribute1                 =>  p_bpr_attribute1
      ,p_bpr_attribute2                 =>  p_bpr_attribute2
      ,p_bpr_attribute3                 =>  p_bpr_attribute3
      ,p_bpr_attribute4                 =>  p_bpr_attribute4
      ,p_bpr_attribute5                 =>  p_bpr_attribute5
      ,p_bpr_attribute6                 =>  p_bpr_attribute6
      ,p_bpr_attribute7                 =>  p_bpr_attribute7
      ,p_bpr_attribute8                 =>  p_bpr_attribute8
      ,p_bpr_attribute9                 =>  p_bpr_attribute9
      ,p_bpr_attribute10                =>  p_bpr_attribute10
      ,p_bpr_attribute11                =>  p_bpr_attribute11
      ,p_bpr_attribute12                =>  p_bpr_attribute12
      ,p_bpr_attribute13                =>  p_bpr_attribute13
      ,p_bpr_attribute14                =>  p_bpr_attribute14
      ,p_bpr_attribute15                =>  p_bpr_attribute15
      ,p_bpr_attribute16                =>  p_bpr_attribute16
      ,p_bpr_attribute17                =>  p_bpr_attribute17
      ,p_bpr_attribute18                =>  p_bpr_attribute18
      ,p_bpr_attribute19                =>  p_bpr_attribute19
      ,p_bpr_attribute20                =>  p_bpr_attribute20
      ,p_bpr_attribute21                =>  p_bpr_attribute21
      ,p_bpr_attribute22                =>  p_bpr_attribute22
      ,p_bpr_attribute23                =>  p_bpr_attribute23
      ,p_bpr_attribute24                =>  p_bpr_attribute24
      ,p_bpr_attribute25                =>  p_bpr_attribute25
      ,p_bpr_attribute26                =>  p_bpr_attribute26
      ,p_bpr_attribute27                =>  p_bpr_attribute27
      ,p_bpr_attribute28                =>  p_bpr_attribute28
      ,p_bpr_attribute29                =>  p_bpr_attribute29
      ,p_bpr_attribute30                =>  p_bpr_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Bnft_Pool_Rlovr_Rqmt'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_Bnft_Pool_Rlovr_Rqmt
    --
  end;
  --
  ben_bpr_upd.upd
    (
     p_bnft_pool_rlovr_rqmt_id       => p_bnft_pool_rlovr_rqmt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_no_mn_rlovr_pct_dfnd_flag     => p_no_mn_rlovr_pct_dfnd_flag
    ,p_no_mx_rlovr_pct_dfnd_flag     => p_no_mx_rlovr_pct_dfnd_flag
    ,p_no_mn_rlovr_val_dfnd_flag     => p_no_mn_rlovr_val_dfnd_flag
    ,p_no_mx_rlovr_val_dfnd_flag     => p_no_mx_rlovr_val_dfnd_flag
    ,p_rlovr_val_incrmt_num          => p_rlovr_val_incrmt_num
    ,p_rlovr_val_rl                  => p_rlovr_val_rl
    ,p_mn_rlovr_val                  => p_mn_rlovr_val
    ,p_mx_rlovr_val                  => p_mx_rlovr_val
    ,p_val_rndg_cd                   => p_val_rndg_cd
    ,p_val_rndg_rl                   => p_val_rndg_rl
    ,p_pct_rndg_cd                   => p_pct_rndg_cd
    ,p_pct_rndg_rl                   => p_pct_rndg_rl
    ,p_prtt_elig_rlovr_rl            => p_prtt_elig_rlovr_rl
    ,p_mx_rchd_dflt_ordr_num         => p_mx_rchd_dflt_ordr_num
    ,p_pct_rlovr_incrmt_num          => p_pct_rlovr_incrmt_num
    ,p_mn_rlovr_pct_num              => p_mn_rlovr_pct_num
    ,p_mx_rlovr_pct_num              => p_mx_rlovr_pct_num
    ,p_crs_rlovr_procg_cd            => p_crs_rlovr_procg_cd
    ,p_mx_pct_ttl_crs_cn_roll_num    => p_mx_pct_ttl_crs_cn_roll_num
    ,p_bnft_prvdr_pool_id            => p_bnft_prvdr_pool_id
    ,p_acty_base_rt_id               => p_acty_base_rt_id
    ,p_business_group_id             => p_business_group_id
    ,p_bpr_attribute_category        => p_bpr_attribute_category
    ,p_bpr_attribute1                => p_bpr_attribute1
    ,p_bpr_attribute2                => p_bpr_attribute2
    ,p_bpr_attribute3                => p_bpr_attribute3
    ,p_bpr_attribute4                => p_bpr_attribute4
    ,p_bpr_attribute5                => p_bpr_attribute5
    ,p_bpr_attribute6                => p_bpr_attribute6
    ,p_bpr_attribute7                => p_bpr_attribute7
    ,p_bpr_attribute8                => p_bpr_attribute8
    ,p_bpr_attribute9                => p_bpr_attribute9
    ,p_bpr_attribute10               => p_bpr_attribute10
    ,p_bpr_attribute11               => p_bpr_attribute11
    ,p_bpr_attribute12               => p_bpr_attribute12
    ,p_bpr_attribute13               => p_bpr_attribute13
    ,p_bpr_attribute14               => p_bpr_attribute14
    ,p_bpr_attribute15               => p_bpr_attribute15
    ,p_bpr_attribute16               => p_bpr_attribute16
    ,p_bpr_attribute17               => p_bpr_attribute17
    ,p_bpr_attribute18               => p_bpr_attribute18
    ,p_bpr_attribute19               => p_bpr_attribute19
    ,p_bpr_attribute20               => p_bpr_attribute20
    ,p_bpr_attribute21               => p_bpr_attribute21
    ,p_bpr_attribute22               => p_bpr_attribute22
    ,p_bpr_attribute23               => p_bpr_attribute23
    ,p_bpr_attribute24               => p_bpr_attribute24
    ,p_bpr_attribute25               => p_bpr_attribute25
    ,p_bpr_attribute26               => p_bpr_attribute26
    ,p_bpr_attribute27               => p_bpr_attribute27
    ,p_bpr_attribute28               => p_bpr_attribute28
    ,p_bpr_attribute29               => p_bpr_attribute29
    ,p_bpr_attribute30               => p_bpr_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_Bnft_Pool_Rlovr_Rqmt
    --
    ben_Bnft_Pool_Rlovr_Rqmt_bk2.update_Bnft_Pool_Rlovr_Rqmt_a
      (
       p_bnft_pool_rlovr_rqmt_id        =>  p_bnft_pool_rlovr_rqmt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_no_mn_rlovr_pct_dfnd_flag      =>  p_no_mn_rlovr_pct_dfnd_flag
      ,p_no_mx_rlovr_pct_dfnd_flag      =>  p_no_mx_rlovr_pct_dfnd_flag
      ,p_no_mn_rlovr_val_dfnd_flag      =>  p_no_mn_rlovr_val_dfnd_flag
      ,p_no_mx_rlovr_val_dfnd_flag      =>  p_no_mx_rlovr_val_dfnd_flag
      ,p_rlovr_val_incrmt_num           =>  p_rlovr_val_incrmt_num
      ,p_rlovr_val_rl                   =>  p_rlovr_val_rl
      ,p_mn_rlovr_val                   =>  p_mn_rlovr_val
      ,p_mx_rlovr_val                   =>  p_mx_rlovr_val
      ,p_val_rndg_cd                    =>  p_val_rndg_cd
      ,p_val_rndg_rl                    =>  p_val_rndg_rl
      ,p_pct_rndg_cd                    =>  p_pct_rndg_cd
      ,p_pct_rndg_rl                    =>  p_pct_rndg_rl
      ,p_prtt_elig_rlovr_rl             =>  p_prtt_elig_rlovr_rl
      ,p_mx_rchd_dflt_ordr_num          =>  p_mx_rchd_dflt_ordr_num
      ,p_pct_rlovr_incrmt_num           =>  p_pct_rlovr_incrmt_num
      ,p_mn_rlovr_pct_num               =>  p_mn_rlovr_pct_num
      ,p_mx_rlovr_pct_num               =>  p_mx_rlovr_pct_num
      ,p_crs_rlovr_procg_cd             =>  p_crs_rlovr_procg_cd
      ,p_mx_pct_ttl_crs_cn_roll_num     =>  p_mx_pct_ttl_crs_cn_roll_num
      ,p_bnft_prvdr_pool_id             =>  p_bnft_prvdr_pool_id
      ,p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_bpr_attribute_category         =>  p_bpr_attribute_category
      ,p_bpr_attribute1                 =>  p_bpr_attribute1
      ,p_bpr_attribute2                 =>  p_bpr_attribute2
      ,p_bpr_attribute3                 =>  p_bpr_attribute3
      ,p_bpr_attribute4                 =>  p_bpr_attribute4
      ,p_bpr_attribute5                 =>  p_bpr_attribute5
      ,p_bpr_attribute6                 =>  p_bpr_attribute6
      ,p_bpr_attribute7                 =>  p_bpr_attribute7
      ,p_bpr_attribute8                 =>  p_bpr_attribute8
      ,p_bpr_attribute9                 =>  p_bpr_attribute9
      ,p_bpr_attribute10                =>  p_bpr_attribute10
      ,p_bpr_attribute11                =>  p_bpr_attribute11
      ,p_bpr_attribute12                =>  p_bpr_attribute12
      ,p_bpr_attribute13                =>  p_bpr_attribute13
      ,p_bpr_attribute14                =>  p_bpr_attribute14
      ,p_bpr_attribute15                =>  p_bpr_attribute15
      ,p_bpr_attribute16                =>  p_bpr_attribute16
      ,p_bpr_attribute17                =>  p_bpr_attribute17
      ,p_bpr_attribute18                =>  p_bpr_attribute18
      ,p_bpr_attribute19                =>  p_bpr_attribute19
      ,p_bpr_attribute20                =>  p_bpr_attribute20
      ,p_bpr_attribute21                =>  p_bpr_attribute21
      ,p_bpr_attribute22                =>  p_bpr_attribute22
      ,p_bpr_attribute23                =>  p_bpr_attribute23
      ,p_bpr_attribute24                =>  p_bpr_attribute24
      ,p_bpr_attribute25                =>  p_bpr_attribute25
      ,p_bpr_attribute26                =>  p_bpr_attribute26
      ,p_bpr_attribute27                =>  p_bpr_attribute27
      ,p_bpr_attribute28                =>  p_bpr_attribute28
      ,p_bpr_attribute29                =>  p_bpr_attribute29
      ,p_bpr_attribute30                =>  p_bpr_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Bnft_Pool_Rlovr_Rqmt'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_Bnft_Pool_Rlovr_Rqmt
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
  p_effective_start_date := l_effective_start_date;
  p_effective_end_date := l_effective_end_date;
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
    ROLLBACK TO update_Bnft_Pool_Rlovr_Rqmt;
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
    ROLLBACK TO update_Bnft_Pool_Rlovr_Rqmt;
    raise;
    --
end update_Bnft_Pool_Rlovr_Rqmt;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Bnft_Pool_Rlovr_Rqmt >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Bnft_Pool_Rlovr_Rqmt
  (p_validate                       in  boolean  default false
  ,p_bnft_pool_rlovr_rqmt_id        in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Bnft_Pool_Rlovr_Rqmt';
  l_object_version_number ben_bnft_pool_rlovr_rqmt_f.object_version_number%TYPE;
  l_effective_start_date ben_bnft_pool_rlovr_rqmt_f.effective_start_date%TYPE;
  l_effective_end_date ben_bnft_pool_rlovr_rqmt_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_Bnft_Pool_Rlovr_Rqmt;
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
    -- Start of API User Hook for the before hook of delete_Bnft_Pool_Rlovr_Rqmt
    --
    ben_Bnft_Pool_Rlovr_Rqmt_bk3.delete_Bnft_Pool_Rlovr_Rqmt_b
      (
       p_bnft_pool_rlovr_rqmt_id        =>  p_bnft_pool_rlovr_rqmt_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Bnft_Pool_Rlovr_Rqmt'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_Bnft_Pool_Rlovr_Rqmt
    --
  end;
  --
  ben_bpr_del.del
    (
     p_bnft_pool_rlovr_rqmt_id       => p_bnft_pool_rlovr_rqmt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_Bnft_Pool_Rlovr_Rqmt
    --
    ben_Bnft_Pool_Rlovr_Rqmt_bk3.delete_Bnft_Pool_Rlovr_Rqmt_a
      (
       p_bnft_pool_rlovr_rqmt_id        =>  p_bnft_pool_rlovr_rqmt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Bnft_Pool_Rlovr_Rqmt'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_Bnft_Pool_Rlovr_Rqmt
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
    ROLLBACK TO delete_Bnft_Pool_Rlovr_Rqmt;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_start_date := null;
    p_effective_end_date := null;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_Bnft_Pool_Rlovr_Rqmt;
    raise;
    --
end delete_Bnft_Pool_Rlovr_Rqmt;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_bnft_pool_rlovr_rqmt_id                   in     number
  ,p_object_version_number          in     number
  ,p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  ,p_validation_start_date          out nocopy    date
  ,p_validation_end_date            out nocopy    date
  ) is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'lck';
  l_validation_start_date date;
  l_validation_end_date date;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  ben_bpr_shd.lck
    (
      p_bnft_pool_rlovr_rqmt_id                 => p_bnft_pool_rlovr_rqmt_id
     ,p_validation_start_date      => l_validation_start_date
     ,p_validation_end_date        => l_validation_end_date
     ,p_object_version_number      => p_object_version_number
     ,p_effective_date             => p_effective_date
     ,p_datetrack_mode             => p_datetrack_mode
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_Bnft_Pool_Rlovr_Rqmt_api;

/
