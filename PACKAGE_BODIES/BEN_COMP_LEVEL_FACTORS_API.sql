--------------------------------------------------------
--  DDL for Package Body BEN_COMP_LEVEL_FACTORS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_COMP_LEVEL_FACTORS_API" as
/* $Header: beclfapi.pkb 120.0 2005/05/28 01:03:42 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_comp_level_factors_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_comp_level_factors >---------------------|
-- ----------------------------------------------------------------------------
--
procedure create_comp_level_factors
  (p_validate                       in  boolean   default false
  ,p_comp_lvl_fctr_id               out nocopy number
  ,p_name                           in  varchar2  default null
  ,p_comp_lvl_det_cd                in  varchar2  default null
  ,p_comp_lvl_det_rl                in  number    default null
  ,p_comp_lvl_uom                   in  varchar2  default null
  ,p_comp_src_cd                    in  varchar2  default null
  ,p_no_mn_comp_flag                in  varchar2  default null
  ,p_no_mx_comp_flag                in  varchar2  default null
  ,p_mx_comp_val                    in  number    default null
  ,p_mn_comp_val                    in  number    default null
  ,p_rndg_cd                        in  varchar2  default null
  ,p_rndg_rl                        in  number    default null
  ,p_defined_balance_id             in  number    default null
  ,p_bnfts_bal_id                   in  number    default null
  ,p_comp_alt_val_to_use_cd         in  varchar2  default null
  ,p_comp_calc_rl                   in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_proration_flag                 in Varchar2   default 'N'
  ,p_start_day_mo                   in Varchar2   default null
  ,p_end_day_mo                     in Varchar2   default null
  ,p_start_year                     in Varchar2   default null
  ,p_end_year                       in Varchar2   default null
  ,p_clf_attribute_category         in  varchar2  default null
  ,p_clf_attribute1                 in  varchar2  default null
  ,p_clf_attribute2                 in  varchar2  default null
  ,p_clf_attribute3                 in  varchar2  default null
  ,p_clf_attribute4                 in  varchar2  default null
  ,p_clf_attribute5                 in  varchar2  default null
  ,p_clf_attribute6                 in  varchar2  default null
  ,p_clf_attribute7                 in  varchar2  default null
  ,p_clf_attribute8                 in  varchar2  default null
  ,p_clf_attribute9                 in  varchar2  default null
  ,p_clf_attribute10                in  varchar2  default null
  ,p_clf_attribute11                in  varchar2  default null
  ,p_clf_attribute12                in  varchar2  default null
  ,p_clf_attribute13                in  varchar2  default null
  ,p_clf_attribute14                in  varchar2  default null
  ,p_clf_attribute15                in  varchar2  default null
  ,p_clf_attribute16                in  varchar2  default null
  ,p_clf_attribute17                in  varchar2  default null
  ,p_clf_attribute18                in  varchar2  default null
  ,p_clf_attribute19                in  varchar2  default null
  ,p_clf_attribute20                in  varchar2  default null
  ,p_clf_attribute21                in  varchar2  default null
  ,p_clf_attribute22                in  varchar2  default null
  ,p_clf_attribute23                in  varchar2  default null
  ,p_clf_attribute24                in  varchar2  default null
  ,p_clf_attribute25                in  varchar2  default null
  ,p_clf_attribute26                in  varchar2  default null
  ,p_clf_attribute27                in  varchar2  default null
  ,p_clf_attribute28                in  varchar2  default null
  ,p_clf_attribute29                in  varchar2  default null
  ,p_clf_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_sttd_sal_prdcty_cd             in  varchar2  default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_comp_lvl_fctr_id ben_comp_lvl_fctr.comp_lvl_fctr_id%TYPE;
  l_proc varchar2(72) := g_package||'create_comp_level_factors';
  l_object_version_number ben_comp_lvl_fctr.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_comp_level_factors;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_comp_level_factors
    --
    ben_comp_level_factors_bk1.create_comp_level_factors_b
      (
       p_name                           =>  p_name
      ,p_comp_lvl_det_cd                =>  p_comp_lvl_det_cd
      ,p_comp_lvl_det_rl                =>  p_comp_lvl_det_rl
      ,p_comp_lvl_uom                   =>  p_comp_lvl_uom
      ,p_comp_src_cd                    =>  p_comp_src_cd
      ,p_no_mn_comp_flag                =>  p_no_mn_comp_flag
      ,p_no_mx_comp_flag                =>  p_no_mx_comp_flag
      ,p_mx_comp_val                    =>  p_mx_comp_val
      ,p_mn_comp_val                    =>  p_mn_comp_val
      ,p_rndg_cd                        =>  p_rndg_cd
      ,p_rndg_rl                        =>  p_rndg_rl
      ,p_defined_balance_id             =>  p_defined_balance_id
      ,p_bnfts_bal_id                   =>  p_bnfts_bal_id
      ,p_comp_alt_val_to_use_cd         =>  p_comp_alt_val_to_use_cd
      ,p_comp_calc_rl                   =>  p_comp_calc_rl
      ,p_business_group_id              =>  p_business_group_id
      ,p_proration_flag                 =>  p_proration_flag
      ,p_start_day_mo                   =>  p_start_day_mo
      ,p_end_day_mo                     =>  p_end_day_mo
      ,p_start_year                     =>  p_start_year
      ,p_end_year                       =>  p_end_year
      ,p_clf_attribute_category         =>  p_clf_attribute_category
      ,p_clf_attribute1                 =>  p_clf_attribute1
      ,p_clf_attribute2                 =>  p_clf_attribute2
      ,p_clf_attribute3                 =>  p_clf_attribute3
      ,p_clf_attribute4                 =>  p_clf_attribute4
      ,p_clf_attribute5                 =>  p_clf_attribute5
      ,p_clf_attribute6                 =>  p_clf_attribute6
      ,p_clf_attribute7                 =>  p_clf_attribute7
      ,p_clf_attribute8                 =>  p_clf_attribute8
      ,p_clf_attribute9                 =>  p_clf_attribute9
      ,p_clf_attribute10                =>  p_clf_attribute10
      ,p_clf_attribute11                =>  p_clf_attribute11
      ,p_clf_attribute12                =>  p_clf_attribute12
      ,p_clf_attribute13                =>  p_clf_attribute13
      ,p_clf_attribute14                =>  p_clf_attribute14
      ,p_clf_attribute15                =>  p_clf_attribute15
      ,p_clf_attribute16                =>  p_clf_attribute16
      ,p_clf_attribute17                =>  p_clf_attribute17
      ,p_clf_attribute18                =>  p_clf_attribute18
      ,p_clf_attribute19                =>  p_clf_attribute19
      ,p_clf_attribute20                =>  p_clf_attribute20
      ,p_clf_attribute21                =>  p_clf_attribute21
      ,p_clf_attribute22                =>  p_clf_attribute22
      ,p_clf_attribute23                =>  p_clf_attribute23
      ,p_clf_attribute24                =>  p_clf_attribute24
      ,p_clf_attribute25                =>  p_clf_attribute25
      ,p_clf_attribute26                =>  p_clf_attribute26
      ,p_clf_attribute27                =>  p_clf_attribute27
      ,p_clf_attribute28                =>  p_clf_attribute28
      ,p_clf_attribute29                =>  p_clf_attribute29
      ,p_clf_attribute30                =>  p_clf_attribute30
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_sttd_sal_prdcty_cd             =>  p_sttd_sal_prdcty_cd
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_comp_level_factors'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_comp_level_factors
    --
  end;
  --
  ben_clf_ins.ins
    (
     p_comp_lvl_fctr_id              => l_comp_lvl_fctr_id
    ,p_name                          => p_name
    ,p_comp_lvl_det_cd               => p_comp_lvl_det_cd
    ,p_comp_lvl_det_rl               => p_comp_lvl_det_rl
    ,p_comp_lvl_uom                  => p_comp_lvl_uom
    ,p_comp_src_cd                   => p_comp_src_cd
    ,p_no_mn_comp_flag               => p_no_mn_comp_flag
    ,p_no_mx_comp_flag               => p_no_mx_comp_flag
    ,p_mx_comp_val                   => p_mx_comp_val
    ,p_mn_comp_val                   => p_mn_comp_val
    ,p_rndg_cd                       => p_rndg_cd
    ,p_rndg_rl                       => p_rndg_rl
    ,p_defined_balance_id            => p_defined_balance_id
    ,p_bnfts_bal_id                  => p_bnfts_bal_id
    ,p_comp_alt_val_to_use_cd        => p_comp_alt_val_to_use_cd
    ,p_comp_calc_rl                  => p_comp_calc_rl
    ,p_business_group_id             => p_business_group_id
    ,p_proration_flag                =>  p_proration_flag
    ,p_start_day_mo                  =>  p_start_day_mo
    ,p_end_day_mo                    =>  p_end_day_mo
    ,p_start_year                    =>  p_start_year
    ,p_end_year                      =>  p_end_year
    ,p_clf_attribute_category        => p_clf_attribute_category
    ,p_clf_attribute1                => p_clf_attribute1
    ,p_clf_attribute2                => p_clf_attribute2
    ,p_clf_attribute3                => p_clf_attribute3
    ,p_clf_attribute4                => p_clf_attribute4
    ,p_clf_attribute5                => p_clf_attribute5
    ,p_clf_attribute6                => p_clf_attribute6
    ,p_clf_attribute7                => p_clf_attribute7
    ,p_clf_attribute8                => p_clf_attribute8
    ,p_clf_attribute9                => p_clf_attribute9
    ,p_clf_attribute10               => p_clf_attribute10
    ,p_clf_attribute11               => p_clf_attribute11
    ,p_clf_attribute12               => p_clf_attribute12
    ,p_clf_attribute13               => p_clf_attribute13
    ,p_clf_attribute14               => p_clf_attribute14
    ,p_clf_attribute15               => p_clf_attribute15
    ,p_clf_attribute16               => p_clf_attribute16
    ,p_clf_attribute17               => p_clf_attribute17
    ,p_clf_attribute18               => p_clf_attribute18
    ,p_clf_attribute19               => p_clf_attribute19
    ,p_clf_attribute20               => p_clf_attribute20
    ,p_clf_attribute21               => p_clf_attribute21
    ,p_clf_attribute22               => p_clf_attribute22
    ,p_clf_attribute23               => p_clf_attribute23
    ,p_clf_attribute24               => p_clf_attribute24
    ,p_clf_attribute25               => p_clf_attribute25
    ,p_clf_attribute26               => p_clf_attribute26
    ,p_clf_attribute27               => p_clf_attribute27
    ,p_clf_attribute28               => p_clf_attribute28
    ,p_clf_attribute29               => p_clf_attribute29
    ,p_clf_attribute30               => p_clf_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_sttd_sal_prdcty_cd            => p_sttd_sal_prdcty_cd
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_comp_level_factors
    --
    ben_comp_level_factors_bk1.create_comp_level_factors_a
      (
       p_comp_lvl_fctr_id               =>  l_comp_lvl_fctr_id
      ,p_name                           =>  p_name
      ,p_comp_lvl_det_cd                =>  p_comp_lvl_det_cd
      ,p_comp_lvl_det_rl                =>  p_comp_lvl_det_rl
      ,p_comp_lvl_uom                   =>  p_comp_lvl_uom
      ,p_comp_src_cd                    =>  p_comp_src_cd
      ,p_no_mn_comp_flag                =>  p_no_mn_comp_flag
      ,p_no_mx_comp_flag                =>  p_no_mx_comp_flag
      ,p_mx_comp_val                    =>  p_mx_comp_val
      ,p_mn_comp_val                    =>  p_mn_comp_val
      ,p_rndg_cd                        =>  p_rndg_cd
      ,p_rndg_rl                        =>  p_rndg_rl
      ,p_defined_balance_id             =>  p_defined_balance_id
      ,p_bnfts_bal_id                   =>  p_bnfts_bal_id
      ,p_comp_alt_val_to_use_cd         =>  p_comp_alt_val_to_use_cd
      ,p_comp_calc_rl                   =>  p_comp_calc_rl
      ,p_business_group_id              =>  p_business_group_id
      ,p_proration_flag                 =>  p_proration_flag
      ,p_start_day_mo                   =>  p_start_day_mo
      ,p_end_day_mo                     =>  p_end_day_mo
      ,p_start_year                     =>  p_start_year
      ,p_end_year                       =>  p_end_year
      ,p_clf_attribute_category         =>  p_clf_attribute_category
      ,p_clf_attribute1                 =>  p_clf_attribute1
      ,p_clf_attribute2                 =>  p_clf_attribute2
      ,p_clf_attribute3                 =>  p_clf_attribute3
      ,p_clf_attribute4                 =>  p_clf_attribute4
      ,p_clf_attribute5                 =>  p_clf_attribute5
      ,p_clf_attribute6                 =>  p_clf_attribute6
      ,p_clf_attribute7                 =>  p_clf_attribute7
      ,p_clf_attribute8                 =>  p_clf_attribute8
      ,p_clf_attribute9                 =>  p_clf_attribute9
      ,p_clf_attribute10                =>  p_clf_attribute10
      ,p_clf_attribute11                =>  p_clf_attribute11
      ,p_clf_attribute12                =>  p_clf_attribute12
      ,p_clf_attribute13                =>  p_clf_attribute13
      ,p_clf_attribute14                =>  p_clf_attribute14
      ,p_clf_attribute15                =>  p_clf_attribute15
      ,p_clf_attribute16                =>  p_clf_attribute16
      ,p_clf_attribute17                =>  p_clf_attribute17
      ,p_clf_attribute18                =>  p_clf_attribute18
      ,p_clf_attribute19                =>  p_clf_attribute19
      ,p_clf_attribute20                =>  p_clf_attribute20
      ,p_clf_attribute21                =>  p_clf_attribute21
      ,p_clf_attribute22                =>  p_clf_attribute22
      ,p_clf_attribute23                =>  p_clf_attribute23
      ,p_clf_attribute24                =>  p_clf_attribute24
      ,p_clf_attribute25                =>  p_clf_attribute25
      ,p_clf_attribute26                =>  p_clf_attribute26
      ,p_clf_attribute27                =>  p_clf_attribute27
      ,p_clf_attribute28                =>  p_clf_attribute28
      ,p_clf_attribute29                =>  p_clf_attribute29
      ,p_clf_attribute30                =>  p_clf_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_sttd_sal_prdcty_cd             =>  p_sttd_sal_prdcty_cd
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_comp_level_factors'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_comp_level_factors
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
  p_comp_lvl_fctr_id := l_comp_lvl_fctr_id;
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
    ROLLBACK TO create_comp_level_factors;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_comp_lvl_fctr_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_comp_level_factors;
      /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    raise;
    --
end create_comp_level_factors;
-- ----------------------------------------------------------------------------
-- |------------------------< update_comp_level_factors >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_comp_level_factors
  (p_validate                       in  boolean   default false
  ,p_comp_lvl_fctr_id               in  number
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_comp_lvl_det_cd                in  varchar2  default hr_api.g_varchar2
  ,p_comp_lvl_det_rl                in  number    default hr_api.g_number
  ,p_comp_lvl_uom                   in  varchar2  default hr_api.g_varchar2
  ,p_comp_src_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_no_mn_comp_flag                in  varchar2  default hr_api.g_varchar2
  ,p_no_mx_comp_flag                in  varchar2  default hr_api.g_varchar2
  ,p_mx_comp_val                    in  number    default hr_api.g_number
  ,p_mn_comp_val                    in  number    default hr_api.g_number
  ,p_rndg_cd                        in  varchar2  default hr_api.g_varchar2
  ,p_rndg_rl                        in  number    default hr_api.g_number
  ,p_defined_balance_id             in  number    default hr_api.g_number
  ,p_bnfts_bal_id                   in  number    default hr_api.g_number
  ,p_comp_alt_val_to_use_cd         in  varchar2  default hr_api.g_varchar2
  ,p_comp_calc_rl                   in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_proration_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_start_day_mo                   in  varchar2  default hr_api.g_varchar2
  ,p_end_day_mo                     in  varchar2  default hr_api.g_varchar2
  ,p_start_year                     in  varchar2  default hr_api.g_varchar2
  ,p_end_year                       in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_clf_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_sttd_sal_prdcty_cd             in  varchar2  default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_comp_level_factors';
  l_object_version_number ben_comp_lvl_fctr.object_version_number%TYPE;
  l_in_object_version_number  number  := p_object_version_number ;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_comp_level_factors;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_comp_level_factors
    --
    ben_comp_level_factors_bk2.update_comp_level_factors_b
      (
       p_comp_lvl_fctr_id               =>  p_comp_lvl_fctr_id
      ,p_name                           =>  p_name
      ,p_comp_lvl_det_cd                =>  p_comp_lvl_det_cd
      ,p_comp_lvl_det_rl                =>  p_comp_lvl_det_rl
      ,p_comp_lvl_uom                   =>  p_comp_lvl_uom
      ,p_comp_src_cd                    =>  p_comp_src_cd
      ,p_no_mn_comp_flag                =>  p_no_mn_comp_flag
      ,p_no_mx_comp_flag                =>  p_no_mx_comp_flag
      ,p_mx_comp_val                    =>  p_mx_comp_val
      ,p_mn_comp_val                    =>  p_mn_comp_val
      ,p_rndg_cd                        =>  p_rndg_cd
      ,p_rndg_rl                        =>  p_rndg_rl
      ,p_defined_balance_id             =>  p_defined_balance_id
      ,p_bnfts_bal_id                   =>  p_bnfts_bal_id
      ,p_comp_alt_val_to_use_cd         =>  p_comp_alt_val_to_use_cd
      ,p_comp_calc_rl                   =>  p_comp_calc_rl
      ,p_business_group_id              =>  p_business_group_id
      ,p_proration_flag                 =>  p_proration_flag
      ,p_start_day_mo                   =>  p_start_day_mo
      ,p_end_day_mo                     =>  p_end_day_mo
      ,p_start_year                     =>  p_start_year
      ,p_end_year                       =>  p_end_year
      ,p_clf_attribute_category         =>  p_clf_attribute_category
      ,p_clf_attribute1                 =>  p_clf_attribute1
      ,p_clf_attribute2                 =>  p_clf_attribute2
      ,p_clf_attribute3                 =>  p_clf_attribute3
      ,p_clf_attribute4                 =>  p_clf_attribute4
      ,p_clf_attribute5                 =>  p_clf_attribute5
      ,p_clf_attribute6                 =>  p_clf_attribute6
      ,p_clf_attribute7                 =>  p_clf_attribute7
      ,p_clf_attribute8                 =>  p_clf_attribute8
      ,p_clf_attribute9                 =>  p_clf_attribute9
      ,p_clf_attribute10                =>  p_clf_attribute10
      ,p_clf_attribute11                =>  p_clf_attribute11
      ,p_clf_attribute12                =>  p_clf_attribute12
      ,p_clf_attribute13                =>  p_clf_attribute13
      ,p_clf_attribute14                =>  p_clf_attribute14
      ,p_clf_attribute15                =>  p_clf_attribute15
      ,p_clf_attribute16                =>  p_clf_attribute16
      ,p_clf_attribute17                =>  p_clf_attribute17
      ,p_clf_attribute18                =>  p_clf_attribute18
      ,p_clf_attribute19                =>  p_clf_attribute19
      ,p_clf_attribute20                =>  p_clf_attribute20
      ,p_clf_attribute21                =>  p_clf_attribute21
      ,p_clf_attribute22                =>  p_clf_attribute22
      ,p_clf_attribute23                =>  p_clf_attribute23
      ,p_clf_attribute24                =>  p_clf_attribute24
      ,p_clf_attribute25                =>  p_clf_attribute25
      ,p_clf_attribute26                =>  p_clf_attribute26
      ,p_clf_attribute27                =>  p_clf_attribute27
      ,p_clf_attribute28                =>  p_clf_attribute28
      ,p_clf_attribute29                =>  p_clf_attribute29
      ,p_clf_attribute30                =>  p_clf_attribute30
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_sttd_sal_prdcty_cd             =>  p_sttd_sal_prdcty_cd
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_comp_level_factors'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_comp_level_factors
    --
  end;
  --
  ben_clf_upd.upd
    (
     p_comp_lvl_fctr_id              => p_comp_lvl_fctr_id
    ,p_name                          => p_name
    ,p_comp_lvl_det_cd               => p_comp_lvl_det_cd
    ,p_comp_lvl_det_rl               => p_comp_lvl_det_rl
    ,p_comp_lvl_uom                  => p_comp_lvl_uom
    ,p_comp_src_cd                   => p_comp_src_cd
    ,p_no_mn_comp_flag               => p_no_mn_comp_flag
    ,p_no_mx_comp_flag               => p_no_mx_comp_flag
    ,p_mx_comp_val                   => p_mx_comp_val
    ,p_mn_comp_val                   => p_mn_comp_val
    ,p_rndg_cd                       => p_rndg_cd
    ,p_rndg_rl                       => p_rndg_rl
    ,p_defined_balance_id            => p_defined_balance_id
    ,p_bnfts_bal_id                  => p_bnfts_bal_id
    ,p_comp_alt_val_to_use_cd        => p_comp_alt_val_to_use_cd
    ,p_comp_calc_rl                  => p_comp_calc_rl
    ,p_business_group_id             => p_business_group_id
    ,p_proration_flag                =>  p_proration_flag
    ,p_start_day_mo                  =>  p_start_day_mo
    ,p_end_day_mo                    =>  p_end_day_mo
    ,p_start_year                    =>  p_start_year
    ,p_end_year                      =>  p_end_year
    ,p_clf_attribute_category        => p_clf_attribute_category
    ,p_clf_attribute1                => p_clf_attribute1
    ,p_clf_attribute2                => p_clf_attribute2
    ,p_clf_attribute3                => p_clf_attribute3
    ,p_clf_attribute4                => p_clf_attribute4
    ,p_clf_attribute5                => p_clf_attribute5
    ,p_clf_attribute6                => p_clf_attribute6
    ,p_clf_attribute7                => p_clf_attribute7
    ,p_clf_attribute8                => p_clf_attribute8
    ,p_clf_attribute9                => p_clf_attribute9
    ,p_clf_attribute10               => p_clf_attribute10
    ,p_clf_attribute11               => p_clf_attribute11
    ,p_clf_attribute12               => p_clf_attribute12
    ,p_clf_attribute13               => p_clf_attribute13
    ,p_clf_attribute14               => p_clf_attribute14
    ,p_clf_attribute15               => p_clf_attribute15
    ,p_clf_attribute16               => p_clf_attribute16
    ,p_clf_attribute17               => p_clf_attribute17
    ,p_clf_attribute18               => p_clf_attribute18
    ,p_clf_attribute19               => p_clf_attribute19
    ,p_clf_attribute20               => p_clf_attribute20
    ,p_clf_attribute21               => p_clf_attribute21
    ,p_clf_attribute22               => p_clf_attribute22
    ,p_clf_attribute23               => p_clf_attribute23
    ,p_clf_attribute24               => p_clf_attribute24
    ,p_clf_attribute25               => p_clf_attribute25
    ,p_clf_attribute26               => p_clf_attribute26
    ,p_clf_attribute27               => p_clf_attribute27
    ,p_clf_attribute28               => p_clf_attribute28
    ,p_clf_attribute29               => p_clf_attribute29
    ,p_clf_attribute30               => p_clf_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_sttd_sal_prdcty_cd            => p_sttd_sal_prdcty_cd
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_comp_level_factors
    --
    ben_comp_level_factors_bk2.update_comp_level_factors_a
      (
       p_comp_lvl_fctr_id               =>  p_comp_lvl_fctr_id
      ,p_name                           =>  p_name
      ,p_comp_lvl_det_cd                =>  p_comp_lvl_det_cd
      ,p_comp_lvl_det_rl                =>  p_comp_lvl_det_rl
      ,p_comp_lvl_uom                   =>  p_comp_lvl_uom
      ,p_comp_src_cd                    =>  p_comp_src_cd
      ,p_no_mn_comp_flag                =>  p_no_mn_comp_flag
      ,p_no_mx_comp_flag                =>  p_no_mx_comp_flag
      ,p_mx_comp_val                    =>  p_mx_comp_val
      ,p_mn_comp_val                    =>  p_mn_comp_val
      ,p_rndg_cd                        =>  p_rndg_cd
      ,p_rndg_rl                        =>  p_rndg_rl
      ,p_defined_balance_id             =>  p_defined_balance_id
      ,p_bnfts_bal_id                   =>  p_bnfts_bal_id
      ,p_comp_alt_val_to_use_cd         =>  p_comp_alt_val_to_use_cd
      ,p_comp_calc_rl                   =>  p_comp_calc_rl
      ,p_business_group_id              =>  p_business_group_id
      ,p_proration_flag                 =>  p_proration_flag
      ,p_start_day_mo                   =>  p_start_day_mo
      ,p_end_day_mo                     =>  p_end_day_mo
      ,p_start_year                     =>  p_start_year
      ,p_end_year                       =>  p_end_year
      ,p_clf_attribute_category         =>  p_clf_attribute_category
      ,p_clf_attribute1                 =>  p_clf_attribute1
      ,p_clf_attribute2                 =>  p_clf_attribute2
      ,p_clf_attribute3                 =>  p_clf_attribute3
      ,p_clf_attribute4                 =>  p_clf_attribute4
      ,p_clf_attribute5                 =>  p_clf_attribute5
      ,p_clf_attribute6                 =>  p_clf_attribute6
      ,p_clf_attribute7                 =>  p_clf_attribute7
      ,p_clf_attribute8                 =>  p_clf_attribute8
      ,p_clf_attribute9                 =>  p_clf_attribute9
      ,p_clf_attribute10                =>  p_clf_attribute10
      ,p_clf_attribute11                =>  p_clf_attribute11
      ,p_clf_attribute12                =>  p_clf_attribute12
      ,p_clf_attribute13                =>  p_clf_attribute13
      ,p_clf_attribute14                =>  p_clf_attribute14
      ,p_clf_attribute15                =>  p_clf_attribute15
      ,p_clf_attribute16                =>  p_clf_attribute16
      ,p_clf_attribute17                =>  p_clf_attribute17
      ,p_clf_attribute18                =>  p_clf_attribute18
      ,p_clf_attribute19                =>  p_clf_attribute19
      ,p_clf_attribute20                =>  p_clf_attribute20
      ,p_clf_attribute21                =>  p_clf_attribute21
      ,p_clf_attribute22                =>  p_clf_attribute22
      ,p_clf_attribute23                =>  p_clf_attribute23
      ,p_clf_attribute24                =>  p_clf_attribute24
      ,p_clf_attribute25                =>  p_clf_attribute25
      ,p_clf_attribute26                =>  p_clf_attribute26
      ,p_clf_attribute27                =>  p_clf_attribute27
      ,p_clf_attribute28                =>  p_clf_attribute28
      ,p_clf_attribute29                =>  p_clf_attribute29
      ,p_clf_attribute30                =>  p_clf_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_sttd_sal_prdcty_cd             =>  p_sttd_sal_prdcty_cd
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_comp_level_factors'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_comp_level_factors
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
    ROLLBACK TO update_comp_level_factors;
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
    p_object_version_number := l_in_object_version_number ;
    --
    ROLLBACK TO update_comp_level_factors;
    /* Inserted for nocopy changes */
    raise;
    --
