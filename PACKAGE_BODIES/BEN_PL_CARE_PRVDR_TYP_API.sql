--------------------------------------------------------
--  DDL for Package Body BEN_PL_CARE_PRVDR_TYP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PL_CARE_PRVDR_TYP_API" as
/* $Header: beptyapi.pkb 115.3 2002/12/13 08:30:49 bmanyam noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_pl_care_prvdr_typ_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_pl_care_prvdr_typ >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_pl_care_prvdr_typ
  (p_validate                       in  boolean   default false
  ,p_pl_pcp_typ_id                  out nocopy number
  ,p_pl_pcp_id                      in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_pcp_typ_cd                     in  varchar2  default null
  ,p_min_age                        in  number    default null
  ,p_max_age                        in  number    default null
  ,p_gndr_alwd_cd                   in  varchar2  default null
  ,p_pty_attribute_category         in  varchar2  default null
  ,p_pty_attribute1                 in  varchar2  default null
  ,p_pty_attribute2                 in  varchar2  default null
  ,p_pty_attribute3                 in  varchar2  default null
  ,p_pty_attribute4                 in  varchar2  default null
  ,p_pty_attribute5                 in  varchar2  default null
  ,p_pty_attribute6                 in  varchar2  default null
  ,p_pty_attribute7                 in  varchar2  default null
  ,p_pty_attribute8                 in  varchar2  default null
  ,p_pty_attribute9                 in  varchar2  default null
  ,p_pty_attribute10                in  varchar2  default null
  ,p_pty_attribute11                in  varchar2  default null
  ,p_pty_attribute12                in  varchar2  default null
  ,p_pty_attribute13                in  varchar2  default null
  ,p_pty_attribute14                in  varchar2  default null
  ,p_pty_attribute15                in  varchar2  default null
  ,p_pty_attribute16                in  varchar2  default null
  ,p_pty_attribute17                in  varchar2  default null
  ,p_pty_attribute18                in  varchar2  default null
  ,p_pty_attribute19                in  varchar2  default null
  ,p_pty_attribute20                in  varchar2  default null
  ,p_pty_attribute21                in  varchar2  default null
  ,p_pty_attribute22                in  varchar2  default null
  ,p_pty_attribute23                in  varchar2  default null
  ,p_pty_attribute24                in  varchar2  default null
  ,p_pty_attribute25                in  varchar2  default null
  ,p_pty_attribute26                in  varchar2  default null
  ,p_pty_attribute27                in  varchar2  default null
  ,p_pty_attribute28                in  varchar2  default null
  ,p_pty_attribute29                in  varchar2  default null
  ,p_pty_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_pl_pcp_typ_id ben_pl_pcp_typ.pl_pcp_typ_id%TYPE;
  l_proc varchar2(72) := g_package||'create_pl_care_prvdr_typ';
  l_object_version_number ben_pl_pcp_typ.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_pl_care_prvdr_typ;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_pl_care_prvdr_typ
    --
    ben_pl_care_prvdr_typ_bk1.create_pl_care_prvdr_typ_b
      (
       p_pl_pcp_id                      =>  p_pl_pcp_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pcp_typ_cd                     =>  p_pcp_typ_cd
      ,p_min_age                        =>  p_min_age
      ,p_max_age                        =>  p_max_age
      ,p_gndr_alwd_cd                   =>  p_gndr_alwd_cd
      ,p_pty_attribute_category         =>  p_pty_attribute_category
      ,p_pty_attribute1                 =>  p_pty_attribute1
      ,p_pty_attribute2                 =>  p_pty_attribute2
      ,p_pty_attribute3                 =>  p_pty_attribute3
      ,p_pty_attribute4                 =>  p_pty_attribute4
      ,p_pty_attribute5                 =>  p_pty_attribute5
      ,p_pty_attribute6                 =>  p_pty_attribute6
      ,p_pty_attribute7                 =>  p_pty_attribute7
      ,p_pty_attribute8                 =>  p_pty_attribute8
      ,p_pty_attribute9                 =>  p_pty_attribute9
      ,p_pty_attribute10                =>  p_pty_attribute10
      ,p_pty_attribute11                =>  p_pty_attribute11
      ,p_pty_attribute12                =>  p_pty_attribute12
      ,p_pty_attribute13                =>  p_pty_attribute13
      ,p_pty_attribute14                =>  p_pty_attribute14
      ,p_pty_attribute15                =>  p_pty_attribute15
      ,p_pty_attribute16                =>  p_pty_attribute16
      ,p_pty_attribute17                =>  p_pty_attribute17
      ,p_pty_attribute18                =>  p_pty_attribute18
      ,p_pty_attribute19                =>  p_pty_attribute19
      ,p_pty_attribute20                =>  p_pty_attribute20
      ,p_pty_attribute21                =>  p_pty_attribute21
      ,p_pty_attribute22                =>  p_pty_attribute22
      ,p_pty_attribute23                =>  p_pty_attribute23
      ,p_pty_attribute24                =>  p_pty_attribute24
      ,p_pty_attribute25                =>  p_pty_attribute25
      ,p_pty_attribute26                =>  p_pty_attribute26
      ,p_pty_attribute27                =>  p_pty_attribute27
      ,p_pty_attribute28                =>  p_pty_attribute28
      ,p_pty_attribute29                =>  p_pty_attribute29
      ,p_pty_attribute30                =>  p_pty_attribute30
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_pl_care_prvdr_typ'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_pl_care_prvdr_typ
    --
  end;
  --
  ben_pty_ins.ins
    (
     p_pl_pcp_typ_id                 => l_pl_pcp_typ_id
    ,p_pl_pcp_id                     => p_pl_pcp_id
    ,p_business_group_id             => p_business_group_id
    ,p_pcp_typ_cd                    => p_pcp_typ_cd
    ,p_min_age                       => p_min_age
    ,p_max_age                       => p_max_age
    ,p_gndr_alwd_cd                  => p_gndr_alwd_cd
    ,p_pty_attribute_category        => p_pty_attribute_category
    ,p_pty_attribute1                => p_pty_attribute1
    ,p_pty_attribute2                => p_pty_attribute2
    ,p_pty_attribute3                => p_pty_attribute3
    ,p_pty_attribute4                => p_pty_attribute4
    ,p_pty_attribute5                => p_pty_attribute5
    ,p_pty_attribute6                => p_pty_attribute6
    ,p_pty_attribute7                => p_pty_attribute7
    ,p_pty_attribute8                => p_pty_attribute8
    ,p_pty_attribute9                => p_pty_attribute9
    ,p_pty_attribute10               => p_pty_attribute10
    ,p_pty_attribute11               => p_pty_attribute11
    ,p_pty_attribute12               => p_pty_attribute12
    ,p_pty_attribute13               => p_pty_attribute13
    ,p_pty_attribute14               => p_pty_attribute14
    ,p_pty_attribute15               => p_pty_attribute15
    ,p_pty_attribute16               => p_pty_attribute16
    ,p_pty_attribute17               => p_pty_attribute17
    ,p_pty_attribute18               => p_pty_attribute18
    ,p_pty_attribute19               => p_pty_attribute19
    ,p_pty_attribute20               => p_pty_attribute20
    ,p_pty_attribute21               => p_pty_attribute21
    ,p_pty_attribute22               => p_pty_attribute22
    ,p_pty_attribute23               => p_pty_attribute23
    ,p_pty_attribute24               => p_pty_attribute24
    ,p_pty_attribute25               => p_pty_attribute25
    ,p_pty_attribute26               => p_pty_attribute26
    ,p_pty_attribute27               => p_pty_attribute27
    ,p_pty_attribute28               => p_pty_attribute28
    ,p_pty_attribute29               => p_pty_attribute29
    ,p_pty_attribute30               => p_pty_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_pl_care_prvdr_typ
    --
    ben_pl_care_prvdr_typ_bk1.create_pl_care_prvdr_typ_a
      (
       p_pl_pcp_typ_id                  =>  l_pl_pcp_typ_id
      ,p_pl_pcp_id                      =>  p_pl_pcp_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pcp_typ_cd                     =>  p_pcp_typ_cd
      ,p_min_age                        =>  p_min_age
      ,p_max_age                        =>  p_max_age
      ,p_gndr_alwd_cd                   =>  p_gndr_alwd_cd
      ,p_pty_attribute_category         =>  p_pty_attribute_category
      ,p_pty_attribute1                 =>  p_pty_attribute1
      ,p_pty_attribute2                 =>  p_pty_attribute2
      ,p_pty_attribute3                 =>  p_pty_attribute3
      ,p_pty_attribute4                 =>  p_pty_attribute4
      ,p_pty_attribute5                 =>  p_pty_attribute5
      ,p_pty_attribute6                 =>  p_pty_attribute6
      ,p_pty_attribute7                 =>  p_pty_attribute7
      ,p_pty_attribute8                 =>  p_pty_attribute8
      ,p_pty_attribute9                 =>  p_pty_attribute9
      ,p_pty_attribute10                =>  p_pty_attribute10
      ,p_pty_attribute11                =>  p_pty_attribute11
      ,p_pty_attribute12                =>  p_pty_attribute12
      ,p_pty_attribute13                =>  p_pty_attribute13
      ,p_pty_attribute14                =>  p_pty_attribute14
      ,p_pty_attribute15                =>  p_pty_attribute15
      ,p_pty_attribute16                =>  p_pty_attribute16
      ,p_pty_attribute17                =>  p_pty_attribute17
      ,p_pty_attribute18                =>  p_pty_attribute18
      ,p_pty_attribute19                =>  p_pty_attribute19
      ,p_pty_attribute20                =>  p_pty_attribute20
      ,p_pty_attribute21                =>  p_pty_attribute21
      ,p_pty_attribute22                =>  p_pty_attribute22
      ,p_pty_attribute23                =>  p_pty_attribute23
      ,p_pty_attribute24                =>  p_pty_attribute24
      ,p_pty_attribute25                =>  p_pty_attribute25
      ,p_pty_attribute26                =>  p_pty_attribute26
      ,p_pty_attribute27                =>  p_pty_attribute27
      ,p_pty_attribute28                =>  p_pty_attribute28
      ,p_pty_attribute29                =>  p_pty_attribute29
      ,p_pty_attribute30                =>  p_pty_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_pl_care_prvdr_typ'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_pl_care_prvdr_typ
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
  p_pl_pcp_typ_id := l_pl_pcp_typ_id;
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
    ROLLBACK TO create_pl_care_prvdr_typ;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_pl_pcp_typ_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_pl_care_prvdr_typ;
    -- NOCOPY Changes
    p_pl_pcp_typ_id := null;
    p_object_version_number  := null;
    -- NOCOPY Changes
   raise;
    --
end create_pl_care_prvdr_typ;
-- ----------------------------------------------------------------------------
-- |------------------------< update_pl_care_prvdr_typ >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_pl_care_prvdr_typ
  (p_validate                       in  boolean   default false
  ,p_pl_pcp_typ_id                  in  number
  ,p_pl_pcp_id                      in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pcp_typ_cd                     in  varchar2  default hr_api.g_varchar2
  ,p_min_age                        in  number    default hr_api.g_number
  ,p_max_age                        in  number    default hr_api.g_number
  ,p_gndr_alwd_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pty_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_pl_care_prvdr_typ';
  l_object_version_number ben_pl_pcp_typ.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_pl_care_prvdr_typ;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_pl_care_prvdr_typ
    --
    ben_pl_care_prvdr_typ_bk2.update_pl_care_prvdr_typ_b
      (
       p_pl_pcp_typ_id                  =>  p_pl_pcp_typ_id
      ,p_pl_pcp_id                      =>  p_pl_pcp_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pcp_typ_cd                     =>  p_pcp_typ_cd
      ,p_min_age                        =>  p_min_age
      ,p_max_age                        =>  p_max_age
      ,p_gndr_alwd_cd                   =>  p_gndr_alwd_cd
      ,p_pty_attribute_category         =>  p_pty_attribute_category
      ,p_pty_attribute1                 =>  p_pty_attribute1
      ,p_pty_attribute2                 =>  p_pty_attribute2
      ,p_pty_attribute3                 =>  p_pty_attribute3
      ,p_pty_attribute4                 =>  p_pty_attribute4
      ,p_pty_attribute5                 =>  p_pty_attribute5
      ,p_pty_attribute6                 =>  p_pty_attribute6
      ,p_pty_attribute7                 =>  p_pty_attribute7
      ,p_pty_attribute8                 =>  p_pty_attribute8
      ,p_pty_attribute9                 =>  p_pty_attribute9
      ,p_pty_attribute10                =>  p_pty_attribute10
      ,p_pty_attribute11                =>  p_pty_attribute11
      ,p_pty_attribute12                =>  p_pty_attribute12
      ,p_pty_attribute13                =>  p_pty_attribute13
      ,p_pty_attribute14                =>  p_pty_attribute14
      ,p_pty_attribute15                =>  p_pty_attribute15
      ,p_pty_attribute16                =>  p_pty_attribute16
      ,p_pty_attribute17                =>  p_pty_attribute17
      ,p_pty_attribute18                =>  p_pty_attribute18
      ,p_pty_attribute19                =>  p_pty_attribute19
      ,p_pty_attribute20                =>  p_pty_attribute20
      ,p_pty_attribute21                =>  p_pty_attribute21
      ,p_pty_attribute22                =>  p_pty_attribute22
      ,p_pty_attribute23                =>  p_pty_attribute23
      ,p_pty_attribute24                =>  p_pty_attribute24
      ,p_pty_attribute25                =>  p_pty_attribute25
      ,p_pty_attribute26                =>  p_pty_attribute26
      ,p_pty_attribute27                =>  p_pty_attribute27
      ,p_pty_attribute28                =>  p_pty_attribute28
      ,p_pty_attribute29                =>  p_pty_attribute29
      ,p_pty_attribute30                =>  p_pty_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_pl_care_prvdr_typ'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_pl_care_prvdr_typ
    --
  end;
  --
  ben_pty_upd.upd
    (
     p_pl_pcp_typ_id                 => p_pl_pcp_typ_id
    ,p_pl_pcp_id                     => p_pl_pcp_id
    ,p_business_group_id             => p_business_group_id
    ,p_pcp_typ_cd                    => p_pcp_typ_cd
    ,p_min_age                       => p_min_age
    ,p_max_age                       => p_max_age
    ,p_gndr_alwd_cd                  => p_gndr_alwd_cd
    ,p_pty_attribute_category        => p_pty_attribute_category
    ,p_pty_attribute1                => p_pty_attribute1
    ,p_pty_attribute2                => p_pty_attribute2
    ,p_pty_attribute3                => p_pty_attribute3
    ,p_pty_attribute4                => p_pty_attribute4
    ,p_pty_attribute5                => p_pty_attribute5
    ,p_pty_attribute6                => p_pty_attribute6
    ,p_pty_attribute7                => p_pty_attribute7
    ,p_pty_attribute8                => p_pty_attribute8
    ,p_pty_attribute9                => p_pty_attribute9
    ,p_pty_attribute10               => p_pty_attribute10
    ,p_pty_attribute11               => p_pty_attribute11
    ,p_pty_attribute12               => p_pty_attribute12
    ,p_pty_attribute13               => p_pty_attribute13
    ,p_pty_attribute14               => p_pty_attribute14
    ,p_pty_attribute15               => p_pty_attribute15
    ,p_pty_attribute16               => p_pty_attribute16
    ,p_pty_attribute17               => p_pty_attribute17
    ,p_pty_attribute18               => p_pty_attribute18
    ,p_pty_attribute19               => p_pty_attribute19
    ,p_pty_attribute20               => p_pty_attribute20
    ,p_pty_attribute21               => p_pty_attribute21
    ,p_pty_attribute22               => p_pty_attribute22
    ,p_pty_attribute23               => p_pty_attribute23
    ,p_pty_attribute24               => p_pty_attribute24
    ,p_pty_attribute25               => p_pty_attribute25
    ,p_pty_attribute26               => p_pty_attribute26
    ,p_pty_attribute27               => p_pty_attribute27
    ,p_pty_attribute28               => p_pty_attribute28
    ,p_pty_attribute29               => p_pty_attribute29
    ,p_pty_attribute30               => p_pty_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_pl_care_prvdr_typ
    --
    ben_pl_care_prvdr_typ_bk2.update_pl_care_prvdr_typ_a
      (
       p_pl_pcp_typ_id                  =>  p_pl_pcp_typ_id
      ,p_pl_pcp_id                      =>  p_pl_pcp_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pcp_typ_cd                     =>  p_pcp_typ_cd
      ,p_min_age                        =>  p_min_age
      ,p_max_age                        =>  p_max_age
      ,p_gndr_alwd_cd                   =>  p_gndr_alwd_cd
      ,p_pty_attribute_category         =>  p_pty_attribute_category
      ,p_pty_attribute1                 =>  p_pty_attribute1
      ,p_pty_attribute2                 =>  p_pty_attribute2
      ,p_pty_attribute3                 =>  p_pty_attribute3
      ,p_pty_attribute4                 =>  p_pty_attribute4
      ,p_pty_attribute5                 =>  p_pty_attribute5
      ,p_pty_attribute6                 =>  p_pty_attribute6
      ,p_pty_attribute7                 =>  p_pty_attribute7
      ,p_pty_attribute8                 =>  p_pty_attribute8
      ,p_pty_attribute9                 =>  p_pty_attribute9
      ,p_pty_attribute10                =>  p_pty_attribute10
      ,p_pty_attribute11                =>  p_pty_attribute11
      ,p_pty_attribute12                =>  p_pty_attribute12
      ,p_pty_attribute13                =>  p_pty_attribute13
      ,p_pty_attribute14                =>  p_pty_attribute14
      ,p_pty_attribute15                =>  p_pty_attribute15
      ,p_pty_attribute16                =>  p_pty_attribute16
      ,p_pty_attribute17                =>  p_pty_attribute17
      ,p_pty_attribute18                =>  p_pty_attribute18
      ,p_pty_attribute19                =>  p_pty_attribute19
      ,p_pty_attribute20                =>  p_pty_attribute20
      ,p_pty_attribute21                =>  p_pty_attribute21
      ,p_pty_attribute22                =>  p_pty_attribute22
      ,p_pty_attribute23                =>  p_pty_attribute23
      ,p_pty_attribute24                =>  p_pty_attribute24
      ,p_pty_attribute25                =>  p_pty_attribute25
      ,p_pty_attribute26                =>  p_pty_attribute26
      ,p_pty_attribute27                =>  p_pty_attribute27
      ,p_pty_attribute28                =>  p_pty_attribute28
      ,p_pty_attribute29                =>  p_pty_attribute29
      ,p_pty_attribute30                =>  p_pty_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_pl_care_prvdr_typ'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_pl_care_prvdr_typ
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
    ROLLBACK TO update_pl_care_prvdr_typ;
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
    ROLLBACK TO update_pl_care_prvdr_typ;
    raise;
    --
end update_pl_care_prvdr_typ;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_pl_care_prvdr_typ >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pl_care_prvdr_typ
  (p_validate                       in  boolean  default false
  ,p_pl_pcp_typ_id                  in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_pl_care_prvdr_typ';
  l_object_version_number ben_pl_pcp_typ.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_pl_care_prvdr_typ;
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
    -- Start of API User Hook for the before hook of delete_pl_care_prvdr_typ
    --
    ben_pl_care_prvdr_typ_bk3.delete_pl_care_prvdr_typ_b
      (
       p_pl_pcp_typ_id                  =>  p_pl_pcp_typ_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_pl_care_prvdr_typ'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_pl_care_prvdr_typ
    --
  end;
  --
  ben_pty_del.del
    (
     p_pl_pcp_typ_id                 => p_pl_pcp_typ_id
    ,p_object_version_number         => l_object_version_number
   -- ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_pl_care_prvdr_typ
    --
    ben_pl_care_prvdr_typ_bk3.delete_pl_care_prvdr_typ_a
      (
       p_pl_pcp_typ_id                  =>  p_pl_pcp_typ_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_pl_care_prvdr_typ'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_pl_care_prvdr_typ
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
    ROLLBACK TO delete_pl_care_prvdr_typ;
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
    ROLLBACK TO delete_pl_care_prvdr_typ;
    raise;
    --
end delete_pl_care_prvdr_typ;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_pl_pcp_typ_id                   in     number
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
  ben_pty_shd.lck
    (
      p_pl_pcp_typ_id                 => p_pl_pcp_typ_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_pl_care_prvdr_typ_api;

/
