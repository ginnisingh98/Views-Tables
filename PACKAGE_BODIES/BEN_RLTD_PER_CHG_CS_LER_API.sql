--------------------------------------------------------
--  DDL for Package Body BEN_RLTD_PER_CHG_CS_LER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_RLTD_PER_CHG_CS_LER_API" as
/* $Header: berclapi.pkb 115.6 2004/01/25 00:25:08 hmani ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_Rltd_Per_Chg_Cs_Ler_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Rltd_Per_Chg_Cs_Ler >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_Rltd_Per_Chg_Cs_Ler
  (p_validate                       in  boolean   default false
  ,p_rltd_per_chg_cs_ler_id         out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default null
  ,p_old_val                        in  varchar2  default null
  ,p_new_val                        in  varchar2  default null
  ,p_whatif_lbl_txt                 in  varchar2  default null
  ,p_rule_overrides_flag                 in  varchar2  default 'N'
  ,p_source_column                  in  varchar2  default null
  ,p_source_table                   in  varchar2  default null
  ,p_rltd_per_chg_cs_ler_rl         in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_rcl_attribute_category         in  varchar2  default null
  ,p_rcl_attribute1                 in  varchar2  default null
  ,p_rcl_attribute2                 in  varchar2  default null
  ,p_rcl_attribute3                 in  varchar2  default null
  ,p_rcl_attribute4                 in  varchar2  default null
  ,p_rcl_attribute5                 in  varchar2  default null
  ,p_rcl_attribute6                 in  varchar2  default null
  ,p_rcl_attribute7                 in  varchar2  default null
  ,p_rcl_attribute8                 in  varchar2  default null
  ,p_rcl_attribute9                 in  varchar2  default null
  ,p_rcl_attribute10                in  varchar2  default null
  ,p_rcl_attribute11                in  varchar2  default null
  ,p_rcl_attribute12                in  varchar2  default null
  ,p_rcl_attribute13                in  varchar2  default null
  ,p_rcl_attribute14                in  varchar2  default null
  ,p_rcl_attribute15                in  varchar2  default null
  ,p_rcl_attribute16                in  varchar2  default null
  ,p_rcl_attribute17                in  varchar2  default null
  ,p_rcl_attribute18                in  varchar2  default null
  ,p_rcl_attribute19                in  varchar2  default null
  ,p_rcl_attribute20                in  varchar2  default null
  ,p_rcl_attribute21                in  varchar2  default null
  ,p_rcl_attribute22                in  varchar2  default null
  ,p_rcl_attribute23                in  varchar2  default null
  ,p_rcl_attribute24                in  varchar2  default null
  ,p_rcl_attribute25                in  varchar2  default null
  ,p_rcl_attribute26                in  varchar2  default null
  ,p_rcl_attribute27                in  varchar2  default null
  ,p_rcl_attribute28                in  varchar2  default null
  ,p_rcl_attribute29                in  varchar2  default null
  ,p_rcl_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_rltd_per_chg_cs_ler_id ben_rltd_per_chg_cs_ler_f.rltd_per_chg_cs_ler_id%TYPE;
  l_effective_start_date ben_rltd_per_chg_cs_ler_f.effective_start_date%TYPE;
  l_effective_end_date ben_rltd_per_chg_cs_ler_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_Rltd_Per_Chg_Cs_Ler';
  l_object_version_number ben_rltd_per_chg_cs_ler_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_Rltd_Per_Chg_Cs_Ler;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_Rltd_Per_Chg_Cs_Ler
    --
    ben_Rltd_Per_Chg_Cs_Ler_bk1.create_Rltd_Per_Chg_Cs_Ler_b
      (
       p_name                           =>  p_name
      ,p_old_val                        =>  p_new_val
      ,p_new_val                        =>  p_new_val
      ,p_whatif_lbl_txt                 =>  p_whatif_lbl_txt
      ,p_rule_overrides_flag                 =>  p_rule_overrides_flag
      ,p_source_column                  =>  p_source_column
      ,p_source_table                   =>  p_source_table
      ,p_rltd_per_chg_cs_ler_rl         =>  p_rltd_per_chg_cs_ler_rl
      ,p_business_group_id              =>  p_business_group_id
      ,p_rcl_attribute_category         =>  p_rcl_attribute_category
      ,p_rcl_attribute1                 =>  p_rcl_attribute1
      ,p_rcl_attribute2                 =>  p_rcl_attribute2
      ,p_rcl_attribute3                 =>  p_rcl_attribute3
      ,p_rcl_attribute4                 =>  p_rcl_attribute4
      ,p_rcl_attribute5                 =>  p_rcl_attribute5
      ,p_rcl_attribute6                 =>  p_rcl_attribute6
      ,p_rcl_attribute7                 =>  p_rcl_attribute7
      ,p_rcl_attribute8                 =>  p_rcl_attribute8
      ,p_rcl_attribute9                 =>  p_rcl_attribute9
      ,p_rcl_attribute10                =>  p_rcl_attribute10
      ,p_rcl_attribute11                =>  p_rcl_attribute11
      ,p_rcl_attribute12                =>  p_rcl_attribute12
      ,p_rcl_attribute13                =>  p_rcl_attribute13
      ,p_rcl_attribute14                =>  p_rcl_attribute14
      ,p_rcl_attribute15                =>  p_rcl_attribute15
      ,p_rcl_attribute16                =>  p_rcl_attribute16
      ,p_rcl_attribute17                =>  p_rcl_attribute17
      ,p_rcl_attribute18                =>  p_rcl_attribute18
      ,p_rcl_attribute19                =>  p_rcl_attribute19
      ,p_rcl_attribute20                =>  p_rcl_attribute20
      ,p_rcl_attribute21                =>  p_rcl_attribute21
      ,p_rcl_attribute22                =>  p_rcl_attribute22
      ,p_rcl_attribute23                =>  p_rcl_attribute23
      ,p_rcl_attribute24                =>  p_rcl_attribute24
      ,p_rcl_attribute25                =>  p_rcl_attribute25
      ,p_rcl_attribute26                =>  p_rcl_attribute26
      ,p_rcl_attribute27                =>  p_rcl_attribute27
      ,p_rcl_attribute28                =>  p_rcl_attribute28
      ,p_rcl_attribute29                =>  p_rcl_attribute29
      ,p_rcl_attribute30                =>  p_rcl_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_Rltd_Per_Chg_Cs_Ler'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_Rltd_Per_Chg_Cs_Ler
    --
  end;
  --
  ben_rcl_ins.ins
    (
     p_rltd_per_chg_cs_ler_id        => l_rltd_per_chg_cs_ler_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_name                          => p_name
    ,p_old_val                       => p_old_val
    ,p_new_val                       => p_new_val
    ,p_whatif_lbl_txt                => p_whatif_lbl_txt
    ,p_rule_overrides_flag                => p_rule_overrides_flag
    ,p_source_column                 => p_source_column
    ,p_source_table                  => p_source_table
    ,p_rltd_per_chg_cs_ler_rl        => p_rltd_per_chg_cs_ler_rl
    ,p_business_group_id             => p_business_group_id
    ,p_rcl_attribute_category        => p_rcl_attribute_category
    ,p_rcl_attribute1                => p_rcl_attribute1
    ,p_rcl_attribute2                => p_rcl_attribute2
    ,p_rcl_attribute3                => p_rcl_attribute3
    ,p_rcl_attribute4                => p_rcl_attribute4
    ,p_rcl_attribute5                => p_rcl_attribute5
    ,p_rcl_attribute6                => p_rcl_attribute6
    ,p_rcl_attribute7                => p_rcl_attribute7
    ,p_rcl_attribute8                => p_rcl_attribute8
    ,p_rcl_attribute9                => p_rcl_attribute9
    ,p_rcl_attribute10               => p_rcl_attribute10
    ,p_rcl_attribute11               => p_rcl_attribute11
    ,p_rcl_attribute12               => p_rcl_attribute12
    ,p_rcl_attribute13               => p_rcl_attribute13
    ,p_rcl_attribute14               => p_rcl_attribute14
    ,p_rcl_attribute15               => p_rcl_attribute15
    ,p_rcl_attribute16               => p_rcl_attribute16
    ,p_rcl_attribute17               => p_rcl_attribute17
    ,p_rcl_attribute18               => p_rcl_attribute18
    ,p_rcl_attribute19               => p_rcl_attribute19
    ,p_rcl_attribute20               => p_rcl_attribute20
    ,p_rcl_attribute21               => p_rcl_attribute21
    ,p_rcl_attribute22               => p_rcl_attribute22
    ,p_rcl_attribute23               => p_rcl_attribute23
    ,p_rcl_attribute24               => p_rcl_attribute24
    ,p_rcl_attribute25               => p_rcl_attribute25
    ,p_rcl_attribute26               => p_rcl_attribute26
    ,p_rcl_attribute27               => p_rcl_attribute27
    ,p_rcl_attribute28               => p_rcl_attribute28
    ,p_rcl_attribute29               => p_rcl_attribute29
    ,p_rcl_attribute30               => p_rcl_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_Rltd_Per_Chg_Cs_Ler
    --
    ben_Rltd_Per_Chg_Cs_Ler_bk1.create_Rltd_Per_Chg_Cs_Ler_a
      (
       p_rltd_per_chg_cs_ler_id         =>  l_rltd_per_chg_cs_ler_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_name                           =>  p_name
      ,p_old_val                        =>  p_old_val
      ,p_new_val                        =>  p_new_val
      ,p_whatif_lbl_txt                 =>  p_whatif_lbl_txt
      ,p_rule_overrides_flag                 =>  p_rule_overrides_flag
      ,p_source_column                  =>  p_source_column
      ,p_source_table                   =>  p_source_table
      ,p_rltd_per_chg_cs_ler_rl         =>  p_rltd_per_chg_cs_ler_rl
      ,p_business_group_id              =>  p_business_group_id
      ,p_rcl_attribute_category         =>  p_rcl_attribute_category
      ,p_rcl_attribute1                 =>  p_rcl_attribute1
      ,p_rcl_attribute2                 =>  p_rcl_attribute2
      ,p_rcl_attribute3                 =>  p_rcl_attribute3
      ,p_rcl_attribute4                 =>  p_rcl_attribute4
      ,p_rcl_attribute5                 =>  p_rcl_attribute5
      ,p_rcl_attribute6                 =>  p_rcl_attribute6
      ,p_rcl_attribute7                 =>  p_rcl_attribute7
      ,p_rcl_attribute8                 =>  p_rcl_attribute8
      ,p_rcl_attribute9                 =>  p_rcl_attribute9
      ,p_rcl_attribute10                =>  p_rcl_attribute10
      ,p_rcl_attribute11                =>  p_rcl_attribute11
      ,p_rcl_attribute12                =>  p_rcl_attribute12
      ,p_rcl_attribute13                =>  p_rcl_attribute13
      ,p_rcl_attribute14                =>  p_rcl_attribute14
      ,p_rcl_attribute15                =>  p_rcl_attribute15
      ,p_rcl_attribute16                =>  p_rcl_attribute16
      ,p_rcl_attribute17                =>  p_rcl_attribute17
      ,p_rcl_attribute18                =>  p_rcl_attribute18
      ,p_rcl_attribute19                =>  p_rcl_attribute19
      ,p_rcl_attribute20                =>  p_rcl_attribute20
      ,p_rcl_attribute21                =>  p_rcl_attribute21
      ,p_rcl_attribute22                =>  p_rcl_attribute22
      ,p_rcl_attribute23                =>  p_rcl_attribute23
      ,p_rcl_attribute24                =>  p_rcl_attribute24
      ,p_rcl_attribute25                =>  p_rcl_attribute25
      ,p_rcl_attribute26                =>  p_rcl_attribute26
      ,p_rcl_attribute27                =>  p_rcl_attribute27
      ,p_rcl_attribute28                =>  p_rcl_attribute28
      ,p_rcl_attribute29                =>  p_rcl_attribute29
      ,p_rcl_attribute30                =>  p_rcl_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_Rltd_Per_Chg_Cs_Ler'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_Rltd_Per_Chg_Cs_Ler
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
  p_rltd_per_chg_cs_ler_id := l_rltd_per_chg_cs_ler_id;
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
    ROLLBACK TO create_Rltd_Per_Chg_Cs_Ler;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_rltd_per_chg_cs_ler_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_Rltd_Per_Chg_Cs_Ler;

    -- NOCOPY, Reset out parameters
    p_rltd_per_chg_cs_ler_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;

    raise;
    --
end create_Rltd_Per_Chg_Cs_Ler;
-- ----------------------------------------------------------------------------
-- |------------------------< update_Rltd_Per_Chg_Cs_Ler >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_Rltd_Per_Chg_Cs_Ler
  (p_validate                       in  boolean   default false
  ,p_rltd_per_chg_cs_ler_id         in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_old_val                        in  varchar2  default hr_api.g_varchar2
  ,p_new_val                        in  varchar2  default hr_api.g_varchar2
  ,p_whatif_lbl_txt                 in  varchar2  default hr_api.g_varchar2
  ,p_rule_overrides_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_source_column                  in  varchar2  default hr_api.g_varchar2
  ,p_source_table                   in  varchar2  default hr_api.g_varchar2
  ,p_rltd_per_chg_cs_ler_rl         in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_rcl_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_rcl_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_rcl_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_rcl_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_rcl_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_rcl_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_rcl_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_rcl_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_rcl_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_rcl_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_rcl_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_rcl_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_rcl_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_rcl_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_rcl_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_rcl_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_rcl_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_rcl_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_rcl_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_rcl_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_rcl_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_rcl_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_rcl_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_rcl_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_rcl_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_rcl_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_rcl_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_rcl_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_rcl_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_rcl_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_rcl_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Rltd_Per_Chg_Cs_Ler';
  l_object_version_number ben_rltd_per_chg_cs_ler_f.object_version_number%TYPE;
  l_effective_start_date ben_rltd_per_chg_cs_ler_f.effective_start_date%TYPE;
  l_effective_end_date ben_rltd_per_chg_cs_ler_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_Rltd_Per_Chg_Cs_Ler;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_Rltd_Per_Chg_Cs_Ler
    --
    ben_Rltd_Per_Chg_Cs_Ler_bk2.update_Rltd_Per_Chg_Cs_Ler_b
      (
       p_rltd_per_chg_cs_ler_id         =>  p_rltd_per_chg_cs_ler_id
      ,p_name                           =>  p_name
      ,p_old_val                        =>  p_old_val
      ,p_new_val                        =>  p_new_val
      ,p_whatif_lbl_txt                 =>  p_whatif_lbl_txt
      ,p_rule_overrides_flag                 =>  p_rule_overrides_flag
      ,p_source_column                  =>  p_source_column
      ,p_source_table                   =>  p_source_table
      ,p_rltd_per_chg_cs_ler_rl         =>  p_rltd_per_chg_cs_ler_rl
      ,p_business_group_id              =>  p_business_group_id
      ,p_rcl_attribute_category         =>  p_rcl_attribute_category
      ,p_rcl_attribute1                 =>  p_rcl_attribute1
      ,p_rcl_attribute2                 =>  p_rcl_attribute2
      ,p_rcl_attribute3                 =>  p_rcl_attribute3
      ,p_rcl_attribute4                 =>  p_rcl_attribute4
      ,p_rcl_attribute5                 =>  p_rcl_attribute5
      ,p_rcl_attribute6                 =>  p_rcl_attribute6
      ,p_rcl_attribute7                 =>  p_rcl_attribute7
      ,p_rcl_attribute8                 =>  p_rcl_attribute8
      ,p_rcl_attribute9                 =>  p_rcl_attribute9
      ,p_rcl_attribute10                =>  p_rcl_attribute10
      ,p_rcl_attribute11                =>  p_rcl_attribute11
      ,p_rcl_attribute12                =>  p_rcl_attribute12
      ,p_rcl_attribute13                =>  p_rcl_attribute13
      ,p_rcl_attribute14                =>  p_rcl_attribute14
      ,p_rcl_attribute15                =>  p_rcl_attribute15
      ,p_rcl_attribute16                =>  p_rcl_attribute16
      ,p_rcl_attribute17                =>  p_rcl_attribute17
      ,p_rcl_attribute18                =>  p_rcl_attribute18
      ,p_rcl_attribute19                =>  p_rcl_attribute19
      ,p_rcl_attribute20                =>  p_rcl_attribute20
      ,p_rcl_attribute21                =>  p_rcl_attribute21
      ,p_rcl_attribute22                =>  p_rcl_attribute22
      ,p_rcl_attribute23                =>  p_rcl_attribute23
      ,p_rcl_attribute24                =>  p_rcl_attribute24
      ,p_rcl_attribute25                =>  p_rcl_attribute25
      ,p_rcl_attribute26                =>  p_rcl_attribute26
      ,p_rcl_attribute27                =>  p_rcl_attribute27
      ,p_rcl_attribute28                =>  p_rcl_attribute28
      ,p_rcl_attribute29                =>  p_rcl_attribute29
      ,p_rcl_attribute30                =>  p_rcl_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Rltd_Per_Chg_Cs_Ler'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_Rltd_Per_Chg_Cs_Ler
    --
  end;
  --
  ben_rcl_upd.upd
    (
     p_rltd_per_chg_cs_ler_id        => p_rltd_per_chg_cs_ler_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_name                          => p_name
    ,p_old_val                       => p_old_val
    ,p_new_val                       => p_new_val
    ,p_whatif_lbl_txt                => p_whatif_lbl_txt
    ,p_rule_overrides_flag                => p_rule_overrides_flag
    ,p_source_column                 => p_source_column
    ,p_source_table                  => p_source_table
    ,p_rltd_per_chg_cs_ler_rl        => p_rltd_per_chg_cs_ler_rl
    ,p_business_group_id             => p_business_group_id
    ,p_rcl_attribute_category        => p_rcl_attribute_category
    ,p_rcl_attribute1                => p_rcl_attribute1
    ,p_rcl_attribute2                => p_rcl_attribute2
    ,p_rcl_attribute3                => p_rcl_attribute3
    ,p_rcl_attribute4                => p_rcl_attribute4
    ,p_rcl_attribute5                => p_rcl_attribute5
    ,p_rcl_attribute6                => p_rcl_attribute6
    ,p_rcl_attribute7                => p_rcl_attribute7
    ,p_rcl_attribute8                => p_rcl_attribute8
    ,p_rcl_attribute9                => p_rcl_attribute9
    ,p_rcl_attribute10               => p_rcl_attribute10
    ,p_rcl_attribute11               => p_rcl_attribute11
    ,p_rcl_attribute12               => p_rcl_attribute12
    ,p_rcl_attribute13               => p_rcl_attribute13
    ,p_rcl_attribute14               => p_rcl_attribute14
    ,p_rcl_attribute15               => p_rcl_attribute15
    ,p_rcl_attribute16               => p_rcl_attribute16
    ,p_rcl_attribute17               => p_rcl_attribute17
    ,p_rcl_attribute18               => p_rcl_attribute18
    ,p_rcl_attribute19               => p_rcl_attribute19
    ,p_rcl_attribute20               => p_rcl_attribute20
    ,p_rcl_attribute21               => p_rcl_attribute21
    ,p_rcl_attribute22               => p_rcl_attribute22
    ,p_rcl_attribute23               => p_rcl_attribute23
    ,p_rcl_attribute24               => p_rcl_attribute24
    ,p_rcl_attribute25               => p_rcl_attribute25
    ,p_rcl_attribute26               => p_rcl_attribute26
    ,p_rcl_attribute27               => p_rcl_attribute27
    ,p_rcl_attribute28               => p_rcl_attribute28
    ,p_rcl_attribute29               => p_rcl_attribute29
    ,p_rcl_attribute30               => p_rcl_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_Rltd_Per_Chg_Cs_Ler
    --
    ben_Rltd_Per_Chg_Cs_Ler_bk2.update_Rltd_Per_Chg_Cs_Ler_a
      (
       p_rltd_per_chg_cs_ler_id         =>  p_rltd_per_chg_cs_ler_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_name                           =>  p_name
      ,p_old_val                        =>  p_old_val
      ,p_new_val                        =>  p_new_val
      ,p_whatif_lbl_txt                 =>  p_whatif_lbl_txt
      ,p_rule_overrides_flag                 =>  p_rule_overrides_flag
      ,p_source_column                  =>  p_source_column
      ,p_source_table                   =>  p_source_table
      ,p_rltd_per_chg_cs_ler_rl         =>  p_rltd_per_chg_cs_ler_rl
      ,p_business_group_id              =>  p_business_group_id
      ,p_rcl_attribute_category         =>  p_rcl_attribute_category
      ,p_rcl_attribute1                 =>  p_rcl_attribute1
      ,p_rcl_attribute2                 =>  p_rcl_attribute2
      ,p_rcl_attribute3                 =>  p_rcl_attribute3
      ,p_rcl_attribute4                 =>  p_rcl_attribute4
      ,p_rcl_attribute5                 =>  p_rcl_attribute5
      ,p_rcl_attribute6                 =>  p_rcl_attribute6
      ,p_rcl_attribute7                 =>  p_rcl_attribute7
      ,p_rcl_attribute8                 =>  p_rcl_attribute8
      ,p_rcl_attribute9                 =>  p_rcl_attribute9
      ,p_rcl_attribute10                =>  p_rcl_attribute10
      ,p_rcl_attribute11                =>  p_rcl_attribute11
      ,p_rcl_attribute12                =>  p_rcl_attribute12
      ,p_rcl_attribute13                =>  p_rcl_attribute13
      ,p_rcl_attribute14                =>  p_rcl_attribute14
      ,p_rcl_attribute15                =>  p_rcl_attribute15
      ,p_rcl_attribute16                =>  p_rcl_attribute16
      ,p_rcl_attribute17                =>  p_rcl_attribute17
      ,p_rcl_attribute18                =>  p_rcl_attribute18
      ,p_rcl_attribute19                =>  p_rcl_attribute19
      ,p_rcl_attribute20                =>  p_rcl_attribute20
      ,p_rcl_attribute21                =>  p_rcl_attribute21
      ,p_rcl_attribute22                =>  p_rcl_attribute22
      ,p_rcl_attribute23                =>  p_rcl_attribute23
      ,p_rcl_attribute24                =>  p_rcl_attribute24
      ,p_rcl_attribute25                =>  p_rcl_attribute25
      ,p_rcl_attribute26                =>  p_rcl_attribute26
      ,p_rcl_attribute27                =>  p_rcl_attribute27
      ,p_rcl_attribute28                =>  p_rcl_attribute28
      ,p_rcl_attribute29                =>  p_rcl_attribute29
      ,p_rcl_attribute30                =>  p_rcl_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Rltd_Per_Chg_Cs_Ler'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_Rltd_Per_Chg_Cs_Ler
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
    ROLLBACK TO update_Rltd_Per_Chg_Cs_Ler;
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
    ROLLBACK TO update_Rltd_Per_Chg_Cs_Ler;

    -- NOCOPY, Reset out parameters
    p_effective_start_date := null;
    p_effective_end_date   := null;

    raise;
    --
end update_Rltd_Per_Chg_Cs_Ler;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Rltd_Per_Chg_Cs_Ler >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Rltd_Per_Chg_Cs_Ler
  (p_validate                       in  boolean  default false
  ,p_rltd_per_chg_cs_ler_id         in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Rltd_Per_Chg_Cs_Ler';
  l_object_version_number ben_rltd_per_chg_cs_ler_f.object_version_number%TYPE;
  l_effective_start_date ben_rltd_per_chg_cs_ler_f.effective_start_date%TYPE;
  l_effective_end_date ben_rltd_per_chg_cs_ler_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_Rltd_Per_Chg_Cs_Ler;
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
    -- Start of API User Hook for the before hook of delete_Rltd_Per_Chg_Cs_Ler
    --
    ben_Rltd_Per_Chg_Cs_Ler_bk3.delete_Rltd_Per_Chg_Cs_Ler_b
      (
       p_rltd_per_chg_cs_ler_id         =>  p_rltd_per_chg_cs_ler_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Rltd_Per_Chg_Cs_Ler'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_Rltd_Per_Chg_Cs_Ler
    --
  end;
  --
  ben_rcl_del.del
    (
     p_rltd_per_chg_cs_ler_id        => p_rltd_per_chg_cs_ler_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_Rltd_Per_Chg_Cs_Ler
    --
    ben_Rltd_Per_Chg_Cs_Ler_bk3.delete_Rltd_Per_Chg_Cs_Ler_a
      (
       p_rltd_per_chg_cs_ler_id         =>  p_rltd_per_chg_cs_ler_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Rltd_Per_Chg_Cs_Ler'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_Rltd_Per_Chg_Cs_Ler
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
    ROLLBACK TO delete_Rltd_Per_Chg_Cs_Ler;
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
    ROLLBACK TO delete_Rltd_Per_Chg_Cs_Ler;

    -- NOCOPY, Reset out parameters
    p_effective_start_date := null;
    p_effective_end_date   := null;

    raise;
    --
end delete_Rltd_Per_Chg_Cs_Ler;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_rltd_per_chg_cs_ler_id                   in     number
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
  ben_rcl_shd.lck
    (
      p_rltd_per_chg_cs_ler_id                 => p_rltd_per_chg_cs_ler_id
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
end ben_Rltd_Per_Chg_Cs_Ler_api;

/
