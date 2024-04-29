--------------------------------------------------------
--  DDL for Package Body BEN_BAL_TYPE_FOR_RATE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BAL_TYPE_FOR_RATE_API" as
/* $Header: bebtrapi.pkb 120.0 2005/05/28 00:52:43 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_Bal_Type_For_Rate_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Bal_Type_For_Rate >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_Bal_Type_For_Rate
  (p_validate                       in  boolean   default false
  ,p_comp_lvl_acty_rt_id            out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_dflt_flag                      in  varchar2  default 'N'
  ,p_comp_lvl_fctr_id               in  number    default null
  ,p_acty_base_rt_id                in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_btr_attribute_category         in  varchar2  default null
  ,p_btr_attribute1                 in  varchar2  default null
  ,p_btr_attribute2                 in  varchar2  default null
  ,p_btr_attribute3                 in  varchar2  default null
  ,p_btr_attribute4                 in  varchar2  default null
  ,p_btr_attribute5                 in  varchar2  default null
  ,p_btr_attribute6                 in  varchar2  default null
  ,p_btr_attribute7                 in  varchar2  default null
  ,p_btr_attribute8                 in  varchar2  default null
  ,p_btr_attribute9                 in  varchar2  default null
  ,p_btr_attribute10                in  varchar2  default null
  ,p_btr_attribute11                in  varchar2  default null
  ,p_btr_attribute12                in  varchar2  default null
  ,p_btr_attribute13                in  varchar2  default null
  ,p_btr_attribute14                in  varchar2  default null
  ,p_btr_attribute15                in  varchar2  default null
  ,p_btr_attribute16                in  varchar2  default null
  ,p_btr_attribute17                in  varchar2  default null
  ,p_btr_attribute18                in  varchar2  default null
  ,p_btr_attribute19                in  varchar2  default null
  ,p_btr_attribute20                in  varchar2  default null
  ,p_btr_attribute21                in  varchar2  default null
  ,p_btr_attribute22                in  varchar2  default null
  ,p_btr_attribute23                in  varchar2  default null
  ,p_btr_attribute24                in  varchar2  default null
  ,p_btr_attribute25                in  varchar2  default null
  ,p_btr_attribute26                in  varchar2  default null
  ,p_btr_attribute27                in  varchar2  default null
  ,p_btr_attribute28                in  varchar2  default null
  ,p_btr_attribute29                in  varchar2  default null
  ,p_btr_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_comp_lvl_acty_rt_id ben_comp_lvl_acty_rt_f.comp_lvl_acty_rt_id%TYPE;
  l_effective_start_date ben_comp_lvl_acty_rt_f.effective_start_date%TYPE;
  l_effective_end_date ben_comp_lvl_acty_rt_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_Bal_Type_For_Rate';
  l_object_version_number ben_comp_lvl_acty_rt_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_Bal_Type_For_Rate;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_Bal_Type_For_Rate
    --
    ben_Bal_Type_For_Rate_bk1.create_Bal_Type_For_Rate_b
      (
       p_dflt_flag                      =>  p_dflt_flag
      ,p_comp_lvl_fctr_id               =>  p_comp_lvl_fctr_id
      ,p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_btr_attribute_category         =>  p_btr_attribute_category
      ,p_btr_attribute1                 =>  p_btr_attribute1
      ,p_btr_attribute2                 =>  p_btr_attribute2
      ,p_btr_attribute3                 =>  p_btr_attribute3
      ,p_btr_attribute4                 =>  p_btr_attribute4
      ,p_btr_attribute5                 =>  p_btr_attribute5
      ,p_btr_attribute6                 =>  p_btr_attribute6
      ,p_btr_attribute7                 =>  p_btr_attribute7
      ,p_btr_attribute8                 =>  p_btr_attribute8
      ,p_btr_attribute9                 =>  p_btr_attribute9
      ,p_btr_attribute10                =>  p_btr_attribute10
      ,p_btr_attribute11                =>  p_btr_attribute11
      ,p_btr_attribute12                =>  p_btr_attribute12
      ,p_btr_attribute13                =>  p_btr_attribute13
      ,p_btr_attribute14                =>  p_btr_attribute14
      ,p_btr_attribute15                =>  p_btr_attribute15
      ,p_btr_attribute16                =>  p_btr_attribute16
      ,p_btr_attribute17                =>  p_btr_attribute17
      ,p_btr_attribute18                =>  p_btr_attribute18
      ,p_btr_attribute19                =>  p_btr_attribute19
      ,p_btr_attribute20                =>  p_btr_attribute20
      ,p_btr_attribute21                =>  p_btr_attribute21
      ,p_btr_attribute22                =>  p_btr_attribute22
      ,p_btr_attribute23                =>  p_btr_attribute23
      ,p_btr_attribute24                =>  p_btr_attribute24
      ,p_btr_attribute25                =>  p_btr_attribute25
      ,p_btr_attribute26                =>  p_btr_attribute26
      ,p_btr_attribute27                =>  p_btr_attribute27
      ,p_btr_attribute28                =>  p_btr_attribute28
      ,p_btr_attribute29                =>  p_btr_attribute29
      ,p_btr_attribute30                =>  p_btr_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_Bal_Type_For_Rate'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_Bal_Type_For_Rate
    --
  end;
  --
  ben_btr_ins.ins
    (
     p_comp_lvl_acty_rt_id           => l_comp_lvl_acty_rt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_dflt_flag                     => p_dflt_flag
    ,p_comp_lvl_fctr_id              => p_comp_lvl_fctr_id
    ,p_acty_base_rt_id               => p_acty_base_rt_id
    ,p_business_group_id             => p_business_group_id
    ,p_btr_attribute_category        => p_btr_attribute_category
    ,p_btr_attribute1                => p_btr_attribute1
    ,p_btr_attribute2                => p_btr_attribute2
    ,p_btr_attribute3                => p_btr_attribute3
    ,p_btr_attribute4                => p_btr_attribute4
    ,p_btr_attribute5                => p_btr_attribute5
    ,p_btr_attribute6                => p_btr_attribute6
    ,p_btr_attribute7                => p_btr_attribute7
    ,p_btr_attribute8                => p_btr_attribute8
    ,p_btr_attribute9                => p_btr_attribute9
    ,p_btr_attribute10               => p_btr_attribute10
    ,p_btr_attribute11               => p_btr_attribute11
    ,p_btr_attribute12               => p_btr_attribute12
    ,p_btr_attribute13               => p_btr_attribute13
    ,p_btr_attribute14               => p_btr_attribute14
    ,p_btr_attribute15               => p_btr_attribute15
    ,p_btr_attribute16               => p_btr_attribute16
    ,p_btr_attribute17               => p_btr_attribute17
    ,p_btr_attribute18               => p_btr_attribute18
    ,p_btr_attribute19               => p_btr_attribute19
    ,p_btr_attribute20               => p_btr_attribute20
    ,p_btr_attribute21               => p_btr_attribute21
    ,p_btr_attribute22               => p_btr_attribute22
    ,p_btr_attribute23               => p_btr_attribute23
    ,p_btr_attribute24               => p_btr_attribute24
    ,p_btr_attribute25               => p_btr_attribute25
    ,p_btr_attribute26               => p_btr_attribute26
    ,p_btr_attribute27               => p_btr_attribute27
    ,p_btr_attribute28               => p_btr_attribute28
    ,p_btr_attribute29               => p_btr_attribute29
    ,p_btr_attribute30               => p_btr_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_Bal_Type_For_Rate
    --
    ben_Bal_Type_For_Rate_bk1.create_Bal_Type_For_Rate_a
      (
       p_comp_lvl_acty_rt_id            =>  l_comp_lvl_acty_rt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_comp_lvl_fctr_id               =>  p_comp_lvl_fctr_id
      ,p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_btr_attribute_category         =>  p_btr_attribute_category
      ,p_btr_attribute1                 =>  p_btr_attribute1
      ,p_btr_attribute2                 =>  p_btr_attribute2
      ,p_btr_attribute3                 =>  p_btr_attribute3
      ,p_btr_attribute4                 =>  p_btr_attribute4
      ,p_btr_attribute5                 =>  p_btr_attribute5
      ,p_btr_attribute6                 =>  p_btr_attribute6
      ,p_btr_attribute7                 =>  p_btr_attribute7
      ,p_btr_attribute8                 =>  p_btr_attribute8
      ,p_btr_attribute9                 =>  p_btr_attribute9
      ,p_btr_attribute10                =>  p_btr_attribute10
      ,p_btr_attribute11                =>  p_btr_attribute11
      ,p_btr_attribute12                =>  p_btr_attribute12
      ,p_btr_attribute13                =>  p_btr_attribute13
      ,p_btr_attribute14                =>  p_btr_attribute14
      ,p_btr_attribute15                =>  p_btr_attribute15
      ,p_btr_attribute16                =>  p_btr_attribute16
      ,p_btr_attribute17                =>  p_btr_attribute17
      ,p_btr_attribute18                =>  p_btr_attribute18
      ,p_btr_attribute19                =>  p_btr_attribute19
      ,p_btr_attribute20                =>  p_btr_attribute20
      ,p_btr_attribute21                =>  p_btr_attribute21
      ,p_btr_attribute22                =>  p_btr_attribute22
      ,p_btr_attribute23                =>  p_btr_attribute23
      ,p_btr_attribute24                =>  p_btr_attribute24
      ,p_btr_attribute25                =>  p_btr_attribute25
      ,p_btr_attribute26                =>  p_btr_attribute26
      ,p_btr_attribute27                =>  p_btr_attribute27
      ,p_btr_attribute28                =>  p_btr_attribute28
      ,p_btr_attribute29                =>  p_btr_attribute29
      ,p_btr_attribute30                =>  p_btr_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_Bal_Type_For_Rate'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_Bal_Type_For_Rate
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
  p_comp_lvl_acty_rt_id := l_comp_lvl_acty_rt_id;
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
    ROLLBACK TO create_Bal_Type_For_Rate;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_comp_lvl_acty_rt_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_comp_lvl_acty_rt_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
    ROLLBACK TO create_Bal_Type_For_Rate;
    raise;
    --
end create_Bal_Type_For_Rate;
-- ----------------------------------------------------------------------------
-- |------------------------< update_Bal_Type_For_Rate >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_Bal_Type_For_Rate
  (p_validate                       in  boolean   default false
  ,p_comp_lvl_acty_rt_id            in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_dflt_flag                      in  varchar2  default hr_api.g_varchar2
  ,p_comp_lvl_fctr_id               in  number    default hr_api.g_number
  ,p_acty_base_rt_id                in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_btr_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_btr_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_btr_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_btr_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_btr_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_btr_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_btr_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_btr_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_btr_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_btr_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_btr_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_btr_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_btr_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_btr_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_btr_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_btr_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_btr_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_btr_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_btr_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_btr_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_btr_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_btr_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_btr_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_btr_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_btr_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_btr_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_btr_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_btr_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_btr_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_btr_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_btr_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Bal_Type_For_Rate';
  l_object_version_number ben_comp_lvl_acty_rt_f.object_version_number%TYPE;
  l_effective_start_date ben_comp_lvl_acty_rt_f.effective_start_date%TYPE;
  l_effective_end_date ben_comp_lvl_acty_rt_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_Bal_Type_For_Rate;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_Bal_Type_For_Rate
    --
    ben_Bal_Type_For_Rate_bk2.update_Bal_Type_For_Rate_b
      (
       p_comp_lvl_acty_rt_id            =>  p_comp_lvl_acty_rt_id
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_comp_lvl_fctr_id               =>  p_comp_lvl_fctr_id
      ,p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_btr_attribute_category         =>  p_btr_attribute_category
      ,p_btr_attribute1                 =>  p_btr_attribute1
      ,p_btr_attribute2                 =>  p_btr_attribute2
      ,p_btr_attribute3                 =>  p_btr_attribute3
      ,p_btr_attribute4                 =>  p_btr_attribute4
      ,p_btr_attribute5                 =>  p_btr_attribute5
      ,p_btr_attribute6                 =>  p_btr_attribute6
      ,p_btr_attribute7                 =>  p_btr_attribute7
      ,p_btr_attribute8                 =>  p_btr_attribute8
      ,p_btr_attribute9                 =>  p_btr_attribute9
      ,p_btr_attribute10                =>  p_btr_attribute10
      ,p_btr_attribute11                =>  p_btr_attribute11
      ,p_btr_attribute12                =>  p_btr_attribute12
      ,p_btr_attribute13                =>  p_btr_attribute13
      ,p_btr_attribute14                =>  p_btr_attribute14
      ,p_btr_attribute15                =>  p_btr_attribute15
      ,p_btr_attribute16                =>  p_btr_attribute16
      ,p_btr_attribute17                =>  p_btr_attribute17
      ,p_btr_attribute18                =>  p_btr_attribute18
      ,p_btr_attribute19                =>  p_btr_attribute19
      ,p_btr_attribute20                =>  p_btr_attribute20
      ,p_btr_attribute21                =>  p_btr_attribute21
      ,p_btr_attribute22                =>  p_btr_attribute22
      ,p_btr_attribute23                =>  p_btr_attribute23
      ,p_btr_attribute24                =>  p_btr_attribute24
      ,p_btr_attribute25                =>  p_btr_attribute25
      ,p_btr_attribute26                =>  p_btr_attribute26
      ,p_btr_attribute27                =>  p_btr_attribute27
      ,p_btr_attribute28                =>  p_btr_attribute28
      ,p_btr_attribute29                =>  p_btr_attribute29
      ,p_btr_attribute30                =>  p_btr_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Bal_Type_For_Rate'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_Bal_Type_For_Rate
    --
  end;
  --
  ben_btr_upd.upd
    (
     p_comp_lvl_acty_rt_id           => p_comp_lvl_acty_rt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_dflt_flag                     => p_dflt_flag
    ,p_comp_lvl_fctr_id              => p_comp_lvl_fctr_id
    ,p_acty_base_rt_id               => p_acty_base_rt_id
    ,p_business_group_id             => p_business_group_id
    ,p_btr_attribute_category        => p_btr_attribute_category
    ,p_btr_attribute1                => p_btr_attribute1
    ,p_btr_attribute2                => p_btr_attribute2
    ,p_btr_attribute3                => p_btr_attribute3
    ,p_btr_attribute4                => p_btr_attribute4
    ,p_btr_attribute5                => p_btr_attribute5
    ,p_btr_attribute6                => p_btr_attribute6
    ,p_btr_attribute7                => p_btr_attribute7
    ,p_btr_attribute8                => p_btr_attribute8
    ,p_btr_attribute9                => p_btr_attribute9
    ,p_btr_attribute10               => p_btr_attribute10
    ,p_btr_attribute11               => p_btr_attribute11
    ,p_btr_attribute12               => p_btr_attribute12
    ,p_btr_attribute13               => p_btr_attribute13
    ,p_btr_attribute14               => p_btr_attribute14
    ,p_btr_attribute15               => p_btr_attribute15
    ,p_btr_attribute16               => p_btr_attribute16
    ,p_btr_attribute17               => p_btr_attribute17
    ,p_btr_attribute18               => p_btr_attribute18
    ,p_btr_attribute19               => p_btr_attribute19
    ,p_btr_attribute20               => p_btr_attribute20
    ,p_btr_attribute21               => p_btr_attribute21
    ,p_btr_attribute22               => p_btr_attribute22
    ,p_btr_attribute23               => p_btr_attribute23
    ,p_btr_attribute24               => p_btr_attribute24
    ,p_btr_attribute25               => p_btr_attribute25
    ,p_btr_attribute26               => p_btr_attribute26
    ,p_btr_attribute27               => p_btr_attribute27
    ,p_btr_attribute28               => p_btr_attribute28
    ,p_btr_attribute29               => p_btr_attribute29
    ,p_btr_attribute30               => p_btr_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_Bal_Type_For_Rate
    --
    ben_Bal_Type_For_Rate_bk2.update_Bal_Type_For_Rate_a
      (
       p_comp_lvl_acty_rt_id            =>  p_comp_lvl_acty_rt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_comp_lvl_fctr_id               =>  p_comp_lvl_fctr_id
      ,p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_btr_attribute_category         =>  p_btr_attribute_category
      ,p_btr_attribute1                 =>  p_btr_attribute1
      ,p_btr_attribute2                 =>  p_btr_attribute2
      ,p_btr_attribute3                 =>  p_btr_attribute3
      ,p_btr_attribute4                 =>  p_btr_attribute4
      ,p_btr_attribute5                 =>  p_btr_attribute5
      ,p_btr_attribute6                 =>  p_btr_attribute6
      ,p_btr_attribute7                 =>  p_btr_attribute7
      ,p_btr_attribute8                 =>  p_btr_attribute8
      ,p_btr_attribute9                 =>  p_btr_attribute9
      ,p_btr_attribute10                =>  p_btr_attribute10
      ,p_btr_attribute11                =>  p_btr_attribute11
      ,p_btr_attribute12                =>  p_btr_attribute12
      ,p_btr_attribute13                =>  p_btr_attribute13
      ,p_btr_attribute14                =>  p_btr_attribute14
      ,p_btr_attribute15                =>  p_btr_attribute15
      ,p_btr_attribute16                =>  p_btr_attribute16
      ,p_btr_attribute17                =>  p_btr_attribute17
      ,p_btr_attribute18                =>  p_btr_attribute18
      ,p_btr_attribute19                =>  p_btr_attribute19
      ,p_btr_attribute20                =>  p_btr_attribute20
      ,p_btr_attribute21                =>  p_btr_attribute21
      ,p_btr_attribute22                =>  p_btr_attribute22
      ,p_btr_attribute23                =>  p_btr_attribute23
      ,p_btr_attribute24                =>  p_btr_attribute24
      ,p_btr_attribute25                =>  p_btr_attribute25
      ,p_btr_attribute26                =>  p_btr_attribute26
      ,p_btr_attribute27                =>  p_btr_attribute27
      ,p_btr_attribute28                =>  p_btr_attribute28
      ,p_btr_attribute29                =>  p_btr_attribute29
      ,p_btr_attribute30                =>  p_btr_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Bal_Type_For_Rate'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_Bal_Type_For_Rate
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
    ROLLBACK TO update_Bal_Type_For_Rate;
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
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
    ROLLBACK TO update_Bal_Type_For_Rate;
    raise;
    --
end update_Bal_Type_For_Rate;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Bal_Type_For_Rate >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Bal_Type_For_Rate
  (p_validate                       in  boolean  default false
  ,p_comp_lvl_acty_rt_id            in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Bal_Type_For_Rate';
  l_object_version_number ben_comp_lvl_acty_rt_f.object_version_number%TYPE;
  l_effective_start_date ben_comp_lvl_acty_rt_f.effective_start_date%TYPE;
  l_effective_end_date ben_comp_lvl_acty_rt_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_Bal_Type_For_Rate;
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
    -- Start of API User Hook for the before hook of delete_Bal_Type_For_Rate
    --
    ben_Bal_Type_For_Rate_bk3.delete_Bal_Type_For_Rate_b
      (
       p_comp_lvl_acty_rt_id            =>  p_comp_lvl_acty_rt_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Bal_Type_For_Rate'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_Bal_Type_For_Rate
    --
  end;
  --
  ben_btr_del.del
    (
     p_comp_lvl_acty_rt_id           => p_comp_lvl_acty_rt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_Bal_Type_For_Rate
    --
    ben_Bal_Type_For_Rate_bk3.delete_Bal_Type_For_Rate_a
      (
       p_comp_lvl_acty_rt_id            =>  p_comp_lvl_acty_rt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Bal_Type_For_Rate'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_Bal_Type_For_Rate
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
    ROLLBACK TO delete_Bal_Type_For_Rate;
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
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
    ROLLBACK TO delete_Bal_Type_For_Rate;
    raise;
    --
end delete_Bal_Type_For_Rate;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_comp_lvl_acty_rt_id                   in     number
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
  ben_btr_shd.lck
    (
      p_comp_lvl_acty_rt_id                 => p_comp_lvl_acty_rt_id
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
end ben_Bal_Type_For_Rate_api;

/
