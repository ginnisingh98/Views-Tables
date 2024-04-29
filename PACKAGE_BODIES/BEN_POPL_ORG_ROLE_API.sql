--------------------------------------------------------
--  DDL for Package Body BEN_POPL_ORG_ROLE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_POPL_ORG_ROLE_API" as
/* $Header: becprapi.pkb 115.5 2002/12/13 06:53:51 hmani ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_POPL_ORG_ROLE_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_POPL_ORG_ROLE >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_POPL_ORG_ROLE
  (p_validate                       in  boolean   default false
  ,p_popl_org_role_id               out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default null
  ,p_org_role_typ_cd                in  varchar2  default null
  ,p_popl_org_id                    in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_cpr_attribute_category         in  varchar2  default null
  ,p_cpr_attribute1                 in  varchar2  default null
  ,p_cpr_attribute2                 in  varchar2  default null
  ,p_cpr_attribute3                 in  varchar2  default null
  ,p_cpr_attribute4                 in  varchar2  default null
  ,p_cpr_attribute5                 in  varchar2  default null
  ,p_cpr_attribute6                 in  varchar2  default null
  ,p_cpr_attribute7                 in  varchar2  default null
  ,p_cpr_attribute8                 in  varchar2  default null
  ,p_cpr_attribute9                 in  varchar2  default null
  ,p_cpr_attribute10                in  varchar2  default null
  ,p_cpr_attribute11                in  varchar2  default null
  ,p_cpr_attribute12                in  varchar2  default null
  ,p_cpr_attribute13                in  varchar2  default null
  ,p_cpr_attribute14                in  varchar2  default null
  ,p_cpr_attribute15                in  varchar2  default null
  ,p_cpr_attribute16                in  varchar2  default null
  ,p_cpr_attribute17                in  varchar2  default null
  ,p_cpr_attribute18                in  varchar2  default null
  ,p_cpr_attribute19                in  varchar2  default null
  ,p_cpr_attribute20                in  varchar2  default null
  ,p_cpr_attribute21                in  varchar2  default null
  ,p_cpr_attribute22                in  varchar2  default null
  ,p_cpr_attribute23                in  varchar2  default null
  ,p_cpr_attribute24                in  varchar2  default null
  ,p_cpr_attribute25                in  varchar2  default null
  ,p_cpr_attribute26                in  varchar2  default null
  ,p_cpr_attribute27                in  varchar2  default null
  ,p_cpr_attribute28                in  varchar2  default null
  ,p_cpr_attribute29                in  varchar2  default null
  ,p_cpr_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_popl_org_role_id ben_popl_org_role_f.popl_org_role_id%TYPE;
  l_effective_start_date ben_popl_org_role_f.effective_start_date%TYPE;
  l_effective_end_date ben_popl_org_role_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_POPL_ORG_ROLE';
  l_object_version_number ben_popl_org_role_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_POPL_ORG_ROLE;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_POPL_ORG_ROLE
    --
    ben_POPL_ORG_ROLE_bk1.create_POPL_ORG_ROLE_b
      (
       p_name                           =>  p_name
      ,p_org_role_typ_cd                =>  p_org_role_typ_cd
      ,p_popl_org_id                    =>  p_popl_org_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_cpr_attribute_category         =>  p_cpr_attribute_category
      ,p_cpr_attribute1                 =>  p_cpr_attribute1
      ,p_cpr_attribute2                 =>  p_cpr_attribute2
      ,p_cpr_attribute3                 =>  p_cpr_attribute3
      ,p_cpr_attribute4                 =>  p_cpr_attribute4
      ,p_cpr_attribute5                 =>  p_cpr_attribute5
      ,p_cpr_attribute6                 =>  p_cpr_attribute6
      ,p_cpr_attribute7                 =>  p_cpr_attribute7
      ,p_cpr_attribute8                 =>  p_cpr_attribute8
      ,p_cpr_attribute9                 =>  p_cpr_attribute9
      ,p_cpr_attribute10                =>  p_cpr_attribute10
      ,p_cpr_attribute11                =>  p_cpr_attribute11
      ,p_cpr_attribute12                =>  p_cpr_attribute12
      ,p_cpr_attribute13                =>  p_cpr_attribute13
      ,p_cpr_attribute14                =>  p_cpr_attribute14
      ,p_cpr_attribute15                =>  p_cpr_attribute15
      ,p_cpr_attribute16                =>  p_cpr_attribute16
      ,p_cpr_attribute17                =>  p_cpr_attribute17
      ,p_cpr_attribute18                =>  p_cpr_attribute18
      ,p_cpr_attribute19                =>  p_cpr_attribute19
      ,p_cpr_attribute20                =>  p_cpr_attribute20
      ,p_cpr_attribute21                =>  p_cpr_attribute21
      ,p_cpr_attribute22                =>  p_cpr_attribute22
      ,p_cpr_attribute23                =>  p_cpr_attribute23
      ,p_cpr_attribute24                =>  p_cpr_attribute24
      ,p_cpr_attribute25                =>  p_cpr_attribute25
      ,p_cpr_attribute26                =>  p_cpr_attribute26
      ,p_cpr_attribute27                =>  p_cpr_attribute27
      ,p_cpr_attribute28                =>  p_cpr_attribute28
      ,p_cpr_attribute29                =>  p_cpr_attribute29
      ,p_cpr_attribute30                =>  p_cpr_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_POPL_ORG_ROLE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_POPL_ORG_ROLE
    --
  end;
  --
  ben_cpr_ins.ins
    (
     p_popl_org_role_id              => l_popl_org_role_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_name                          => p_name
    ,p_org_role_typ_cd               => p_org_role_typ_cd
    ,p_popl_org_id                   => p_popl_org_id
    ,p_business_group_id             => p_business_group_id
    ,p_cpr_attribute_category        => p_cpr_attribute_category
    ,p_cpr_attribute1                => p_cpr_attribute1
    ,p_cpr_attribute2                => p_cpr_attribute2
    ,p_cpr_attribute3                => p_cpr_attribute3
    ,p_cpr_attribute4                => p_cpr_attribute4
    ,p_cpr_attribute5                => p_cpr_attribute5
    ,p_cpr_attribute6                => p_cpr_attribute6
    ,p_cpr_attribute7                => p_cpr_attribute7
    ,p_cpr_attribute8                => p_cpr_attribute8
    ,p_cpr_attribute9                => p_cpr_attribute9
    ,p_cpr_attribute10               => p_cpr_attribute10
    ,p_cpr_attribute11               => p_cpr_attribute11
    ,p_cpr_attribute12               => p_cpr_attribute12
    ,p_cpr_attribute13               => p_cpr_attribute13
    ,p_cpr_attribute14               => p_cpr_attribute14
    ,p_cpr_attribute15               => p_cpr_attribute15
    ,p_cpr_attribute16               => p_cpr_attribute16
    ,p_cpr_attribute17               => p_cpr_attribute17
    ,p_cpr_attribute18               => p_cpr_attribute18
    ,p_cpr_attribute19               => p_cpr_attribute19
    ,p_cpr_attribute20               => p_cpr_attribute20
    ,p_cpr_attribute21               => p_cpr_attribute21
    ,p_cpr_attribute22               => p_cpr_attribute22
    ,p_cpr_attribute23               => p_cpr_attribute23
    ,p_cpr_attribute24               => p_cpr_attribute24
    ,p_cpr_attribute25               => p_cpr_attribute25
    ,p_cpr_attribute26               => p_cpr_attribute26
    ,p_cpr_attribute27               => p_cpr_attribute27
    ,p_cpr_attribute28               => p_cpr_attribute28
    ,p_cpr_attribute29               => p_cpr_attribute29
    ,p_cpr_attribute30               => p_cpr_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_POPL_ORG_ROLE
    --
    ben_POPL_ORG_ROLE_bk1.create_POPL_ORG_ROLE_a
      (
       p_popl_org_role_id               =>  l_popl_org_role_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_name                           =>  p_name
      ,p_org_role_typ_cd                =>  p_org_role_typ_cd
      ,p_popl_org_id                    =>  p_popl_org_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_cpr_attribute_category         =>  p_cpr_attribute_category
      ,p_cpr_attribute1                 =>  p_cpr_attribute1
      ,p_cpr_attribute2                 =>  p_cpr_attribute2
      ,p_cpr_attribute3                 =>  p_cpr_attribute3
      ,p_cpr_attribute4                 =>  p_cpr_attribute4
      ,p_cpr_attribute5                 =>  p_cpr_attribute5
      ,p_cpr_attribute6                 =>  p_cpr_attribute6
      ,p_cpr_attribute7                 =>  p_cpr_attribute7
      ,p_cpr_attribute8                 =>  p_cpr_attribute8
      ,p_cpr_attribute9                 =>  p_cpr_attribute9
      ,p_cpr_attribute10                =>  p_cpr_attribute10
      ,p_cpr_attribute11                =>  p_cpr_attribute11
      ,p_cpr_attribute12                =>  p_cpr_attribute12
      ,p_cpr_attribute13                =>  p_cpr_attribute13
      ,p_cpr_attribute14                =>  p_cpr_attribute14
      ,p_cpr_attribute15                =>  p_cpr_attribute15
      ,p_cpr_attribute16                =>  p_cpr_attribute16
      ,p_cpr_attribute17                =>  p_cpr_attribute17
      ,p_cpr_attribute18                =>  p_cpr_attribute18
      ,p_cpr_attribute19                =>  p_cpr_attribute19
      ,p_cpr_attribute20                =>  p_cpr_attribute20
      ,p_cpr_attribute21                =>  p_cpr_attribute21
      ,p_cpr_attribute22                =>  p_cpr_attribute22
      ,p_cpr_attribute23                =>  p_cpr_attribute23
      ,p_cpr_attribute24                =>  p_cpr_attribute24
      ,p_cpr_attribute25                =>  p_cpr_attribute25
      ,p_cpr_attribute26                =>  p_cpr_attribute26
      ,p_cpr_attribute27                =>  p_cpr_attribute27
      ,p_cpr_attribute28                =>  p_cpr_attribute28
      ,p_cpr_attribute29                =>  p_cpr_attribute29
      ,p_cpr_attribute30                =>  p_cpr_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_POPL_ORG_ROLE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_POPL_ORG_ROLE
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
  p_popl_org_role_id := l_popl_org_role_id;
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
    ROLLBACK TO create_POPL_ORG_ROLE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_popl_org_role_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_POPL_ORG_ROLE;
    raise;
    --
end create_POPL_ORG_ROLE;
-- ----------------------------------------------------------------------------
-- |------------------------< update_POPL_ORG_ROLE >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_POPL_ORG_ROLE
  (p_validate                       in  boolean   default false
  ,p_popl_org_role_id               in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_org_role_typ_cd                in  varchar2   default hr_api.g_varchar2
  ,p_popl_org_id                    in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_cpr_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_cpr_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_cpr_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_cpr_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_cpr_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_cpr_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_cpr_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_cpr_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_cpr_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_cpr_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_cpr_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_cpr_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_cpr_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_cpr_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_cpr_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_cpr_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_cpr_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_cpr_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_cpr_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_cpr_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_cpr_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_cpr_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_cpr_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_cpr_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_cpr_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_cpr_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_cpr_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_cpr_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_cpr_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_cpr_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_cpr_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_POPL_ORG_ROLE';
  l_object_version_number ben_popl_org_role_f.object_version_number%TYPE;
  l_effective_start_date ben_popl_org_role_f.effective_start_date%TYPE;
  l_effective_end_date ben_popl_org_role_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_POPL_ORG_ROLE;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_POPL_ORG_ROLE
    --
    ben_POPL_ORG_ROLE_bk2.update_POPL_ORG_ROLE_b
      (
       p_popl_org_role_id               =>  p_popl_org_role_id
      ,p_name                           =>  p_name
      ,p_org_role_typ_cd                =>  p_org_role_typ_cd
      ,p_popl_org_id                    =>  p_popl_org_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_cpr_attribute_category         =>  p_cpr_attribute_category
      ,p_cpr_attribute1                 =>  p_cpr_attribute1
      ,p_cpr_attribute2                 =>  p_cpr_attribute2
      ,p_cpr_attribute3                 =>  p_cpr_attribute3
      ,p_cpr_attribute4                 =>  p_cpr_attribute4
      ,p_cpr_attribute5                 =>  p_cpr_attribute5
      ,p_cpr_attribute6                 =>  p_cpr_attribute6
      ,p_cpr_attribute7                 =>  p_cpr_attribute7
      ,p_cpr_attribute8                 =>  p_cpr_attribute8
      ,p_cpr_attribute9                 =>  p_cpr_attribute9
      ,p_cpr_attribute10                =>  p_cpr_attribute10
      ,p_cpr_attribute11                =>  p_cpr_attribute11
      ,p_cpr_attribute12                =>  p_cpr_attribute12
      ,p_cpr_attribute13                =>  p_cpr_attribute13
      ,p_cpr_attribute14                =>  p_cpr_attribute14
      ,p_cpr_attribute15                =>  p_cpr_attribute15
      ,p_cpr_attribute16                =>  p_cpr_attribute16
      ,p_cpr_attribute17                =>  p_cpr_attribute17
      ,p_cpr_attribute18                =>  p_cpr_attribute18
      ,p_cpr_attribute19                =>  p_cpr_attribute19
      ,p_cpr_attribute20                =>  p_cpr_attribute20
      ,p_cpr_attribute21                =>  p_cpr_attribute21
      ,p_cpr_attribute22                =>  p_cpr_attribute22
      ,p_cpr_attribute23                =>  p_cpr_attribute23
      ,p_cpr_attribute24                =>  p_cpr_attribute24
      ,p_cpr_attribute25                =>  p_cpr_attribute25
      ,p_cpr_attribute26                =>  p_cpr_attribute26
      ,p_cpr_attribute27                =>  p_cpr_attribute27
      ,p_cpr_attribute28                =>  p_cpr_attribute28
      ,p_cpr_attribute29                =>  p_cpr_attribute29
      ,p_cpr_attribute30                =>  p_cpr_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_POPL_ORG_ROLE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_POPL_ORG_ROLE
    --
  end;
  --
  ben_cpr_upd.upd
    (
     p_popl_org_role_id              => p_popl_org_role_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_name                          => p_name
    ,p_org_role_typ_cd               => p_org_role_typ_cd
    ,p_popl_org_id                   => p_popl_org_id
    ,p_business_group_id             => p_business_group_id
    ,p_cpr_attribute_category        => p_cpr_attribute_category
    ,p_cpr_attribute1                => p_cpr_attribute1
    ,p_cpr_attribute2                => p_cpr_attribute2
    ,p_cpr_attribute3                => p_cpr_attribute3
    ,p_cpr_attribute4                => p_cpr_attribute4
    ,p_cpr_attribute5                => p_cpr_attribute5
    ,p_cpr_attribute6                => p_cpr_attribute6
    ,p_cpr_attribute7                => p_cpr_attribute7
    ,p_cpr_attribute8                => p_cpr_attribute8
    ,p_cpr_attribute9                => p_cpr_attribute9
    ,p_cpr_attribute10               => p_cpr_attribute10
    ,p_cpr_attribute11               => p_cpr_attribute11
    ,p_cpr_attribute12               => p_cpr_attribute12
    ,p_cpr_attribute13               => p_cpr_attribute13
    ,p_cpr_attribute14               => p_cpr_attribute14
    ,p_cpr_attribute15               => p_cpr_attribute15
    ,p_cpr_attribute16               => p_cpr_attribute16
    ,p_cpr_attribute17               => p_cpr_attribute17
    ,p_cpr_attribute18               => p_cpr_attribute18
    ,p_cpr_attribute19               => p_cpr_attribute19
    ,p_cpr_attribute20               => p_cpr_attribute20
    ,p_cpr_attribute21               => p_cpr_attribute21
    ,p_cpr_attribute22               => p_cpr_attribute22
    ,p_cpr_attribute23               => p_cpr_attribute23
    ,p_cpr_attribute24               => p_cpr_attribute24
    ,p_cpr_attribute25               => p_cpr_attribute25
    ,p_cpr_attribute26               => p_cpr_attribute26
    ,p_cpr_attribute27               => p_cpr_attribute27
    ,p_cpr_attribute28               => p_cpr_attribute28
    ,p_cpr_attribute29               => p_cpr_attribute29
    ,p_cpr_attribute30               => p_cpr_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_POPL_ORG_ROLE
    --
    ben_POPL_ORG_ROLE_bk2.update_POPL_ORG_ROLE_a
      (
       p_popl_org_role_id               =>  p_popl_org_role_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_name                           =>  p_name
      ,p_org_role_typ_cd                =>  p_org_role_typ_cd
      ,p_popl_org_id                    =>  p_popl_org_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_cpr_attribute_category         =>  p_cpr_attribute_category
      ,p_cpr_attribute1                 =>  p_cpr_attribute1
      ,p_cpr_attribute2                 =>  p_cpr_attribute2
      ,p_cpr_attribute3                 =>  p_cpr_attribute3
      ,p_cpr_attribute4                 =>  p_cpr_attribute4
      ,p_cpr_attribute5                 =>  p_cpr_attribute5
      ,p_cpr_attribute6                 =>  p_cpr_attribute6
      ,p_cpr_attribute7                 =>  p_cpr_attribute7
      ,p_cpr_attribute8                 =>  p_cpr_attribute8
      ,p_cpr_attribute9                 =>  p_cpr_attribute9
      ,p_cpr_attribute10                =>  p_cpr_attribute10
      ,p_cpr_attribute11                =>  p_cpr_attribute11
      ,p_cpr_attribute12                =>  p_cpr_attribute12
      ,p_cpr_attribute13                =>  p_cpr_attribute13
      ,p_cpr_attribute14                =>  p_cpr_attribute14
      ,p_cpr_attribute15                =>  p_cpr_attribute15
      ,p_cpr_attribute16                =>  p_cpr_attribute16
      ,p_cpr_attribute17                =>  p_cpr_attribute17
      ,p_cpr_attribute18                =>  p_cpr_attribute18
      ,p_cpr_attribute19                =>  p_cpr_attribute19
      ,p_cpr_attribute20                =>  p_cpr_attribute20
      ,p_cpr_attribute21                =>  p_cpr_attribute21
      ,p_cpr_attribute22                =>  p_cpr_attribute22
      ,p_cpr_attribute23                =>  p_cpr_attribute23
      ,p_cpr_attribute24                =>  p_cpr_attribute24
      ,p_cpr_attribute25                =>  p_cpr_attribute25
      ,p_cpr_attribute26                =>  p_cpr_attribute26
      ,p_cpr_attribute27                =>  p_cpr_attribute27
      ,p_cpr_attribute28                =>  p_cpr_attribute28
      ,p_cpr_attribute29                =>  p_cpr_attribute29
      ,p_cpr_attribute30                =>  p_cpr_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_POPL_ORG_ROLE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_POPL_ORG_ROLE
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
    ROLLBACK TO update_POPL_ORG_ROLE;
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
    ROLLBACK TO update_POPL_ORG_ROLE;
    raise;
    --
end update_POPL_ORG_ROLE;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_POPL_ORG_ROLE >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_POPL_ORG_ROLE
  (p_validate                       in  boolean  default false
  ,p_popl_org_role_id               in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_POPL_ORG_ROLE';
  l_object_version_number ben_popl_org_role_f.object_version_number%TYPE;
  l_effective_start_date ben_popl_org_role_f.effective_start_date%TYPE;
  l_effective_end_date ben_popl_org_role_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_POPL_ORG_ROLE;
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
    -- Start of API User Hook for the before hook of delete_POPL_ORG_ROLE
    --
    ben_POPL_ORG_ROLE_bk3.delete_POPL_ORG_ROLE_b
      (
       p_popl_org_role_id               =>  p_popl_org_role_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_POPL_ORG_ROLE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_POPL_ORG_ROLE
    --
  end;
  --
  ben_cpr_del.del
    (
     p_popl_org_role_id              => p_popl_org_role_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_POPL_ORG_ROLE
    --
    ben_POPL_ORG_ROLE_bk3.delete_POPL_ORG_ROLE_a
      (
       p_popl_org_role_id               =>  p_popl_org_role_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_POPL_ORG_ROLE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_POPL_ORG_ROLE
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
    ROLLBACK TO delete_POPL_ORG_ROLE;
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
    ROLLBACK TO delete_POPL_ORG_ROLE;
    raise;
    --
end delete_POPL_ORG_ROLE;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_popl_org_role_id                   in     number
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
  ben_cpr_shd.lck
    (
      p_popl_org_role_id                 => p_popl_org_role_id
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
end ben_POPL_ORG_ROLE_api;

/
