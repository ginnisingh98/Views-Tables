--------------------------------------------------------
--  DDL for Package Body BEN_WITHIN_YEAR_PERD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_WITHIN_YEAR_PERD_API" as
/* $Header: bewypapi.pkb 115.3 2003/01/01 00:03:14 mmudigon ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_WITHIN_YEAR_PERD_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_WITHIN_YEAR_PERD >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_WITHIN_YEAR_PERD
  (p_validate                       in  boolean   default false
  ,p_wthn_yr_perd_id                out nocopy number
  ,p_strt_day                       in  number    default null
  ,p_end_day                        in  number    default null
  ,p_strt_mo                        in  number    default null
  ,p_end_mo                         in  number    default null
  ,p_tm_uom                         in  varchar2  default null
  ,p_yr_perd_id                     in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_wyp_attribute_category         in  varchar2  default null
  ,p_wyp_attribute1                 in  varchar2  default null
  ,p_wyp_attribute2                 in  varchar2  default null
  ,p_wyp_attribute3                 in  varchar2  default null
  ,p_wyp_attribute4                 in  varchar2  default null
  ,p_wyp_attribute5                 in  varchar2  default null
  ,p_wyp_attribute6                 in  varchar2  default null
  ,p_wyp_attribute7                 in  varchar2  default null
  ,p_wyp_attribute8                 in  varchar2  default null
  ,p_wyp_attribute9                 in  varchar2  default null
  ,p_wyp_attribute10                in  varchar2  default null
  ,p_wyp_attribute11                in  varchar2  default null
  ,p_wyp_attribute12                in  varchar2  default null
  ,p_wyp_attribute13                in  varchar2  default null
  ,p_wyp_attribute14                in  varchar2  default null
  ,p_wyp_attribute15                in  varchar2  default null
  ,p_wyp_attribute16                in  varchar2  default null
  ,p_wyp_attribute17                in  varchar2  default null
  ,p_wyp_attribute18                in  varchar2  default null
  ,p_wyp_attribute19                in  varchar2  default null
  ,p_wyp_attribute20                in  varchar2  default null
  ,p_wyp_attribute21                in  varchar2  default null
  ,p_wyp_attribute22                in  varchar2  default null
  ,p_wyp_attribute23                in  varchar2  default null
  ,p_wyp_attribute24                in  varchar2  default null
  ,p_wyp_attribute25                in  varchar2  default null
  ,p_wyp_attribute26                in  varchar2  default null
  ,p_wyp_attribute27                in  varchar2  default null
  ,p_wyp_attribute28                in  varchar2  default null
  ,p_wyp_attribute29                in  varchar2  default null
  ,p_wyp_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_wthn_yr_perd_id ben_wthn_yr_perd.wthn_yr_perd_id%TYPE;
  l_proc varchar2(72) := g_package||'create_WITHIN_YEAR_PERD';
  l_object_version_number ben_wthn_yr_perd.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_WITHIN_YEAR_PERD;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_WITHIN_YEAR_PERD
    --
    ben_WITHIN_YEAR_PERD_bk1.create_WITHIN_YEAR_PERD_b
      (
       p_strt_day                       =>  p_strt_day
      ,p_end_day                        =>  p_end_day
      ,p_strt_mo                        =>  p_strt_mo
      ,p_end_mo                         =>  p_end_mo
      ,p_tm_uom                         =>  p_tm_uom
      ,p_yr_perd_id                     =>  p_yr_perd_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_wyp_attribute_category         =>  p_wyp_attribute_category
      ,p_wyp_attribute1                 =>  p_wyp_attribute1
      ,p_wyp_attribute2                 =>  p_wyp_attribute2
      ,p_wyp_attribute3                 =>  p_wyp_attribute3
      ,p_wyp_attribute4                 =>  p_wyp_attribute4
      ,p_wyp_attribute5                 =>  p_wyp_attribute5
      ,p_wyp_attribute6                 =>  p_wyp_attribute6
      ,p_wyp_attribute7                 =>  p_wyp_attribute7
      ,p_wyp_attribute8                 =>  p_wyp_attribute8
      ,p_wyp_attribute9                 =>  p_wyp_attribute9
      ,p_wyp_attribute10                =>  p_wyp_attribute10
      ,p_wyp_attribute11                =>  p_wyp_attribute11
      ,p_wyp_attribute12                =>  p_wyp_attribute12
      ,p_wyp_attribute13                =>  p_wyp_attribute13
      ,p_wyp_attribute14                =>  p_wyp_attribute14
      ,p_wyp_attribute15                =>  p_wyp_attribute15
      ,p_wyp_attribute16                =>  p_wyp_attribute16
      ,p_wyp_attribute17                =>  p_wyp_attribute17
      ,p_wyp_attribute18                =>  p_wyp_attribute18
      ,p_wyp_attribute19                =>  p_wyp_attribute19
      ,p_wyp_attribute20                =>  p_wyp_attribute20
      ,p_wyp_attribute21                =>  p_wyp_attribute21
      ,p_wyp_attribute22                =>  p_wyp_attribute22
      ,p_wyp_attribute23                =>  p_wyp_attribute23
      ,p_wyp_attribute24                =>  p_wyp_attribute24
      ,p_wyp_attribute25                =>  p_wyp_attribute25
      ,p_wyp_attribute26                =>  p_wyp_attribute26
      ,p_wyp_attribute27                =>  p_wyp_attribute27
      ,p_wyp_attribute28                =>  p_wyp_attribute28
      ,p_wyp_attribute29                =>  p_wyp_attribute29
      ,p_wyp_attribute30                =>  p_wyp_attribute30
      ,p_effective_date                 =>  trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_WITHIN_YEAR_PERD'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_WITHIN_YEAR_PERD
    --
  end;
  --
  ben_wyp_ins.ins
    (
     p_wthn_yr_perd_id               => l_wthn_yr_perd_id
    ,p_strt_day                      => p_strt_day
    ,p_end_day                       => p_end_day
    ,p_strt_mo                       => p_strt_mo
    ,p_end_mo                        => p_end_mo
    ,p_tm_uom                        => p_tm_uom
    ,p_yr_perd_id                    => p_yr_perd_id
    ,p_business_group_id             => p_business_group_id
    ,p_wyp_attribute_category        => p_wyp_attribute_category
    ,p_wyp_attribute1                => p_wyp_attribute1
    ,p_wyp_attribute2                => p_wyp_attribute2
    ,p_wyp_attribute3                => p_wyp_attribute3
    ,p_wyp_attribute4                => p_wyp_attribute4
    ,p_wyp_attribute5                => p_wyp_attribute5
    ,p_wyp_attribute6                => p_wyp_attribute6
    ,p_wyp_attribute7                => p_wyp_attribute7
    ,p_wyp_attribute8                => p_wyp_attribute8
    ,p_wyp_attribute9                => p_wyp_attribute9
    ,p_wyp_attribute10               => p_wyp_attribute10
    ,p_wyp_attribute11               => p_wyp_attribute11
    ,p_wyp_attribute12               => p_wyp_attribute12
    ,p_wyp_attribute13               => p_wyp_attribute13
    ,p_wyp_attribute14               => p_wyp_attribute14
    ,p_wyp_attribute15               => p_wyp_attribute15
    ,p_wyp_attribute16               => p_wyp_attribute16
    ,p_wyp_attribute17               => p_wyp_attribute17
    ,p_wyp_attribute18               => p_wyp_attribute18
    ,p_wyp_attribute19               => p_wyp_attribute19
    ,p_wyp_attribute20               => p_wyp_attribute20
    ,p_wyp_attribute21               => p_wyp_attribute21
    ,p_wyp_attribute22               => p_wyp_attribute22
    ,p_wyp_attribute23               => p_wyp_attribute23
    ,p_wyp_attribute24               => p_wyp_attribute24
    ,p_wyp_attribute25               => p_wyp_attribute25
    ,p_wyp_attribute26               => p_wyp_attribute26
    ,p_wyp_attribute27               => p_wyp_attribute27
    ,p_wyp_attribute28               => p_wyp_attribute28
    ,p_wyp_attribute29               => p_wyp_attribute29
    ,p_wyp_attribute30               => p_wyp_attribute30
    ,p_effective_date                => trunc(p_effective_date)
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_WITHIN_YEAR_PERD
    --
    ben_WITHIN_YEAR_PERD_bk1.create_WITHIN_YEAR_PERD_a
      (
       p_wthn_yr_perd_id                =>  l_wthn_yr_perd_id
      ,p_strt_day                       =>  p_strt_day
      ,p_end_day                        =>  p_end_day
      ,p_strt_mo                        =>  p_strt_mo
      ,p_end_mo                         =>  p_end_mo
      ,p_tm_uom                         =>  p_tm_uom
      ,p_yr_perd_id                     =>  p_yr_perd_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_wyp_attribute_category         =>  p_wyp_attribute_category
      ,p_wyp_attribute1                 =>  p_wyp_attribute1
      ,p_wyp_attribute2                 =>  p_wyp_attribute2
      ,p_wyp_attribute3                 =>  p_wyp_attribute3
      ,p_wyp_attribute4                 =>  p_wyp_attribute4
      ,p_wyp_attribute5                 =>  p_wyp_attribute5
      ,p_wyp_attribute6                 =>  p_wyp_attribute6
      ,p_wyp_attribute7                 =>  p_wyp_attribute7
      ,p_wyp_attribute8                 =>  p_wyp_attribute8
      ,p_wyp_attribute9                 =>  p_wyp_attribute9
      ,p_wyp_attribute10                =>  p_wyp_attribute10
      ,p_wyp_attribute11                =>  p_wyp_attribute11
      ,p_wyp_attribute12                =>  p_wyp_attribute12
      ,p_wyp_attribute13                =>  p_wyp_attribute13
      ,p_wyp_attribute14                =>  p_wyp_attribute14
      ,p_wyp_attribute15                =>  p_wyp_attribute15
      ,p_wyp_attribute16                =>  p_wyp_attribute16
      ,p_wyp_attribute17                =>  p_wyp_attribute17
      ,p_wyp_attribute18                =>  p_wyp_attribute18
      ,p_wyp_attribute19                =>  p_wyp_attribute19
      ,p_wyp_attribute20                =>  p_wyp_attribute20
      ,p_wyp_attribute21                =>  p_wyp_attribute21
      ,p_wyp_attribute22                =>  p_wyp_attribute22
      ,p_wyp_attribute23                =>  p_wyp_attribute23
      ,p_wyp_attribute24                =>  p_wyp_attribute24
      ,p_wyp_attribute25                =>  p_wyp_attribute25
      ,p_wyp_attribute26                =>  p_wyp_attribute26
      ,p_wyp_attribute27                =>  p_wyp_attribute27
      ,p_wyp_attribute28                =>  p_wyp_attribute28
      ,p_wyp_attribute29                =>  p_wyp_attribute29
      ,p_wyp_attribute30                =>  p_wyp_attribute30
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_WITHIN_YEAR_PERD'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_WITHIN_YEAR_PERD
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
  p_wthn_yr_perd_id := l_wthn_yr_perd_id;
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
    ROLLBACK TO create_WITHIN_YEAR_PERD;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_wthn_yr_perd_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_WITHIN_YEAR_PERD;
    raise;
    --
end create_WITHIN_YEAR_PERD;
-- ----------------------------------------------------------------------------
-- |------------------------< update_WITHIN_YEAR_PERD >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_WITHIN_YEAR_PERD
  (p_validate                       in  boolean   default false
  ,p_wthn_yr_perd_id                in  number
  ,p_strt_day                       in  number    default hr_api.g_number
  ,p_end_day                        in  number    default hr_api.g_number
  ,p_strt_mo                        in  number    default hr_api.g_number
  ,p_end_mo                         in  number    default hr_api.g_number
  ,p_tm_uom                         in  varchar2  default hr_api.g_varchar2
  ,p_yr_perd_id                     in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_wyp_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_wyp_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_effective_date                 in  date
  ,p_object_version_number          in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_WITHIN_YEAR_PERD';
  l_object_version_number ben_wthn_yr_perd.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_WITHIN_YEAR_PERD;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_WITHIN_YEAR_PERD
    --
    ben_WITHIN_YEAR_PERD_bk2.update_WITHIN_YEAR_PERD_b
      (
       p_wthn_yr_perd_id                =>  p_wthn_yr_perd_id
      ,p_strt_day                       =>  p_strt_day
      ,p_end_day                        =>  p_end_day
      ,p_strt_mo                        =>  p_strt_mo
      ,p_end_mo                         =>  p_end_mo
      ,p_tm_uom                         =>  p_tm_uom
      ,p_yr_perd_id                     =>  p_yr_perd_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_wyp_attribute_category         =>  p_wyp_attribute_category
      ,p_wyp_attribute1                 =>  p_wyp_attribute1
      ,p_wyp_attribute2                 =>  p_wyp_attribute2
      ,p_wyp_attribute3                 =>  p_wyp_attribute3
      ,p_wyp_attribute4                 =>  p_wyp_attribute4
      ,p_wyp_attribute5                 =>  p_wyp_attribute5
      ,p_wyp_attribute6                 =>  p_wyp_attribute6
      ,p_wyp_attribute7                 =>  p_wyp_attribute7
      ,p_wyp_attribute8                 =>  p_wyp_attribute8
      ,p_wyp_attribute9                 =>  p_wyp_attribute9
      ,p_wyp_attribute10                =>  p_wyp_attribute10
      ,p_wyp_attribute11                =>  p_wyp_attribute11
      ,p_wyp_attribute12                =>  p_wyp_attribute12
      ,p_wyp_attribute13                =>  p_wyp_attribute13
      ,p_wyp_attribute14                =>  p_wyp_attribute14
      ,p_wyp_attribute15                =>  p_wyp_attribute15
      ,p_wyp_attribute16                =>  p_wyp_attribute16
      ,p_wyp_attribute17                =>  p_wyp_attribute17
      ,p_wyp_attribute18                =>  p_wyp_attribute18
      ,p_wyp_attribute19                =>  p_wyp_attribute19
      ,p_wyp_attribute20                =>  p_wyp_attribute20
      ,p_wyp_attribute21                =>  p_wyp_attribute21
      ,p_wyp_attribute22                =>  p_wyp_attribute22
      ,p_wyp_attribute23                =>  p_wyp_attribute23
      ,p_wyp_attribute24                =>  p_wyp_attribute24
      ,p_wyp_attribute25                =>  p_wyp_attribute25
      ,p_wyp_attribute26                =>  p_wyp_attribute26
      ,p_wyp_attribute27                =>  p_wyp_attribute27
      ,p_wyp_attribute28                =>  p_wyp_attribute28
      ,p_wyp_attribute29                =>  p_wyp_attribute29
      ,p_wyp_attribute30                =>  p_wyp_attribute30
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_WITHIN_YEAR_PERD'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_WITHIN_YEAR_PERD
    --
  end;
  --
  ben_wyp_upd.upd
    (
     p_wthn_yr_perd_id               => p_wthn_yr_perd_id
    ,p_strt_day                      => p_strt_day
    ,p_end_day                       => p_end_day
    ,p_strt_mo                       => p_strt_mo
    ,p_end_mo                        => p_end_mo
    ,p_tm_uom                        => p_tm_uom
    ,p_yr_perd_id                    => p_yr_perd_id
    ,p_business_group_id             => p_business_group_id
    ,p_wyp_attribute_category        => p_wyp_attribute_category
    ,p_wyp_attribute1                => p_wyp_attribute1
    ,p_wyp_attribute2                => p_wyp_attribute2
    ,p_wyp_attribute3                => p_wyp_attribute3
    ,p_wyp_attribute4                => p_wyp_attribute4
    ,p_wyp_attribute5                => p_wyp_attribute5
    ,p_wyp_attribute6                => p_wyp_attribute6
    ,p_wyp_attribute7                => p_wyp_attribute7
    ,p_wyp_attribute8                => p_wyp_attribute8
    ,p_wyp_attribute9                => p_wyp_attribute9
    ,p_wyp_attribute10               => p_wyp_attribute10
    ,p_wyp_attribute11               => p_wyp_attribute11
    ,p_wyp_attribute12               => p_wyp_attribute12
    ,p_wyp_attribute13               => p_wyp_attribute13
    ,p_wyp_attribute14               => p_wyp_attribute14
    ,p_wyp_attribute15               => p_wyp_attribute15
    ,p_wyp_attribute16               => p_wyp_attribute16
    ,p_wyp_attribute17               => p_wyp_attribute17
    ,p_wyp_attribute18               => p_wyp_attribute18
    ,p_wyp_attribute19               => p_wyp_attribute19
    ,p_wyp_attribute20               => p_wyp_attribute20
    ,p_wyp_attribute21               => p_wyp_attribute21
    ,p_wyp_attribute22               => p_wyp_attribute22
    ,p_wyp_attribute23               => p_wyp_attribute23
    ,p_wyp_attribute24               => p_wyp_attribute24
    ,p_wyp_attribute25               => p_wyp_attribute25
    ,p_wyp_attribute26               => p_wyp_attribute26
    ,p_wyp_attribute27               => p_wyp_attribute27
    ,p_wyp_attribute28               => p_wyp_attribute28
    ,p_wyp_attribute29               => p_wyp_attribute29
    ,p_wyp_attribute30               => p_wyp_attribute30
    ,p_effective_date                => trunc(p_effective_date)
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_WITHIN_YEAR_PERD
    --
    ben_WITHIN_YEAR_PERD_bk2.update_WITHIN_YEAR_PERD_a
      (
       p_wthn_yr_perd_id                =>  p_wthn_yr_perd_id
      ,p_strt_day                       =>  p_strt_day
      ,p_end_day                        =>  p_end_day
      ,p_strt_mo                        =>  p_strt_mo
      ,p_end_mo                         =>  p_end_mo
      ,p_tm_uom                         =>  p_tm_uom
      ,p_yr_perd_id                     =>  p_yr_perd_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_wyp_attribute_category         =>  p_wyp_attribute_category
      ,p_wyp_attribute1                 =>  p_wyp_attribute1
      ,p_wyp_attribute2                 =>  p_wyp_attribute2
      ,p_wyp_attribute3                 =>  p_wyp_attribute3
      ,p_wyp_attribute4                 =>  p_wyp_attribute4
      ,p_wyp_attribute5                 =>  p_wyp_attribute5
      ,p_wyp_attribute6                 =>  p_wyp_attribute6
      ,p_wyp_attribute7                 =>  p_wyp_attribute7
      ,p_wyp_attribute8                 =>  p_wyp_attribute8
      ,p_wyp_attribute9                 =>  p_wyp_attribute9
      ,p_wyp_attribute10                =>  p_wyp_attribute10
      ,p_wyp_attribute11                =>  p_wyp_attribute11
      ,p_wyp_attribute12                =>  p_wyp_attribute12
      ,p_wyp_attribute13                =>  p_wyp_attribute13
      ,p_wyp_attribute14                =>  p_wyp_attribute14
      ,p_wyp_attribute15                =>  p_wyp_attribute15
      ,p_wyp_attribute16                =>  p_wyp_attribute16
      ,p_wyp_attribute17                =>  p_wyp_attribute17
      ,p_wyp_attribute18                =>  p_wyp_attribute18
      ,p_wyp_attribute19                =>  p_wyp_attribute19
      ,p_wyp_attribute20                =>  p_wyp_attribute20
      ,p_wyp_attribute21                =>  p_wyp_attribute21
      ,p_wyp_attribute22                =>  p_wyp_attribute22
      ,p_wyp_attribute23                =>  p_wyp_attribute23
      ,p_wyp_attribute24                =>  p_wyp_attribute24
      ,p_wyp_attribute25                =>  p_wyp_attribute25
      ,p_wyp_attribute26                =>  p_wyp_attribute26
      ,p_wyp_attribute27                =>  p_wyp_attribute27
      ,p_wyp_attribute28                =>  p_wyp_attribute28
      ,p_wyp_attribute29                =>  p_wyp_attribute29
      ,p_wyp_attribute30                =>  p_wyp_attribute30
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_WITHIN_YEAR_PERD'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_WITHIN_YEAR_PERD
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
    ROLLBACK TO update_WITHIN_YEAR_PERD;
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
    ROLLBACK TO update_WITHIN_YEAR_PERD;
    /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    raise;
    --
end update_WITHIN_YEAR_PERD;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_WITHIN_YEAR_PERD >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_WITHIN_YEAR_PERD
  (p_validate                       in  boolean  default false
  ,p_wthn_yr_perd_id                in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_WITHIN_YEAR_PERD';
  l_object_version_number ben_wthn_yr_perd.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_WITHIN_YEAR_PERD;
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
    -- Start of API User Hook for the before hook of delete_WITHIN_YEAR_PERD
    --
    ben_WITHIN_YEAR_PERD_bk3.delete_WITHIN_YEAR_PERD_b
      (
       p_wthn_yr_perd_id                =>  p_wthn_yr_perd_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_WITHIN_YEAR_PERD'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_WITHIN_YEAR_PERD
    --
  end;
  --
  ben_wyp_del.del
    (
     p_wthn_yr_perd_id               => p_wthn_yr_perd_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_WITHIN_YEAR_PERD
    --
    ben_WITHIN_YEAR_PERD_bk3.delete_WITHIN_YEAR_PERD_a
      (
       p_wthn_yr_perd_id                =>  p_wthn_yr_perd_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_WITHIN_YEAR_PERD'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_WITHIN_YEAR_PERD
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
    ROLLBACK TO delete_WITHIN_YEAR_PERD;
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
    ROLLBACK TO delete_WITHIN_YEAR_PERD;
    /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    raise;
    --
end delete_WITHIN_YEAR_PERD;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_wthn_yr_perd_id                   in     number
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
  ben_wyp_shd.lck
    (
      p_wthn_yr_perd_id                 => p_wthn_yr_perd_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_WITHIN_YEAR_PERD_api;

/
