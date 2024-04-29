--------------------------------------------------------
--  DDL for Package Body BEN_ELIG_MRTL_STS_PRTE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ELIG_MRTL_STS_PRTE_API" as
/* $Header: beempapi.pkb 120.0 2005/05/28 02:25:20 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_elig_mrtl_sts_prte_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_elig_mrtl_sts_prte >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_elig_mrtl_sts_prte
  (p_validate                       in  boolean   default false
  ,p_elig_mrtl_sts_prte_id          out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_excld_flag                     in  varchar2  default null
  ,p_marital_status                 in  varchar2  default null
  ,p_eligy_prfl_id                  in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_emp_attribute_category         in  varchar2  default null
  ,p_emp_attribute1                 in  varchar2  default null
  ,p_emp_attribute2                 in  varchar2  default null
  ,p_emp_attribute3                 in  varchar2  default null
  ,p_emp_attribute4                 in  varchar2  default null
  ,p_emp_attribute5                 in  varchar2  default null
  ,p_emp_attribute6                 in  varchar2  default null
  ,p_emp_attribute7                 in  varchar2  default null
  ,p_emp_attribute8                 in  varchar2  default null
  ,p_emp_attribute9                 in  varchar2  default null
  ,p_emp_attribute10                in  varchar2  default null
  ,p_emp_attribute11                in  varchar2  default null
  ,p_emp_attribute12                in  varchar2  default null
  ,p_emp_attribute13                in  varchar2  default null
  ,p_emp_attribute14                in  varchar2  default null
  ,p_emp_attribute15                in  varchar2  default null
  ,p_emp_attribute16                in  varchar2  default null
  ,p_emp_attribute17                in  varchar2  default null
  ,p_emp_attribute18                in  varchar2  default null
  ,p_emp_attribute19                in  varchar2  default null
  ,p_emp_attribute20                in  varchar2  default null
  ,p_emp_attribute21                in  varchar2  default null
  ,p_emp_attribute22                in  varchar2  default null
  ,p_emp_attribute23                in  varchar2  default null
  ,p_emp_attribute24                in  varchar2  default null
  ,p_emp_attribute25                in  varchar2  default null
  ,p_emp_attribute26                in  varchar2  default null
  ,p_emp_attribute27                in  varchar2  default null
  ,p_emp_attribute28                in  varchar2  default null
  ,p_emp_attribute29                in  varchar2  default null
  ,p_emp_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_criteria_score                 in number     default null
  ,p_criteria_weight                in  number    default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_elig_mrtl_sts_prte_id ben_elig_mrtl_sts_prte_f.elig_mrtl_sts_prte_id%TYPE;
  l_effective_start_date ben_elig_mrtl_sts_prte_f.effective_start_date%TYPE;
  l_effective_end_date ben_elig_mrtl_sts_prte_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_elig_mrtl_sts_prte';
  l_object_version_number ben_elig_mrtl_sts_prte_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_elig_mrtl_sts_prte;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_elig_mrtl_sts_prte
    --
    ben_elig_mrtl_sts_prte_bk1.create_elig_mrtl_sts_prte_b
      (
       p_excld_flag                     =>  p_excld_flag
      ,p_marital_status                 =>  p_marital_status
      ,p_eligy_prfl_id                  =>  p_eligy_prfl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_emp_attribute_category         =>  p_emp_attribute_category
      ,p_emp_attribute1                 =>  p_emp_attribute1
      ,p_emp_attribute2                 =>  p_emp_attribute2
      ,p_emp_attribute3                 =>  p_emp_attribute3
      ,p_emp_attribute4                 =>  p_emp_attribute4
      ,p_emp_attribute5                 =>  p_emp_attribute5
      ,p_emp_attribute6                 =>  p_emp_attribute6
      ,p_emp_attribute7                 =>  p_emp_attribute7
      ,p_emp_attribute8                 =>  p_emp_attribute8
      ,p_emp_attribute9                 =>  p_emp_attribute9
      ,p_emp_attribute10                =>  p_emp_attribute10
      ,p_emp_attribute11                =>  p_emp_attribute11
      ,p_emp_attribute12                =>  p_emp_attribute12
      ,p_emp_attribute13                =>  p_emp_attribute13
      ,p_emp_attribute14                =>  p_emp_attribute14
      ,p_emp_attribute15                =>  p_emp_attribute15
      ,p_emp_attribute16                =>  p_emp_attribute16
      ,p_emp_attribute17                =>  p_emp_attribute17
      ,p_emp_attribute18                =>  p_emp_attribute18
      ,p_emp_attribute19                =>  p_emp_attribute19
      ,p_emp_attribute20                =>  p_emp_attribute20
      ,p_emp_attribute21                =>  p_emp_attribute21
      ,p_emp_attribute22                =>  p_emp_attribute22
      ,p_emp_attribute23                =>  p_emp_attribute23
      ,p_emp_attribute24                =>  p_emp_attribute24
      ,p_emp_attribute25                =>  p_emp_attribute25
      ,p_emp_attribute26                =>  p_emp_attribute26
      ,p_emp_attribute27                =>  p_emp_attribute27
      ,p_emp_attribute28                =>  p_emp_attribute28
      ,p_emp_attribute29                =>  p_emp_attribute29
      ,p_emp_attribute30                =>  p_emp_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_criteria_score                 =>  p_criteria_score
      ,p_criteria_weight                =>  p_criteria_weight
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_elig_mrtl_sts_prte'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_elig_mrtl_sts_prte
    --
  end;
  --
  ben_emp_ins.ins
    (
     p_elig_mrtl_sts_prte_id         => l_elig_mrtl_sts_prte_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_excld_flag                    => p_excld_flag
    ,p_marital_status                => p_marital_status
    ,p_eligy_prfl_id                 => p_eligy_prfl_id
    ,p_business_group_id             => p_business_group_id
    ,p_emp_attribute_category        => p_emp_attribute_category
    ,p_emp_attribute1                => p_emp_attribute1
    ,p_emp_attribute2                => p_emp_attribute2
    ,p_emp_attribute3                => p_emp_attribute3
    ,p_emp_attribute4                => p_emp_attribute4
    ,p_emp_attribute5                => p_emp_attribute5
    ,p_emp_attribute6                => p_emp_attribute6
    ,p_emp_attribute7                => p_emp_attribute7
    ,p_emp_attribute8                => p_emp_attribute8
    ,p_emp_attribute9                => p_emp_attribute9
    ,p_emp_attribute10               => p_emp_attribute10
    ,p_emp_attribute11               => p_emp_attribute11
    ,p_emp_attribute12               => p_emp_attribute12
    ,p_emp_attribute13               => p_emp_attribute13
    ,p_emp_attribute14               => p_emp_attribute14
    ,p_emp_attribute15               => p_emp_attribute15
    ,p_emp_attribute16               => p_emp_attribute16
    ,p_emp_attribute17               => p_emp_attribute17
    ,p_emp_attribute18               => p_emp_attribute18
    ,p_emp_attribute19               => p_emp_attribute19
    ,p_emp_attribute20               => p_emp_attribute20
    ,p_emp_attribute21               => p_emp_attribute21
    ,p_emp_attribute22               => p_emp_attribute22
    ,p_emp_attribute23               => p_emp_attribute23
    ,p_emp_attribute24               => p_emp_attribute24
    ,p_emp_attribute25               => p_emp_attribute25
    ,p_emp_attribute26               => p_emp_attribute26
    ,p_emp_attribute27               => p_emp_attribute27
    ,p_emp_attribute28               => p_emp_attribute28
    ,p_emp_attribute29               => p_emp_attribute29
    ,p_emp_attribute30               => p_emp_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_criteria_score                =>  p_criteria_score
    ,p_criteria_weight               =>  p_criteria_weight
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_elig_mrtl_sts_prte
    --
    ben_elig_mrtl_sts_prte_bk1.create_elig_mrtl_sts_prte_a
      (
       p_elig_mrtl_sts_prte_id          =>  l_elig_mrtl_sts_prte_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_excld_flag                     =>  p_excld_flag
      ,p_marital_status                 =>  p_marital_status
      ,p_eligy_prfl_id                  =>  p_eligy_prfl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_emp_attribute_category         =>  p_emp_attribute_category
      ,p_emp_attribute1                 =>  p_emp_attribute1
      ,p_emp_attribute2                 =>  p_emp_attribute2
      ,p_emp_attribute3                 =>  p_emp_attribute3
      ,p_emp_attribute4                 =>  p_emp_attribute4
      ,p_emp_attribute5                 =>  p_emp_attribute5
      ,p_emp_attribute6                 =>  p_emp_attribute6
      ,p_emp_attribute7                 =>  p_emp_attribute7
      ,p_emp_attribute8                 =>  p_emp_attribute8
      ,p_emp_attribute9                 =>  p_emp_attribute9
      ,p_emp_attribute10                =>  p_emp_attribute10
      ,p_emp_attribute11                =>  p_emp_attribute11
      ,p_emp_attribute12                =>  p_emp_attribute12
      ,p_emp_attribute13                =>  p_emp_attribute13
      ,p_emp_attribute14                =>  p_emp_attribute14
      ,p_emp_attribute15                =>  p_emp_attribute15
      ,p_emp_attribute16                =>  p_emp_attribute16
      ,p_emp_attribute17                =>  p_emp_attribute17
      ,p_emp_attribute18                =>  p_emp_attribute18
      ,p_emp_attribute19                =>  p_emp_attribute19
      ,p_emp_attribute20                =>  p_emp_attribute20
      ,p_emp_attribute21                =>  p_emp_attribute21
      ,p_emp_attribute22                =>  p_emp_attribute22
      ,p_emp_attribute23                =>  p_emp_attribute23
      ,p_emp_attribute24                =>  p_emp_attribute24
      ,p_emp_attribute25                =>  p_emp_attribute25
      ,p_emp_attribute26                =>  p_emp_attribute26
      ,p_emp_attribute27                =>  p_emp_attribute27
      ,p_emp_attribute28                =>  p_emp_attribute28
      ,p_emp_attribute29                =>  p_emp_attribute29
      ,p_emp_attribute30                =>  p_emp_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_criteria_score                 =>  p_criteria_score
      ,p_criteria_weight                =>  p_criteria_weight
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_elig_mrtl_sts_prte'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_elig_mrtl_sts_prte
    --
  end;
  --
  ben_profile_handler.event_handler
    (p_event                       => 'CREATE',
     p_base_table                  => 'BEN_ELIGY_PRFL_F',
     p_base_table_column           => 'ELIGY_PRFL_ID',
     p_base_table_column_value     => p_eligy_prfl_id,
     p_base_table_reference_column => 'ELIG_MRTL_STS_FLAG',
     p_reference_table             => 'BEN_ELIG_MRTL_STS_PRTE_F',
     p_reference_table_column      => 'ELIGY_PRFL_ID');
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
  p_elig_mrtl_sts_prte_id := l_elig_mrtl_sts_prte_id;
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
    ROLLBACK TO create_elig_mrtl_sts_prte;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_elig_mrtl_sts_prte_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_elig_mrtl_sts_prte;
    p_elig_mrtl_sts_prte_id := null; -- nocopy change
    p_effective_start_date := null; -- nocopy change
    p_effective_end_date := null; -- nocopy change
    p_object_version_number  := null; -- nocopy change
    raise;
    --
end create_elig_mrtl_sts_prte;
-- ----------------------------------------------------------------------------
-- |------------------------< update_elig_mrtl_sts_prte >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_elig_mrtl_sts_prte
  (p_validate                       in  boolean   default false
  ,p_elig_mrtl_sts_prte_id          in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_excld_flag                     in  varchar2  default hr_api.g_varchar2
  ,p_marital_status                 in  varchar2  default hr_api.g_varchar2
  ,p_eligy_prfl_id                  in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_emp_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_emp_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_emp_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_emp_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_emp_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_emp_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_emp_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_emp_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_emp_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_emp_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_emp_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_emp_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_emp_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_emp_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_emp_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_emp_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_emp_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_emp_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_emp_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_emp_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_emp_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_emp_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_emp_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_emp_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_emp_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_emp_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_emp_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_emp_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_emp_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_emp_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_emp_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_criteria_score                 in number     default hr_api.g_number
  ,p_criteria_weight                in  number    default hr_api.g_number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_elig_mrtl_sts_prte';
  l_object_version_number ben_elig_mrtl_sts_prte_f.object_version_number%TYPE;
  l_effective_start_date ben_elig_mrtl_sts_prte_f.effective_start_date%TYPE;
  l_effective_end_date ben_elig_mrtl_sts_prte_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_elig_mrtl_sts_prte;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_elig_mrtl_sts_prte
    --
    ben_elig_mrtl_sts_prte_bk2.update_elig_mrtl_sts_prte_b
      (
       p_elig_mrtl_sts_prte_id          =>  p_elig_mrtl_sts_prte_id
      ,p_excld_flag                     =>  p_excld_flag
      ,p_marital_status                 =>  p_marital_status
      ,p_eligy_prfl_id                  =>  p_eligy_prfl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_emp_attribute_category         =>  p_emp_attribute_category
      ,p_emp_attribute1                 =>  p_emp_attribute1
      ,p_emp_attribute2                 =>  p_emp_attribute2
      ,p_emp_attribute3                 =>  p_emp_attribute3
      ,p_emp_attribute4                 =>  p_emp_attribute4
      ,p_emp_attribute5                 =>  p_emp_attribute5
      ,p_emp_attribute6                 =>  p_emp_attribute6
      ,p_emp_attribute7                 =>  p_emp_attribute7
      ,p_emp_attribute8                 =>  p_emp_attribute8
      ,p_emp_attribute9                 =>  p_emp_attribute9
      ,p_emp_attribute10                =>  p_emp_attribute10
      ,p_emp_attribute11                =>  p_emp_attribute11
      ,p_emp_attribute12                =>  p_emp_attribute12
      ,p_emp_attribute13                =>  p_emp_attribute13
      ,p_emp_attribute14                =>  p_emp_attribute14
      ,p_emp_attribute15                =>  p_emp_attribute15
      ,p_emp_attribute16                =>  p_emp_attribute16
      ,p_emp_attribute17                =>  p_emp_attribute17
      ,p_emp_attribute18                =>  p_emp_attribute18
      ,p_emp_attribute19                =>  p_emp_attribute19
      ,p_emp_attribute20                =>  p_emp_attribute20
      ,p_emp_attribute21                =>  p_emp_attribute21
      ,p_emp_attribute22                =>  p_emp_attribute22
      ,p_emp_attribute23                =>  p_emp_attribute23
      ,p_emp_attribute24                =>  p_emp_attribute24
      ,p_emp_attribute25                =>  p_emp_attribute25
      ,p_emp_attribute26                =>  p_emp_attribute26
      ,p_emp_attribute27                =>  p_emp_attribute27
      ,p_emp_attribute28                =>  p_emp_attribute28
      ,p_emp_attribute29                =>  p_emp_attribute29
      ,p_emp_attribute30                =>  p_emp_attribute30
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_datetrack_mode                 =>  p_datetrack_mode
      ,p_criteria_score                 =>  p_criteria_score
      ,p_criteria_weight                =>  p_criteria_weight
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_elig_mrtl_sts_prte'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_elig_mrtl_sts_prte
    --
  end;
  --
  ben_emp_upd.upd
    (
     p_elig_mrtl_sts_prte_id         => p_elig_mrtl_sts_prte_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_excld_flag                    => p_excld_flag
    ,p_marital_status                => p_marital_status
    ,p_eligy_prfl_id                 => p_eligy_prfl_id
    ,p_business_group_id             => p_business_group_id
    ,p_emp_attribute_category        => p_emp_attribute_category
    ,p_emp_attribute1                => p_emp_attribute1
    ,p_emp_attribute2                => p_emp_attribute2
    ,p_emp_attribute3                => p_emp_attribute3
    ,p_emp_attribute4                => p_emp_attribute4
    ,p_emp_attribute5                => p_emp_attribute5
    ,p_emp_attribute6                => p_emp_attribute6
    ,p_emp_attribute7                => p_emp_attribute7
    ,p_emp_attribute8                => p_emp_attribute8
    ,p_emp_attribute9                => p_emp_attribute9
    ,p_emp_attribute10               => p_emp_attribute10
    ,p_emp_attribute11               => p_emp_attribute11
    ,p_emp_attribute12               => p_emp_attribute12
    ,p_emp_attribute13               => p_emp_attribute13
    ,p_emp_attribute14               => p_emp_attribute14
    ,p_emp_attribute15               => p_emp_attribute15
    ,p_emp_attribute16               => p_emp_attribute16
    ,p_emp_attribute17               => p_emp_attribute17
    ,p_emp_attribute18               => p_emp_attribute18
    ,p_emp_attribute19               => p_emp_attribute19
    ,p_emp_attribute20               => p_emp_attribute20
    ,p_emp_attribute21               => p_emp_attribute21
    ,p_emp_attribute22               => p_emp_attribute22
    ,p_emp_attribute23               => p_emp_attribute23
    ,p_emp_attribute24               => p_emp_attribute24
    ,p_emp_attribute25               => p_emp_attribute25
    ,p_emp_attribute26               => p_emp_attribute26
    ,p_emp_attribute27               => p_emp_attribute27
    ,p_emp_attribute28               => p_emp_attribute28
    ,p_emp_attribute29               => p_emp_attribute29
    ,p_emp_attribute30               => p_emp_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    ,p_criteria_score                =>  p_criteria_score
    ,p_criteria_weight               =>  p_criteria_weight
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_elig_mrtl_sts_prte
    --
    ben_elig_mrtl_sts_prte_bk2.update_elig_mrtl_sts_prte_a
      (
       p_elig_mrtl_sts_prte_id          =>  p_elig_mrtl_sts_prte_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_excld_flag                     =>  p_excld_flag
      ,p_marital_status                 =>  p_marital_status
      ,p_eligy_prfl_id                  =>  p_eligy_prfl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_emp_attribute_category         =>  p_emp_attribute_category
      ,p_emp_attribute1                 =>  p_emp_attribute1
      ,p_emp_attribute2                 =>  p_emp_attribute2
      ,p_emp_attribute3                 =>  p_emp_attribute3
      ,p_emp_attribute4                 =>  p_emp_attribute4
      ,p_emp_attribute5                 =>  p_emp_attribute5
      ,p_emp_attribute6                 =>  p_emp_attribute6
      ,p_emp_attribute7                 =>  p_emp_attribute7
      ,p_emp_attribute8                 =>  p_emp_attribute8
      ,p_emp_attribute9                 =>  p_emp_attribute9
      ,p_emp_attribute10                =>  p_emp_attribute10
      ,p_emp_attribute11                =>  p_emp_attribute11
      ,p_emp_attribute12                =>  p_emp_attribute12
      ,p_emp_attribute13                =>  p_emp_attribute13
      ,p_emp_attribute14                =>  p_emp_attribute14
      ,p_emp_attribute15                =>  p_emp_attribute15
      ,p_emp_attribute16                =>  p_emp_attribute16
      ,p_emp_attribute17                =>  p_emp_attribute17
      ,p_emp_attribute18                =>  p_emp_attribute18
      ,p_emp_attribute19                =>  p_emp_attribute19
      ,p_emp_attribute20                =>  p_emp_attribute20
      ,p_emp_attribute21                =>  p_emp_attribute21
      ,p_emp_attribute22                =>  p_emp_attribute22
      ,p_emp_attribute23                =>  p_emp_attribute23
      ,p_emp_attribute24                =>  p_emp_attribute24
      ,p_emp_attribute25                =>  p_emp_attribute25
      ,p_emp_attribute26                =>  p_emp_attribute26
      ,p_emp_attribute27                =>  p_emp_attribute27
      ,p_emp_attribute28                =>  p_emp_attribute28
      ,p_emp_attribute29                =>  p_emp_attribute29
      ,p_emp_attribute30                =>  p_emp_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      ,p_criteria_score                 =>  p_criteria_score
      ,p_criteria_weight                =>  p_criteria_weight
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_elig_mrtl_sts_prte'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_elig_mrtl_sts_prte
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
    ROLLBACK TO update_elig_mrtl_sts_prte;
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
    ROLLBACK TO update_elig_mrtl_sts_prte;
    p_object_version_number := l_object_version_number; --nocopy change
    p_effective_start_date := null; --nocopy change
    p_effective_end_date := null; --nocopy change
    raise;
    --
end update_elig_mrtl_sts_prte;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_elig_mrtl_sts_prte >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_elig_mrtl_sts_prte
  (p_validate                       in  boolean  default false
  ,p_elig_mrtl_sts_prte_id         in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_elig_mrtl_sts_prte';
  l_object_version_number ben_elig_mrtl_sts_prte_f.object_version_number%TYPE;
  l_effective_start_date ben_elig_mrtl_sts_prte_f.effective_start_date%TYPE;
  l_effective_end_date ben_elig_mrtl_sts_prte_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_elig_mrtl_sts_prte;
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
    -- Start of API User Hook for the before hook of delete_elig_mrtl_sts_prte
    --
    ben_elig_mrtl_sts_prte_bk3.delete_elig_mrtl_sts_prte_b
      (
       p_elig_mrtl_sts_prte_id         =>  p_elig_mrtl_sts_prte_id
      ,p_object_version_number         =>  p_object_version_number
    ,p_effective_date                  => trunc(p_effective_date)
    ,p_datetrack_mode                  => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_elig_mrtl_sts_prte'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_elig_mrtl_sts_prte
    --
  end;
  --
  ben_emp_del.del
    (
     p_elig_mrtl_sts_prte_id         => p_elig_mrtl_sts_prte_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_elig_mrtl_sts_prte
    --
    ben_elig_mrtl_sts_prte_bk3.delete_elig_mrtl_sts_prte_a
      (
       p_elig_mrtl_sts_prte_id          =>  p_elig_mrtl_sts_prte_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                   =>  trunc(p_effective_date)
    ,p_datetrack_mode                   =>   p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_elig_mrtl_sts_prte'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_elig_mrtl_sts_prte
    --
  end;
  --
  ben_profile_handler.event_handler
    (p_event                       => 'DELETE',
     p_base_table                  => 'BEN_ELIGY_PRFL_F',
     p_base_table_column           => 'ELIGY_PRFL_ID',
     p_base_table_column_value     =>  ben_emp_shd.g_old_rec.eligy_prfl_id,
     p_base_table_reference_column => 'ELIG_MRTL_STS_FLAG',
     p_reference_table             => 'BEN_ELIG_MRTL_STS_PRTE_F',
     p_reference_table_column      => 'ELIGY_PRFL_ID');
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
    ROLLBACK TO delete_elig_mrtl_sts_prte;
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
    ROLLBACK TO delete_elig_mrtl_sts_prte;
    p_effective_start_date := null; --nocopy change
    p_effective_end_date := null; --nocopy change
    p_object_version_number := l_object_version_number;--nocopy change
    raise;
    --
end delete_elig_mrtl_sts_prte;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_elig_mrtl_sts_prte_id                   in     number
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
  ben_emp_shd.lck
    (
      p_elig_mrtl_sts_prte_id      => p_elig_mrtl_sts_prte_id
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
end ben_elig_mrtl_sts_prte_api;

/
