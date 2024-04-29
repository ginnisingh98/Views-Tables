--------------------------------------------------------
--  DDL for Package Body BEN_BNFT_VRBL_RT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BNFT_VRBL_RT_API" as
/* $Header: bebvrapi.pkb 120.0 2005/05/28 00:54:24 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_bnft_vrbl_rt_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_bnft_vrbl_rt >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_bnft_vrbl_rt
  (p_validate                       in  boolean   default false
  ,p_bnft_vrbl_rt_id                out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_cvg_amt_calc_mthd_id           in  number    default null
  ,p_vrbl_rt_prfl_id                in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_bvr_attribute_category         in  varchar2  default null
  ,p_bvr_attribute1                 in  varchar2  default null
  ,p_bvr_attribute2                 in  varchar2  default null
  ,p_bvr_attribute3                 in  varchar2  default null
  ,p_bvr_attribute4                 in  varchar2  default null
  ,p_bvr_attribute5                 in  varchar2  default null
  ,p_bvr_attribute6                 in  varchar2  default null
  ,p_bvr_attribute7                 in  varchar2  default null
  ,p_bvr_attribute8                 in  varchar2  default null
  ,p_bvr_attribute9                 in  varchar2  default null
  ,p_bvr_attribute10                in  varchar2  default null
  ,p_bvr_attribute11                in  varchar2  default null
  ,p_bvr_attribute12                in  varchar2  default null
  ,p_bvr_attribute13                in  varchar2  default null
  ,p_bvr_attribute14                in  varchar2  default null
  ,p_bvr_attribute15                in  varchar2  default null
  ,p_bvr_attribute16                in  varchar2  default null
  ,p_bvr_attribute17                in  varchar2  default null
  ,p_bvr_attribute18                in  varchar2  default null
  ,p_bvr_attribute19                in  varchar2  default null
  ,p_bvr_attribute20                in  varchar2  default null
  ,p_bvr_attribute21                in  varchar2  default null
  ,p_bvr_attribute22                in  varchar2  default null
  ,p_bvr_attribute23                in  varchar2  default null
  ,p_bvr_attribute24                in  varchar2  default null
  ,p_bvr_attribute25                in  varchar2  default null
  ,p_bvr_attribute26                in  varchar2  default null
  ,p_bvr_attribute27                in  varchar2  default null
  ,p_bvr_attribute28                in  varchar2  default null
  ,p_bvr_attribute29                in  varchar2  default null
  ,p_bvr_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_ordr_num                       in  number    default null
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_bnft_vrbl_rt_id ben_bnft_vrbl_rt_f.bnft_vrbl_rt_id%TYPE;
  l_effective_start_date ben_bnft_vrbl_rt_f.effective_start_date%TYPE;
  l_effective_end_date ben_bnft_vrbl_rt_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_bnft_vrbl_rt';
  l_object_version_number ben_bnft_vrbl_rt_f.object_version_number%TYPE;
  --
  cursor c1 is
    select pl_id,
           oipl_id,
           plip_id
    from   ben_cvg_amt_calc_mthd_f
    where  cvg_amt_calc_mthd_id = p_cvg_amt_calc_mthd_id;
  --
  l_c1  c1%rowtype;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_bnft_vrbl_rt;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_bnft_vrbl_rt
    --
    ben_bnft_vrbl_rt_bk1.create_bnft_vrbl_rt_b
      (
       p_cvg_amt_calc_mthd_id           =>  p_cvg_amt_calc_mthd_id
      ,p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_bvr_attribute_category         =>  p_bvr_attribute_category
      ,p_bvr_attribute1                 =>  p_bvr_attribute1
      ,p_bvr_attribute2                 =>  p_bvr_attribute2
      ,p_bvr_attribute3                 =>  p_bvr_attribute3
      ,p_bvr_attribute4                 =>  p_bvr_attribute4
      ,p_bvr_attribute5                 =>  p_bvr_attribute5
      ,p_bvr_attribute6                 =>  p_bvr_attribute6
      ,p_bvr_attribute7                 =>  p_bvr_attribute7
      ,p_bvr_attribute8                 =>  p_bvr_attribute8
      ,p_bvr_attribute9                 =>  p_bvr_attribute9
      ,p_bvr_attribute10                =>  p_bvr_attribute10
      ,p_bvr_attribute11                =>  p_bvr_attribute11
      ,p_bvr_attribute12                =>  p_bvr_attribute12
      ,p_bvr_attribute13                =>  p_bvr_attribute13
      ,p_bvr_attribute14                =>  p_bvr_attribute14
      ,p_bvr_attribute15                =>  p_bvr_attribute15
      ,p_bvr_attribute16                =>  p_bvr_attribute16
      ,p_bvr_attribute17                =>  p_bvr_attribute17
      ,p_bvr_attribute18                =>  p_bvr_attribute18
      ,p_bvr_attribute19                =>  p_bvr_attribute19
      ,p_bvr_attribute20                =>  p_bvr_attribute20
      ,p_bvr_attribute21                =>  p_bvr_attribute21
      ,p_bvr_attribute22                =>  p_bvr_attribute22
      ,p_bvr_attribute23                =>  p_bvr_attribute23
      ,p_bvr_attribute24                =>  p_bvr_attribute24
      ,p_bvr_attribute25                =>  p_bvr_attribute25
      ,p_bvr_attribute26                =>  p_bvr_attribute26
      ,p_bvr_attribute27                =>  p_bvr_attribute27
      ,p_bvr_attribute28                =>  p_bvr_attribute28
      ,p_bvr_attribute29                =>  p_bvr_attribute29
      ,p_bvr_attribute30                =>  p_bvr_attribute30
      ,p_ordr_num                       =>  p_ordr_num
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_bnft_vrbl_rt'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_bnft_vrbl_rt
    --
  end;
  --
  ben_bvr_ins.ins
    (
     p_bnft_vrbl_rt_id               => l_bnft_vrbl_rt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_cvg_amt_calc_mthd_id          => p_cvg_amt_calc_mthd_id
    ,p_vrbl_rt_prfl_id               => p_vrbl_rt_prfl_id
    ,p_business_group_id             => p_business_group_id
    ,p_bvr_attribute_category        => p_bvr_attribute_category
    ,p_bvr_attribute1                => p_bvr_attribute1
    ,p_bvr_attribute2                => p_bvr_attribute2
    ,p_bvr_attribute3                => p_bvr_attribute3
    ,p_bvr_attribute4                => p_bvr_attribute4
    ,p_bvr_attribute5                => p_bvr_attribute5
    ,p_bvr_attribute6                => p_bvr_attribute6
    ,p_bvr_attribute7                => p_bvr_attribute7
    ,p_bvr_attribute8                => p_bvr_attribute8
    ,p_bvr_attribute9                => p_bvr_attribute9
    ,p_bvr_attribute10               => p_bvr_attribute10
    ,p_bvr_attribute11               => p_bvr_attribute11
    ,p_bvr_attribute12               => p_bvr_attribute12
    ,p_bvr_attribute13               => p_bvr_attribute13
    ,p_bvr_attribute14               => p_bvr_attribute14
    ,p_bvr_attribute15               => p_bvr_attribute15
    ,p_bvr_attribute16               => p_bvr_attribute16
    ,p_bvr_attribute17               => p_bvr_attribute17
    ,p_bvr_attribute18               => p_bvr_attribute18
    ,p_bvr_attribute19               => p_bvr_attribute19
    ,p_bvr_attribute20               => p_bvr_attribute20
    ,p_bvr_attribute21               => p_bvr_attribute21
    ,p_bvr_attribute22               => p_bvr_attribute22
    ,p_bvr_attribute23               => p_bvr_attribute23
    ,p_bvr_attribute24               => p_bvr_attribute24
    ,p_bvr_attribute25               => p_bvr_attribute25
    ,p_bvr_attribute26               => p_bvr_attribute26
    ,p_bvr_attribute27               => p_bvr_attribute27
    ,p_bvr_attribute28               => p_bvr_attribute28
    ,p_bvr_attribute29               => p_bvr_attribute29
    ,p_bvr_attribute30               => p_bvr_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_ordr_num                      => p_ordr_num
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_bnft_vrbl_rt
    --
    ben_bnft_vrbl_rt_bk1.create_bnft_vrbl_rt_a
      (
       p_bnft_vrbl_rt_id                =>  l_bnft_vrbl_rt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_cvg_amt_calc_mthd_id           =>  p_cvg_amt_calc_mthd_id
      ,p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_bvr_attribute_category         =>  p_bvr_attribute_category
      ,p_bvr_attribute1                 =>  p_bvr_attribute1
      ,p_bvr_attribute2                 =>  p_bvr_attribute2
      ,p_bvr_attribute3                 =>  p_bvr_attribute3
      ,p_bvr_attribute4                 =>  p_bvr_attribute4
      ,p_bvr_attribute5                 =>  p_bvr_attribute5
      ,p_bvr_attribute6                 =>  p_bvr_attribute6
      ,p_bvr_attribute7                 =>  p_bvr_attribute7
      ,p_bvr_attribute8                 =>  p_bvr_attribute8
      ,p_bvr_attribute9                 =>  p_bvr_attribute9
      ,p_bvr_attribute10                =>  p_bvr_attribute10
      ,p_bvr_attribute11                =>  p_bvr_attribute11
      ,p_bvr_attribute12                =>  p_bvr_attribute12
      ,p_bvr_attribute13                =>  p_bvr_attribute13
      ,p_bvr_attribute14                =>  p_bvr_attribute14
      ,p_bvr_attribute15                =>  p_bvr_attribute15
      ,p_bvr_attribute16                =>  p_bvr_attribute16
      ,p_bvr_attribute17                =>  p_bvr_attribute17
      ,p_bvr_attribute18                =>  p_bvr_attribute18
      ,p_bvr_attribute19                =>  p_bvr_attribute19
      ,p_bvr_attribute20                =>  p_bvr_attribute20
      ,p_bvr_attribute21                =>  p_bvr_attribute21
      ,p_bvr_attribute22                =>  p_bvr_attribute22
      ,p_bvr_attribute23                =>  p_bvr_attribute23
      ,p_bvr_attribute24                =>  p_bvr_attribute24
      ,p_bvr_attribute25                =>  p_bvr_attribute25
      ,p_bvr_attribute26                =>  p_bvr_attribute26
      ,p_bvr_attribute27                =>  p_bvr_attribute27
      ,p_bvr_attribute28                =>  p_bvr_attribute28
      ,p_bvr_attribute29                =>  p_bvr_attribute29
      ,p_bvr_attribute30                =>  p_bvr_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_ordr_num                       =>  p_ordr_num
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_bnft_vrbl_rt'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_bnft_vrbl_rt
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
  elsif l_c1.plip_id is not null then
    --
    ben_derivable_rate.rate_prfl_handler('CREATE','ben_plip_f','plip_id',l_c1.plip_id);
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
  p_bnft_vrbl_rt_id := l_bnft_vrbl_rt_id;
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
    ROLLBACK TO create_bnft_vrbl_rt;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_bnft_vrbl_rt_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_bnft_vrbl_rt;
    -- NOCOPY Changes
    p_bnft_vrbl_rt_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number := null ;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end create_bnft_vrbl_rt;
-- ----------------------------------------------------------------------------
-- |------------------------< update_bnft_vrbl_rt >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_bnft_vrbl_rt
  (p_validate                       in  boolean   default false
  ,p_bnft_vrbl_rt_id                in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_cvg_amt_calc_mthd_id           in  number    default hr_api.g_number
  ,p_vrbl_rt_prfl_id                in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_bvr_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_bvr_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_bvr_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_bvr_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_bvr_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_bvr_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_bvr_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_bvr_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_bvr_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_bvr_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_bvr_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_bvr_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_bvr_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_bvr_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_bvr_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_bvr_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_bvr_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_bvr_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_bvr_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_bvr_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_bvr_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_bvr_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_bvr_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_bvr_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_bvr_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_bvr_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_bvr_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_bvr_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_bvr_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_bvr_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_bvr_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_ordr_num                       in  number    default hr_api.g_number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_bnft_vrbl_rt';
  l_object_version_number ben_bnft_vrbl_rt_f.object_version_number%TYPE;
  l_effective_start_date ben_bnft_vrbl_rt_f.effective_start_date%TYPE;
  l_effective_end_date ben_bnft_vrbl_rt_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_bnft_vrbl_rt;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_bnft_vrbl_rt
    --
    ben_bnft_vrbl_rt_bk2.update_bnft_vrbl_rt_b
      (
       p_bnft_vrbl_rt_id                =>  p_bnft_vrbl_rt_id
      ,p_cvg_amt_calc_mthd_id           =>  p_cvg_amt_calc_mthd_id
      ,p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_bvr_attribute_category         =>  p_bvr_attribute_category
      ,p_bvr_attribute1                 =>  p_bvr_attribute1
      ,p_bvr_attribute2                 =>  p_bvr_attribute2
      ,p_bvr_attribute3                 =>  p_bvr_attribute3
      ,p_bvr_attribute4                 =>  p_bvr_attribute4
      ,p_bvr_attribute5                 =>  p_bvr_attribute5
      ,p_bvr_attribute6                 =>  p_bvr_attribute6
      ,p_bvr_attribute7                 =>  p_bvr_attribute7
      ,p_bvr_attribute8                 =>  p_bvr_attribute8
      ,p_bvr_attribute9                 =>  p_bvr_attribute9
      ,p_bvr_attribute10                =>  p_bvr_attribute10
      ,p_bvr_attribute11                =>  p_bvr_attribute11
      ,p_bvr_attribute12                =>  p_bvr_attribute12
      ,p_bvr_attribute13                =>  p_bvr_attribute13
      ,p_bvr_attribute14                =>  p_bvr_attribute14
      ,p_bvr_attribute15                =>  p_bvr_attribute15
      ,p_bvr_attribute16                =>  p_bvr_attribute16
      ,p_bvr_attribute17                =>  p_bvr_attribute17
      ,p_bvr_attribute18                =>  p_bvr_attribute18
      ,p_bvr_attribute19                =>  p_bvr_attribute19
      ,p_bvr_attribute20                =>  p_bvr_attribute20
      ,p_bvr_attribute21                =>  p_bvr_attribute21
      ,p_bvr_attribute22                =>  p_bvr_attribute22
      ,p_bvr_attribute23                =>  p_bvr_attribute23
      ,p_bvr_attribute24                =>  p_bvr_attribute24
      ,p_bvr_attribute25                =>  p_bvr_attribute25
      ,p_bvr_attribute26                =>  p_bvr_attribute26
      ,p_bvr_attribute27                =>  p_bvr_attribute27
      ,p_bvr_attribute28                =>  p_bvr_attribute28
      ,p_bvr_attribute29                =>  p_bvr_attribute29
      ,p_bvr_attribute30                =>  p_bvr_attribute30
      ,p_object_version_number          =>  p_object_version_number
      ,p_ordr_num                       =>  p_ordr_num
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_bnft_vrbl_rt'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_bnft_vrbl_rt
    --
  end;
  --
  ben_bvr_upd.upd
    (
     p_bnft_vrbl_rt_id               => p_bnft_vrbl_rt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_cvg_amt_calc_mthd_id          => p_cvg_amt_calc_mthd_id
    ,p_vrbl_rt_prfl_id               => p_vrbl_rt_prfl_id
    ,p_business_group_id             => p_business_group_id
    ,p_bvr_attribute_category        => p_bvr_attribute_category
    ,p_bvr_attribute1                => p_bvr_attribute1
    ,p_bvr_attribute2                => p_bvr_attribute2
    ,p_bvr_attribute3                => p_bvr_attribute3
    ,p_bvr_attribute4                => p_bvr_attribute4
    ,p_bvr_attribute5                => p_bvr_attribute5
    ,p_bvr_attribute6                => p_bvr_attribute6
    ,p_bvr_attribute7                => p_bvr_attribute7
    ,p_bvr_attribute8                => p_bvr_attribute8
    ,p_bvr_attribute9                => p_bvr_attribute9
    ,p_bvr_attribute10               => p_bvr_attribute10
    ,p_bvr_attribute11               => p_bvr_attribute11
    ,p_bvr_attribute12               => p_bvr_attribute12
    ,p_bvr_attribute13               => p_bvr_attribute13
    ,p_bvr_attribute14               => p_bvr_attribute14
    ,p_bvr_attribute15               => p_bvr_attribute15
    ,p_bvr_attribute16               => p_bvr_attribute16
    ,p_bvr_attribute17               => p_bvr_attribute17
    ,p_bvr_attribute18               => p_bvr_attribute18
    ,p_bvr_attribute19               => p_bvr_attribute19
    ,p_bvr_attribute20               => p_bvr_attribute20
    ,p_bvr_attribute21               => p_bvr_attribute21
    ,p_bvr_attribute22               => p_bvr_attribute22
    ,p_bvr_attribute23               => p_bvr_attribute23
    ,p_bvr_attribute24               => p_bvr_attribute24
    ,p_bvr_attribute25               => p_bvr_attribute25
    ,p_bvr_attribute26               => p_bvr_attribute26
    ,p_bvr_attribute27               => p_bvr_attribute27
    ,p_bvr_attribute28               => p_bvr_attribute28
    ,p_bvr_attribute29               => p_bvr_attribute29
    ,p_bvr_attribute30               => p_bvr_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_ordr_num                      => p_ordr_num
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_bnft_vrbl_rt
    --
    ben_bnft_vrbl_rt_bk2.update_bnft_vrbl_rt_a
      (
       p_bnft_vrbl_rt_id                =>  p_bnft_vrbl_rt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_cvg_amt_calc_mthd_id           =>  p_cvg_amt_calc_mthd_id
      ,p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_bvr_attribute_category         =>  p_bvr_attribute_category
      ,p_bvr_attribute1                 =>  p_bvr_attribute1
      ,p_bvr_attribute2                 =>  p_bvr_attribute2
      ,p_bvr_attribute3                 =>  p_bvr_attribute3
      ,p_bvr_attribute4                 =>  p_bvr_attribute4
      ,p_bvr_attribute5                 =>  p_bvr_attribute5
      ,p_bvr_attribute6                 =>  p_bvr_attribute6
      ,p_bvr_attribute7                 =>  p_bvr_attribute7
      ,p_bvr_attribute8                 =>  p_bvr_attribute8
      ,p_bvr_attribute9                 =>  p_bvr_attribute9
      ,p_bvr_attribute10                =>  p_bvr_attribute10
      ,p_bvr_attribute11                =>  p_bvr_attribute11
      ,p_bvr_attribute12                =>  p_bvr_attribute12
      ,p_bvr_attribute13                =>  p_bvr_attribute13
      ,p_bvr_attribute14                =>  p_bvr_attribute14
      ,p_bvr_attribute15                =>  p_bvr_attribute15
      ,p_bvr_attribute16                =>  p_bvr_attribute16
      ,p_bvr_attribute17                =>  p_bvr_attribute17
      ,p_bvr_attribute18                =>  p_bvr_attribute18
      ,p_bvr_attribute19                =>  p_bvr_attribute19
      ,p_bvr_attribute20                =>  p_bvr_attribute20
      ,p_bvr_attribute21                =>  p_bvr_attribute21
      ,p_bvr_attribute22                =>  p_bvr_attribute22
      ,p_bvr_attribute23                =>  p_bvr_attribute23
      ,p_bvr_attribute24                =>  p_bvr_attribute24
      ,p_bvr_attribute25                =>  p_bvr_attribute25
      ,p_bvr_attribute26                =>  p_bvr_attribute26
      ,p_bvr_attribute27                =>  p_bvr_attribute27
      ,p_bvr_attribute28                =>  p_bvr_attribute28
      ,p_bvr_attribute29                =>  p_bvr_attribute29
      ,p_bvr_attribute30                =>  p_bvr_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_ordr_num                       =>  p_ordr_num
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_bnft_vrbl_rt'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_bnft_vrbl_rt
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
    ROLLBACK TO update_bnft_vrbl_rt;
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
    ROLLBACK TO update_bnft_vrbl_rt;
    -- NOCOPY Changes
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number := l_object_version_number ;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end update_bnft_vrbl_rt;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_bnft_vrbl_rt >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_bnft_vrbl_rt
  (p_validate                       in  boolean  default false
  ,p_bnft_vrbl_rt_id                in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_bnft_vrbl_rt';
  l_object_version_number ben_bnft_vrbl_rt_f.object_version_number%TYPE;
  l_effective_start_date ben_bnft_vrbl_rt_f.effective_start_date%TYPE;
  l_effective_end_date ben_bnft_vrbl_rt_f.effective_end_date%TYPE;
  --
  cursor c1 is
    select plip_id,
           pl_id,
           oipl_id
    from   ben_cvg_amt_calc_mthd_f ccm,
           ben_bnft_vrbl_rt_f bvr
    where  ccm.cvg_amt_calc_mthd_id = bvr.cvg_amt_calc_mthd_id
    and    bvr.bnft_vrbl_rt_id = p_bnft_vrbl_rt_id;
  --
  l_c1 c1%rowtype;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_bnft_vrbl_rt;
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
    -- Start of API User Hook for the before hook of delete_bnft_vrbl_rt
    --
    ben_bnft_vrbl_rt_bk3.delete_bnft_vrbl_rt_b
      (
       p_bnft_vrbl_rt_id                =>  p_bnft_vrbl_rt_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_bnft_vrbl_rt'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_bnft_vrbl_rt
    --
  end;
  --
  ben_bvr_del.del
    (
     p_bnft_vrbl_rt_id               => p_bnft_vrbl_rt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_bnft_vrbl_rt
    --
    ben_bnft_vrbl_rt_bk3.delete_bnft_vrbl_rt_a
      (
       p_bnft_vrbl_rt_id                =>  p_bnft_vrbl_rt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_bnft_vrbl_rt'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_bnft_vrbl_rt
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
  elsif l_c1.plip_id is not null then
    --
    ben_derivable_rate.rate_prfl_handler('DELETE','ben_plip_f','plip_id',l_c1.plip_id);
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
    ROLLBACK TO delete_bnft_vrbl_rt;
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
    ROLLBACK TO delete_bnft_vrbl_rt;
    -- NOCOPY Changes
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number := l_object_version_number ;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end delete_bnft_vrbl_rt;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_bnft_vrbl_rt_id                   in     number
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
  ben_bvr_shd.lck
    (
      p_bnft_vrbl_rt_id                 => p_bnft_vrbl_rt_id
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
end ben_bnft_vrbl_rt_api;

/
