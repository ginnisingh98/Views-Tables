--------------------------------------------------------
--  DDL for Package Body BEN_HRS_WKD_IN_PERD_FCTR_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_HRS_WKD_IN_PERD_FCTR_API" as
/* $Header: behwfapi.pkb 120.0 2005/05/28 03:11:51 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_hrs_wkd_in_perd_fctr_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_hrs_wkd_in_perd_fctr >-------------------|
-- ----------------------------------------------------------------------------
--
procedure create_hrs_wkd_in_perd_fctr
  (p_validate                       in  boolean   default false
  ,p_hrs_wkd_in_perd_fctr_id        out nocopy number
  ,p_name                           in  varchar2  default null
  ,p_business_group_id              in  number    default null
  ,p_hrs_src_cd                     in  varchar2  default null
  ,p_rndg_cd                        in  varchar2  default null
  ,p_rndg_rl                        in  number    default null
  ,p_hrs_wkd_det_cd                 in  varchar2  default null
  ,p_hrs_wkd_det_rl                 in  number    default null
  ,p_no_mn_hrs_wkd_flag             in  varchar2  default null
  ,p_mx_hrs_num                     in  number    default null
  ,p_no_mx_hrs_wkd_flag             in  varchar2  default null
  ,p_once_r_cntug_cd                in  varchar2  default null
  ,p_mn_hrs_num                     in  number    default null
  ,p_hrs_alt_val_to_use_cd          in  varchar2  default null
  ,p_pyrl_freq_cd                   in  varchar2  default null
  ,p_hrs_wkd_calc_rl                in  number    default null
  ,p_defined_balance_id             in  number    default null
  ,p_bnfts_bal_id                   in  number    default null
  ,p_hwf_attribute_category         in  varchar2  default null
  ,p_hwf_attribute1                 in  varchar2  default null
  ,p_hwf_attribute2                 in  varchar2  default null
  ,p_hwf_attribute3                 in  varchar2  default null
  ,p_hwf_attribute4                 in  varchar2  default null
  ,p_hwf_attribute5                 in  varchar2  default null
  ,p_hwf_attribute6                 in  varchar2  default null
  ,p_hwf_attribute7                 in  varchar2  default null
  ,p_hwf_attribute8                 in  varchar2  default null
  ,p_hwf_attribute9                 in  varchar2  default null
  ,p_hwf_attribute10                in  varchar2  default null
  ,p_hwf_attribute11                in  varchar2  default null
  ,p_hwf_attribute12                in  varchar2  default null
  ,p_hwf_attribute13                in  varchar2  default null
  ,p_hwf_attribute14                in  varchar2  default null
  ,p_hwf_attribute15                in  varchar2  default null
  ,p_hwf_attribute16                in  varchar2  default null
  ,p_hwf_attribute17                in  varchar2  default null
  ,p_hwf_attribute18                in  varchar2  default null
  ,p_hwf_attribute19                in  varchar2  default null
  ,p_hwf_attribute20                in  varchar2  default null
  ,p_hwf_attribute21                in  varchar2  default null
  ,p_hwf_attribute22                in  varchar2  default null
  ,p_hwf_attribute23                in  varchar2  default null
  ,p_hwf_attribute24                in  varchar2  default null
  ,p_hwf_attribute25                in  varchar2  default null
  ,p_hwf_attribute26                in  varchar2  default null
  ,p_hwf_attribute27                in  varchar2  default null
  ,p_hwf_attribute28                in  varchar2  default null
  ,p_hwf_attribute29                in  varchar2  default null
  ,p_hwf_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_hrs_wkd_in_perd_fctr_id ben_hrs_wkd_in_perd_fctr.hrs_wkd_in_perd_fctr_id%TYPE;
  l_proc varchar2(72) := g_package||'create_hrs_wkd_in_perd_fctr';
  l_object_version_number ben_hrs_wkd_in_perd_fctr.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_hrs_wkd_in_perd_fctr;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_hrs_wkd_in_perd_fctr
    --
    ben_hrs_wkd_in_perd_fctr_bk1.create_hrs_wkd_in_perd_fctr_b
      (
       p_name                           =>  p_name
      ,p_business_group_id              =>  p_business_group_id
      ,p_hrs_src_cd                     =>  p_hrs_src_cd
      ,p_rndg_cd                        =>  p_rndg_cd
      ,p_rndg_rl                        =>  p_rndg_rl
      ,p_hrs_wkd_det_cd                 =>  p_hrs_wkd_det_cd
      ,p_hrs_wkd_det_rl                 =>  p_hrs_wkd_det_rl
      ,p_no_mn_hrs_wkd_flag             =>  p_no_mn_hrs_wkd_flag
      ,p_mx_hrs_num                     =>  p_mx_hrs_num
      ,p_no_mx_hrs_wkd_flag             =>  p_no_mx_hrs_wkd_flag
      ,p_once_r_cntug_cd                =>  p_once_r_cntug_cd
      ,p_mn_hrs_num                     =>  p_mn_hrs_num
      ,p_hrs_alt_val_to_use_cd          =>  p_hrs_alt_val_to_use_cd
      ,p_pyrl_freq_cd                   =>  p_pyrl_freq_cd
      ,p_hrs_wkd_calc_rl                =>  p_hrs_wkd_calc_rl
      ,p_defined_balance_id             =>  p_defined_balance_id
      ,p_bnfts_bal_id                   =>  p_bnfts_bal_id
      ,p_hwf_attribute_category         =>  p_hwf_attribute_category
      ,p_hwf_attribute1                 =>  p_hwf_attribute1
      ,p_hwf_attribute2                 =>  p_hwf_attribute2
      ,p_hwf_attribute3                 =>  p_hwf_attribute3
      ,p_hwf_attribute4                 =>  p_hwf_attribute4
      ,p_hwf_attribute5                 =>  p_hwf_attribute5
      ,p_hwf_attribute6                 =>  p_hwf_attribute6
      ,p_hwf_attribute7                 =>  p_hwf_attribute7
      ,p_hwf_attribute8                 =>  p_hwf_attribute8
      ,p_hwf_attribute9                 =>  p_hwf_attribute9
      ,p_hwf_attribute10                =>  p_hwf_attribute10
      ,p_hwf_attribute11                =>  p_hwf_attribute11
      ,p_hwf_attribute12                =>  p_hwf_attribute12
      ,p_hwf_attribute13                =>  p_hwf_attribute13
      ,p_hwf_attribute14                =>  p_hwf_attribute14
      ,p_hwf_attribute15                =>  p_hwf_attribute15
      ,p_hwf_attribute16                =>  p_hwf_attribute16
      ,p_hwf_attribute17                =>  p_hwf_attribute17
      ,p_hwf_attribute18                =>  p_hwf_attribute18
      ,p_hwf_attribute19                =>  p_hwf_attribute19
      ,p_hwf_attribute20                =>  p_hwf_attribute20
      ,p_hwf_attribute21                =>  p_hwf_attribute21
      ,p_hwf_attribute22                =>  p_hwf_attribute22
      ,p_hwf_attribute23                =>  p_hwf_attribute23
      ,p_hwf_attribute24                =>  p_hwf_attribute24
      ,p_hwf_attribute25                =>  p_hwf_attribute25
      ,p_hwf_attribute26                =>  p_hwf_attribute26
      ,p_hwf_attribute27                =>  p_hwf_attribute27
      ,p_hwf_attribute28                =>  p_hwf_attribute28
      ,p_hwf_attribute29                =>  p_hwf_attribute29
      ,p_hwf_attribute30                =>  p_hwf_attribute30
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_hrs_wkd_in_perd_fctr'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_hrs_wkd_in_perd_fctr
    --
  end;
  --
  ben_hwf_ins.ins
    (
     p_hrs_wkd_in_perd_fctr_id       => l_hrs_wkd_in_perd_fctr_id
    ,p_name                          => p_name
    ,p_business_group_id             => p_business_group_id
    ,p_hrs_src_cd                    => p_hrs_src_cd
    ,p_rndg_cd                       => p_rndg_cd
    ,p_rndg_rl                       => p_rndg_rl
    ,p_hrs_wkd_det_cd                => p_hrs_wkd_det_cd
    ,p_hrs_wkd_det_rl                => p_hrs_wkd_det_rl
    ,p_no_mn_hrs_wkd_flag            => p_no_mn_hrs_wkd_flag
    ,p_mx_hrs_num                    => p_mx_hrs_num
    ,p_no_mx_hrs_wkd_flag            => p_no_mx_hrs_wkd_flag
    ,p_once_r_cntug_cd               => p_once_r_cntug_cd
    ,p_mn_hrs_num                    => p_mn_hrs_num
    ,p_hrs_alt_val_to_use_cd         => p_hrs_alt_val_to_use_cd
    ,p_pyrl_freq_cd                  => p_pyrl_freq_cd
    ,p_hrs_wkd_calc_rl               => p_hrs_wkd_calc_rl
    ,p_defined_balance_id            => p_defined_balance_id
    ,p_bnfts_bal_id                  => p_bnfts_bal_id
    ,p_hwf_attribute_category        => p_hwf_attribute_category
    ,p_hwf_attribute1                => p_hwf_attribute1
    ,p_hwf_attribute2                => p_hwf_attribute2
    ,p_hwf_attribute3                => p_hwf_attribute3
    ,p_hwf_attribute4                => p_hwf_attribute4
    ,p_hwf_attribute5                => p_hwf_attribute5
    ,p_hwf_attribute6                => p_hwf_attribute6
    ,p_hwf_attribute7                => p_hwf_attribute7
    ,p_hwf_attribute8                => p_hwf_attribute8
    ,p_hwf_attribute9                => p_hwf_attribute9
    ,p_hwf_attribute10               => p_hwf_attribute10
    ,p_hwf_attribute11               => p_hwf_attribute11
    ,p_hwf_attribute12               => p_hwf_attribute12
    ,p_hwf_attribute13               => p_hwf_attribute13
    ,p_hwf_attribute14               => p_hwf_attribute14
    ,p_hwf_attribute15               => p_hwf_attribute15
    ,p_hwf_attribute16               => p_hwf_attribute16
    ,p_hwf_attribute17               => p_hwf_attribute17
    ,p_hwf_attribute18               => p_hwf_attribute18
    ,p_hwf_attribute19               => p_hwf_attribute19
    ,p_hwf_attribute20               => p_hwf_attribute20
    ,p_hwf_attribute21               => p_hwf_attribute21
    ,p_hwf_attribute22               => p_hwf_attribute22
    ,p_hwf_attribute23               => p_hwf_attribute23
    ,p_hwf_attribute24               => p_hwf_attribute24
    ,p_hwf_attribute25               => p_hwf_attribute25
    ,p_hwf_attribute26               => p_hwf_attribute26
    ,p_hwf_attribute27               => p_hwf_attribute27
    ,p_hwf_attribute28               => p_hwf_attribute28
    ,p_hwf_attribute29               => p_hwf_attribute29
    ,p_hwf_attribute30               => p_hwf_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_hrs_wkd_in_perd_fctr
    --
    ben_hrs_wkd_in_perd_fctr_bk1.create_hrs_wkd_in_perd_fctr_a
      (
       p_hrs_wkd_in_perd_fctr_id        =>  l_hrs_wkd_in_perd_fctr_id
      ,p_name                           =>  p_name
      ,p_business_group_id              =>  p_business_group_id
      ,p_hrs_src_cd                     =>  p_hrs_src_cd
      ,p_rndg_cd                        =>  p_rndg_cd
      ,p_rndg_rl                        =>  p_rndg_rl
      ,p_hrs_wkd_det_cd                 =>  p_hrs_wkd_det_cd
      ,p_hrs_wkd_det_rl                 =>  p_hrs_wkd_det_rl
      ,p_no_mn_hrs_wkd_flag             =>  p_no_mn_hrs_wkd_flag
      ,p_mx_hrs_num                     =>  p_mx_hrs_num
      ,p_no_mx_hrs_wkd_flag             =>  p_no_mx_hrs_wkd_flag
      ,p_once_r_cntug_cd                =>  p_once_r_cntug_cd
      ,p_mn_hrs_num                     =>  p_mn_hrs_num
      ,p_hrs_alt_val_to_use_cd          =>  p_hrs_alt_val_to_use_cd
      ,p_pyrl_freq_cd                   =>  p_pyrl_freq_cd
      ,p_hrs_wkd_calc_rl                =>  p_hrs_wkd_calc_rl
      ,p_defined_balance_id             =>  p_defined_balance_id
      ,p_bnfts_bal_id                   =>  p_bnfts_bal_id
      ,p_hwf_attribute_category         =>  p_hwf_attribute_category
      ,p_hwf_attribute1                 =>  p_hwf_attribute1
      ,p_hwf_attribute2                 =>  p_hwf_attribute2
      ,p_hwf_attribute3                 =>  p_hwf_attribute3
      ,p_hwf_attribute4                 =>  p_hwf_attribute4
      ,p_hwf_attribute5                 =>  p_hwf_attribute5
      ,p_hwf_attribute6                 =>  p_hwf_attribute6
      ,p_hwf_attribute7                 =>  p_hwf_attribute7
      ,p_hwf_attribute8                 =>  p_hwf_attribute8
      ,p_hwf_attribute9                 =>  p_hwf_attribute9
      ,p_hwf_attribute10                =>  p_hwf_attribute10
      ,p_hwf_attribute11                =>  p_hwf_attribute11
      ,p_hwf_attribute12                =>  p_hwf_attribute12
      ,p_hwf_attribute13                =>  p_hwf_attribute13
      ,p_hwf_attribute14                =>  p_hwf_attribute14
      ,p_hwf_attribute15                =>  p_hwf_attribute15
      ,p_hwf_attribute16                =>  p_hwf_attribute16
      ,p_hwf_attribute17                =>  p_hwf_attribute17
      ,p_hwf_attribute18                =>  p_hwf_attribute18
      ,p_hwf_attribute19                =>  p_hwf_attribute19
      ,p_hwf_attribute20                =>  p_hwf_attribute20
      ,p_hwf_attribute21                =>  p_hwf_attribute21
      ,p_hwf_attribute22                =>  p_hwf_attribute22
      ,p_hwf_attribute23                =>  p_hwf_attribute23
      ,p_hwf_attribute24                =>  p_hwf_attribute24
      ,p_hwf_attribute25                =>  p_hwf_attribute25
      ,p_hwf_attribute26                =>  p_hwf_attribute26
      ,p_hwf_attribute27                =>  p_hwf_attribute27
      ,p_hwf_attribute28                =>  p_hwf_attribute28
      ,p_hwf_attribute29                =>  p_hwf_attribute29
      ,p_hwf_attribute30                =>  p_hwf_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_hrs_wkd_in_perd_fctr'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_hrs_wkd_in_perd_fctr
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
  p_hrs_wkd_in_perd_fctr_id := l_hrs_wkd_in_perd_fctr_id;
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
    ROLLBACK TO create_hrs_wkd_in_perd_fctr;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_hrs_wkd_in_perd_fctr_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_hrs_wkd_in_perd_fctr;
    p_hrs_wkd_in_perd_fctr_id := null;
    p_object_version_number  := null;

    raise;
    --
end create_hrs_wkd_in_perd_fctr;
-- ----------------------------------------------------------------------------
-- |------------------------< update_hrs_wkd_in_perd_fctr >-------------------|
-- ----------------------------------------------------------------------------
--
procedure update_hrs_wkd_in_perd_fctr
  (p_validate                       in  boolean   default false
  ,p_hrs_wkd_in_perd_fctr_id        in  number
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_hrs_src_cd                     in  varchar2  default hr_api.g_varchar2
  ,p_rndg_cd                        in  varchar2  default hr_api.g_varchar2
  ,p_rndg_rl                        in  number    default hr_api.g_number
  ,p_hrs_wkd_det_cd                 in  varchar2  default hr_api.g_varchar2
  ,p_hrs_wkd_det_rl                 in  number    default hr_api.g_number
  ,p_no_mn_hrs_wkd_flag             in  varchar2  default hr_api.g_varchar2
  ,p_mx_hrs_num                     in  number    default hr_api.g_number
  ,p_no_mx_hrs_wkd_flag             in  varchar2  default hr_api.g_varchar2
  ,p_once_r_cntug_cd                in  varchar2  default hr_api.g_varchar2
  ,p_mn_hrs_num                     in  number    default hr_api.g_number
  ,p_hrs_alt_val_to_use_cd          in  varchar2  default hr_api.g_varchar2
  ,p_pyrl_freq_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_hrs_wkd_calc_rl                in  number    default hr_api.g_number
  ,p_defined_balance_id             in  number    default hr_api.g_number
  ,p_bnfts_bal_id                   in  number    default hr_api.g_number
  ,p_hwf_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_hwf_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_hwf_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_hwf_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_hwf_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_hwf_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_hwf_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_hwf_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_hwf_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_hwf_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_hwf_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_hwf_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_hwf_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_hwf_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_hwf_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_hwf_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_hwf_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_hwf_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_hwf_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_hwf_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_hwf_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_hwf_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_hwf_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_hwf_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_hwf_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_hwf_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_hwf_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_hwf_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_hwf_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_hwf_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_hwf_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_hrs_wkd_in_perd_fctr';
  l_object_version_number ben_hrs_wkd_in_perd_fctr.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_hrs_wkd_in_perd_fctr;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_hrs_wkd_in_perd_fctr
    --
    ben_hrs_wkd_in_perd_fctr_bk2.update_hrs_wkd_in_perd_fctr_b
      (
       p_hrs_wkd_in_perd_fctr_id        =>  p_hrs_wkd_in_perd_fctr_id
      ,p_name                           =>  p_name
      ,p_business_group_id              =>  p_business_group_id
      ,p_hrs_src_cd                     =>  p_hrs_src_cd
      ,p_rndg_cd                        =>  p_rndg_cd
      ,p_rndg_rl                        =>  p_rndg_rl
      ,p_hrs_wkd_det_cd                 =>  p_hrs_wkd_det_cd
      ,p_hrs_wkd_det_rl                 =>  p_hrs_wkd_det_rl
      ,p_no_mn_hrs_wkd_flag             =>  p_no_mn_hrs_wkd_flag
      ,p_mx_hrs_num                     =>  p_mx_hrs_num
      ,p_no_mx_hrs_wkd_flag             =>  p_no_mx_hrs_wkd_flag
      ,p_once_r_cntug_cd                =>  p_once_r_cntug_cd
      ,p_mn_hrs_num                     =>  p_mn_hrs_num
      ,p_hrs_alt_val_to_use_cd          =>  p_hrs_alt_val_to_use_cd
      ,p_pyrl_freq_cd                   =>  p_pyrl_freq_cd
      ,p_hrs_wkd_calc_rl                =>  p_hrs_wkd_calc_rl
      ,p_defined_balance_id             =>  p_defined_balance_id
      ,p_bnfts_bal_id                   =>  p_bnfts_bal_id
      ,p_hwf_attribute_category         =>  p_hwf_attribute_category
      ,p_hwf_attribute1                 =>  p_hwf_attribute1
      ,p_hwf_attribute2                 =>  p_hwf_attribute2
      ,p_hwf_attribute3                 =>  p_hwf_attribute3
      ,p_hwf_attribute4                 =>  p_hwf_attribute4
      ,p_hwf_attribute5                 =>  p_hwf_attribute5
      ,p_hwf_attribute6                 =>  p_hwf_attribute6
      ,p_hwf_attribute7                 =>  p_hwf_attribute7
      ,p_hwf_attribute8                 =>  p_hwf_attribute8
      ,p_hwf_attribute9                 =>  p_hwf_attribute9
      ,p_hwf_attribute10                =>  p_hwf_attribute10
      ,p_hwf_attribute11                =>  p_hwf_attribute11
      ,p_hwf_attribute12                =>  p_hwf_attribute12
      ,p_hwf_attribute13                =>  p_hwf_attribute13
      ,p_hwf_attribute14                =>  p_hwf_attribute14
      ,p_hwf_attribute15                =>  p_hwf_attribute15
      ,p_hwf_attribute16                =>  p_hwf_attribute16
      ,p_hwf_attribute17                =>  p_hwf_attribute17
      ,p_hwf_attribute18                =>  p_hwf_attribute18
      ,p_hwf_attribute19                =>  p_hwf_attribute19
      ,p_hwf_attribute20                =>  p_hwf_attribute20
      ,p_hwf_attribute21                =>  p_hwf_attribute21
      ,p_hwf_attribute22                =>  p_hwf_attribute22
      ,p_hwf_attribute23                =>  p_hwf_attribute23
      ,p_hwf_attribute24                =>  p_hwf_attribute24
      ,p_hwf_attribute25                =>  p_hwf_attribute25
      ,p_hwf_attribute26                =>  p_hwf_attribute26
      ,p_hwf_attribute27                =>  p_hwf_attribute27
      ,p_hwf_attribute28                =>  p_hwf_attribute28
      ,p_hwf_attribute29                =>  p_hwf_attribute29
      ,p_hwf_attribute30                =>  p_hwf_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_hrs_wkd_in_perd_fctr'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_hrs_wkd_in_perd_fctr
    --
  end;
  --
  ben_hwf_upd.upd
    (
     p_hrs_wkd_in_perd_fctr_id       => p_hrs_wkd_in_perd_fctr_id
    ,p_name                          => p_name
    ,p_business_group_id             => p_business_group_id
    ,p_hrs_src_cd                    => p_hrs_src_cd
    ,p_rndg_cd                       => p_rndg_cd
    ,p_rndg_rl                       => p_rndg_rl
    ,p_hrs_wkd_det_cd                => p_hrs_wkd_det_cd
    ,p_hrs_wkd_det_rl                => p_hrs_wkd_det_rl
    ,p_no_mn_hrs_wkd_flag            => p_no_mn_hrs_wkd_flag
    ,p_mx_hrs_num                    => p_mx_hrs_num
    ,p_no_mx_hrs_wkd_flag            => p_no_mx_hrs_wkd_flag
    ,p_once_r_cntug_cd               => p_once_r_cntug_cd
    ,p_mn_hrs_num                    => p_mn_hrs_num
    ,p_hrs_alt_val_to_use_cd         => p_hrs_alt_val_to_use_cd
    ,p_pyrl_freq_cd                  => p_pyrl_freq_cd
    ,p_hrs_wkd_calc_rl               => p_hrs_wkd_calc_rl
    ,p_defined_balance_id            => p_defined_balance_id
    ,p_bnfts_bal_id                  => p_bnfts_bal_id
    ,p_hwf_attribute_category        => p_hwf_attribute_category
    ,p_hwf_attribute1                => p_hwf_attribute1
    ,p_hwf_attribute2                => p_hwf_attribute2
    ,p_hwf_attribute3                => p_hwf_attribute3
    ,p_hwf_attribute4                => p_hwf_attribute4
    ,p_hwf_attribute5                => p_hwf_attribute5
    ,p_hwf_attribute6                => p_hwf_attribute6
    ,p_hwf_attribute7                => p_hwf_attribute7
    ,p_hwf_attribute8                => p_hwf_attribute8
    ,p_hwf_attribute9                => p_hwf_attribute9
    ,p_hwf_attribute10               => p_hwf_attribute10
    ,p_hwf_attribute11               => p_hwf_attribute11
    ,p_hwf_attribute12               => p_hwf_attribute12
    ,p_hwf_attribute13               => p_hwf_attribute13
    ,p_hwf_attribute14               => p_hwf_attribute14
    ,p_hwf_attribute15               => p_hwf_attribute15
    ,p_hwf_attribute16               => p_hwf_attribute16
    ,p_hwf_attribute17               => p_hwf_attribute17
    ,p_hwf_attribute18               => p_hwf_attribute18
    ,p_hwf_attribute19               => p_hwf_attribute19
    ,p_hwf_attribute20               => p_hwf_attribute20
    ,p_hwf_attribute21               => p_hwf_attribute21
    ,p_hwf_attribute22               => p_hwf_attribute22
    ,p_hwf_attribute23               => p_hwf_attribute23
    ,p_hwf_attribute24               => p_hwf_attribute24
    ,p_hwf_attribute25               => p_hwf_attribute25
    ,p_hwf_attribute26               => p_hwf_attribute26
    ,p_hwf_attribute27               => p_hwf_attribute27
    ,p_hwf_attribute28               => p_hwf_attribute28
    ,p_hwf_attribute29               => p_hwf_attribute29
    ,p_hwf_attribute30               => p_hwf_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_hrs_wkd_in_perd_fctr
    --
    ben_hrs_wkd_in_perd_fctr_bk2.update_hrs_wkd_in_perd_fctr_a
      (
       p_hrs_wkd_in_perd_fctr_id        =>  p_hrs_wkd_in_perd_fctr_id
      ,p_name                           =>  p_name
      ,p_business_group_id              =>  p_business_group_id
      ,p_hrs_src_cd                     =>  p_hrs_src_cd
      ,p_rndg_cd                        =>  p_rndg_cd
      ,p_rndg_rl                        =>  p_rndg_rl
      ,p_hrs_wkd_det_cd                 =>  p_hrs_wkd_det_cd
      ,p_hrs_wkd_det_rl                 =>  p_hrs_wkd_det_rl
      ,p_no_mn_hrs_wkd_flag             =>  p_no_mn_hrs_wkd_flag
      ,p_mx_hrs_num                     =>  p_mx_hrs_num
      ,p_no_mx_hrs_wkd_flag             =>  p_no_mx_hrs_wkd_flag
      ,p_once_r_cntug_cd                =>  p_once_r_cntug_cd
      ,p_mn_hrs_num                     =>  p_mn_hrs_num
      ,p_hrs_alt_val_to_use_cd          =>  p_hrs_alt_val_to_use_cd
      ,p_pyrl_freq_cd                   =>  p_pyrl_freq_cd
      ,p_hrs_wkd_calc_rl                =>  p_hrs_wkd_calc_rl
      ,p_defined_balance_id             =>  p_defined_balance_id
      ,p_bnfts_bal_id                   =>  p_bnfts_bal_id
      ,p_hwf_attribute_category         =>  p_hwf_attribute_category
      ,p_hwf_attribute1                 =>  p_hwf_attribute1
      ,p_hwf_attribute2                 =>  p_hwf_attribute2
      ,p_hwf_attribute3                 =>  p_hwf_attribute3
      ,p_hwf_attribute4                 =>  p_hwf_attribute4
      ,p_hwf_attribute5                 =>  p_hwf_attribute5
      ,p_hwf_attribute6                 =>  p_hwf_attribute6
      ,p_hwf_attribute7                 =>  p_hwf_attribute7
      ,p_hwf_attribute8                 =>  p_hwf_attribute8
      ,p_hwf_attribute9                 =>  p_hwf_attribute9
      ,p_hwf_attribute10                =>  p_hwf_attribute10
      ,p_hwf_attribute11                =>  p_hwf_attribute11
      ,p_hwf_attribute12                =>  p_hwf_attribute12
      ,p_hwf_attribute13                =>  p_hwf_attribute13
      ,p_hwf_attribute14                =>  p_hwf_attribute14
      ,p_hwf_attribute15                =>  p_hwf_attribute15
      ,p_hwf_attribute16                =>  p_hwf_attribute16
      ,p_hwf_attribute17                =>  p_hwf_attribute17
      ,p_hwf_attribute18                =>  p_hwf_attribute18
      ,p_hwf_attribute19                =>  p_hwf_attribute19
      ,p_hwf_attribute20                =>  p_hwf_attribute20
      ,p_hwf_attribute21                =>  p_hwf_attribute21
      ,p_hwf_attribute22                =>  p_hwf_attribute22
      ,p_hwf_attribute23                =>  p_hwf_attribute23
      ,p_hwf_attribute24                =>  p_hwf_attribute24
      ,p_hwf_attribute25                =>  p_hwf_attribute25
      ,p_hwf_attribute26                =>  p_hwf_attribute26
      ,p_hwf_attribute27                =>  p_hwf_attribute27
      ,p_hwf_attribute28                =>  p_hwf_attribute28
      ,p_hwf_attribute29                =>  p_hwf_attribute29
      ,p_hwf_attribute30                =>  p_hwf_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_hrs_wkd_in_perd_fctr'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_hrs_wkd_in_perd_fctr
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
    ROLLBACK TO update_hrs_wkd_in_perd_fctr;
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
    ROLLBACK TO update_hrs_wkd_in_perd_fctr;
    p_object_version_number := l_object_version_number;
    raise;
    --
end update_hrs_wkd_in_perd_fctr;
-- ----------------------------------------------------------------------------
-- |---------------------< delete_hrs_wkd_in_perd_fctr >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_hrs_wkd_in_perd_fctr
  (p_validate                       in  boolean  default false
  ,p_hrs_wkd_in_perd_fctr_id        in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_hrs_wkd_in_perd_fctr';
  l_object_version_number ben_hrs_wkd_in_perd_fctr.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_hrs_wkd_in_perd_fctr;
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
    -- Start of API User Hook for the before hook of delete_hrs_wkd_in_perd_fctr
    --
    ben_hrs_wkd_in_perd_fctr_bk3.delete_hrs_wkd_in_perd_fctr_b
      (
       p_hrs_wkd_in_perd_fctr_id        =>  p_hrs_wkd_in_perd_fctr_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_hrs_wkd_in_perd_fctr'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_hrs_wkd_in_perd_fctr
    --
  end;
  --
  ben_hwf_del.del
    (
     p_hrs_wkd_in_perd_fctr_id       => p_hrs_wkd_in_perd_fctr_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_hrs_wkd_in_perd_fctr
    --
    ben_hrs_wkd_in_perd_fctr_bk3.delete_hrs_wkd_in_perd_fctr_a
      (
       p_hrs_wkd_in_perd_fctr_id        =>  p_hrs_wkd_in_perd_fctr_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_hrs_wkd_in_perd_fctr'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_hrs_wkd_in_perd_fctr
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
    ROLLBACK TO delete_hrs_wkd_in_perd_fctr;
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
    ROLLBACK TO delete_hrs_wkd_in_perd_fctr;
    p_object_version_number := l_object_version_number;
    raise;
    --
end delete_hrs_wkd_in_perd_fctr;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_hrs_wkd_in_perd_fctr_id                   in     number
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
  ben_hwf_shd.lck
    (
      p_hrs_wkd_in_perd_fctr_id                 => p_hrs_wkd_in_perd_fctr_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_hrs_wkd_in_perd_fctr_api;

/
