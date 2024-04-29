--------------------------------------------------------
--  DDL for Package Body BEN_COMM_DLVRY_MTHDS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_COMM_DLVRY_MTHDS_API" as
/* $Header: becmtapi.pkb 115.6 2002/12/31 23:57:39 mmudigon ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_Comm_Dlvry_Mthds_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Comm_Dlvry_Mthds >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_Comm_Dlvry_Mthds
  (p_validate                       in  boolean   default false
  ,p_cm_dlvry_mthd_typ_id           out nocopy number
  ,p_cm_dlvry_mthd_typ_cd           in  varchar2  default null
  ,p_business_group_id              in  number    default null
  ,p_cm_typ_id                      in  number    default null
  ,p_cmt_attribute1                 in  varchar2  default null
  ,p_cmt_attribute10                in  varchar2  default null
  ,p_cmt_attribute11                in  varchar2  default null
  ,p_cmt_attribute12                in  varchar2  default null
  ,p_cmt_attribute13                in  varchar2  default null
  ,p_cmt_attribute14                in  varchar2  default null
  ,p_cmt_attribute15                in  varchar2  default null
  ,p_cmt_attribute16                in  varchar2  default null
  ,p_cmt_attribute17                in  varchar2  default null
  ,p_cmt_attribute18                in  varchar2  default null
  ,p_cmt_attribute19                in  varchar2  default null
  ,p_cmt_attribute2                 in  varchar2  default null
  ,p_cmt_attribute20                in  varchar2  default null
  ,p_cmt_attribute21                in  varchar2  default null
  ,p_cmt_attribute22                in  varchar2  default null
  ,p_cmt_attribute23                in  varchar2  default null
  ,p_cmt_attribute24                in  varchar2  default null
  ,p_cmt_attribute25                in  varchar2  default null
  ,p_cmt_attribute26                in  varchar2  default null
  ,p_cmt_attribute27                in  varchar2  default null
  ,p_cmt_attribute28                in  varchar2  default null
  ,p_cmt_attribute29                in  varchar2  default null
  ,p_cmt_attribute3                 in  varchar2  default null
  ,p_cmt_attribute30                in  varchar2  default null
  ,p_rqd_flag                       in  varchar2  default null
  ,p_cmt_attribute_category         in  varchar2  default null
  ,p_cmt_attribute4                 in  varchar2  default null
  ,p_cmt_attribute5                 in  varchar2  default null
  ,p_cmt_attribute6                 in  varchar2  default null
  ,p_cmt_attribute7                 in  varchar2  default null
  ,p_cmt_attribute8                 in  varchar2  default null
  ,p_cmt_attribute9                 in  varchar2  default null
  ,p_dflt_flag                      in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_cm_dlvry_mthd_typ_id ben_cm_dlvry_mthd_typ.cm_dlvry_mthd_typ_id%TYPE;
  l_proc varchar2(72) := g_package||'create_Comm_Dlvry_Mthds';
  l_object_version_number ben_cm_dlvry_mthd_typ.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_Comm_Dlvry_Mthds;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_Comm_Dlvry_Mthds
    --
    ben_Comm_Dlvry_Mthds_bk1.create_Comm_Dlvry_Mthds_b
      (
       p_cm_dlvry_mthd_typ_cd           =>  p_cm_dlvry_mthd_typ_cd
      ,p_business_group_id              =>  p_business_group_id
      ,p_cm_typ_id                      =>  p_cm_typ_id
      ,p_cmt_attribute1                 =>  p_cmt_attribute1
      ,p_cmt_attribute10                =>  p_cmt_attribute10
      ,p_cmt_attribute11                =>  p_cmt_attribute11
      ,p_cmt_attribute12                =>  p_cmt_attribute12
      ,p_cmt_attribute13                =>  p_cmt_attribute13
      ,p_cmt_attribute14                =>  p_cmt_attribute14
      ,p_cmt_attribute15                =>  p_cmt_attribute15
      ,p_cmt_attribute16                =>  p_cmt_attribute16
      ,p_cmt_attribute17                =>  p_cmt_attribute17
      ,p_cmt_attribute18                =>  p_cmt_attribute18
      ,p_cmt_attribute19                =>  p_cmt_attribute19
      ,p_cmt_attribute2                 =>  p_cmt_attribute2
      ,p_cmt_attribute20                =>  p_cmt_attribute20
      ,p_cmt_attribute21                =>  p_cmt_attribute21
      ,p_cmt_attribute22                =>  p_cmt_attribute22
      ,p_cmt_attribute23                =>  p_cmt_attribute23
      ,p_cmt_attribute24                =>  p_cmt_attribute24
      ,p_cmt_attribute25                =>  p_cmt_attribute25
      ,p_cmt_attribute26                =>  p_cmt_attribute26
      ,p_cmt_attribute27                =>  p_cmt_attribute27
      ,p_cmt_attribute28                =>  p_cmt_attribute28
      ,p_cmt_attribute29                =>  p_cmt_attribute29
      ,p_cmt_attribute3                 =>  p_cmt_attribute3
      ,p_cmt_attribute30                =>  p_cmt_attribute30
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_cmt_attribute_category         =>  p_cmt_attribute_category
      ,p_cmt_attribute4                 =>  p_cmt_attribute4
      ,p_cmt_attribute5                 =>  p_cmt_attribute5
      ,p_cmt_attribute6                 =>  p_cmt_attribute6
      ,p_cmt_attribute7                 =>  p_cmt_attribute7
      ,p_cmt_attribute8                 =>  p_cmt_attribute8
      ,p_cmt_attribute9                 =>  p_cmt_attribute9
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_Comm_Dlvry_Mthds'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_Comm_Dlvry_Mthds
    --
  end;
  --
  ben_cmt_ins.ins
    (
     p_cm_dlvry_mthd_typ_id          => l_cm_dlvry_mthd_typ_id
    ,p_cm_dlvry_mthd_typ_cd          => p_cm_dlvry_mthd_typ_cd
    ,p_business_group_id             => p_business_group_id
    ,p_cm_typ_id                     => p_cm_typ_id
    ,p_cmt_attribute1                => p_cmt_attribute1
    ,p_cmt_attribute10               => p_cmt_attribute10
    ,p_cmt_attribute11               => p_cmt_attribute11
    ,p_cmt_attribute12               => p_cmt_attribute12
    ,p_cmt_attribute13               => p_cmt_attribute13
    ,p_cmt_attribute14               => p_cmt_attribute14
    ,p_cmt_attribute15               => p_cmt_attribute15
    ,p_cmt_attribute16               => p_cmt_attribute16
    ,p_cmt_attribute17               => p_cmt_attribute17
    ,p_cmt_attribute18               => p_cmt_attribute18
    ,p_cmt_attribute19               => p_cmt_attribute19
    ,p_cmt_attribute2                => p_cmt_attribute2
    ,p_cmt_attribute20               => p_cmt_attribute20
    ,p_cmt_attribute21               => p_cmt_attribute21
    ,p_cmt_attribute22               => p_cmt_attribute22
    ,p_cmt_attribute23               => p_cmt_attribute23
    ,p_cmt_attribute24               => p_cmt_attribute24
    ,p_cmt_attribute25               => p_cmt_attribute25
    ,p_cmt_attribute26               => p_cmt_attribute26
    ,p_cmt_attribute27               => p_cmt_attribute27
    ,p_cmt_attribute28               => p_cmt_attribute28
    ,p_cmt_attribute29               => p_cmt_attribute29
    ,p_cmt_attribute3                => p_cmt_attribute3
    ,p_cmt_attribute30               => p_cmt_attribute30
    ,p_rqd_flag                      => p_rqd_flag
    ,p_cmt_attribute_category        => p_cmt_attribute_category
    ,p_cmt_attribute4                => p_cmt_attribute4
    ,p_cmt_attribute5                => p_cmt_attribute5
    ,p_cmt_attribute6                => p_cmt_attribute6
    ,p_cmt_attribute7                => p_cmt_attribute7
    ,p_cmt_attribute8                => p_cmt_attribute8
    ,p_cmt_attribute9                => p_cmt_attribute9
    ,p_dflt_flag                     => p_dflt_flag
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_Comm_Dlvry_Mthds
    --
    ben_Comm_Dlvry_Mthds_bk1.create_Comm_Dlvry_Mthds_a
      (
       p_cm_dlvry_mthd_typ_id           =>  l_cm_dlvry_mthd_typ_id
      ,p_cm_dlvry_mthd_typ_cd           =>  p_cm_dlvry_mthd_typ_cd
      ,p_business_group_id              =>  p_business_group_id
      ,p_cm_typ_id                      =>  p_cm_typ_id
      ,p_cmt_attribute1                 =>  p_cmt_attribute1
      ,p_cmt_attribute10                =>  p_cmt_attribute10
      ,p_cmt_attribute11                =>  p_cmt_attribute11
      ,p_cmt_attribute12                =>  p_cmt_attribute12
      ,p_cmt_attribute13                =>  p_cmt_attribute13
      ,p_cmt_attribute14                =>  p_cmt_attribute14
      ,p_cmt_attribute15                =>  p_cmt_attribute15
      ,p_cmt_attribute16                =>  p_cmt_attribute16
      ,p_cmt_attribute17                =>  p_cmt_attribute17
      ,p_cmt_attribute18                =>  p_cmt_attribute18
      ,p_cmt_attribute19                =>  p_cmt_attribute19
      ,p_cmt_attribute2                 =>  p_cmt_attribute2
      ,p_cmt_attribute20                =>  p_cmt_attribute20
      ,p_cmt_attribute21                =>  p_cmt_attribute21
      ,p_cmt_attribute22                =>  p_cmt_attribute22
      ,p_cmt_attribute23                =>  p_cmt_attribute23
      ,p_cmt_attribute24                =>  p_cmt_attribute24
      ,p_cmt_attribute25                =>  p_cmt_attribute25
      ,p_cmt_attribute26                =>  p_cmt_attribute26
      ,p_cmt_attribute27                =>  p_cmt_attribute27
      ,p_cmt_attribute28                =>  p_cmt_attribute28
      ,p_cmt_attribute29                =>  p_cmt_attribute29
      ,p_cmt_attribute3                 =>  p_cmt_attribute3
      ,p_cmt_attribute30                =>  p_cmt_attribute30
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_cmt_attribute_category         =>  p_cmt_attribute_category
      ,p_cmt_attribute4                 =>  p_cmt_attribute4
      ,p_cmt_attribute5                 =>  p_cmt_attribute5
      ,p_cmt_attribute6                 =>  p_cmt_attribute6
      ,p_cmt_attribute7                 =>  p_cmt_attribute7
      ,p_cmt_attribute8                 =>  p_cmt_attribute8
      ,p_cmt_attribute9                 =>  p_cmt_attribute9
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_Comm_Dlvry_Mthds'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_Comm_Dlvry_Mthds
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
  p_cm_dlvry_mthd_typ_id := l_cm_dlvry_mthd_typ_id;
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
    ROLLBACK TO create_Comm_Dlvry_Mthds;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_cm_dlvry_mthd_typ_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_Comm_Dlvry_Mthds;
    raise;
    --
end create_Comm_Dlvry_Mthds;
-- ----------------------------------------------------------------------------
-- |------------------------< update_Comm_Dlvry_Mthds >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_Comm_Dlvry_Mthds
  (p_validate                       in  boolean   default false
  ,p_cm_dlvry_mthd_typ_id           in  number
  ,p_cm_dlvry_mthd_typ_cd           in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_cm_typ_id                      in  number    default hr_api.g_number
  ,p_cmt_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_cmt_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_cmt_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_cmt_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_cmt_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_cmt_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_cmt_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_cmt_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_cmt_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_cmt_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_cmt_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_cmt_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_cmt_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_cmt_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_cmt_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_cmt_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_cmt_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_cmt_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_cmt_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_cmt_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_cmt_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_cmt_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_cmt_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_cmt_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_rqd_flag                       in  varchar2  default hr_api.g_varchar2
  ,p_cmt_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_cmt_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_cmt_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_cmt_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_cmt_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_cmt_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_cmt_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_dflt_flag                      in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Comm_Dlvry_Mthds';
  l_object_version_number ben_cm_dlvry_mthd_typ.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_Comm_Dlvry_Mthds;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_Comm_Dlvry_Mthds
    --
    ben_Comm_Dlvry_Mthds_bk2.update_Comm_Dlvry_Mthds_b
      (
       p_cm_dlvry_mthd_typ_id           =>  p_cm_dlvry_mthd_typ_id
      ,p_cm_dlvry_mthd_typ_cd           =>  p_cm_dlvry_mthd_typ_cd
      ,p_business_group_id              =>  p_business_group_id
      ,p_cm_typ_id                      =>  p_cm_typ_id
      ,p_cmt_attribute1                 =>  p_cmt_attribute1
      ,p_cmt_attribute10                =>  p_cmt_attribute10
      ,p_cmt_attribute11                =>  p_cmt_attribute11
      ,p_cmt_attribute12                =>  p_cmt_attribute12
      ,p_cmt_attribute13                =>  p_cmt_attribute13
      ,p_cmt_attribute14                =>  p_cmt_attribute14
      ,p_cmt_attribute15                =>  p_cmt_attribute15
      ,p_cmt_attribute16                =>  p_cmt_attribute16
      ,p_cmt_attribute17                =>  p_cmt_attribute17
      ,p_cmt_attribute18                =>  p_cmt_attribute18
      ,p_cmt_attribute19                =>  p_cmt_attribute19
      ,p_cmt_attribute2                 =>  p_cmt_attribute2
      ,p_cmt_attribute20                =>  p_cmt_attribute20
      ,p_cmt_attribute21                =>  p_cmt_attribute21
      ,p_cmt_attribute22                =>  p_cmt_attribute22
      ,p_cmt_attribute23                =>  p_cmt_attribute23
      ,p_cmt_attribute24                =>  p_cmt_attribute24
      ,p_cmt_attribute25                =>  p_cmt_attribute25
      ,p_cmt_attribute26                =>  p_cmt_attribute26
      ,p_cmt_attribute27                =>  p_cmt_attribute27
      ,p_cmt_attribute28                =>  p_cmt_attribute28
      ,p_cmt_attribute29                =>  p_cmt_attribute29
      ,p_cmt_attribute3                 =>  p_cmt_attribute3
      ,p_cmt_attribute30                =>  p_cmt_attribute30
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_cmt_attribute_category         =>  p_cmt_attribute_category
      ,p_cmt_attribute4                 =>  p_cmt_attribute4
      ,p_cmt_attribute5                 =>  p_cmt_attribute5
      ,p_cmt_attribute6                 =>  p_cmt_attribute6
      ,p_cmt_attribute7                 =>  p_cmt_attribute7
      ,p_cmt_attribute8                 =>  p_cmt_attribute8
      ,p_cmt_attribute9                 =>  p_cmt_attribute9
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Comm_Dlvry_Mthds'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_Comm_Dlvry_Mthds
    --
  end;
  --
  ben_cmt_upd.upd
    (
     p_cm_dlvry_mthd_typ_id          => p_cm_dlvry_mthd_typ_id
    ,p_cm_dlvry_mthd_typ_cd          => p_cm_dlvry_mthd_typ_cd
    ,p_business_group_id             => p_business_group_id
    ,p_cm_typ_id                     => p_cm_typ_id
    ,p_cmt_attribute1                => p_cmt_attribute1
    ,p_cmt_attribute10               => p_cmt_attribute10
    ,p_cmt_attribute11               => p_cmt_attribute11
    ,p_cmt_attribute12               => p_cmt_attribute12
    ,p_cmt_attribute13               => p_cmt_attribute13
    ,p_cmt_attribute14               => p_cmt_attribute14
    ,p_cmt_attribute15               => p_cmt_attribute15
    ,p_cmt_attribute16               => p_cmt_attribute16
    ,p_cmt_attribute17               => p_cmt_attribute17
    ,p_cmt_attribute18               => p_cmt_attribute18
    ,p_cmt_attribute19               => p_cmt_attribute19
    ,p_cmt_attribute2                => p_cmt_attribute2
    ,p_cmt_attribute20               => p_cmt_attribute20
    ,p_cmt_attribute21               => p_cmt_attribute21
    ,p_cmt_attribute22               => p_cmt_attribute22
    ,p_cmt_attribute23               => p_cmt_attribute23
    ,p_cmt_attribute24               => p_cmt_attribute24
    ,p_cmt_attribute25               => p_cmt_attribute25
    ,p_cmt_attribute26               => p_cmt_attribute26
    ,p_cmt_attribute27               => p_cmt_attribute27
    ,p_cmt_attribute28               => p_cmt_attribute28
    ,p_cmt_attribute29               => p_cmt_attribute29
    ,p_cmt_attribute3                => p_cmt_attribute3
    ,p_cmt_attribute30               => p_cmt_attribute30
    ,p_rqd_flag                      => p_rqd_flag
    ,p_cmt_attribute_category        => p_cmt_attribute_category
    ,p_cmt_attribute4                => p_cmt_attribute4
    ,p_cmt_attribute5                => p_cmt_attribute5
    ,p_cmt_attribute6                => p_cmt_attribute6
    ,p_cmt_attribute7                => p_cmt_attribute7
    ,p_cmt_attribute8                => p_cmt_attribute8
    ,p_cmt_attribute9                => p_cmt_attribute9
    ,p_dflt_flag                     => p_dflt_flag
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_Comm_Dlvry_Mthds
    --
    ben_Comm_Dlvry_Mthds_bk2.update_Comm_Dlvry_Mthds_a
      (
       p_cm_dlvry_mthd_typ_id           =>  p_cm_dlvry_mthd_typ_id
      ,p_cm_dlvry_mthd_typ_cd           =>  p_cm_dlvry_mthd_typ_cd
      ,p_business_group_id              =>  p_business_group_id
      ,p_cm_typ_id                      =>  p_cm_typ_id
      ,p_cmt_attribute1                 =>  p_cmt_attribute1
      ,p_cmt_attribute10                =>  p_cmt_attribute10
      ,p_cmt_attribute11                =>  p_cmt_attribute11
      ,p_cmt_attribute12                =>  p_cmt_attribute12
      ,p_cmt_attribute13                =>  p_cmt_attribute13
      ,p_cmt_attribute14                =>  p_cmt_attribute14
      ,p_cmt_attribute15                =>  p_cmt_attribute15
      ,p_cmt_attribute16                =>  p_cmt_attribute16
      ,p_cmt_attribute17                =>  p_cmt_attribute17
      ,p_cmt_attribute18                =>  p_cmt_attribute18
      ,p_cmt_attribute19                =>  p_cmt_attribute19
      ,p_cmt_attribute2                 =>  p_cmt_attribute2
      ,p_cmt_attribute20                =>  p_cmt_attribute20
      ,p_cmt_attribute21                =>  p_cmt_attribute21
      ,p_cmt_attribute22                =>  p_cmt_attribute22
      ,p_cmt_attribute23                =>  p_cmt_attribute23
      ,p_cmt_attribute24                =>  p_cmt_attribute24
      ,p_cmt_attribute25                =>  p_cmt_attribute25
      ,p_cmt_attribute26                =>  p_cmt_attribute26
      ,p_cmt_attribute27                =>  p_cmt_attribute27
      ,p_cmt_attribute28                =>  p_cmt_attribute28
      ,p_cmt_attribute29                =>  p_cmt_attribute29
      ,p_cmt_attribute3                 =>  p_cmt_attribute3
      ,p_cmt_attribute30                =>  p_cmt_attribute30
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_cmt_attribute_category         =>  p_cmt_attribute_category
      ,p_cmt_attribute4                 =>  p_cmt_attribute4
      ,p_cmt_attribute5                 =>  p_cmt_attribute5
      ,p_cmt_attribute6                 =>  p_cmt_attribute6
      ,p_cmt_attribute7                 =>  p_cmt_attribute7
      ,p_cmt_attribute8                 =>  p_cmt_attribute8
      ,p_cmt_attribute9                 =>  p_cmt_attribute9
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Comm_Dlvry_Mthds'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_Comm_Dlvry_Mthds
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
    ROLLBACK TO update_Comm_Dlvry_Mthds;
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
    ROLLBACK TO update_Comm_Dlvry_Mthds;
    /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    raise;
    --
end update_Comm_Dlvry_Mthds;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Comm_Dlvry_Mthds >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Comm_Dlvry_Mthds
  (p_validate                       in  boolean  default false
  ,p_cm_dlvry_mthd_typ_id           in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Comm_Dlvry_Mthds';
  l_object_version_number ben_cm_dlvry_mthd_typ.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_Comm_Dlvry_Mthds;
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
    -- Start of API User Hook for the before hook of delete_Comm_Dlvry_Mthds
    --
    ben_Comm_Dlvry_Mthds_bk3.delete_Comm_Dlvry_Mthds_b
      (
       p_cm_dlvry_mthd_typ_id           =>  p_cm_dlvry_mthd_typ_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Comm_Dlvry_Mthds'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_Comm_Dlvry_Mthds
    --
  end;
  --
  ben_cmt_del.del
    (
     p_cm_dlvry_mthd_typ_id          => p_cm_dlvry_mthd_typ_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_Comm_Dlvry_Mthds
    --
    ben_Comm_Dlvry_Mthds_bk3.delete_Comm_Dlvry_Mthds_a
      (
       p_cm_dlvry_mthd_typ_id           =>  p_cm_dlvry_mthd_typ_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Comm_Dlvry_Mthds'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_Comm_Dlvry_Mthds
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
    ROLLBACK TO delete_Comm_Dlvry_Mthds;
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
    ROLLBACK TO delete_Comm_Dlvry_Mthds;
    /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    raise;
    --
end delete_Comm_Dlvry_Mthds;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_cm_dlvry_mthd_typ_id                   in     number
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
  ben_cmt_shd.lck
    (
      p_cm_dlvry_mthd_typ_id                 => p_cm_dlvry_mthd_typ_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_Comm_Dlvry_Mthds_api;

/
