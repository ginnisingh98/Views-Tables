--------------------------------------------------------
--  DDL for Package Body BEN_SCHEDD_ENROLLMENT_RL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_SCHEDD_ENROLLMENT_RL_API" as
/* $Header: beserapi.pkb 115.4 2003/01/16 14:36:05 rpgupta ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_Schedd_Enrollment_Rl_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Schedd_Enrollment_Rl >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_Schedd_Enrollment_Rl
  (p_validate                       in  boolean   default false
  ,p_schedd_enrt_rl_id              out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_ordr_to_aply_num               in  number    default null
  ,p_enrt_perd_id                   in  number    default null
  ,p_formula_id                     in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_ser_attribute_category         in  varchar2  default null
  ,p_ser_attribute1                 in  varchar2  default null
  ,p_ser_attribute2                 in  varchar2  default null
  ,p_ser_attribute3                 in  varchar2  default null
  ,p_ser_attribute4                 in  varchar2  default null
  ,p_ser_attribute5                 in  varchar2  default null
  ,p_ser_attribute6                 in  varchar2  default null
  ,p_ser_attribute7                 in  varchar2  default null
  ,p_ser_attribute8                 in  varchar2  default null
  ,p_ser_attribute9                 in  varchar2  default null
  ,p_ser_attribute10                in  varchar2  default null
  ,p_ser_attribute11                in  varchar2  default null
  ,p_ser_attribute12                in  varchar2  default null
  ,p_ser_attribute13                in  varchar2  default null
  ,p_ser_attribute14                in  varchar2  default null
  ,p_ser_attribute15                in  varchar2  default null
  ,p_ser_attribute16                in  varchar2  default null
  ,p_ser_attribute17                in  varchar2  default null
  ,p_ser_attribute18                in  varchar2  default null
  ,p_ser_attribute19                in  varchar2  default null
  ,p_ser_attribute20                in  varchar2  default null
  ,p_ser_attribute21                in  varchar2  default null
  ,p_ser_attribute22                in  varchar2  default null
  ,p_ser_attribute23                in  varchar2  default null
  ,p_ser_attribute24                in  varchar2  default null
  ,p_ser_attribute25                in  varchar2  default null
  ,p_ser_attribute26                in  varchar2  default null
  ,p_ser_attribute27                in  varchar2  default null
  ,p_ser_attribute28                in  varchar2  default null
  ,p_ser_attribute29                in  varchar2  default null
  ,p_ser_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_schedd_enrt_rl_id ben_schedd_enrt_rl_f.schedd_enrt_rl_id%TYPE;
  l_effective_start_date ben_schedd_enrt_rl_f.effective_start_date%TYPE;
  l_effective_end_date ben_schedd_enrt_rl_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_Schedd_Enrollment_Rl';
  l_object_version_number ben_schedd_enrt_rl_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_Schedd_Enrollment_Rl;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_Schedd_Enrollment_Rl
    --
    ben_Schedd_Enrollment_Rl_bk1.create_Schedd_Enrollment_Rl_b
      (
       p_ordr_to_aply_num               =>  p_ordr_to_aply_num
      ,p_enrt_perd_id                   =>  p_enrt_perd_id
      ,p_formula_id                     =>  p_formula_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ser_attribute_category         =>  p_ser_attribute_category
      ,p_ser_attribute1                 =>  p_ser_attribute1
      ,p_ser_attribute2                 =>  p_ser_attribute2
      ,p_ser_attribute3                 =>  p_ser_attribute3
      ,p_ser_attribute4                 =>  p_ser_attribute4
      ,p_ser_attribute5                 =>  p_ser_attribute5
      ,p_ser_attribute6                 =>  p_ser_attribute6
      ,p_ser_attribute7                 =>  p_ser_attribute7
      ,p_ser_attribute8                 =>  p_ser_attribute8
      ,p_ser_attribute9                 =>  p_ser_attribute9
      ,p_ser_attribute10                =>  p_ser_attribute10
      ,p_ser_attribute11                =>  p_ser_attribute11
      ,p_ser_attribute12                =>  p_ser_attribute12
      ,p_ser_attribute13                =>  p_ser_attribute13
      ,p_ser_attribute14                =>  p_ser_attribute14
      ,p_ser_attribute15                =>  p_ser_attribute15
      ,p_ser_attribute16                =>  p_ser_attribute16
      ,p_ser_attribute17                =>  p_ser_attribute17
      ,p_ser_attribute18                =>  p_ser_attribute18
      ,p_ser_attribute19                =>  p_ser_attribute19
      ,p_ser_attribute20                =>  p_ser_attribute20
      ,p_ser_attribute21                =>  p_ser_attribute21
      ,p_ser_attribute22                =>  p_ser_attribute22
      ,p_ser_attribute23                =>  p_ser_attribute23
      ,p_ser_attribute24                =>  p_ser_attribute24
      ,p_ser_attribute25                =>  p_ser_attribute25
      ,p_ser_attribute26                =>  p_ser_attribute26
      ,p_ser_attribute27                =>  p_ser_attribute27
      ,p_ser_attribute28                =>  p_ser_attribute28
      ,p_ser_attribute29                =>  p_ser_attribute29
      ,p_ser_attribute30                =>  p_ser_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_Schedd_Enrollment_Rl'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_Schedd_Enrollment_Rl
    --
  end;
  --
  ben_ser_ins.ins
    (
     p_schedd_enrt_rl_id             => l_schedd_enrt_rl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_ordr_to_aply_num              => p_ordr_to_aply_num
    ,p_enrt_perd_id                  => p_enrt_perd_id
    ,p_formula_id                    => p_formula_id
    ,p_business_group_id             => p_business_group_id
    ,p_ser_attribute_category        => p_ser_attribute_category
    ,p_ser_attribute1                => p_ser_attribute1
    ,p_ser_attribute2                => p_ser_attribute2
    ,p_ser_attribute3                => p_ser_attribute3
    ,p_ser_attribute4                => p_ser_attribute4
    ,p_ser_attribute5                => p_ser_attribute5
    ,p_ser_attribute6                => p_ser_attribute6
    ,p_ser_attribute7                => p_ser_attribute7
    ,p_ser_attribute8                => p_ser_attribute8
    ,p_ser_attribute9                => p_ser_attribute9
    ,p_ser_attribute10               => p_ser_attribute10
    ,p_ser_attribute11               => p_ser_attribute11
    ,p_ser_attribute12               => p_ser_attribute12
    ,p_ser_attribute13               => p_ser_attribute13
    ,p_ser_attribute14               => p_ser_attribute14
    ,p_ser_attribute15               => p_ser_attribute15
    ,p_ser_attribute16               => p_ser_attribute16
    ,p_ser_attribute17               => p_ser_attribute17
    ,p_ser_attribute18               => p_ser_attribute18
    ,p_ser_attribute19               => p_ser_attribute19
    ,p_ser_attribute20               => p_ser_attribute20
    ,p_ser_attribute21               => p_ser_attribute21
    ,p_ser_attribute22               => p_ser_attribute22
    ,p_ser_attribute23               => p_ser_attribute23
    ,p_ser_attribute24               => p_ser_attribute24
    ,p_ser_attribute25               => p_ser_attribute25
    ,p_ser_attribute26               => p_ser_attribute26
    ,p_ser_attribute27               => p_ser_attribute27
    ,p_ser_attribute28               => p_ser_attribute28
    ,p_ser_attribute29               => p_ser_attribute29
    ,p_ser_attribute30               => p_ser_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_Schedd_Enrollment_Rl
    --
    ben_Schedd_Enrollment_Rl_bk1.create_Schedd_Enrollment_Rl_a
      (
       p_schedd_enrt_rl_id              =>  l_schedd_enrt_rl_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_ordr_to_aply_num               =>  p_ordr_to_aply_num
      ,p_enrt_perd_id                   =>  p_enrt_perd_id
      ,p_formula_id                     =>  p_formula_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ser_attribute_category         =>  p_ser_attribute_category
      ,p_ser_attribute1                 =>  p_ser_attribute1
      ,p_ser_attribute2                 =>  p_ser_attribute2
      ,p_ser_attribute3                 =>  p_ser_attribute3
      ,p_ser_attribute4                 =>  p_ser_attribute4
      ,p_ser_attribute5                 =>  p_ser_attribute5
      ,p_ser_attribute6                 =>  p_ser_attribute6
      ,p_ser_attribute7                 =>  p_ser_attribute7
      ,p_ser_attribute8                 =>  p_ser_attribute8
      ,p_ser_attribute9                 =>  p_ser_attribute9
      ,p_ser_attribute10                =>  p_ser_attribute10
      ,p_ser_attribute11                =>  p_ser_attribute11
      ,p_ser_attribute12                =>  p_ser_attribute12
      ,p_ser_attribute13                =>  p_ser_attribute13
      ,p_ser_attribute14                =>  p_ser_attribute14
      ,p_ser_attribute15                =>  p_ser_attribute15
      ,p_ser_attribute16                =>  p_ser_attribute16
      ,p_ser_attribute17                =>  p_ser_attribute17
      ,p_ser_attribute18                =>  p_ser_attribute18
      ,p_ser_attribute19                =>  p_ser_attribute19
      ,p_ser_attribute20                =>  p_ser_attribute20
      ,p_ser_attribute21                =>  p_ser_attribute21
      ,p_ser_attribute22                =>  p_ser_attribute22
      ,p_ser_attribute23                =>  p_ser_attribute23
      ,p_ser_attribute24                =>  p_ser_attribute24
      ,p_ser_attribute25                =>  p_ser_attribute25
      ,p_ser_attribute26                =>  p_ser_attribute26
      ,p_ser_attribute27                =>  p_ser_attribute27
      ,p_ser_attribute28                =>  p_ser_attribute28
      ,p_ser_attribute29                =>  p_ser_attribute29
      ,p_ser_attribute30                =>  p_ser_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_Schedd_Enrollment_Rl'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_Schedd_Enrollment_Rl
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
  p_schedd_enrt_rl_id := l_schedd_enrt_rl_id;
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
    ROLLBACK TO create_Schedd_Enrollment_Rl;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_schedd_enrt_rl_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_Schedd_Enrollment_Rl;
    p_schedd_enrt_rl_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    raise;
    --
end create_Schedd_Enrollment_Rl;
-- ----------------------------------------------------------------------------
-- |------------------------< update_Schedd_Enrollment_Rl >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_Schedd_Enrollment_Rl
  (p_validate                       in  boolean   default false
  ,p_schedd_enrt_rl_id              in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_ordr_to_aply_num               in  number    default hr_api.g_number
  ,p_enrt_perd_id                   in  number    default hr_api.g_number
  ,p_formula_id                     in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_ser_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_ser_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_ser_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_ser_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_ser_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_ser_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_ser_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_ser_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_ser_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_ser_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_ser_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_ser_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_ser_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_ser_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_ser_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_ser_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_ser_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_ser_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_ser_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_ser_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_ser_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_ser_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_ser_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_ser_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_ser_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_ser_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_ser_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_ser_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_ser_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_ser_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_ser_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Schedd_Enrollment_Rl';
  l_object_version_number ben_schedd_enrt_rl_f.object_version_number%TYPE;
  l_effective_start_date ben_schedd_enrt_rl_f.effective_start_date%TYPE;
  l_effective_end_date ben_schedd_enrt_rl_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_Schedd_Enrollment_Rl;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_Schedd_Enrollment_Rl
    --
    ben_Schedd_Enrollment_Rl_bk2.update_Schedd_Enrollment_Rl_b
      (
       p_schedd_enrt_rl_id              =>  p_schedd_enrt_rl_id
      ,p_ordr_to_aply_num               =>  p_ordr_to_aply_num
      ,p_enrt_perd_id                   =>  p_enrt_perd_id
      ,p_formula_id                     =>  p_formula_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ser_attribute_category         =>  p_ser_attribute_category
      ,p_ser_attribute1                 =>  p_ser_attribute1
      ,p_ser_attribute2                 =>  p_ser_attribute2
      ,p_ser_attribute3                 =>  p_ser_attribute3
      ,p_ser_attribute4                 =>  p_ser_attribute4
      ,p_ser_attribute5                 =>  p_ser_attribute5
      ,p_ser_attribute6                 =>  p_ser_attribute6
      ,p_ser_attribute7                 =>  p_ser_attribute7
      ,p_ser_attribute8                 =>  p_ser_attribute8
      ,p_ser_attribute9                 =>  p_ser_attribute9
      ,p_ser_attribute10                =>  p_ser_attribute10
      ,p_ser_attribute11                =>  p_ser_attribute11
      ,p_ser_attribute12                =>  p_ser_attribute12
      ,p_ser_attribute13                =>  p_ser_attribute13
      ,p_ser_attribute14                =>  p_ser_attribute14
      ,p_ser_attribute15                =>  p_ser_attribute15
      ,p_ser_attribute16                =>  p_ser_attribute16
      ,p_ser_attribute17                =>  p_ser_attribute17
      ,p_ser_attribute18                =>  p_ser_attribute18
      ,p_ser_attribute19                =>  p_ser_attribute19
      ,p_ser_attribute20                =>  p_ser_attribute20
      ,p_ser_attribute21                =>  p_ser_attribute21
      ,p_ser_attribute22                =>  p_ser_attribute22
      ,p_ser_attribute23                =>  p_ser_attribute23
      ,p_ser_attribute24                =>  p_ser_attribute24
      ,p_ser_attribute25                =>  p_ser_attribute25
      ,p_ser_attribute26                =>  p_ser_attribute26
      ,p_ser_attribute27                =>  p_ser_attribute27
      ,p_ser_attribute28                =>  p_ser_attribute28
      ,p_ser_attribute29                =>  p_ser_attribute29
      ,p_ser_attribute30                =>  p_ser_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Schedd_Enrollment_Rl'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_Schedd_Enrollment_Rl
    --
  end;
  --
  ben_ser_upd.upd
    (
     p_schedd_enrt_rl_id             => p_schedd_enrt_rl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_ordr_to_aply_num              => p_ordr_to_aply_num
    ,p_enrt_perd_id                  => p_enrt_perd_id
    ,p_formula_id                    => p_formula_id
    ,p_business_group_id             => p_business_group_id
    ,p_ser_attribute_category        => p_ser_attribute_category
    ,p_ser_attribute1                => p_ser_attribute1
    ,p_ser_attribute2                => p_ser_attribute2
    ,p_ser_attribute3                => p_ser_attribute3
    ,p_ser_attribute4                => p_ser_attribute4
    ,p_ser_attribute5                => p_ser_attribute5
    ,p_ser_attribute6                => p_ser_attribute6
    ,p_ser_attribute7                => p_ser_attribute7
    ,p_ser_attribute8                => p_ser_attribute8
    ,p_ser_attribute9                => p_ser_attribute9
    ,p_ser_attribute10               => p_ser_attribute10
    ,p_ser_attribute11               => p_ser_attribute11
    ,p_ser_attribute12               => p_ser_attribute12
    ,p_ser_attribute13               => p_ser_attribute13
    ,p_ser_attribute14               => p_ser_attribute14
    ,p_ser_attribute15               => p_ser_attribute15
    ,p_ser_attribute16               => p_ser_attribute16
    ,p_ser_attribute17               => p_ser_attribute17
    ,p_ser_attribute18               => p_ser_attribute18
    ,p_ser_attribute19               => p_ser_attribute19
    ,p_ser_attribute20               => p_ser_attribute20
    ,p_ser_attribute21               => p_ser_attribute21
    ,p_ser_attribute22               => p_ser_attribute22
    ,p_ser_attribute23               => p_ser_attribute23
    ,p_ser_attribute24               => p_ser_attribute24
    ,p_ser_attribute25               => p_ser_attribute25
    ,p_ser_attribute26               => p_ser_attribute26
    ,p_ser_attribute27               => p_ser_attribute27
    ,p_ser_attribute28               => p_ser_attribute28
    ,p_ser_attribute29               => p_ser_attribute29
    ,p_ser_attribute30               => p_ser_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_Schedd_Enrollment_Rl
    --
    ben_Schedd_Enrollment_Rl_bk2.update_Schedd_Enrollment_Rl_a
      (
       p_schedd_enrt_rl_id              =>  p_schedd_enrt_rl_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_ordr_to_aply_num               =>  p_ordr_to_aply_num
      ,p_enrt_perd_id                   =>  p_enrt_perd_id
      ,p_formula_id                     =>  p_formula_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ser_attribute_category         =>  p_ser_attribute_category
      ,p_ser_attribute1                 =>  p_ser_attribute1
      ,p_ser_attribute2                 =>  p_ser_attribute2
      ,p_ser_attribute3                 =>  p_ser_attribute3
      ,p_ser_attribute4                 =>  p_ser_attribute4
      ,p_ser_attribute5                 =>  p_ser_attribute5
      ,p_ser_attribute6                 =>  p_ser_attribute6
      ,p_ser_attribute7                 =>  p_ser_attribute7
      ,p_ser_attribute8                 =>  p_ser_attribute8
      ,p_ser_attribute9                 =>  p_ser_attribute9
      ,p_ser_attribute10                =>  p_ser_attribute10
      ,p_ser_attribute11                =>  p_ser_attribute11
      ,p_ser_attribute12                =>  p_ser_attribute12
      ,p_ser_attribute13                =>  p_ser_attribute13
      ,p_ser_attribute14                =>  p_ser_attribute14
      ,p_ser_attribute15                =>  p_ser_attribute15
      ,p_ser_attribute16                =>  p_ser_attribute16
      ,p_ser_attribute17                =>  p_ser_attribute17
      ,p_ser_attribute18                =>  p_ser_attribute18
      ,p_ser_attribute19                =>  p_ser_attribute19
      ,p_ser_attribute20                =>  p_ser_attribute20
      ,p_ser_attribute21                =>  p_ser_attribute21
      ,p_ser_attribute22                =>  p_ser_attribute22
      ,p_ser_attribute23                =>  p_ser_attribute23
      ,p_ser_attribute24                =>  p_ser_attribute24
      ,p_ser_attribute25                =>  p_ser_attribute25
      ,p_ser_attribute26                =>  p_ser_attribute26
      ,p_ser_attribute27                =>  p_ser_attribute27
      ,p_ser_attribute28                =>  p_ser_attribute28
      ,p_ser_attribute29                =>  p_ser_attribute29
      ,p_ser_attribute30                =>  p_ser_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Schedd_Enrollment_Rl'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_Schedd_Enrollment_Rl
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
    ROLLBACK TO update_Schedd_Enrollment_Rl;
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
    ROLLBACK TO update_Schedd_Enrollment_Rl;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end update_Schedd_Enrollment_Rl;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Schedd_Enrollment_Rl >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Schedd_Enrollment_Rl
  (p_validate                       in  boolean  default false
  ,p_schedd_enrt_rl_id              in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Schedd_Enrollment_Rl';
  l_object_version_number ben_schedd_enrt_rl_f.object_version_number%TYPE;
  l_effective_start_date ben_schedd_enrt_rl_f.effective_start_date%TYPE;
  l_effective_end_date ben_schedd_enrt_rl_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_Schedd_Enrollment_Rl;
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
    -- Start of API User Hook for the before hook of delete_Schedd_Enrollment_Rl
    --
    ben_Schedd_Enrollment_Rl_bk3.delete_Schedd_Enrollment_Rl_b
      (
       p_schedd_enrt_rl_id              =>  p_schedd_enrt_rl_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Schedd_Enrollment_Rl'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_Schedd_Enrollment_Rl
    --
  end;
  --
  ben_ser_del.del
    (
     p_schedd_enrt_rl_id             => p_schedd_enrt_rl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_Schedd_Enrollment_Rl
    --
    ben_Schedd_Enrollment_Rl_bk3.delete_Schedd_Enrollment_Rl_a
      (
       p_schedd_enrt_rl_id              =>  p_schedd_enrt_rl_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Schedd_Enrollment_Rl'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_Schedd_Enrollment_Rl
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
    ROLLBACK TO delete_Schedd_Enrollment_Rl;
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
    ROLLBACK TO delete_Schedd_Enrollment_Rl;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end delete_Schedd_Enrollment_Rl;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_schedd_enrt_rl_id                   in     number
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
  ben_ser_shd.lck
    (
      p_schedd_enrt_rl_id                 => p_schedd_enrt_rl_id
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
end ben_Schedd_Enrollment_Rl_api;

/
