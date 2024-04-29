--------------------------------------------------------
--  DDL for Package Body BEN_DSGN_RQMT_RLSHP_TYP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DSGN_RQMT_RLSHP_TYP_API" as
/* $Header: bedrrapi.pkb 115.2 2002/12/11 10:37:24 lakrish ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_DSGN_RQMT_RLSHP_TYP_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_DSGN_RQMT_RLSHP_TYP >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_DSGN_RQMT_RLSHP_TYP
  (p_validate                       in  boolean   default false
  ,p_dsgn_rqmt_rlshp_typ_id         out nocopy number
  ,p_rlshp_typ_cd                   in  varchar2  default null
  ,p_dsgn_rqmt_id                   in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_drr_attribute_category         in  varchar2  default null
  ,p_drr_attribute1                 in  varchar2  default null
  ,p_drr_attribute2                 in  varchar2  default null
  ,p_drr_attribute3                 in  varchar2  default null
  ,p_drr_attribute4                 in  varchar2  default null
  ,p_drr_attribute5                 in  varchar2  default null
  ,p_drr_attribute6                 in  varchar2  default null
  ,p_drr_attribute7                 in  varchar2  default null
  ,p_drr_attribute8                 in  varchar2  default null
  ,p_drr_attribute9                 in  varchar2  default null
  ,p_drr_attribute10                in  varchar2  default null
  ,p_drr_attribute11                in  varchar2  default null
  ,p_drr_attribute12                in  varchar2  default null
  ,p_drr_attribute13                in  varchar2  default null
  ,p_drr_attribute14                in  varchar2  default null
  ,p_drr_attribute15                in  varchar2  default null
  ,p_drr_attribute16                in  varchar2  default null
  ,p_drr_attribute17                in  varchar2  default null
  ,p_drr_attribute18                in  varchar2  default null
  ,p_drr_attribute19                in  varchar2  default null
  ,p_drr_attribute20                in  varchar2  default null
  ,p_drr_attribute21                in  varchar2  default null
  ,p_drr_attribute22                in  varchar2  default null
  ,p_drr_attribute23                in  varchar2  default null
  ,p_drr_attribute24                in  varchar2  default null
  ,p_drr_attribute25                in  varchar2  default null
  ,p_drr_attribute26                in  varchar2  default null
  ,p_drr_attribute27                in  varchar2  default null
  ,p_drr_attribute28                in  varchar2  default null
  ,p_drr_attribute29                in  varchar2  default null
  ,p_drr_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_dsgn_rqmt_rlshp_typ_id ben_dsgn_rqmt_rlshp_typ.dsgn_rqmt_rlshp_typ_id%TYPE;
  l_proc varchar2(72) := g_package||'create_DSGN_RQMT_RLSHP_TYP';
  l_object_version_number ben_dsgn_rqmt_rlshp_typ.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_DSGN_RQMT_RLSHP_TYP;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_DSGN_RQMT_RLSHP_TYP
    --
    ben_DSGN_RQMT_RLSHP_TYP_bk1.create_DSGN_RQMT_RLSHP_TYP_b
      (
       p_rlshp_typ_cd                   =>  p_rlshp_typ_cd
      ,p_dsgn_rqmt_id                   =>  p_dsgn_rqmt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_drr_attribute_category         =>  p_drr_attribute_category
      ,p_drr_attribute1                 =>  p_drr_attribute1
      ,p_drr_attribute2                 =>  p_drr_attribute2
      ,p_drr_attribute3                 =>  p_drr_attribute3
      ,p_drr_attribute4                 =>  p_drr_attribute4
      ,p_drr_attribute5                 =>  p_drr_attribute5
      ,p_drr_attribute6                 =>  p_drr_attribute6
      ,p_drr_attribute7                 =>  p_drr_attribute7
      ,p_drr_attribute8                 =>  p_drr_attribute8
      ,p_drr_attribute9                 =>  p_drr_attribute9
      ,p_drr_attribute10                =>  p_drr_attribute10
      ,p_drr_attribute11                =>  p_drr_attribute11
      ,p_drr_attribute12                =>  p_drr_attribute12
      ,p_drr_attribute13                =>  p_drr_attribute13
      ,p_drr_attribute14                =>  p_drr_attribute14
      ,p_drr_attribute15                =>  p_drr_attribute15
      ,p_drr_attribute16                =>  p_drr_attribute16
      ,p_drr_attribute17                =>  p_drr_attribute17
      ,p_drr_attribute18                =>  p_drr_attribute18
      ,p_drr_attribute19                =>  p_drr_attribute19
      ,p_drr_attribute20                =>  p_drr_attribute20
      ,p_drr_attribute21                =>  p_drr_attribute21
      ,p_drr_attribute22                =>  p_drr_attribute22
      ,p_drr_attribute23                =>  p_drr_attribute23
      ,p_drr_attribute24                =>  p_drr_attribute24
      ,p_drr_attribute25                =>  p_drr_attribute25
      ,p_drr_attribute26                =>  p_drr_attribute26
      ,p_drr_attribute27                =>  p_drr_attribute27
      ,p_drr_attribute28                =>  p_drr_attribute28
      ,p_drr_attribute29                =>  p_drr_attribute29
      ,p_drr_attribute30                =>  p_drr_attribute30
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_DSGN_RQMT_RLSHP_TYP'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_DSGN_RQMT_RLSHP_TYP
    --
  end;
  --
  ben_drr_ins.ins
    (
     p_dsgn_rqmt_rlshp_typ_id        => l_dsgn_rqmt_rlshp_typ_id
    ,p_rlshp_typ_cd                  => p_rlshp_typ_cd
    ,p_dsgn_rqmt_id                  => p_dsgn_rqmt_id
    ,p_business_group_id             => p_business_group_id
    ,p_drr_attribute_category        => p_drr_attribute_category
    ,p_drr_attribute1                => p_drr_attribute1
    ,p_drr_attribute2                => p_drr_attribute2
    ,p_drr_attribute3                => p_drr_attribute3
    ,p_drr_attribute4                => p_drr_attribute4
    ,p_drr_attribute5                => p_drr_attribute5
    ,p_drr_attribute6                => p_drr_attribute6
    ,p_drr_attribute7                => p_drr_attribute7
    ,p_drr_attribute8                => p_drr_attribute8
    ,p_drr_attribute9                => p_drr_attribute9
    ,p_drr_attribute10               => p_drr_attribute10
    ,p_drr_attribute11               => p_drr_attribute11
    ,p_drr_attribute12               => p_drr_attribute12
    ,p_drr_attribute13               => p_drr_attribute13
    ,p_drr_attribute14               => p_drr_attribute14
    ,p_drr_attribute15               => p_drr_attribute15
    ,p_drr_attribute16               => p_drr_attribute16
    ,p_drr_attribute17               => p_drr_attribute17
    ,p_drr_attribute18               => p_drr_attribute18
    ,p_drr_attribute19               => p_drr_attribute19
    ,p_drr_attribute20               => p_drr_attribute20
    ,p_drr_attribute21               => p_drr_attribute21
    ,p_drr_attribute22               => p_drr_attribute22
    ,p_drr_attribute23               => p_drr_attribute23
    ,p_drr_attribute24               => p_drr_attribute24
    ,p_drr_attribute25               => p_drr_attribute25
    ,p_drr_attribute26               => p_drr_attribute26
    ,p_drr_attribute27               => p_drr_attribute27
    ,p_drr_attribute28               => p_drr_attribute28
    ,p_drr_attribute29               => p_drr_attribute29
    ,p_drr_attribute30               => p_drr_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_DSGN_RQMT_RLSHP_TYP
    --
    ben_DSGN_RQMT_RLSHP_TYP_bk1.create_DSGN_RQMT_RLSHP_TYP_a
      (
       p_dsgn_rqmt_rlshp_typ_id         =>  l_dsgn_rqmt_rlshp_typ_id
      ,p_rlshp_typ_cd                   =>  p_rlshp_typ_cd
      ,p_dsgn_rqmt_id                   =>  p_dsgn_rqmt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_drr_attribute_category         =>  p_drr_attribute_category
      ,p_drr_attribute1                 =>  p_drr_attribute1
      ,p_drr_attribute2                 =>  p_drr_attribute2
      ,p_drr_attribute3                 =>  p_drr_attribute3
      ,p_drr_attribute4                 =>  p_drr_attribute4
      ,p_drr_attribute5                 =>  p_drr_attribute5
      ,p_drr_attribute6                 =>  p_drr_attribute6
      ,p_drr_attribute7                 =>  p_drr_attribute7
      ,p_drr_attribute8                 =>  p_drr_attribute8
      ,p_drr_attribute9                 =>  p_drr_attribute9
      ,p_drr_attribute10                =>  p_drr_attribute10
      ,p_drr_attribute11                =>  p_drr_attribute11
      ,p_drr_attribute12                =>  p_drr_attribute12
      ,p_drr_attribute13                =>  p_drr_attribute13
      ,p_drr_attribute14                =>  p_drr_attribute14
      ,p_drr_attribute15                =>  p_drr_attribute15
      ,p_drr_attribute16                =>  p_drr_attribute16
      ,p_drr_attribute17                =>  p_drr_attribute17
      ,p_drr_attribute18                =>  p_drr_attribute18
      ,p_drr_attribute19                =>  p_drr_attribute19
      ,p_drr_attribute20                =>  p_drr_attribute20
      ,p_drr_attribute21                =>  p_drr_attribute21
      ,p_drr_attribute22                =>  p_drr_attribute22
      ,p_drr_attribute23                =>  p_drr_attribute23
      ,p_drr_attribute24                =>  p_drr_attribute24
      ,p_drr_attribute25                =>  p_drr_attribute25
      ,p_drr_attribute26                =>  p_drr_attribute26
      ,p_drr_attribute27                =>  p_drr_attribute27
      ,p_drr_attribute28                =>  p_drr_attribute28
      ,p_drr_attribute29                =>  p_drr_attribute29
      ,p_drr_attribute30                =>  p_drr_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_DSGN_RQMT_RLSHP_TYP'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_DSGN_RQMT_RLSHP_TYP
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
  p_dsgn_rqmt_rlshp_typ_id := l_dsgn_rqmt_rlshp_typ_id;
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
    ROLLBACK TO create_DSGN_RQMT_RLSHP_TYP;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_dsgn_rqmt_rlshp_typ_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_DSGN_RQMT_RLSHP_TYP;

    -- NOCOPY, Reset out parameters
    p_dsgn_rqmt_rlshp_typ_id := null;
    p_object_version_number  := null;

    raise;
    --
end create_DSGN_RQMT_RLSHP_TYP;
-- ----------------------------------------------------------------------------
-- |------------------------< update_DSGN_RQMT_RLSHP_TYP >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_DSGN_RQMT_RLSHP_TYP
  (p_validate                       in  boolean   default false
  ,p_dsgn_rqmt_rlshp_typ_id         in  number
  ,p_rlshp_typ_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_dsgn_rqmt_id                   in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_drr_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_drr_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_DSGN_RQMT_RLSHP_TYP';
  l_object_version_number ben_dsgn_rqmt_rlshp_typ.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_DSGN_RQMT_RLSHP_TYP;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_DSGN_RQMT_RLSHP_TYP
    --
    ben_DSGN_RQMT_RLSHP_TYP_bk2.update_DSGN_RQMT_RLSHP_TYP_b
      (
       p_dsgn_rqmt_rlshp_typ_id         =>  p_dsgn_rqmt_rlshp_typ_id
      ,p_rlshp_typ_cd                   =>  p_rlshp_typ_cd
      ,p_dsgn_rqmt_id                   =>  p_dsgn_rqmt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_drr_attribute_category         =>  p_drr_attribute_category
      ,p_drr_attribute1                 =>  p_drr_attribute1
      ,p_drr_attribute2                 =>  p_drr_attribute2
      ,p_drr_attribute3                 =>  p_drr_attribute3
      ,p_drr_attribute4                 =>  p_drr_attribute4
      ,p_drr_attribute5                 =>  p_drr_attribute5
      ,p_drr_attribute6                 =>  p_drr_attribute6
      ,p_drr_attribute7                 =>  p_drr_attribute7
      ,p_drr_attribute8                 =>  p_drr_attribute8
      ,p_drr_attribute9                 =>  p_drr_attribute9
      ,p_drr_attribute10                =>  p_drr_attribute10
      ,p_drr_attribute11                =>  p_drr_attribute11
      ,p_drr_attribute12                =>  p_drr_attribute12
      ,p_drr_attribute13                =>  p_drr_attribute13
      ,p_drr_attribute14                =>  p_drr_attribute14
      ,p_drr_attribute15                =>  p_drr_attribute15
      ,p_drr_attribute16                =>  p_drr_attribute16
      ,p_drr_attribute17                =>  p_drr_attribute17
      ,p_drr_attribute18                =>  p_drr_attribute18
      ,p_drr_attribute19                =>  p_drr_attribute19
      ,p_drr_attribute20                =>  p_drr_attribute20
      ,p_drr_attribute21                =>  p_drr_attribute21
      ,p_drr_attribute22                =>  p_drr_attribute22
      ,p_drr_attribute23                =>  p_drr_attribute23
      ,p_drr_attribute24                =>  p_drr_attribute24
      ,p_drr_attribute25                =>  p_drr_attribute25
      ,p_drr_attribute26                =>  p_drr_attribute26
      ,p_drr_attribute27                =>  p_drr_attribute27
      ,p_drr_attribute28                =>  p_drr_attribute28
      ,p_drr_attribute29                =>  p_drr_attribute29
      ,p_drr_attribute30                =>  p_drr_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_DSGN_RQMT_RLSHP_TYP'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_DSGN_RQMT_RLSHP_TYP
    --
  end;
  --
  ben_drr_upd.upd
    (
     p_dsgn_rqmt_rlshp_typ_id        => p_dsgn_rqmt_rlshp_typ_id
    ,p_rlshp_typ_cd                  => p_rlshp_typ_cd
    ,p_dsgn_rqmt_id                  => p_dsgn_rqmt_id
    ,p_business_group_id             => p_business_group_id
    ,p_drr_attribute_category        => p_drr_attribute_category
    ,p_drr_attribute1                => p_drr_attribute1
    ,p_drr_attribute2                => p_drr_attribute2
    ,p_drr_attribute3                => p_drr_attribute3
    ,p_drr_attribute4                => p_drr_attribute4
    ,p_drr_attribute5                => p_drr_attribute5
    ,p_drr_attribute6                => p_drr_attribute6
    ,p_drr_attribute7                => p_drr_attribute7
    ,p_drr_attribute8                => p_drr_attribute8
    ,p_drr_attribute9                => p_drr_attribute9
    ,p_drr_attribute10               => p_drr_attribute10
    ,p_drr_attribute11               => p_drr_attribute11
    ,p_drr_attribute12               => p_drr_attribute12
    ,p_drr_attribute13               => p_drr_attribute13
    ,p_drr_attribute14               => p_drr_attribute14
    ,p_drr_attribute15               => p_drr_attribute15
    ,p_drr_attribute16               => p_drr_attribute16
    ,p_drr_attribute17               => p_drr_attribute17
    ,p_drr_attribute18               => p_drr_attribute18
    ,p_drr_attribute19               => p_drr_attribute19
    ,p_drr_attribute20               => p_drr_attribute20
    ,p_drr_attribute21               => p_drr_attribute21
    ,p_drr_attribute22               => p_drr_attribute22
    ,p_drr_attribute23               => p_drr_attribute23
    ,p_drr_attribute24               => p_drr_attribute24
    ,p_drr_attribute25               => p_drr_attribute25
    ,p_drr_attribute26               => p_drr_attribute26
    ,p_drr_attribute27               => p_drr_attribute27
    ,p_drr_attribute28               => p_drr_attribute28
    ,p_drr_attribute29               => p_drr_attribute29
    ,p_drr_attribute30               => p_drr_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_DSGN_RQMT_RLSHP_TYP
    --
    ben_DSGN_RQMT_RLSHP_TYP_bk2.update_DSGN_RQMT_RLSHP_TYP_a
      (
       p_dsgn_rqmt_rlshp_typ_id         =>  p_dsgn_rqmt_rlshp_typ_id
      ,p_rlshp_typ_cd                   =>  p_rlshp_typ_cd
      ,p_dsgn_rqmt_id                   =>  p_dsgn_rqmt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_drr_attribute_category         =>  p_drr_attribute_category
      ,p_drr_attribute1                 =>  p_drr_attribute1
      ,p_drr_attribute2                 =>  p_drr_attribute2
      ,p_drr_attribute3                 =>  p_drr_attribute3
      ,p_drr_attribute4                 =>  p_drr_attribute4
      ,p_drr_attribute5                 =>  p_drr_attribute5
      ,p_drr_attribute6                 =>  p_drr_attribute6
      ,p_drr_attribute7                 =>  p_drr_attribute7
      ,p_drr_attribute8                 =>  p_drr_attribute8
      ,p_drr_attribute9                 =>  p_drr_attribute9
      ,p_drr_attribute10                =>  p_drr_attribute10
      ,p_drr_attribute11                =>  p_drr_attribute11
      ,p_drr_attribute12                =>  p_drr_attribute12
      ,p_drr_attribute13                =>  p_drr_attribute13
      ,p_drr_attribute14                =>  p_drr_attribute14
      ,p_drr_attribute15                =>  p_drr_attribute15
      ,p_drr_attribute16                =>  p_drr_attribute16
      ,p_drr_attribute17                =>  p_drr_attribute17
      ,p_drr_attribute18                =>  p_drr_attribute18
      ,p_drr_attribute19                =>  p_drr_attribute19
      ,p_drr_attribute20                =>  p_drr_attribute20
      ,p_drr_attribute21                =>  p_drr_attribute21
      ,p_drr_attribute22                =>  p_drr_attribute22
      ,p_drr_attribute23                =>  p_drr_attribute23
      ,p_drr_attribute24                =>  p_drr_attribute24
      ,p_drr_attribute25                =>  p_drr_attribute25
      ,p_drr_attribute26                =>  p_drr_attribute26
      ,p_drr_attribute27                =>  p_drr_attribute27
      ,p_drr_attribute28                =>  p_drr_attribute28
      ,p_drr_attribute29                =>  p_drr_attribute29
      ,p_drr_attribute30                =>  p_drr_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_DSGN_RQMT_RLSHP_TYP'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_DSGN_RQMT_RLSHP_TYP
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
    ROLLBACK TO update_DSGN_RQMT_RLSHP_TYP;
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
    ROLLBACK TO update_DSGN_RQMT_RLSHP_TYP;
    raise;
    --
end update_DSGN_RQMT_RLSHP_TYP;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_DSGN_RQMT_RLSHP_TYP >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_DSGN_RQMT_RLSHP_TYP
  (p_validate                       in  boolean  default false
  ,p_dsgn_rqmt_rlshp_typ_id         in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_DSGN_RQMT_RLSHP_TYP';
  l_object_version_number ben_dsgn_rqmt_rlshp_typ.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_DSGN_RQMT_RLSHP_TYP;
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
    -- Start of API User Hook for the before hook of delete_DSGN_RQMT_RLSHP_TYP
    --
    ben_DSGN_RQMT_RLSHP_TYP_bk3.delete_DSGN_RQMT_RLSHP_TYP_b
      (
       p_dsgn_rqmt_rlshp_typ_id         =>  p_dsgn_rqmt_rlshp_typ_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_DSGN_RQMT_RLSHP_TYP'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_DSGN_RQMT_RLSHP_TYP
    --
  end;
  --
  ben_drr_del.del
    (
     p_dsgn_rqmt_rlshp_typ_id        => p_dsgn_rqmt_rlshp_typ_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_DSGN_RQMT_RLSHP_TYP
    --
    ben_DSGN_RQMT_RLSHP_TYP_bk3.delete_DSGN_RQMT_RLSHP_TYP_a
      (
       p_dsgn_rqmt_rlshp_typ_id         =>  p_dsgn_rqmt_rlshp_typ_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_DSGN_RQMT_RLSHP_TYP'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_DSGN_RQMT_RLSHP_TYP
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
    ROLLBACK TO delete_DSGN_RQMT_RLSHP_TYP;
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
    ROLLBACK TO delete_DSGN_RQMT_RLSHP_TYP;
    raise;
    --
end delete_DSGN_RQMT_RLSHP_TYP;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_dsgn_rqmt_rlshp_typ_id                   in     number
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
  ben_drr_shd.lck
    (
      p_dsgn_rqmt_rlshp_typ_id                 => p_dsgn_rqmt_rlshp_typ_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_DSGN_RQMT_RLSHP_TYP_api;

/
