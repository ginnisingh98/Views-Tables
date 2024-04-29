--------------------------------------------------------
--  DDL for Package Body BEN_PGM_OR_PL_YR_PERD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PGM_OR_PL_YR_PERD_API" as
/* $Header: beyrpapi.pkb 115.3 2002/12/16 17:56:39 glingapp ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_pgm_or_pl_yr_perd_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_pgm_or_pl_yr_perd >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_pgm_or_pl_yr_perd
  (p_validate                       in  boolean   default false
  ,p_yr_perd_id                     out nocopy number
  ,p_perds_in_yr_num                in  number    default null
  ,p_perd_tm_uom_cd                 in  varchar2  default null
  ,p_perd_typ_cd                    in  varchar2  default null
  ,p_end_date                       in  date      default null
  ,p_start_date                     in  date      default null
  ,p_lmtn_yr_strt_dt                in  date      default null
  ,p_lmtn_yr_end_dt                 in  date      default null
  ,p_business_group_id              in  number    default null
  ,p_yrp_attribute_category         in  varchar2  default null
  ,p_yrp_attribute1                 in  varchar2  default null
  ,p_yrp_attribute2                 in  varchar2  default null
  ,p_yrp_attribute3                 in  varchar2  default null
  ,p_yrp_attribute4                 in  varchar2  default null
  ,p_yrp_attribute5                 in  varchar2  default null
  ,p_yrp_attribute6                 in  varchar2  default null
  ,p_yrp_attribute7                 in  varchar2  default null
  ,p_yrp_attribute8                 in  varchar2  default null
  ,p_yrp_attribute9                 in  varchar2  default null
  ,p_yrp_attribute10                in  varchar2  default null
  ,p_yrp_attribute11                in  varchar2  default null
  ,p_yrp_attribute12                in  varchar2  default null
  ,p_yrp_attribute13                in  varchar2  default null
  ,p_yrp_attribute14                in  varchar2  default null
  ,p_yrp_attribute15                in  varchar2  default null
  ,p_yrp_attribute16                in  varchar2  default null
  ,p_yrp_attribute17                in  varchar2  default null
  ,p_yrp_attribute18                in  varchar2  default null
  ,p_yrp_attribute19                in  varchar2  default null
  ,p_yrp_attribute20                in  varchar2  default null
  ,p_yrp_attribute21                in  varchar2  default null
  ,p_yrp_attribute22                in  varchar2  default null
  ,p_yrp_attribute23                in  varchar2  default null
  ,p_yrp_attribute24                in  varchar2  default null
  ,p_yrp_attribute25                in  varchar2  default null
  ,p_yrp_attribute26                in  varchar2  default null
  ,p_yrp_attribute27                in  varchar2  default null
  ,p_yrp_attribute28                in  varchar2  default null
  ,p_yrp_attribute29                in  varchar2  default null
  ,p_yrp_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_yr_perd_id ben_yr_perd.yr_perd_id%TYPE;
  l_proc varchar2(72) := g_package||'create_pgm_or_pl_yr_perd';
  l_object_version_number ben_yr_perd.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_pgm_or_pl_yr_perd;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_pgm_or_pl_yr_perd
    --
    ben_pgm_or_pl_yr_perd_bk1.create_pgm_or_pl_yr_perd_b
      (
       p_perds_in_yr_num                =>  p_perds_in_yr_num
      ,p_perd_tm_uom_cd                 =>  p_perd_tm_uom_cd
      ,p_perd_typ_cd                    =>  p_perd_typ_cd
      ,p_end_date                       =>  p_end_date
      ,p_start_date                     =>  p_start_date
      ,p_lmtn_yr_strt_dt                =>  p_lmtn_yr_strt_dt
      ,p_lmtn_yr_end_dt                 =>  p_lmtn_yr_end_dt
      ,p_business_group_id              =>  p_business_group_id
      ,p_yrp_attribute_category         =>  p_yrp_attribute_category
      ,p_yrp_attribute1                 =>  p_yrp_attribute1
      ,p_yrp_attribute2                 =>  p_yrp_attribute2
      ,p_yrp_attribute3                 =>  p_yrp_attribute3
      ,p_yrp_attribute4                 =>  p_yrp_attribute4
      ,p_yrp_attribute5                 =>  p_yrp_attribute5
      ,p_yrp_attribute6                 =>  p_yrp_attribute6
      ,p_yrp_attribute7                 =>  p_yrp_attribute7
      ,p_yrp_attribute8                 =>  p_yrp_attribute8
      ,p_yrp_attribute9                 =>  p_yrp_attribute9
      ,p_yrp_attribute10                =>  p_yrp_attribute10
      ,p_yrp_attribute11                =>  p_yrp_attribute11
      ,p_yrp_attribute12                =>  p_yrp_attribute12
      ,p_yrp_attribute13                =>  p_yrp_attribute13
      ,p_yrp_attribute14                =>  p_yrp_attribute14
      ,p_yrp_attribute15                =>  p_yrp_attribute15
      ,p_yrp_attribute16                =>  p_yrp_attribute16
      ,p_yrp_attribute17                =>  p_yrp_attribute17
      ,p_yrp_attribute18                =>  p_yrp_attribute18
      ,p_yrp_attribute19                =>  p_yrp_attribute19
      ,p_yrp_attribute20                =>  p_yrp_attribute20
      ,p_yrp_attribute21                =>  p_yrp_attribute21
      ,p_yrp_attribute22                =>  p_yrp_attribute22
      ,p_yrp_attribute23                =>  p_yrp_attribute23
      ,p_yrp_attribute24                =>  p_yrp_attribute24
      ,p_yrp_attribute25                =>  p_yrp_attribute25
      ,p_yrp_attribute26                =>  p_yrp_attribute26
      ,p_yrp_attribute27                =>  p_yrp_attribute27
      ,p_yrp_attribute28                =>  p_yrp_attribute28
      ,p_yrp_attribute29                =>  p_yrp_attribute29
      ,p_yrp_attribute30                =>  p_yrp_attribute30
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_pgm_or_pl_yr_perd'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_pgm_or_pl_yr_perd
    --
  end;
  --
  ben_yrp_ins.ins
    (
     p_yr_perd_id                    => l_yr_perd_id
    ,p_perds_in_yr_num               => p_perds_in_yr_num
    ,p_perd_tm_uom_cd                => p_perd_tm_uom_cd
    ,p_perd_typ_cd                   => p_perd_typ_cd
    ,p_end_date                      => p_end_date
    ,p_start_date                    => p_start_date
    ,p_lmtn_yr_strt_dt               => p_lmtn_yr_strt_dt
    ,p_lmtn_yr_end_dt                => p_lmtn_yr_end_dt
    ,p_business_group_id             => p_business_group_id
    ,p_yrp_attribute_category        => p_yrp_attribute_category
    ,p_yrp_attribute1                => p_yrp_attribute1
    ,p_yrp_attribute2                => p_yrp_attribute2
    ,p_yrp_attribute3                => p_yrp_attribute3
    ,p_yrp_attribute4                => p_yrp_attribute4
    ,p_yrp_attribute5                => p_yrp_attribute5
    ,p_yrp_attribute6                => p_yrp_attribute6
    ,p_yrp_attribute7                => p_yrp_attribute7
    ,p_yrp_attribute8                => p_yrp_attribute8
    ,p_yrp_attribute9                => p_yrp_attribute9
    ,p_yrp_attribute10               => p_yrp_attribute10
    ,p_yrp_attribute11               => p_yrp_attribute11
    ,p_yrp_attribute12               => p_yrp_attribute12
    ,p_yrp_attribute13               => p_yrp_attribute13
    ,p_yrp_attribute14               => p_yrp_attribute14
    ,p_yrp_attribute15               => p_yrp_attribute15
    ,p_yrp_attribute16               => p_yrp_attribute16
    ,p_yrp_attribute17               => p_yrp_attribute17
    ,p_yrp_attribute18               => p_yrp_attribute18
    ,p_yrp_attribute19               => p_yrp_attribute19
    ,p_yrp_attribute20               => p_yrp_attribute20
    ,p_yrp_attribute21               => p_yrp_attribute21
    ,p_yrp_attribute22               => p_yrp_attribute22
    ,p_yrp_attribute23               => p_yrp_attribute23
    ,p_yrp_attribute24               => p_yrp_attribute24
    ,p_yrp_attribute25               => p_yrp_attribute25
    ,p_yrp_attribute26               => p_yrp_attribute26
    ,p_yrp_attribute27               => p_yrp_attribute27
    ,p_yrp_attribute28               => p_yrp_attribute28
    ,p_yrp_attribute29               => p_yrp_attribute29
    ,p_yrp_attribute30               => p_yrp_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_pgm_or_pl_yr_perd
    --
    ben_pgm_or_pl_yr_perd_bk1.create_pgm_or_pl_yr_perd_a
      (
       p_yr_perd_id                     =>  l_yr_perd_id
      ,p_perds_in_yr_num                =>  p_perds_in_yr_num
      ,p_perd_tm_uom_cd                 =>  p_perd_tm_uom_cd
      ,p_perd_typ_cd                    =>  p_perd_typ_cd
      ,p_end_date                       =>  p_end_date
      ,p_start_date                     =>  p_start_date
      ,p_lmtn_yr_strt_dt                =>  p_lmtn_yr_strt_dt
      ,p_lmtn_yr_end_dt                 =>  p_lmtn_yr_end_dt
      ,p_business_group_id              =>  p_business_group_id
      ,p_yrp_attribute_category         =>  p_yrp_attribute_category
      ,p_yrp_attribute1                 =>  p_yrp_attribute1
      ,p_yrp_attribute2                 =>  p_yrp_attribute2
      ,p_yrp_attribute3                 =>  p_yrp_attribute3
      ,p_yrp_attribute4                 =>  p_yrp_attribute4
      ,p_yrp_attribute5                 =>  p_yrp_attribute5
      ,p_yrp_attribute6                 =>  p_yrp_attribute6
      ,p_yrp_attribute7                 =>  p_yrp_attribute7
      ,p_yrp_attribute8                 =>  p_yrp_attribute8
      ,p_yrp_attribute9                 =>  p_yrp_attribute9
      ,p_yrp_attribute10                =>  p_yrp_attribute10
      ,p_yrp_attribute11                =>  p_yrp_attribute11
      ,p_yrp_attribute12                =>  p_yrp_attribute12
      ,p_yrp_attribute13                =>  p_yrp_attribute13
      ,p_yrp_attribute14                =>  p_yrp_attribute14
      ,p_yrp_attribute15                =>  p_yrp_attribute15
      ,p_yrp_attribute16                =>  p_yrp_attribute16
      ,p_yrp_attribute17                =>  p_yrp_attribute17
      ,p_yrp_attribute18                =>  p_yrp_attribute18
      ,p_yrp_attribute19                =>  p_yrp_attribute19
      ,p_yrp_attribute20                =>  p_yrp_attribute20
      ,p_yrp_attribute21                =>  p_yrp_attribute21
      ,p_yrp_attribute22                =>  p_yrp_attribute22
      ,p_yrp_attribute23                =>  p_yrp_attribute23
      ,p_yrp_attribute24                =>  p_yrp_attribute24
      ,p_yrp_attribute25                =>  p_yrp_attribute25
      ,p_yrp_attribute26                =>  p_yrp_attribute26
      ,p_yrp_attribute27                =>  p_yrp_attribute27
      ,p_yrp_attribute28                =>  p_yrp_attribute28
      ,p_yrp_attribute29                =>  p_yrp_attribute29
      ,p_yrp_attribute30                =>  p_yrp_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_pgm_or_pl_yr_perd'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_pgm_or_pl_yr_perd
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
  p_yr_perd_id := l_yr_perd_id;
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
    ROLLBACK TO create_pgm_or_pl_yr_perd;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_yr_perd_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_pgm_or_pl_yr_perd;
    p_yr_perd_id := null;
    p_object_version_number  := null;
    raise;
    --
end create_pgm_or_pl_yr_perd;
-- ----------------------------------------------------------------------------
-- |------------------------< update_pgm_or_pl_yr_perd >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_pgm_or_pl_yr_perd
  (p_validate                       in  boolean   default false
  ,p_yr_perd_id                     in  number
  ,p_perds_in_yr_num                in  number    default hr_api.g_number
  ,p_perd_tm_uom_cd                 in  varchar2  default hr_api.g_varchar2
  ,p_perd_typ_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_end_date                       in  date      default hr_api.g_date
  ,p_start_date                     in  date      default hr_api.g_date
  ,p_lmtn_yr_strt_dt                in  date      default hr_api.g_date
  ,p_lmtn_yr_end_dt                 in  date      default hr_api.g_date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_yrp_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_yrp_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_pgm_or_pl_yr_perd';
  l_object_version_number ben_yr_perd.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_pgm_or_pl_yr_perd;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_pgm_or_pl_yr_perd
    --
    ben_pgm_or_pl_yr_perd_bk2.update_pgm_or_pl_yr_perd_b
      (
       p_yr_perd_id                     =>  p_yr_perd_id
      ,p_perds_in_yr_num                =>  p_perds_in_yr_num
      ,p_perd_tm_uom_cd                 =>  p_perd_tm_uom_cd
      ,p_perd_typ_cd                    =>  p_perd_typ_cd
      ,p_end_date                       =>  p_end_date
      ,p_start_date                     =>  p_start_date
      ,p_lmtn_yr_strt_dt                =>  p_lmtn_yr_strt_dt
      ,p_lmtn_yr_end_dt                 =>  p_lmtn_yr_end_dt
      ,p_business_group_id              =>  p_business_group_id
      ,p_yrp_attribute_category         =>  p_yrp_attribute_category
      ,p_yrp_attribute1                 =>  p_yrp_attribute1
      ,p_yrp_attribute2                 =>  p_yrp_attribute2
      ,p_yrp_attribute3                 =>  p_yrp_attribute3
      ,p_yrp_attribute4                 =>  p_yrp_attribute4
      ,p_yrp_attribute5                 =>  p_yrp_attribute5
      ,p_yrp_attribute6                 =>  p_yrp_attribute6
      ,p_yrp_attribute7                 =>  p_yrp_attribute7
      ,p_yrp_attribute8                 =>  p_yrp_attribute8
      ,p_yrp_attribute9                 =>  p_yrp_attribute9
      ,p_yrp_attribute10                =>  p_yrp_attribute10
      ,p_yrp_attribute11                =>  p_yrp_attribute11
      ,p_yrp_attribute12                =>  p_yrp_attribute12
      ,p_yrp_attribute13                =>  p_yrp_attribute13
      ,p_yrp_attribute14                =>  p_yrp_attribute14
      ,p_yrp_attribute15                =>  p_yrp_attribute15
      ,p_yrp_attribute16                =>  p_yrp_attribute16
      ,p_yrp_attribute17                =>  p_yrp_attribute17
      ,p_yrp_attribute18                =>  p_yrp_attribute18
      ,p_yrp_attribute19                =>  p_yrp_attribute19
      ,p_yrp_attribute20                =>  p_yrp_attribute20
      ,p_yrp_attribute21                =>  p_yrp_attribute21
      ,p_yrp_attribute22                =>  p_yrp_attribute22
      ,p_yrp_attribute23                =>  p_yrp_attribute23
      ,p_yrp_attribute24                =>  p_yrp_attribute24
      ,p_yrp_attribute25                =>  p_yrp_attribute25
      ,p_yrp_attribute26                =>  p_yrp_attribute26
      ,p_yrp_attribute27                =>  p_yrp_attribute27
      ,p_yrp_attribute28                =>  p_yrp_attribute28
      ,p_yrp_attribute29                =>  p_yrp_attribute29
      ,p_yrp_attribute30                =>  p_yrp_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_pgm_or_pl_yr_perd'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_pgm_or_pl_yr_perd
    --
  end;
  --
  ben_yrp_upd.upd
    (
     p_yr_perd_id                    => p_yr_perd_id
    ,p_perds_in_yr_num               => p_perds_in_yr_num
    ,p_perd_tm_uom_cd                => p_perd_tm_uom_cd
    ,p_perd_typ_cd                   => p_perd_typ_cd
    ,p_end_date                      => p_end_date
    ,p_start_date                    => p_start_date
    ,p_lmtn_yr_strt_dt               => p_lmtn_yr_strt_dt
    ,p_lmtn_yr_end_dt                => p_lmtn_yr_end_dt
    ,p_business_group_id             => p_business_group_id
    ,p_yrp_attribute_category        => p_yrp_attribute_category
    ,p_yrp_attribute1                => p_yrp_attribute1
    ,p_yrp_attribute2                => p_yrp_attribute2
    ,p_yrp_attribute3                => p_yrp_attribute3
    ,p_yrp_attribute4                => p_yrp_attribute4
    ,p_yrp_attribute5                => p_yrp_attribute5
    ,p_yrp_attribute6                => p_yrp_attribute6
    ,p_yrp_attribute7                => p_yrp_attribute7
    ,p_yrp_attribute8                => p_yrp_attribute8
    ,p_yrp_attribute9                => p_yrp_attribute9
    ,p_yrp_attribute10               => p_yrp_attribute10
    ,p_yrp_attribute11               => p_yrp_attribute11
    ,p_yrp_attribute12               => p_yrp_attribute12
    ,p_yrp_attribute13               => p_yrp_attribute13
    ,p_yrp_attribute14               => p_yrp_attribute14
    ,p_yrp_attribute15               => p_yrp_attribute15
    ,p_yrp_attribute16               => p_yrp_attribute16
    ,p_yrp_attribute17               => p_yrp_attribute17
    ,p_yrp_attribute18               => p_yrp_attribute18
    ,p_yrp_attribute19               => p_yrp_attribute19
    ,p_yrp_attribute20               => p_yrp_attribute20
    ,p_yrp_attribute21               => p_yrp_attribute21
    ,p_yrp_attribute22               => p_yrp_attribute22
    ,p_yrp_attribute23               => p_yrp_attribute23
    ,p_yrp_attribute24               => p_yrp_attribute24
    ,p_yrp_attribute25               => p_yrp_attribute25
    ,p_yrp_attribute26               => p_yrp_attribute26
    ,p_yrp_attribute27               => p_yrp_attribute27
    ,p_yrp_attribute28               => p_yrp_attribute28
    ,p_yrp_attribute29               => p_yrp_attribute29
    ,p_yrp_attribute30               => p_yrp_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_pgm_or_pl_yr_perd
    --
    ben_pgm_or_pl_yr_perd_bk2.update_pgm_or_pl_yr_perd_a
      (
       p_yr_perd_id                     =>  p_yr_perd_id
      ,p_perds_in_yr_num                =>  p_perds_in_yr_num
      ,p_perd_tm_uom_cd                 =>  p_perd_tm_uom_cd
      ,p_perd_typ_cd                    =>  p_perd_typ_cd
      ,p_end_date                       =>  p_end_date
      ,p_start_date                     =>  p_start_date
      ,p_lmtn_yr_strt_dt                =>  p_lmtn_yr_strt_dt
      ,p_lmtn_yr_end_dt                 =>  p_lmtn_yr_end_dt
      ,p_business_group_id              =>  p_business_group_id
      ,p_yrp_attribute_category         =>  p_yrp_attribute_category
      ,p_yrp_attribute1                 =>  p_yrp_attribute1
      ,p_yrp_attribute2                 =>  p_yrp_attribute2
      ,p_yrp_attribute3                 =>  p_yrp_attribute3
      ,p_yrp_attribute4                 =>  p_yrp_attribute4
      ,p_yrp_attribute5                 =>  p_yrp_attribute5
      ,p_yrp_attribute6                 =>  p_yrp_attribute6
      ,p_yrp_attribute7                 =>  p_yrp_attribute7
      ,p_yrp_attribute8                 =>  p_yrp_attribute8
      ,p_yrp_attribute9                 =>  p_yrp_attribute9
      ,p_yrp_attribute10                =>  p_yrp_attribute10
      ,p_yrp_attribute11                =>  p_yrp_attribute11
      ,p_yrp_attribute12                =>  p_yrp_attribute12
      ,p_yrp_attribute13                =>  p_yrp_attribute13
      ,p_yrp_attribute14                =>  p_yrp_attribute14
      ,p_yrp_attribute15                =>  p_yrp_attribute15
      ,p_yrp_attribute16                =>  p_yrp_attribute16
      ,p_yrp_attribute17                =>  p_yrp_attribute17
      ,p_yrp_attribute18                =>  p_yrp_attribute18
      ,p_yrp_attribute19                =>  p_yrp_attribute19
      ,p_yrp_attribute20                =>  p_yrp_attribute20
      ,p_yrp_attribute21                =>  p_yrp_attribute21
      ,p_yrp_attribute22                =>  p_yrp_attribute22
      ,p_yrp_attribute23                =>  p_yrp_attribute23
      ,p_yrp_attribute24                =>  p_yrp_attribute24
      ,p_yrp_attribute25                =>  p_yrp_attribute25
      ,p_yrp_attribute26                =>  p_yrp_attribute26
      ,p_yrp_attribute27                =>  p_yrp_attribute27
      ,p_yrp_attribute28                =>  p_yrp_attribute28
      ,p_yrp_attribute29                =>  p_yrp_attribute29
      ,p_yrp_attribute30                =>  p_yrp_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_pgm_or_pl_yr_perd'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_pgm_or_pl_yr_perd
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
    ROLLBACK TO update_pgm_or_pl_yr_perd;
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
    ROLLBACK TO update_pgm_or_pl_yr_perd;
    raise;
    --
end update_pgm_or_pl_yr_perd;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_pgm_or_pl_yr_perd >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pgm_or_pl_yr_perd
  (p_validate                       in  boolean  default false
  ,p_yr_perd_id                     in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_pgm_or_pl_yr_perd';
  l_object_version_number ben_yr_perd.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_pgm_or_pl_yr_perd;
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
    -- Start of API User Hook for the before hook of delete_pgm_or_pl_yr_perd
    --
    ben_pgm_or_pl_yr_perd_bk3.delete_pgm_or_pl_yr_perd_b
      (
       p_yr_perd_id                     =>  p_yr_perd_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_pgm_or_pl_yr_perd'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_pgm_or_pl_yr_perd
    --
  end;
  --
  ben_yrp_del.del
    (
     p_yr_perd_id                    => p_yr_perd_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_pgm_or_pl_yr_perd
    --
    ben_pgm_or_pl_yr_perd_bk3.delete_pgm_or_pl_yr_perd_a
      (
       p_yr_perd_id                     =>  p_yr_perd_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_pgm_or_pl_yr_perd'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_pgm_or_pl_yr_perd
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
    ROLLBACK TO delete_pgm_or_pl_yr_perd;
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
    ROLLBACK TO delete_pgm_or_pl_yr_perd;
    raise;
    --
end delete_pgm_or_pl_yr_perd;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_yr_perd_id                   in     number
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
  ben_yrp_shd.lck
    (
      p_yr_perd_id                 => p_yr_perd_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_pgm_or_pl_yr_perd_api;

/
