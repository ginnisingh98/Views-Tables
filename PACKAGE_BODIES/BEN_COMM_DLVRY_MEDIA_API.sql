--------------------------------------------------------
--  DDL for Package Body BEN_COMM_DLVRY_MEDIA_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_COMM_DLVRY_MEDIA_API" as
/* $Header: becmdapi.pkb 115.3 2002/12/31 23:57:05 mmudigon ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_Comm_Dlvry_Media_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Comm_Dlvry_Media >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_Comm_Dlvry_Media
  (p_validate                       in  boolean   default false
  ,p_cm_dlvry_med_typ_id            out nocopy number
  ,p_cm_dlvry_med_typ_cd            in  varchar2  default null
  ,p_cm_dlvry_mthd_typ_id           in  number    default null
  ,p_rqd_flag                       in  varchar2  default null
  ,p_dflt_flag                      in  varchar2  default null
  ,p_business_group_id              in  number    default null
  ,p_cmd_attribute_category         in  varchar2  default null
  ,p_cmd_attribute1                 in  varchar2  default null
  ,p_cmd_attribute2                 in  varchar2  default null
  ,p_cmd_attribute3                 in  varchar2  default null
  ,p_cmd_attribute4                 in  varchar2  default null
  ,p_cmd_attribute5                 in  varchar2  default null
  ,p_cmd_attribute6                 in  varchar2  default null
  ,p_cmd_attribute7                 in  varchar2  default null
  ,p_cmd_attribute8                 in  varchar2  default null
  ,p_cmd_attribute9                 in  varchar2  default null
  ,p_cmd_attribute10                in  varchar2  default null
  ,p_cmd_attribute11                in  varchar2  default null
  ,p_cmd_attribute12                in  varchar2  default null
  ,p_cmd_attribute13                in  varchar2  default null
  ,p_cmd_attribute14                in  varchar2  default null
  ,p_cmd_attribute15                in  varchar2  default null
  ,p_cmd_attribute16                in  varchar2  default null
  ,p_cmd_attribute17                in  varchar2  default null
  ,p_cmd_attribute18                in  varchar2  default null
  ,p_cmd_attribute19                in  varchar2  default null
  ,p_cmd_attribute20                in  varchar2  default null
  ,p_cmd_attribute21                in  varchar2  default null
  ,p_cmd_attribute22                in  varchar2  default null
  ,p_cmd_attribute23                in  varchar2  default null
  ,p_cmd_attribute24                in  varchar2  default null
  ,p_cmd_attribute25                in  varchar2  default null
  ,p_cmd_attribute26                in  varchar2  default null
  ,p_cmd_attribute27                in  varchar2  default null
  ,p_cmd_attribute28                in  varchar2  default null
  ,p_cmd_attribute29                in  varchar2  default null
  ,p_cmd_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_cm_dlvry_med_typ_id ben_cm_dlvry_med_typ.cm_dlvry_med_typ_id%TYPE;
  l_proc varchar2(72) := g_package||'create_Comm_Dlvry_Media';
  l_object_version_number ben_cm_dlvry_med_typ.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_Comm_Dlvry_Media;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_Comm_Dlvry_Media
    --
    ben_Comm_Dlvry_Media_bk1.create_Comm_Dlvry_Media_b
      (
       p_cm_dlvry_med_typ_cd            =>  p_cm_dlvry_med_typ_cd
      ,p_cm_dlvry_mthd_typ_id           =>  p_cm_dlvry_mthd_typ_id
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_business_group_id              =>  p_business_group_id
      ,p_cmd_attribute_category         =>  p_cmd_attribute_category
      ,p_cmd_attribute1                 =>  p_cmd_attribute1
      ,p_cmd_attribute2                 =>  p_cmd_attribute2
      ,p_cmd_attribute3                 =>  p_cmd_attribute3
      ,p_cmd_attribute4                 =>  p_cmd_attribute4
      ,p_cmd_attribute5                 =>  p_cmd_attribute5
      ,p_cmd_attribute6                 =>  p_cmd_attribute6
      ,p_cmd_attribute7                 =>  p_cmd_attribute7
      ,p_cmd_attribute8                 =>  p_cmd_attribute8
      ,p_cmd_attribute9                 =>  p_cmd_attribute9
      ,p_cmd_attribute10                =>  p_cmd_attribute10
      ,p_cmd_attribute11                =>  p_cmd_attribute11
      ,p_cmd_attribute12                =>  p_cmd_attribute12
      ,p_cmd_attribute13                =>  p_cmd_attribute13
      ,p_cmd_attribute14                =>  p_cmd_attribute14
      ,p_cmd_attribute15                =>  p_cmd_attribute15
      ,p_cmd_attribute16                =>  p_cmd_attribute16
      ,p_cmd_attribute17                =>  p_cmd_attribute17
      ,p_cmd_attribute18                =>  p_cmd_attribute18
      ,p_cmd_attribute19                =>  p_cmd_attribute19
      ,p_cmd_attribute20                =>  p_cmd_attribute20
      ,p_cmd_attribute21                =>  p_cmd_attribute21
      ,p_cmd_attribute22                =>  p_cmd_attribute22
      ,p_cmd_attribute23                =>  p_cmd_attribute23
      ,p_cmd_attribute24                =>  p_cmd_attribute24
      ,p_cmd_attribute25                =>  p_cmd_attribute25
      ,p_cmd_attribute26                =>  p_cmd_attribute26
      ,p_cmd_attribute27                =>  p_cmd_attribute27
      ,p_cmd_attribute28                =>  p_cmd_attribute28
      ,p_cmd_attribute29                =>  p_cmd_attribute29
      ,p_cmd_attribute30                =>  p_cmd_attribute30
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_Comm_Dlvry_Media'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_Comm_Dlvry_Media
    --
  end;
  --
  ben_cmd_ins.ins
    (
     p_cm_dlvry_med_typ_id           => l_cm_dlvry_med_typ_id
    ,p_cm_dlvry_med_typ_cd           => p_cm_dlvry_med_typ_cd
    ,p_cm_dlvry_mthd_typ_id          => p_cm_dlvry_mthd_typ_id
    ,p_rqd_flag                      => p_rqd_flag
    ,p_dflt_flag                     => p_dflt_flag
    ,p_business_group_id             => p_business_group_id
    ,p_cmd_attribute_category        => p_cmd_attribute_category
    ,p_cmd_attribute1                => p_cmd_attribute1
    ,p_cmd_attribute2                => p_cmd_attribute2
    ,p_cmd_attribute3                => p_cmd_attribute3
    ,p_cmd_attribute4                => p_cmd_attribute4
    ,p_cmd_attribute5                => p_cmd_attribute5
    ,p_cmd_attribute6                => p_cmd_attribute6
    ,p_cmd_attribute7                => p_cmd_attribute7
    ,p_cmd_attribute8                => p_cmd_attribute8
    ,p_cmd_attribute9                => p_cmd_attribute9
    ,p_cmd_attribute10               => p_cmd_attribute10
    ,p_cmd_attribute11               => p_cmd_attribute11
    ,p_cmd_attribute12               => p_cmd_attribute12
    ,p_cmd_attribute13               => p_cmd_attribute13
    ,p_cmd_attribute14               => p_cmd_attribute14
    ,p_cmd_attribute15               => p_cmd_attribute15
    ,p_cmd_attribute16               => p_cmd_attribute16
    ,p_cmd_attribute17               => p_cmd_attribute17
    ,p_cmd_attribute18               => p_cmd_attribute18
    ,p_cmd_attribute19               => p_cmd_attribute19
    ,p_cmd_attribute20               => p_cmd_attribute20
    ,p_cmd_attribute21               => p_cmd_attribute21
    ,p_cmd_attribute22               => p_cmd_attribute22
    ,p_cmd_attribute23               => p_cmd_attribute23
    ,p_cmd_attribute24               => p_cmd_attribute24
    ,p_cmd_attribute25               => p_cmd_attribute25
    ,p_cmd_attribute26               => p_cmd_attribute26
    ,p_cmd_attribute27               => p_cmd_attribute27
    ,p_cmd_attribute28               => p_cmd_attribute28
    ,p_cmd_attribute29               => p_cmd_attribute29
    ,p_cmd_attribute30               => p_cmd_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_Comm_Dlvry_Media
    --
    ben_Comm_Dlvry_Media_bk1.create_Comm_Dlvry_Media_a
      (
       p_cm_dlvry_med_typ_id            =>  l_cm_dlvry_med_typ_id
      ,p_cm_dlvry_med_typ_cd            =>  p_cm_dlvry_med_typ_cd
      ,p_cm_dlvry_mthd_typ_id           =>  p_cm_dlvry_mthd_typ_id
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_business_group_id              =>  p_business_group_id
      ,p_cmd_attribute_category         =>  p_cmd_attribute_category
      ,p_cmd_attribute1                 =>  p_cmd_attribute1
      ,p_cmd_attribute2                 =>  p_cmd_attribute2
      ,p_cmd_attribute3                 =>  p_cmd_attribute3
      ,p_cmd_attribute4                 =>  p_cmd_attribute4
      ,p_cmd_attribute5                 =>  p_cmd_attribute5
      ,p_cmd_attribute6                 =>  p_cmd_attribute6
      ,p_cmd_attribute7                 =>  p_cmd_attribute7
      ,p_cmd_attribute8                 =>  p_cmd_attribute8
      ,p_cmd_attribute9                 =>  p_cmd_attribute9
      ,p_cmd_attribute10                =>  p_cmd_attribute10
      ,p_cmd_attribute11                =>  p_cmd_attribute11
      ,p_cmd_attribute12                =>  p_cmd_attribute12
      ,p_cmd_attribute13                =>  p_cmd_attribute13
      ,p_cmd_attribute14                =>  p_cmd_attribute14
      ,p_cmd_attribute15                =>  p_cmd_attribute15
      ,p_cmd_attribute16                =>  p_cmd_attribute16
      ,p_cmd_attribute17                =>  p_cmd_attribute17
      ,p_cmd_attribute18                =>  p_cmd_attribute18
      ,p_cmd_attribute19                =>  p_cmd_attribute19
      ,p_cmd_attribute20                =>  p_cmd_attribute20
      ,p_cmd_attribute21                =>  p_cmd_attribute21
      ,p_cmd_attribute22                =>  p_cmd_attribute22
      ,p_cmd_attribute23                =>  p_cmd_attribute23
      ,p_cmd_attribute24                =>  p_cmd_attribute24
      ,p_cmd_attribute25                =>  p_cmd_attribute25
      ,p_cmd_attribute26                =>  p_cmd_attribute26
      ,p_cmd_attribute27                =>  p_cmd_attribute27
      ,p_cmd_attribute28                =>  p_cmd_attribute28
      ,p_cmd_attribute29                =>  p_cmd_attribute29
      ,p_cmd_attribute30                =>  p_cmd_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_Comm_Dlvry_Media'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_Comm_Dlvry_Media
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
  p_cm_dlvry_med_typ_id := l_cm_dlvry_med_typ_id;
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
    ROLLBACK TO create_Comm_Dlvry_Media;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_cm_dlvry_med_typ_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_Comm_Dlvry_Media;
    raise;
    --
end create_Comm_Dlvry_Media;
-- ----------------------------------------------------------------------------
-- |------------------------< update_Comm_Dlvry_Media >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_Comm_Dlvry_Media
  (p_validate                       in  boolean   default false
  ,p_cm_dlvry_med_typ_id            in  number
  ,p_cm_dlvry_med_typ_cd            in  varchar2  default hr_api.g_varchar2
  ,p_cm_dlvry_mthd_typ_id           in  number    default hr_api.g_number
  ,p_rqd_flag                       in  varchar2  default hr_api.g_varchar2
  ,p_dflt_flag                      in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_cmd_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_cmd_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_cmd_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_cmd_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_cmd_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_cmd_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_cmd_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_cmd_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_cmd_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_cmd_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_cmd_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_cmd_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_cmd_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_cmd_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_cmd_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_cmd_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_cmd_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_cmd_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_cmd_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_cmd_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_cmd_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_cmd_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_cmd_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_cmd_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_cmd_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_cmd_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_cmd_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_cmd_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_cmd_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_cmd_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_cmd_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Comm_Dlvry_Media';
  l_object_version_number ben_cm_dlvry_med_typ.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_Comm_Dlvry_Media;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_Comm_Dlvry_Media
    --
    ben_Comm_Dlvry_Media_bk2.update_Comm_Dlvry_Media_b
      (
       p_cm_dlvry_med_typ_id            =>  p_cm_dlvry_med_typ_id
      ,p_cm_dlvry_med_typ_cd            =>  p_cm_dlvry_med_typ_cd
      ,p_cm_dlvry_mthd_typ_id           =>  p_cm_dlvry_mthd_typ_id
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_business_group_id              =>  p_business_group_id
      ,p_cmd_attribute_category         =>  p_cmd_attribute_category
      ,p_cmd_attribute1                 =>  p_cmd_attribute1
      ,p_cmd_attribute2                 =>  p_cmd_attribute2
      ,p_cmd_attribute3                 =>  p_cmd_attribute3
      ,p_cmd_attribute4                 =>  p_cmd_attribute4
      ,p_cmd_attribute5                 =>  p_cmd_attribute5
      ,p_cmd_attribute6                 =>  p_cmd_attribute6
      ,p_cmd_attribute7                 =>  p_cmd_attribute7
      ,p_cmd_attribute8                 =>  p_cmd_attribute8
      ,p_cmd_attribute9                 =>  p_cmd_attribute9
      ,p_cmd_attribute10                =>  p_cmd_attribute10
      ,p_cmd_attribute11                =>  p_cmd_attribute11
      ,p_cmd_attribute12                =>  p_cmd_attribute12
      ,p_cmd_attribute13                =>  p_cmd_attribute13
      ,p_cmd_attribute14                =>  p_cmd_attribute14
      ,p_cmd_attribute15                =>  p_cmd_attribute15
      ,p_cmd_attribute16                =>  p_cmd_attribute16
      ,p_cmd_attribute17                =>  p_cmd_attribute17
      ,p_cmd_attribute18                =>  p_cmd_attribute18
      ,p_cmd_attribute19                =>  p_cmd_attribute19
      ,p_cmd_attribute20                =>  p_cmd_attribute20
      ,p_cmd_attribute21                =>  p_cmd_attribute21
      ,p_cmd_attribute22                =>  p_cmd_attribute22
      ,p_cmd_attribute23                =>  p_cmd_attribute23
      ,p_cmd_attribute24                =>  p_cmd_attribute24
      ,p_cmd_attribute25                =>  p_cmd_attribute25
      ,p_cmd_attribute26                =>  p_cmd_attribute26
      ,p_cmd_attribute27                =>  p_cmd_attribute27
      ,p_cmd_attribute28                =>  p_cmd_attribute28
      ,p_cmd_attribute29                =>  p_cmd_attribute29
      ,p_cmd_attribute30                =>  p_cmd_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Comm_Dlvry_Media'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_Comm_Dlvry_Media
    --
  end;
  --
  ben_cmd_upd.upd
    (
     p_cm_dlvry_med_typ_id           => p_cm_dlvry_med_typ_id
    ,p_cm_dlvry_med_typ_cd           => p_cm_dlvry_med_typ_cd
    ,p_cm_dlvry_mthd_typ_id          => p_cm_dlvry_mthd_typ_id
    ,p_rqd_flag                      => p_rqd_flag
    ,p_dflt_flag                     => p_dflt_flag
    ,p_business_group_id             => p_business_group_id
    ,p_cmd_attribute_category        => p_cmd_attribute_category
    ,p_cmd_attribute1                => p_cmd_attribute1
    ,p_cmd_attribute2                => p_cmd_attribute2
    ,p_cmd_attribute3                => p_cmd_attribute3
    ,p_cmd_attribute4                => p_cmd_attribute4
    ,p_cmd_attribute5                => p_cmd_attribute5
    ,p_cmd_attribute6                => p_cmd_attribute6
    ,p_cmd_attribute7                => p_cmd_attribute7
    ,p_cmd_attribute8                => p_cmd_attribute8
    ,p_cmd_attribute9                => p_cmd_attribute9
    ,p_cmd_attribute10               => p_cmd_attribute10
    ,p_cmd_attribute11               => p_cmd_attribute11
    ,p_cmd_attribute12               => p_cmd_attribute12
    ,p_cmd_attribute13               => p_cmd_attribute13
    ,p_cmd_attribute14               => p_cmd_attribute14
    ,p_cmd_attribute15               => p_cmd_attribute15
    ,p_cmd_attribute16               => p_cmd_attribute16
    ,p_cmd_attribute17               => p_cmd_attribute17
    ,p_cmd_attribute18               => p_cmd_attribute18
    ,p_cmd_attribute19               => p_cmd_attribute19
    ,p_cmd_attribute20               => p_cmd_attribute20
    ,p_cmd_attribute21               => p_cmd_attribute21
    ,p_cmd_attribute22               => p_cmd_attribute22
    ,p_cmd_attribute23               => p_cmd_attribute23
    ,p_cmd_attribute24               => p_cmd_attribute24
    ,p_cmd_attribute25               => p_cmd_attribute25
    ,p_cmd_attribute26               => p_cmd_attribute26
    ,p_cmd_attribute27               => p_cmd_attribute27
    ,p_cmd_attribute28               => p_cmd_attribute28
    ,p_cmd_attribute29               => p_cmd_attribute29
    ,p_cmd_attribute30               => p_cmd_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_Comm_Dlvry_Media
    --
    ben_Comm_Dlvry_Media_bk2.update_Comm_Dlvry_Media_a
      (
       p_cm_dlvry_med_typ_id            =>  p_cm_dlvry_med_typ_id
      ,p_cm_dlvry_med_typ_cd            =>  p_cm_dlvry_med_typ_cd
      ,p_cm_dlvry_mthd_typ_id           =>  p_cm_dlvry_mthd_typ_id
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_business_group_id              =>  p_business_group_id
      ,p_cmd_attribute_category         =>  p_cmd_attribute_category
      ,p_cmd_attribute1                 =>  p_cmd_attribute1
      ,p_cmd_attribute2                 =>  p_cmd_attribute2
      ,p_cmd_attribute3                 =>  p_cmd_attribute3
      ,p_cmd_attribute4                 =>  p_cmd_attribute4
      ,p_cmd_attribute5                 =>  p_cmd_attribute5
      ,p_cmd_attribute6                 =>  p_cmd_attribute6
      ,p_cmd_attribute7                 =>  p_cmd_attribute7
      ,p_cmd_attribute8                 =>  p_cmd_attribute8
      ,p_cmd_attribute9                 =>  p_cmd_attribute9
      ,p_cmd_attribute10                =>  p_cmd_attribute10
      ,p_cmd_attribute11                =>  p_cmd_attribute11
      ,p_cmd_attribute12                =>  p_cmd_attribute12
      ,p_cmd_attribute13                =>  p_cmd_attribute13
      ,p_cmd_attribute14                =>  p_cmd_attribute14
      ,p_cmd_attribute15                =>  p_cmd_attribute15
      ,p_cmd_attribute16                =>  p_cmd_attribute16
      ,p_cmd_attribute17                =>  p_cmd_attribute17
      ,p_cmd_attribute18                =>  p_cmd_attribute18
      ,p_cmd_attribute19                =>  p_cmd_attribute19
      ,p_cmd_attribute20                =>  p_cmd_attribute20
      ,p_cmd_attribute21                =>  p_cmd_attribute21
      ,p_cmd_attribute22                =>  p_cmd_attribute22
      ,p_cmd_attribute23                =>  p_cmd_attribute23
      ,p_cmd_attribute24                =>  p_cmd_attribute24
      ,p_cmd_attribute25                =>  p_cmd_attribute25
      ,p_cmd_attribute26                =>  p_cmd_attribute26
      ,p_cmd_attribute27                =>  p_cmd_attribute27
      ,p_cmd_attribute28                =>  p_cmd_attribute28
      ,p_cmd_attribute29                =>  p_cmd_attribute29
      ,p_cmd_attribute30                =>  p_cmd_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Comm_Dlvry_Media'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_Comm_Dlvry_Media
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
    ROLLBACK TO update_Comm_Dlvry_Media;
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
    ROLLBACK TO update_Comm_Dlvry_Media;
    /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    raise;
    --
end update_Comm_Dlvry_Media;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Comm_Dlvry_Media >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Comm_Dlvry_Media
  (p_validate                       in  boolean  default false
  ,p_cm_dlvry_med_typ_id            in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Comm_Dlvry_Media';
  l_object_version_number ben_cm_dlvry_med_typ.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_Comm_Dlvry_Media;
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
    -- Start of API User Hook for the before hook of delete_Comm_Dlvry_Media
    --
    ben_Comm_Dlvry_Media_bk3.delete_Comm_Dlvry_Media_b
      (
       p_cm_dlvry_med_typ_id            =>  p_cm_dlvry_med_typ_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Comm_Dlvry_Media'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_Comm_Dlvry_Media
    --
  end;
  --
  ben_cmd_del.del
    (
     p_cm_dlvry_med_typ_id           => p_cm_dlvry_med_typ_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_Comm_Dlvry_Media
    --
    ben_Comm_Dlvry_Media_bk3.delete_Comm_Dlvry_Media_a
      (
       p_cm_dlvry_med_typ_id            =>  p_cm_dlvry_med_typ_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Comm_Dlvry_Media'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_Comm_Dlvry_Media
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
    ROLLBACK TO delete_Comm_Dlvry_Media;
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
    ROLLBACK TO delete_Comm_Dlvry_Media;
    /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    raise;
    --
end delete_Comm_Dlvry_Media;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_cm_dlvry_med_typ_id                   in     number
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
  ben_cmd_shd.lck
    (
      p_cm_dlvry_med_typ_id                 => p_cm_dlvry_med_typ_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_Comm_Dlvry_Media_api;

/
