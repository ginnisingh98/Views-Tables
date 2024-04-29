--------------------------------------------------------
--  DDL for Package Body BEN_VALD_RLSHP_FOR_REIMB_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_VALD_RLSHP_FOR_REIMB_API" as
/* $Header: bevrpapi.pkb 120.0 2005/05/28 12:12:05 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_Vald_Rlshp_For_Reimb_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Vald_Rlshp_For_Reimb >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_Vald_Rlshp_For_Reimb
  (p_validate                       in  boolean   default false
  ,p_vald_rlshp_for_reimb_id        out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_rlshp_typ_cd                   in  varchar2  default null
  ,p_vrp_attribute_category         in  varchar2  default null
  ,p_vrp_attribute1                 in  varchar2  default null
  ,p_vrp_attribute2                 in  varchar2  default null
  ,p_vrp_attribute3                 in  varchar2  default null
  ,p_vrp_attribute4                 in  varchar2  default null
  ,p_vrp_attribute5                 in  varchar2  default null
  ,p_vrp_attribute6                 in  varchar2  default null
  ,p_vrp_attribute7                 in  varchar2  default null
  ,p_vrp_attribute8                 in  varchar2  default null
  ,p_vrp_attribute9                 in  varchar2  default null
  ,p_vrp_attribute10                in  varchar2  default null
  ,p_vrp_attribute11                in  varchar2  default null
  ,p_vrp_attribute12                in  varchar2  default null
  ,p_vrp_attribute13                in  varchar2  default null
  ,p_vrp_attribute14                in  varchar2  default null
  ,p_vrp_attribute15                in  varchar2  default null
  ,p_vrp_attribute16                in  varchar2  default null
  ,p_vrp_attribute17                in  varchar2  default null
  ,p_vrp_attribute18                in  varchar2  default null
  ,p_vrp_attribute19                in  varchar2  default null
  ,p_vrp_attribute20                in  varchar2  default null
  ,p_vrp_attribute21                in  varchar2  default null
  ,p_vrp_attribute22                in  varchar2  default null
  ,p_vrp_attribute23                in  varchar2  default null
  ,p_vrp_attribute24                in  varchar2  default null
  ,p_vrp_attribute25                in  varchar2  default null
  ,p_vrp_attribute26                in  varchar2  default null
  ,p_vrp_attribute27                in  varchar2  default null
  ,p_vrp_attribute28                in  varchar2  default null
  ,p_vrp_attribute29                in  varchar2  default null
  ,p_vrp_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_vald_rlshp_for_reimb_id ben_vald_rlshp_for_reimb_f.vald_rlshp_for_reimb_id%TYPE;
  l_effective_start_date ben_vald_rlshp_for_reimb_f.effective_start_date%TYPE;
  l_effective_end_date ben_vald_rlshp_for_reimb_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_Vald_Rlshp_For_Reimb';
  l_object_version_number ben_vald_rlshp_for_reimb_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_Vald_Rlshp_For_Reimb;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_Vald_Rlshp_For_Reimb
    --
    ben_Vald_Rlshp_For_Reimb_bk1.create_Vald_Rlshp_For_Reimb_b
      (
       p_business_group_id              =>  p_business_group_id
      ,p_pl_id                          =>  p_pl_id
      ,p_rlshp_typ_cd                   =>  p_rlshp_typ_cd
      ,p_vrp_attribute_category         =>  p_vrp_attribute_category
      ,p_vrp_attribute1                 =>  p_vrp_attribute1
      ,p_vrp_attribute2                 =>  p_vrp_attribute2
      ,p_vrp_attribute3                 =>  p_vrp_attribute3
      ,p_vrp_attribute4                 =>  p_vrp_attribute4
      ,p_vrp_attribute5                 =>  p_vrp_attribute5
      ,p_vrp_attribute6                 =>  p_vrp_attribute6
      ,p_vrp_attribute7                 =>  p_vrp_attribute7
      ,p_vrp_attribute8                 =>  p_vrp_attribute8
      ,p_vrp_attribute9                 =>  p_vrp_attribute9
      ,p_vrp_attribute10                =>  p_vrp_attribute10
      ,p_vrp_attribute11                =>  p_vrp_attribute11
      ,p_vrp_attribute12                =>  p_vrp_attribute12
      ,p_vrp_attribute13                =>  p_vrp_attribute13
      ,p_vrp_attribute14                =>  p_vrp_attribute14
      ,p_vrp_attribute15                =>  p_vrp_attribute15
      ,p_vrp_attribute16                =>  p_vrp_attribute16
      ,p_vrp_attribute17                =>  p_vrp_attribute17
      ,p_vrp_attribute18                =>  p_vrp_attribute18
      ,p_vrp_attribute19                =>  p_vrp_attribute19
      ,p_vrp_attribute20                =>  p_vrp_attribute20
      ,p_vrp_attribute21                =>  p_vrp_attribute21
      ,p_vrp_attribute22                =>  p_vrp_attribute22
      ,p_vrp_attribute23                =>  p_vrp_attribute23
      ,p_vrp_attribute24                =>  p_vrp_attribute24
      ,p_vrp_attribute25                =>  p_vrp_attribute25
      ,p_vrp_attribute26                =>  p_vrp_attribute26
      ,p_vrp_attribute27                =>  p_vrp_attribute27
      ,p_vrp_attribute28                =>  p_vrp_attribute28
      ,p_vrp_attribute29                =>  p_vrp_attribute29
      ,p_vrp_attribute30                =>  p_vrp_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_Vald_Rlshp_For_Reimb'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_Vald_Rlshp_For_Reimb
    --
  end;
  --
  ben_vrp_ins.ins
    (
     p_vald_rlshp_for_reimb_id       => l_vald_rlshp_for_reimb_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => p_business_group_id
    ,p_pl_id                         => p_pl_id
    ,p_rlshp_typ_cd                  => p_rlshp_typ_cd
    ,p_vrp_attribute_category        => p_vrp_attribute_category
    ,p_vrp_attribute1                => p_vrp_attribute1
    ,p_vrp_attribute2                => p_vrp_attribute2
    ,p_vrp_attribute3                => p_vrp_attribute3
    ,p_vrp_attribute4                => p_vrp_attribute4
    ,p_vrp_attribute5                => p_vrp_attribute5
    ,p_vrp_attribute6                => p_vrp_attribute6
    ,p_vrp_attribute7                => p_vrp_attribute7
    ,p_vrp_attribute8                => p_vrp_attribute8
    ,p_vrp_attribute9                => p_vrp_attribute9
    ,p_vrp_attribute10               => p_vrp_attribute10
    ,p_vrp_attribute11               => p_vrp_attribute11
    ,p_vrp_attribute12               => p_vrp_attribute12
    ,p_vrp_attribute13               => p_vrp_attribute13
    ,p_vrp_attribute14               => p_vrp_attribute14
    ,p_vrp_attribute15               => p_vrp_attribute15
    ,p_vrp_attribute16               => p_vrp_attribute16
    ,p_vrp_attribute17               => p_vrp_attribute17
    ,p_vrp_attribute18               => p_vrp_attribute18
    ,p_vrp_attribute19               => p_vrp_attribute19
    ,p_vrp_attribute20               => p_vrp_attribute20
    ,p_vrp_attribute21               => p_vrp_attribute21
    ,p_vrp_attribute22               => p_vrp_attribute22
    ,p_vrp_attribute23               => p_vrp_attribute23
    ,p_vrp_attribute24               => p_vrp_attribute24
    ,p_vrp_attribute25               => p_vrp_attribute25
    ,p_vrp_attribute26               => p_vrp_attribute26
    ,p_vrp_attribute27               => p_vrp_attribute27
    ,p_vrp_attribute28               => p_vrp_attribute28
    ,p_vrp_attribute29               => p_vrp_attribute29
    ,p_vrp_attribute30               => p_vrp_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_Vald_Rlshp_For_Reimb
    --
    ben_Vald_Rlshp_For_Reimb_bk1.create_Vald_Rlshp_For_Reimb_a
      (
       p_vald_rlshp_for_reimb_id        =>  l_vald_rlshp_for_reimb_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_pl_id                          =>  p_pl_id
      ,p_rlshp_typ_cd                   =>  p_rlshp_typ_cd
      ,p_vrp_attribute_category         =>  p_vrp_attribute_category
      ,p_vrp_attribute1                 =>  p_vrp_attribute1
      ,p_vrp_attribute2                 =>  p_vrp_attribute2
      ,p_vrp_attribute3                 =>  p_vrp_attribute3
      ,p_vrp_attribute4                 =>  p_vrp_attribute4
      ,p_vrp_attribute5                 =>  p_vrp_attribute5
      ,p_vrp_attribute6                 =>  p_vrp_attribute6
      ,p_vrp_attribute7                 =>  p_vrp_attribute7
      ,p_vrp_attribute8                 =>  p_vrp_attribute8
      ,p_vrp_attribute9                 =>  p_vrp_attribute9
      ,p_vrp_attribute10                =>  p_vrp_attribute10
      ,p_vrp_attribute11                =>  p_vrp_attribute11
      ,p_vrp_attribute12                =>  p_vrp_attribute12
      ,p_vrp_attribute13                =>  p_vrp_attribute13
      ,p_vrp_attribute14                =>  p_vrp_attribute14
      ,p_vrp_attribute15                =>  p_vrp_attribute15
      ,p_vrp_attribute16                =>  p_vrp_attribute16
      ,p_vrp_attribute17                =>  p_vrp_attribute17
      ,p_vrp_attribute18                =>  p_vrp_attribute18
      ,p_vrp_attribute19                =>  p_vrp_attribute19
      ,p_vrp_attribute20                =>  p_vrp_attribute20
      ,p_vrp_attribute21                =>  p_vrp_attribute21
      ,p_vrp_attribute22                =>  p_vrp_attribute22
      ,p_vrp_attribute23                =>  p_vrp_attribute23
      ,p_vrp_attribute24                =>  p_vrp_attribute24
      ,p_vrp_attribute25                =>  p_vrp_attribute25
      ,p_vrp_attribute26                =>  p_vrp_attribute26
      ,p_vrp_attribute27                =>  p_vrp_attribute27
      ,p_vrp_attribute28                =>  p_vrp_attribute28
      ,p_vrp_attribute29                =>  p_vrp_attribute29
      ,p_vrp_attribute30                =>  p_vrp_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
   null;
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_Vald_Rlshp_For_Reimb'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_Vald_Rlshp_For_Reimb
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
  p_vald_rlshp_for_reimb_id := l_vald_rlshp_for_reimb_id;
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
    ROLLBACK TO create_Vald_Rlshp_For_Reimb;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_vald_rlshp_for_reimb_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_Vald_Rlshp_For_Reimb;
    raise;
    --
end create_Vald_Rlshp_For_Reimb;
-- ----------------------------------------------------------------------------
-- |------------------------< update_Vald_Rlshp_For_Reimb >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_Vald_Rlshp_For_Reimb
  (p_validate                       in  boolean   default false
  ,p_vald_rlshp_for_reimb_id        in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_rlshp_typ_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_vrp_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Vald_Rlshp_For_Reimb';
  l_object_version_number ben_vald_rlshp_for_reimb_f.object_version_number%TYPE;
  l_effective_start_date ben_vald_rlshp_for_reimb_f.effective_start_date%TYPE;
  l_effective_end_date ben_vald_rlshp_for_reimb_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_Vald_Rlshp_For_Reimb;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_Vald_Rlshp_For_Reimb
    --
    ben_Vald_Rlshp_For_Reimb_bk2.update_Vald_Rlshp_For_Reimb_b
      (
       p_vald_rlshp_for_reimb_id        =>  p_vald_rlshp_for_reimb_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pl_id                          =>  p_pl_id
      ,p_rlshp_typ_cd                   =>  p_rlshp_typ_cd
      ,p_vrp_attribute_category         =>  p_vrp_attribute_category
      ,p_vrp_attribute1                 =>  p_vrp_attribute1
      ,p_vrp_attribute2                 =>  p_vrp_attribute2
      ,p_vrp_attribute3                 =>  p_vrp_attribute3
      ,p_vrp_attribute4                 =>  p_vrp_attribute4
      ,p_vrp_attribute5                 =>  p_vrp_attribute5
      ,p_vrp_attribute6                 =>  p_vrp_attribute6
      ,p_vrp_attribute7                 =>  p_vrp_attribute7
      ,p_vrp_attribute8                 =>  p_vrp_attribute8
      ,p_vrp_attribute9                 =>  p_vrp_attribute9
      ,p_vrp_attribute10                =>  p_vrp_attribute10
      ,p_vrp_attribute11                =>  p_vrp_attribute11
      ,p_vrp_attribute12                =>  p_vrp_attribute12
      ,p_vrp_attribute13                =>  p_vrp_attribute13
      ,p_vrp_attribute14                =>  p_vrp_attribute14
      ,p_vrp_attribute15                =>  p_vrp_attribute15
      ,p_vrp_attribute16                =>  p_vrp_attribute16
      ,p_vrp_attribute17                =>  p_vrp_attribute17
      ,p_vrp_attribute18                =>  p_vrp_attribute18
      ,p_vrp_attribute19                =>  p_vrp_attribute19
      ,p_vrp_attribute20                =>  p_vrp_attribute20
      ,p_vrp_attribute21                =>  p_vrp_attribute21
      ,p_vrp_attribute22                =>  p_vrp_attribute22
      ,p_vrp_attribute23                =>  p_vrp_attribute23
      ,p_vrp_attribute24                =>  p_vrp_attribute24
      ,p_vrp_attribute25                =>  p_vrp_attribute25
      ,p_vrp_attribute26                =>  p_vrp_attribute26
      ,p_vrp_attribute27                =>  p_vrp_attribute27
      ,p_vrp_attribute28                =>  p_vrp_attribute28
      ,p_vrp_attribute29                =>  p_vrp_attribute29
      ,p_vrp_attribute30                =>  p_vrp_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Vald_Rlshp_For_Reimb'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_Vald_Rlshp_For_Reimb
    --
  end;
  --
  ben_vrp_upd.upd
    (
     p_vald_rlshp_for_reimb_id       => p_vald_rlshp_for_reimb_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => p_business_group_id
    ,p_pl_id                         => p_pl_id
    ,p_rlshp_typ_cd                  => p_rlshp_typ_cd
    ,p_vrp_attribute_category        => p_vrp_attribute_category
    ,p_vrp_attribute1                => p_vrp_attribute1
    ,p_vrp_attribute2                => p_vrp_attribute2
    ,p_vrp_attribute3                => p_vrp_attribute3
    ,p_vrp_attribute4                => p_vrp_attribute4
    ,p_vrp_attribute5                => p_vrp_attribute5
    ,p_vrp_attribute6                => p_vrp_attribute6
    ,p_vrp_attribute7                => p_vrp_attribute7
    ,p_vrp_attribute8                => p_vrp_attribute8
    ,p_vrp_attribute9                => p_vrp_attribute9
    ,p_vrp_attribute10               => p_vrp_attribute10
    ,p_vrp_attribute11               => p_vrp_attribute11
    ,p_vrp_attribute12               => p_vrp_attribute12
    ,p_vrp_attribute13               => p_vrp_attribute13
    ,p_vrp_attribute14               => p_vrp_attribute14
    ,p_vrp_attribute15               => p_vrp_attribute15
    ,p_vrp_attribute16               => p_vrp_attribute16
    ,p_vrp_attribute17               => p_vrp_attribute17
    ,p_vrp_attribute18               => p_vrp_attribute18
    ,p_vrp_attribute19               => p_vrp_attribute19
    ,p_vrp_attribute20               => p_vrp_attribute20
    ,p_vrp_attribute21               => p_vrp_attribute21
    ,p_vrp_attribute22               => p_vrp_attribute22
    ,p_vrp_attribute23               => p_vrp_attribute23
    ,p_vrp_attribute24               => p_vrp_attribute24
    ,p_vrp_attribute25               => p_vrp_attribute25
    ,p_vrp_attribute26               => p_vrp_attribute26
    ,p_vrp_attribute27               => p_vrp_attribute27
    ,p_vrp_attribute28               => p_vrp_attribute28
    ,p_vrp_attribute29               => p_vrp_attribute29
    ,p_vrp_attribute30               => p_vrp_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_Vald_Rlshp_For_Reimb
    --
    ben_Vald_Rlshp_For_Reimb_bk2.update_Vald_Rlshp_For_Reimb_a
      (
       p_vald_rlshp_for_reimb_id        =>  p_vald_rlshp_for_reimb_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_pl_id                          =>  p_pl_id
      ,p_rlshp_typ_cd                   =>  p_rlshp_typ_cd
      ,p_vrp_attribute_category         =>  p_vrp_attribute_category
      ,p_vrp_attribute1                 =>  p_vrp_attribute1
      ,p_vrp_attribute2                 =>  p_vrp_attribute2
      ,p_vrp_attribute3                 =>  p_vrp_attribute3
      ,p_vrp_attribute4                 =>  p_vrp_attribute4
      ,p_vrp_attribute5                 =>  p_vrp_attribute5
      ,p_vrp_attribute6                 =>  p_vrp_attribute6
      ,p_vrp_attribute7                 =>  p_vrp_attribute7
      ,p_vrp_attribute8                 =>  p_vrp_attribute8
      ,p_vrp_attribute9                 =>  p_vrp_attribute9
      ,p_vrp_attribute10                =>  p_vrp_attribute10
      ,p_vrp_attribute11                =>  p_vrp_attribute11
      ,p_vrp_attribute12                =>  p_vrp_attribute12
      ,p_vrp_attribute13                =>  p_vrp_attribute13
      ,p_vrp_attribute14                =>  p_vrp_attribute14
      ,p_vrp_attribute15                =>  p_vrp_attribute15
      ,p_vrp_attribute16                =>  p_vrp_attribute16
      ,p_vrp_attribute17                =>  p_vrp_attribute17
      ,p_vrp_attribute18                =>  p_vrp_attribute18
      ,p_vrp_attribute19                =>  p_vrp_attribute19
      ,p_vrp_attribute20                =>  p_vrp_attribute20
      ,p_vrp_attribute21                =>  p_vrp_attribute21
      ,p_vrp_attribute22                =>  p_vrp_attribute22
      ,p_vrp_attribute23                =>  p_vrp_attribute23
      ,p_vrp_attribute24                =>  p_vrp_attribute24
      ,p_vrp_attribute25                =>  p_vrp_attribute25
      ,p_vrp_attribute26                =>  p_vrp_attribute26
      ,p_vrp_attribute27                =>  p_vrp_attribute27
      ,p_vrp_attribute28                =>  p_vrp_attribute28
      ,p_vrp_attribute29                =>  p_vrp_attribute29
      ,p_vrp_attribute30                =>  p_vrp_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Vald_Rlshp_For_Reimb'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_Vald_Rlshp_For_Reimb
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
    ROLLBACK TO update_Vald_Rlshp_For_Reimb;
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
    ROLLBACK TO update_Vald_Rlshp_For_Reimb;
    raise;
    --
end update_Vald_Rlshp_For_Reimb;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Vald_Rlshp_For_Reimb >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Vald_Rlshp_For_Reimb
  (p_validate                       in  boolean  default false
  ,p_vald_rlshp_for_reimb_id        in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Vald_Rlshp_For_Reimb';
  l_object_version_number ben_vald_rlshp_for_reimb_f.object_version_number%TYPE;
  l_effective_start_date ben_vald_rlshp_for_reimb_f.effective_start_date%TYPE;
  l_effective_end_date ben_vald_rlshp_for_reimb_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_Vald_Rlshp_For_Reimb;
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
    -- Start of API User Hook for the before hook of delete_Vald_Rlshp_For_Reimb
    --
    ben_Vald_Rlshp_For_Reimb_bk3.delete_Vald_Rlshp_For_Reimb_b
      (
       p_vald_rlshp_for_reimb_id        =>  p_vald_rlshp_for_reimb_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Vald_Rlshp_For_Reimb'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_Vald_Rlshp_For_Reimb
    --
  end;
  --
  ben_vrp_del.del
    (
     p_vald_rlshp_for_reimb_id       => p_vald_rlshp_for_reimb_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_Vald_Rlshp_For_Reimb
    --
    ben_Vald_Rlshp_For_Reimb_bk3.delete_Vald_Rlshp_For_Reimb_a
      (
       p_vald_rlshp_for_reimb_id        =>  p_vald_rlshp_for_reimb_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Vald_Rlshp_For_Reimb'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_Vald_Rlshp_For_Reimb
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
    ROLLBACK TO delete_Vald_Rlshp_For_Reimb;
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
    ROLLBACK TO delete_Vald_Rlshp_For_Reimb;
    raise;
    --
end delete_Vald_Rlshp_For_Reimb;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_vald_rlshp_for_reimb_id                   in     number
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
  ben_vrp_shd.lck
    (
      p_vald_rlshp_for_reimb_id                 => p_vald_rlshp_for_reimb_id
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
end ben_Vald_Rlshp_For_Reimb_api;

/
