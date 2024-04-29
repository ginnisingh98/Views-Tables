--------------------------------------------------------
--  DDL for Package Body BEN_AGE_FACTOR_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_AGE_FACTOR_API" as
/* $Header: beagfapi.pkb 120.0 2005/05/28 00:22:47 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_age_factor_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_age_factor >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_age_factor
  (p_validate                       in  boolean   default false
  ,p_age_fctr_id                    out nocopy number
  ,p_name                           in  varchar2  default null
  ,p_mx_age_num                     in  number    default null
  ,p_mn_age_num                     in  number    default null
  ,p_age_uom                        in  varchar2  default null
  ,p_no_mn_age_flag                 in  varchar2  default null
  ,p_no_mx_age_flag                 in  varchar2  default null
  ,p_age_to_use_cd                  in  varchar2  default null
  ,p_age_det_cd                     in  varchar2  default null
  ,p_age_det_rl                     in  number    default null
  ,p_rndg_cd                        in  varchar2  default null
  ,p_rndg_rl                        in  number    default null
  ,p_age_calc_rl                    in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_agf_attribute_category         in  varchar2  default null
  ,p_agf_attribute1                 in  varchar2  default null
  ,p_agf_attribute2                 in  varchar2  default null
  ,p_agf_attribute3                 in  varchar2  default null
  ,p_agf_attribute4                 in  varchar2  default null
  ,p_agf_attribute5                 in  varchar2  default null
  ,p_agf_attribute6                 in  varchar2  default null
  ,p_agf_attribute7                 in  varchar2  default null
  ,p_agf_attribute8                 in  varchar2  default null
  ,p_agf_attribute9                 in  varchar2  default null
  ,p_agf_attribute10                in  varchar2  default null
  ,p_agf_attribute11                in  varchar2  default null
  ,p_agf_attribute12                in  varchar2  default null
  ,p_agf_attribute13                in  varchar2  default null
  ,p_agf_attribute14                in  varchar2  default null
  ,p_agf_attribute15                in  varchar2  default null
  ,p_agf_attribute16                in  varchar2  default null
  ,p_agf_attribute17                in  varchar2  default null
  ,p_agf_attribute18                in  varchar2  default null
  ,p_agf_attribute19                in  varchar2  default null
  ,p_agf_attribute20                in  varchar2  default null
  ,p_agf_attribute21                in  varchar2  default null
  ,p_agf_attribute22                in  varchar2  default null
  ,p_agf_attribute23                in  varchar2  default null
  ,p_agf_attribute24                in  varchar2  default null
  ,p_agf_attribute25                in  varchar2  default null
  ,p_agf_attribute26                in  varchar2  default null
  ,p_agf_attribute27                in  varchar2  default null
  ,p_agf_attribute28                in  varchar2  default null
  ,p_agf_attribute29                in  varchar2  default null
  ,p_agf_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_age_fctr_id ben_age_fctr.age_fctr_id%TYPE;
  l_proc varchar2(72) := g_package||'create_age_factor';
  l_object_version_number ben_age_fctr.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_age_factor;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_age_factor
    --
    ben_age_factor_bk1.create_age_factor_b
      (
       p_name                           =>  p_name
      ,p_mx_age_num                     =>  p_mx_age_num
      ,p_mn_age_num                     =>  p_mn_age_num
      ,p_age_uom                        =>  p_age_uom
      ,p_no_mn_age_flag                 =>  p_no_mn_age_flag
      ,p_no_mx_age_flag                 =>  p_no_mx_age_flag
      ,p_age_to_use_cd                  =>  p_age_to_use_cd
      ,p_age_det_cd                     =>  p_age_det_cd
      ,p_age_det_rl                     =>  p_age_det_rl
      ,p_rndg_cd                        =>  p_rndg_cd
      ,p_rndg_rl                        =>  p_rndg_rl
      ,p_age_calc_rl                    =>  p_age_calc_rl
      ,p_business_group_id              =>  p_business_group_id
      ,p_agf_attribute_category         =>  p_agf_attribute_category
      ,p_agf_attribute1                 =>  p_agf_attribute1
      ,p_agf_attribute2                 =>  p_agf_attribute2
      ,p_agf_attribute3                 =>  p_agf_attribute3
      ,p_agf_attribute4                 =>  p_agf_attribute4
      ,p_agf_attribute5                 =>  p_agf_attribute5
      ,p_agf_attribute6                 =>  p_agf_attribute6
      ,p_agf_attribute7                 =>  p_agf_attribute7
      ,p_agf_attribute8                 =>  p_agf_attribute8
      ,p_agf_attribute9                 =>  p_agf_attribute9
      ,p_agf_attribute10                =>  p_agf_attribute10
      ,p_agf_attribute11                =>  p_agf_attribute11
      ,p_agf_attribute12                =>  p_agf_attribute12
      ,p_agf_attribute13                =>  p_agf_attribute13
      ,p_agf_attribute14                =>  p_agf_attribute14
      ,p_agf_attribute15                =>  p_agf_attribute15
      ,p_agf_attribute16                =>  p_agf_attribute16
      ,p_agf_attribute17                =>  p_agf_attribute17
      ,p_agf_attribute18                =>  p_agf_attribute18
      ,p_agf_attribute19                =>  p_agf_attribute19
      ,p_agf_attribute20                =>  p_agf_attribute20
      ,p_agf_attribute21                =>  p_agf_attribute21
      ,p_agf_attribute22                =>  p_agf_attribute22
      ,p_agf_attribute23                =>  p_agf_attribute23
      ,p_agf_attribute24                =>  p_agf_attribute24
      ,p_agf_attribute25                =>  p_agf_attribute25
      ,p_agf_attribute26                =>  p_agf_attribute26
      ,p_agf_attribute27                =>  p_agf_attribute27
      ,p_agf_attribute28                =>  p_agf_attribute28
      ,p_agf_attribute29                =>  p_agf_attribute29
      ,p_agf_attribute30                =>  p_agf_attribute30
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_age_factor'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_age_factor
    --
  end;
  --
  ben_agf_ins.ins
    (
     p_age_fctr_id                   => l_age_fctr_id
    ,p_name                          => p_name
    ,p_mx_age_num                    => p_mx_age_num
    ,p_mn_age_num                    => p_mn_age_num
    ,p_age_uom                       => p_age_uom
    ,p_no_mn_age_flag                => p_no_mn_age_flag
    ,p_no_mx_age_flag                => p_no_mx_age_flag
    ,p_age_to_use_cd                 => p_age_to_use_cd
    ,p_age_det_cd                    => p_age_det_cd
    ,p_age_det_rl                    => p_age_det_rl
    ,p_rndg_cd                       => p_rndg_cd
    ,p_rndg_rl                       => p_rndg_rl
    ,p_age_calc_rl                   => p_age_calc_rl
    ,p_business_group_id             => p_business_group_id
    ,p_agf_attribute_category        => p_agf_attribute_category
    ,p_agf_attribute1                => p_agf_attribute1
    ,p_agf_attribute2                => p_agf_attribute2
    ,p_agf_attribute3                => p_agf_attribute3
    ,p_agf_attribute4                => p_agf_attribute4
    ,p_agf_attribute5                => p_agf_attribute5
    ,p_agf_attribute6                => p_agf_attribute6
    ,p_agf_attribute7                => p_agf_attribute7
    ,p_agf_attribute8                => p_agf_attribute8
    ,p_agf_attribute9                => p_agf_attribute9
    ,p_agf_attribute10               => p_agf_attribute10
    ,p_agf_attribute11               => p_agf_attribute11
    ,p_agf_attribute12               => p_agf_attribute12
    ,p_agf_attribute13               => p_agf_attribute13
    ,p_agf_attribute14               => p_agf_attribute14
    ,p_agf_attribute15               => p_agf_attribute15
    ,p_agf_attribute16               => p_agf_attribute16
    ,p_agf_attribute17               => p_agf_attribute17
    ,p_agf_attribute18               => p_agf_attribute18
    ,p_agf_attribute19               => p_agf_attribute19
    ,p_agf_attribute20               => p_agf_attribute20
    ,p_agf_attribute21               => p_agf_attribute21
    ,p_agf_attribute22               => p_agf_attribute22
    ,p_agf_attribute23               => p_agf_attribute23
    ,p_agf_attribute24               => p_agf_attribute24
    ,p_agf_attribute25               => p_agf_attribute25
    ,p_agf_attribute26               => p_agf_attribute26
    ,p_agf_attribute27               => p_agf_attribute27
    ,p_agf_attribute28               => p_agf_attribute28
    ,p_agf_attribute29               => p_agf_attribute29
    ,p_agf_attribute30               => p_agf_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_age_factor
    --
    ben_age_factor_bk1.create_age_factor_a
      (
       p_age_fctr_id                    =>  l_age_fctr_id
      ,p_name                           =>  p_name
      ,p_mx_age_num                     =>  p_mx_age_num
      ,p_mn_age_num                     =>  p_mn_age_num
      ,p_age_uom                        =>  p_age_uom
      ,p_no_mn_age_flag                 =>  p_no_mn_age_flag
      ,p_no_mx_age_flag                 =>  p_no_mx_age_flag
      ,p_age_to_use_cd                  =>  p_age_to_use_cd
      ,p_age_det_cd                     =>  p_age_det_cd
      ,p_age_det_rl                     =>  p_age_det_rl
      ,p_rndg_cd                        =>  p_rndg_cd
      ,p_rndg_rl                        =>  p_rndg_rl
      ,p_age_calc_rl                    =>  p_age_calc_rl
      ,p_business_group_id              =>  p_business_group_id
      ,p_agf_attribute_category         =>  p_agf_attribute_category
      ,p_agf_attribute1                 =>  p_agf_attribute1
      ,p_agf_attribute2                 =>  p_agf_attribute2
      ,p_agf_attribute3                 =>  p_agf_attribute3
      ,p_agf_attribute4                 =>  p_agf_attribute4
      ,p_agf_attribute5                 =>  p_agf_attribute5
      ,p_agf_attribute6                 =>  p_agf_attribute6
      ,p_agf_attribute7                 =>  p_agf_attribute7
      ,p_agf_attribute8                 =>  p_agf_attribute8
      ,p_agf_attribute9                 =>  p_agf_attribute9
      ,p_agf_attribute10                =>  p_agf_attribute10
      ,p_agf_attribute11                =>  p_agf_attribute11
      ,p_agf_attribute12                =>  p_agf_attribute12
      ,p_agf_attribute13                =>  p_agf_attribute13
      ,p_agf_attribute14                =>  p_agf_attribute14
      ,p_agf_attribute15                =>  p_agf_attribute15
      ,p_agf_attribute16                =>  p_agf_attribute16
      ,p_agf_attribute17                =>  p_agf_attribute17
      ,p_agf_attribute18                =>  p_agf_attribute18
      ,p_agf_attribute19                =>  p_agf_attribute19
      ,p_agf_attribute20                =>  p_agf_attribute20
      ,p_agf_attribute21                =>  p_agf_attribute21
      ,p_agf_attribute22                =>  p_agf_attribute22
      ,p_agf_attribute23                =>  p_agf_attribute23
      ,p_agf_attribute24                =>  p_agf_attribute24
      ,p_agf_attribute25                =>  p_agf_attribute25
      ,p_agf_attribute26                =>  p_agf_attribute26
      ,p_agf_attribute27                =>  p_agf_attribute27
      ,p_agf_attribute28                =>  p_agf_attribute28
      ,p_agf_attribute29                =>  p_agf_attribute29
      ,p_agf_attribute30                =>  p_agf_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_age_factor'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_age_factor
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
  p_age_fctr_id := l_age_fctr_id;
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
    ROLLBACK TO create_age_factor;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_age_fctr_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_age_factor;
    -- NOCOPY Changes
    p_age_fctr_id := null;
    p_object_version_number := null ;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end create_age_factor;
-- ----------------------------------------------------------------------------
-- |------------------------< update_age_factor >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_age_factor
  (p_validate                       in  boolean   default false
  ,p_age_fctr_id                    in  number
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_mx_age_num                     in  number    default hr_api.g_number
  ,p_mn_age_num                     in  number    default hr_api.g_number
  ,p_age_uom                        in  varchar2  default hr_api.g_varchar2
  ,p_no_mn_age_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_no_mx_age_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_age_to_use_cd                  in  varchar2  default hr_api.g_varchar2
  ,p_age_det_cd                     in  varchar2  default hr_api.g_varchar2
  ,p_age_det_rl                     in  number    default hr_api.g_number
  ,p_rndg_cd                        in  varchar2  default hr_api.g_varchar2
  ,p_rndg_rl                        in  number    default hr_api.g_number
  ,p_age_calc_rl                    in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_agf_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_agf_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_agf_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_agf_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_agf_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_agf_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_agf_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_agf_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_agf_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_agf_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_agf_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_agf_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_agf_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_agf_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_agf_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_agf_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_agf_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_agf_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_agf_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_agf_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_agf_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_agf_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_agf_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_agf_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_agf_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_agf_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_agf_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_agf_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_agf_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_agf_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_agf_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_age_factor';
  l_object_version_number ben_age_fctr.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_age_factor;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_age_factor
    --
    ben_age_factor_bk2.update_age_factor_b
      (
       p_age_fctr_id                    =>  p_age_fctr_id
      ,p_name                           =>  p_name
      ,p_mx_age_num                     =>  p_mx_age_num
      ,p_mn_age_num                     =>  p_mn_age_num
      ,p_age_uom                        =>  p_age_uom
      ,p_no_mn_age_flag                 =>  p_no_mn_age_flag
      ,p_no_mx_age_flag                 =>  p_no_mx_age_flag
      ,p_age_to_use_cd                  =>  p_age_to_use_cd
      ,p_age_det_cd                     =>  p_age_det_cd
      ,p_age_det_rl                     =>  p_age_det_rl
      ,p_rndg_cd                        =>  p_rndg_cd
      ,p_rndg_rl                        =>  p_rndg_rl
      ,p_age_calc_rl                    =>  p_age_calc_rl
      ,p_business_group_id              =>  p_business_group_id
      ,p_agf_attribute_category         =>  p_agf_attribute_category
      ,p_agf_attribute1                 =>  p_agf_attribute1
      ,p_agf_attribute2                 =>  p_agf_attribute2
      ,p_agf_attribute3                 =>  p_agf_attribute3
      ,p_agf_attribute4                 =>  p_agf_attribute4
      ,p_agf_attribute5                 =>  p_agf_attribute5
      ,p_agf_attribute6                 =>  p_agf_attribute6
      ,p_agf_attribute7                 =>  p_agf_attribute7
      ,p_agf_attribute8                 =>  p_agf_attribute8
      ,p_agf_attribute9                 =>  p_agf_attribute9
      ,p_agf_attribute10                =>  p_agf_attribute10
      ,p_agf_attribute11                =>  p_agf_attribute11
      ,p_agf_attribute12                =>  p_agf_attribute12
      ,p_agf_attribute13                =>  p_agf_attribute13
      ,p_agf_attribute14                =>  p_agf_attribute14
      ,p_agf_attribute15                =>  p_agf_attribute15
      ,p_agf_attribute16                =>  p_agf_attribute16
      ,p_agf_attribute17                =>  p_agf_attribute17
      ,p_agf_attribute18                =>  p_agf_attribute18
      ,p_agf_attribute19                =>  p_agf_attribute19
      ,p_agf_attribute20                =>  p_agf_attribute20
      ,p_agf_attribute21                =>  p_agf_attribute21
      ,p_agf_attribute22                =>  p_agf_attribute22
      ,p_agf_attribute23                =>  p_agf_attribute23
      ,p_agf_attribute24                =>  p_agf_attribute24
      ,p_agf_attribute25                =>  p_agf_attribute25
      ,p_agf_attribute26                =>  p_agf_attribute26
      ,p_agf_attribute27                =>  p_agf_attribute27
      ,p_agf_attribute28                =>  p_agf_attribute28
      ,p_agf_attribute29                =>  p_agf_attribute29
      ,p_agf_attribute30                =>  p_agf_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_age_factor'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_age_factor
    --
  end;
  --
  ben_agf_upd.upd
    (
     p_age_fctr_id                   => p_age_fctr_id
    ,p_name                          => p_name
    ,p_mx_age_num                    => p_mx_age_num
    ,p_mn_age_num                    => p_mn_age_num
    ,p_age_uom                       => p_age_uom
    ,p_no_mn_age_flag                => p_no_mn_age_flag
    ,p_no_mx_age_flag                => p_no_mx_age_flag
    ,p_age_to_use_cd                 => p_age_to_use_cd
    ,p_age_det_cd                    => p_age_det_cd
    ,p_age_det_rl                    => p_age_det_rl
    ,p_rndg_cd                       => p_rndg_cd
    ,p_rndg_rl                       => p_rndg_rl
    ,p_age_calc_rl                   => p_age_calc_rl
    ,p_business_group_id             => p_business_group_id
    ,p_agf_attribute_category        => p_agf_attribute_category
    ,p_agf_attribute1                => p_agf_attribute1
    ,p_agf_attribute2                => p_agf_attribute2
    ,p_agf_attribute3                => p_agf_attribute3
    ,p_agf_attribute4                => p_agf_attribute4
    ,p_agf_attribute5                => p_agf_attribute5
    ,p_agf_attribute6                => p_agf_attribute6
    ,p_agf_attribute7                => p_agf_attribute7
    ,p_agf_attribute8                => p_agf_attribute8
    ,p_agf_attribute9                => p_agf_attribute9
    ,p_agf_attribute10               => p_agf_attribute10
    ,p_agf_attribute11               => p_agf_attribute11
    ,p_agf_attribute12               => p_agf_attribute12
    ,p_agf_attribute13               => p_agf_attribute13
    ,p_agf_attribute14               => p_agf_attribute14
    ,p_agf_attribute15               => p_agf_attribute15
    ,p_agf_attribute16               => p_agf_attribute16
    ,p_agf_attribute17               => p_agf_attribute17
    ,p_agf_attribute18               => p_agf_attribute18
    ,p_agf_attribute19               => p_agf_attribute19
    ,p_agf_attribute20               => p_agf_attribute20
    ,p_agf_attribute21               => p_agf_attribute21
    ,p_agf_attribute22               => p_agf_attribute22
    ,p_agf_attribute23               => p_agf_attribute23
    ,p_agf_attribute24               => p_agf_attribute24
    ,p_agf_attribute25               => p_agf_attribute25
    ,p_agf_attribute26               => p_agf_attribute26
    ,p_agf_attribute27               => p_agf_attribute27
    ,p_agf_attribute28               => p_agf_attribute28
    ,p_agf_attribute29               => p_agf_attribute29
    ,p_agf_attribute30               => p_agf_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_age_factor
    --
    ben_age_factor_bk2.update_age_factor_a
      (
       p_age_fctr_id                    =>  p_age_fctr_id
      ,p_name                           =>  p_name
      ,p_mx_age_num                     =>  p_mx_age_num
      ,p_mn_age_num                     =>  p_mn_age_num
      ,p_age_uom                        =>  p_age_uom
      ,p_no_mn_age_flag                 =>  p_no_mn_age_flag
      ,p_no_mx_age_flag                 =>  p_no_mx_age_flag
      ,p_age_to_use_cd                  =>  p_age_to_use_cd
      ,p_age_det_cd                     =>  p_age_det_cd
      ,p_age_det_rl                     =>  p_age_det_rl
      ,p_rndg_cd                        =>  p_rndg_cd
      ,p_rndg_rl                        =>  p_rndg_rl
      ,p_age_calc_rl                    =>  p_age_calc_rl
      ,p_business_group_id              =>  p_business_group_id
      ,p_agf_attribute_category         =>  p_agf_attribute_category
      ,p_agf_attribute1                 =>  p_agf_attribute1
      ,p_agf_attribute2                 =>  p_agf_attribute2
      ,p_agf_attribute3                 =>  p_agf_attribute3
      ,p_agf_attribute4                 =>  p_agf_attribute4
      ,p_agf_attribute5                 =>  p_agf_attribute5
      ,p_agf_attribute6                 =>  p_agf_attribute6
      ,p_agf_attribute7                 =>  p_agf_attribute7
      ,p_agf_attribute8                 =>  p_agf_attribute8
      ,p_agf_attribute9                 =>  p_agf_attribute9
      ,p_agf_attribute10                =>  p_agf_attribute10
      ,p_agf_attribute11                =>  p_agf_attribute11
      ,p_agf_attribute12                =>  p_agf_attribute12
      ,p_agf_attribute13                =>  p_agf_attribute13
      ,p_agf_attribute14                =>  p_agf_attribute14
      ,p_agf_attribute15                =>  p_agf_attribute15
      ,p_agf_attribute16                =>  p_agf_attribute16
      ,p_agf_attribute17                =>  p_agf_attribute17
      ,p_agf_attribute18                =>  p_agf_attribute18
      ,p_agf_attribute19                =>  p_agf_attribute19
      ,p_agf_attribute20                =>  p_agf_attribute20
      ,p_agf_attribute21                =>  p_agf_attribute21
      ,p_agf_attribute22                =>  p_agf_attribute22
      ,p_agf_attribute23                =>  p_agf_attribute23
      ,p_agf_attribute24                =>  p_agf_attribute24
      ,p_agf_attribute25                =>  p_agf_attribute25
      ,p_agf_attribute26                =>  p_agf_attribute26
      ,p_agf_attribute27                =>  p_agf_attribute27
      ,p_agf_attribute28                =>  p_agf_attribute28
      ,p_agf_attribute29                =>  p_agf_attribute29
      ,p_agf_attribute30                =>  p_agf_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_age_factor'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_age_factor
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
    ROLLBACK TO update_age_factor;
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
    ROLLBACK TO update_age_factor;
    -- NOCOPY Changes
    p_object_version_number := l_object_version_number ;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end update_age_factor;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_age_factor >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_age_factor
  (p_validate                       in  boolean  default false
  ,p_age_fctr_id                    in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_age_factor';
  l_object_version_number ben_age_fctr.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_age_factor;
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
    -- Start of API User Hook for the before hook of delete_age_factor
    --
    ben_age_factor_bk3.delete_age_factor_b
      (
       p_age_fctr_id                    =>  p_age_fctr_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_age_factor'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_age_factor
    --
  end;
  --
  ben_agf_del.del
    (
     p_age_fctr_id                   => p_age_fctr_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_age_factor
    --
    ben_age_factor_bk3.delete_age_factor_a
      (
       p_age_fctr_id                    =>  p_age_fctr_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_age_factor'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_age_factor
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
    ROLLBACK TO delete_age_factor;
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
    ROLLBACK TO delete_age_factor;
    -- NOCOPY Changes
    p_object_version_number := l_object_version_number ;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end delete_age_factor;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_age_fctr_id                   in     number
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
  ben_agf_shd.lck
    (
      p_age_fctr_id                 => p_age_fctr_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_age_factor_api;

/
