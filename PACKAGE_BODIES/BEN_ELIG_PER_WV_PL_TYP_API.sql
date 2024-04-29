--------------------------------------------------------
--  DDL for Package Body BEN_ELIG_PER_WV_PL_TYP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ELIG_PER_WV_PL_TYP_API" as
/* $Header: beetwapi.pkb 120.0 2005/05/28 03:03:39 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_elig_per_wv_pl_typ_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_elig_per_wv_pl_typ >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_elig_per_wv_pl_typ
  (p_validate                       in  boolean   default false
  ,p_elig_per_wv_pl_typ_id          out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_pl_typ_id                      in  number    default null
  ,p_elig_per_id                    in  number    default null
  ,p_wv_cftn_typ_cd                 in  varchar2  default null
  ,p_wv_prtn_rsn_cd                 in  varchar2  default null
  ,p_wvd_flag                       in  varchar2  default null
  ,p_business_group_id              in  number    default null
  ,p_etw_attribute_category         in  varchar2  default null
  ,p_etw_attribute1                 in  varchar2  default null
  ,p_etw_attribute2                 in  varchar2  default null
  ,p_etw_attribute3                 in  varchar2  default null
  ,p_etw_attribute4                 in  varchar2  default null
  ,p_etw_attribute5                 in  varchar2  default null
  ,p_etw_attribute6                 in  varchar2  default null
  ,p_etw_attribute7                 in  varchar2  default null
  ,p_etw_attribute8                 in  varchar2  default null
  ,p_etw_attribute9                 in  varchar2  default null
  ,p_etw_attribute10                in  varchar2  default null
  ,p_etw_attribute11                in  varchar2  default null
  ,p_etw_attribute12                in  varchar2  default null
  ,p_etw_attribute13                in  varchar2  default null
  ,p_etw_attribute14                in  varchar2  default null
  ,p_etw_attribute15                in  varchar2  default null
  ,p_etw_attribute16                in  varchar2  default null
  ,p_etw_attribute17                in  varchar2  default null
  ,p_etw_attribute18                in  varchar2  default null
  ,p_etw_attribute19                in  varchar2  default null
  ,p_etw_attribute20                in  varchar2  default null
  ,p_etw_attribute21                in  varchar2  default null
  ,p_etw_attribute22                in  varchar2  default null
  ,p_etw_attribute23                in  varchar2  default null
  ,p_etw_attribute24                in  varchar2  default null
  ,p_etw_attribute25                in  varchar2  default null
  ,p_etw_attribute26                in  varchar2  default null
  ,p_etw_attribute27                in  varchar2  default null
  ,p_etw_attribute28                in  varchar2  default null
  ,p_etw_attribute29                in  varchar2  default null
  ,p_etw_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_elig_per_wv_pl_typ_id ben_elig_per_wv_pl_typ_f.elig_per_wv_pl_typ_id%TYPE;
  l_effective_start_date ben_elig_per_wv_pl_typ_f.effective_start_date%TYPE;
  l_effective_end_date ben_elig_per_wv_pl_typ_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_elig_per_wv_pl_typ';
  l_object_version_number ben_elig_per_wv_pl_typ_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_elig_per_wv_pl_typ;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_elig_per_wv_pl_typ
    --
    ben_elig_per_wv_pl_typ_bk1.create_elig_per_wv_pl_typ_b
      (
       p_pl_typ_id                      =>  p_pl_typ_id
      ,p_elig_per_id                    =>  p_elig_per_id
      ,p_wv_cftn_typ_cd                 =>  p_wv_cftn_typ_cd
      ,p_wv_prtn_rsn_cd                 =>  p_wv_prtn_rsn_cd
      ,p_wvd_flag                       =>  p_wvd_flag
      ,p_business_group_id              =>  p_business_group_id
      ,p_etw_attribute_category         =>  p_etw_attribute_category
      ,p_etw_attribute1                 =>  p_etw_attribute1
      ,p_etw_attribute2                 =>  p_etw_attribute2
      ,p_etw_attribute3                 =>  p_etw_attribute3
      ,p_etw_attribute4                 =>  p_etw_attribute4
      ,p_etw_attribute5                 =>  p_etw_attribute5
      ,p_etw_attribute6                 =>  p_etw_attribute6
      ,p_etw_attribute7                 =>  p_etw_attribute7
      ,p_etw_attribute8                 =>  p_etw_attribute8
      ,p_etw_attribute9                 =>  p_etw_attribute9
      ,p_etw_attribute10                =>  p_etw_attribute10
      ,p_etw_attribute11                =>  p_etw_attribute11
      ,p_etw_attribute12                =>  p_etw_attribute12
      ,p_etw_attribute13                =>  p_etw_attribute13
      ,p_etw_attribute14                =>  p_etw_attribute14
      ,p_etw_attribute15                =>  p_etw_attribute15
      ,p_etw_attribute16                =>  p_etw_attribute16
      ,p_etw_attribute17                =>  p_etw_attribute17
      ,p_etw_attribute18                =>  p_etw_attribute18
      ,p_etw_attribute19                =>  p_etw_attribute19
      ,p_etw_attribute20                =>  p_etw_attribute20
      ,p_etw_attribute21                =>  p_etw_attribute21
      ,p_etw_attribute22                =>  p_etw_attribute22
      ,p_etw_attribute23                =>  p_etw_attribute23
      ,p_etw_attribute24                =>  p_etw_attribute24
      ,p_etw_attribute25                =>  p_etw_attribute25
      ,p_etw_attribute26                =>  p_etw_attribute26
      ,p_etw_attribute27                =>  p_etw_attribute27
      ,p_etw_attribute28                =>  p_etw_attribute28
      ,p_etw_attribute29                =>  p_etw_attribute29
      ,p_etw_attribute30                =>  p_etw_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_elig_per_wv_pl_typ'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_elig_per_wv_pl_typ
    --
  end;
  --
  ben_etw_ins.ins
    (
     p_elig_per_wv_pl_typ_id         => l_elig_per_wv_pl_typ_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_pl_typ_id                     => p_pl_typ_id
    ,p_elig_per_id                   => p_elig_per_id
    ,p_wv_cftn_typ_cd                => p_wv_cftn_typ_cd
    ,p_wv_prtn_rsn_cd                => p_wv_prtn_rsn_cd
    ,p_wvd_flag                      => p_wvd_flag
    ,p_business_group_id             => p_business_group_id
    ,p_etw_attribute_category        => p_etw_attribute_category
    ,p_etw_attribute1                => p_etw_attribute1
    ,p_etw_attribute2                => p_etw_attribute2
    ,p_etw_attribute3                => p_etw_attribute3
    ,p_etw_attribute4                => p_etw_attribute4
    ,p_etw_attribute5                => p_etw_attribute5
    ,p_etw_attribute6                => p_etw_attribute6
    ,p_etw_attribute7                => p_etw_attribute7
    ,p_etw_attribute8                => p_etw_attribute8
    ,p_etw_attribute9                => p_etw_attribute9
    ,p_etw_attribute10               => p_etw_attribute10
    ,p_etw_attribute11               => p_etw_attribute11
    ,p_etw_attribute12               => p_etw_attribute12
    ,p_etw_attribute13               => p_etw_attribute13
    ,p_etw_attribute14               => p_etw_attribute14
    ,p_etw_attribute15               => p_etw_attribute15
    ,p_etw_attribute16               => p_etw_attribute16
    ,p_etw_attribute17               => p_etw_attribute17
    ,p_etw_attribute18               => p_etw_attribute18
    ,p_etw_attribute19               => p_etw_attribute19
    ,p_etw_attribute20               => p_etw_attribute20
    ,p_etw_attribute21               => p_etw_attribute21
    ,p_etw_attribute22               => p_etw_attribute22
    ,p_etw_attribute23               => p_etw_attribute23
    ,p_etw_attribute24               => p_etw_attribute24
    ,p_etw_attribute25               => p_etw_attribute25
    ,p_etw_attribute26               => p_etw_attribute26
    ,p_etw_attribute27               => p_etw_attribute27
    ,p_etw_attribute28               => p_etw_attribute28
    ,p_etw_attribute29               => p_etw_attribute29
    ,p_etw_attribute30               => p_etw_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_elig_per_wv_pl_typ
    --
    ben_elig_per_wv_pl_typ_bk1.create_elig_per_wv_pl_typ_a
      (
       p_elig_per_wv_pl_typ_id          =>  l_elig_per_wv_pl_typ_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_pl_typ_id                      =>  p_pl_typ_id
      ,p_elig_per_id                    =>  p_elig_per_id
      ,p_wv_cftn_typ_cd                 =>  p_wv_cftn_typ_cd
      ,p_wv_prtn_rsn_cd                 =>  p_wv_prtn_rsn_cd
      ,p_wvd_flag                       =>  p_wvd_flag
      ,p_business_group_id              =>  p_business_group_id
      ,p_etw_attribute_category         =>  p_etw_attribute_category
      ,p_etw_attribute1                 =>  p_etw_attribute1
      ,p_etw_attribute2                 =>  p_etw_attribute2
      ,p_etw_attribute3                 =>  p_etw_attribute3
      ,p_etw_attribute4                 =>  p_etw_attribute4
      ,p_etw_attribute5                 =>  p_etw_attribute5
      ,p_etw_attribute6                 =>  p_etw_attribute6
      ,p_etw_attribute7                 =>  p_etw_attribute7
      ,p_etw_attribute8                 =>  p_etw_attribute8
      ,p_etw_attribute9                 =>  p_etw_attribute9
      ,p_etw_attribute10                =>  p_etw_attribute10
      ,p_etw_attribute11                =>  p_etw_attribute11
      ,p_etw_attribute12                =>  p_etw_attribute12
      ,p_etw_attribute13                =>  p_etw_attribute13
      ,p_etw_attribute14                =>  p_etw_attribute14
      ,p_etw_attribute15                =>  p_etw_attribute15
      ,p_etw_attribute16                =>  p_etw_attribute16
      ,p_etw_attribute17                =>  p_etw_attribute17
      ,p_etw_attribute18                =>  p_etw_attribute18
      ,p_etw_attribute19                =>  p_etw_attribute19
      ,p_etw_attribute20                =>  p_etw_attribute20
      ,p_etw_attribute21                =>  p_etw_attribute21
      ,p_etw_attribute22                =>  p_etw_attribute22
      ,p_etw_attribute23                =>  p_etw_attribute23
      ,p_etw_attribute24                =>  p_etw_attribute24
      ,p_etw_attribute25                =>  p_etw_attribute25
      ,p_etw_attribute26                =>  p_etw_attribute26
      ,p_etw_attribute27                =>  p_etw_attribute27
      ,p_etw_attribute28                =>  p_etw_attribute28
      ,p_etw_attribute29                =>  p_etw_attribute29
      ,p_etw_attribute30                =>  p_etw_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_elig_per_wv_pl_typ'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_elig_per_wv_pl_typ
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
  p_elig_per_wv_pl_typ_id := l_elig_per_wv_pl_typ_id;
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
    ROLLBACK TO create_elig_per_wv_pl_typ;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_elig_per_wv_pl_typ_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_elig_per_wv_pl_typ;
    -- NOCOPY Changes
    p_elig_per_wv_pl_typ_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number := null ;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end create_elig_per_wv_pl_typ;
-- ----------------------------------------------------------------------------
-- |------------------------< update_elig_per_wv_pl_typ >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_elig_per_wv_pl_typ
  (p_validate                       in  boolean   default false
  ,p_elig_per_wv_pl_typ_id          in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_pl_typ_id                      in  number    default hr_api.g_number
  ,p_elig_per_id                    in  number    default hr_api.g_number
  ,p_wv_cftn_typ_cd                 in  varchar2  default hr_api.g_varchar2
  ,p_wv_prtn_rsn_cd                 in  varchar2  default hr_api.g_varchar2
  ,p_wvd_flag                       in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_etw_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_etw_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_etw_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_etw_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_etw_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_etw_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_etw_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_etw_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_etw_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_etw_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_etw_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_etw_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_etw_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_etw_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_etw_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_etw_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_etw_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_etw_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_etw_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_etw_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_etw_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_etw_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_etw_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_etw_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_etw_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_etw_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_etw_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_etw_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_etw_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_etw_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_etw_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_elig_per_wv_pl_typ';
  l_object_version_number ben_elig_per_wv_pl_typ_f.object_version_number%TYPE;
  l_effective_start_date ben_elig_per_wv_pl_typ_f.effective_start_date%TYPE;
  l_effective_end_date ben_elig_per_wv_pl_typ_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_elig_per_wv_pl_typ;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_elig_per_wv_pl_typ
    --
    ben_elig_per_wv_pl_typ_bk2.update_elig_per_wv_pl_typ_b
      (
       p_elig_per_wv_pl_typ_id          =>  p_elig_per_wv_pl_typ_id
      ,p_pl_typ_id                      =>  p_pl_typ_id
      ,p_elig_per_id                    =>  p_elig_per_id
      ,p_wv_cftn_typ_cd                 =>  p_wv_cftn_typ_cd
      ,p_wv_prtn_rsn_cd                 =>  p_wv_prtn_rsn_cd
      ,p_wvd_flag                       =>  p_wvd_flag
      ,p_business_group_id              =>  p_business_group_id
      ,p_etw_attribute_category         =>  p_etw_attribute_category
      ,p_etw_attribute1                 =>  p_etw_attribute1
      ,p_etw_attribute2                 =>  p_etw_attribute2
      ,p_etw_attribute3                 =>  p_etw_attribute3
      ,p_etw_attribute4                 =>  p_etw_attribute4
      ,p_etw_attribute5                 =>  p_etw_attribute5
      ,p_etw_attribute6                 =>  p_etw_attribute6
      ,p_etw_attribute7                 =>  p_etw_attribute7
      ,p_etw_attribute8                 =>  p_etw_attribute8
      ,p_etw_attribute9                 =>  p_etw_attribute9
      ,p_etw_attribute10                =>  p_etw_attribute10
      ,p_etw_attribute11                =>  p_etw_attribute11
      ,p_etw_attribute12                =>  p_etw_attribute12
      ,p_etw_attribute13                =>  p_etw_attribute13
      ,p_etw_attribute14                =>  p_etw_attribute14
      ,p_etw_attribute15                =>  p_etw_attribute15
      ,p_etw_attribute16                =>  p_etw_attribute16
      ,p_etw_attribute17                =>  p_etw_attribute17
      ,p_etw_attribute18                =>  p_etw_attribute18
      ,p_etw_attribute19                =>  p_etw_attribute19
      ,p_etw_attribute20                =>  p_etw_attribute20
      ,p_etw_attribute21                =>  p_etw_attribute21
      ,p_etw_attribute22                =>  p_etw_attribute22
      ,p_etw_attribute23                =>  p_etw_attribute23
      ,p_etw_attribute24                =>  p_etw_attribute24
      ,p_etw_attribute25                =>  p_etw_attribute25
      ,p_etw_attribute26                =>  p_etw_attribute26
      ,p_etw_attribute27                =>  p_etw_attribute27
      ,p_etw_attribute28                =>  p_etw_attribute28
      ,p_etw_attribute29                =>  p_etw_attribute29
      ,p_etw_attribute30                =>  p_etw_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_elig_per_wv_pl_typ'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_elig_per_wv_pl_typ
    --
  end;
  --
  ben_etw_upd.upd
    (
     p_elig_per_wv_pl_typ_id         => p_elig_per_wv_pl_typ_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_pl_typ_id                     => p_pl_typ_id
    ,p_elig_per_id                   => p_elig_per_id
    ,p_wv_cftn_typ_cd                => p_wv_cftn_typ_cd
    ,p_wv_prtn_rsn_cd                => p_wv_prtn_rsn_cd
    ,p_wvd_flag                      => p_wvd_flag
    ,p_business_group_id             => p_business_group_id
    ,p_etw_attribute_category        => p_etw_attribute_category
    ,p_etw_attribute1                => p_etw_attribute1
    ,p_etw_attribute2                => p_etw_attribute2
    ,p_etw_attribute3                => p_etw_attribute3
    ,p_etw_attribute4                => p_etw_attribute4
    ,p_etw_attribute5                => p_etw_attribute5
    ,p_etw_attribute6                => p_etw_attribute6
    ,p_etw_attribute7                => p_etw_attribute7
    ,p_etw_attribute8                => p_etw_attribute8
    ,p_etw_attribute9                => p_etw_attribute9
    ,p_etw_attribute10               => p_etw_attribute10
    ,p_etw_attribute11               => p_etw_attribute11
    ,p_etw_attribute12               => p_etw_attribute12
    ,p_etw_attribute13               => p_etw_attribute13
    ,p_etw_attribute14               => p_etw_attribute14
    ,p_etw_attribute15               => p_etw_attribute15
    ,p_etw_attribute16               => p_etw_attribute16
    ,p_etw_attribute17               => p_etw_attribute17
    ,p_etw_attribute18               => p_etw_attribute18
    ,p_etw_attribute19               => p_etw_attribute19
    ,p_etw_attribute20               => p_etw_attribute20
    ,p_etw_attribute21               => p_etw_attribute21
    ,p_etw_attribute22               => p_etw_attribute22
    ,p_etw_attribute23               => p_etw_attribute23
    ,p_etw_attribute24               => p_etw_attribute24
    ,p_etw_attribute25               => p_etw_attribute25
    ,p_etw_attribute26               => p_etw_attribute26
    ,p_etw_attribute27               => p_etw_attribute27
    ,p_etw_attribute28               => p_etw_attribute28
    ,p_etw_attribute29               => p_etw_attribute29
    ,p_etw_attribute30               => p_etw_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_elig_per_wv_pl_typ
    --
    ben_elig_per_wv_pl_typ_bk2.update_elig_per_wv_pl_typ_a
      (
       p_elig_per_wv_pl_typ_id          =>  p_elig_per_wv_pl_typ_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_pl_typ_id                      =>  p_pl_typ_id
      ,p_elig_per_id                    =>  p_elig_per_id
      ,p_wv_cftn_typ_cd                 =>  p_wv_cftn_typ_cd
      ,p_wv_prtn_rsn_cd                 =>  p_wv_prtn_rsn_cd
      ,p_wvd_flag                       =>  p_wvd_flag
      ,p_business_group_id              =>  p_business_group_id
      ,p_etw_attribute_category         =>  p_etw_attribute_category
      ,p_etw_attribute1                 =>  p_etw_attribute1
      ,p_etw_attribute2                 =>  p_etw_attribute2
      ,p_etw_attribute3                 =>  p_etw_attribute3
      ,p_etw_attribute4                 =>  p_etw_attribute4
      ,p_etw_attribute5                 =>  p_etw_attribute5
      ,p_etw_attribute6                 =>  p_etw_attribute6
      ,p_etw_attribute7                 =>  p_etw_attribute7
      ,p_etw_attribute8                 =>  p_etw_attribute8
      ,p_etw_attribute9                 =>  p_etw_attribute9
      ,p_etw_attribute10                =>  p_etw_attribute10
      ,p_etw_attribute11                =>  p_etw_attribute11
      ,p_etw_attribute12                =>  p_etw_attribute12
      ,p_etw_attribute13                =>  p_etw_attribute13
      ,p_etw_attribute14                =>  p_etw_attribute14
      ,p_etw_attribute15                =>  p_etw_attribute15
      ,p_etw_attribute16                =>  p_etw_attribute16
      ,p_etw_attribute17                =>  p_etw_attribute17
      ,p_etw_attribute18                =>  p_etw_attribute18
      ,p_etw_attribute19                =>  p_etw_attribute19
      ,p_etw_attribute20                =>  p_etw_attribute20
      ,p_etw_attribute21                =>  p_etw_attribute21
      ,p_etw_attribute22                =>  p_etw_attribute22
      ,p_etw_attribute23                =>  p_etw_attribute23
      ,p_etw_attribute24                =>  p_etw_attribute24
      ,p_etw_attribute25                =>  p_etw_attribute25
      ,p_etw_attribute26                =>  p_etw_attribute26
      ,p_etw_attribute27                =>  p_etw_attribute27
      ,p_etw_attribute28                =>  p_etw_attribute28
      ,p_etw_attribute29                =>  p_etw_attribute29
      ,p_etw_attribute30                =>  p_etw_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_elig_per_wv_pl_typ'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_elig_per_wv_pl_typ
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
    ROLLBACK TO update_elig_per_wv_pl_typ;
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
    ROLLBACK TO update_elig_per_wv_pl_typ;
    -- NOCOPY Changes
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number := l_object_version_number ;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end update_elig_per_wv_pl_typ;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_elig_per_wv_pl_typ >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_elig_per_wv_pl_typ
  (p_validate                       in  boolean  default false
  ,p_elig_per_wv_pl_typ_id          in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_elig_per_wv_pl_typ';
  l_object_version_number ben_elig_per_wv_pl_typ_f.object_version_number%TYPE;
  l_effective_start_date ben_elig_per_wv_pl_typ_f.effective_start_date%TYPE;
  l_effective_end_date ben_elig_per_wv_pl_typ_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_elig_per_wv_pl_typ;
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
    -- Start of API User Hook for the before hook of delete_elig_per_wv_pl_typ
    --
    ben_elig_per_wv_pl_typ_bk3.delete_elig_per_wv_pl_typ_b
      (
       p_elig_per_wv_pl_typ_id          =>  p_elig_per_wv_pl_typ_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_elig_per_wv_pl_typ'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_elig_per_wv_pl_typ
    --
  end;
  --
  ben_etw_del.del
    (
     p_elig_per_wv_pl_typ_id         => p_elig_per_wv_pl_typ_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_elig_per_wv_pl_typ
    --
    ben_elig_per_wv_pl_typ_bk3.delete_elig_per_wv_pl_typ_a
      (
       p_elig_per_wv_pl_typ_id          =>  p_elig_per_wv_pl_typ_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_elig_per_wv_pl_typ'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_elig_per_wv_pl_typ
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
    ROLLBACK TO delete_elig_per_wv_pl_typ;
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
    ROLLBACK TO delete_elig_per_wv_pl_typ;
    -- NOCOPY Changes
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number := l_object_version_number ;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end delete_elig_per_wv_pl_typ;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_elig_per_wv_pl_typ_id                   in     number
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
  ben_etw_shd.lck
    (
      p_elig_per_wv_pl_typ_id                 => p_elig_per_wv_pl_typ_id
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
end ben_elig_per_wv_pl_typ_api;

/
