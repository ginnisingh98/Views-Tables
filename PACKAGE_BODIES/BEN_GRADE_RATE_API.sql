--------------------------------------------------------
--  DDL for Package Body BEN_GRADE_RATE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_GRADE_RATE_API" as
/* $Header: begrrapi.pkb 120.0 2005/05/28 03:08:53 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_GRADE_RATE_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_GRADE_RATE >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_GRADE_RATE
  (p_validate                       in  boolean   default false
  ,p_grade_rt_id                    out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default null
  ,p_vrbl_rt_prfl_id                in  number    default null
  ,p_grade_id                       in  number    default null
  ,p_ordr_num                       in  number    default null
  ,p_excld_flag                     in  varchar2  default null
  ,p_grr_attribute_category         in  varchar2  default null
  ,p_grr_attribute1                 in  varchar2  default null
  ,p_grr_attribute2                 in  varchar2  default null
  ,p_grr_attribute3                 in  varchar2  default null
  ,p_grr_attribute4                 in  varchar2  default null
  ,p_grr_attribute5                 in  varchar2  default null
  ,p_grr_attribute6                 in  varchar2  default null
  ,p_grr_attribute7                 in  varchar2  default null
  ,p_grr_attribute8                 in  varchar2  default null
  ,p_grr_attribute9                 in  varchar2  default null
  ,p_grr_attribute10                in  varchar2  default null
  ,p_grr_attribute11                in  varchar2  default null
  ,p_grr_attribute12                in  varchar2  default null
  ,p_grr_attribute13                in  varchar2  default null
  ,p_grr_attribute14                in  varchar2  default null
  ,p_grr_attribute15                in  varchar2  default null
  ,p_grr_attribute16                in  varchar2  default null
  ,p_grr_attribute17                in  varchar2  default null
  ,p_grr_attribute18                in  varchar2  default null
  ,p_grr_attribute19                in  varchar2  default null
  ,p_grr_attribute20                in  varchar2  default null
  ,p_grr_attribute21                in  varchar2  default null
  ,p_grr_attribute22                in  varchar2  default null
  ,p_grr_attribute23                in  varchar2  default null
  ,p_grr_attribute24                in  varchar2  default null
  ,p_grr_attribute25                in  varchar2  default null
  ,p_grr_attribute26                in  varchar2  default null
  ,p_grr_attribute27                in  varchar2  default null
  ,p_grr_attribute28                in  varchar2  default null
  ,p_grr_attribute29                in  varchar2  default null
  ,p_grr_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_grade_rt_id ben_grade_rt_f.grade_rt_id%TYPE;
  l_effective_start_date ben_grade_rt_f.effective_start_date%TYPE;
  l_effective_end_date ben_grade_rt_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_GRADE_RATE';
  l_object_version_number ben_grade_rt_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_GRADE_RATE;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_GRADE_RATE
    --
    ben_GRADE_RATE_bk1.create_GRADE_RATE_b
      (
       p_business_group_id              =>  p_business_group_id
      ,p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_grade_id                       =>  p_grade_id
      ,p_ordr_num                       =>  p_ordr_num
      ,p_excld_flag                     =>  p_excld_flag
      ,p_grr_attribute_category         =>  p_grr_attribute_category
      ,p_grr_attribute1                 =>  p_grr_attribute1
      ,p_grr_attribute2                 =>  p_grr_attribute2
      ,p_grr_attribute3                 =>  p_grr_attribute3
      ,p_grr_attribute4                 =>  p_grr_attribute4
      ,p_grr_attribute5                 =>  p_grr_attribute5
      ,p_grr_attribute6                 =>  p_grr_attribute6
      ,p_grr_attribute7                 =>  p_grr_attribute7
      ,p_grr_attribute8                 =>  p_grr_attribute8
      ,p_grr_attribute9                 =>  p_grr_attribute9
      ,p_grr_attribute10                =>  p_grr_attribute10
      ,p_grr_attribute11                =>  p_grr_attribute11
      ,p_grr_attribute12                =>  p_grr_attribute12
      ,p_grr_attribute13                =>  p_grr_attribute13
      ,p_grr_attribute14                =>  p_grr_attribute14
      ,p_grr_attribute15                =>  p_grr_attribute15
      ,p_grr_attribute16                =>  p_grr_attribute16
      ,p_grr_attribute17                =>  p_grr_attribute17
      ,p_grr_attribute18                =>  p_grr_attribute18
      ,p_grr_attribute19                =>  p_grr_attribute19
      ,p_grr_attribute20                =>  p_grr_attribute20
      ,p_grr_attribute21                =>  p_grr_attribute21
      ,p_grr_attribute22                =>  p_grr_attribute22
      ,p_grr_attribute23                =>  p_grr_attribute23
      ,p_grr_attribute24                =>  p_grr_attribute24
      ,p_grr_attribute25                =>  p_grr_attribute25
      ,p_grr_attribute26                =>  p_grr_attribute26
      ,p_grr_attribute27                =>  p_grr_attribute27
      ,p_grr_attribute28                =>  p_grr_attribute28
      ,p_grr_attribute29                =>  p_grr_attribute29
      ,p_grr_attribute30                =>  p_grr_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_GRADE_RATE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_GRADE_RATE
    --
  end;
  --
  ben_grr_ins.ins
    (
     p_grade_rt_id                   => l_grade_rt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => p_business_group_id
    ,p_vrbl_rt_prfl_id               => p_vrbl_rt_prfl_id
    ,p_grade_id                      => p_grade_id
    ,p_ordr_num                      => p_ordr_num
    ,p_excld_flag                    => p_excld_flag
    ,p_grr_attribute_category        => p_grr_attribute_category
    ,p_grr_attribute1                => p_grr_attribute1
    ,p_grr_attribute2                => p_grr_attribute2
    ,p_grr_attribute3                => p_grr_attribute3
    ,p_grr_attribute4                => p_grr_attribute4
    ,p_grr_attribute5                => p_grr_attribute5
    ,p_grr_attribute6                => p_grr_attribute6
    ,p_grr_attribute7                => p_grr_attribute7
    ,p_grr_attribute8                => p_grr_attribute8
    ,p_grr_attribute9                => p_grr_attribute9
    ,p_grr_attribute10               => p_grr_attribute10
    ,p_grr_attribute11               => p_grr_attribute11
    ,p_grr_attribute12               => p_grr_attribute12
    ,p_grr_attribute13               => p_grr_attribute13
    ,p_grr_attribute14               => p_grr_attribute14
    ,p_grr_attribute15               => p_grr_attribute15
    ,p_grr_attribute16               => p_grr_attribute16
    ,p_grr_attribute17               => p_grr_attribute17
    ,p_grr_attribute18               => p_grr_attribute18
    ,p_grr_attribute19               => p_grr_attribute19
    ,p_grr_attribute20               => p_grr_attribute20
    ,p_grr_attribute21               => p_grr_attribute21
    ,p_grr_attribute22               => p_grr_attribute22
    ,p_grr_attribute23               => p_grr_attribute23
    ,p_grr_attribute24               => p_grr_attribute24
    ,p_grr_attribute25               => p_grr_attribute25
    ,p_grr_attribute26               => p_grr_attribute26
    ,p_grr_attribute27               => p_grr_attribute27
    ,p_grr_attribute28               => p_grr_attribute28
    ,p_grr_attribute29               => p_grr_attribute29
    ,p_grr_attribute30               => p_grr_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_GRADE_RATE
    --
    ben_GRADE_RATE_bk1.create_GRADE_RATE_a
      (
       p_grade_rt_id                    =>  l_grade_rt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_grade_id                       =>  p_grade_id
      ,p_ordr_num                       =>  p_ordr_num
      ,p_excld_flag                     =>  p_excld_flag
      ,p_grr_attribute_category         =>  p_grr_attribute_category
      ,p_grr_attribute1                 =>  p_grr_attribute1
      ,p_grr_attribute2                 =>  p_grr_attribute2
      ,p_grr_attribute3                 =>  p_grr_attribute3
      ,p_grr_attribute4                 =>  p_grr_attribute4
      ,p_grr_attribute5                 =>  p_grr_attribute5
      ,p_grr_attribute6                 =>  p_grr_attribute6
      ,p_grr_attribute7                 =>  p_grr_attribute7
      ,p_grr_attribute8                 =>  p_grr_attribute8
      ,p_grr_attribute9                 =>  p_grr_attribute9
      ,p_grr_attribute10                =>  p_grr_attribute10
      ,p_grr_attribute11                =>  p_grr_attribute11
      ,p_grr_attribute12                =>  p_grr_attribute12
      ,p_grr_attribute13                =>  p_grr_attribute13
      ,p_grr_attribute14                =>  p_grr_attribute14
      ,p_grr_attribute15                =>  p_grr_attribute15
      ,p_grr_attribute16                =>  p_grr_attribute16
      ,p_grr_attribute17                =>  p_grr_attribute17
      ,p_grr_attribute18                =>  p_grr_attribute18
      ,p_grr_attribute19                =>  p_grr_attribute19
      ,p_grr_attribute20                =>  p_grr_attribute20
      ,p_grr_attribute21                =>  p_grr_attribute21
      ,p_grr_attribute22                =>  p_grr_attribute22
      ,p_grr_attribute23                =>  p_grr_attribute23
      ,p_grr_attribute24                =>  p_grr_attribute24
      ,p_grr_attribute25                =>  p_grr_attribute25
      ,p_grr_attribute26                =>  p_grr_attribute26
      ,p_grr_attribute27                =>  p_grr_attribute27
      ,p_grr_attribute28                =>  p_grr_attribute28
      ,p_grr_attribute29                =>  p_grr_attribute29
      ,p_grr_attribute30                =>  p_grr_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_GRADE_RATE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_GRADE_RATE
    --
  end;
  --
  ben_profile_handler.event_handler
    (p_event                       => 'CREATE',
     p_base_table                  => 'BEN_VRBL_RT_PRFL_F',
     p_base_table_column           => 'VRBL_RT_PRFL_ID',
     p_base_table_column_value     => p_vrbl_rt_prfl_id,
     p_base_table_reference_column => 'RT_GRD_FLAG',
     p_reference_table             => 'BEN_GRADE_RT_F',
     p_reference_table_column      => 'VRBL_RT_PRFL_ID');
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
  p_grade_rt_id := l_grade_rt_id;
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
    ROLLBACK TO create_GRADE_RATE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_grade_rt_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_GRADE_RATE;
    raise;
    --
end create_GRADE_RATE;
-- ----------------------------------------------------------------------------
-- |------------------------< update_GRADE_RATE >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_GRADE_RATE
  (p_validate                       in  boolean   default false
  ,p_grade_rt_id                    in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_vrbl_rt_prfl_id                in  number    default hr_api.g_number
  ,p_grade_id                       in  number    default hr_api.g_number
  ,p_ordr_num                       in  number    default hr_api.g_number
  ,p_excld_flag                     in  varchar2  default hr_api.g_varchar2
  ,p_grr_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_grr_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_grr_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_grr_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_grr_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_grr_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_grr_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_grr_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_grr_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_grr_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_grr_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_grr_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_grr_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_grr_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_grr_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_grr_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_grr_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_grr_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_grr_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_grr_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_grr_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_grr_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_grr_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_grr_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_grr_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_grr_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_grr_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_grr_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_grr_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_grr_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_grr_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_GRADE_RATE';
  l_object_version_number ben_grade_rt_f.object_version_number%TYPE;
  l_effective_start_date ben_grade_rt_f.effective_start_date%TYPE;
  l_effective_end_date ben_grade_rt_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_GRADE_RATE;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_GRADE_RATE
    --
    ben_GRADE_RATE_bk2.update_GRADE_RATE_b
      (
       p_grade_rt_id                    =>  p_grade_rt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_grade_id                       =>  p_grade_id
      ,p_ordr_num                       =>  p_ordr_num
      ,p_excld_flag                     =>  p_excld_flag
      ,p_grr_attribute_category         =>  p_grr_attribute_category
      ,p_grr_attribute1                 =>  p_grr_attribute1
      ,p_grr_attribute2                 =>  p_grr_attribute2
      ,p_grr_attribute3                 =>  p_grr_attribute3
      ,p_grr_attribute4                 =>  p_grr_attribute4
      ,p_grr_attribute5                 =>  p_grr_attribute5
      ,p_grr_attribute6                 =>  p_grr_attribute6
      ,p_grr_attribute7                 =>  p_grr_attribute7
      ,p_grr_attribute8                 =>  p_grr_attribute8
      ,p_grr_attribute9                 =>  p_grr_attribute9
      ,p_grr_attribute10                =>  p_grr_attribute10
      ,p_grr_attribute11                =>  p_grr_attribute11
      ,p_grr_attribute12                =>  p_grr_attribute12
      ,p_grr_attribute13                =>  p_grr_attribute13
      ,p_grr_attribute14                =>  p_grr_attribute14
      ,p_grr_attribute15                =>  p_grr_attribute15
      ,p_grr_attribute16                =>  p_grr_attribute16
      ,p_grr_attribute17                =>  p_grr_attribute17
      ,p_grr_attribute18                =>  p_grr_attribute18
      ,p_grr_attribute19                =>  p_grr_attribute19
      ,p_grr_attribute20                =>  p_grr_attribute20
      ,p_grr_attribute21                =>  p_grr_attribute21
      ,p_grr_attribute22                =>  p_grr_attribute22
      ,p_grr_attribute23                =>  p_grr_attribute23
      ,p_grr_attribute24                =>  p_grr_attribute24
      ,p_grr_attribute25                =>  p_grr_attribute25
      ,p_grr_attribute26                =>  p_grr_attribute26
      ,p_grr_attribute27                =>  p_grr_attribute27
      ,p_grr_attribute28                =>  p_grr_attribute28
      ,p_grr_attribute29                =>  p_grr_attribute29
      ,p_grr_attribute30                =>  p_grr_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_GRADE_RATE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_GRADE_RATE
    --
  end;
  --
  ben_grr_upd.upd
    (
     p_grade_rt_id                   => p_grade_rt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => p_business_group_id
    ,p_vrbl_rt_prfl_id               => p_vrbl_rt_prfl_id
    ,p_grade_id                      => p_grade_id
    ,p_ordr_num                      => p_ordr_num
    ,p_excld_flag                    => p_excld_flag
    ,p_grr_attribute_category        => p_grr_attribute_category
    ,p_grr_attribute1                => p_grr_attribute1
    ,p_grr_attribute2                => p_grr_attribute2
    ,p_grr_attribute3                => p_grr_attribute3
    ,p_grr_attribute4                => p_grr_attribute4
    ,p_grr_attribute5                => p_grr_attribute5
    ,p_grr_attribute6                => p_grr_attribute6
    ,p_grr_attribute7                => p_grr_attribute7
    ,p_grr_attribute8                => p_grr_attribute8
    ,p_grr_attribute9                => p_grr_attribute9
    ,p_grr_attribute10               => p_grr_attribute10
    ,p_grr_attribute11               => p_grr_attribute11
    ,p_grr_attribute12               => p_grr_attribute12
    ,p_grr_attribute13               => p_grr_attribute13
    ,p_grr_attribute14               => p_grr_attribute14
    ,p_grr_attribute15               => p_grr_attribute15
    ,p_grr_attribute16               => p_grr_attribute16
    ,p_grr_attribute17               => p_grr_attribute17
    ,p_grr_attribute18               => p_grr_attribute18
    ,p_grr_attribute19               => p_grr_attribute19
    ,p_grr_attribute20               => p_grr_attribute20
    ,p_grr_attribute21               => p_grr_attribute21
    ,p_grr_attribute22               => p_grr_attribute22
    ,p_grr_attribute23               => p_grr_attribute23
    ,p_grr_attribute24               => p_grr_attribute24
    ,p_grr_attribute25               => p_grr_attribute25
    ,p_grr_attribute26               => p_grr_attribute26
    ,p_grr_attribute27               => p_grr_attribute27
    ,p_grr_attribute28               => p_grr_attribute28
    ,p_grr_attribute29               => p_grr_attribute29
    ,p_grr_attribute30               => p_grr_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_GRADE_RATE
    --
    ben_GRADE_RATE_bk2.update_GRADE_RATE_a
      (
       p_grade_rt_id                    =>  p_grade_rt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_grade_id                       =>  p_grade_id
      ,p_ordr_num                       =>  p_ordr_num
      ,p_excld_flag                     =>  p_excld_flag
      ,p_grr_attribute_category         =>  p_grr_attribute_category
      ,p_grr_attribute1                 =>  p_grr_attribute1
      ,p_grr_attribute2                 =>  p_grr_attribute2
      ,p_grr_attribute3                 =>  p_grr_attribute3
      ,p_grr_attribute4                 =>  p_grr_attribute4
      ,p_grr_attribute5                 =>  p_grr_attribute5
      ,p_grr_attribute6                 =>  p_grr_attribute6
      ,p_grr_attribute7                 =>  p_grr_attribute7
      ,p_grr_attribute8                 =>  p_grr_attribute8
      ,p_grr_attribute9                 =>  p_grr_attribute9
      ,p_grr_attribute10                =>  p_grr_attribute10
      ,p_grr_attribute11                =>  p_grr_attribute11
      ,p_grr_attribute12                =>  p_grr_attribute12
      ,p_grr_attribute13                =>  p_grr_attribute13
      ,p_grr_attribute14                =>  p_grr_attribute14
      ,p_grr_attribute15                =>  p_grr_attribute15
      ,p_grr_attribute16                =>  p_grr_attribute16
      ,p_grr_attribute17                =>  p_grr_attribute17
      ,p_grr_attribute18                =>  p_grr_attribute18
      ,p_grr_attribute19                =>  p_grr_attribute19
      ,p_grr_attribute20                =>  p_grr_attribute20
      ,p_grr_attribute21                =>  p_grr_attribute21
      ,p_grr_attribute22                =>  p_grr_attribute22
      ,p_grr_attribute23                =>  p_grr_attribute23
      ,p_grr_attribute24                =>  p_grr_attribute24
      ,p_grr_attribute25                =>  p_grr_attribute25
      ,p_grr_attribute26                =>  p_grr_attribute26
      ,p_grr_attribute27                =>  p_grr_attribute27
      ,p_grr_attribute28                =>  p_grr_attribute28
      ,p_grr_attribute29                =>  p_grr_attribute29
      ,p_grr_attribute30                =>  p_grr_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_GRADE_RATE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_GRADE_RATE
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
    ROLLBACK TO update_GRADE_RATE;
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
    ROLLBACK TO update_GRADE_RATE;
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;

    raise;
    --
end update_GRADE_RATE;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_GRADE_RATE >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_GRADE_RATE
  (p_validate                       in  boolean  default false
  ,p_grade_rt_id                    in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_GRADE_RATE';
  l_object_version_number ben_grade_rt_f.object_version_number%TYPE;
  l_effective_start_date ben_grade_rt_f.effective_start_date%TYPE;
  l_effective_end_date ben_grade_rt_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_GRADE_RATE;
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
    -- Start of API User Hook for the before hook of delete_GRADE_RATE
    --
    ben_GRADE_RATE_bk3.delete_GRADE_RATE_b
      (
       p_grade_rt_id                    =>  p_grade_rt_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_GRADE_RATE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_GRADE_RATE
    --
  end;
  --
  ben_grr_del.del
    (
     p_grade_rt_id                   => p_grade_rt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_GRADE_RATE
    --
    ben_GRADE_RATE_bk3.delete_GRADE_RATE_a
      (
       p_grade_rt_id                    =>  p_grade_rt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_GRADE_RATE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_GRADE_RATE
    --
  end;
  --
  ben_profile_handler.event_handler
    (p_event                       => 'DELETE',
     p_base_table                  => 'BEN_VRBL_RT_PRFL_F',
     p_base_table_column           => 'VRBL_RT_PRFL_ID',
     p_base_table_column_value     => ben_grr_shd.g_old_rec.vrbl_rt_prfl_id,
     p_base_table_reference_column => 'RT_GRD_FLAG',
     p_reference_table             => 'BEN_GRADE_RT_F',
     p_reference_table_column      => 'VRBL_RT_PRFL_ID');
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
    ROLLBACK TO delete_GRADE_RATE;
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
    ROLLBACK TO delete_GRADE_RATE;
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;

    raise;
    --
end delete_GRADE_RATE;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_grade_rt_id                   in     number
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
  ben_grr_shd.lck
    (
      p_grade_rt_id                 => p_grade_rt_id
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
end ben_GRADE_RATE_api;

/
