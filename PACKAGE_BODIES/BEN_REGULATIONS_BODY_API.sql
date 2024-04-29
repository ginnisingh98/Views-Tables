--------------------------------------------------------
--  DDL for Package Body BEN_REGULATIONS_BODY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_REGULATIONS_BODY_API" as
/* $Header: berrbapi.pkb 115.3 2002/12/16 09:37:29 hnarayan ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_regulations_body_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_regulations_body >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_regulations_body
  (p_validate                       in  boolean   default false
  ,p_regn_for_regy_body_id          out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_regn_admin_cd                  in  varchar2  default null
  ,p_regn_id                        in  number    default null
  ,p_organization_id                in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_rrb_attribute_category         in  varchar2  default null
  ,p_rrb_attribute1                 in  varchar2  default null
  ,p_rrb_attribute2                 in  varchar2  default null
  ,p_rrb_attribute3                 in  varchar2  default null
  ,p_rrb_attribute4                 in  varchar2  default null
  ,p_rrb_attribute5                 in  varchar2  default null
  ,p_rrb_attribute6                 in  varchar2  default null
  ,p_rrb_attribute7                 in  varchar2  default null
  ,p_rrb_attribute8                 in  varchar2  default null
  ,p_rrb_attribute9                 in  varchar2  default null
  ,p_rrb_attribute10                in  varchar2  default null
  ,p_rrb_attribute11                in  varchar2  default null
  ,p_rrb_attribute12                in  varchar2  default null
  ,p_rrb_attribute13                in  varchar2  default null
  ,p_rrb_attribute14                in  varchar2  default null
  ,p_rrb_attribute15                in  varchar2  default null
  ,p_rrb_attribute16                in  varchar2  default null
  ,p_rrb_attribute17                in  varchar2  default null
  ,p_rrb_attribute18                in  varchar2  default null
  ,p_rrb_attribute19                in  varchar2  default null
  ,p_rrb_attribute20                in  varchar2  default null
  ,p_rrb_attribute21                in  varchar2  default null
  ,p_rrb_attribute22                in  varchar2  default null
  ,p_rrb_attribute23                in  varchar2  default null
  ,p_rrb_attribute24                in  varchar2  default null
  ,p_rrb_attribute25                in  varchar2  default null
  ,p_rrb_attribute26                in  varchar2  default null
  ,p_rrb_attribute27                in  varchar2  default null
  ,p_rrb_attribute28                in  varchar2  default null
  ,p_rrb_attribute29                in  varchar2  default null
  ,p_rrb_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_regn_for_regy_body_id ben_regn_for_regy_body_f.regn_for_regy_body_id%TYPE;
  l_effective_start_date ben_regn_for_regy_body_f.effective_start_date%TYPE;
  l_effective_end_date ben_regn_for_regy_body_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_regulations_body';
  l_object_version_number ben_regn_for_regy_body_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_regulations_body;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_regulations_body
    --
    ben_regulations_body_bk1.create_regulations_body_b
      (
       p_regn_admin_cd                  =>  p_regn_admin_cd
      ,p_regn_id                        =>  p_regn_id
      ,p_organization_id                =>  p_organization_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_rrb_attribute_category         =>  p_rrb_attribute_category
      ,p_rrb_attribute1                 =>  p_rrb_attribute1
      ,p_rrb_attribute2                 =>  p_rrb_attribute2
      ,p_rrb_attribute3                 =>  p_rrb_attribute3
      ,p_rrb_attribute4                 =>  p_rrb_attribute4
      ,p_rrb_attribute5                 =>  p_rrb_attribute5
      ,p_rrb_attribute6                 =>  p_rrb_attribute6
      ,p_rrb_attribute7                 =>  p_rrb_attribute7
      ,p_rrb_attribute8                 =>  p_rrb_attribute8
      ,p_rrb_attribute9                 =>  p_rrb_attribute9
      ,p_rrb_attribute10                =>  p_rrb_attribute10
      ,p_rrb_attribute11                =>  p_rrb_attribute11
      ,p_rrb_attribute12                =>  p_rrb_attribute12
      ,p_rrb_attribute13                =>  p_rrb_attribute13
      ,p_rrb_attribute14                =>  p_rrb_attribute14
      ,p_rrb_attribute15                =>  p_rrb_attribute15
      ,p_rrb_attribute16                =>  p_rrb_attribute16
      ,p_rrb_attribute17                =>  p_rrb_attribute17
      ,p_rrb_attribute18                =>  p_rrb_attribute18
      ,p_rrb_attribute19                =>  p_rrb_attribute19
      ,p_rrb_attribute20                =>  p_rrb_attribute20
      ,p_rrb_attribute21                =>  p_rrb_attribute21
      ,p_rrb_attribute22                =>  p_rrb_attribute22
      ,p_rrb_attribute23                =>  p_rrb_attribute23
      ,p_rrb_attribute24                =>  p_rrb_attribute24
      ,p_rrb_attribute25                =>  p_rrb_attribute25
      ,p_rrb_attribute26                =>  p_rrb_attribute26
      ,p_rrb_attribute27                =>  p_rrb_attribute27
      ,p_rrb_attribute28                =>  p_rrb_attribute28
      ,p_rrb_attribute29                =>  p_rrb_attribute29
      ,p_rrb_attribute30                =>  p_rrb_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_regulations_body'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_regulations_body
    --
  end;
  --
  ben_rrb_ins.ins
    (
     p_regn_for_regy_body_id         => l_regn_for_regy_body_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_regn_admin_cd                 => p_regn_admin_cd
    ,p_regn_id                       => p_regn_id
    ,p_organization_id               => p_organization_id
    ,p_business_group_id             => p_business_group_id
    ,p_rrb_attribute_category        => p_rrb_attribute_category
    ,p_rrb_attribute1                => p_rrb_attribute1
    ,p_rrb_attribute2                => p_rrb_attribute2
    ,p_rrb_attribute3                => p_rrb_attribute3
    ,p_rrb_attribute4                => p_rrb_attribute4
    ,p_rrb_attribute5                => p_rrb_attribute5
    ,p_rrb_attribute6                => p_rrb_attribute6
    ,p_rrb_attribute7                => p_rrb_attribute7
    ,p_rrb_attribute8                => p_rrb_attribute8
    ,p_rrb_attribute9                => p_rrb_attribute9
    ,p_rrb_attribute10               => p_rrb_attribute10
    ,p_rrb_attribute11               => p_rrb_attribute11
    ,p_rrb_attribute12               => p_rrb_attribute12
    ,p_rrb_attribute13               => p_rrb_attribute13
    ,p_rrb_attribute14               => p_rrb_attribute14
    ,p_rrb_attribute15               => p_rrb_attribute15
    ,p_rrb_attribute16               => p_rrb_attribute16
    ,p_rrb_attribute17               => p_rrb_attribute17
    ,p_rrb_attribute18               => p_rrb_attribute18
    ,p_rrb_attribute19               => p_rrb_attribute19
    ,p_rrb_attribute20               => p_rrb_attribute20
    ,p_rrb_attribute21               => p_rrb_attribute21
    ,p_rrb_attribute22               => p_rrb_attribute22
    ,p_rrb_attribute23               => p_rrb_attribute23
    ,p_rrb_attribute24               => p_rrb_attribute24
    ,p_rrb_attribute25               => p_rrb_attribute25
    ,p_rrb_attribute26               => p_rrb_attribute26
    ,p_rrb_attribute27               => p_rrb_attribute27
    ,p_rrb_attribute28               => p_rrb_attribute28
    ,p_rrb_attribute29               => p_rrb_attribute29
    ,p_rrb_attribute30               => p_rrb_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_regulations_body
    --
    ben_regulations_body_bk1.create_regulations_body_a
      (
       p_regn_for_regy_body_id          =>  l_regn_for_regy_body_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_regn_admin_cd                  =>  p_regn_admin_cd
      ,p_regn_id                        =>  p_regn_id
      ,p_organization_id                =>  p_organization_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_rrb_attribute_category         =>  p_rrb_attribute_category
      ,p_rrb_attribute1                 =>  p_rrb_attribute1
      ,p_rrb_attribute2                 =>  p_rrb_attribute2
      ,p_rrb_attribute3                 =>  p_rrb_attribute3
      ,p_rrb_attribute4                 =>  p_rrb_attribute4
      ,p_rrb_attribute5                 =>  p_rrb_attribute5
      ,p_rrb_attribute6                 =>  p_rrb_attribute6
      ,p_rrb_attribute7                 =>  p_rrb_attribute7
      ,p_rrb_attribute8                 =>  p_rrb_attribute8
      ,p_rrb_attribute9                 =>  p_rrb_attribute9
      ,p_rrb_attribute10                =>  p_rrb_attribute10
      ,p_rrb_attribute11                =>  p_rrb_attribute11
      ,p_rrb_attribute12                =>  p_rrb_attribute12
      ,p_rrb_attribute13                =>  p_rrb_attribute13
      ,p_rrb_attribute14                =>  p_rrb_attribute14
      ,p_rrb_attribute15                =>  p_rrb_attribute15
      ,p_rrb_attribute16                =>  p_rrb_attribute16
      ,p_rrb_attribute17                =>  p_rrb_attribute17
      ,p_rrb_attribute18                =>  p_rrb_attribute18
      ,p_rrb_attribute19                =>  p_rrb_attribute19
      ,p_rrb_attribute20                =>  p_rrb_attribute20
      ,p_rrb_attribute21                =>  p_rrb_attribute21
      ,p_rrb_attribute22                =>  p_rrb_attribute22
      ,p_rrb_attribute23                =>  p_rrb_attribute23
      ,p_rrb_attribute24                =>  p_rrb_attribute24
      ,p_rrb_attribute25                =>  p_rrb_attribute25
      ,p_rrb_attribute26                =>  p_rrb_attribute26
      ,p_rrb_attribute27                =>  p_rrb_attribute27
      ,p_rrb_attribute28                =>  p_rrb_attribute28
      ,p_rrb_attribute29                =>  p_rrb_attribute29
      ,p_rrb_attribute30                =>  p_rrb_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_regulations_body'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_regulations_body
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
  p_regn_for_regy_body_id := l_regn_for_regy_body_id;
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
    ROLLBACK TO create_regulations_body;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_regn_for_regy_body_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_regulations_body;
    p_regn_for_regy_body_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    raise;
    --
end create_regulations_body;
-- ----------------------------------------------------------------------------
-- |------------------------< update_regulations_body >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_regulations_body
  (p_validate                       in  boolean   default false
  ,p_regn_for_regy_body_id          in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_regn_admin_cd                  in  varchar2  default hr_api.g_varchar2
  ,p_regn_id                        in  number    default hr_api.g_number
  ,p_organization_id                in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_rrb_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_rrb_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_rrb_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_rrb_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_rrb_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_rrb_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_rrb_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_rrb_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_rrb_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_rrb_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_rrb_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_rrb_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_rrb_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_rrb_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_rrb_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_rrb_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_rrb_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_rrb_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_rrb_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_rrb_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_rrb_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_rrb_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_rrb_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_rrb_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_rrb_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_rrb_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_rrb_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_rrb_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_rrb_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_rrb_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_rrb_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_regulations_body';
  l_object_version_number ben_regn_for_regy_body_f.object_version_number%TYPE;
  l_effective_start_date ben_regn_for_regy_body_f.effective_start_date%TYPE;
  l_effective_end_date ben_regn_for_regy_body_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_regulations_body;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_regulations_body
    --
    ben_regulations_body_bk2.update_regulations_body_b
      (
       p_regn_for_regy_body_id          =>  p_regn_for_regy_body_id
      ,p_regn_admin_cd                  =>  p_regn_admin_cd
      ,p_regn_id                        =>  p_regn_id
      ,p_organization_id                =>  p_organization_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_rrb_attribute_category         =>  p_rrb_attribute_category
      ,p_rrb_attribute1                 =>  p_rrb_attribute1
      ,p_rrb_attribute2                 =>  p_rrb_attribute2
      ,p_rrb_attribute3                 =>  p_rrb_attribute3
      ,p_rrb_attribute4                 =>  p_rrb_attribute4
      ,p_rrb_attribute5                 =>  p_rrb_attribute5
      ,p_rrb_attribute6                 =>  p_rrb_attribute6
      ,p_rrb_attribute7                 =>  p_rrb_attribute7
      ,p_rrb_attribute8                 =>  p_rrb_attribute8
      ,p_rrb_attribute9                 =>  p_rrb_attribute9
      ,p_rrb_attribute10                =>  p_rrb_attribute10
      ,p_rrb_attribute11                =>  p_rrb_attribute11
      ,p_rrb_attribute12                =>  p_rrb_attribute12
      ,p_rrb_attribute13                =>  p_rrb_attribute13
      ,p_rrb_attribute14                =>  p_rrb_attribute14
      ,p_rrb_attribute15                =>  p_rrb_attribute15
      ,p_rrb_attribute16                =>  p_rrb_attribute16
      ,p_rrb_attribute17                =>  p_rrb_attribute17
      ,p_rrb_attribute18                =>  p_rrb_attribute18
      ,p_rrb_attribute19                =>  p_rrb_attribute19
      ,p_rrb_attribute20                =>  p_rrb_attribute20
      ,p_rrb_attribute21                =>  p_rrb_attribute21
      ,p_rrb_attribute22                =>  p_rrb_attribute22
      ,p_rrb_attribute23                =>  p_rrb_attribute23
      ,p_rrb_attribute24                =>  p_rrb_attribute24
      ,p_rrb_attribute25                =>  p_rrb_attribute25
      ,p_rrb_attribute26                =>  p_rrb_attribute26
      ,p_rrb_attribute27                =>  p_rrb_attribute27
      ,p_rrb_attribute28                =>  p_rrb_attribute28
      ,p_rrb_attribute29                =>  p_rrb_attribute29
      ,p_rrb_attribute30                =>  p_rrb_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_regulations_body'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_regulations_body
    --
  end;
  --
  ben_rrb_upd.upd
    (
     p_regn_for_regy_body_id         => p_regn_for_regy_body_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_regn_admin_cd                 => p_regn_admin_cd
    ,p_regn_id                       => p_regn_id
    ,p_organization_id               => p_organization_id
    ,p_business_group_id             => p_business_group_id
    ,p_rrb_attribute_category        => p_rrb_attribute_category
    ,p_rrb_attribute1                => p_rrb_attribute1
    ,p_rrb_attribute2                => p_rrb_attribute2
    ,p_rrb_attribute3                => p_rrb_attribute3
    ,p_rrb_attribute4                => p_rrb_attribute4
    ,p_rrb_attribute5                => p_rrb_attribute5
    ,p_rrb_attribute6                => p_rrb_attribute6
    ,p_rrb_attribute7                => p_rrb_attribute7
    ,p_rrb_attribute8                => p_rrb_attribute8
    ,p_rrb_attribute9                => p_rrb_attribute9
    ,p_rrb_attribute10               => p_rrb_attribute10
    ,p_rrb_attribute11               => p_rrb_attribute11
    ,p_rrb_attribute12               => p_rrb_attribute12
    ,p_rrb_attribute13               => p_rrb_attribute13
    ,p_rrb_attribute14               => p_rrb_attribute14
    ,p_rrb_attribute15               => p_rrb_attribute15
    ,p_rrb_attribute16               => p_rrb_attribute16
    ,p_rrb_attribute17               => p_rrb_attribute17
    ,p_rrb_attribute18               => p_rrb_attribute18
    ,p_rrb_attribute19               => p_rrb_attribute19
    ,p_rrb_attribute20               => p_rrb_attribute20
    ,p_rrb_attribute21               => p_rrb_attribute21
    ,p_rrb_attribute22               => p_rrb_attribute22
    ,p_rrb_attribute23               => p_rrb_attribute23
    ,p_rrb_attribute24               => p_rrb_attribute24
    ,p_rrb_attribute25               => p_rrb_attribute25
    ,p_rrb_attribute26               => p_rrb_attribute26
    ,p_rrb_attribute27               => p_rrb_attribute27
    ,p_rrb_attribute28               => p_rrb_attribute28
    ,p_rrb_attribute29               => p_rrb_attribute29
    ,p_rrb_attribute30               => p_rrb_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_regulations_body
    --
    ben_regulations_body_bk2.update_regulations_body_a
      (
       p_regn_for_regy_body_id          =>  p_regn_for_regy_body_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_regn_admin_cd                  =>  p_regn_admin_cd
      ,p_regn_id                        =>  p_regn_id
      ,p_organization_id                =>  p_organization_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_rrb_attribute_category         =>  p_rrb_attribute_category
      ,p_rrb_attribute1                 =>  p_rrb_attribute1
      ,p_rrb_attribute2                 =>  p_rrb_attribute2
      ,p_rrb_attribute3                 =>  p_rrb_attribute3
      ,p_rrb_attribute4                 =>  p_rrb_attribute4
      ,p_rrb_attribute5                 =>  p_rrb_attribute5
      ,p_rrb_attribute6                 =>  p_rrb_attribute6
      ,p_rrb_attribute7                 =>  p_rrb_attribute7
      ,p_rrb_attribute8                 =>  p_rrb_attribute8
      ,p_rrb_attribute9                 =>  p_rrb_attribute9
      ,p_rrb_attribute10                =>  p_rrb_attribute10
      ,p_rrb_attribute11                =>  p_rrb_attribute11
      ,p_rrb_attribute12                =>  p_rrb_attribute12
      ,p_rrb_attribute13                =>  p_rrb_attribute13
      ,p_rrb_attribute14                =>  p_rrb_attribute14
      ,p_rrb_attribute15                =>  p_rrb_attribute15
      ,p_rrb_attribute16                =>  p_rrb_attribute16
      ,p_rrb_attribute17                =>  p_rrb_attribute17
      ,p_rrb_attribute18                =>  p_rrb_attribute18
      ,p_rrb_attribute19                =>  p_rrb_attribute19
      ,p_rrb_attribute20                =>  p_rrb_attribute20
      ,p_rrb_attribute21                =>  p_rrb_attribute21
      ,p_rrb_attribute22                =>  p_rrb_attribute22
      ,p_rrb_attribute23                =>  p_rrb_attribute23
      ,p_rrb_attribute24                =>  p_rrb_attribute24
      ,p_rrb_attribute25                =>  p_rrb_attribute25
      ,p_rrb_attribute26                =>  p_rrb_attribute26
      ,p_rrb_attribute27                =>  p_rrb_attribute27
      ,p_rrb_attribute28                =>  p_rrb_attribute28
      ,p_rrb_attribute29                =>  p_rrb_attribute29
      ,p_rrb_attribute30                =>  p_rrb_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_regulations_body'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_regulations_body
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
    ROLLBACK TO update_regulations_body;
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
    ROLLBACK TO update_regulations_body;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end update_regulations_body;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_regulations_body >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_regulations_body
  (p_validate                       in  boolean  default false
  ,p_regn_for_regy_body_id          in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_regulations_body';
  l_object_version_number ben_regn_for_regy_body_f.object_version_number%TYPE;
  l_effective_start_date ben_regn_for_regy_body_f.effective_start_date%TYPE;
  l_effective_end_date ben_regn_for_regy_body_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_regulations_body;
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
    -- Start of API User Hook for the before hook of delete_regulations_body
    --
    ben_regulations_body_bk3.delete_regulations_body_b
      (
       p_regn_for_regy_body_id          =>  p_regn_for_regy_body_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_regulations_body'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_regulations_body
    --
  end;
  --
  ben_rrb_del.del
    (
     p_regn_for_regy_body_id         => p_regn_for_regy_body_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_regulations_body
    --
    ben_regulations_body_bk3.delete_regulations_body_a
      (
       p_regn_for_regy_body_id          =>  p_regn_for_regy_body_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_regulations_body'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_regulations_body
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
    ROLLBACK TO delete_regulations_body;
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
    ROLLBACK TO delete_regulations_body;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end delete_regulations_body;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_regn_for_regy_body_id                   in     number
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
  ben_rrb_shd.lck
    (
      p_regn_for_regy_body_id                 => p_regn_for_regy_body_id
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
end ben_regulations_body_api;

/