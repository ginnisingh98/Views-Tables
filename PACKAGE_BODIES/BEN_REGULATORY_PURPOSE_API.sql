--------------------------------------------------------
--  DDL for Package Body BEN_REGULATORY_PURPOSE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_REGULATORY_PURPOSE_API" as
/* $Header: beprpapi.pkb 115.4 2002/12/16 07:24:20 rpgupta ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_regulatory_purpose_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_regulatory_purpose >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_regulatory_purpose
  (p_validate                       in  boolean   default false
  ,p_pl_regy_prps_id                out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_pl_regy_prps_cd                in  varchar2  default null
  ,p_pl_regy_bod_id                 in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_prp_attribute_category         in  varchar2  default null
  ,p_prp_attribute1                 in  varchar2  default null
  ,p_prp_attribute2                 in  varchar2  default null
  ,p_prp_attribute3                 in  varchar2  default null
  ,p_prp_attribute4                 in  varchar2  default null
  ,p_prp_attribute5                 in  varchar2  default null
  ,p_prp_attribute6                 in  varchar2  default null
  ,p_prp_attribute7                 in  varchar2  default null
  ,p_prp_attribute8                 in  varchar2  default null
  ,p_prp_attribute9                 in  varchar2  default null
  ,p_prp_attribute10                in  varchar2  default null
  ,p_prp_attribute11                in  varchar2  default null
  ,p_prp_attribute12                in  varchar2  default null
  ,p_prp_attribute13                in  varchar2  default null
  ,p_prp_attribute14                in  varchar2  default null
  ,p_prp_attribute15                in  varchar2  default null
  ,p_prp_attribute16                in  varchar2  default null
  ,p_prp_attribute17                in  varchar2  default null
  ,p_prp_attribute18                in  varchar2  default null
  ,p_prp_attribute19                in  varchar2  default null
  ,p_prp_attribute20                in  varchar2  default null
  ,p_prp_attribute21                in  varchar2  default null
  ,p_prp_attribute22                in  varchar2  default null
  ,p_prp_attribute23                in  varchar2  default null
  ,p_prp_attribute24                in  varchar2  default null
  ,p_prp_attribute25                in  varchar2  default null
  ,p_prp_attribute26                in  varchar2  default null
  ,p_prp_attribute27                in  varchar2  default null
  ,p_prp_attribute28                in  varchar2  default null
  ,p_prp_attribute29                in  varchar2  default null
  ,p_prp_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_pl_regy_prps_id ben_pl_regy_prp_f.pl_regy_prps_id%TYPE;
  l_effective_start_date ben_pl_regy_prp_f.effective_start_date%TYPE;
  l_effective_end_date ben_pl_regy_prp_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_regulatory_purpose';
  l_object_version_number ben_pl_regy_prp_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_regulatory_purpose;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_regulatory_purpose
    --
    ben_regulatory_purpose_bk1.create_regulatory_purpose_b
      (
       p_pl_regy_prps_cd                =>  p_pl_regy_prps_cd
      ,p_pl_regy_bod_id                 =>  p_pl_regy_bod_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_prp_attribute_category         =>  p_prp_attribute_category
      ,p_prp_attribute1                 =>  p_prp_attribute1
      ,p_prp_attribute2                 =>  p_prp_attribute2
      ,p_prp_attribute3                 =>  p_prp_attribute3
      ,p_prp_attribute4                 =>  p_prp_attribute4
      ,p_prp_attribute5                 =>  p_prp_attribute5
      ,p_prp_attribute6                 =>  p_prp_attribute6
      ,p_prp_attribute7                 =>  p_prp_attribute7
      ,p_prp_attribute8                 =>  p_prp_attribute8
      ,p_prp_attribute9                 =>  p_prp_attribute9
      ,p_prp_attribute10                =>  p_prp_attribute10
      ,p_prp_attribute11                =>  p_prp_attribute11
      ,p_prp_attribute12                =>  p_prp_attribute12
      ,p_prp_attribute13                =>  p_prp_attribute13
      ,p_prp_attribute14                =>  p_prp_attribute14
      ,p_prp_attribute15                =>  p_prp_attribute15
      ,p_prp_attribute16                =>  p_prp_attribute16
      ,p_prp_attribute17                =>  p_prp_attribute17
      ,p_prp_attribute18                =>  p_prp_attribute18
      ,p_prp_attribute19                =>  p_prp_attribute19
      ,p_prp_attribute20                =>  p_prp_attribute20
      ,p_prp_attribute21                =>  p_prp_attribute21
      ,p_prp_attribute22                =>  p_prp_attribute22
      ,p_prp_attribute23                =>  p_prp_attribute23
      ,p_prp_attribute24                =>  p_prp_attribute24
      ,p_prp_attribute25                =>  p_prp_attribute25
      ,p_prp_attribute26                =>  p_prp_attribute26
      ,p_prp_attribute27                =>  p_prp_attribute27
      ,p_prp_attribute28                =>  p_prp_attribute28
      ,p_prp_attribute29                =>  p_prp_attribute29
      ,p_prp_attribute30                =>  p_prp_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_regulatory_purpose'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_regulatory_purpose
    --
  end;
  --
  ben_prp_ins.ins
    (
     p_pl_regy_prps_id               => l_pl_regy_prps_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_pl_regy_prps_cd               => p_pl_regy_prps_cd
    ,p_pl_regy_bod_id                => p_pl_regy_bod_id
    ,p_business_group_id             => p_business_group_id
    ,p_prp_attribute_category        => p_prp_attribute_category
    ,p_prp_attribute1                => p_prp_attribute1
    ,p_prp_attribute2                => p_prp_attribute2
    ,p_prp_attribute3                => p_prp_attribute3
    ,p_prp_attribute4                => p_prp_attribute4
    ,p_prp_attribute5                => p_prp_attribute5
    ,p_prp_attribute6                => p_prp_attribute6
    ,p_prp_attribute7                => p_prp_attribute7
    ,p_prp_attribute8                => p_prp_attribute8
    ,p_prp_attribute9                => p_prp_attribute9
    ,p_prp_attribute10               => p_prp_attribute10
    ,p_prp_attribute11               => p_prp_attribute11
    ,p_prp_attribute12               => p_prp_attribute12
    ,p_prp_attribute13               => p_prp_attribute13
    ,p_prp_attribute14               => p_prp_attribute14
    ,p_prp_attribute15               => p_prp_attribute15
    ,p_prp_attribute16               => p_prp_attribute16
    ,p_prp_attribute17               => p_prp_attribute17
    ,p_prp_attribute18               => p_prp_attribute18
    ,p_prp_attribute19               => p_prp_attribute19
    ,p_prp_attribute20               => p_prp_attribute20
    ,p_prp_attribute21               => p_prp_attribute21
    ,p_prp_attribute22               => p_prp_attribute22
    ,p_prp_attribute23               => p_prp_attribute23
    ,p_prp_attribute24               => p_prp_attribute24
    ,p_prp_attribute25               => p_prp_attribute25
    ,p_prp_attribute26               => p_prp_attribute26
    ,p_prp_attribute27               => p_prp_attribute27
    ,p_prp_attribute28               => p_prp_attribute28
    ,p_prp_attribute29               => p_prp_attribute29
    ,p_prp_attribute30               => p_prp_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_regulatory_purpose
    --
    ben_regulatory_purpose_bk1.create_regulatory_purpose_a
      (
       p_pl_regy_prps_id                =>  l_pl_regy_prps_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_pl_regy_prps_cd                =>  p_pl_regy_prps_cd
      ,p_pl_regy_bod_id                 =>  p_pl_regy_bod_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_prp_attribute_category         =>  p_prp_attribute_category
      ,p_prp_attribute1                 =>  p_prp_attribute1
      ,p_prp_attribute2                 =>  p_prp_attribute2
      ,p_prp_attribute3                 =>  p_prp_attribute3
      ,p_prp_attribute4                 =>  p_prp_attribute4
      ,p_prp_attribute5                 =>  p_prp_attribute5
      ,p_prp_attribute6                 =>  p_prp_attribute6
      ,p_prp_attribute7                 =>  p_prp_attribute7
      ,p_prp_attribute8                 =>  p_prp_attribute8
      ,p_prp_attribute9                 =>  p_prp_attribute9
      ,p_prp_attribute10                =>  p_prp_attribute10
      ,p_prp_attribute11                =>  p_prp_attribute11
      ,p_prp_attribute12                =>  p_prp_attribute12
      ,p_prp_attribute13                =>  p_prp_attribute13
      ,p_prp_attribute14                =>  p_prp_attribute14
      ,p_prp_attribute15                =>  p_prp_attribute15
      ,p_prp_attribute16                =>  p_prp_attribute16
      ,p_prp_attribute17                =>  p_prp_attribute17
      ,p_prp_attribute18                =>  p_prp_attribute18
      ,p_prp_attribute19                =>  p_prp_attribute19
      ,p_prp_attribute20                =>  p_prp_attribute20
      ,p_prp_attribute21                =>  p_prp_attribute21
      ,p_prp_attribute22                =>  p_prp_attribute22
      ,p_prp_attribute23                =>  p_prp_attribute23
      ,p_prp_attribute24                =>  p_prp_attribute24
      ,p_prp_attribute25                =>  p_prp_attribute25
      ,p_prp_attribute26                =>  p_prp_attribute26
      ,p_prp_attribute27                =>  p_prp_attribute27
      ,p_prp_attribute28                =>  p_prp_attribute28
      ,p_prp_attribute29                =>  p_prp_attribute29
      ,p_prp_attribute30                =>  p_prp_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_regulatory_purpose'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_regulatory_purpose
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
  p_pl_regy_prps_id := l_pl_regy_prps_id;
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
    ROLLBACK TO create_regulatory_purpose;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_pl_regy_prps_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_regulatory_purpose;
    p_pl_regy_prps_id := null; --nocopy change
    p_effective_start_date := null; --nocopy change
    p_effective_end_date := null; --nocopy change
    p_object_version_number  := null; --nocopy change
    raise;
    --
end create_regulatory_purpose;
-- ----------------------------------------------------------------------------
-- |------------------------< update_regulatory_purpose >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_regulatory_purpose
  (p_validate                       in  boolean   default false
  ,p_pl_regy_prps_id                in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_pl_regy_prps_cd                in  varchar2  default hr_api.g_varchar2
  ,p_pl_regy_bod_id                 in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_prp_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_prp_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_prp_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_prp_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_prp_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_prp_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_prp_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_prp_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_prp_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_prp_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_prp_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_prp_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_prp_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_prp_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_prp_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_prp_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_prp_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_prp_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_prp_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_prp_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_prp_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_prp_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_prp_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_prp_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_prp_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_prp_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_prp_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_prp_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_prp_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_prp_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_prp_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_regulatory_purpose';
  l_object_version_number ben_pl_regy_prp_f.object_version_number%TYPE;
  l_effective_start_date ben_pl_regy_prp_f.effective_start_date%TYPE;
  l_effective_end_date ben_pl_regy_prp_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_regulatory_purpose;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_regulatory_purpose
    --
    ben_regulatory_purpose_bk2.update_regulatory_purpose_b
      (
       p_pl_regy_prps_id                =>  p_pl_regy_prps_id
      ,p_pl_regy_prps_cd                =>  p_pl_regy_prps_cd
      ,p_pl_regy_bod_id                 =>  p_pl_regy_bod_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_prp_attribute_category         =>  p_prp_attribute_category
      ,p_prp_attribute1                 =>  p_prp_attribute1
      ,p_prp_attribute2                 =>  p_prp_attribute2
      ,p_prp_attribute3                 =>  p_prp_attribute3
      ,p_prp_attribute4                 =>  p_prp_attribute4
      ,p_prp_attribute5                 =>  p_prp_attribute5
      ,p_prp_attribute6                 =>  p_prp_attribute6
      ,p_prp_attribute7                 =>  p_prp_attribute7
      ,p_prp_attribute8                 =>  p_prp_attribute8
      ,p_prp_attribute9                 =>  p_prp_attribute9
      ,p_prp_attribute10                =>  p_prp_attribute10
      ,p_prp_attribute11                =>  p_prp_attribute11
      ,p_prp_attribute12                =>  p_prp_attribute12
      ,p_prp_attribute13                =>  p_prp_attribute13
      ,p_prp_attribute14                =>  p_prp_attribute14
      ,p_prp_attribute15                =>  p_prp_attribute15
      ,p_prp_attribute16                =>  p_prp_attribute16
      ,p_prp_attribute17                =>  p_prp_attribute17
      ,p_prp_attribute18                =>  p_prp_attribute18
      ,p_prp_attribute19                =>  p_prp_attribute19
      ,p_prp_attribute20                =>  p_prp_attribute20
      ,p_prp_attribute21                =>  p_prp_attribute21
      ,p_prp_attribute22                =>  p_prp_attribute22
      ,p_prp_attribute23                =>  p_prp_attribute23
      ,p_prp_attribute24                =>  p_prp_attribute24
      ,p_prp_attribute25                =>  p_prp_attribute25
      ,p_prp_attribute26                =>  p_prp_attribute26
      ,p_prp_attribute27                =>  p_prp_attribute27
      ,p_prp_attribute28                =>  p_prp_attribute28
      ,p_prp_attribute29                =>  p_prp_attribute29
      ,p_prp_attribute30                =>  p_prp_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_regulatory_purpose'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_regulatory_purpose
    --
  end;
  --
  ben_prp_upd.upd
    (
     p_pl_regy_prps_id               => p_pl_regy_prps_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_pl_regy_prps_cd               => p_pl_regy_prps_cd
    ,p_pl_regy_bod_id                => p_pl_regy_bod_id
    ,p_business_group_id             => p_business_group_id
    ,p_prp_attribute_category        => p_prp_attribute_category
    ,p_prp_attribute1                => p_prp_attribute1
    ,p_prp_attribute2                => p_prp_attribute2
    ,p_prp_attribute3                => p_prp_attribute3
    ,p_prp_attribute4                => p_prp_attribute4
    ,p_prp_attribute5                => p_prp_attribute5
    ,p_prp_attribute6                => p_prp_attribute6
    ,p_prp_attribute7                => p_prp_attribute7
    ,p_prp_attribute8                => p_prp_attribute8
    ,p_prp_attribute9                => p_prp_attribute9
    ,p_prp_attribute10               => p_prp_attribute10
    ,p_prp_attribute11               => p_prp_attribute11
    ,p_prp_attribute12               => p_prp_attribute12
    ,p_prp_attribute13               => p_prp_attribute13
    ,p_prp_attribute14               => p_prp_attribute14
    ,p_prp_attribute15               => p_prp_attribute15
    ,p_prp_attribute16               => p_prp_attribute16
    ,p_prp_attribute17               => p_prp_attribute17
    ,p_prp_attribute18               => p_prp_attribute18
    ,p_prp_attribute19               => p_prp_attribute19
    ,p_prp_attribute20               => p_prp_attribute20
    ,p_prp_attribute21               => p_prp_attribute21
    ,p_prp_attribute22               => p_prp_attribute22
    ,p_prp_attribute23               => p_prp_attribute23
    ,p_prp_attribute24               => p_prp_attribute24
    ,p_prp_attribute25               => p_prp_attribute25
    ,p_prp_attribute26               => p_prp_attribute26
    ,p_prp_attribute27               => p_prp_attribute27
    ,p_prp_attribute28               => p_prp_attribute28
    ,p_prp_attribute29               => p_prp_attribute29
    ,p_prp_attribute30               => p_prp_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_regulatory_purpose
    --
    ben_regulatory_purpose_bk2.update_regulatory_purpose_a
      (
       p_pl_regy_prps_id                =>  p_pl_regy_prps_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_pl_regy_prps_cd                =>  p_pl_regy_prps_cd
      ,p_pl_regy_bod_id                 =>  p_pl_regy_bod_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_prp_attribute_category         =>  p_prp_attribute_category
      ,p_prp_attribute1                 =>  p_prp_attribute1
      ,p_prp_attribute2                 =>  p_prp_attribute2
      ,p_prp_attribute3                 =>  p_prp_attribute3
      ,p_prp_attribute4                 =>  p_prp_attribute4
      ,p_prp_attribute5                 =>  p_prp_attribute5
      ,p_prp_attribute6                 =>  p_prp_attribute6
      ,p_prp_attribute7                 =>  p_prp_attribute7
      ,p_prp_attribute8                 =>  p_prp_attribute8
      ,p_prp_attribute9                 =>  p_prp_attribute9
      ,p_prp_attribute10                =>  p_prp_attribute10
      ,p_prp_attribute11                =>  p_prp_attribute11
      ,p_prp_attribute12                =>  p_prp_attribute12
      ,p_prp_attribute13                =>  p_prp_attribute13
      ,p_prp_attribute14                =>  p_prp_attribute14
      ,p_prp_attribute15                =>  p_prp_attribute15
      ,p_prp_attribute16                =>  p_prp_attribute16
      ,p_prp_attribute17                =>  p_prp_attribute17
      ,p_prp_attribute18                =>  p_prp_attribute18
      ,p_prp_attribute19                =>  p_prp_attribute19
      ,p_prp_attribute20                =>  p_prp_attribute20
      ,p_prp_attribute21                =>  p_prp_attribute21
      ,p_prp_attribute22                =>  p_prp_attribute22
      ,p_prp_attribute23                =>  p_prp_attribute23
      ,p_prp_attribute24                =>  p_prp_attribute24
      ,p_prp_attribute25                =>  p_prp_attribute25
      ,p_prp_attribute26                =>  p_prp_attribute26
      ,p_prp_attribute27                =>  p_prp_attribute27
      ,p_prp_attribute28                =>  p_prp_attribute28
      ,p_prp_attribute29                =>  p_prp_attribute29
      ,p_prp_attribute30                =>  p_prp_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_regulatory_purpose'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_regulatory_purpose
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
    ROLLBACK TO update_regulatory_purpose;
    p_effective_start_date := null;
    p_effective_end_date := null;
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
    ROLLBACK TO update_regulatory_purpose;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end update_regulatory_purpose;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_regulatory_purpose >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_regulatory_purpose
  (p_validate                       in  boolean  default false
  ,p_pl_regy_prps_id                in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_regulatory_purpose';
  l_object_version_number ben_pl_regy_prp_f.object_version_number%TYPE;
  l_effective_start_date ben_pl_regy_prp_f.effective_start_date%TYPE;
  l_effective_end_date ben_pl_regy_prp_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_regulatory_purpose;
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
    -- Start of API User Hook for the before hook of delete_regulatory_purpose
    --
    ben_regulatory_purpose_bk3.delete_regulatory_purpose_b
      (
       p_pl_regy_prps_id                =>  p_pl_regy_prps_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_regulatory_purpose'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_regulatory_purpose
    --
  end;
  --
  ben_prp_del.del
    (
     p_pl_regy_prps_id               => p_pl_regy_prps_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_regulatory_purpose
    --
    ben_regulatory_purpose_bk3.delete_regulatory_purpose_a
      (
       p_pl_regy_prps_id                =>  p_pl_regy_prps_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_regulatory_purpose'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_regulatory_purpose
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
    ROLLBACK TO delete_regulatory_purpose;
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
    ROLLBACK TO delete_regulatory_purpose;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end delete_regulatory_purpose;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_pl_regy_prps_id                   in     number
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
  ben_prp_shd.lck
    (
      p_pl_regy_prps_id                 => p_pl_regy_prps_id
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
end ben_regulatory_purpose_api;

/
