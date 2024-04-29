--------------------------------------------------------
--  DDL for Package Body BEN_CM_TYP_TRGR_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CM_TYP_TRGR_API" as
/* $Header: becttapi.pkb 115.3 2002/12/16 17:35:02 glingapp ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_cm_typ_trgr_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------------< create_cm_typ_trgr >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_cm_typ_trgr
  (p_validate                       in  boolean   default false
  ,p_cm_typ_trgr_id                 out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_cm_typ_trgr_rl                 in  number    default null
  ,p_cm_trgr_id                     in  number    default null
  ,p_cm_typ_id                      in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_ctt_attribute_category         in  varchar2  default null
  ,p_ctt_attribute1                 in  varchar2  default null
  ,p_ctt_attribute2                 in  varchar2  default null
  ,p_ctt_attribute3                 in  varchar2  default null
  ,p_ctt_attribute4                 in  varchar2  default null
  ,p_ctt_attribute5                 in  varchar2  default null
  ,p_ctt_attribute6                 in  varchar2  default null
  ,p_ctt_attribute7                 in  varchar2  default null
  ,p_ctt_attribute8                 in  varchar2  default null
  ,p_ctt_attribute9                 in  varchar2  default null
  ,p_ctt_attribute10                in  varchar2  default null
  ,p_ctt_attribute11                in  varchar2  default null
  ,p_ctt_attribute12                in  varchar2  default null
  ,p_ctt_attribute13                in  varchar2  default null
  ,p_ctt_attribute14                in  varchar2  default null
  ,p_ctt_attribute15                in  varchar2  default null
  ,p_ctt_attribute16                in  varchar2  default null
  ,p_ctt_attribute17                in  varchar2  default null
  ,p_ctt_attribute18                in  varchar2  default null
  ,p_ctt_attribute19                in  varchar2  default null
  ,p_ctt_attribute20                in  varchar2  default null
  ,p_ctt_attribute21                in  varchar2  default null
  ,p_ctt_attribute22                in  varchar2  default null
  ,p_ctt_attribute23                in  varchar2  default null
  ,p_ctt_attribute24                in  varchar2  default null
  ,p_ctt_attribute25                in  varchar2  default null
  ,p_ctt_attribute26                in  varchar2  default null
  ,p_ctt_attribute27                in  varchar2  default null
  ,p_ctt_attribute28                in  varchar2  default null
  ,p_ctt_attribute29                in  varchar2  default null
  ,p_ctt_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date) is
  --
  -- Declare cursors and local variables
  --
  l_cm_typ_trgr_id ben_cm_typ_trgr_f.cm_typ_trgr_id%TYPE;
  l_effective_start_date ben_cm_typ_trgr_f.effective_start_date%TYPE;
  l_effective_end_date ben_cm_typ_trgr_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_cm_typ_trgr';
  l_object_version_number ben_cm_typ_trgr_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_cm_typ_trgr;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_cm_typ_trgr
    --
    ben_cm_typ_trgr_bk1.create_cm_typ_trgr_b
      (p_cm_typ_trgr_rl                 =>  p_cm_typ_trgr_rl
      ,p_cm_trgr_id                     =>  p_cm_trgr_id
      ,p_cm_typ_id                      =>  p_cm_typ_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ctt_attribute_category         =>  p_ctt_attribute_category
      ,p_ctt_attribute1                 =>  p_ctt_attribute1
      ,p_ctt_attribute2                 =>  p_ctt_attribute2
      ,p_ctt_attribute3                 =>  p_ctt_attribute3
      ,p_ctt_attribute4                 =>  p_ctt_attribute4
      ,p_ctt_attribute5                 =>  p_ctt_attribute5
      ,p_ctt_attribute6                 =>  p_ctt_attribute6
      ,p_ctt_attribute7                 =>  p_ctt_attribute7
      ,p_ctt_attribute8                 =>  p_ctt_attribute8
      ,p_ctt_attribute9                 =>  p_ctt_attribute9
      ,p_ctt_attribute10                =>  p_ctt_attribute10
      ,p_ctt_attribute11                =>  p_ctt_attribute11
      ,p_ctt_attribute12                =>  p_ctt_attribute12
      ,p_ctt_attribute13                =>  p_ctt_attribute13
      ,p_ctt_attribute14                =>  p_ctt_attribute14
      ,p_ctt_attribute15                =>  p_ctt_attribute15
      ,p_ctt_attribute16                =>  p_ctt_attribute16
      ,p_ctt_attribute17                =>  p_ctt_attribute17
      ,p_ctt_attribute18                =>  p_ctt_attribute18
      ,p_ctt_attribute19                =>  p_ctt_attribute19
      ,p_ctt_attribute20                =>  p_ctt_attribute20
      ,p_ctt_attribute21                =>  p_ctt_attribute21
      ,p_ctt_attribute22                =>  p_ctt_attribute22
      ,p_ctt_attribute23                =>  p_ctt_attribute23
      ,p_ctt_attribute24                =>  p_ctt_attribute24
      ,p_ctt_attribute25                =>  p_ctt_attribute25
      ,p_ctt_attribute26                =>  p_ctt_attribute26
      ,p_ctt_attribute27                =>  p_ctt_attribute27
      ,p_ctt_attribute28                =>  p_ctt_attribute28
      ,p_ctt_attribute29                =>  p_ctt_attribute29
      ,p_ctt_attribute30                =>  p_ctt_attribute30
      ,p_effective_date                 =>  trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_cm_typ_trgr'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of create_cm_typ_trgr
    --
  end;
  --
  ben_ctt_ins.ins
    (p_cm_typ_trgr_id                => l_cm_typ_trgr_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_cm_typ_trgr_rl                => p_cm_typ_trgr_rl
    ,p_cm_trgr_id                    => p_cm_trgr_id
    ,p_cm_typ_id                     => p_cm_typ_id
    ,p_business_group_id             => p_business_group_id
    ,p_ctt_attribute_category        => p_ctt_attribute_category
    ,p_ctt_attribute1                => p_ctt_attribute1
    ,p_ctt_attribute2                => p_ctt_attribute2
    ,p_ctt_attribute3                => p_ctt_attribute3
    ,p_ctt_attribute4                => p_ctt_attribute4
    ,p_ctt_attribute5                => p_ctt_attribute5
    ,p_ctt_attribute6                => p_ctt_attribute6
    ,p_ctt_attribute7                => p_ctt_attribute7
    ,p_ctt_attribute8                => p_ctt_attribute8
    ,p_ctt_attribute9                => p_ctt_attribute9
    ,p_ctt_attribute10               => p_ctt_attribute10
    ,p_ctt_attribute11               => p_ctt_attribute11
    ,p_ctt_attribute12               => p_ctt_attribute12
    ,p_ctt_attribute13               => p_ctt_attribute13
    ,p_ctt_attribute14               => p_ctt_attribute14
    ,p_ctt_attribute15               => p_ctt_attribute15
    ,p_ctt_attribute16               => p_ctt_attribute16
    ,p_ctt_attribute17               => p_ctt_attribute17
    ,p_ctt_attribute18               => p_ctt_attribute18
    ,p_ctt_attribute19               => p_ctt_attribute19
    ,p_ctt_attribute20               => p_ctt_attribute20
    ,p_ctt_attribute21               => p_ctt_attribute21
    ,p_ctt_attribute22               => p_ctt_attribute22
    ,p_ctt_attribute23               => p_ctt_attribute23
    ,p_ctt_attribute24               => p_ctt_attribute24
    ,p_ctt_attribute25               => p_ctt_attribute25
    ,p_ctt_attribute26               => p_ctt_attribute26
    ,p_ctt_attribute27               => p_ctt_attribute27
    ,p_ctt_attribute28               => p_ctt_attribute28
    ,p_ctt_attribute29               => p_ctt_attribute29
    ,p_ctt_attribute30               => p_ctt_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date));
    --
  begin
    --
    -- Start of API User Hook for the after hook of create_cm_typ_trgr
    --
    ben_cm_typ_trgr_bk1.create_cm_typ_trgr_a
      (p_cm_typ_trgr_id                 =>  l_cm_typ_trgr_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_cm_typ_trgr_rl                 =>  p_cm_typ_trgr_rl
      ,p_cm_trgr_id                     =>  p_cm_trgr_id
      ,p_cm_typ_id                      =>  p_cm_typ_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ctt_attribute_category         =>  p_ctt_attribute_category
      ,p_ctt_attribute1                 =>  p_ctt_attribute1
      ,p_ctt_attribute2                 =>  p_ctt_attribute2
      ,p_ctt_attribute3                 =>  p_ctt_attribute3
      ,p_ctt_attribute4                 =>  p_ctt_attribute4
      ,p_ctt_attribute5                 =>  p_ctt_attribute5
      ,p_ctt_attribute6                 =>  p_ctt_attribute6
      ,p_ctt_attribute7                 =>  p_ctt_attribute7
      ,p_ctt_attribute8                 =>  p_ctt_attribute8
      ,p_ctt_attribute9                 =>  p_ctt_attribute9
      ,p_ctt_attribute10                =>  p_ctt_attribute10
      ,p_ctt_attribute11                =>  p_ctt_attribute11
      ,p_ctt_attribute12                =>  p_ctt_attribute12
      ,p_ctt_attribute13                =>  p_ctt_attribute13
      ,p_ctt_attribute14                =>  p_ctt_attribute14
      ,p_ctt_attribute15                =>  p_ctt_attribute15
      ,p_ctt_attribute16                =>  p_ctt_attribute16
      ,p_ctt_attribute17                =>  p_ctt_attribute17
      ,p_ctt_attribute18                =>  p_ctt_attribute18
      ,p_ctt_attribute19                =>  p_ctt_attribute19
      ,p_ctt_attribute20                =>  p_ctt_attribute20
      ,p_ctt_attribute21                =>  p_ctt_attribute21
      ,p_ctt_attribute22                =>  p_ctt_attribute22
      ,p_ctt_attribute23                =>  p_ctt_attribute23
      ,p_ctt_attribute24                =>  p_ctt_attribute24
      ,p_ctt_attribute25                =>  p_ctt_attribute25
      ,p_ctt_attribute26                =>  p_ctt_attribute26
      ,p_ctt_attribute27                =>  p_ctt_attribute27
      ,p_ctt_attribute28                =>  p_ctt_attribute28
      ,p_ctt_attribute29                =>  p_ctt_attribute29
      ,p_ctt_attribute30                =>  p_ctt_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_cm_typ_trgr'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of create_cm_typ_trgr
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
  p_cm_typ_trgr_id := l_cm_typ_trgr_id;
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
    ROLLBACK TO create_cm_typ_trgr;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_cm_typ_trgr_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_cm_typ_trgr;
    p_cm_typ_trgr_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    raise;
    --
end create_cm_typ_trgr;
-- ----------------------------------------------------------------------------
-- |------------------------< update_cm_typ_trgr >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_cm_typ_trgr
  (p_validate                       in  boolean   default false
  ,p_cm_typ_trgr_id                 in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_cm_typ_trgr_rl                 in  number    default hr_api.g_number
  ,p_cm_trgr_id                     in  number    default hr_api.g_number
  ,p_cm_typ_id                      in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_ctt_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_ctt_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_ctt_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_ctt_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_ctt_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_ctt_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_ctt_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_ctt_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_ctt_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_ctt_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_ctt_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_ctt_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_ctt_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_ctt_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_ctt_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_ctt_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_ctt_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_ctt_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_ctt_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_ctt_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_ctt_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_ctt_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_ctt_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_ctt_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_ctt_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_ctt_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_ctt_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_ctt_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_ctt_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_ctt_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_ctt_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_cm_typ_trgr';
  l_object_version_number ben_cm_typ_trgr_f.object_version_number%TYPE;
  l_effective_start_date ben_cm_typ_trgr_f.effective_start_date%TYPE;
  l_effective_end_date ben_cm_typ_trgr_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_cm_typ_trgr;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_cm_typ_trgr
    --
    ben_cm_typ_trgr_bk2.update_cm_typ_trgr_b
      (p_cm_typ_trgr_id                 =>  p_cm_typ_trgr_id
      ,p_cm_typ_trgr_rl                 =>  p_cm_typ_trgr_rl
      ,p_cm_trgr_id                     =>  p_cm_trgr_id
      ,p_cm_typ_id                      =>  p_cm_typ_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ctt_attribute_category         =>  p_ctt_attribute_category
      ,p_ctt_attribute1                 =>  p_ctt_attribute1
      ,p_ctt_attribute2                 =>  p_ctt_attribute2
      ,p_ctt_attribute3                 =>  p_ctt_attribute3
      ,p_ctt_attribute4                 =>  p_ctt_attribute4
      ,p_ctt_attribute5                 =>  p_ctt_attribute5
      ,p_ctt_attribute6                 =>  p_ctt_attribute6
      ,p_ctt_attribute7                 =>  p_ctt_attribute7
      ,p_ctt_attribute8                 =>  p_ctt_attribute8
      ,p_ctt_attribute9                 =>  p_ctt_attribute9
      ,p_ctt_attribute10                =>  p_ctt_attribute10
      ,p_ctt_attribute11                =>  p_ctt_attribute11
      ,p_ctt_attribute12                =>  p_ctt_attribute12
      ,p_ctt_attribute13                =>  p_ctt_attribute13
      ,p_ctt_attribute14                =>  p_ctt_attribute14
      ,p_ctt_attribute15                =>  p_ctt_attribute15
      ,p_ctt_attribute16                =>  p_ctt_attribute16
      ,p_ctt_attribute17                =>  p_ctt_attribute17
      ,p_ctt_attribute18                =>  p_ctt_attribute18
      ,p_ctt_attribute19                =>  p_ctt_attribute19
      ,p_ctt_attribute20                =>  p_ctt_attribute20
      ,p_ctt_attribute21                =>  p_ctt_attribute21
      ,p_ctt_attribute22                =>  p_ctt_attribute22
      ,p_ctt_attribute23                =>  p_ctt_attribute23
      ,p_ctt_attribute24                =>  p_ctt_attribute24
      ,p_ctt_attribute25                =>  p_ctt_attribute25
      ,p_ctt_attribute26                =>  p_ctt_attribute26
      ,p_ctt_attribute27                =>  p_ctt_attribute27
      ,p_ctt_attribute28                =>  p_ctt_attribute28
      ,p_ctt_attribute29                =>  p_ctt_attribute29
      ,p_ctt_attribute30                =>  p_ctt_attribute30
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_datetrack_mode                 =>  p_datetrack_mode);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_cm_typ_trgr'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of update_cm_typ_trgr
    --
  end;
  --
  ben_ctt_upd.upd
    (p_cm_typ_trgr_id                => p_cm_typ_trgr_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_cm_typ_trgr_rl                => p_cm_typ_trgr_rl
    ,p_cm_trgr_id                    => p_cm_trgr_id
    ,p_cm_typ_id                     => p_cm_typ_id
    ,p_business_group_id             => p_business_group_id
    ,p_ctt_attribute_category        => p_ctt_attribute_category
    ,p_ctt_attribute1                => p_ctt_attribute1
    ,p_ctt_attribute2                => p_ctt_attribute2
    ,p_ctt_attribute3                => p_ctt_attribute3
    ,p_ctt_attribute4                => p_ctt_attribute4
    ,p_ctt_attribute5                => p_ctt_attribute5
    ,p_ctt_attribute6                => p_ctt_attribute6
    ,p_ctt_attribute7                => p_ctt_attribute7
    ,p_ctt_attribute8                => p_ctt_attribute8
    ,p_ctt_attribute9                => p_ctt_attribute9
    ,p_ctt_attribute10               => p_ctt_attribute10
    ,p_ctt_attribute11               => p_ctt_attribute11
    ,p_ctt_attribute12               => p_ctt_attribute12
    ,p_ctt_attribute13               => p_ctt_attribute13
    ,p_ctt_attribute14               => p_ctt_attribute14
    ,p_ctt_attribute15               => p_ctt_attribute15
    ,p_ctt_attribute16               => p_ctt_attribute16
    ,p_ctt_attribute17               => p_ctt_attribute17
    ,p_ctt_attribute18               => p_ctt_attribute18
    ,p_ctt_attribute19               => p_ctt_attribute19
    ,p_ctt_attribute20               => p_ctt_attribute20
    ,p_ctt_attribute21               => p_ctt_attribute21
    ,p_ctt_attribute22               => p_ctt_attribute22
    ,p_ctt_attribute23               => p_ctt_attribute23
    ,p_ctt_attribute24               => p_ctt_attribute24
    ,p_ctt_attribute25               => p_ctt_attribute25
    ,p_ctt_attribute26               => p_ctt_attribute26
    ,p_ctt_attribute27               => p_ctt_attribute27
    ,p_ctt_attribute28               => p_ctt_attribute28
    ,p_ctt_attribute29               => p_ctt_attribute29
    ,p_ctt_attribute30               => p_ctt_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode);
    --
  begin
    --
    -- Start of API User Hook for the after hook of update_cm_typ_trgr
    --
    ben_cm_typ_trgr_bk2.update_cm_typ_trgr_a
      (p_cm_typ_trgr_id                 =>  p_cm_typ_trgr_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_cm_typ_trgr_rl                 =>  p_cm_typ_trgr_rl
      ,p_cm_trgr_id                     =>  p_cm_trgr_id
      ,p_cm_typ_id                      =>  p_cm_typ_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ctt_attribute_category         =>  p_ctt_attribute_category
      ,p_ctt_attribute1                 =>  p_ctt_attribute1
      ,p_ctt_attribute2                 =>  p_ctt_attribute2
      ,p_ctt_attribute3                 =>  p_ctt_attribute3
      ,p_ctt_attribute4                 =>  p_ctt_attribute4
      ,p_ctt_attribute5                 =>  p_ctt_attribute5
      ,p_ctt_attribute6                 =>  p_ctt_attribute6
      ,p_ctt_attribute7                 =>  p_ctt_attribute7
      ,p_ctt_attribute8                 =>  p_ctt_attribute8
      ,p_ctt_attribute9                 =>  p_ctt_attribute9
      ,p_ctt_attribute10                =>  p_ctt_attribute10
      ,p_ctt_attribute11                =>  p_ctt_attribute11
      ,p_ctt_attribute12                =>  p_ctt_attribute12
      ,p_ctt_attribute13                =>  p_ctt_attribute13
      ,p_ctt_attribute14                =>  p_ctt_attribute14
      ,p_ctt_attribute15                =>  p_ctt_attribute15
      ,p_ctt_attribute16                =>  p_ctt_attribute16
      ,p_ctt_attribute17                =>  p_ctt_attribute17
      ,p_ctt_attribute18                =>  p_ctt_attribute18
      ,p_ctt_attribute19                =>  p_ctt_attribute19
      ,p_ctt_attribute20                =>  p_ctt_attribute20
      ,p_ctt_attribute21                =>  p_ctt_attribute21
      ,p_ctt_attribute22                =>  p_ctt_attribute22
      ,p_ctt_attribute23                =>  p_ctt_attribute23
      ,p_ctt_attribute24                =>  p_ctt_attribute24
      ,p_ctt_attribute25                =>  p_ctt_attribute25
      ,p_ctt_attribute26                =>  p_ctt_attribute26
      ,p_ctt_attribute27                =>  p_ctt_attribute27
      ,p_ctt_attribute28                =>  p_ctt_attribute28
      ,p_ctt_attribute29                =>  p_ctt_attribute29
      ,p_ctt_attribute30                =>  p_ctt_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_datetrack_mode                 =>  p_datetrack_mode);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_cm_typ_trgr'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of update_cm_typ_trgr
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
    ROLLBACK TO update_cm_typ_trgr;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_start_date := null;
    p_effective_end_date := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_cm_typ_trgr;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end update_cm_typ_trgr;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_cm_typ_trgr >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_cm_typ_trgr
  (p_validate                       in  boolean  default false
  ,p_cm_typ_trgr_id                 in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_cm_typ_trgr';
  l_object_version_number ben_cm_typ_trgr_f.object_version_number%TYPE;
  l_effective_start_date ben_cm_typ_trgr_f.effective_start_date%TYPE;
  l_effective_end_date ben_cm_typ_trgr_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_cm_typ_trgr;
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
    -- Start of API User Hook for the before hook of delete_cm_typ_trgr
    --
    ben_cm_typ_trgr_bk3.delete_cm_typ_trgr_b
      (p_cm_typ_trgr_id                 =>  p_cm_typ_trgr_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_datetrack_mode                 => p_datetrack_mode);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_cm_typ_trgr'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of delete_cm_typ_trgr
    --
  end;
  --
  ben_ctt_del.del
    (p_cm_typ_trgr_id                => p_cm_typ_trgr_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode);
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_cm_typ_trgr
    --
    ben_cm_typ_trgr_bk3.delete_cm_typ_trgr_a
      (p_cm_typ_trgr_id                 =>  p_cm_typ_trgr_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_datetrack_mode                 =>  p_datetrack_mode);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_cm_typ_trgr'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of delete_cm_typ_trgr
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
    ROLLBACK TO delete_cm_typ_trgr;
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
    ROLLBACK TO delete_cm_typ_trgr;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end delete_cm_typ_trgr;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (p_cm_typ_trgr_id                 in     number
  ,p_object_version_number          in     number
  ,p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  ,p_validation_start_date          out nocopy    date
  ,p_validation_end_date            out nocopy    date) is
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
  ben_ctt_shd.lck
    (p_cm_typ_trgr_id             => p_cm_typ_trgr_id
    ,p_validation_start_date      => l_validation_start_date
    ,p_validation_end_date        => l_validation_end_date
    ,p_object_version_number      => p_object_version_number
    ,p_effective_date             => p_effective_date
    ,p_datetrack_mode             => p_datetrack_mode);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_cm_typ_trgr_api;

/