end update_comp_level_factors;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_comp_level_factors >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_comp_level_factors
  (p_validate                       in  boolean  default false
  ,p_comp_lvl_fctr_id               in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_comp_level_factors';
  l_object_version_number ben_comp_lvl_fctr.object_version_number%TYPE;
  l_in_object_version_number  number  := p_object_version_number ;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_comp_level_factors;
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
    -- Start of API User Hook for the before hook of delete_comp_level_factors
    --
    ben_comp_level_factors_bk3.delete_comp_level_factors_b
      (
       p_comp_lvl_fctr_id               =>  p_comp_lvl_fctr_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_comp_level_factors'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_comp_level_factors
    --
  end;
  --
  ben_clf_del.del
    (
     p_comp_lvl_fctr_id              => p_comp_lvl_fctr_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_comp_level_factors
    --
    ben_comp_level_factors_bk3.delete_comp_level_factors_a
      (
       p_comp_lvl_fctr_id               =>  p_comp_lvl_fctr_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_comp_level_factors'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_comp_level_factors
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
    ROLLBACK TO delete_comp_level_factors;
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
    p_object_version_number := l_in_object_version_number ;
    ROLLBACK TO delete_comp_level_factors;
    raise;
    --
end delete_comp_level_factors;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_comp_lvl_fctr_id                   in     number
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
  ben_clf_shd.lck
    (
      p_comp_lvl_fctr_id                 => p_comp_lvl_fctr_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_comp_level_factors_api;

/
