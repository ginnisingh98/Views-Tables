--------------------------------------------------------
--  DDL for Package Body BEN_ACTUAL_PREMIUM_RATE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ACTUAL_PREMIUM_RATE_API" as
/* $Header: beapvapi.pkb 120.0 2005/05/28 00:27:33 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_actual_premium_rate_api.';
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_actual_premium_rate >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_actual_premium_rate
  (p_validate                       in  boolean   default false
  ,p_actl_prem_vrbl_rt_id           out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_actl_prem_id                   in  number    default null
  ,p_vrbl_rt_prfl_id                in  number    default null
  ,p_ordr_num                       in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_apv_attribute_category         in  varchar2  default null
  ,p_apv_attribute1                 in  varchar2  default null
  ,p_apv_attribute2                 in  varchar2  default null
  ,p_apv_attribute3                 in  varchar2  default null
  ,p_apv_attribute4                 in  varchar2  default null
  ,p_apv_attribute5                 in  varchar2  default null
  ,p_apv_attribute6                 in  varchar2  default null
  ,p_apv_attribute7                 in  varchar2  default null
  ,p_apv_attribute8                 in  varchar2  default null
  ,p_apv_attribute9                 in  varchar2  default null
  ,p_apv_attribute10                in  varchar2  default null
  ,p_apv_attribute11                in  varchar2  default null
  ,p_apv_attribute12                in  varchar2  default null
  ,p_apv_attribute13                in  varchar2  default null
  ,p_apv_attribute14                in  varchar2  default null
  ,p_apv_attribute15                in  varchar2  default null
  ,p_apv_attribute16                in  varchar2  default null
  ,p_apv_attribute17                in  varchar2  default null
  ,p_apv_attribute18                in  varchar2  default null
  ,p_apv_attribute19                in  varchar2  default null
  ,p_apv_attribute20                in  varchar2  default null
  ,p_apv_attribute21                in  varchar2  default null
  ,p_apv_attribute22                in  varchar2  default null
  ,p_apv_attribute23                in  varchar2  default null
  ,p_apv_attribute24                in  varchar2  default null
  ,p_apv_attribute25                in  varchar2  default null
  ,p_apv_attribute26                in  varchar2  default null
  ,p_apv_attribute27                in  varchar2  default null
  ,p_apv_attribute28                in  varchar2  default null
  ,p_apv_attribute29                in  varchar2  default null
  ,p_apv_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_actl_prem_vrbl_rt_id ben_actl_prem_vrbl_rt_f.actl_prem_vrbl_rt_id%TYPE;
  l_effective_start_date ben_actl_prem_vrbl_rt_f.effective_start_date%TYPE;
  l_effective_end_date ben_actl_prem_vrbl_rt_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_actual_premium_rate';
  l_object_version_number ben_actl_prem_vrbl_rt_f.object_version_number%TYPE;
  --
  cursor c1 is
    select pl_id,
           oipl_id
    from   ben_actl_prem_f
    where  actl_prem_id = p_actl_prem_id;
  --
  l_c1  c1%rowtype;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_actual_premium_rate;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_actual_premium_rate
    --
    ben_actual_premium_rate_bk1.create_actual_premium_rate_b
      (
       p_actl_prem_id                   =>  p_actl_prem_id
      ,p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_ordr_num                       =>  p_ordr_num
      ,p_business_group_id              =>  p_business_group_id
      ,p_apv_attribute_category         =>  p_apv_attribute_category
      ,p_apv_attribute1                 =>  p_apv_attribute1
      ,p_apv_attribute2                 =>  p_apv_attribute2
      ,p_apv_attribute3                 =>  p_apv_attribute3
      ,p_apv_attribute4                 =>  p_apv_attribute4
      ,p_apv_attribute5                 =>  p_apv_attribute5
      ,p_apv_attribute6                 =>  p_apv_attribute6
      ,p_apv_attribute7                 =>  p_apv_attribute7
      ,p_apv_attribute8                 =>  p_apv_attribute8
      ,p_apv_attribute9                 =>  p_apv_attribute9
      ,p_apv_attribute10                =>  p_apv_attribute10
      ,p_apv_attribute11                =>  p_apv_attribute11
      ,p_apv_attribute12                =>  p_apv_attribute12
      ,p_apv_attribute13                =>  p_apv_attribute13
      ,p_apv_attribute14                =>  p_apv_attribute14
      ,p_apv_attribute15                =>  p_apv_attribute15
      ,p_apv_attribute16                =>  p_apv_attribute16
      ,p_apv_attribute17                =>  p_apv_attribute17
      ,p_apv_attribute18                =>  p_apv_attribute18
      ,p_apv_attribute19                =>  p_apv_attribute19
      ,p_apv_attribute20                =>  p_apv_attribute20
      ,p_apv_attribute21                =>  p_apv_attribute21
      ,p_apv_attribute22                =>  p_apv_attribute22
      ,p_apv_attribute23                =>  p_apv_attribute23
      ,p_apv_attribute24                =>  p_apv_attribute24
      ,p_apv_attribute25                =>  p_apv_attribute25
      ,p_apv_attribute26                =>  p_apv_attribute26
      ,p_apv_attribute27                =>  p_apv_attribute27
      ,p_apv_attribute28                =>  p_apv_attribute28
      ,p_apv_attribute29                =>  p_apv_attribute29
      ,p_apv_attribute30                =>  p_apv_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_actual_premium_rate'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_actual_premium_rate
    --
  end;
  --
  ben_apv_ins.ins
    (
     p_actl_prem_vrbl_rt_id          => l_actl_prem_vrbl_rt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_actl_prem_id                  => p_actl_prem_id
    ,p_vrbl_rt_prfl_id               => p_vrbl_rt_prfl_id
    ,p_ordr_num                      => p_ordr_num
    ,p_business_group_id             => p_business_group_id
    ,p_apv_attribute_category        => p_apv_attribute_category
    ,p_apv_attribute1                => p_apv_attribute1
    ,p_apv_attribute2                => p_apv_attribute2
    ,p_apv_attribute3                => p_apv_attribute3
    ,p_apv_attribute4                => p_apv_attribute4
    ,p_apv_attribute5                => p_apv_attribute5
    ,p_apv_attribute6                => p_apv_attribute6
    ,p_apv_attribute7                => p_apv_attribute7
    ,p_apv_attribute8                => p_apv_attribute8
    ,p_apv_attribute9                => p_apv_attribute9
    ,p_apv_attribute10               => p_apv_attribute10
    ,p_apv_attribute11               => p_apv_attribute11
    ,p_apv_attribute12               => p_apv_attribute12
    ,p_apv_attribute13               => p_apv_attribute13
    ,p_apv_attribute14               => p_apv_attribute14
    ,p_apv_attribute15               => p_apv_attribute15
    ,p_apv_attribute16               => p_apv_attribute16
    ,p_apv_attribute17               => p_apv_attribute17
    ,p_apv_attribute18               => p_apv_attribute18
    ,p_apv_attribute19               => p_apv_attribute19
    ,p_apv_attribute20               => p_apv_attribute20
    ,p_apv_attribute21               => p_apv_attribute21
    ,p_apv_attribute22               => p_apv_attribute22
    ,p_apv_attribute23               => p_apv_attribute23
    ,p_apv_attribute24               => p_apv_attribute24
    ,p_apv_attribute25               => p_apv_attribute25
    ,p_apv_attribute26               => p_apv_attribute26
    ,p_apv_attribute27               => p_apv_attribute27
    ,p_apv_attribute28               => p_apv_attribute28
    ,p_apv_attribute29               => p_apv_attribute29
    ,p_apv_attribute30               => p_apv_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_actual_premium_rate
    --
    ben_actual_premium_rate_bk1.create_actual_premium_rate_a
      (
       p_actl_prem_vrbl_rt_id           =>  l_actl_prem_vrbl_rt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_actl_prem_id                   =>  p_actl_prem_id
      ,p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_ordr_num                       =>  p_ordr_num
      ,p_business_group_id              =>  p_business_group_id
      ,p_apv_attribute_category         =>  p_apv_attribute_category
      ,p_apv_attribute1                 =>  p_apv_attribute1
      ,p_apv_attribute2                 =>  p_apv_attribute2
      ,p_apv_attribute3                 =>  p_apv_attribute3
      ,p_apv_attribute4                 =>  p_apv_attribute4
      ,p_apv_attribute5                 =>  p_apv_attribute5
      ,p_apv_attribute6                 =>  p_apv_attribute6
      ,p_apv_attribute7                 =>  p_apv_attribute7
      ,p_apv_attribute8                 =>  p_apv_attribute8
      ,p_apv_attribute9                 =>  p_apv_attribute9
      ,p_apv_attribute10                =>  p_apv_attribute10
      ,p_apv_attribute11                =>  p_apv_attribute11
      ,p_apv_attribute12                =>  p_apv_attribute12
      ,p_apv_attribute13                =>  p_apv_attribute13
      ,p_apv_attribute14                =>  p_apv_attribute14
      ,p_apv_attribute15                =>  p_apv_attribute15
      ,p_apv_attribute16                =>  p_apv_attribute16
      ,p_apv_attribute17                =>  p_apv_attribute17
      ,p_apv_attribute18                =>  p_apv_attribute18
      ,p_apv_attribute19                =>  p_apv_attribute19
      ,p_apv_attribute20                =>  p_apv_attribute20
      ,p_apv_attribute21                =>  p_apv_attribute21
      ,p_apv_attribute22                =>  p_apv_attribute22
      ,p_apv_attribute23                =>  p_apv_attribute23
      ,p_apv_attribute24                =>  p_apv_attribute24
      ,p_apv_attribute25                =>  p_apv_attribute25
      ,p_apv_attribute26                =>  p_apv_attribute26
      ,p_apv_attribute27                =>  p_apv_attribute27
      ,p_apv_attribute28                =>  p_apv_attribute28
      ,p_apv_attribute29                =>  p_apv_attribute29
      ,p_apv_attribute30                =>  p_apv_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_actual_premium_rate'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_actual_premium_rate
    --
  end;
  --
  open c1;
    --
    fetch c1 into l_c1;
    --
  close c1;
  --
  if l_c1.pl_id is not null then
    --
    ben_derivable_rate.rate_prfl_handler('CREATE','ben_pl_f','pl_id',l_c1.pl_id);
    --
  elsif l_c1.oipl_id is not null then
    --
     ben_derivable_rate.rate_prfl_handler('CREATE','ben_oipl_f','oipl_id',l_c1.oipl_id);
    --
  end if;
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
  p_actl_prem_vrbl_rt_id := l_actl_prem_vrbl_rt_id;
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
    ROLLBACK TO create_actual_premium_rate;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_actl_prem_vrbl_rt_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_actual_premium_rate;
      /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end create_actual_premium_rate;
-- ----------------------------------------------------------------------------
-- |------------------------< update_actual_premium_rate >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_actual_premium_rate
  (p_validate                       in  boolean   default false
  ,p_actl_prem_vrbl_rt_id           in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_actl_prem_id                   in  number    default hr_api.g_number
  ,p_vrbl_rt_prfl_id                in  number    default hr_api.g_number
  ,p_ordr_num                       in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_apv_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_apv_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_apv_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_apv_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_apv_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_apv_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_apv_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_apv_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_apv_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_apv_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_apv_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_apv_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_apv_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_apv_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_apv_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_apv_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_apv_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_apv_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_apv_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_apv_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_apv_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_apv_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_apv_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_apv_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_apv_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_apv_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_apv_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_apv_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_apv_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_apv_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_apv_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_actual_premium_rate';
  l_object_version_number ben_actl_prem_vrbl_rt_f.object_version_number%TYPE;
  l_effective_start_date ben_actl_prem_vrbl_rt_f.effective_start_date%TYPE;
  l_effective_end_date ben_actl_prem_vrbl_rt_f.effective_end_date%TYPE;
  l_in_object_version_number  number  := p_object_version_number ;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_actual_premium_rate;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_actual_premium_rate
    --
    ben_actual_premium_rate_bk2.update_actual_premium_rate_b
      (
       p_actl_prem_vrbl_rt_id           =>  p_actl_prem_vrbl_rt_id
      ,p_actl_prem_id                   =>  p_actl_prem_id
      ,p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_ordr_num                       =>  p_ordr_num
      ,p_business_group_id              =>  p_business_group_id
      ,p_apv_attribute_category         =>  p_apv_attribute_category
      ,p_apv_attribute1                 =>  p_apv_attribute1
      ,p_apv_attribute2                 =>  p_apv_attribute2
      ,p_apv_attribute3                 =>  p_apv_attribute3
      ,p_apv_attribute4                 =>  p_apv_attribute4
      ,p_apv_attribute5                 =>  p_apv_attribute5
      ,p_apv_attribute6                 =>  p_apv_attribute6
      ,p_apv_attribute7                 =>  p_apv_attribute7
      ,p_apv_attribute8                 =>  p_apv_attribute8
      ,p_apv_attribute9                 =>  p_apv_attribute9
      ,p_apv_attribute10                =>  p_apv_attribute10
      ,p_apv_attribute11                =>  p_apv_attribute11
      ,p_apv_attribute12                =>  p_apv_attribute12
      ,p_apv_attribute13                =>  p_apv_attribute13
      ,p_apv_attribute14                =>  p_apv_attribute14
      ,p_apv_attribute15                =>  p_apv_attribute15
      ,p_apv_attribute16                =>  p_apv_attribute16
      ,p_apv_attribute17                =>  p_apv_attribute17
      ,p_apv_attribute18                =>  p_apv_attribute18
      ,p_apv_attribute19                =>  p_apv_attribute19
      ,p_apv_attribute20                =>  p_apv_attribute20
      ,p_apv_attribute21                =>  p_apv_attribute21
      ,p_apv_attribute22                =>  p_apv_attribute22
      ,p_apv_attribute23                =>  p_apv_attribute23
      ,p_apv_attribute24                =>  p_apv_attribute24
      ,p_apv_attribute25                =>  p_apv_attribute25
      ,p_apv_attribute26                =>  p_apv_attribute26
      ,p_apv_attribute27                =>  p_apv_attribute27
      ,p_apv_attribute28                =>  p_apv_attribute28
      ,p_apv_attribute29                =>  p_apv_attribute29
      ,p_apv_attribute30                =>  p_apv_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_actual_premium_rate'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_actual_premium_rate
    --
  end;
  --
  ben_apv_upd.upd
    (
     p_actl_prem_vrbl_rt_id          => p_actl_prem_vrbl_rt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_actl_prem_id                  => p_actl_prem_id
    ,p_vrbl_rt_prfl_id               => p_vrbl_rt_prfl_id
    ,p_ordr_num                      => p_ordr_num
    ,p_business_group_id             => p_business_group_id
    ,p_apv_attribute_category        => p_apv_attribute_category
    ,p_apv_attribute1                => p_apv_attribute1
    ,p_apv_attribute2                => p_apv_attribute2
    ,p_apv_attribute3                => p_apv_attribute3
    ,p_apv_attribute4                => p_apv_attribute4
    ,p_apv_attribute5                => p_apv_attribute5
    ,p_apv_attribute6                => p_apv_attribute6
    ,p_apv_attribute7                => p_apv_attribute7
    ,p_apv_attribute8                => p_apv_attribute8
    ,p_apv_attribute9                => p_apv_attribute9
    ,p_apv_attribute10               => p_apv_attribute10
    ,p_apv_attribute11               => p_apv_attribute11
    ,p_apv_attribute12               => p_apv_attribute12
    ,p_apv_attribute13               => p_apv_attribute13
    ,p_apv_attribute14               => p_apv_attribute14
    ,p_apv_attribute15               => p_apv_attribute15
    ,p_apv_attribute16               => p_apv_attribute16
    ,p_apv_attribute17               => p_apv_attribute17
    ,p_apv_attribute18               => p_apv_attribute18
    ,p_apv_attribute19               => p_apv_attribute19
    ,p_apv_attribute20               => p_apv_attribute20
    ,p_apv_attribute21               => p_apv_attribute21
    ,p_apv_attribute22               => p_apv_attribute22
    ,p_apv_attribute23               => p_apv_attribute23
    ,p_apv_attribute24               => p_apv_attribute24
    ,p_apv_attribute25               => p_apv_attribute25
    ,p_apv_attribute26               => p_apv_attribute26
    ,p_apv_attribute27               => p_apv_attribute27
    ,p_apv_attribute28               => p_apv_attribute28
    ,p_apv_attribute29               => p_apv_attribute29
    ,p_apv_attribute30               => p_apv_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_actual_premium_rate
    --
    ben_actual_premium_rate_bk2.update_actual_premium_rate_a
      (
       p_actl_prem_vrbl_rt_id           =>  p_actl_prem_vrbl_rt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_actl_prem_id                   =>  p_actl_prem_id
      ,p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_ordr_num                       =>  p_ordr_num
      ,p_business_group_id              =>  p_business_group_id
      ,p_apv_attribute_category         =>  p_apv_attribute_category
      ,p_apv_attribute1                 =>  p_apv_attribute1
      ,p_apv_attribute2                 =>  p_apv_attribute2
      ,p_apv_attribute3                 =>  p_apv_attribute3
      ,p_apv_attribute4                 =>  p_apv_attribute4
      ,p_apv_attribute5                 =>  p_apv_attribute5
      ,p_apv_attribute6                 =>  p_apv_attribute6
      ,p_apv_attribute7                 =>  p_apv_attribute7
      ,p_apv_attribute8                 =>  p_apv_attribute8
      ,p_apv_attribute9                 =>  p_apv_attribute9
      ,p_apv_attribute10                =>  p_apv_attribute10
      ,p_apv_attribute11                =>  p_apv_attribute11
      ,p_apv_attribute12                =>  p_apv_attribute12
      ,p_apv_attribute13                =>  p_apv_attribute13
      ,p_apv_attribute14                =>  p_apv_attribute14
      ,p_apv_attribute15                =>  p_apv_attribute15
      ,p_apv_attribute16                =>  p_apv_attribute16
      ,p_apv_attribute17                =>  p_apv_attribute17
      ,p_apv_attribute18                =>  p_apv_attribute18
      ,p_apv_attribute19                =>  p_apv_attribute19
      ,p_apv_attribute20                =>  p_apv_attribute20
      ,p_apv_attribute21                =>  p_apv_attribute21
      ,p_apv_attribute22                =>  p_apv_attribute22
      ,p_apv_attribute23                =>  p_apv_attribute23
      ,p_apv_attribute24                =>  p_apv_attribute24
      ,p_apv_attribute25                =>  p_apv_attribute25
      ,p_apv_attribute26                =>  p_apv_attribute26
      ,p_apv_attribute27                =>  p_apv_attribute27
      ,p_apv_attribute28                =>  p_apv_attribute28
      ,p_apv_attribute29                =>  p_apv_attribute29
      ,p_apv_attribute30                =>  p_apv_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_actual_premium_rate'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_actual_premium_rate
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
    ROLLBACK TO update_actual_premium_rate;
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
    p_object_version_number := l_in_object_version_number ;
    --
    ROLLBACK TO update_actual_premium_rate;
     /* Inserted for nocopy changes */
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end update_actual_premium_rate;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_actual_premium_rate >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_actual_premium_rate
  (p_validate                       in  boolean  default false
  ,p_actl_prem_vrbl_rt_id           in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_actual_premium_rate';
  l_object_version_number ben_actl_prem_vrbl_rt_f.object_version_number%TYPE;
  l_effective_start_date ben_actl_prem_vrbl_rt_f.effective_start_date%TYPE;
  l_effective_end_date ben_actl_prem_vrbl_rt_f.effective_end_date%TYPE;
  l_in_object_version_number  number  := p_object_version_number ;
  --
  cursor c1 is
    select pl_id,
           oipl_id
    from   ben_actl_prem_f apr,
           ben_actl_prem_vrbl_rt_f apv
    where  apr.actl_prem_id = apv.actl_prem_id
    and    apv.actl_prem_vrbl_rt_id = p_actl_prem_vrbl_rt_id;
  --
  l_c1 c1%rowtype;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_actual_premium_rate;
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
    -- Start of API User Hook for the before hook of delete_actual_premium_rate
    --
    ben_actual_premium_rate_bk3.delete_actual_premium_rate_b
      (
       p_actl_prem_vrbl_rt_id           =>  p_actl_prem_vrbl_rt_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_actual_premium_rate'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_actual_premium_rate
    --
  end;
  --
  ben_apv_del.del
    (
     p_actl_prem_vrbl_rt_id          => p_actl_prem_vrbl_rt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_actual_premium_rate
    --
    ben_actual_premium_rate_bk3.delete_actual_premium_rate_a
      (
       p_actl_prem_vrbl_rt_id           =>  p_actl_prem_vrbl_rt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_actual_premium_rate'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_actual_premium_rate
    --
  end;
  --
  open c1;
    --
    fetch c1 into l_c1;
    --
  close c1;
  --
  if l_c1.pl_id is not null then
    --
    ben_derivable_rate.rate_prfl_handler('DELETE','ben_pl_f','pl_id',l_c1.pl_id);
    --
  elsif l_c1.oipl_id is not null then
    --
    ben_derivable_rate.rate_prfl_handler('DELETE','ben_oipl_f','oipl_id',l_c1.oipl_id);
    --
  end if;
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
    ROLLBACK TO delete_actual_premium_rate;
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
    p_object_version_number := l_in_object_version_number ;
    --
    ROLLBACK TO delete_actual_premium_rate;
    /* Inserted for nocopy changes */
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end delete_actual_premium_rate;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_actl_prem_vrbl_rt_id                   in     number
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
  ben_apv_shd.lck
    (
      p_actl_prem_vrbl_rt_id                 => p_actl_prem_vrbl_rt_id
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
end ben_actual_premium_rate_api;

/
