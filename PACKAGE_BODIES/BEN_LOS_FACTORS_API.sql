--------------------------------------------------------
--  DDL for Package Body BEN_LOS_FACTORS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_LOS_FACTORS_API" as
/* $Header: belsfapi.pkb 115.4 2002/12/16 17:38:15 glingapp ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_LOS_FACTORS_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_LOS_FACTORS >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_LOS_FACTORS
  (p_validate                       in  boolean   default false
  ,p_los_fctr_id                    out nocopy number
  ,p_name                           in  varchar2  default null
  ,p_business_group_id              in  number    default null
  ,p_los_det_cd                     in  varchar2  default null
  ,p_los_det_rl                     in  number    default null
  ,p_mn_los_num                     in  number    default null
  ,p_mx_los_num                     in  number    default null
  ,p_no_mx_los_num_apls_flag        in  varchar2  default null
  ,p_no_mn_los_num_apls_flag        in  varchar2  default null
  ,p_rndg_cd                        in  varchar2  default null
  ,p_rndg_rl                        in  number    default null
  ,p_los_dt_to_use_cd               in  varchar2  default null
  ,p_los_dt_to_use_rl               in  number    default null
  ,p_los_uom                        in  varchar2  default null
  ,p_los_calc_rl                    in  number    default null
  ,p_los_alt_val_to_use_cd          in  varchar2  default null
  ,p_lsf_attribute_category         in  varchar2  default null
  ,p_lsf_attribute1                 in  varchar2  default null
  ,p_lsf_attribute2                 in  varchar2  default null
  ,p_lsf_attribute3                 in  varchar2  default null
  ,p_lsf_attribute4                 in  varchar2  default null
  ,p_lsf_attribute5                 in  varchar2  default null
  ,p_lsf_attribute6                 in  varchar2  default null
  ,p_lsf_attribute7                 in  varchar2  default null
  ,p_lsf_attribute8                 in  varchar2  default null
  ,p_lsf_attribute9                 in  varchar2  default null
  ,p_lsf_attribute10                in  varchar2  default null
  ,p_lsf_attribute11                in  varchar2  default null
  ,p_lsf_attribute12                in  varchar2  default null
  ,p_lsf_attribute13                in  varchar2  default null
  ,p_lsf_attribute14                in  varchar2  default null
  ,p_lsf_attribute15                in  varchar2  default null
  ,p_lsf_attribute16                in  varchar2  default null
  ,p_lsf_attribute17                in  varchar2  default null
  ,p_lsf_attribute18                in  varchar2  default null
  ,p_lsf_attribute19                in  varchar2  default null
  ,p_lsf_attribute20                in  varchar2  default null
  ,p_lsf_attribute21                in  varchar2  default null
  ,p_lsf_attribute22                in  varchar2  default null
  ,p_lsf_attribute23                in  varchar2  default null
  ,p_lsf_attribute24                in  varchar2  default null
  ,p_lsf_attribute25                in  varchar2  default null
  ,p_lsf_attribute26                in  varchar2  default null
  ,p_lsf_attribute27                in  varchar2  default null
  ,p_lsf_attribute28                in  varchar2  default null
  ,p_lsf_attribute29                in  varchar2  default null
  ,p_lsf_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_use_overid_svc_dt_flag         in  varchar2  default null
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_los_fctr_id ben_los_fctr.los_fctr_id%TYPE;
  l_proc varchar2(72) := g_package||'create_LOS_FACTORS';
  l_object_version_number ben_los_fctr.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_LOS_FACTORS;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_LOS_FACTORS
    --
    ben_LOS_FACTORS_bk1.create_LOS_FACTORS_b
      (
       p_name                           =>  p_name
      ,p_business_group_id              =>  p_business_group_id
      ,p_los_det_cd                     =>  p_los_det_cd
      ,p_los_det_rl                     =>  p_los_det_rl
      ,p_mn_los_num                     =>  p_mn_los_num
      ,p_mx_los_num                     =>  p_mx_los_num
      ,p_no_mx_los_num_apls_flag        =>  p_no_mx_los_num_apls_flag
      ,p_no_mn_los_num_apls_flag        =>  p_no_mn_los_num_apls_flag
      ,p_rndg_cd                        =>  p_rndg_cd
      ,p_rndg_rl                        =>  p_rndg_rl
      ,p_los_dt_to_use_cd               =>  p_los_dt_to_use_cd
      ,p_los_dt_to_use_rl               =>  p_los_dt_to_use_rl
      ,p_los_uom                        =>  p_los_uom
      ,p_los_calc_rl                    =>  p_los_calc_rl
      ,p_los_alt_val_to_use_cd          =>  p_los_alt_val_to_use_cd
      ,p_lsf_attribute_category         =>  p_lsf_attribute_category
      ,p_lsf_attribute1                 =>  p_lsf_attribute1
      ,p_lsf_attribute2                 =>  p_lsf_attribute2
      ,p_lsf_attribute3                 =>  p_lsf_attribute3
      ,p_lsf_attribute4                 =>  p_lsf_attribute4
      ,p_lsf_attribute5                 =>  p_lsf_attribute5
      ,p_lsf_attribute6                 =>  p_lsf_attribute6
      ,p_lsf_attribute7                 =>  p_lsf_attribute7
      ,p_lsf_attribute8                 =>  p_lsf_attribute8
      ,p_lsf_attribute9                 =>  p_lsf_attribute9
      ,p_lsf_attribute10                =>  p_lsf_attribute10
      ,p_lsf_attribute11                =>  p_lsf_attribute11
      ,p_lsf_attribute12                =>  p_lsf_attribute12
      ,p_lsf_attribute13                =>  p_lsf_attribute13
      ,p_lsf_attribute14                =>  p_lsf_attribute14
      ,p_lsf_attribute15                =>  p_lsf_attribute15
      ,p_lsf_attribute16                =>  p_lsf_attribute16
      ,p_lsf_attribute17                =>  p_lsf_attribute17
      ,p_lsf_attribute18                =>  p_lsf_attribute18
      ,p_lsf_attribute19                =>  p_lsf_attribute19
      ,p_lsf_attribute20                =>  p_lsf_attribute20
      ,p_lsf_attribute21                =>  p_lsf_attribute21
      ,p_lsf_attribute22                =>  p_lsf_attribute22
      ,p_lsf_attribute23                =>  p_lsf_attribute23
      ,p_lsf_attribute24                =>  p_lsf_attribute24
      ,p_lsf_attribute25                =>  p_lsf_attribute25
      ,p_lsf_attribute26                =>  p_lsf_attribute26
      ,p_lsf_attribute27                =>  p_lsf_attribute27
      ,p_lsf_attribute28                =>  p_lsf_attribute28
      ,p_lsf_attribute29                =>  p_lsf_attribute29
      ,p_lsf_attribute30                =>  p_lsf_attribute30
      ,p_use_overid_svc_dt_flag         =>  p_use_overid_svc_dt_flag
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_LOS_FACTORS'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_LOS_FACTORS
    --
  end;
  --
  ben_lsf_ins.ins
    (
     p_los_fctr_id                   => l_los_fctr_id
    ,p_name                          => p_name
    ,p_business_group_id             => p_business_group_id
    ,p_los_det_cd                    => p_los_det_cd
    ,p_los_det_rl                    => p_los_det_rl
    ,p_mn_los_num                    => p_mn_los_num
    ,p_mx_los_num                    => p_mx_los_num
    ,p_no_mx_los_num_apls_flag       => p_no_mx_los_num_apls_flag
    ,p_no_mn_los_num_apls_flag       => p_no_mn_los_num_apls_flag
    ,p_rndg_cd                       => p_rndg_cd
    ,p_rndg_rl                       => p_rndg_rl
    ,p_los_dt_to_use_cd              => p_los_dt_to_use_cd
    ,p_los_dt_to_use_rl              => p_los_dt_to_use_rl
    ,p_los_uom                       => p_los_uom
    ,p_los_calc_rl                   => p_los_calc_rl
    ,p_los_alt_val_to_use_cd         => p_los_alt_val_to_use_cd
    ,p_lsf_attribute_category        => p_lsf_attribute_category
    ,p_lsf_attribute1                => p_lsf_attribute1
    ,p_lsf_attribute2                => p_lsf_attribute2
    ,p_lsf_attribute3                => p_lsf_attribute3
    ,p_lsf_attribute4                => p_lsf_attribute4
    ,p_lsf_attribute5                => p_lsf_attribute5
    ,p_lsf_attribute6                => p_lsf_attribute6
    ,p_lsf_attribute7                => p_lsf_attribute7
    ,p_lsf_attribute8                => p_lsf_attribute8
    ,p_lsf_attribute9                => p_lsf_attribute9
    ,p_lsf_attribute10               => p_lsf_attribute10
    ,p_lsf_attribute11               => p_lsf_attribute11
    ,p_lsf_attribute12               => p_lsf_attribute12
    ,p_lsf_attribute13               => p_lsf_attribute13
    ,p_lsf_attribute14               => p_lsf_attribute14
    ,p_lsf_attribute15               => p_lsf_attribute15
    ,p_lsf_attribute16               => p_lsf_attribute16
    ,p_lsf_attribute17               => p_lsf_attribute17
    ,p_lsf_attribute18               => p_lsf_attribute18
    ,p_lsf_attribute19               => p_lsf_attribute19
    ,p_lsf_attribute20               => p_lsf_attribute20
    ,p_lsf_attribute21               => p_lsf_attribute21
    ,p_lsf_attribute22               => p_lsf_attribute22
    ,p_lsf_attribute23               => p_lsf_attribute23
    ,p_lsf_attribute24               => p_lsf_attribute24
    ,p_lsf_attribute25               => p_lsf_attribute25
    ,p_lsf_attribute26               => p_lsf_attribute26
    ,p_lsf_attribute27               => p_lsf_attribute27
    ,p_lsf_attribute28               => p_lsf_attribute28
    ,p_lsf_attribute29               => p_lsf_attribute29
    ,p_lsf_attribute30               => p_lsf_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_use_overid_svc_dt_flag        => p_use_overid_svc_dt_flag
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_LOS_FACTORS
    --
    ben_LOS_FACTORS_bk1.create_LOS_FACTORS_a
      (
       p_los_fctr_id                    =>  l_los_fctr_id
      ,p_name                           =>  p_name
      ,p_business_group_id              =>  p_business_group_id
      ,p_los_det_cd                     =>  p_los_det_cd
      ,p_los_det_rl                     =>  p_los_det_rl
      ,p_mn_los_num                     =>  p_mn_los_num
      ,p_mx_los_num                     =>  p_mx_los_num
      ,p_no_mx_los_num_apls_flag        =>  p_no_mx_los_num_apls_flag
      ,p_no_mn_los_num_apls_flag        =>  p_no_mn_los_num_apls_flag
      ,p_rndg_cd                        =>  p_rndg_cd
      ,p_rndg_rl                        =>  p_rndg_rl
      ,p_los_dt_to_use_cd               =>  p_los_dt_to_use_cd
      ,p_los_dt_to_use_rl               =>  p_los_dt_to_use_rl
      ,p_los_uom                        =>  p_los_uom
      ,p_los_calc_rl                    =>  p_los_calc_rl
      ,p_los_alt_val_to_use_cd          =>  p_los_alt_val_to_use_cd
      ,p_lsf_attribute_category         =>  p_lsf_attribute_category
      ,p_lsf_attribute1                 =>  p_lsf_attribute1
      ,p_lsf_attribute2                 =>  p_lsf_attribute2
      ,p_lsf_attribute3                 =>  p_lsf_attribute3
      ,p_lsf_attribute4                 =>  p_lsf_attribute4
      ,p_lsf_attribute5                 =>  p_lsf_attribute5
      ,p_lsf_attribute6                 =>  p_lsf_attribute6
      ,p_lsf_attribute7                 =>  p_lsf_attribute7
      ,p_lsf_attribute8                 =>  p_lsf_attribute8
      ,p_lsf_attribute9                 =>  p_lsf_attribute9
      ,p_lsf_attribute10                =>  p_lsf_attribute10
      ,p_lsf_attribute11                =>  p_lsf_attribute11
      ,p_lsf_attribute12                =>  p_lsf_attribute12
      ,p_lsf_attribute13                =>  p_lsf_attribute13
      ,p_lsf_attribute14                =>  p_lsf_attribute14
      ,p_lsf_attribute15                =>  p_lsf_attribute15
      ,p_lsf_attribute16                =>  p_lsf_attribute16
      ,p_lsf_attribute17                =>  p_lsf_attribute17
      ,p_lsf_attribute18                =>  p_lsf_attribute18
      ,p_lsf_attribute19                =>  p_lsf_attribute19
      ,p_lsf_attribute20                =>  p_lsf_attribute20
      ,p_lsf_attribute21                =>  p_lsf_attribute21
      ,p_lsf_attribute22                =>  p_lsf_attribute22
      ,p_lsf_attribute23                =>  p_lsf_attribute23
      ,p_lsf_attribute24                =>  p_lsf_attribute24
      ,p_lsf_attribute25                =>  p_lsf_attribute25
      ,p_lsf_attribute26                =>  p_lsf_attribute26
      ,p_lsf_attribute27                =>  p_lsf_attribute27
      ,p_lsf_attribute28                =>  p_lsf_attribute28
      ,p_lsf_attribute29                =>  p_lsf_attribute29
      ,p_lsf_attribute30                =>  p_lsf_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_use_overid_svc_dt_flag         =>  p_use_overid_svc_dt_flag
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_LOS_FACTORS'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_LOS_FACTORS
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
  p_los_fctr_id := l_los_fctr_id;
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
    ROLLBACK TO create_LOS_FACTORS;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_los_fctr_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_LOS_FACTORS;
    p_los_fctr_id := null;
    p_object_version_number  := null;
    raise;
    --
end create_LOS_FACTORS;
-- ----------------------------------------------------------------------------
-- |------------------------< update_LOS_FACTORS >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_LOS_FACTORS
  (p_validate                       in  boolean   default false
  ,p_los_fctr_id                    in  number
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_los_det_cd                     in  varchar2  default hr_api.g_varchar2
  ,p_los_det_rl                     in  number    default hr_api.g_number
  ,p_mn_los_num                     in  number    default hr_api.g_number
  ,p_mx_los_num                     in  number    default hr_api.g_number
  ,p_no_mx_los_num_apls_flag        in  varchar2  default hr_api.g_varchar2
  ,p_no_mn_los_num_apls_flag        in  varchar2  default hr_api.g_varchar2
  ,p_rndg_cd                        in  varchar2  default hr_api.g_varchar2
  ,p_rndg_rl                        in  number    default hr_api.g_number
  ,p_los_dt_to_use_cd               in  varchar2  default hr_api.g_varchar2
  ,p_los_dt_to_use_rl               in  number    default hr_api.g_number
  ,p_los_uom                        in  varchar2  default hr_api.g_varchar2
  ,p_los_calc_rl                    in  number    default hr_api.g_number
  ,p_los_alt_val_to_use_cd          in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_lsf_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_use_overid_svc_dt_flag         in  varchar2  default hr_api.g_varchar2
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_LOS_FACTORS';
  l_object_version_number ben_los_fctr.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_LOS_FACTORS;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_LOS_FACTORS
    --
    ben_LOS_FACTORS_bk2.update_LOS_FACTORS_b
      (
       p_los_fctr_id                    =>  p_los_fctr_id
      ,p_name                           =>  p_name
      ,p_business_group_id              =>  p_business_group_id
      ,p_los_det_cd                     =>  p_los_det_cd
      ,p_los_det_rl                     =>  p_los_det_rl
      ,p_mn_los_num                     =>  p_mn_los_num
      ,p_mx_los_num                     =>  p_mx_los_num
      ,p_no_mx_los_num_apls_flag        =>  p_no_mx_los_num_apls_flag
      ,p_no_mn_los_num_apls_flag        =>  p_no_mn_los_num_apls_flag
      ,p_rndg_cd                        =>  p_rndg_cd
      ,p_rndg_rl                        =>  p_rndg_rl
      ,p_los_dt_to_use_cd               =>  p_los_dt_to_use_cd
      ,p_los_dt_to_use_rl               =>  p_los_dt_to_use_rl
      ,p_los_uom                        =>  p_los_uom
      ,p_los_calc_rl                    =>  p_los_calc_rl
      ,p_los_alt_val_to_use_cd          =>  p_los_alt_val_to_use_cd
      ,p_lsf_attribute_category         =>  p_lsf_attribute_category
      ,p_lsf_attribute1                 =>  p_lsf_attribute1
      ,p_lsf_attribute2                 =>  p_lsf_attribute2
      ,p_lsf_attribute3                 =>  p_lsf_attribute3
      ,p_lsf_attribute4                 =>  p_lsf_attribute4
      ,p_lsf_attribute5                 =>  p_lsf_attribute5
      ,p_lsf_attribute6                 =>  p_lsf_attribute6
      ,p_lsf_attribute7                 =>  p_lsf_attribute7
      ,p_lsf_attribute8                 =>  p_lsf_attribute8
      ,p_lsf_attribute9                 =>  p_lsf_attribute9
      ,p_lsf_attribute10                =>  p_lsf_attribute10
      ,p_lsf_attribute11                =>  p_lsf_attribute11
      ,p_lsf_attribute12                =>  p_lsf_attribute12
      ,p_lsf_attribute13                =>  p_lsf_attribute13
      ,p_lsf_attribute14                =>  p_lsf_attribute14
      ,p_lsf_attribute15                =>  p_lsf_attribute15
      ,p_lsf_attribute16                =>  p_lsf_attribute16
      ,p_lsf_attribute17                =>  p_lsf_attribute17
      ,p_lsf_attribute18                =>  p_lsf_attribute18
      ,p_lsf_attribute19                =>  p_lsf_attribute19
      ,p_lsf_attribute20                =>  p_lsf_attribute20
      ,p_lsf_attribute21                =>  p_lsf_attribute21
      ,p_lsf_attribute22                =>  p_lsf_attribute22
      ,p_lsf_attribute23                =>  p_lsf_attribute23
      ,p_lsf_attribute24                =>  p_lsf_attribute24
      ,p_lsf_attribute25                =>  p_lsf_attribute25
      ,p_lsf_attribute26                =>  p_lsf_attribute26
      ,p_lsf_attribute27                =>  p_lsf_attribute27
      ,p_lsf_attribute28                =>  p_lsf_attribute28
      ,p_lsf_attribute29                =>  p_lsf_attribute29
      ,p_lsf_attribute30                =>  p_lsf_attribute30
      ,p_object_version_number          =>  p_object_version_number
      ,p_use_overid_svc_dt_flag         =>  p_use_overid_svc_dt_flag
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_LOS_FACTORS'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_LOS_FACTORS
    --
  end;
  --
  ben_lsf_upd.upd
    (
     p_los_fctr_id                   => p_los_fctr_id
    ,p_name                          => p_name
    ,p_business_group_id             => p_business_group_id
    ,p_los_det_cd                    => p_los_det_cd
    ,p_los_det_rl                    => p_los_det_rl
    ,p_mn_los_num                    => p_mn_los_num
    ,p_mx_los_num                    => p_mx_los_num
    ,p_no_mx_los_num_apls_flag       => p_no_mx_los_num_apls_flag
    ,p_no_mn_los_num_apls_flag       => p_no_mn_los_num_apls_flag
    ,p_rndg_cd                       => p_rndg_cd
    ,p_rndg_rl                       => p_rndg_rl
    ,p_los_dt_to_use_cd              => p_los_dt_to_use_cd
    ,p_los_dt_to_use_rl              => p_los_dt_to_use_rl
    ,p_los_uom                       => p_los_uom
    ,p_los_calc_rl                   => p_los_calc_rl
    ,p_los_alt_val_to_use_cd         => p_los_alt_val_to_use_cd
    ,p_lsf_attribute_category        => p_lsf_attribute_category
    ,p_lsf_attribute1                => p_lsf_attribute1
    ,p_lsf_attribute2                => p_lsf_attribute2
    ,p_lsf_attribute3                => p_lsf_attribute3
    ,p_lsf_attribute4                => p_lsf_attribute4
    ,p_lsf_attribute5                => p_lsf_attribute5
    ,p_lsf_attribute6                => p_lsf_attribute6
    ,p_lsf_attribute7                => p_lsf_attribute7
    ,p_lsf_attribute8                => p_lsf_attribute8
    ,p_lsf_attribute9                => p_lsf_attribute9
    ,p_lsf_attribute10               => p_lsf_attribute10
    ,p_lsf_attribute11               => p_lsf_attribute11
    ,p_lsf_attribute12               => p_lsf_attribute12
    ,p_lsf_attribute13               => p_lsf_attribute13
    ,p_lsf_attribute14               => p_lsf_attribute14
    ,p_lsf_attribute15               => p_lsf_attribute15
    ,p_lsf_attribute16               => p_lsf_attribute16
    ,p_lsf_attribute17               => p_lsf_attribute17
    ,p_lsf_attribute18               => p_lsf_attribute18
    ,p_lsf_attribute19               => p_lsf_attribute19
    ,p_lsf_attribute20               => p_lsf_attribute20
    ,p_lsf_attribute21               => p_lsf_attribute21
    ,p_lsf_attribute22               => p_lsf_attribute22
    ,p_lsf_attribute23               => p_lsf_attribute23
    ,p_lsf_attribute24               => p_lsf_attribute24
    ,p_lsf_attribute25               => p_lsf_attribute25
    ,p_lsf_attribute26               => p_lsf_attribute26
    ,p_lsf_attribute27               => p_lsf_attribute27
    ,p_lsf_attribute28               => p_lsf_attribute28
    ,p_lsf_attribute29               => p_lsf_attribute29
    ,p_lsf_attribute30               => p_lsf_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_use_overid_svc_dt_flag        => p_use_overid_svc_dt_flag
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_LOS_FACTORS
    --
    ben_LOS_FACTORS_bk2.update_LOS_FACTORS_a
      (
       p_los_fctr_id                    =>  p_los_fctr_id
      ,p_name                           =>  p_name
      ,p_business_group_id              =>  p_business_group_id
      ,p_los_det_cd                     =>  p_los_det_cd
      ,p_los_det_rl                     =>  p_los_det_rl
      ,p_mn_los_num                     =>  p_mn_los_num
      ,p_mx_los_num                     =>  p_mx_los_num
      ,p_no_mx_los_num_apls_flag        =>  p_no_mx_los_num_apls_flag
      ,p_no_mn_los_num_apls_flag        =>  p_no_mn_los_num_apls_flag
      ,p_rndg_cd                        =>  p_rndg_cd
      ,p_rndg_rl                        =>  p_rndg_rl
      ,p_los_dt_to_use_cd               =>  p_los_dt_to_use_cd
      ,p_los_dt_to_use_rl               =>  p_los_dt_to_use_rl
      ,p_los_uom                        =>  p_los_uom
      ,p_los_calc_rl                    =>  p_los_calc_rl
      ,p_los_alt_val_to_use_cd          =>  p_los_alt_val_to_use_cd
      ,p_lsf_attribute_category         =>  p_lsf_attribute_category
      ,p_lsf_attribute1                 =>  p_lsf_attribute1
      ,p_lsf_attribute2                 =>  p_lsf_attribute2
      ,p_lsf_attribute3                 =>  p_lsf_attribute3
      ,p_lsf_attribute4                 =>  p_lsf_attribute4
      ,p_lsf_attribute5                 =>  p_lsf_attribute5
      ,p_lsf_attribute6                 =>  p_lsf_attribute6
      ,p_lsf_attribute7                 =>  p_lsf_attribute7
      ,p_lsf_attribute8                 =>  p_lsf_attribute8
      ,p_lsf_attribute9                 =>  p_lsf_attribute9
      ,p_lsf_attribute10                =>  p_lsf_attribute10
      ,p_lsf_attribute11                =>  p_lsf_attribute11
      ,p_lsf_attribute12                =>  p_lsf_attribute12
      ,p_lsf_attribute13                =>  p_lsf_attribute13
      ,p_lsf_attribute14                =>  p_lsf_attribute14
      ,p_lsf_attribute15                =>  p_lsf_attribute15
      ,p_lsf_attribute16                =>  p_lsf_attribute16
      ,p_lsf_attribute17                =>  p_lsf_attribute17
      ,p_lsf_attribute18                =>  p_lsf_attribute18
      ,p_lsf_attribute19                =>  p_lsf_attribute19
      ,p_lsf_attribute20                =>  p_lsf_attribute20
      ,p_lsf_attribute21                =>  p_lsf_attribute21
      ,p_lsf_attribute22                =>  p_lsf_attribute22
      ,p_lsf_attribute23                =>  p_lsf_attribute23
      ,p_lsf_attribute24                =>  p_lsf_attribute24
      ,p_lsf_attribute25                =>  p_lsf_attribute25
      ,p_lsf_attribute26                =>  p_lsf_attribute26
      ,p_lsf_attribute27                =>  p_lsf_attribute27
      ,p_lsf_attribute28                =>  p_lsf_attribute28
      ,p_lsf_attribute29                =>  p_lsf_attribute29
      ,p_lsf_attribute30                =>  p_lsf_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_use_overid_svc_dt_flag         =>  p_use_overid_svc_dt_flag
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_LOS_FACTORS'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_LOS_FACTORS
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
    ROLLBACK TO update_LOS_FACTORS;
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
    ROLLBACK TO update_LOS_FACTORS;
    raise;
    --
end update_LOS_FACTORS;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_LOS_FACTORS >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_LOS_FACTORS
  (p_validate                       in  boolean  default false
  ,p_los_fctr_id                    in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_LOS_FACTORS';
  l_object_version_number ben_los_fctr.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_LOS_FACTORS;
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
    -- Start of API User Hook for the before hook of delete_LOS_FACTORS
    --
    ben_LOS_FACTORS_bk3.delete_LOS_FACTORS_b
      (
       p_los_fctr_id                    =>  p_los_fctr_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_LOS_FACTORS'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_LOS_FACTORS
    --
  end;
  --
  ben_lsf_del.del
    (
     p_los_fctr_id                   => p_los_fctr_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_LOS_FACTORS
    --
    ben_LOS_FACTORS_bk3.delete_LOS_FACTORS_a
      (
       p_los_fctr_id                    =>  p_los_fctr_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_LOS_FACTORS'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_LOS_FACTORS
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
    ROLLBACK TO delete_LOS_FACTORS;
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
    ROLLBACK TO delete_LOS_FACTORS;
    raise;
    --
end delete_LOS_FACTORS;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_los_fctr_id                   in     number
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
  ben_lsf_shd.lck
    (
      p_los_fctr_id                 => p_los_fctr_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_LOS_FACTORS_api;

/
