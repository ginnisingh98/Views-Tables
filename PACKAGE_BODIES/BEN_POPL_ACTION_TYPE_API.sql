--------------------------------------------------------
--  DDL for Package Body BEN_POPL_ACTION_TYPE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_POPL_ACTION_TYPE_API" as
/* $Header: bepatapi.pkb 120.1 2007/03/28 15:49:20 rtagarra noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_POPL_ACTION_TYPE_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_POPL_ACTION_TYPE >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_POPL_ACTION_TYPE
  (p_validate                       in  boolean   default false
  ,p_popl_actn_typ_id               out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_actn_typ_due_dt_cd             in  varchar2  default null
  ,p_actn_typ_due_dt_rl             in  number    default null
  ,p_actn_typ_id                    in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_pat_attribute_category         in  varchar2  default null
  ,p_pat_attribute1                 in  varchar2  default null
  ,p_pat_attribute2                 in  varchar2  default null
  ,p_pat_attribute3                 in  varchar2  default null
  ,p_pat_attribute4                 in  varchar2  default null
  ,p_pat_attribute5                 in  varchar2  default null
  ,p_pat_attribute6                 in  varchar2  default null
  ,p_pat_attribute7                 in  varchar2  default null
  ,p_pat_attribute8                 in  varchar2  default null
  ,p_pat_attribute9                 in  varchar2  default null
  ,p_pat_attribute10                in  varchar2  default null
  ,p_pat_attribute11                in  varchar2  default null
  ,p_pat_attribute12                in  varchar2  default null
  ,p_pat_attribute13                in  varchar2  default null
  ,p_pat_attribute14                in  varchar2  default null
  ,p_pat_attribute15                in  varchar2  default null
  ,p_pat_attribute16                in  varchar2  default null
  ,p_pat_attribute17                in  varchar2  default null
  ,p_pat_attribute18                in  varchar2  default null
  ,p_pat_attribute19                in  varchar2  default null
  ,p_pat_attribute20                in  varchar2  default null
  ,p_pat_attribute21                in  varchar2  default null
  ,p_pat_attribute22                in  varchar2  default null
  ,p_pat_attribute23                in  varchar2  default null
  ,p_pat_attribute24                in  varchar2  default null
  ,p_pat_attribute25                in  varchar2  default null
  ,p_pat_attribute26                in  varchar2  default null
  ,p_pat_attribute27                in  varchar2  default null
  ,p_pat_attribute28                in  varchar2  default null
  ,p_pat_attribute29                in  varchar2  default null
  ,p_pat_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_mandatory                      in  varchar2  default null
  ,p_once_or_always                 in  varchar2  default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_popl_actn_typ_id ben_popl_actn_typ_f.popl_actn_typ_id%TYPE;
  l_effective_start_date ben_popl_actn_typ_f.effective_start_date%TYPE;
  l_effective_end_date ben_popl_actn_typ_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_POPL_ACTION_TYPE';
  l_object_version_number ben_popl_actn_typ_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_POPL_ACTION_TYPE;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_POPL_ACTION_TYPE
    --
    ben_POPL_ACTION_TYPE_bk1.create_POPL_ACTION_TYPE_b
      (
       p_actn_typ_due_dt_cd             =>  p_actn_typ_due_dt_cd
      ,p_actn_typ_due_dt_rl             =>  p_actn_typ_due_dt_rl
      ,p_actn_typ_id                    =>  p_actn_typ_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_pl_id                          =>  p_pl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pat_attribute_category         =>  p_pat_attribute_category
      ,p_pat_attribute1                 =>  p_pat_attribute1
      ,p_pat_attribute2                 =>  p_pat_attribute2
      ,p_pat_attribute3                 =>  p_pat_attribute3
      ,p_pat_attribute4                 =>  p_pat_attribute4
      ,p_pat_attribute5                 =>  p_pat_attribute5
      ,p_pat_attribute6                 =>  p_pat_attribute6
      ,p_pat_attribute7                 =>  p_pat_attribute7
      ,p_pat_attribute8                 =>  p_pat_attribute8
      ,p_pat_attribute9                 =>  p_pat_attribute9
      ,p_pat_attribute10                =>  p_pat_attribute10
      ,p_pat_attribute11                =>  p_pat_attribute11
      ,p_pat_attribute12                =>  p_pat_attribute12
      ,p_pat_attribute13                =>  p_pat_attribute13
      ,p_pat_attribute14                =>  p_pat_attribute14
      ,p_pat_attribute15                =>  p_pat_attribute15
      ,p_pat_attribute16                =>  p_pat_attribute16
      ,p_pat_attribute17                =>  p_pat_attribute17
      ,p_pat_attribute18                =>  p_pat_attribute18
      ,p_pat_attribute19                =>  p_pat_attribute19
      ,p_pat_attribute20                =>  p_pat_attribute20
      ,p_pat_attribute21                =>  p_pat_attribute21
      ,p_pat_attribute22                =>  p_pat_attribute22
      ,p_pat_attribute23                =>  p_pat_attribute23
      ,p_pat_attribute24                =>  p_pat_attribute24
      ,p_pat_attribute25                =>  p_pat_attribute25
      ,p_pat_attribute26                =>  p_pat_attribute26
      ,p_pat_attribute27                =>  p_pat_attribute27
      ,p_pat_attribute28                =>  p_pat_attribute28
      ,p_pat_attribute29                =>  p_pat_attribute29
      ,p_pat_attribute30                =>  p_pat_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_mandatory                      => p_mandatory
      ,p_once_or_always                 => p_once_or_always
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_POPL_ACTION_TYPE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_POPL_ACTION_TYPE
    --
  end;
  --
  ben_pat_ins.ins
    (
     p_popl_actn_typ_id              => l_popl_actn_typ_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_actn_typ_due_dt_cd            => p_actn_typ_due_dt_cd
    ,p_actn_typ_due_dt_rl            => p_actn_typ_due_dt_rl
    ,p_actn_typ_id                   => p_actn_typ_id
    ,p_pgm_id                        => p_pgm_id
    ,p_pl_id                         => p_pl_id
    ,p_business_group_id             => p_business_group_id
    ,p_pat_attribute_category        => p_pat_attribute_category
    ,p_pat_attribute1                => p_pat_attribute1
    ,p_pat_attribute2                => p_pat_attribute2
    ,p_pat_attribute3                => p_pat_attribute3
    ,p_pat_attribute4                => p_pat_attribute4
    ,p_pat_attribute5                => p_pat_attribute5
    ,p_pat_attribute6                => p_pat_attribute6
    ,p_pat_attribute7                => p_pat_attribute7
    ,p_pat_attribute8                => p_pat_attribute8
    ,p_pat_attribute9                => p_pat_attribute9
    ,p_pat_attribute10               => p_pat_attribute10
    ,p_pat_attribute11               => p_pat_attribute11
    ,p_pat_attribute12               => p_pat_attribute12
    ,p_pat_attribute13               => p_pat_attribute13
    ,p_pat_attribute14               => p_pat_attribute14
    ,p_pat_attribute15               => p_pat_attribute15
    ,p_pat_attribute16               => p_pat_attribute16
    ,p_pat_attribute17               => p_pat_attribute17
    ,p_pat_attribute18               => p_pat_attribute18
    ,p_pat_attribute19               => p_pat_attribute19
    ,p_pat_attribute20               => p_pat_attribute20
    ,p_pat_attribute21               => p_pat_attribute21
    ,p_pat_attribute22               => p_pat_attribute22
    ,p_pat_attribute23               => p_pat_attribute23
    ,p_pat_attribute24               => p_pat_attribute24
    ,p_pat_attribute25               => p_pat_attribute25
    ,p_pat_attribute26               => p_pat_attribute26
    ,p_pat_attribute27               => p_pat_attribute27
    ,p_pat_attribute28               => p_pat_attribute28
    ,p_pat_attribute29               => p_pat_attribute29
    ,p_pat_attribute30               => p_pat_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_mandatory                      => p_mandatory
    ,p_once_or_always                 => p_once_or_always
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_POPL_ACTION_TYPE
    --
    ben_POPL_ACTION_TYPE_bk1.create_POPL_ACTION_TYPE_a
      (
       p_popl_actn_typ_id               =>  l_popl_actn_typ_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_actn_typ_due_dt_cd             =>  p_actn_typ_due_dt_cd
      ,p_actn_typ_due_dt_rl             =>  p_actn_typ_due_dt_rl
      ,p_actn_typ_id                    =>  p_actn_typ_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_pl_id                          =>  p_pl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pat_attribute_category         =>  p_pat_attribute_category
      ,p_pat_attribute1                 =>  p_pat_attribute1
      ,p_pat_attribute2                 =>  p_pat_attribute2
      ,p_pat_attribute3                 =>  p_pat_attribute3
      ,p_pat_attribute4                 =>  p_pat_attribute4
      ,p_pat_attribute5                 =>  p_pat_attribute5
      ,p_pat_attribute6                 =>  p_pat_attribute6
      ,p_pat_attribute7                 =>  p_pat_attribute7
      ,p_pat_attribute8                 =>  p_pat_attribute8
      ,p_pat_attribute9                 =>  p_pat_attribute9
      ,p_pat_attribute10                =>  p_pat_attribute10
      ,p_pat_attribute11                =>  p_pat_attribute11
      ,p_pat_attribute12                =>  p_pat_attribute12
      ,p_pat_attribute13                =>  p_pat_attribute13
      ,p_pat_attribute14                =>  p_pat_attribute14
      ,p_pat_attribute15                =>  p_pat_attribute15
      ,p_pat_attribute16                =>  p_pat_attribute16
      ,p_pat_attribute17                =>  p_pat_attribute17
      ,p_pat_attribute18                =>  p_pat_attribute18
      ,p_pat_attribute19                =>  p_pat_attribute19
      ,p_pat_attribute20                =>  p_pat_attribute20
      ,p_pat_attribute21                =>  p_pat_attribute21
      ,p_pat_attribute22                =>  p_pat_attribute22
      ,p_pat_attribute23                =>  p_pat_attribute23
      ,p_pat_attribute24                =>  p_pat_attribute24
      ,p_pat_attribute25                =>  p_pat_attribute25
      ,p_pat_attribute26                =>  p_pat_attribute26
      ,p_pat_attribute27                =>  p_pat_attribute27
      ,p_pat_attribute28                =>  p_pat_attribute28
      ,p_pat_attribute29                =>  p_pat_attribute29
      ,p_pat_attribute30                =>  p_pat_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      ,p_mandatory                      => p_mandatory
      ,p_once_or_always                 => p_once_or_always
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_POPL_ACTION_TYPE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_POPL_ACTION_TYPE
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
  p_popl_actn_typ_id := l_popl_actn_typ_id;
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
    ROLLBACK TO create_POPL_ACTION_TYPE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_popl_actn_typ_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_POPL_ACTION_TYPE;

    -- NOCOPY, Reset out parameters
    p_popl_actn_typ_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;

    raise;
    --
end create_POPL_ACTION_TYPE;
-- ----------------------------------------------------------------------------
-- |------------------------< update_POPL_ACTION_TYPE >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_POPL_ACTION_TYPE
  (p_validate                       in  boolean   default false
  ,p_popl_actn_typ_id               in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_actn_typ_due_dt_cd             in  varchar2  default hr_api.g_varchar2
  ,p_actn_typ_due_dt_rl             in  number    default hr_api.g_number
  ,p_actn_typ_id                    in  number    default hr_api.g_number
  ,p_pgm_id                         in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pat_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pat_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pat_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pat_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pat_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pat_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pat_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pat_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pat_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pat_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pat_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pat_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pat_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pat_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pat_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pat_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pat_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pat_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pat_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pat_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pat_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pat_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pat_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pat_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pat_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pat_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pat_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pat_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pat_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pat_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pat_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_mandatory                      in  varchar2  default hr_api.g_varchar2
  ,p_once_or_always                 in  varchar2  default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_POPL_ACTION_TYPE';
  l_object_version_number ben_popl_actn_typ_f.object_version_number%TYPE;
  l_effective_start_date ben_popl_actn_typ_f.effective_start_date%TYPE;
  l_effective_end_date ben_popl_actn_typ_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_POPL_ACTION_TYPE;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_POPL_ACTION_TYPE
    --
    ben_POPL_ACTION_TYPE_bk2.update_POPL_ACTION_TYPE_b
      (
       p_popl_actn_typ_id               =>  p_popl_actn_typ_id
      ,p_actn_typ_due_dt_cd             =>  p_actn_typ_due_dt_cd
      ,p_actn_typ_due_dt_rl             =>  p_actn_typ_due_dt_rl
      ,p_actn_typ_id                    =>  p_actn_typ_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_pl_id                          =>  p_pl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pat_attribute_category         =>  p_pat_attribute_category
      ,p_pat_attribute1                 =>  p_pat_attribute1
      ,p_pat_attribute2                 =>  p_pat_attribute2
      ,p_pat_attribute3                 =>  p_pat_attribute3
      ,p_pat_attribute4                 =>  p_pat_attribute4
      ,p_pat_attribute5                 =>  p_pat_attribute5
      ,p_pat_attribute6                 =>  p_pat_attribute6
      ,p_pat_attribute7                 =>  p_pat_attribute7
      ,p_pat_attribute8                 =>  p_pat_attribute8
      ,p_pat_attribute9                 =>  p_pat_attribute9
      ,p_pat_attribute10                =>  p_pat_attribute10
      ,p_pat_attribute11                =>  p_pat_attribute11
      ,p_pat_attribute12                =>  p_pat_attribute12
      ,p_pat_attribute13                =>  p_pat_attribute13
      ,p_pat_attribute14                =>  p_pat_attribute14
      ,p_pat_attribute15                =>  p_pat_attribute15
      ,p_pat_attribute16                =>  p_pat_attribute16
      ,p_pat_attribute17                =>  p_pat_attribute17
      ,p_pat_attribute18                =>  p_pat_attribute18
      ,p_pat_attribute19                =>  p_pat_attribute19
      ,p_pat_attribute20                =>  p_pat_attribute20
      ,p_pat_attribute21                =>  p_pat_attribute21
      ,p_pat_attribute22                =>  p_pat_attribute22
      ,p_pat_attribute23                =>  p_pat_attribute23
      ,p_pat_attribute24                =>  p_pat_attribute24
      ,p_pat_attribute25                =>  p_pat_attribute25
      ,p_pat_attribute26                =>  p_pat_attribute26
      ,p_pat_attribute27                =>  p_pat_attribute27
      ,p_pat_attribute28                =>  p_pat_attribute28
      ,p_pat_attribute29                =>  p_pat_attribute29
      ,p_pat_attribute30                =>  p_pat_attribute30
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      ,p_datetrack_mode                      => p_datetrack_mode
      ,p_mandatory                      => p_mandatory
      ,p_once_or_always                 => p_once_or_always
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_POPL_ACTION_TYPE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_POPL_ACTION_TYPE
    --
  end;
  --
  ben_pat_upd.upd
    (
     p_popl_actn_typ_id              => p_popl_actn_typ_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_actn_typ_due_dt_cd            => p_actn_typ_due_dt_cd
    ,p_actn_typ_due_dt_rl            => p_actn_typ_due_dt_rl
    ,p_actn_typ_id                   => p_actn_typ_id
    ,p_pgm_id                        => p_pgm_id
    ,p_pl_id                         => p_pl_id
    ,p_business_group_id             => p_business_group_id
    ,p_pat_attribute_category        => p_pat_attribute_category
    ,p_pat_attribute1                => p_pat_attribute1
    ,p_pat_attribute2                => p_pat_attribute2
    ,p_pat_attribute3                => p_pat_attribute3
    ,p_pat_attribute4                => p_pat_attribute4
    ,p_pat_attribute5                => p_pat_attribute5
    ,p_pat_attribute6                => p_pat_attribute6
    ,p_pat_attribute7                => p_pat_attribute7
    ,p_pat_attribute8                => p_pat_attribute8
    ,p_pat_attribute9                => p_pat_attribute9
    ,p_pat_attribute10               => p_pat_attribute10
    ,p_pat_attribute11               => p_pat_attribute11
    ,p_pat_attribute12               => p_pat_attribute12
    ,p_pat_attribute13               => p_pat_attribute13
    ,p_pat_attribute14               => p_pat_attribute14
    ,p_pat_attribute15               => p_pat_attribute15
    ,p_pat_attribute16               => p_pat_attribute16
    ,p_pat_attribute17               => p_pat_attribute17
    ,p_pat_attribute18               => p_pat_attribute18
    ,p_pat_attribute19               => p_pat_attribute19
    ,p_pat_attribute20               => p_pat_attribute20
    ,p_pat_attribute21               => p_pat_attribute21
    ,p_pat_attribute22               => p_pat_attribute22
    ,p_pat_attribute23               => p_pat_attribute23
    ,p_pat_attribute24               => p_pat_attribute24
    ,p_pat_attribute25               => p_pat_attribute25
    ,p_pat_attribute26               => p_pat_attribute26
    ,p_pat_attribute27               => p_pat_attribute27
    ,p_pat_attribute28               => p_pat_attribute28
    ,p_pat_attribute29               => p_pat_attribute29
    ,p_pat_attribute30               => p_pat_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    ,p_mandatory                      => p_mandatory
    ,p_once_or_always                 => p_once_or_always
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_POPL_ACTION_TYPE
    --
    ben_POPL_ACTION_TYPE_bk2.update_POPL_ACTION_TYPE_a
      (
       p_popl_actn_typ_id               =>  p_popl_actn_typ_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_actn_typ_due_dt_cd             =>  p_actn_typ_due_dt_cd
      ,p_actn_typ_due_dt_rl             =>  p_actn_typ_due_dt_rl
      ,p_actn_typ_id                    =>  p_actn_typ_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_pl_id                          =>  p_pl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pat_attribute_category         =>  p_pat_attribute_category
      ,p_pat_attribute1                 =>  p_pat_attribute1
      ,p_pat_attribute2                 =>  p_pat_attribute2
      ,p_pat_attribute3                 =>  p_pat_attribute3
      ,p_pat_attribute4                 =>  p_pat_attribute4
      ,p_pat_attribute5                 =>  p_pat_attribute5
      ,p_pat_attribute6                 =>  p_pat_attribute6
      ,p_pat_attribute7                 =>  p_pat_attribute7
      ,p_pat_attribute8                 =>  p_pat_attribute8
      ,p_pat_attribute9                 =>  p_pat_attribute9
      ,p_pat_attribute10                =>  p_pat_attribute10
      ,p_pat_attribute11                =>  p_pat_attribute11
      ,p_pat_attribute12                =>  p_pat_attribute12
      ,p_pat_attribute13                =>  p_pat_attribute13
      ,p_pat_attribute14                =>  p_pat_attribute14
      ,p_pat_attribute15                =>  p_pat_attribute15
      ,p_pat_attribute16                =>  p_pat_attribute16
      ,p_pat_attribute17                =>  p_pat_attribute17
      ,p_pat_attribute18                =>  p_pat_attribute18
      ,p_pat_attribute19                =>  p_pat_attribute19
      ,p_pat_attribute20                =>  p_pat_attribute20
      ,p_pat_attribute21                =>  p_pat_attribute21
      ,p_pat_attribute22                =>  p_pat_attribute22
      ,p_pat_attribute23                =>  p_pat_attribute23
      ,p_pat_attribute24                =>  p_pat_attribute24
      ,p_pat_attribute25                =>  p_pat_attribute25
      ,p_pat_attribute26                =>  p_pat_attribute26
      ,p_pat_attribute27                =>  p_pat_attribute27
      ,p_pat_attribute28                =>  p_pat_attribute28
      ,p_pat_attribute29                =>  p_pat_attribute29
      ,p_pat_attribute30                =>  p_pat_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      ,p_mandatory                      => p_mandatory
      ,p_once_or_always                 => p_once_or_always
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_POPL_ACTION_TYPE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_POPL_ACTION_TYPE
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
    ROLLBACK TO update_POPL_ACTION_TYPE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_start_date := null;
    p_effective_end_date   := null;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_POPL_ACTION_TYPE;

    -- NOCOPY, Reset out parameters
    p_effective_start_date := null;
    p_effective_end_date   := null;

    raise;
    --
end update_POPL_ACTION_TYPE;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_POPL_ACTION_TYPE >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_POPL_ACTION_TYPE
  (p_validate                       in  boolean  default false
  ,p_popl_actn_typ_id               in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_POPL_ACTION_TYPE';
  l_object_version_number ben_popl_actn_typ_f.object_version_number%TYPE;
  l_effective_start_date ben_popl_actn_typ_f.effective_start_date%TYPE;
  l_effective_end_date ben_popl_actn_typ_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_POPL_ACTION_TYPE;
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
    -- Start of API User Hook for the before hook of delete_POPL_ACTION_TYPE
    --
    ben_POPL_ACTION_TYPE_bk3.delete_POPL_ACTION_TYPE_b
      (
       p_popl_actn_typ_id               =>  p_popl_actn_typ_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_POPL_ACTION_TYPE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_POPL_ACTION_TYPE
    --
  end;
  --
  ben_pat_del.del
    (
     p_popl_actn_typ_id              => p_popl_actn_typ_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_POPL_ACTION_TYPE
    --
    ben_POPL_ACTION_TYPE_bk3.delete_POPL_ACTION_TYPE_a
      (
       p_popl_actn_typ_id               =>  p_popl_actn_typ_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_POPL_ACTION_TYPE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_POPL_ACTION_TYPE
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
    ROLLBACK TO delete_POPL_ACTION_TYPE;
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
    ROLLBACK TO delete_POPL_ACTION_TYPE;

    -- NOCOPY, Reset out parameters
    p_effective_start_date := null;
    p_effective_end_date   := null;

    raise;
    --
end delete_POPL_ACTION_TYPE;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_popl_actn_typ_id                   in     number
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
  ben_pat_shd.lck
    (
      p_popl_actn_typ_id                 => p_popl_actn_typ_id
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
end ben_POPL_ACTION_TYPE_api;

/
