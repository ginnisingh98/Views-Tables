--------------------------------------------------------
--  DDL for Package Body BEN_GENDER_RATE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_GENDER_RATE_API" as
/* $Header: begnrapi.pkb 120.0 2005/05/28 03:07:06 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_GENDER_RATE_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_GENDER_RATE >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_GENDER_RATE
  (p_validate                       in  boolean   default false
  ,p_gndr_rt_id                     out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default null
  ,p_vrbl_rt_prfl_id                in  number    default null
  ,p_ordr_num                       in  number    default null
  ,p_gndr_cd                        in  varchar2  default null
  ,p_excld_flag                     in  varchar2  default null
  ,p_gnr_attribute_category         in  varchar2  default null
  ,p_gnr_attribute1                 in  varchar2  default null
  ,p_gnr_attribute2                 in  varchar2  default null
  ,p_gnr_attribute3                 in  varchar2  default null
  ,p_gnr_attribute4                 in  varchar2  default null
  ,p_gnr_attribute5                 in  varchar2  default null
  ,p_gnr_attribute6                 in  varchar2  default null
  ,p_gnr_attribute7                 in  varchar2  default null
  ,p_gnr_attribute8                 in  varchar2  default null
  ,p_gnr_attribute9                 in  varchar2  default null
  ,p_gnr_attribute10                in  varchar2  default null
  ,p_gnr_attribute11                in  varchar2  default null
  ,p_gnr_attribute12                in  varchar2  default null
  ,p_gnr_attribute13                in  varchar2  default null
  ,p_gnr_attribute14                in  varchar2  default null
  ,p_gnr_attribute15                in  varchar2  default null
  ,p_gnr_attribute16                in  varchar2  default null
  ,p_gnr_attribute17                in  varchar2  default null
  ,p_gnr_attribute18                in  varchar2  default null
  ,p_gnr_attribute19                in  varchar2  default null
  ,p_gnr_attribute20                in  varchar2  default null
  ,p_gnr_attribute21                in  varchar2  default null
  ,p_gnr_attribute22                in  varchar2  default null
  ,p_gnr_attribute23                in  varchar2  default null
  ,p_gnr_attribute24                in  varchar2  default null
  ,p_gnr_attribute25                in  varchar2  default null
  ,p_gnr_attribute26                in  varchar2  default null
  ,p_gnr_attribute27                in  varchar2  default null
  ,p_gnr_attribute28                in  varchar2  default null
  ,p_gnr_attribute29                in  varchar2  default null
  ,p_gnr_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_gndr_rt_id ben_gndr_rt_f.gndr_rt_id%TYPE;
  l_effective_start_date ben_gndr_rt_f.effective_start_date%TYPE;
  l_effective_end_date ben_gndr_rt_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_GENDER_RATE';
  l_object_version_number ben_gndr_rt_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_GENDER_RATE;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_GENDER_RATE
    --
    ben_GENDER_RATE_bk1.create_GENDER_RATE_b
      (
       p_business_group_id              =>  p_business_group_id
      ,p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_ordr_num                       =>  p_ordr_num
      ,p_gndr_cd                        =>  p_gndr_cd
      ,p_excld_flag                     =>  p_excld_flag
      ,p_gnr_attribute_category         =>  p_gnr_attribute_category
      ,p_gnr_attribute1                 =>  p_gnr_attribute1
      ,p_gnr_attribute2                 =>  p_gnr_attribute2
      ,p_gnr_attribute3                 =>  p_gnr_attribute3
      ,p_gnr_attribute4                 =>  p_gnr_attribute4
      ,p_gnr_attribute5                 =>  p_gnr_attribute5
      ,p_gnr_attribute6                 =>  p_gnr_attribute6
      ,p_gnr_attribute7                 =>  p_gnr_attribute7
      ,p_gnr_attribute8                 =>  p_gnr_attribute8
      ,p_gnr_attribute9                 =>  p_gnr_attribute9
      ,p_gnr_attribute10                =>  p_gnr_attribute10
      ,p_gnr_attribute11                =>  p_gnr_attribute11
      ,p_gnr_attribute12                =>  p_gnr_attribute12
      ,p_gnr_attribute13                =>  p_gnr_attribute13
      ,p_gnr_attribute14                =>  p_gnr_attribute14
      ,p_gnr_attribute15                =>  p_gnr_attribute15
      ,p_gnr_attribute16                =>  p_gnr_attribute16
      ,p_gnr_attribute17                =>  p_gnr_attribute17
      ,p_gnr_attribute18                =>  p_gnr_attribute18
      ,p_gnr_attribute19                =>  p_gnr_attribute19
      ,p_gnr_attribute20                =>  p_gnr_attribute20
      ,p_gnr_attribute21                =>  p_gnr_attribute21
      ,p_gnr_attribute22                =>  p_gnr_attribute22
      ,p_gnr_attribute23                =>  p_gnr_attribute23
      ,p_gnr_attribute24                =>  p_gnr_attribute24
      ,p_gnr_attribute25                =>  p_gnr_attribute25
      ,p_gnr_attribute26                =>  p_gnr_attribute26
      ,p_gnr_attribute27                =>  p_gnr_attribute27
      ,p_gnr_attribute28                =>  p_gnr_attribute28
      ,p_gnr_attribute29                =>  p_gnr_attribute29
      ,p_gnr_attribute30                =>  p_gnr_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_GENDER_RATE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_GENDER_RATE
    --
  end;
  --
  ben_gnr_ins.ins
    (
     p_gndr_rt_id                    => l_gndr_rt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => p_business_group_id
    ,p_vrbl_rt_prfl_id               => p_vrbl_rt_prfl_id
    ,p_ordr_num                      => p_ordr_num
    ,p_gndr_cd                       => p_gndr_cd
    ,p_excld_flag                    => p_excld_flag
    ,p_gnr_attribute_category        => p_gnr_attribute_category
    ,p_gnr_attribute1                => p_gnr_attribute1
    ,p_gnr_attribute2                => p_gnr_attribute2
    ,p_gnr_attribute3                => p_gnr_attribute3
    ,p_gnr_attribute4                => p_gnr_attribute4
    ,p_gnr_attribute5                => p_gnr_attribute5
    ,p_gnr_attribute6                => p_gnr_attribute6
    ,p_gnr_attribute7                => p_gnr_attribute7
    ,p_gnr_attribute8                => p_gnr_attribute8
    ,p_gnr_attribute9                => p_gnr_attribute9
    ,p_gnr_attribute10               => p_gnr_attribute10
    ,p_gnr_attribute11               => p_gnr_attribute11
    ,p_gnr_attribute12               => p_gnr_attribute12
    ,p_gnr_attribute13               => p_gnr_attribute13
    ,p_gnr_attribute14               => p_gnr_attribute14
    ,p_gnr_attribute15               => p_gnr_attribute15
    ,p_gnr_attribute16               => p_gnr_attribute16
    ,p_gnr_attribute17               => p_gnr_attribute17
    ,p_gnr_attribute18               => p_gnr_attribute18
    ,p_gnr_attribute19               => p_gnr_attribute19
    ,p_gnr_attribute20               => p_gnr_attribute20
    ,p_gnr_attribute21               => p_gnr_attribute21
    ,p_gnr_attribute22               => p_gnr_attribute22
    ,p_gnr_attribute23               => p_gnr_attribute23
    ,p_gnr_attribute24               => p_gnr_attribute24
    ,p_gnr_attribute25               => p_gnr_attribute25
    ,p_gnr_attribute26               => p_gnr_attribute26
    ,p_gnr_attribute27               => p_gnr_attribute27
    ,p_gnr_attribute28               => p_gnr_attribute28
    ,p_gnr_attribute29               => p_gnr_attribute29
    ,p_gnr_attribute30               => p_gnr_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_GENDER_RATE
    --
    ben_GENDER_RATE_bk1.create_GENDER_RATE_a
      (
       p_gndr_rt_id                     =>  l_gndr_rt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_ordr_num                       =>  p_ordr_num
      ,p_gndr_cd                        =>  p_gndr_cd
      ,p_excld_flag                     =>  p_excld_flag
      ,p_gnr_attribute_category         =>  p_gnr_attribute_category
      ,p_gnr_attribute1                 =>  p_gnr_attribute1
      ,p_gnr_attribute2                 =>  p_gnr_attribute2
      ,p_gnr_attribute3                 =>  p_gnr_attribute3
      ,p_gnr_attribute4                 =>  p_gnr_attribute4
      ,p_gnr_attribute5                 =>  p_gnr_attribute5
      ,p_gnr_attribute6                 =>  p_gnr_attribute6
      ,p_gnr_attribute7                 =>  p_gnr_attribute7
      ,p_gnr_attribute8                 =>  p_gnr_attribute8
      ,p_gnr_attribute9                 =>  p_gnr_attribute9
      ,p_gnr_attribute10                =>  p_gnr_attribute10
      ,p_gnr_attribute11                =>  p_gnr_attribute11
      ,p_gnr_attribute12                =>  p_gnr_attribute12
      ,p_gnr_attribute13                =>  p_gnr_attribute13
      ,p_gnr_attribute14                =>  p_gnr_attribute14
      ,p_gnr_attribute15                =>  p_gnr_attribute15
      ,p_gnr_attribute16                =>  p_gnr_attribute16
      ,p_gnr_attribute17                =>  p_gnr_attribute17
      ,p_gnr_attribute18                =>  p_gnr_attribute18
      ,p_gnr_attribute19                =>  p_gnr_attribute19
      ,p_gnr_attribute20                =>  p_gnr_attribute20
      ,p_gnr_attribute21                =>  p_gnr_attribute21
      ,p_gnr_attribute22                =>  p_gnr_attribute22
      ,p_gnr_attribute23                =>  p_gnr_attribute23
      ,p_gnr_attribute24                =>  p_gnr_attribute24
      ,p_gnr_attribute25                =>  p_gnr_attribute25
      ,p_gnr_attribute26                =>  p_gnr_attribute26
      ,p_gnr_attribute27                =>  p_gnr_attribute27
      ,p_gnr_attribute28                =>  p_gnr_attribute28
      ,p_gnr_attribute29                =>  p_gnr_attribute29
      ,p_gnr_attribute30                =>  p_gnr_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_GENDER_RATE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_GENDER_RATE
    --
  end;
  --
  ben_profile_handler.event_handler
    (p_event                       => 'CREATE',
     p_base_table                  => 'BEN_VRBL_RT_PRFL_F',
     p_base_table_column           => 'VRBL_RT_PRFL_ID',
     p_base_table_column_value     => p_vrbl_rt_prfl_id,
     p_base_table_reference_column => 'RT_GNDR_FLAG',
     p_reference_table             => 'BEN_GNDR_RT_F',
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
  p_gndr_rt_id := l_gndr_rt_id;
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
    ROLLBACK TO create_GENDER_RATE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_gndr_rt_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_GENDER_RATE;
    raise;
    --
end create_GENDER_RATE;
-- ----------------------------------------------------------------------------
-- |------------------------< update_GENDER_RATE >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_GENDER_RATE
  (p_validate                       in  boolean   default false
  ,p_gndr_rt_id                     in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_vrbl_rt_prfl_id                in  number    default hr_api.g_number
  ,p_ordr_num                       in  number    default hr_api.g_number
  ,p_gndr_cd                        in  varchar2  default hr_api.g_varchar2
  ,p_excld_flag                     in  varchar2  default hr_api.g_varchar2
  ,p_gnr_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_gnr_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_gnr_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_gnr_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_gnr_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_gnr_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_gnr_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_gnr_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_gnr_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_gnr_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_gnr_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_gnr_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_gnr_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_gnr_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_gnr_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_gnr_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_gnr_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_gnr_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_gnr_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_gnr_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_gnr_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_gnr_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_gnr_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_gnr_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_gnr_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_gnr_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_gnr_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_gnr_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_gnr_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_gnr_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_gnr_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_GENDER_RATE';
  l_object_version_number ben_gndr_rt_f.object_version_number%TYPE;
  l_effective_start_date ben_gndr_rt_f.effective_start_date%TYPE;
  l_effective_end_date ben_gndr_rt_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_GENDER_RATE;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_GENDER_RATE
    --
    ben_GENDER_RATE_bk2.update_GENDER_RATE_b
      (
       p_gndr_rt_id                     =>  p_gndr_rt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_ordr_num                       =>  p_ordr_num
      ,p_gndr_cd                        =>  p_gndr_cd
      ,p_excld_flag                     =>  p_excld_flag
      ,p_gnr_attribute_category         =>  p_gnr_attribute_category
      ,p_gnr_attribute1                 =>  p_gnr_attribute1
      ,p_gnr_attribute2                 =>  p_gnr_attribute2
      ,p_gnr_attribute3                 =>  p_gnr_attribute3
      ,p_gnr_attribute4                 =>  p_gnr_attribute4
      ,p_gnr_attribute5                 =>  p_gnr_attribute5
      ,p_gnr_attribute6                 =>  p_gnr_attribute6
      ,p_gnr_attribute7                 =>  p_gnr_attribute7
      ,p_gnr_attribute8                 =>  p_gnr_attribute8
      ,p_gnr_attribute9                 =>  p_gnr_attribute9
      ,p_gnr_attribute10                =>  p_gnr_attribute10
      ,p_gnr_attribute11                =>  p_gnr_attribute11
      ,p_gnr_attribute12                =>  p_gnr_attribute12
      ,p_gnr_attribute13                =>  p_gnr_attribute13
      ,p_gnr_attribute14                =>  p_gnr_attribute14
      ,p_gnr_attribute15                =>  p_gnr_attribute15
      ,p_gnr_attribute16                =>  p_gnr_attribute16
      ,p_gnr_attribute17                =>  p_gnr_attribute17
      ,p_gnr_attribute18                =>  p_gnr_attribute18
      ,p_gnr_attribute19                =>  p_gnr_attribute19
      ,p_gnr_attribute20                =>  p_gnr_attribute20
      ,p_gnr_attribute21                =>  p_gnr_attribute21
      ,p_gnr_attribute22                =>  p_gnr_attribute22
      ,p_gnr_attribute23                =>  p_gnr_attribute23
      ,p_gnr_attribute24                =>  p_gnr_attribute24
      ,p_gnr_attribute25                =>  p_gnr_attribute25
      ,p_gnr_attribute26                =>  p_gnr_attribute26
      ,p_gnr_attribute27                =>  p_gnr_attribute27
      ,p_gnr_attribute28                =>  p_gnr_attribute28
      ,p_gnr_attribute29                =>  p_gnr_attribute29
      ,p_gnr_attribute30                =>  p_gnr_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_GENDER_RATE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_GENDER_RATE
    --
  end;
  --
  ben_gnr_upd.upd
    (
     p_gndr_rt_id                    => p_gndr_rt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => p_business_group_id
    ,p_vrbl_rt_prfl_id               => p_vrbl_rt_prfl_id
    ,p_ordr_num                      => p_ordr_num
    ,p_gndr_cd                       => p_gndr_cd
    ,p_excld_flag                    => p_excld_flag
    ,p_gnr_attribute_category        => p_gnr_attribute_category
    ,p_gnr_attribute1                => p_gnr_attribute1
    ,p_gnr_attribute2                => p_gnr_attribute2
    ,p_gnr_attribute3                => p_gnr_attribute3
    ,p_gnr_attribute4                => p_gnr_attribute4
    ,p_gnr_attribute5                => p_gnr_attribute5
    ,p_gnr_attribute6                => p_gnr_attribute6
    ,p_gnr_attribute7                => p_gnr_attribute7
    ,p_gnr_attribute8                => p_gnr_attribute8
    ,p_gnr_attribute9                => p_gnr_attribute9
    ,p_gnr_attribute10               => p_gnr_attribute10
    ,p_gnr_attribute11               => p_gnr_attribute11
    ,p_gnr_attribute12               => p_gnr_attribute12
    ,p_gnr_attribute13               => p_gnr_attribute13
    ,p_gnr_attribute14               => p_gnr_attribute14
    ,p_gnr_attribute15               => p_gnr_attribute15
    ,p_gnr_attribute16               => p_gnr_attribute16
    ,p_gnr_attribute17               => p_gnr_attribute17
    ,p_gnr_attribute18               => p_gnr_attribute18
    ,p_gnr_attribute19               => p_gnr_attribute19
    ,p_gnr_attribute20               => p_gnr_attribute20
    ,p_gnr_attribute21               => p_gnr_attribute21
    ,p_gnr_attribute22               => p_gnr_attribute22
    ,p_gnr_attribute23               => p_gnr_attribute23
    ,p_gnr_attribute24               => p_gnr_attribute24
    ,p_gnr_attribute25               => p_gnr_attribute25
    ,p_gnr_attribute26               => p_gnr_attribute26
    ,p_gnr_attribute27               => p_gnr_attribute27
    ,p_gnr_attribute28               => p_gnr_attribute28
    ,p_gnr_attribute29               => p_gnr_attribute29
    ,p_gnr_attribute30               => p_gnr_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_GENDER_RATE
    --
    ben_GENDER_RATE_bk2.update_GENDER_RATE_a
      (
       p_gndr_rt_id                     =>  p_gndr_rt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_ordr_num                       =>  p_ordr_num
      ,p_gndr_cd                        =>  p_gndr_cd
      ,p_excld_flag                     =>  p_excld_flag
      ,p_gnr_attribute_category         =>  p_gnr_attribute_category
      ,p_gnr_attribute1                 =>  p_gnr_attribute1
      ,p_gnr_attribute2                 =>  p_gnr_attribute2
      ,p_gnr_attribute3                 =>  p_gnr_attribute3
      ,p_gnr_attribute4                 =>  p_gnr_attribute4
      ,p_gnr_attribute5                 =>  p_gnr_attribute5
      ,p_gnr_attribute6                 =>  p_gnr_attribute6
      ,p_gnr_attribute7                 =>  p_gnr_attribute7
      ,p_gnr_attribute8                 =>  p_gnr_attribute8
      ,p_gnr_attribute9                 =>  p_gnr_attribute9
      ,p_gnr_attribute10                =>  p_gnr_attribute10
      ,p_gnr_attribute11                =>  p_gnr_attribute11
      ,p_gnr_attribute12                =>  p_gnr_attribute12
      ,p_gnr_attribute13                =>  p_gnr_attribute13
      ,p_gnr_attribute14                =>  p_gnr_attribute14
      ,p_gnr_attribute15                =>  p_gnr_attribute15
      ,p_gnr_attribute16                =>  p_gnr_attribute16
      ,p_gnr_attribute17                =>  p_gnr_attribute17
      ,p_gnr_attribute18                =>  p_gnr_attribute18
      ,p_gnr_attribute19                =>  p_gnr_attribute19
      ,p_gnr_attribute20                =>  p_gnr_attribute20
      ,p_gnr_attribute21                =>  p_gnr_attribute21
      ,p_gnr_attribute22                =>  p_gnr_attribute22
      ,p_gnr_attribute23                =>  p_gnr_attribute23
      ,p_gnr_attribute24                =>  p_gnr_attribute24
      ,p_gnr_attribute25                =>  p_gnr_attribute25
      ,p_gnr_attribute26                =>  p_gnr_attribute26
      ,p_gnr_attribute27                =>  p_gnr_attribute27
      ,p_gnr_attribute28                =>  p_gnr_attribute28
      ,p_gnr_attribute29                =>  p_gnr_attribute29
      ,p_gnr_attribute30                =>  p_gnr_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_GENDER_RATE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_GENDER_RATE
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
    ROLLBACK TO update_GENDER_RATE;
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
    ROLLBACK TO update_GENDER_RATE;
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;

    raise;
    --
end update_GENDER_RATE;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_GENDER_RATE >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_GENDER_RATE
  (p_validate                       in  boolean  default false
  ,p_gndr_rt_id                     in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_GENDER_RATE';
  l_object_version_number ben_gndr_rt_f.object_version_number%TYPE;
  l_effective_start_date ben_gndr_rt_f.effective_start_date%TYPE;
  l_effective_end_date ben_gndr_rt_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_GENDER_RATE;
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
    -- Start of API User Hook for the before hook of delete_GENDER_RATE
    --
    ben_GENDER_RATE_bk3.delete_GENDER_RATE_b
      (
       p_gndr_rt_id                     =>  p_gndr_rt_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_GENDER_RATE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_GENDER_RATE
    --
  end;
  --
  ben_gnr_del.del
    (
     p_gndr_rt_id                    => p_gndr_rt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_GENDER_RATE
    --
    ben_GENDER_RATE_bk3.delete_GENDER_RATE_a
      (
       p_gndr_rt_id                     =>  p_gndr_rt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_GENDER_RATE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_GENDER_RATE
    --
  end;
  --
  ben_profile_handler.event_handler
    (p_event                       => 'DELETE',
     p_base_table                  => 'BEN_VRBL_RT_PRFL_F',
     p_base_table_column           => 'VRBL_RT_PRFL_ID',
     p_base_table_column_value     => ben_gnr_shd.g_old_rec.vrbl_rt_prfl_id,
     p_base_table_reference_column => 'RT_GNDR_FLAG',
     p_reference_table             => 'BEN_GNDR_RT_F',
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
    ROLLBACK TO delete_GENDER_RATE;
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
    ROLLBACK TO delete_GENDER_RATE;
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;

    raise;
    --
end delete_GENDER_RATE;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_gndr_rt_id                   in     number
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
  ben_gnr_shd.lck
    (
      p_gndr_rt_id                 => p_gndr_rt_id
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
end ben_GENDER_RATE_api;

/
