--------------------------------------------------------
--  DDL for Package Body BEN_ELIG_OTHR_PTIP_PRTE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ELIG_OTHR_PTIP_PRTE_API" as
/* $Header: beeoyapi.pkb 120.0 2005/05/28 02:34:01 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_ELIG_OTHR_PTIP_PRTE_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_ELIG_OTHR_PTIP_PRTE >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELIG_OTHR_PTIP_PRTE
  (p_validate                       in  boolean   default false
  ,p_elig_othr_ptip_prte_id         out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_excld_flag                     in  varchar2  default 'N'
  ,p_ordr_num                       in  number    default null
  ,p_only_pls_subj_cobra_flag       in  varchar2  default 'N'
  ,p_eligy_prfl_id                  in  number    default null
  ,p_ptip_id                        in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_eoy_attribute_category         in  varchar2  default null
  ,p_eoy_attribute1                 in  varchar2  default null
  ,p_eoy_attribute2                 in  varchar2  default null
  ,p_eoy_attribute3                 in  varchar2  default null
  ,p_eoy_attribute4                 in  varchar2  default null
  ,p_eoy_attribute5                 in  varchar2  default null
  ,p_eoy_attribute6                 in  varchar2  default null
  ,p_eoy_attribute7                 in  varchar2  default null
  ,p_eoy_attribute8                 in  varchar2  default null
  ,p_eoy_attribute9                 in  varchar2  default null
  ,p_eoy_attribute10                in  varchar2  default null
  ,p_eoy_attribute11                in  varchar2  default null
  ,p_eoy_attribute12                in  varchar2  default null
  ,p_eoy_attribute13                in  varchar2  default null
  ,p_eoy_attribute14                in  varchar2  default null
  ,p_eoy_attribute15                in  varchar2  default null
  ,p_eoy_attribute16                in  varchar2  default null
  ,p_eoy_attribute17                in  varchar2  default null
  ,p_eoy_attribute18                in  varchar2  default null
  ,p_eoy_attribute19                in  varchar2  default null
  ,p_eoy_attribute20                in  varchar2  default null
  ,p_eoy_attribute21                in  varchar2  default null
  ,p_eoy_attribute22                in  varchar2  default null
  ,p_eoy_attribute23                in  varchar2  default null
  ,p_eoy_attribute24                in  varchar2  default null
  ,p_eoy_attribute25                in  varchar2  default null
  ,p_eoy_attribute26                in  varchar2  default null
  ,p_eoy_attribute27                in  varchar2  default null
  ,p_eoy_attribute28                in  varchar2  default null
  ,p_eoy_attribute29                in  varchar2  default null
  ,p_eoy_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_elig_othr_ptip_prte_id ben_elig_othr_ptip_prte_f.elig_othr_ptip_prte_id%TYPE;
  l_effective_start_date ben_elig_othr_ptip_prte_f.effective_start_date%TYPE;
  l_effective_end_date ben_elig_othr_ptip_prte_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_ELIG_OTHR_PTIP_PRTE';
  l_object_version_number ben_elig_othr_ptip_prte_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_ELIG_OTHR_PTIP_PRTE;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_ELIG_OTHR_PTIP_PRTE
    --
    ben_ELIG_OTHR_PTIP_PRTE_bk1.create_ELIG_OTHR_PTIP_PRTE_b
      (
       p_excld_flag                     =>  p_excld_flag
      ,p_ordr_num                       =>  p_ordr_num
      ,p_only_pls_subj_cobra_flag       =>  p_only_pls_subj_cobra_flag
      ,p_eligy_prfl_id                  =>  p_eligy_prfl_id
      ,p_ptip_id                        =>  p_ptip_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_eoy_attribute_category         =>  p_eoy_attribute_category
      ,p_eoy_attribute1                 =>  p_eoy_attribute1
      ,p_eoy_attribute2                 =>  p_eoy_attribute2
      ,p_eoy_attribute3                 =>  p_eoy_attribute3
      ,p_eoy_attribute4                 =>  p_eoy_attribute4
      ,p_eoy_attribute5                 =>  p_eoy_attribute5
      ,p_eoy_attribute6                 =>  p_eoy_attribute6
      ,p_eoy_attribute7                 =>  p_eoy_attribute7
      ,p_eoy_attribute8                 =>  p_eoy_attribute8
      ,p_eoy_attribute9                 =>  p_eoy_attribute9
      ,p_eoy_attribute10                =>  p_eoy_attribute10
      ,p_eoy_attribute11                =>  p_eoy_attribute11
      ,p_eoy_attribute12                =>  p_eoy_attribute12
      ,p_eoy_attribute13                =>  p_eoy_attribute13
      ,p_eoy_attribute14                =>  p_eoy_attribute14
      ,p_eoy_attribute15                =>  p_eoy_attribute15
      ,p_eoy_attribute16                =>  p_eoy_attribute16
      ,p_eoy_attribute17                =>  p_eoy_attribute17
      ,p_eoy_attribute18                =>  p_eoy_attribute18
      ,p_eoy_attribute19                =>  p_eoy_attribute19
      ,p_eoy_attribute20                =>  p_eoy_attribute20
      ,p_eoy_attribute21                =>  p_eoy_attribute21
      ,p_eoy_attribute22                =>  p_eoy_attribute22
      ,p_eoy_attribute23                =>  p_eoy_attribute23
      ,p_eoy_attribute24                =>  p_eoy_attribute24
      ,p_eoy_attribute25                =>  p_eoy_attribute25
      ,p_eoy_attribute26                =>  p_eoy_attribute26
      ,p_eoy_attribute27                =>  p_eoy_attribute27
      ,p_eoy_attribute28                =>  p_eoy_attribute28
      ,p_eoy_attribute29                =>  p_eoy_attribute29
      ,p_eoy_attribute30                =>  p_eoy_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_ELIG_OTHR_PTIP_PRTE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_ELIG_OTHR_PTIP_PRTE
    --
  end;
  --
  ben_eoy_ins.ins
    (
     p_elig_othr_ptip_prte_id        => l_elig_othr_ptip_prte_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_excld_flag                    => p_excld_flag
    ,p_ordr_num                      => p_ordr_num
    ,p_only_pls_subj_cobra_flag      => p_only_pls_subj_cobra_flag
    ,p_eligy_prfl_id                 => p_eligy_prfl_id
    ,p_ptip_id                       => p_ptip_id
    ,p_business_group_id             => p_business_group_id
    ,p_eoy_attribute_category        => p_eoy_attribute_category
    ,p_eoy_attribute1                => p_eoy_attribute1
    ,p_eoy_attribute2                => p_eoy_attribute2
    ,p_eoy_attribute3                => p_eoy_attribute3
    ,p_eoy_attribute4                => p_eoy_attribute4
    ,p_eoy_attribute5                => p_eoy_attribute5
    ,p_eoy_attribute6                => p_eoy_attribute6
    ,p_eoy_attribute7                => p_eoy_attribute7
    ,p_eoy_attribute8                => p_eoy_attribute8
    ,p_eoy_attribute9                => p_eoy_attribute9
    ,p_eoy_attribute10               => p_eoy_attribute10
    ,p_eoy_attribute11               => p_eoy_attribute11
    ,p_eoy_attribute12               => p_eoy_attribute12
    ,p_eoy_attribute13               => p_eoy_attribute13
    ,p_eoy_attribute14               => p_eoy_attribute14
    ,p_eoy_attribute15               => p_eoy_attribute15
    ,p_eoy_attribute16               => p_eoy_attribute16
    ,p_eoy_attribute17               => p_eoy_attribute17
    ,p_eoy_attribute18               => p_eoy_attribute18
    ,p_eoy_attribute19               => p_eoy_attribute19
    ,p_eoy_attribute20               => p_eoy_attribute20
    ,p_eoy_attribute21               => p_eoy_attribute21
    ,p_eoy_attribute22               => p_eoy_attribute22
    ,p_eoy_attribute23               => p_eoy_attribute23
    ,p_eoy_attribute24               => p_eoy_attribute24
    ,p_eoy_attribute25               => p_eoy_attribute25
    ,p_eoy_attribute26               => p_eoy_attribute26
    ,p_eoy_attribute27               => p_eoy_attribute27
    ,p_eoy_attribute28               => p_eoy_attribute28
    ,p_eoy_attribute29               => p_eoy_attribute29
    ,p_eoy_attribute30               => p_eoy_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_ELIG_OTHR_PTIP_PRTE
    --
    ben_ELIG_OTHR_PTIP_PRTE_bk1.create_ELIG_OTHR_PTIP_PRTE_a
      (
       p_elig_othr_ptip_prte_id         =>  l_elig_othr_ptip_prte_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_excld_flag                     =>  p_excld_flag
      ,p_ordr_num                       =>  p_ordr_num
      ,p_only_pls_subj_cobra_flag       =>  p_only_pls_subj_cobra_flag
      ,p_eligy_prfl_id                  =>  p_eligy_prfl_id
      ,p_ptip_id                        =>  p_ptip_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_eoy_attribute_category         =>  p_eoy_attribute_category
      ,p_eoy_attribute1                 =>  p_eoy_attribute1
      ,p_eoy_attribute2                 =>  p_eoy_attribute2
      ,p_eoy_attribute3                 =>  p_eoy_attribute3
      ,p_eoy_attribute4                 =>  p_eoy_attribute4
      ,p_eoy_attribute5                 =>  p_eoy_attribute5
      ,p_eoy_attribute6                 =>  p_eoy_attribute6
      ,p_eoy_attribute7                 =>  p_eoy_attribute7
      ,p_eoy_attribute8                 =>  p_eoy_attribute8
      ,p_eoy_attribute9                 =>  p_eoy_attribute9
      ,p_eoy_attribute10                =>  p_eoy_attribute10
      ,p_eoy_attribute11                =>  p_eoy_attribute11
      ,p_eoy_attribute12                =>  p_eoy_attribute12
      ,p_eoy_attribute13                =>  p_eoy_attribute13
      ,p_eoy_attribute14                =>  p_eoy_attribute14
      ,p_eoy_attribute15                =>  p_eoy_attribute15
      ,p_eoy_attribute16                =>  p_eoy_attribute16
      ,p_eoy_attribute17                =>  p_eoy_attribute17
      ,p_eoy_attribute18                =>  p_eoy_attribute18
      ,p_eoy_attribute19                =>  p_eoy_attribute19
      ,p_eoy_attribute20                =>  p_eoy_attribute20
      ,p_eoy_attribute21                =>  p_eoy_attribute21
      ,p_eoy_attribute22                =>  p_eoy_attribute22
      ,p_eoy_attribute23                =>  p_eoy_attribute23
      ,p_eoy_attribute24                =>  p_eoy_attribute24
      ,p_eoy_attribute25                =>  p_eoy_attribute25
      ,p_eoy_attribute26                =>  p_eoy_attribute26
      ,p_eoy_attribute27                =>  p_eoy_attribute27
      ,p_eoy_attribute28                =>  p_eoy_attribute28
      ,p_eoy_attribute29                =>  p_eoy_attribute29
      ,p_eoy_attribute30                =>  p_eoy_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ELIG_OTHR_PTIP_PRTE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_ELIG_OTHR_PTIP_PRTE
    --
  end;
  --
  ben_profile_handler.event_handler
    (p_event                       => 'CREATE',
     p_base_table                  => 'BEN_ELIGY_PRFL_F',
     p_base_table_column           => 'ELIGY_PRFL_ID',
     p_base_table_column_value     => p_eligy_prfl_id,
     p_base_table_reference_column => 'ELIG_PTIP_PRTE_FLAG',
     p_reference_table             => 'BEN_ELIG_OTHR_PTIP_PRTE_F',
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
  p_elig_othr_ptip_prte_id := l_elig_othr_ptip_prte_id;
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
    ROLLBACK TO create_ELIG_OTHR_PTIP_PRTE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_elig_othr_ptip_prte_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    -- Initialize OUT Variables for NOCOPY
    p_elig_othr_ptip_prte_id :=null;
    p_effective_start_date   :=null;
    p_effective_end_date     :=null;
    p_object_version_number  :=null;


    ROLLBACK TO create_ELIG_OTHR_PTIP_PRTE;
    raise;
    --
end create_ELIG_OTHR_PTIP_PRTE;
-- ----------------------------------------------------------------------------
-- |------------------------< update_ELIG_OTHR_PTIP_PRTE >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIG_OTHR_PTIP_PRTE
  (p_validate                       in  boolean   default false
  ,p_elig_othr_ptip_prte_id         in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_excld_flag                     in  varchar2  default hr_api.g_varchar2
  ,p_ordr_num                       in  number    default hr_api.g_number
  ,p_only_pls_subj_cobra_flag       in  varchar2  default hr_api.g_varchar2
  ,p_eligy_prfl_id                  in  number    default hr_api.g_number
  ,p_ptip_id                        in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_eoy_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_eoy_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_eoy_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_eoy_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_eoy_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_eoy_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_eoy_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_eoy_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_eoy_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_eoy_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_eoy_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_eoy_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_eoy_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_eoy_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_eoy_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_eoy_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_eoy_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_eoy_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_eoy_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_eoy_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_eoy_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_eoy_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_eoy_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_eoy_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_eoy_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_eoy_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_eoy_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_eoy_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_eoy_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_eoy_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_eoy_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_ELIG_OTHR_PTIP_PRTE';
  l_object_version_number ben_elig_othr_ptip_prte_f.object_version_number%TYPE;
  l_effective_start_date ben_elig_othr_ptip_prte_f.effective_start_date%TYPE;
  l_effective_end_date ben_elig_othr_ptip_prte_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_ELIG_OTHR_PTIP_PRTE;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_ELIG_OTHR_PTIP_PRTE
    --
    ben_ELIG_OTHR_PTIP_PRTE_bk2.update_ELIG_OTHR_PTIP_PRTE_b
      (
       p_elig_othr_ptip_prte_id         =>  p_elig_othr_ptip_prte_id
      ,p_excld_flag                     =>  p_excld_flag
      ,p_ordr_num                       =>  p_ordr_num
      ,p_only_pls_subj_cobra_flag       =>  p_only_pls_subj_cobra_flag
      ,p_eligy_prfl_id                  =>  p_eligy_prfl_id
      ,p_ptip_id                        =>  p_ptip_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_eoy_attribute_category         =>  p_eoy_attribute_category
      ,p_eoy_attribute1                 =>  p_eoy_attribute1
      ,p_eoy_attribute2                 =>  p_eoy_attribute2
      ,p_eoy_attribute3                 =>  p_eoy_attribute3
      ,p_eoy_attribute4                 =>  p_eoy_attribute4
      ,p_eoy_attribute5                 =>  p_eoy_attribute5
      ,p_eoy_attribute6                 =>  p_eoy_attribute6
      ,p_eoy_attribute7                 =>  p_eoy_attribute7
      ,p_eoy_attribute8                 =>  p_eoy_attribute8
      ,p_eoy_attribute9                 =>  p_eoy_attribute9
      ,p_eoy_attribute10                =>  p_eoy_attribute10
      ,p_eoy_attribute11                =>  p_eoy_attribute11
      ,p_eoy_attribute12                =>  p_eoy_attribute12
      ,p_eoy_attribute13                =>  p_eoy_attribute13
      ,p_eoy_attribute14                =>  p_eoy_attribute14
      ,p_eoy_attribute15                =>  p_eoy_attribute15
      ,p_eoy_attribute16                =>  p_eoy_attribute16
      ,p_eoy_attribute17                =>  p_eoy_attribute17
      ,p_eoy_attribute18                =>  p_eoy_attribute18
      ,p_eoy_attribute19                =>  p_eoy_attribute19
      ,p_eoy_attribute20                =>  p_eoy_attribute20
      ,p_eoy_attribute21                =>  p_eoy_attribute21
      ,p_eoy_attribute22                =>  p_eoy_attribute22
      ,p_eoy_attribute23                =>  p_eoy_attribute23
      ,p_eoy_attribute24                =>  p_eoy_attribute24
      ,p_eoy_attribute25                =>  p_eoy_attribute25
      ,p_eoy_attribute26                =>  p_eoy_attribute26
      ,p_eoy_attribute27                =>  p_eoy_attribute27
      ,p_eoy_attribute28                =>  p_eoy_attribute28
      ,p_eoy_attribute29                =>  p_eoy_attribute29
      ,p_eoy_attribute30                =>  p_eoy_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ELIG_OTHR_PTIP_PRTE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_ELIG_OTHR_PTIP_PRTE
    --
  end;
  --
  ben_eoy_upd.upd
    (
     p_elig_othr_ptip_prte_id        => p_elig_othr_ptip_prte_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_excld_flag                    => p_excld_flag
    ,p_ordr_num                      => p_ordr_num
    ,p_only_pls_subj_cobra_flag      => p_only_pls_subj_cobra_flag
    ,p_eligy_prfl_id                 => p_eligy_prfl_id
    ,p_ptip_id                       => p_ptip_id
    ,p_business_group_id             => p_business_group_id
    ,p_eoy_attribute_category        => p_eoy_attribute_category
    ,p_eoy_attribute1                => p_eoy_attribute1
    ,p_eoy_attribute2                => p_eoy_attribute2
    ,p_eoy_attribute3                => p_eoy_attribute3
    ,p_eoy_attribute4                => p_eoy_attribute4
    ,p_eoy_attribute5                => p_eoy_attribute5
    ,p_eoy_attribute6                => p_eoy_attribute6
    ,p_eoy_attribute7                => p_eoy_attribute7
    ,p_eoy_attribute8                => p_eoy_attribute8
    ,p_eoy_attribute9                => p_eoy_attribute9
    ,p_eoy_attribute10               => p_eoy_attribute10
    ,p_eoy_attribute11               => p_eoy_attribute11
    ,p_eoy_attribute12               => p_eoy_attribute12
    ,p_eoy_attribute13               => p_eoy_attribute13
    ,p_eoy_attribute14               => p_eoy_attribute14
    ,p_eoy_attribute15               => p_eoy_attribute15
    ,p_eoy_attribute16               => p_eoy_attribute16
    ,p_eoy_attribute17               => p_eoy_attribute17
    ,p_eoy_attribute18               => p_eoy_attribute18
    ,p_eoy_attribute19               => p_eoy_attribute19
    ,p_eoy_attribute20               => p_eoy_attribute20
    ,p_eoy_attribute21               => p_eoy_attribute21
    ,p_eoy_attribute22               => p_eoy_attribute22
    ,p_eoy_attribute23               => p_eoy_attribute23
    ,p_eoy_attribute24               => p_eoy_attribute24
    ,p_eoy_attribute25               => p_eoy_attribute25
    ,p_eoy_attribute26               => p_eoy_attribute26
    ,p_eoy_attribute27               => p_eoy_attribute27
    ,p_eoy_attribute28               => p_eoy_attribute28
    ,p_eoy_attribute29               => p_eoy_attribute29
    ,p_eoy_attribute30               => p_eoy_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_ELIG_OTHR_PTIP_PRTE
    --
    ben_ELIG_OTHR_PTIP_PRTE_bk2.update_ELIG_OTHR_PTIP_PRTE_a
      (
       p_elig_othr_ptip_prte_id         =>  p_elig_othr_ptip_prte_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_excld_flag                     =>  p_excld_flag
      ,p_ordr_num                       =>  p_ordr_num
      ,p_only_pls_subj_cobra_flag       =>  p_only_pls_subj_cobra_flag
      ,p_eligy_prfl_id                  =>  p_eligy_prfl_id
      ,p_ptip_id                        =>  p_ptip_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_eoy_attribute_category         =>  p_eoy_attribute_category
      ,p_eoy_attribute1                 =>  p_eoy_attribute1
      ,p_eoy_attribute2                 =>  p_eoy_attribute2
      ,p_eoy_attribute3                 =>  p_eoy_attribute3
      ,p_eoy_attribute4                 =>  p_eoy_attribute4
      ,p_eoy_attribute5                 =>  p_eoy_attribute5
      ,p_eoy_attribute6                 =>  p_eoy_attribute6
      ,p_eoy_attribute7                 =>  p_eoy_attribute7
      ,p_eoy_attribute8                 =>  p_eoy_attribute8
      ,p_eoy_attribute9                 =>  p_eoy_attribute9
      ,p_eoy_attribute10                =>  p_eoy_attribute10
      ,p_eoy_attribute11                =>  p_eoy_attribute11
      ,p_eoy_attribute12                =>  p_eoy_attribute12
      ,p_eoy_attribute13                =>  p_eoy_attribute13
      ,p_eoy_attribute14                =>  p_eoy_attribute14
      ,p_eoy_attribute15                =>  p_eoy_attribute15
      ,p_eoy_attribute16                =>  p_eoy_attribute16
      ,p_eoy_attribute17                =>  p_eoy_attribute17
      ,p_eoy_attribute18                =>  p_eoy_attribute18
      ,p_eoy_attribute19                =>  p_eoy_attribute19
      ,p_eoy_attribute20                =>  p_eoy_attribute20
      ,p_eoy_attribute21                =>  p_eoy_attribute21
      ,p_eoy_attribute22                =>  p_eoy_attribute22
      ,p_eoy_attribute23                =>  p_eoy_attribute23
      ,p_eoy_attribute24                =>  p_eoy_attribute24
      ,p_eoy_attribute25                =>  p_eoy_attribute25
      ,p_eoy_attribute26                =>  p_eoy_attribute26
      ,p_eoy_attribute27                =>  p_eoy_attribute27
      ,p_eoy_attribute28                =>  p_eoy_attribute28
      ,p_eoy_attribute29                =>  p_eoy_attribute29
      ,p_eoy_attribute30                =>  p_eoy_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ELIG_OTHR_PTIP_PRTE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_ELIG_OTHR_PTIP_PRTE
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
    ROLLBACK TO update_ELIG_OTHR_PTIP_PRTE;
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
    -- Initialize OUT Variables for NOCOPY
    p_effective_start_date   :=null ;
    p_effective_end_date     :=null ;

    -- Initialize IN/OUT Variables for NOCOPY
    p_object_version_number := l_object_version_number ;

    --
    ROLLBACK TO update_ELIG_OTHR_PTIP_PRTE;
    raise;
    --
end update_ELIG_OTHR_PTIP_PRTE;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_ELIG_OTHR_PTIP_PRTE >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELIG_OTHR_PTIP_PRTE
  (p_validate                       in  boolean  default false
  ,p_elig_othr_ptip_prte_id         in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_ELIG_OTHR_PTIP_PRTE';
  l_object_version_number ben_elig_othr_ptip_prte_f.object_version_number%TYPE;
  l_effective_start_date ben_elig_othr_ptip_prte_f.effective_start_date%TYPE;
  l_effective_end_date ben_elig_othr_ptip_prte_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_ELIG_OTHR_PTIP_PRTE;
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
    -- Start of API User Hook for the before hook of delete_ELIG_OTHR_PTIP_PRTE
    --
    ben_ELIG_OTHR_PTIP_PRTE_bk3.delete_ELIG_OTHR_PTIP_PRTE_b
      (
       p_elig_othr_ptip_prte_id         =>  p_elig_othr_ptip_prte_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ELIG_OTHR_PTIP_PRTE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_ELIG_OTHR_PTIP_PRTE
    --
  end;
  --
  ben_eoy_del.del
    (
     p_elig_othr_ptip_prte_id        => p_elig_othr_ptip_prte_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_ELIG_OTHR_PTIP_PRTE
    --
    ben_ELIG_OTHR_PTIP_PRTE_bk3.delete_ELIG_OTHR_PTIP_PRTE_a
      (
       p_elig_othr_ptip_prte_id         =>  p_elig_othr_ptip_prte_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ELIG_OTHR_PTIP_PRTE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_ELIG_OTHR_PTIP_PRTE
    --
  end;
  --
  ben_profile_handler.event_handler
    (p_event                       => 'DELETE',
     p_base_table                  => 'BEN_ELIGY_PRFL_F',
     p_base_table_column           => 'ELIGY_PRFL_ID',
     p_base_table_column_value     => ben_eoy_shd.g_old_rec.eligy_prfl_id,
     p_base_table_reference_column => 'ELIG_PTIP_PRTE_FLAG',
     p_reference_table             => 'BEN_ELIG_OTHR_PTIP_PRTE_F',
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
    ROLLBACK TO delete_ELIG_OTHR_PTIP_PRTE;
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

    -- Initialize OUT Variables for NOCOPY
    p_effective_start_date :=null ;
    p_effective_end_date   :=null ;

    -- Initialize IN/OUT Variables for NOCOPY
    p_object_version_number:=l_object_version_number ;

    --
    ROLLBACK TO delete_ELIG_OTHR_PTIP_PRTE;
    raise;
    --
end delete_ELIG_OTHR_PTIP_PRTE;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_elig_othr_ptip_prte_id                   in     number
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
  ben_eoy_shd.lck
    (
      p_elig_othr_ptip_prte_id                 => p_elig_othr_ptip_prte_id
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
end ben_ELIG_OTHR_PTIP_PRTE_api;

/
