--------------------------------------------------------
--  DDL for Package Body BEN_OPTION_IN_PLAN_IN_PGM_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_OPTION_IN_PLAN_IN_PGM_API" as
/* $Header: beoppapi.pkb 115.3 2003/09/25 00:28:28 rpgupta ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_option_in_plan_in_pgm_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_option_in_plan_in_pgm >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_option_in_plan_in_pgm
  (p_validate                       in  boolean   default false
  ,p_oiplip_id                      out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_oipl_id                        in  number    default null
  ,p_plip_id                        in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_legislation_code         in  varchar2  default null
  ,p_legislation_subgroup         in  varchar2  default null
  ,p_opp_attribute_category         in  varchar2  default null
  ,p_opp_attribute1                 in  varchar2  default null
  ,p_opp_attribute2                 in  varchar2  default null
  ,p_opp_attribute3                 in  varchar2  default null
  ,p_opp_attribute4                 in  varchar2  default null
  ,p_opp_attribute5                 in  varchar2  default null
  ,p_opp_attribute6                 in  varchar2  default null
  ,p_opp_attribute7                 in  varchar2  default null
  ,p_opp_attribute8                 in  varchar2  default null
  ,p_opp_attribute9                 in  varchar2  default null
  ,p_opp_attribute10                in  varchar2  default null
  ,p_opp_attribute11                in  varchar2  default null
  ,p_opp_attribute12                in  varchar2  default null
  ,p_opp_attribute13                in  varchar2  default null
  ,p_opp_attribute14                in  varchar2  default null
  ,p_opp_attribute15                in  varchar2  default null
  ,p_opp_attribute16                in  varchar2  default null
  ,p_opp_attribute17                in  varchar2  default null
  ,p_opp_attribute18                in  varchar2  default null
  ,p_opp_attribute19                in  varchar2  default null
  ,p_opp_attribute20                in  varchar2  default null
  ,p_opp_attribute21                in  varchar2  default null
  ,p_opp_attribute22                in  varchar2  default null
  ,p_opp_attribute23                in  varchar2  default null
  ,p_opp_attribute24                in  varchar2  default null
  ,p_opp_attribute25                in  varchar2  default null
  ,p_opp_attribute26                in  varchar2  default null
  ,p_opp_attribute27                in  varchar2  default null
  ,p_opp_attribute28                in  varchar2  default null
  ,p_opp_attribute29                in  varchar2  default null
  ,p_opp_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_oiplip_id ben_oiplip_f.oiplip_id%TYPE;
  l_effective_start_date ben_oiplip_f.effective_start_date%TYPE;
  l_effective_end_date ben_oiplip_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_option_in_plan_in_pgm';
  l_object_version_number ben_oiplip_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_option_in_plan_in_pgm;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for before hook of create_option_in_plan_in_pgm
    --
    ben_option_in_plan_in_pgm_bk1.create_option_in_plan_in_pgm_b
      (
       p_oipl_id                        =>  p_oipl_id
      ,p_plip_id                        =>  p_plip_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code         =>  p_legislation_code
      ,p_legislation_subgroup         =>  p_legislation_subgroup
      ,p_opp_attribute_category         =>  p_opp_attribute_category
      ,p_opp_attribute1                 =>  p_opp_attribute1
      ,p_opp_attribute2                 =>  p_opp_attribute2
      ,p_opp_attribute3                 =>  p_opp_attribute3
      ,p_opp_attribute4                 =>  p_opp_attribute4
      ,p_opp_attribute5                 =>  p_opp_attribute5
      ,p_opp_attribute6                 =>  p_opp_attribute6
      ,p_opp_attribute7                 =>  p_opp_attribute7
      ,p_opp_attribute8                 =>  p_opp_attribute8
      ,p_opp_attribute9                 =>  p_opp_attribute9
      ,p_opp_attribute10                =>  p_opp_attribute10
      ,p_opp_attribute11                =>  p_opp_attribute11
      ,p_opp_attribute12                =>  p_opp_attribute12
      ,p_opp_attribute13                =>  p_opp_attribute13
      ,p_opp_attribute14                =>  p_opp_attribute14
      ,p_opp_attribute15                =>  p_opp_attribute15
      ,p_opp_attribute16                =>  p_opp_attribute16
      ,p_opp_attribute17                =>  p_opp_attribute17
      ,p_opp_attribute18                =>  p_opp_attribute18
      ,p_opp_attribute19                =>  p_opp_attribute19
      ,p_opp_attribute20                =>  p_opp_attribute20
      ,p_opp_attribute21                =>  p_opp_attribute21
      ,p_opp_attribute22                =>  p_opp_attribute22
      ,p_opp_attribute23                =>  p_opp_attribute23
      ,p_opp_attribute24                =>  p_opp_attribute24
      ,p_opp_attribute25                =>  p_opp_attribute25
      ,p_opp_attribute26                =>  p_opp_attribute26
      ,p_opp_attribute27                =>  p_opp_attribute27
      ,p_opp_attribute28                =>  p_opp_attribute28
      ,p_opp_attribute29                =>  p_opp_attribute29
      ,p_opp_attribute30                =>  p_opp_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_option_in_plan_in_pgm'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_option_in_plan_in_pgm
    --
  end;
  --
  ben_opp_ins.ins
    (
     p_oiplip_id                     => l_oiplip_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_oipl_id                       => p_oipl_id
    ,p_plip_id                       => p_plip_id
    ,p_business_group_id             => p_business_group_id
    ,p_legislation_code        => p_legislation_code
    ,p_legislation_subgroup        => p_legislation_subgroup
    ,p_opp_attribute_category        => p_opp_attribute_category
    ,p_opp_attribute1                => p_opp_attribute1
    ,p_opp_attribute2                => p_opp_attribute2
    ,p_opp_attribute3                => p_opp_attribute3
    ,p_opp_attribute4                => p_opp_attribute4
    ,p_opp_attribute5                => p_opp_attribute5
    ,p_opp_attribute6                => p_opp_attribute6
    ,p_opp_attribute7                => p_opp_attribute7
    ,p_opp_attribute8                => p_opp_attribute8
    ,p_opp_attribute9                => p_opp_attribute9
    ,p_opp_attribute10               => p_opp_attribute10
    ,p_opp_attribute11               => p_opp_attribute11
    ,p_opp_attribute12               => p_opp_attribute12
    ,p_opp_attribute13               => p_opp_attribute13
    ,p_opp_attribute14               => p_opp_attribute14
    ,p_opp_attribute15               => p_opp_attribute15
    ,p_opp_attribute16               => p_opp_attribute16
    ,p_opp_attribute17               => p_opp_attribute17
    ,p_opp_attribute18               => p_opp_attribute18
    ,p_opp_attribute19               => p_opp_attribute19
    ,p_opp_attribute20               => p_opp_attribute20
    ,p_opp_attribute21               => p_opp_attribute21
    ,p_opp_attribute22               => p_opp_attribute22
    ,p_opp_attribute23               => p_opp_attribute23
    ,p_opp_attribute24               => p_opp_attribute24
    ,p_opp_attribute25               => p_opp_attribute25
    ,p_opp_attribute26               => p_opp_attribute26
    ,p_opp_attribute27               => p_opp_attribute27
    ,p_opp_attribute28               => p_opp_attribute28
    ,p_opp_attribute29               => p_opp_attribute29
    ,p_opp_attribute30               => p_opp_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_option_in_plan_in_pgm
    --
    ben_option_in_plan_in_pgm_bk1.create_option_in_plan_in_pgm_a
      (
       p_oiplip_id                      =>  l_oiplip_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_oipl_id                        =>  p_oipl_id
      ,p_plip_id                        =>  p_plip_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code         =>  p_legislation_code
      ,p_legislation_subgroup         =>  p_legislation_subgroup
      ,p_opp_attribute_category         =>  p_opp_attribute_category
      ,p_opp_attribute1                 =>  p_opp_attribute1
      ,p_opp_attribute2                 =>  p_opp_attribute2
      ,p_opp_attribute3                 =>  p_opp_attribute3
      ,p_opp_attribute4                 =>  p_opp_attribute4
      ,p_opp_attribute5                 =>  p_opp_attribute5
      ,p_opp_attribute6                 =>  p_opp_attribute6
      ,p_opp_attribute7                 =>  p_opp_attribute7
      ,p_opp_attribute8                 =>  p_opp_attribute8
      ,p_opp_attribute9                 =>  p_opp_attribute9
      ,p_opp_attribute10                =>  p_opp_attribute10
      ,p_opp_attribute11                =>  p_opp_attribute11
      ,p_opp_attribute12                =>  p_opp_attribute12
      ,p_opp_attribute13                =>  p_opp_attribute13
      ,p_opp_attribute14                =>  p_opp_attribute14
      ,p_opp_attribute15                =>  p_opp_attribute15
      ,p_opp_attribute16                =>  p_opp_attribute16
      ,p_opp_attribute17                =>  p_opp_attribute17
      ,p_opp_attribute18                =>  p_opp_attribute18
      ,p_opp_attribute19                =>  p_opp_attribute19
      ,p_opp_attribute20                =>  p_opp_attribute20
      ,p_opp_attribute21                =>  p_opp_attribute21
      ,p_opp_attribute22                =>  p_opp_attribute22
      ,p_opp_attribute23                =>  p_opp_attribute23
      ,p_opp_attribute24                =>  p_opp_attribute24
      ,p_opp_attribute25                =>  p_opp_attribute25
      ,p_opp_attribute26                =>  p_opp_attribute26
      ,p_opp_attribute27                =>  p_opp_attribute27
      ,p_opp_attribute28                =>  p_opp_attribute28
      ,p_opp_attribute29                =>  p_opp_attribute29
      ,p_opp_attribute30                =>  p_opp_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_option_in_plan_in_pgm'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_option_in_plan_in_pgm
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
  p_oiplip_id := l_oiplip_id;
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
    ROLLBACK TO create_option_in_plan_in_pgm;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_oiplip_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_option_in_plan_in_pgm;
    -- NOCOPY Changes
    p_oiplip_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    -- NOCOPY Changes
    raise;
    --
end create_option_in_plan_in_pgm;
-- ----------------------------------------------------------------------------
-- |------------------------< update_option_in_plan_in_pgm >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_option_in_plan_in_pgm
  (p_validate                       in  boolean   default false
  ,p_oiplip_id                      in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_oipl_id                        in  number    default hr_api.g_number
  ,p_plip_id                        in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_legislation_code         in  varchar2  default hr_api.g_varchar2
  ,p_legislation_subgroup         in  varchar2  default hr_api.g_varchar2
  ,p_opp_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_opp_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_opp_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_opp_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_opp_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_opp_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_opp_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_opp_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_opp_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_opp_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_opp_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_opp_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_opp_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_opp_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_opp_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_opp_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_opp_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_opp_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_opp_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_opp_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_opp_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_opp_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_opp_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_opp_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_opp_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_opp_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_opp_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_opp_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_opp_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_opp_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_opp_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_option_in_plan_in_pgm';
  l_object_version_number ben_oiplip_f.object_version_number%TYPE;
  l_effective_start_date ben_oiplip_f.effective_start_date%TYPE;
  l_effective_end_date ben_oiplip_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_option_in_plan_in_pgm;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for before hook of update_option_in_plan_in_pgm
    --
    ben_option_in_plan_in_pgm_bk2.update_option_in_plan_in_pgm_b
      (
       p_oiplip_id                      =>  p_oiplip_id
      ,p_oipl_id                        =>  p_oipl_id
      ,p_plip_id                        =>  p_plip_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code         =>  p_legislation_code
      ,p_legislation_subgroup         =>  p_legislation_subgroup
      ,p_opp_attribute_category         =>  p_opp_attribute_category
      ,p_opp_attribute1                 =>  p_opp_attribute1
      ,p_opp_attribute2                 =>  p_opp_attribute2
      ,p_opp_attribute3                 =>  p_opp_attribute3
      ,p_opp_attribute4                 =>  p_opp_attribute4
      ,p_opp_attribute5                 =>  p_opp_attribute5
      ,p_opp_attribute6                 =>  p_opp_attribute6
      ,p_opp_attribute7                 =>  p_opp_attribute7
      ,p_opp_attribute8                 =>  p_opp_attribute8
      ,p_opp_attribute9                 =>  p_opp_attribute9
      ,p_opp_attribute10                =>  p_opp_attribute10
      ,p_opp_attribute11                =>  p_opp_attribute11
      ,p_opp_attribute12                =>  p_opp_attribute12
      ,p_opp_attribute13                =>  p_opp_attribute13
      ,p_opp_attribute14                =>  p_opp_attribute14
      ,p_opp_attribute15                =>  p_opp_attribute15
      ,p_opp_attribute16                =>  p_opp_attribute16
      ,p_opp_attribute17                =>  p_opp_attribute17
      ,p_opp_attribute18                =>  p_opp_attribute18
      ,p_opp_attribute19                =>  p_opp_attribute19
      ,p_opp_attribute20                =>  p_opp_attribute20
      ,p_opp_attribute21                =>  p_opp_attribute21
      ,p_opp_attribute22                =>  p_opp_attribute22
      ,p_opp_attribute23                =>  p_opp_attribute23
      ,p_opp_attribute24                =>  p_opp_attribute24
      ,p_opp_attribute25                =>  p_opp_attribute25
      ,p_opp_attribute26                =>  p_opp_attribute26
      ,p_opp_attribute27                =>  p_opp_attribute27
      ,p_opp_attribute28                =>  p_opp_attribute28
      ,p_opp_attribute29                =>  p_opp_attribute29
      ,p_opp_attribute30                =>  p_opp_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_option_in_plan_in_pgm'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_option_in_plan_in_pgm
    --
  end;
  --
  ben_opp_upd.upd
    (
     p_oiplip_id                     => p_oiplip_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_oipl_id                       => p_oipl_id
    ,p_plip_id                       => p_plip_id
    ,p_business_group_id             => p_business_group_id
    ,p_legislation_code        => p_legislation_code
    ,p_legislation_subgroup        => p_legislation_subgroup
    ,p_opp_attribute_category        => p_opp_attribute_category
    ,p_opp_attribute1                => p_opp_attribute1
    ,p_opp_attribute2                => p_opp_attribute2
    ,p_opp_attribute3                => p_opp_attribute3
    ,p_opp_attribute4                => p_opp_attribute4
    ,p_opp_attribute5                => p_opp_attribute5
    ,p_opp_attribute6                => p_opp_attribute6
    ,p_opp_attribute7                => p_opp_attribute7
    ,p_opp_attribute8                => p_opp_attribute8
    ,p_opp_attribute9                => p_opp_attribute9
    ,p_opp_attribute10               => p_opp_attribute10
    ,p_opp_attribute11               => p_opp_attribute11
    ,p_opp_attribute12               => p_opp_attribute12
    ,p_opp_attribute13               => p_opp_attribute13
    ,p_opp_attribute14               => p_opp_attribute14
    ,p_opp_attribute15               => p_opp_attribute15
    ,p_opp_attribute16               => p_opp_attribute16
    ,p_opp_attribute17               => p_opp_attribute17
    ,p_opp_attribute18               => p_opp_attribute18
    ,p_opp_attribute19               => p_opp_attribute19
    ,p_opp_attribute20               => p_opp_attribute20
    ,p_opp_attribute21               => p_opp_attribute21
    ,p_opp_attribute22               => p_opp_attribute22
    ,p_opp_attribute23               => p_opp_attribute23
    ,p_opp_attribute24               => p_opp_attribute24
    ,p_opp_attribute25               => p_opp_attribute25
    ,p_opp_attribute26               => p_opp_attribute26
    ,p_opp_attribute27               => p_opp_attribute27
    ,p_opp_attribute28               => p_opp_attribute28
    ,p_opp_attribute29               => p_opp_attribute29
    ,p_opp_attribute30               => p_opp_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_option_in_plan_in_pgm
    --
    ben_option_in_plan_in_pgm_bk2.update_option_in_plan_in_pgm_a
      (
       p_oiplip_id                      =>  p_oiplip_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_oipl_id                        =>  p_oipl_id
      ,p_plip_id                        =>  p_plip_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code         =>  p_legislation_code
      ,p_legislation_subgroup         =>  p_legislation_subgroup
      ,p_opp_attribute_category         =>  p_opp_attribute_category
      ,p_opp_attribute1                 =>  p_opp_attribute1
      ,p_opp_attribute2                 =>  p_opp_attribute2
      ,p_opp_attribute3                 =>  p_opp_attribute3
      ,p_opp_attribute4                 =>  p_opp_attribute4
      ,p_opp_attribute5                 =>  p_opp_attribute5
      ,p_opp_attribute6                 =>  p_opp_attribute6
      ,p_opp_attribute7                 =>  p_opp_attribute7
      ,p_opp_attribute8                 =>  p_opp_attribute8
      ,p_opp_attribute9                 =>  p_opp_attribute9
      ,p_opp_attribute10                =>  p_opp_attribute10
      ,p_opp_attribute11                =>  p_opp_attribute11
      ,p_opp_attribute12                =>  p_opp_attribute12
      ,p_opp_attribute13                =>  p_opp_attribute13
      ,p_opp_attribute14                =>  p_opp_attribute14
      ,p_opp_attribute15                =>  p_opp_attribute15
      ,p_opp_attribute16                =>  p_opp_attribute16
      ,p_opp_attribute17                =>  p_opp_attribute17
      ,p_opp_attribute18                =>  p_opp_attribute18
      ,p_opp_attribute19                =>  p_opp_attribute19
      ,p_opp_attribute20                =>  p_opp_attribute20
      ,p_opp_attribute21                =>  p_opp_attribute21
      ,p_opp_attribute22                =>  p_opp_attribute22
      ,p_opp_attribute23                =>  p_opp_attribute23
      ,p_opp_attribute24                =>  p_opp_attribute24
      ,p_opp_attribute25                =>  p_opp_attribute25
      ,p_opp_attribute26                =>  p_opp_attribute26
      ,p_opp_attribute27                =>  p_opp_attribute27
      ,p_opp_attribute28                =>  p_opp_attribute28
      ,p_opp_attribute29                =>  p_opp_attribute29
      ,p_opp_attribute30                =>  p_opp_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_option_in_plan_in_pgm'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_option_in_plan_in_pgm
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
    ROLLBACK TO update_option_in_plan_in_pgm;
    --
	-- NOCOPY Changes
    p_effective_start_date := null;
    p_effective_end_date := null;
    -- NOCOPY Changes

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
    ROLLBACK TO update_option_in_plan_in_pgm;
    -- NOCOPY Changes
    p_effective_start_date := null;
    p_effective_end_date := null;
    -- NOCOPY Changes

    raise;
    --
end update_option_in_plan_in_pgm;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_option_in_plan_in_pgm >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_option_in_plan_in_pgm
  (p_validate                       in  boolean  default false
  ,p_oiplip_id                      in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_option_in_plan_in_pgm';
  l_object_version_number ben_oiplip_f.object_version_number%TYPE;
  l_effective_start_date ben_oiplip_f.effective_start_date%TYPE;
  l_effective_end_date ben_oiplip_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_option_in_plan_in_pgm;
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
    -- Start of API User Hook for before hook of delete_option_in_plan_in_pgm
    --
    ben_option_in_plan_in_pgm_bk3.delete_option_in_plan_in_pgm_b
      (
       p_oiplip_id                      =>  p_oiplip_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_option_in_plan_in_pgm'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_option_in_plan_in_pgm
    --
  end;
  --
  ben_opp_del.del
    (
     p_oiplip_id                     => p_oiplip_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_option_in_plan_in_pgm
    --
    ben_option_in_plan_in_pgm_bk3.delete_option_in_plan_in_pgm_a
      (
       p_oiplip_id                      =>  p_oiplip_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_option_in_plan_in_pgm'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_option_in_plan_in_pgm
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
    ROLLBACK TO delete_option_in_plan_in_pgm;
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
    ROLLBACK TO delete_option_in_plan_in_pgm;
	-- NOCOPY Changes
	p_effective_start_date := null;
	p_effective_end_date := null;
	-- NOCOPY Changes
    raise;
    --
end delete_option_in_plan_in_pgm;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_oiplip_id                   in     number
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
  ben_opp_shd.lck
    (
      p_oiplip_id                 => p_oiplip_id
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
end ben_option_in_plan_in_pgm_api;

/
