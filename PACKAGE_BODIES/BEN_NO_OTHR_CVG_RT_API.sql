--------------------------------------------------------
--  DDL for Package Body BEN_NO_OTHR_CVG_RT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_NO_OTHR_CVG_RT_API" as
/* $Header: benocapi.pkb 120.0 2005/05/28 09:09:57 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_NO_OTHR_CVG_RT_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_NO_OTHR_CVG_RT >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_NO_OTHR_CVG_RT
  (p_validate                       in  boolean   default false
  ,p_no_othr_cvg_rt_id       out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_coord_ben_no_cvg_flag          in  varchar2  default 'N'
  ,p_vrbl_rt_prfl_id                  in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_noc_attribute_category         in  varchar2  default null
  ,p_noc_attribute1                 in  varchar2  default null
  ,p_noc_attribute2                 in  varchar2  default null
  ,p_noc_attribute3                 in  varchar2  default null
  ,p_noc_attribute4                 in  varchar2  default null
  ,p_noc_attribute5                 in  varchar2  default null
  ,p_noc_attribute6                 in  varchar2  default null
  ,p_noc_attribute7                 in  varchar2  default null
  ,p_noc_attribute8                 in  varchar2  default null
  ,p_noc_attribute9                 in  varchar2  default null
  ,p_noc_attribute10                in  varchar2  default null
  ,p_noc_attribute11                in  varchar2  default null
  ,p_noc_attribute12                in  varchar2  default null
  ,p_noc_attribute13                in  varchar2  default null
  ,p_noc_attribute14                in  varchar2  default null
  ,p_noc_attribute15                in  varchar2  default null
  ,p_noc_attribute16                in  varchar2  default null
  ,p_noc_attribute17                in  varchar2  default null
  ,p_noc_attribute18                in  varchar2  default null
  ,p_noc_attribute19                in  varchar2  default null
  ,p_noc_attribute20                in  varchar2  default null
  ,p_noc_attribute21                in  varchar2  default null
  ,p_noc_attribute22                in  varchar2  default null
  ,p_noc_attribute23                in  varchar2  default null
  ,p_noc_attribute24                in  varchar2  default null
  ,p_noc_attribute25                in  varchar2  default null
  ,p_noc_attribute26                in  varchar2  default null
  ,p_noc_attribute27                in  varchar2  default null
  ,p_noc_attribute28                in  varchar2  default null
  ,p_noc_attribute29                in  varchar2  default null
  ,p_noc_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_no_othr_cvg_rt_id ben_no_othr_cvg_rt_f.no_othr_cvg_rt_id%TYPE;
  l_effective_start_date ben_no_othr_cvg_rt_f.effective_start_date%TYPE;
  l_effective_end_date ben_no_othr_cvg_rt_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_NO_OTHR_CVG_RT';
  l_object_version_number ben_no_othr_cvg_rt_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_NO_OTHR_CVG_RT;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_NO_OTHR_CVG_RT
    --
    ben_NO_OTHR_CVG_RT_bk1.create_NO_OTHR_CVG_RT_b
      (
       p_coord_ben_no_cvg_flag          =>  p_coord_ben_no_cvg_flag
      ,p_vrbl_rt_prfl_id                  =>  p_vrbl_rt_prfl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_noc_attribute_category         =>  p_noc_attribute_category
      ,p_noc_attribute1                 =>  p_noc_attribute1
      ,p_noc_attribute2                 =>  p_noc_attribute2
      ,p_noc_attribute3                 =>  p_noc_attribute3
      ,p_noc_attribute4                 =>  p_noc_attribute4
      ,p_noc_attribute5                 =>  p_noc_attribute5
      ,p_noc_attribute6                 =>  p_noc_attribute6
      ,p_noc_attribute7                 =>  p_noc_attribute7
      ,p_noc_attribute8                 =>  p_noc_attribute8
      ,p_noc_attribute9                 =>  p_noc_attribute9
      ,p_noc_attribute10                =>  p_noc_attribute10
      ,p_noc_attribute11                =>  p_noc_attribute11
      ,p_noc_attribute12                =>  p_noc_attribute12
      ,p_noc_attribute13                =>  p_noc_attribute13
      ,p_noc_attribute14                =>  p_noc_attribute14
      ,p_noc_attribute15                =>  p_noc_attribute15
      ,p_noc_attribute16                =>  p_noc_attribute16
      ,p_noc_attribute17                =>  p_noc_attribute17
      ,p_noc_attribute18                =>  p_noc_attribute18
      ,p_noc_attribute19                =>  p_noc_attribute19
      ,p_noc_attribute20                =>  p_noc_attribute20
      ,p_noc_attribute21                =>  p_noc_attribute21
      ,p_noc_attribute22                =>  p_noc_attribute22
      ,p_noc_attribute23                =>  p_noc_attribute23
      ,p_noc_attribute24                =>  p_noc_attribute24
      ,p_noc_attribute25                =>  p_noc_attribute25
      ,p_noc_attribute26                =>  p_noc_attribute26
      ,p_noc_attribute27                =>  p_noc_attribute27
      ,p_noc_attribute28                =>  p_noc_attribute28
      ,p_noc_attribute29                =>  p_noc_attribute29
      ,p_noc_attribute30                =>  p_noc_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_NO_OTHR_CVG_RT'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_NO_OTHR_CVG_RT
    --
  end;
  --
  ben_noc_ins.ins
    (
     p_no_othr_cvg_rt_id      => l_no_othr_cvg_rt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_coord_ben_no_cvg_flag         => p_coord_ben_no_cvg_flag
    ,p_vrbl_rt_prfl_id                 => p_vrbl_rt_prfl_id
    ,p_business_group_id             => p_business_group_id
    ,p_noc_attribute_category        => p_noc_attribute_category
    ,p_noc_attribute1                => p_noc_attribute1
    ,p_noc_attribute2                => p_noc_attribute2
    ,p_noc_attribute3                => p_noc_attribute3
    ,p_noc_attribute4                => p_noc_attribute4
    ,p_noc_attribute5                => p_noc_attribute5
    ,p_noc_attribute6                => p_noc_attribute6
    ,p_noc_attribute7                => p_noc_attribute7
    ,p_noc_attribute8                => p_noc_attribute8
    ,p_noc_attribute9                => p_noc_attribute9
    ,p_noc_attribute10               => p_noc_attribute10
    ,p_noc_attribute11               => p_noc_attribute11
    ,p_noc_attribute12               => p_noc_attribute12
    ,p_noc_attribute13               => p_noc_attribute13
    ,p_noc_attribute14               => p_noc_attribute14
    ,p_noc_attribute15               => p_noc_attribute15
    ,p_noc_attribute16               => p_noc_attribute16
    ,p_noc_attribute17               => p_noc_attribute17
    ,p_noc_attribute18               => p_noc_attribute18
    ,p_noc_attribute19               => p_noc_attribute19
    ,p_noc_attribute20               => p_noc_attribute20
    ,p_noc_attribute21               => p_noc_attribute21
    ,p_noc_attribute22               => p_noc_attribute22
    ,p_noc_attribute23               => p_noc_attribute23
    ,p_noc_attribute24               => p_noc_attribute24
    ,p_noc_attribute25               => p_noc_attribute25
    ,p_noc_attribute26               => p_noc_attribute26
    ,p_noc_attribute27               => p_noc_attribute27
    ,p_noc_attribute28               => p_noc_attribute28
    ,p_noc_attribute29               => p_noc_attribute29
    ,p_noc_attribute30               => p_noc_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_NO_OTHR_CVG_RT
    --
    ben_NO_OTHR_CVG_RT_bk1.create_NO_OTHR_CVG_RT_a
      (
       p_no_othr_cvg_rt_id       =>  l_no_othr_cvg_rt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_coord_ben_no_cvg_flag          =>  p_coord_ben_no_cvg_flag
      ,p_vrbl_rt_prfl_id                  =>  p_vrbl_rt_prfl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_noc_attribute_category         =>  p_noc_attribute_category
      ,p_noc_attribute1                 =>  p_noc_attribute1
      ,p_noc_attribute2                 =>  p_noc_attribute2
      ,p_noc_attribute3                 =>  p_noc_attribute3
      ,p_noc_attribute4                 =>  p_noc_attribute4
      ,p_noc_attribute5                 =>  p_noc_attribute5
      ,p_noc_attribute6                 =>  p_noc_attribute6
      ,p_noc_attribute7                 =>  p_noc_attribute7
      ,p_noc_attribute8                 =>  p_noc_attribute8
      ,p_noc_attribute9                 =>  p_noc_attribute9
      ,p_noc_attribute10                =>  p_noc_attribute10
      ,p_noc_attribute11                =>  p_noc_attribute11
      ,p_noc_attribute12                =>  p_noc_attribute12
      ,p_noc_attribute13                =>  p_noc_attribute13
      ,p_noc_attribute14                =>  p_noc_attribute14
      ,p_noc_attribute15                =>  p_noc_attribute15
      ,p_noc_attribute16                =>  p_noc_attribute16
      ,p_noc_attribute17                =>  p_noc_attribute17
      ,p_noc_attribute18                =>  p_noc_attribute18
      ,p_noc_attribute19                =>  p_noc_attribute19
      ,p_noc_attribute20                =>  p_noc_attribute20
      ,p_noc_attribute21                =>  p_noc_attribute21
      ,p_noc_attribute22                =>  p_noc_attribute22
      ,p_noc_attribute23                =>  p_noc_attribute23
      ,p_noc_attribute24                =>  p_noc_attribute24
      ,p_noc_attribute25                =>  p_noc_attribute25
      ,p_noc_attribute26                =>  p_noc_attribute26
      ,p_noc_attribute27                =>  p_noc_attribute27
      ,p_noc_attribute28                =>  p_noc_attribute28
      ,p_noc_attribute29                =>  p_noc_attribute29
      ,p_noc_attribute30                =>  p_noc_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_NO_OTHR_CVG_RT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_NO_OTHR_CVG_RT
    --
  end;
  --
  ben_profile_handler.event_handler
    (p_event                       => 'CREATE',
     p_base_table                  => 'BEN_VRBL_RT_PRFL_F',
     p_base_table_column           => 'VRBL_RT_PRFL_ID',
     p_base_table_column_value     => p_vrbl_rt_prfl_id,
     p_base_table_reference_column => 'RT_NO_OTHR_CVG_FLAG',
     p_reference_table             => 'BEN_NO_OTHR_CVG_RT_F',
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
  p_no_othr_cvg_rt_id := l_no_othr_cvg_rt_id;
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
    ROLLBACK TO create_NO_OTHR_CVG_RT;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_no_othr_cvg_rt_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_NO_OTHR_CVG_RT;
    p_no_othr_cvg_rt_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;

    raise;
    --
end create_NO_OTHR_CVG_RT;
-- ----------------------------------------------------------------------------
-- |------------------------< update_NO_OTHR_CVG_RT >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_NO_OTHR_CVG_RT
  (p_validate                       in  boolean   default false
  ,p_no_othr_cvg_rt_id       in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_coord_ben_no_cvg_flag          in  varchar2  default hr_api.g_varchar2
  ,p_vrbl_rt_prfl_id                  in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_noc_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_noc_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_noc_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_noc_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_noc_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_noc_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_noc_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_noc_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_noc_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_noc_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_noc_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_noc_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_noc_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_noc_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_noc_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_noc_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_noc_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_noc_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_noc_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_noc_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_noc_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_noc_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_noc_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_noc_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_noc_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_noc_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_noc_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_noc_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_noc_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_noc_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_noc_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_NO_OTHR_CVG_RT';
  l_object_version_number ben_no_othr_cvg_rt_f.object_version_number%TYPE;
  l_effective_start_date ben_no_othr_cvg_rt_f.effective_start_date%TYPE;
  l_effective_end_date ben_no_othr_cvg_rt_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_NO_OTHR_CVG_RT;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_NO_OTHR_CVG_RT
    --
    ben_NO_OTHR_CVG_RT_bk2.update_NO_OTHR_CVG_RT_b
      (
       p_no_othr_cvg_rt_id       =>  p_no_othr_cvg_rt_id
      ,p_coord_ben_no_cvg_flag          =>  p_coord_ben_no_cvg_flag
      ,p_vrbl_rt_prfl_id                  =>  p_vrbl_rt_prfl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_noc_attribute_category         =>  p_noc_attribute_category
      ,p_noc_attribute1                 =>  p_noc_attribute1
      ,p_noc_attribute2                 =>  p_noc_attribute2
      ,p_noc_attribute3                 =>  p_noc_attribute3
      ,p_noc_attribute4                 =>  p_noc_attribute4
      ,p_noc_attribute5                 =>  p_noc_attribute5
      ,p_noc_attribute6                 =>  p_noc_attribute6
      ,p_noc_attribute7                 =>  p_noc_attribute7
      ,p_noc_attribute8                 =>  p_noc_attribute8
      ,p_noc_attribute9                 =>  p_noc_attribute9
      ,p_noc_attribute10                =>  p_noc_attribute10
      ,p_noc_attribute11                =>  p_noc_attribute11
      ,p_noc_attribute12                =>  p_noc_attribute12
      ,p_noc_attribute13                =>  p_noc_attribute13
      ,p_noc_attribute14                =>  p_noc_attribute14
      ,p_noc_attribute15                =>  p_noc_attribute15
      ,p_noc_attribute16                =>  p_noc_attribute16
      ,p_noc_attribute17                =>  p_noc_attribute17
      ,p_noc_attribute18                =>  p_noc_attribute18
      ,p_noc_attribute19                =>  p_noc_attribute19
      ,p_noc_attribute20                =>  p_noc_attribute20
      ,p_noc_attribute21                =>  p_noc_attribute21
      ,p_noc_attribute22                =>  p_noc_attribute22
      ,p_noc_attribute23                =>  p_noc_attribute23
      ,p_noc_attribute24                =>  p_noc_attribute24
      ,p_noc_attribute25                =>  p_noc_attribute25
      ,p_noc_attribute26                =>  p_noc_attribute26
      ,p_noc_attribute27                =>  p_noc_attribute27
      ,p_noc_attribute28                =>  p_noc_attribute28
      ,p_noc_attribute29                =>  p_noc_attribute29
      ,p_noc_attribute30                =>  p_noc_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_NO_OTHR_CVG_RT'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_NO_OTHR_CVG_RT
    --
  end;
  --
  ben_noc_upd.upd
    (
     p_no_othr_cvg_rt_id      => p_no_othr_cvg_rt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_coord_ben_no_cvg_flag         => p_coord_ben_no_cvg_flag
    ,p_vrbl_rt_prfl_id                 => p_vrbl_rt_prfl_id
    ,p_business_group_id             => p_business_group_id
    ,p_noc_attribute_category        => p_noc_attribute_category
    ,p_noc_attribute1                => p_noc_attribute1
    ,p_noc_attribute2                => p_noc_attribute2
    ,p_noc_attribute3                => p_noc_attribute3
    ,p_noc_attribute4                => p_noc_attribute4
    ,p_noc_attribute5                => p_noc_attribute5
    ,p_noc_attribute6                => p_noc_attribute6
    ,p_noc_attribute7                => p_noc_attribute7
    ,p_noc_attribute8                => p_noc_attribute8
    ,p_noc_attribute9                => p_noc_attribute9
    ,p_noc_attribute10               => p_noc_attribute10
    ,p_noc_attribute11               => p_noc_attribute11
    ,p_noc_attribute12               => p_noc_attribute12
    ,p_noc_attribute13               => p_noc_attribute13
    ,p_noc_attribute14               => p_noc_attribute14
    ,p_noc_attribute15               => p_noc_attribute15
    ,p_noc_attribute16               => p_noc_attribute16
    ,p_noc_attribute17               => p_noc_attribute17
    ,p_noc_attribute18               => p_noc_attribute18
    ,p_noc_attribute19               => p_noc_attribute19
    ,p_noc_attribute20               => p_noc_attribute20
    ,p_noc_attribute21               => p_noc_attribute21
    ,p_noc_attribute22               => p_noc_attribute22
    ,p_noc_attribute23               => p_noc_attribute23
    ,p_noc_attribute24               => p_noc_attribute24
    ,p_noc_attribute25               => p_noc_attribute25
    ,p_noc_attribute26               => p_noc_attribute26
    ,p_noc_attribute27               => p_noc_attribute27
    ,p_noc_attribute28               => p_noc_attribute28
    ,p_noc_attribute29               => p_noc_attribute29
    ,p_noc_attribute30               => p_noc_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_NO_OTHR_CVG_RT
    --
    ben_NO_OTHR_CVG_RT_bk2.update_NO_OTHR_CVG_RT_a
      (
       p_no_othr_cvg_rt_id       =>  p_no_othr_cvg_rt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_coord_ben_no_cvg_flag          =>  p_coord_ben_no_cvg_flag
      ,p_vrbl_rt_prfl_id                  =>  p_vrbl_rt_prfl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_noc_attribute_category         =>  p_noc_attribute_category
      ,p_noc_attribute1                 =>  p_noc_attribute1
      ,p_noc_attribute2                 =>  p_noc_attribute2
      ,p_noc_attribute3                 =>  p_noc_attribute3
      ,p_noc_attribute4                 =>  p_noc_attribute4
      ,p_noc_attribute5                 =>  p_noc_attribute5
      ,p_noc_attribute6                 =>  p_noc_attribute6
      ,p_noc_attribute7                 =>  p_noc_attribute7
      ,p_noc_attribute8                 =>  p_noc_attribute8
      ,p_noc_attribute9                 =>  p_noc_attribute9
      ,p_noc_attribute10                =>  p_noc_attribute10
      ,p_noc_attribute11                =>  p_noc_attribute11
      ,p_noc_attribute12                =>  p_noc_attribute12
      ,p_noc_attribute13                =>  p_noc_attribute13
      ,p_noc_attribute14                =>  p_noc_attribute14
      ,p_noc_attribute15                =>  p_noc_attribute15
      ,p_noc_attribute16                =>  p_noc_attribute16
      ,p_noc_attribute17                =>  p_noc_attribute17
      ,p_noc_attribute18                =>  p_noc_attribute18
      ,p_noc_attribute19                =>  p_noc_attribute19
      ,p_noc_attribute20                =>  p_noc_attribute20
      ,p_noc_attribute21                =>  p_noc_attribute21
      ,p_noc_attribute22                =>  p_noc_attribute22
      ,p_noc_attribute23                =>  p_noc_attribute23
      ,p_noc_attribute24                =>  p_noc_attribute24
      ,p_noc_attribute25                =>  p_noc_attribute25
      ,p_noc_attribute26                =>  p_noc_attribute26
      ,p_noc_attribute27                =>  p_noc_attribute27
      ,p_noc_attribute28                =>  p_noc_attribute28
      ,p_noc_attribute29                =>  p_noc_attribute29
      ,p_noc_attribute30                =>  p_noc_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_NO_OTHR_CVG_RT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_NO_OTHR_CVG_RT
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
    ROLLBACK TO update_NO_OTHR_CVG_RT;
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
    ROLLBACK TO update_NO_OTHR_CVG_RT;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := l_object_version_number;

    raise;
    --
end update_NO_OTHR_CVG_RT;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_NO_OTHR_CVG_RT >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_NO_OTHR_CVG_RT
  (p_validate                       in  boolean  default false
  ,p_no_othr_cvg_rt_id       in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_NO_OTHR_CVG_RT';
  l_object_version_number ben_no_othr_cvg_rt_f.object_version_number%TYPE;
  l_effective_start_date ben_no_othr_cvg_rt_f.effective_start_date%TYPE;
  l_effective_end_date ben_no_othr_cvg_rt_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_NO_OTHR_CVG_RT;
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
    -- Start of API User Hook for the before hook of delete_NO_OTHR_CVG_RT
    --
    ben_NO_OTHR_CVG_RT_bk3.delete_NO_OTHR_CVG_RT_b
      (
       p_no_othr_cvg_rt_id       =>  p_no_othr_cvg_rt_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_NO_OTHR_CVG_RT'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_NO_OTHR_CVG_RT
    --
  end;
  --
  ben_noc_del.del
    (
     p_no_othr_cvg_rt_id      => p_no_othr_cvg_rt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_NO_OTHR_CVG_RT
    --
    ben_NO_OTHR_CVG_RT_bk3.delete_NO_OTHR_CVG_RT_a
      (
       p_no_othr_cvg_rt_id       =>  p_no_othr_cvg_rt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_NO_OTHR_CVG_RT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_NO_OTHR_CVG_RT
    --
  end;
  --
  ben_profile_handler.event_handler
    (p_event                       => 'DELETE',
     p_base_table                  => 'BEN_VRBL_RT_PRFL_F',
     p_base_table_column           => 'VRBL_RT_PRFL_ID',
     p_base_table_column_value     => ben_noc_shd.g_old_rec.vrbl_rt_prfl_id,
     p_base_table_reference_column => 'RT_NO_OTHR_CVG_FLAG',
     p_reference_table             => 'BEN_NO_OTHR_CVG_RT_F',
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
    ROLLBACK TO delete_NO_OTHR_CVG_RT;
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
    ROLLBACK TO delete_NO_OTHR_CVG_RT;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := l_object_version_number;

    raise;
    --
end delete_NO_OTHR_CVG_RT;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_no_othr_cvg_rt_id                   in     number
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
  ben_noc_shd.lck
    (
      p_no_othr_cvg_rt_id                 => p_no_othr_cvg_rt_id
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
end ben_NO_OTHR_CVG_RT_api;

/
