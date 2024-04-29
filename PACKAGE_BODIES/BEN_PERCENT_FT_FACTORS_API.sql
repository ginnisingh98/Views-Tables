--------------------------------------------------------
--  DDL for Package Body BEN_PERCENT_FT_FACTORS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PERCENT_FT_FACTORS_API" as
/* $Header: bepffapi.pkb 120.0 2005/05/28 10:41:53 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_percent_ft_factors_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_percent_ft_factors >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_percent_ft_factors
  (p_validate                       in  boolean   default false
  ,p_pct_fl_tm_fctr_id              out nocopy number
  ,p_name                           in  varchar2  default null
  ,p_business_group_id              in  number    default null
  ,p_mx_pct_val                     in  number    default null
  ,p_mn_pct_val                     in  number    default null
  ,p_no_mn_pct_val_flag             in  varchar2  default null
  ,p_no_mx_pct_val_flag             in  varchar2  default null
  ,p_use_prmry_asnt_only_flag       in  varchar2  default null
  ,p_use_sum_of_all_asnts_flag      in  varchar2  default null
  ,p_rndg_cd                        in  varchar2  default null
  ,p_rndg_rl                        in  number    default null
  ,p_pff_attribute_category         in  varchar2  default null
  ,p_pff_attribute1                 in  varchar2  default null
  ,p_pff_attribute2                 in  varchar2  default null
  ,p_pff_attribute3                 in  varchar2  default null
  ,p_pff_attribute4                 in  varchar2  default null
  ,p_pff_attribute5                 in  varchar2  default null
  ,p_pff_attribute6                 in  varchar2  default null
  ,p_pff_attribute7                 in  varchar2  default null
  ,p_pff_attribute8                 in  varchar2  default null
  ,p_pff_attribute9                 in  varchar2  default null
  ,p_pff_attribute10                in  varchar2  default null
  ,p_pff_attribute11                in  varchar2  default null
  ,p_pff_attribute12                in  varchar2  default null
  ,p_pff_attribute13                in  varchar2  default null
  ,p_pff_attribute14                in  varchar2  default null
  ,p_pff_attribute15                in  varchar2  default null
  ,p_pff_attribute16                in  varchar2  default null
  ,p_pff_attribute17                in  varchar2  default null
  ,p_pff_attribute18                in  varchar2  default null
  ,p_pff_attribute19                in  varchar2  default null
  ,p_pff_attribute20                in  varchar2  default null
  ,p_pff_attribute21                in  varchar2  default null
  ,p_pff_attribute22                in  varchar2  default null
  ,p_pff_attribute23                in  varchar2  default null
  ,p_pff_attribute24                in  varchar2  default null
  ,p_pff_attribute25                in  varchar2  default null
  ,p_pff_attribute26                in  varchar2  default null
  ,p_pff_attribute27                in  varchar2  default null
  ,p_pff_attribute28                in  varchar2  default null
  ,p_pff_attribute29                in  varchar2  default null
  ,p_pff_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_pct_fl_tm_fctr_id ben_pct_fl_tm_fctr.pct_fl_tm_fctr_id%TYPE;
  l_proc varchar2(72) := g_package||'create_percent_ft_factors';
  l_object_version_number ben_pct_fl_tm_fctr.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_percent_ft_factors;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_percent_ft_factors
    --
    ben_percent_ft_factors_bk1.create_percent_ft_factors_b
      (
       p_name                           =>  p_name
      ,p_business_group_id              =>  p_business_group_id
      ,p_mx_pct_val                     =>  p_mx_pct_val
      ,p_mn_pct_val                     =>  p_mn_pct_val
      ,p_no_mn_pct_val_flag             =>  p_no_mn_pct_val_flag
      ,p_no_mx_pct_val_flag             =>  p_no_mx_pct_val_flag
      ,p_use_prmry_asnt_only_flag       =>  p_use_prmry_asnt_only_flag
      ,p_use_sum_of_all_asnts_flag      =>  p_use_sum_of_all_asnts_flag
      ,p_rndg_cd                        =>  p_rndg_cd
      ,p_rndg_rl                        =>  p_rndg_rl
      ,p_pff_attribute_category         =>  p_pff_attribute_category
      ,p_pff_attribute1                 =>  p_pff_attribute1
      ,p_pff_attribute2                 =>  p_pff_attribute2
      ,p_pff_attribute3                 =>  p_pff_attribute3
      ,p_pff_attribute4                 =>  p_pff_attribute4
      ,p_pff_attribute5                 =>  p_pff_attribute5
      ,p_pff_attribute6                 =>  p_pff_attribute6
      ,p_pff_attribute7                 =>  p_pff_attribute7
      ,p_pff_attribute8                 =>  p_pff_attribute8
      ,p_pff_attribute9                 =>  p_pff_attribute9
      ,p_pff_attribute10                =>  p_pff_attribute10
      ,p_pff_attribute11                =>  p_pff_attribute11
      ,p_pff_attribute12                =>  p_pff_attribute12
      ,p_pff_attribute13                =>  p_pff_attribute13
      ,p_pff_attribute14                =>  p_pff_attribute14
      ,p_pff_attribute15                =>  p_pff_attribute15
      ,p_pff_attribute16                =>  p_pff_attribute16
      ,p_pff_attribute17                =>  p_pff_attribute17
      ,p_pff_attribute18                =>  p_pff_attribute18
      ,p_pff_attribute19                =>  p_pff_attribute19
      ,p_pff_attribute20                =>  p_pff_attribute20
      ,p_pff_attribute21                =>  p_pff_attribute21
      ,p_pff_attribute22                =>  p_pff_attribute22
      ,p_pff_attribute23                =>  p_pff_attribute23
      ,p_pff_attribute24                =>  p_pff_attribute24
      ,p_pff_attribute25                =>  p_pff_attribute25
      ,p_pff_attribute26                =>  p_pff_attribute26
      ,p_pff_attribute27                =>  p_pff_attribute27
      ,p_pff_attribute28                =>  p_pff_attribute28
      ,p_pff_attribute29                =>  p_pff_attribute29
      ,p_pff_attribute30                =>  p_pff_attribute30
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_percent_ft_factors'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_percent_ft_factors
    --
  end;
  --
  ben_pff_ins.ins
    (
     p_pct_fl_tm_fctr_id             => l_pct_fl_tm_fctr_id
    ,p_name                          => p_name
    ,p_business_group_id             => p_business_group_id
    ,p_mx_pct_val                    => p_mx_pct_val
    ,p_mn_pct_val                    => p_mn_pct_val
    ,p_no_mn_pct_val_flag            => p_no_mn_pct_val_flag
    ,p_no_mx_pct_val_flag            => p_no_mx_pct_val_flag
    ,p_use_prmry_asnt_only_flag      => p_use_prmry_asnt_only_flag
    ,p_use_sum_of_all_asnts_flag     => p_use_sum_of_all_asnts_flag
    ,p_rndg_cd                       => p_rndg_cd
    ,p_rndg_rl                       => p_rndg_rl
    ,p_pff_attribute_category        => p_pff_attribute_category
    ,p_pff_attribute1                => p_pff_attribute1
    ,p_pff_attribute2                => p_pff_attribute2
    ,p_pff_attribute3                => p_pff_attribute3
    ,p_pff_attribute4                => p_pff_attribute4
    ,p_pff_attribute5                => p_pff_attribute5
    ,p_pff_attribute6                => p_pff_attribute6
    ,p_pff_attribute7                => p_pff_attribute7
    ,p_pff_attribute8                => p_pff_attribute8
    ,p_pff_attribute9                => p_pff_attribute9
    ,p_pff_attribute10               => p_pff_attribute10
    ,p_pff_attribute11               => p_pff_attribute11
    ,p_pff_attribute12               => p_pff_attribute12
    ,p_pff_attribute13               => p_pff_attribute13
    ,p_pff_attribute14               => p_pff_attribute14
    ,p_pff_attribute15               => p_pff_attribute15
    ,p_pff_attribute16               => p_pff_attribute16
    ,p_pff_attribute17               => p_pff_attribute17
    ,p_pff_attribute18               => p_pff_attribute18
    ,p_pff_attribute19               => p_pff_attribute19
    ,p_pff_attribute20               => p_pff_attribute20
    ,p_pff_attribute21               => p_pff_attribute21
    ,p_pff_attribute22               => p_pff_attribute22
    ,p_pff_attribute23               => p_pff_attribute23
    ,p_pff_attribute24               => p_pff_attribute24
    ,p_pff_attribute25               => p_pff_attribute25
    ,p_pff_attribute26               => p_pff_attribute26
    ,p_pff_attribute27               => p_pff_attribute27
    ,p_pff_attribute28               => p_pff_attribute28
    ,p_pff_attribute29               => p_pff_attribute29
    ,p_pff_attribute30               => p_pff_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_percent_ft_factors
    --
    ben_percent_ft_factors_bk1.create_percent_ft_factors_a
      (
       p_pct_fl_tm_fctr_id              =>  l_pct_fl_tm_fctr_id
      ,p_name                           =>  p_name
      ,p_business_group_id              =>  p_business_group_id
      ,p_mx_pct_val                     =>  p_mx_pct_val
      ,p_mn_pct_val                     =>  p_mn_pct_val
      ,p_no_mn_pct_val_flag             =>  p_no_mn_pct_val_flag
      ,p_no_mx_pct_val_flag             =>  p_no_mx_pct_val_flag
      ,p_use_prmry_asnt_only_flag       =>  p_use_prmry_asnt_only_flag
      ,p_use_sum_of_all_asnts_flag      =>  p_use_sum_of_all_asnts_flag
      ,p_rndg_cd                        =>  p_rndg_cd
      ,p_rndg_rl                        =>  p_rndg_rl
      ,p_pff_attribute_category         =>  p_pff_attribute_category
      ,p_pff_attribute1                 =>  p_pff_attribute1
      ,p_pff_attribute2                 =>  p_pff_attribute2
      ,p_pff_attribute3                 =>  p_pff_attribute3
      ,p_pff_attribute4                 =>  p_pff_attribute4
      ,p_pff_attribute5                 =>  p_pff_attribute5
      ,p_pff_attribute6                 =>  p_pff_attribute6
      ,p_pff_attribute7                 =>  p_pff_attribute7
      ,p_pff_attribute8                 =>  p_pff_attribute8
      ,p_pff_attribute9                 =>  p_pff_attribute9
      ,p_pff_attribute10                =>  p_pff_attribute10
      ,p_pff_attribute11                =>  p_pff_attribute11
      ,p_pff_attribute12                =>  p_pff_attribute12
      ,p_pff_attribute13                =>  p_pff_attribute13
      ,p_pff_attribute14                =>  p_pff_attribute14
      ,p_pff_attribute15                =>  p_pff_attribute15
      ,p_pff_attribute16                =>  p_pff_attribute16
      ,p_pff_attribute17                =>  p_pff_attribute17
      ,p_pff_attribute18                =>  p_pff_attribute18
      ,p_pff_attribute19                =>  p_pff_attribute19
      ,p_pff_attribute20                =>  p_pff_attribute20
      ,p_pff_attribute21                =>  p_pff_attribute21
      ,p_pff_attribute22                =>  p_pff_attribute22
      ,p_pff_attribute23                =>  p_pff_attribute23
      ,p_pff_attribute24                =>  p_pff_attribute24
      ,p_pff_attribute25                =>  p_pff_attribute25
      ,p_pff_attribute26                =>  p_pff_attribute26
      ,p_pff_attribute27                =>  p_pff_attribute27
      ,p_pff_attribute28                =>  p_pff_attribute28
      ,p_pff_attribute29                =>  p_pff_attribute29
      ,p_pff_attribute30                =>  p_pff_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_percent_ft_factors'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_percent_ft_factors
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
  p_pct_fl_tm_fctr_id := l_pct_fl_tm_fctr_id;
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
    ROLLBACK TO create_percent_ft_factors;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_pct_fl_tm_fctr_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_percent_ft_factors;
    p_object_version_number  := null;
    raise;
    --
end create_percent_ft_factors;
-- ----------------------------------------------------------------------------
-- |------------------------< update_percent_ft_factors >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_percent_ft_factors
  (p_validate                       in  boolean   default false
  ,p_pct_fl_tm_fctr_id              in  number
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_mx_pct_val                     in  number    default hr_api.g_number
  ,p_mn_pct_val                     in  number    default hr_api.g_number
  ,p_no_mn_pct_val_flag             in  varchar2  default hr_api.g_varchar2
  ,p_no_mx_pct_val_flag             in  varchar2  default hr_api.g_varchar2
  ,p_use_prmry_asnt_only_flag       in  varchar2  default hr_api.g_varchar2
  ,p_use_sum_of_all_asnts_flag      in  varchar2  default hr_api.g_varchar2
  ,p_rndg_cd                        in  varchar2  default hr_api.g_varchar2
  ,p_rndg_rl                        in  number    default hr_api.g_number
  ,p_pff_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pff_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_percent_ft_factors';
  l_object_version_number ben_pct_fl_tm_fctr.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_percent_ft_factors;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_percent_ft_factors
    --
    ben_percent_ft_factors_bk2.update_percent_ft_factors_b
      (
       p_pct_fl_tm_fctr_id              =>  p_pct_fl_tm_fctr_id
      ,p_name                           =>  p_name
      ,p_business_group_id              =>  p_business_group_id
      ,p_mx_pct_val                     =>  p_mx_pct_val
      ,p_mn_pct_val                     =>  p_mn_pct_val
      ,p_no_mn_pct_val_flag             =>  p_no_mn_pct_val_flag
      ,p_no_mx_pct_val_flag             =>  p_no_mx_pct_val_flag
      ,p_use_prmry_asnt_only_flag       =>  p_use_prmry_asnt_only_flag
      ,p_use_sum_of_all_asnts_flag      =>  p_use_sum_of_all_asnts_flag
      ,p_rndg_cd                        =>  p_rndg_cd
      ,p_rndg_rl                        =>  p_rndg_rl
      ,p_pff_attribute_category         =>  p_pff_attribute_category
      ,p_pff_attribute1                 =>  p_pff_attribute1
      ,p_pff_attribute2                 =>  p_pff_attribute2
      ,p_pff_attribute3                 =>  p_pff_attribute3
      ,p_pff_attribute4                 =>  p_pff_attribute4
      ,p_pff_attribute5                 =>  p_pff_attribute5
      ,p_pff_attribute6                 =>  p_pff_attribute6
      ,p_pff_attribute7                 =>  p_pff_attribute7
      ,p_pff_attribute8                 =>  p_pff_attribute8
      ,p_pff_attribute9                 =>  p_pff_attribute9
      ,p_pff_attribute10                =>  p_pff_attribute10
      ,p_pff_attribute11                =>  p_pff_attribute11
      ,p_pff_attribute12                =>  p_pff_attribute12
      ,p_pff_attribute13                =>  p_pff_attribute13
      ,p_pff_attribute14                =>  p_pff_attribute14
      ,p_pff_attribute15                =>  p_pff_attribute15
      ,p_pff_attribute16                =>  p_pff_attribute16
      ,p_pff_attribute17                =>  p_pff_attribute17
      ,p_pff_attribute18                =>  p_pff_attribute18
      ,p_pff_attribute19                =>  p_pff_attribute19
      ,p_pff_attribute20                =>  p_pff_attribute20
      ,p_pff_attribute21                =>  p_pff_attribute21
      ,p_pff_attribute22                =>  p_pff_attribute22
      ,p_pff_attribute23                =>  p_pff_attribute23
      ,p_pff_attribute24                =>  p_pff_attribute24
      ,p_pff_attribute25                =>  p_pff_attribute25
      ,p_pff_attribute26                =>  p_pff_attribute26
      ,p_pff_attribute27                =>  p_pff_attribute27
      ,p_pff_attribute28                =>  p_pff_attribute28
      ,p_pff_attribute29                =>  p_pff_attribute29
      ,p_pff_attribute30                =>  p_pff_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_percent_ft_factors'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_percent_ft_factors
    --
  end;
  --
  ben_pff_upd.upd
    (
     p_pct_fl_tm_fctr_id             => p_pct_fl_tm_fctr_id
    ,p_name                          => p_name
    ,p_business_group_id             => p_business_group_id
    ,p_mx_pct_val                    => p_mx_pct_val
    ,p_mn_pct_val                    => p_mn_pct_val
    ,p_no_mn_pct_val_flag            => p_no_mn_pct_val_flag
    ,p_no_mx_pct_val_flag            => p_no_mx_pct_val_flag
    ,p_use_prmry_asnt_only_flag      => p_use_prmry_asnt_only_flag
    ,p_use_sum_of_all_asnts_flag     => p_use_sum_of_all_asnts_flag
    ,p_rndg_cd                       => p_rndg_cd
    ,p_rndg_rl                       => p_rndg_rl
    ,p_pff_attribute_category        => p_pff_attribute_category
    ,p_pff_attribute1                => p_pff_attribute1
    ,p_pff_attribute2                => p_pff_attribute2
    ,p_pff_attribute3                => p_pff_attribute3
    ,p_pff_attribute4                => p_pff_attribute4
    ,p_pff_attribute5                => p_pff_attribute5
    ,p_pff_attribute6                => p_pff_attribute6
    ,p_pff_attribute7                => p_pff_attribute7
    ,p_pff_attribute8                => p_pff_attribute8
    ,p_pff_attribute9                => p_pff_attribute9
    ,p_pff_attribute10               => p_pff_attribute10
    ,p_pff_attribute11               => p_pff_attribute11
    ,p_pff_attribute12               => p_pff_attribute12
    ,p_pff_attribute13               => p_pff_attribute13
    ,p_pff_attribute14               => p_pff_attribute14
    ,p_pff_attribute15               => p_pff_attribute15
    ,p_pff_attribute16               => p_pff_attribute16
    ,p_pff_attribute17               => p_pff_attribute17
    ,p_pff_attribute18               => p_pff_attribute18
    ,p_pff_attribute19               => p_pff_attribute19
    ,p_pff_attribute20               => p_pff_attribute20
    ,p_pff_attribute21               => p_pff_attribute21
    ,p_pff_attribute22               => p_pff_attribute22
    ,p_pff_attribute23               => p_pff_attribute23
    ,p_pff_attribute24               => p_pff_attribute24
    ,p_pff_attribute25               => p_pff_attribute25
    ,p_pff_attribute26               => p_pff_attribute26
    ,p_pff_attribute27               => p_pff_attribute27
    ,p_pff_attribute28               => p_pff_attribute28
    ,p_pff_attribute29               => p_pff_attribute29
    ,p_pff_attribute30               => p_pff_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_percent_ft_factors
    --
    ben_percent_ft_factors_bk2.update_percent_ft_factors_a
      (
       p_pct_fl_tm_fctr_id              =>  p_pct_fl_tm_fctr_id
      ,p_name                           =>  p_name
      ,p_business_group_id              =>  p_business_group_id
      ,p_mx_pct_val                     =>  p_mx_pct_val
      ,p_mn_pct_val                     =>  p_mn_pct_val
      ,p_no_mn_pct_val_flag             =>  p_no_mn_pct_val_flag
      ,p_no_mx_pct_val_flag             =>  p_no_mx_pct_val_flag
      ,p_use_prmry_asnt_only_flag       =>  p_use_prmry_asnt_only_flag
      ,p_use_sum_of_all_asnts_flag      =>  p_use_sum_of_all_asnts_flag
      ,p_rndg_cd                        =>  p_rndg_cd
      ,p_rndg_rl                        =>  p_rndg_rl
      ,p_pff_attribute_category         =>  p_pff_attribute_category
      ,p_pff_attribute1                 =>  p_pff_attribute1
      ,p_pff_attribute2                 =>  p_pff_attribute2
      ,p_pff_attribute3                 =>  p_pff_attribute3
      ,p_pff_attribute4                 =>  p_pff_attribute4
      ,p_pff_attribute5                 =>  p_pff_attribute5
      ,p_pff_attribute6                 =>  p_pff_attribute6
      ,p_pff_attribute7                 =>  p_pff_attribute7
      ,p_pff_attribute8                 =>  p_pff_attribute8
      ,p_pff_attribute9                 =>  p_pff_attribute9
      ,p_pff_attribute10                =>  p_pff_attribute10
      ,p_pff_attribute11                =>  p_pff_attribute11
      ,p_pff_attribute12                =>  p_pff_attribute12
      ,p_pff_attribute13                =>  p_pff_attribute13
      ,p_pff_attribute14                =>  p_pff_attribute14
      ,p_pff_attribute15                =>  p_pff_attribute15
      ,p_pff_attribute16                =>  p_pff_attribute16
      ,p_pff_attribute17                =>  p_pff_attribute17
      ,p_pff_attribute18                =>  p_pff_attribute18
      ,p_pff_attribute19                =>  p_pff_attribute19
      ,p_pff_attribute20                =>  p_pff_attribute20
      ,p_pff_attribute21                =>  p_pff_attribute21
      ,p_pff_attribute22                =>  p_pff_attribute22
      ,p_pff_attribute23                =>  p_pff_attribute23
      ,p_pff_attribute24                =>  p_pff_attribute24
      ,p_pff_attribute25                =>  p_pff_attribute25
      ,p_pff_attribute26                =>  p_pff_attribute26
      ,p_pff_attribute27                =>  p_pff_attribute27
      ,p_pff_attribute28                =>  p_pff_attribute28
      ,p_pff_attribute29                =>  p_pff_attribute29
      ,p_pff_attribute30                =>  p_pff_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_percent_ft_factors'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_percent_ft_factors
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
    ROLLBACK TO update_percent_ft_factors;
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
    ROLLBACK TO update_percent_ft_factors;
    p_object_version_number  := l_object_version_number;
    raise;
    --
end update_percent_ft_factors;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_percent_ft_factors >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_percent_ft_factors
  (p_validate                       in  boolean  default false
  ,p_pct_fl_tm_fctr_id              in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_percent_ft_factors';
  l_object_version_number ben_pct_fl_tm_fctr.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_percent_ft_factors;
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
    -- Start of API User Hook for the before hook of delete_percent_ft_factors
    --
    ben_percent_ft_factors_bk3.delete_percent_ft_factors_b
      (
       p_pct_fl_tm_fctr_id              =>  p_pct_fl_tm_fctr_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_percent_ft_factors'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_percent_ft_factors
    --
  end;
  --
  ben_pff_del.del
    (
     p_pct_fl_tm_fctr_id             => p_pct_fl_tm_fctr_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_percent_ft_factors
    --
    ben_percent_ft_factors_bk3.delete_percent_ft_factors_a
      (
       p_pct_fl_tm_fctr_id              =>  p_pct_fl_tm_fctr_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_percent_ft_factors'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_percent_ft_factors
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
    ROLLBACK TO delete_percent_ft_factors;
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
    ROLLBACK TO delete_percent_ft_factors;
    p_object_version_number  := l_object_version_number;
    raise;
    --
end delete_percent_ft_factors;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_pct_fl_tm_fctr_id                   in     number
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
  ben_pff_shd.lck
    (
      p_pct_fl_tm_fctr_id                 => p_pct_fl_tm_fctr_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_percent_ft_factors_api;

/
