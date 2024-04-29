--------------------------------------------------------
--  DDL for Package Body BEN_POPL_YR_PERD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_POPL_YR_PERD_API" as
/* $Header: becpyapi.pkb 115.3 2002/12/13 06:52:18 hmani ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_POPL_YR_PERD_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_POPL_YR_PERD >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_POPL_YR_PERD
  (p_validate                       in  boolean   default false
  ,p_popl_yr_perd_id                out nocopy number
  ,p_yr_perd_id                     in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_ordr_num                       in  number    default null
  ,p_acpt_clm_rqsts_thru_dt         in  date      default null
  ,p_py_clms_thru_dt                in  date      default null
  ,p_cpy_attribute_category         in  varchar2  default null
  ,p_cpy_attribute1                 in  varchar2  default null
  ,p_cpy_attribute2                 in  varchar2  default null
  ,p_cpy_attribute3                 in  varchar2  default null
  ,p_cpy_attribute4                 in  varchar2  default null
  ,p_cpy_attribute5                 in  varchar2  default null
  ,p_cpy_attribute6                 in  varchar2  default null
  ,p_cpy_attribute7                 in  varchar2  default null
  ,p_cpy_attribute8                 in  varchar2  default null
  ,p_cpy_attribute9                 in  varchar2  default null
  ,p_cpy_attribute10                in  varchar2  default null
  ,p_cpy_attribute11                in  varchar2  default null
  ,p_cpy_attribute12                in  varchar2  default null
  ,p_cpy_attribute13                in  varchar2  default null
  ,p_cpy_attribute14                in  varchar2  default null
  ,p_cpy_attribute15                in  varchar2  default null
  ,p_cpy_attribute16                in  varchar2  default null
  ,p_cpy_attribute17                in  varchar2  default null
  ,p_cpy_attribute18                in  varchar2  default null
  ,p_cpy_attribute19                in  varchar2  default null
  ,p_cpy_attribute20                in  varchar2  default null
  ,p_cpy_attribute21                in  varchar2  default null
  ,p_cpy_attribute22                in  varchar2  default null
  ,p_cpy_attribute23                in  varchar2  default null
  ,p_cpy_attribute24                in  varchar2  default null
  ,p_cpy_attribute25                in  varchar2  default null
  ,p_cpy_attribute26                in  varchar2  default null
  ,p_cpy_attribute27                in  varchar2  default null
  ,p_cpy_attribute28                in  varchar2  default null
  ,p_cpy_attribute29                in  varchar2  default null
  ,p_cpy_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_popl_yr_perd_id ben_popl_yr_perd.popl_yr_perd_id%TYPE;
  l_proc varchar2(72) := g_package||'create_POPL_YR_PERD';
  l_object_version_number ben_popl_yr_perd.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_POPL_YR_PERD;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_POPL_YR_PERD
    --
    ben_POPL_YR_PERD_bk1.create_POPL_YR_PERD_b
      (
       p_yr_perd_id                     =>  p_yr_perd_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pl_id                          =>  p_pl_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_ordr_num                       =>  p_ordr_num
      ,p_acpt_clm_rqsts_thru_dt         =>  p_acpt_clm_rqsts_thru_dt
      ,p_py_clms_thru_dt                =>  p_py_clms_thru_dt
      ,p_cpy_attribute_category         =>  p_cpy_attribute_category
      ,p_cpy_attribute1                 =>  p_cpy_attribute1
      ,p_cpy_attribute2                 =>  p_cpy_attribute2
      ,p_cpy_attribute3                 =>  p_cpy_attribute3
      ,p_cpy_attribute4                 =>  p_cpy_attribute4
      ,p_cpy_attribute5                 =>  p_cpy_attribute5
      ,p_cpy_attribute6                 =>  p_cpy_attribute6
      ,p_cpy_attribute7                 =>  p_cpy_attribute7
      ,p_cpy_attribute8                 =>  p_cpy_attribute8
      ,p_cpy_attribute9                 =>  p_cpy_attribute9
      ,p_cpy_attribute10                =>  p_cpy_attribute10
      ,p_cpy_attribute11                =>  p_cpy_attribute11
      ,p_cpy_attribute12                =>  p_cpy_attribute12
      ,p_cpy_attribute13                =>  p_cpy_attribute13
      ,p_cpy_attribute14                =>  p_cpy_attribute14
      ,p_cpy_attribute15                =>  p_cpy_attribute15
      ,p_cpy_attribute16                =>  p_cpy_attribute16
      ,p_cpy_attribute17                =>  p_cpy_attribute17
      ,p_cpy_attribute18                =>  p_cpy_attribute18
      ,p_cpy_attribute19                =>  p_cpy_attribute19
      ,p_cpy_attribute20                =>  p_cpy_attribute20
      ,p_cpy_attribute21                =>  p_cpy_attribute21
      ,p_cpy_attribute22                =>  p_cpy_attribute22
      ,p_cpy_attribute23                =>  p_cpy_attribute23
      ,p_cpy_attribute24                =>  p_cpy_attribute24
      ,p_cpy_attribute25                =>  p_cpy_attribute25
      ,p_cpy_attribute26                =>  p_cpy_attribute26
      ,p_cpy_attribute27                =>  p_cpy_attribute27
      ,p_cpy_attribute28                =>  p_cpy_attribute28
      ,p_cpy_attribute29                =>  p_cpy_attribute29
      ,p_cpy_attribute30                =>  p_cpy_attribute30
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_POPL_YR_PERD'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_POPL_YR_PERD
    --
  end;
  --
  ben_cpy_ins.ins
    (
     p_popl_yr_perd_id               => l_popl_yr_perd_id
    ,p_yr_perd_id                    => p_yr_perd_id
    ,p_business_group_id             => p_business_group_id
    ,p_pl_id                         => p_pl_id
    ,p_pgm_id                        => p_pgm_id
    ,p_ordr_num                      => p_ordr_num
    ,p_acpt_clm_rqsts_thru_dt        => p_acpt_clm_rqsts_thru_dt
    ,p_py_clms_thru_dt               => p_py_clms_thru_dt
    ,p_cpy_attribute_category        => p_cpy_attribute_category
    ,p_cpy_attribute1                => p_cpy_attribute1
    ,p_cpy_attribute2                => p_cpy_attribute2
    ,p_cpy_attribute3                => p_cpy_attribute3
    ,p_cpy_attribute4                => p_cpy_attribute4
    ,p_cpy_attribute5                => p_cpy_attribute5
    ,p_cpy_attribute6                => p_cpy_attribute6
    ,p_cpy_attribute7                => p_cpy_attribute7
    ,p_cpy_attribute8                => p_cpy_attribute8
    ,p_cpy_attribute9                => p_cpy_attribute9
    ,p_cpy_attribute10               => p_cpy_attribute10
    ,p_cpy_attribute11               => p_cpy_attribute11
    ,p_cpy_attribute12               => p_cpy_attribute12
    ,p_cpy_attribute13               => p_cpy_attribute13
    ,p_cpy_attribute14               => p_cpy_attribute14
    ,p_cpy_attribute15               => p_cpy_attribute15
    ,p_cpy_attribute16               => p_cpy_attribute16
    ,p_cpy_attribute17               => p_cpy_attribute17
    ,p_cpy_attribute18               => p_cpy_attribute18
    ,p_cpy_attribute19               => p_cpy_attribute19
    ,p_cpy_attribute20               => p_cpy_attribute20
    ,p_cpy_attribute21               => p_cpy_attribute21
    ,p_cpy_attribute22               => p_cpy_attribute22
    ,p_cpy_attribute23               => p_cpy_attribute23
    ,p_cpy_attribute24               => p_cpy_attribute24
    ,p_cpy_attribute25               => p_cpy_attribute25
    ,p_cpy_attribute26               => p_cpy_attribute26
    ,p_cpy_attribute27               => p_cpy_attribute27
    ,p_cpy_attribute28               => p_cpy_attribute28
    ,p_cpy_attribute29               => p_cpy_attribute29
    ,p_cpy_attribute30               => p_cpy_attribute30
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_POPL_YR_PERD
    --
    ben_POPL_YR_PERD_bk1.create_POPL_YR_PERD_a
      (
       p_popl_yr_perd_id                =>  l_popl_yr_perd_id
      ,p_yr_perd_id                     =>  p_yr_perd_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pl_id                          =>  p_pl_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_ordr_num                       =>  p_ordr_num
      ,p_acpt_clm_rqsts_thru_dt         =>  p_acpt_clm_rqsts_thru_dt
      ,p_py_clms_thru_dt                =>  p_py_clms_thru_dt
      ,p_cpy_attribute_category         =>  p_cpy_attribute_category
      ,p_cpy_attribute1                 =>  p_cpy_attribute1
      ,p_cpy_attribute2                 =>  p_cpy_attribute2
      ,p_cpy_attribute3                 =>  p_cpy_attribute3
      ,p_cpy_attribute4                 =>  p_cpy_attribute4
      ,p_cpy_attribute5                 =>  p_cpy_attribute5
      ,p_cpy_attribute6                 =>  p_cpy_attribute6
      ,p_cpy_attribute7                 =>  p_cpy_attribute7
      ,p_cpy_attribute8                 =>  p_cpy_attribute8
      ,p_cpy_attribute9                 =>  p_cpy_attribute9
      ,p_cpy_attribute10                =>  p_cpy_attribute10
      ,p_cpy_attribute11                =>  p_cpy_attribute11
      ,p_cpy_attribute12                =>  p_cpy_attribute12
      ,p_cpy_attribute13                =>  p_cpy_attribute13
      ,p_cpy_attribute14                =>  p_cpy_attribute14
      ,p_cpy_attribute15                =>  p_cpy_attribute15
      ,p_cpy_attribute16                =>  p_cpy_attribute16
      ,p_cpy_attribute17                =>  p_cpy_attribute17
      ,p_cpy_attribute18                =>  p_cpy_attribute18
      ,p_cpy_attribute19                =>  p_cpy_attribute19
      ,p_cpy_attribute20                =>  p_cpy_attribute20
      ,p_cpy_attribute21                =>  p_cpy_attribute21
      ,p_cpy_attribute22                =>  p_cpy_attribute22
      ,p_cpy_attribute23                =>  p_cpy_attribute23
      ,p_cpy_attribute24                =>  p_cpy_attribute24
      ,p_cpy_attribute25                =>  p_cpy_attribute25
      ,p_cpy_attribute26                =>  p_cpy_attribute26
      ,p_cpy_attribute27                =>  p_cpy_attribute27
      ,p_cpy_attribute28                =>  p_cpy_attribute28
      ,p_cpy_attribute29                =>  p_cpy_attribute29
      ,p_cpy_attribute30                =>  p_cpy_attribute30
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_POPL_YR_PERD'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_POPL_YR_PERD
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
  p_popl_yr_perd_id := l_popl_yr_perd_id;
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
    ROLLBACK TO create_POPL_YR_PERD;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_popl_yr_perd_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_POPL_YR_PERD;
    raise;
    --
end create_POPL_YR_PERD;
-- ----------------------------------------------------------------------------
-- |------------------------< update_POPL_YR_PERD >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_POPL_YR_PERD
  (p_validate                       in  boolean   default false
  ,p_popl_yr_perd_id                in  number
  ,p_yr_perd_id                     in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_pgm_id                         in  number    default hr_api.g_number
  ,p_ordr_num                       in  number    default hr_api.g_number
  ,p_acpt_clm_rqsts_thru_dt         in  date      default hr_api.g_date
  ,p_py_clms_thru_dt                in  date      default hr_api.g_date
  ,p_cpy_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_cpy_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_POPL_YR_PERD';
  l_object_version_number ben_popl_yr_perd.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_POPL_YR_PERD;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_POPL_YR_PERD
    --
    ben_POPL_YR_PERD_bk2.update_POPL_YR_PERD_b
      (
       p_popl_yr_perd_id                =>  p_popl_yr_perd_id
      ,p_yr_perd_id                     =>  p_yr_perd_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pl_id                          =>  p_pl_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_ordr_num                       =>  p_ordr_num
      ,p_acpt_clm_rqsts_thru_dt         =>  p_acpt_clm_rqsts_thru_dt
      ,p_py_clms_thru_dt                =>  p_py_clms_thru_dt
      ,p_cpy_attribute_category         =>  p_cpy_attribute_category
      ,p_cpy_attribute1                 =>  p_cpy_attribute1
      ,p_cpy_attribute2                 =>  p_cpy_attribute2
      ,p_cpy_attribute3                 =>  p_cpy_attribute3
      ,p_cpy_attribute4                 =>  p_cpy_attribute4
      ,p_cpy_attribute5                 =>  p_cpy_attribute5
      ,p_cpy_attribute6                 =>  p_cpy_attribute6
      ,p_cpy_attribute7                 =>  p_cpy_attribute7
      ,p_cpy_attribute8                 =>  p_cpy_attribute8
      ,p_cpy_attribute9                 =>  p_cpy_attribute9
      ,p_cpy_attribute10                =>  p_cpy_attribute10
      ,p_cpy_attribute11                =>  p_cpy_attribute11
      ,p_cpy_attribute12                =>  p_cpy_attribute12
      ,p_cpy_attribute13                =>  p_cpy_attribute13
      ,p_cpy_attribute14                =>  p_cpy_attribute14
      ,p_cpy_attribute15                =>  p_cpy_attribute15
      ,p_cpy_attribute16                =>  p_cpy_attribute16
      ,p_cpy_attribute17                =>  p_cpy_attribute17
      ,p_cpy_attribute18                =>  p_cpy_attribute18
      ,p_cpy_attribute19                =>  p_cpy_attribute19
      ,p_cpy_attribute20                =>  p_cpy_attribute20
      ,p_cpy_attribute21                =>  p_cpy_attribute21
      ,p_cpy_attribute22                =>  p_cpy_attribute22
      ,p_cpy_attribute23                =>  p_cpy_attribute23
      ,p_cpy_attribute24                =>  p_cpy_attribute24
      ,p_cpy_attribute25                =>  p_cpy_attribute25
      ,p_cpy_attribute26                =>  p_cpy_attribute26
      ,p_cpy_attribute27                =>  p_cpy_attribute27
      ,p_cpy_attribute28                =>  p_cpy_attribute28
      ,p_cpy_attribute29                =>  p_cpy_attribute29
      ,p_cpy_attribute30                =>  p_cpy_attribute30
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_POPL_YR_PERD'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_POPL_YR_PERD
    --
  end;
  --
  ben_cpy_upd.upd
    (
     p_popl_yr_perd_id               => p_popl_yr_perd_id
    ,p_yr_perd_id                    => p_yr_perd_id
    ,p_business_group_id             => p_business_group_id
    ,p_pl_id                         => p_pl_id
    ,p_pgm_id                        => p_pgm_id
    ,p_ordr_num                      => p_ordr_num
    ,p_acpt_clm_rqsts_thru_dt        => p_acpt_clm_rqsts_thru_dt
    ,p_py_clms_thru_dt               => p_py_clms_thru_dt
    ,p_cpy_attribute_category        => p_cpy_attribute_category
    ,p_cpy_attribute1                => p_cpy_attribute1
    ,p_cpy_attribute2                => p_cpy_attribute2
    ,p_cpy_attribute3                => p_cpy_attribute3
    ,p_cpy_attribute4                => p_cpy_attribute4
    ,p_cpy_attribute5                => p_cpy_attribute5
    ,p_cpy_attribute6                => p_cpy_attribute6
    ,p_cpy_attribute7                => p_cpy_attribute7
    ,p_cpy_attribute8                => p_cpy_attribute8
    ,p_cpy_attribute9                => p_cpy_attribute9
    ,p_cpy_attribute10               => p_cpy_attribute10
    ,p_cpy_attribute11               => p_cpy_attribute11
    ,p_cpy_attribute12               => p_cpy_attribute12
    ,p_cpy_attribute13               => p_cpy_attribute13
    ,p_cpy_attribute14               => p_cpy_attribute14
    ,p_cpy_attribute15               => p_cpy_attribute15
    ,p_cpy_attribute16               => p_cpy_attribute16
    ,p_cpy_attribute17               => p_cpy_attribute17
    ,p_cpy_attribute18               => p_cpy_attribute18
    ,p_cpy_attribute19               => p_cpy_attribute19
    ,p_cpy_attribute20               => p_cpy_attribute20
    ,p_cpy_attribute21               => p_cpy_attribute21
    ,p_cpy_attribute22               => p_cpy_attribute22
    ,p_cpy_attribute23               => p_cpy_attribute23
    ,p_cpy_attribute24               => p_cpy_attribute24
    ,p_cpy_attribute25               => p_cpy_attribute25
    ,p_cpy_attribute26               => p_cpy_attribute26
    ,p_cpy_attribute27               => p_cpy_attribute27
    ,p_cpy_attribute28               => p_cpy_attribute28
    ,p_cpy_attribute29               => p_cpy_attribute29
    ,p_cpy_attribute30               => p_cpy_attribute30
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_POPL_YR_PERD
    --
    ben_POPL_YR_PERD_bk2.update_POPL_YR_PERD_a
      (
       p_popl_yr_perd_id                =>  p_popl_yr_perd_id
      ,p_yr_perd_id                     =>  p_yr_perd_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pl_id                          =>  p_pl_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_ordr_num                       =>  p_ordr_num
      ,p_acpt_clm_rqsts_thru_dt         =>  p_acpt_clm_rqsts_thru_dt
      ,p_py_clms_thru_dt                =>  p_py_clms_thru_dt
      ,p_cpy_attribute_category         =>  p_cpy_attribute_category
      ,p_cpy_attribute1                 =>  p_cpy_attribute1
      ,p_cpy_attribute2                 =>  p_cpy_attribute2
      ,p_cpy_attribute3                 =>  p_cpy_attribute3
      ,p_cpy_attribute4                 =>  p_cpy_attribute4
      ,p_cpy_attribute5                 =>  p_cpy_attribute5
      ,p_cpy_attribute6                 =>  p_cpy_attribute6
      ,p_cpy_attribute7                 =>  p_cpy_attribute7
      ,p_cpy_attribute8                 =>  p_cpy_attribute8
      ,p_cpy_attribute9                 =>  p_cpy_attribute9
      ,p_cpy_attribute10                =>  p_cpy_attribute10
      ,p_cpy_attribute11                =>  p_cpy_attribute11
      ,p_cpy_attribute12                =>  p_cpy_attribute12
      ,p_cpy_attribute13                =>  p_cpy_attribute13
      ,p_cpy_attribute14                =>  p_cpy_attribute14
      ,p_cpy_attribute15                =>  p_cpy_attribute15
      ,p_cpy_attribute16                =>  p_cpy_attribute16
      ,p_cpy_attribute17                =>  p_cpy_attribute17
      ,p_cpy_attribute18                =>  p_cpy_attribute18
      ,p_cpy_attribute19                =>  p_cpy_attribute19
      ,p_cpy_attribute20                =>  p_cpy_attribute20
      ,p_cpy_attribute21                =>  p_cpy_attribute21
      ,p_cpy_attribute22                =>  p_cpy_attribute22
      ,p_cpy_attribute23                =>  p_cpy_attribute23
      ,p_cpy_attribute24                =>  p_cpy_attribute24
      ,p_cpy_attribute25                =>  p_cpy_attribute25
      ,p_cpy_attribute26                =>  p_cpy_attribute26
      ,p_cpy_attribute27                =>  p_cpy_attribute27
      ,p_cpy_attribute28                =>  p_cpy_attribute28
      ,p_cpy_attribute29                =>  p_cpy_attribute29
      ,p_cpy_attribute30                =>  p_cpy_attribute30
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_POPL_YR_PERD'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_POPL_YR_PERD
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
    ROLLBACK TO update_POPL_YR_PERD;
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
    ROLLBACK TO update_POPL_YR_PERD;
    raise;
    --
end update_POPL_YR_PERD;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_POPL_YR_PERD >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_POPL_YR_PERD
  (p_validate                       in  boolean  default false
  ,p_popl_yr_perd_id                in  number
  ,p_object_version_number          in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_POPL_YR_PERD';
  l_object_version_number ben_popl_yr_perd.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_POPL_YR_PERD;
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
    -- Start of API User Hook for the before hook of delete_POPL_YR_PERD
    --
    ben_POPL_YR_PERD_bk3.delete_POPL_YR_PERD_b
      (
       p_popl_yr_perd_id                =>  p_popl_yr_perd_id
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_POPL_YR_PERD'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_POPL_YR_PERD
    --
  end;
  --
  ben_cpy_del.del
    (
     p_popl_yr_perd_id               => p_popl_yr_perd_id
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_POPL_YR_PERD
    --
    ben_POPL_YR_PERD_bk3.delete_POPL_YR_PERD_a
      (
       p_popl_yr_perd_id                =>  p_popl_yr_perd_id
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_POPL_YR_PERD'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_POPL_YR_PERD
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
    ROLLBACK TO delete_POPL_YR_PERD;
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
    ROLLBACK TO delete_POPL_YR_PERD;
    raise;
    --
end delete_POPL_YR_PERD;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_popl_yr_perd_id                   in     number
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
  ben_cpy_shd.lck
    (
      p_popl_yr_perd_id                 => p_popl_yr_perd_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_POPL_YR_PERD_api;

/
