--------------------------------------------------------
--  DDL for Package Body BEN_LER_RLTD_PER_CS_LER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_LER_RLTD_PER_CS_LER_API" as
/* $Header: belrcapi.pkb 115.4 2004/01/25 00:24:29 hmani ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_Ler_Rltd_Per_Cs_Ler_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Ler_Rltd_Per_Cs_Ler >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_Ler_Rltd_Per_Cs_Ler
  (p_validate                       in  boolean   default false
  ,p_ler_rltd_per_cs_ler_id         out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_ler_rltd_per_cs_chg_rl         in  number    default null
  ,p_ler_id                         in  number    default null
  ,p_rltd_per_chg_cs_ler_id         in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_lrc_attribute_category         in  varchar2  default null
  ,p_lrc_attribute1                 in  varchar2  default null
  ,p_lrc_attribute2                 in  varchar2  default null
  ,p_lrc_attribute3                 in  varchar2  default null
  ,p_lrc_attribute4                 in  varchar2  default null
  ,p_lrc_attribute5                 in  varchar2  default null
  ,p_lrc_attribute6                 in  varchar2  default null
  ,p_lrc_attribute7                 in  varchar2  default null
  ,p_lrc_attribute8                 in  varchar2  default null
  ,p_lrc_attribute9                 in  varchar2  default null
  ,p_lrc_attribute10                in  varchar2  default null
  ,p_lrc_attribute11                in  varchar2  default null
  ,p_lrc_attribute12                in  varchar2  default null
  ,p_lrc_attribute13                in  varchar2  default null
  ,p_lrc_attribute14                in  varchar2  default null
  ,p_lrc_attribute15                in  varchar2  default null
  ,p_lrc_attribute16                in  varchar2  default null
  ,p_lrc_attribute17                in  varchar2  default null
  ,p_lrc_attribute18                in  varchar2  default null
  ,p_lrc_attribute19                in  varchar2  default null
  ,p_lrc_attribute20                in  varchar2  default null
  ,p_lrc_attribute21                in  varchar2  default null
  ,p_lrc_attribute22                in  varchar2  default null
  ,p_lrc_attribute23                in  varchar2  default null
  ,p_lrc_attribute24                in  varchar2  default null
  ,p_lrc_attribute25                in  varchar2  default null
  ,p_lrc_attribute26                in  varchar2  default null
  ,p_lrc_attribute27                in  varchar2  default null
  ,p_lrc_attribute28                in  varchar2  default null
  ,p_lrc_attribute29                in  varchar2  default null
  ,p_lrc_attribute30                in  varchar2  default null
  ,p_chg_mandatory_cd                in  varchar2  default 'Y'
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_ler_rltd_per_cs_ler_id ben_ler_rltd_per_cs_ler_f.ler_rltd_per_cs_ler_id%TYPE;
  l_effective_start_date ben_ler_rltd_per_cs_ler_f.effective_start_date%TYPE;
  l_effective_end_date ben_ler_rltd_per_cs_ler_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_Ler_Rltd_Per_Cs_Ler';
  l_object_version_number ben_ler_rltd_per_cs_ler_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_Ler_Rltd_Per_Cs_Ler;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_Ler_Rltd_Per_Cs_Ler
    --
    ben_Ler_Rltd_Per_Cs_Ler_bk1.create_Ler_Rltd_Per_Cs_Ler_b
      (
       p_ler_rltd_per_cs_chg_rl         =>  p_ler_rltd_per_cs_chg_rl
      ,p_ler_id                         =>  p_ler_id
      ,p_rltd_per_chg_cs_ler_id         =>  p_rltd_per_chg_cs_ler_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_lrc_attribute_category         =>  p_lrc_attribute_category
      ,p_lrc_attribute1                 =>  p_lrc_attribute1
      ,p_lrc_attribute2                 =>  p_lrc_attribute2
      ,p_lrc_attribute3                 =>  p_lrc_attribute3
      ,p_lrc_attribute4                 =>  p_lrc_attribute4
      ,p_lrc_attribute5                 =>  p_lrc_attribute5
      ,p_lrc_attribute6                 =>  p_lrc_attribute6
      ,p_lrc_attribute7                 =>  p_lrc_attribute7
      ,p_lrc_attribute8                 =>  p_lrc_attribute8
      ,p_lrc_attribute9                 =>  p_lrc_attribute9
      ,p_lrc_attribute10                =>  p_lrc_attribute10
      ,p_lrc_attribute11                =>  p_lrc_attribute11
      ,p_lrc_attribute12                =>  p_lrc_attribute12
      ,p_lrc_attribute13                =>  p_lrc_attribute13
      ,p_lrc_attribute14                =>  p_lrc_attribute14
      ,p_lrc_attribute15                =>  p_lrc_attribute15
      ,p_lrc_attribute16                =>  p_lrc_attribute16
      ,p_lrc_attribute17                =>  p_lrc_attribute17
      ,p_lrc_attribute18                =>  p_lrc_attribute18
      ,p_lrc_attribute19                =>  p_lrc_attribute19
      ,p_lrc_attribute20                =>  p_lrc_attribute20
      ,p_lrc_attribute21                =>  p_lrc_attribute21
      ,p_lrc_attribute22                =>  p_lrc_attribute22
      ,p_lrc_attribute23                =>  p_lrc_attribute23
      ,p_lrc_attribute24                =>  p_lrc_attribute24
      ,p_lrc_attribute25                =>  p_lrc_attribute25
      ,p_lrc_attribute26                =>  p_lrc_attribute26
      ,p_lrc_attribute27                =>  p_lrc_attribute27
      ,p_lrc_attribute28                =>  p_lrc_attribute28
      ,p_lrc_attribute29                =>  p_lrc_attribute29
      ,p_lrc_attribute30                =>  p_lrc_attribute30
      ,p_chg_mandatory_cd                =>  p_chg_mandatory_cd
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_Ler_Rltd_Per_Cs_Ler'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_Ler_Rltd_Per_Cs_Ler
    --
  end;
  --
  ben_lrc_ins.ins
    (
     p_ler_rltd_per_cs_ler_id        => l_ler_rltd_per_cs_ler_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_ler_rltd_per_cs_chg_rl        => p_ler_rltd_per_cs_chg_rl
    ,p_ler_id                        => p_ler_id
    ,p_rltd_per_chg_cs_ler_id        => p_rltd_per_chg_cs_ler_id
    ,p_business_group_id             => p_business_group_id
    ,p_lrc_attribute_category        => p_lrc_attribute_category
    ,p_lrc_attribute1                => p_lrc_attribute1
    ,p_lrc_attribute2                => p_lrc_attribute2
    ,p_lrc_attribute3                => p_lrc_attribute3
    ,p_lrc_attribute4                => p_lrc_attribute4
    ,p_lrc_attribute5                => p_lrc_attribute5
    ,p_lrc_attribute6                => p_lrc_attribute6
    ,p_lrc_attribute7                => p_lrc_attribute7
    ,p_lrc_attribute8                => p_lrc_attribute8
    ,p_lrc_attribute9                => p_lrc_attribute9
    ,p_lrc_attribute10               => p_lrc_attribute10
    ,p_lrc_attribute11               => p_lrc_attribute11
    ,p_lrc_attribute12               => p_lrc_attribute12
    ,p_lrc_attribute13               => p_lrc_attribute13
    ,p_lrc_attribute14               => p_lrc_attribute14
    ,p_lrc_attribute15               => p_lrc_attribute15
    ,p_lrc_attribute16               => p_lrc_attribute16
    ,p_lrc_attribute17               => p_lrc_attribute17
    ,p_lrc_attribute18               => p_lrc_attribute18
    ,p_lrc_attribute19               => p_lrc_attribute19
    ,p_lrc_attribute20               => p_lrc_attribute20
    ,p_lrc_attribute21               => p_lrc_attribute21
    ,p_lrc_attribute22               => p_lrc_attribute22
    ,p_lrc_attribute23               => p_lrc_attribute23
    ,p_lrc_attribute24               => p_lrc_attribute24
    ,p_lrc_attribute25               => p_lrc_attribute25
    ,p_lrc_attribute26               => p_lrc_attribute26
    ,p_lrc_attribute27               => p_lrc_attribute27
    ,p_lrc_attribute28               => p_lrc_attribute28
    ,p_lrc_attribute29               => p_lrc_attribute29
    ,p_lrc_attribute30               => p_lrc_attribute30
    ,p_chg_mandatory_cd               => p_chg_mandatory_cd
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_Ler_Rltd_Per_Cs_Ler
    --
    ben_Ler_Rltd_Per_Cs_Ler_bk1.create_Ler_Rltd_Per_Cs_Ler_a
      (
       p_ler_rltd_per_cs_ler_id         =>  l_ler_rltd_per_cs_ler_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_ler_rltd_per_cs_chg_rl         =>  p_ler_rltd_per_cs_chg_rl
      ,p_ler_id                         =>  p_ler_id
      ,p_rltd_per_chg_cs_ler_id         =>  p_rltd_per_chg_cs_ler_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_lrc_attribute_category         =>  p_lrc_attribute_category
      ,p_lrc_attribute1                 =>  p_lrc_attribute1
      ,p_lrc_attribute2                 =>  p_lrc_attribute2
      ,p_lrc_attribute3                 =>  p_lrc_attribute3
      ,p_lrc_attribute4                 =>  p_lrc_attribute4
      ,p_lrc_attribute5                 =>  p_lrc_attribute5
      ,p_lrc_attribute6                 =>  p_lrc_attribute6
      ,p_lrc_attribute7                 =>  p_lrc_attribute7
      ,p_lrc_attribute8                 =>  p_lrc_attribute8
      ,p_lrc_attribute9                 =>  p_lrc_attribute9
      ,p_lrc_attribute10                =>  p_lrc_attribute10
      ,p_lrc_attribute11                =>  p_lrc_attribute11
      ,p_lrc_attribute12                =>  p_lrc_attribute12
      ,p_lrc_attribute13                =>  p_lrc_attribute13
      ,p_lrc_attribute14                =>  p_lrc_attribute14
      ,p_lrc_attribute15                =>  p_lrc_attribute15
      ,p_lrc_attribute16                =>  p_lrc_attribute16
      ,p_lrc_attribute17                =>  p_lrc_attribute17
      ,p_lrc_attribute18                =>  p_lrc_attribute18
      ,p_lrc_attribute19                =>  p_lrc_attribute19
      ,p_lrc_attribute20                =>  p_lrc_attribute20
      ,p_lrc_attribute21                =>  p_lrc_attribute21
      ,p_lrc_attribute22                =>  p_lrc_attribute22
      ,p_lrc_attribute23                =>  p_lrc_attribute23
      ,p_lrc_attribute24                =>  p_lrc_attribute24
      ,p_lrc_attribute25                =>  p_lrc_attribute25
      ,p_lrc_attribute26                =>  p_lrc_attribute26
      ,p_lrc_attribute27                =>  p_lrc_attribute27
      ,p_lrc_attribute28                =>  p_lrc_attribute28
      ,p_lrc_attribute29                =>  p_lrc_attribute29
      ,p_lrc_attribute30                =>  p_lrc_attribute30
      ,p_chg_mandatory_cd                =>  p_chg_mandatory_cd
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_Ler_Rltd_Per_Cs_Ler'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_Ler_Rltd_Per_Cs_Ler
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
  p_ler_rltd_per_cs_ler_id := l_ler_rltd_per_cs_ler_id;
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
    ROLLBACK TO create_Ler_Rltd_Per_Cs_Ler;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_ler_rltd_per_cs_ler_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_Ler_Rltd_Per_Cs_Ler;
    p_ler_rltd_per_cs_ler_id := null; --nocopy change
    p_effective_start_date := null; --nocopy change
    p_effective_end_date := null; --nocopy change
    p_object_version_number  := null; --nocopy change
    raise;
    --
end create_Ler_Rltd_Per_Cs_Ler;
-- ----------------------------------------------------------------------------
-- |------------------------< update_Ler_Rltd_Per_Cs_Ler >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_Ler_Rltd_Per_Cs_Ler
  (p_validate                       in  boolean   default false
  ,p_ler_rltd_per_cs_ler_id         in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_ler_rltd_per_cs_chg_rl         in  number    default hr_api.g_number
  ,p_ler_id                         in  number    default hr_api.g_number
  ,p_rltd_per_chg_cs_ler_id         in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_lrc_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_lrc_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_lrc_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_lrc_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_lrc_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_lrc_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_lrc_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_lrc_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_lrc_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_lrc_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_lrc_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_lrc_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_lrc_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_lrc_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_lrc_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_lrc_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_lrc_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_lrc_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_lrc_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_lrc_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_lrc_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_lrc_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_lrc_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_lrc_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_lrc_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_lrc_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_lrc_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_lrc_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_lrc_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_lrc_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_lrc_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_chg_mandatory_cd                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Ler_Rltd_Per_Cs_Ler';
  l_object_version_number ben_ler_rltd_per_cs_ler_f.object_version_number%TYPE;
  l_effective_start_date ben_ler_rltd_per_cs_ler_f.effective_start_date%TYPE;
  l_effective_end_date ben_ler_rltd_per_cs_ler_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_Ler_Rltd_Per_Cs_Ler;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_Ler_Rltd_Per_Cs_Ler
    --
    ben_Ler_Rltd_Per_Cs_Ler_bk2.update_Ler_Rltd_Per_Cs_Ler_b
      (
       p_ler_rltd_per_cs_ler_id         =>  p_ler_rltd_per_cs_ler_id
      ,p_ler_rltd_per_cs_chg_rl         =>  p_ler_rltd_per_cs_chg_rl
      ,p_ler_id                         =>  p_ler_id
      ,p_rltd_per_chg_cs_ler_id         =>  p_rltd_per_chg_cs_ler_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_lrc_attribute_category         =>  p_lrc_attribute_category
      ,p_lrc_attribute1                 =>  p_lrc_attribute1
      ,p_lrc_attribute2                 =>  p_lrc_attribute2
      ,p_lrc_attribute3                 =>  p_lrc_attribute3
      ,p_lrc_attribute4                 =>  p_lrc_attribute4
      ,p_lrc_attribute5                 =>  p_lrc_attribute5
      ,p_lrc_attribute6                 =>  p_lrc_attribute6
      ,p_lrc_attribute7                 =>  p_lrc_attribute7
      ,p_lrc_attribute8                 =>  p_lrc_attribute8
      ,p_lrc_attribute9                 =>  p_lrc_attribute9
      ,p_lrc_attribute10                =>  p_lrc_attribute10
      ,p_lrc_attribute11                =>  p_lrc_attribute11
      ,p_lrc_attribute12                =>  p_lrc_attribute12
      ,p_lrc_attribute13                =>  p_lrc_attribute13
      ,p_lrc_attribute14                =>  p_lrc_attribute14
      ,p_lrc_attribute15                =>  p_lrc_attribute15
      ,p_lrc_attribute16                =>  p_lrc_attribute16
      ,p_lrc_attribute17                =>  p_lrc_attribute17
      ,p_lrc_attribute18                =>  p_lrc_attribute18
      ,p_lrc_attribute19                =>  p_lrc_attribute19
      ,p_lrc_attribute20                =>  p_lrc_attribute20
      ,p_lrc_attribute21                =>  p_lrc_attribute21
      ,p_lrc_attribute22                =>  p_lrc_attribute22
      ,p_lrc_attribute23                =>  p_lrc_attribute23
      ,p_lrc_attribute24                =>  p_lrc_attribute24
      ,p_lrc_attribute25                =>  p_lrc_attribute25
      ,p_lrc_attribute26                =>  p_lrc_attribute26
      ,p_lrc_attribute27                =>  p_lrc_attribute27
      ,p_lrc_attribute28                =>  p_lrc_attribute28
      ,p_lrc_attribute29                =>  p_lrc_attribute29
      ,p_lrc_attribute30                =>  p_lrc_attribute30
      ,p_chg_mandatory_cd                =>  p_chg_mandatory_cd
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Ler_Rltd_Per_Cs_Ler'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_Ler_Rltd_Per_Cs_Ler
    --
  end;
  --
  ben_lrc_upd.upd
    (
     p_ler_rltd_per_cs_ler_id        => p_ler_rltd_per_cs_ler_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_ler_rltd_per_cs_chg_rl        => p_ler_rltd_per_cs_chg_rl
    ,p_ler_id                        => p_ler_id
    ,p_rltd_per_chg_cs_ler_id        => p_rltd_per_chg_cs_ler_id
    ,p_business_group_id             => p_business_group_id
    ,p_lrc_attribute_category        => p_lrc_attribute_category
    ,p_lrc_attribute1                => p_lrc_attribute1
    ,p_lrc_attribute2                => p_lrc_attribute2
    ,p_lrc_attribute3                => p_lrc_attribute3
    ,p_lrc_attribute4                => p_lrc_attribute4
    ,p_lrc_attribute5                => p_lrc_attribute5
    ,p_lrc_attribute6                => p_lrc_attribute6
    ,p_lrc_attribute7                => p_lrc_attribute7
    ,p_lrc_attribute8                => p_lrc_attribute8
    ,p_lrc_attribute9                => p_lrc_attribute9
    ,p_lrc_attribute10               => p_lrc_attribute10
    ,p_lrc_attribute11               => p_lrc_attribute11
    ,p_lrc_attribute12               => p_lrc_attribute12
    ,p_lrc_attribute13               => p_lrc_attribute13
    ,p_lrc_attribute14               => p_lrc_attribute14
    ,p_lrc_attribute15               => p_lrc_attribute15
    ,p_lrc_attribute16               => p_lrc_attribute16
    ,p_lrc_attribute17               => p_lrc_attribute17
    ,p_lrc_attribute18               => p_lrc_attribute18
    ,p_lrc_attribute19               => p_lrc_attribute19
    ,p_lrc_attribute20               => p_lrc_attribute20
    ,p_lrc_attribute21               => p_lrc_attribute21
    ,p_lrc_attribute22               => p_lrc_attribute22
    ,p_lrc_attribute23               => p_lrc_attribute23
    ,p_lrc_attribute24               => p_lrc_attribute24
    ,p_lrc_attribute25               => p_lrc_attribute25
    ,p_lrc_attribute26               => p_lrc_attribute26
    ,p_lrc_attribute27               => p_lrc_attribute27
    ,p_lrc_attribute28               => p_lrc_attribute28
    ,p_lrc_attribute29               => p_lrc_attribute29
    ,p_lrc_attribute30               => p_lrc_attribute30
    ,p_chg_mandatory_cd               => p_chg_mandatory_cd
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_Ler_Rltd_Per_Cs_Ler
    --
    ben_Ler_Rltd_Per_Cs_Ler_bk2.update_Ler_Rltd_Per_Cs_Ler_a
      (
       p_ler_rltd_per_cs_ler_id         =>  p_ler_rltd_per_cs_ler_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_ler_rltd_per_cs_chg_rl         =>  p_ler_rltd_per_cs_chg_rl
      ,p_ler_id                         =>  p_ler_id
      ,p_rltd_per_chg_cs_ler_id         =>  p_rltd_per_chg_cs_ler_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_lrc_attribute_category         =>  p_lrc_attribute_category
      ,p_lrc_attribute1                 =>  p_lrc_attribute1
      ,p_lrc_attribute2                 =>  p_lrc_attribute2
      ,p_lrc_attribute3                 =>  p_lrc_attribute3
      ,p_lrc_attribute4                 =>  p_lrc_attribute4
      ,p_lrc_attribute5                 =>  p_lrc_attribute5
      ,p_lrc_attribute6                 =>  p_lrc_attribute6
      ,p_lrc_attribute7                 =>  p_lrc_attribute7
      ,p_lrc_attribute8                 =>  p_lrc_attribute8
      ,p_lrc_attribute9                 =>  p_lrc_attribute9
      ,p_lrc_attribute10                =>  p_lrc_attribute10
      ,p_lrc_attribute11                =>  p_lrc_attribute11
      ,p_lrc_attribute12                =>  p_lrc_attribute12
      ,p_lrc_attribute13                =>  p_lrc_attribute13
      ,p_lrc_attribute14                =>  p_lrc_attribute14
      ,p_lrc_attribute15                =>  p_lrc_attribute15
      ,p_lrc_attribute16                =>  p_lrc_attribute16
      ,p_lrc_attribute17                =>  p_lrc_attribute17
      ,p_lrc_attribute18                =>  p_lrc_attribute18
      ,p_lrc_attribute19                =>  p_lrc_attribute19
      ,p_lrc_attribute20                =>  p_lrc_attribute20
      ,p_lrc_attribute21                =>  p_lrc_attribute21
      ,p_lrc_attribute22                =>  p_lrc_attribute22
      ,p_lrc_attribute23                =>  p_lrc_attribute23
      ,p_lrc_attribute24                =>  p_lrc_attribute24
      ,p_lrc_attribute25                =>  p_lrc_attribute25
      ,p_lrc_attribute26                =>  p_lrc_attribute26
      ,p_lrc_attribute27                =>  p_lrc_attribute27
      ,p_lrc_attribute28                =>  p_lrc_attribute28
      ,p_lrc_attribute29                =>  p_lrc_attribute29
      ,p_lrc_attribute30                =>  p_lrc_attribute30
      ,p_chg_mandatory_cd                =>  p_chg_mandatory_cd
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Ler_Rltd_Per_Cs_Ler'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_Ler_Rltd_Per_Cs_Ler
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
    ROLLBACK TO update_Ler_Rltd_Per_Cs_Ler;
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
    ROLLBACK TO update_Ler_Rltd_Per_Cs_Ler;
    p_object_version_number := l_object_version_number; --nocopy change
    p_effective_start_date := null; --nocopy change
    p_effective_end_date := null; --nocopy change
    raise;
    --
end update_Ler_Rltd_Per_Cs_Ler;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Ler_Rltd_Per_Cs_Ler >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Ler_Rltd_Per_Cs_Ler
  (p_validate                       in  boolean  default false
  ,p_ler_rltd_per_cs_ler_id         in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Ler_Rltd_Per_Cs_Ler';
  l_object_version_number ben_ler_rltd_per_cs_ler_f.object_version_number%TYPE;
  l_effective_start_date ben_ler_rltd_per_cs_ler_f.effective_start_date%TYPE;
  l_effective_end_date ben_ler_rltd_per_cs_ler_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_Ler_Rltd_Per_Cs_Ler;
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
    -- Start of API User Hook for the before hook of delete_Ler_Rltd_Per_Cs_Ler
    --
    ben_Ler_Rltd_Per_Cs_Ler_bk3.delete_Ler_Rltd_Per_Cs_Ler_b
      (
       p_ler_rltd_per_cs_ler_id         =>  p_ler_rltd_per_cs_ler_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Ler_Rltd_Per_Cs_Ler'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_Ler_Rltd_Per_Cs_Ler
    --
  end;
  --
  ben_lrc_del.del
    (
     p_ler_rltd_per_cs_ler_id        => p_ler_rltd_per_cs_ler_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_Ler_Rltd_Per_Cs_Ler
    --
    ben_Ler_Rltd_Per_Cs_Ler_bk3.delete_Ler_Rltd_Per_Cs_Ler_a
      (
       p_ler_rltd_per_cs_ler_id         =>  p_ler_rltd_per_cs_ler_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Ler_Rltd_Per_Cs_Ler'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_Ler_Rltd_Per_Cs_Ler
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
    ROLLBACK TO delete_Ler_Rltd_Per_Cs_Ler;
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
    ROLLBACK TO delete_Ler_Rltd_Per_Cs_Ler;
    p_object_version_number := l_object_version_number; --nocopy change
    p_effective_start_date := null; --nocopy change
    p_effective_end_date := null; --nocopy change
    raise;
    --
end delete_Ler_Rltd_Per_Cs_Ler;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_ler_rltd_per_cs_ler_id                   in     number
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
  ben_lrc_shd.lck
    (
      p_ler_rltd_per_cs_ler_id                 => p_ler_rltd_per_cs_ler_id
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
end ben_Ler_Rltd_Per_Cs_Ler_api;

/
