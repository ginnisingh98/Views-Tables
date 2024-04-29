--------------------------------------------------------
--  DDL for Package Body BEN_ACTY_VRBL_RATE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ACTY_VRBL_RATE_API" as
/* $Header: beavrapi.pkb 115.8 2003/06/02 21:14:14 ikasire ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_acty_vrbl_rate_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_acty_vrbl_rate >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_acty_vrbl_rate
  (p_validate                       in  boolean   default false
  ,p_acty_vrbl_rt_id                out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_acty_base_rt_id                in  number    default null
  ,p_vrbl_rt_prfl_id                in  number    default null
  ,p_ordr_num                       in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_avr_attribute_category         in  varchar2  default null
  ,p_avr_attribute1                 in  varchar2  default null
  ,p_avr_attribute2                 in  varchar2  default null
  ,p_avr_attribute3                 in  varchar2  default null
  ,p_avr_attribute4                 in  varchar2  default null
  ,p_avr_attribute5                 in  varchar2  default null
  ,p_avr_attribute6                 in  varchar2  default null
  ,p_avr_attribute7                 in  varchar2  default null
  ,p_avr_attribute8                 in  varchar2  default null
  ,p_avr_attribute9                 in  varchar2  default null
  ,p_avr_attribute10                in  varchar2  default null
  ,p_avr_attribute11                in  varchar2  default null
  ,p_avr_attribute12                in  varchar2  default null
  ,p_avr_attribute13                in  varchar2  default null
  ,p_avr_attribute14                in  varchar2  default null
  ,p_avr_attribute15                in  varchar2  default null
  ,p_avr_attribute16                in  varchar2  default null
  ,p_avr_attribute17                in  varchar2  default null
  ,p_avr_attribute18                in  varchar2  default null
  ,p_avr_attribute19                in  varchar2  default null
  ,p_avr_attribute20                in  varchar2  default null
  ,p_avr_attribute21                in  varchar2  default null
  ,p_avr_attribute22                in  varchar2  default null
  ,p_avr_attribute23                in  varchar2  default null
  ,p_avr_attribute24                in  varchar2  default null
  ,p_avr_attribute25                in  varchar2  default null
  ,p_avr_attribute26                in  varchar2  default null
  ,p_avr_attribute27                in  varchar2  default null
  ,p_avr_attribute28                in  varchar2  default null
  ,p_avr_attribute29                in  varchar2  default null
  ,p_avr_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
   cursor c1 is select pgm_id,pl_id,ptip_id,plip_id,oipl_id,opt_id
     from ben_acty_base_rt_f
     where acty_base_rt_id = p_acty_base_rt_id;
  l_c1  c1%ROWTYPE;
  --
  -- Start Option Level Rates
  --
  cursor c_oipl(p_opt_id number) is
    select distinct oipl_id
      from ben_oipl_f oipl
     where oipl.opt_id = p_opt_id ;
  --
  -- End Option Level Rates
  --
  l_acty_vrbl_rt_id ben_acty_vrbl_rt_f.acty_vrbl_rt_id%TYPE;
  l_effective_start_date ben_acty_vrbl_rt_f.effective_start_date%TYPE;
  l_effective_end_date ben_acty_vrbl_rt_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_acty_vrbl_rate';
  l_object_version_number ben_acty_vrbl_rt_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_acty_vrbl_rate;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_acty_vrbl_rate
    --
    ben_acty_vrbl_rate_bk1.create_acty_vrbl_rate_b
      (
       p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_ordr_num                       =>  p_ordr_num
      ,p_business_group_id              =>  p_business_group_id
      ,p_avr_attribute_category         =>  p_avr_attribute_category
      ,p_avr_attribute1                 =>  p_avr_attribute1
      ,p_avr_attribute2                 =>  p_avr_attribute2
      ,p_avr_attribute3                 =>  p_avr_attribute3
      ,p_avr_attribute4                 =>  p_avr_attribute4
      ,p_avr_attribute5                 =>  p_avr_attribute5
      ,p_avr_attribute6                 =>  p_avr_attribute6
      ,p_avr_attribute7                 =>  p_avr_attribute7
      ,p_avr_attribute8                 =>  p_avr_attribute8
      ,p_avr_attribute9                 =>  p_avr_attribute9
      ,p_avr_attribute10                =>  p_avr_attribute10
      ,p_avr_attribute11                =>  p_avr_attribute11
      ,p_avr_attribute12                =>  p_avr_attribute12
      ,p_avr_attribute13                =>  p_avr_attribute13
      ,p_avr_attribute14                =>  p_avr_attribute14
      ,p_avr_attribute15                =>  p_avr_attribute15
      ,p_avr_attribute16                =>  p_avr_attribute16
      ,p_avr_attribute17                =>  p_avr_attribute17
      ,p_avr_attribute18                =>  p_avr_attribute18
      ,p_avr_attribute19                =>  p_avr_attribute19
      ,p_avr_attribute20                =>  p_avr_attribute20
      ,p_avr_attribute21                =>  p_avr_attribute21
      ,p_avr_attribute22                =>  p_avr_attribute22
      ,p_avr_attribute23                =>  p_avr_attribute23
      ,p_avr_attribute24                =>  p_avr_attribute24
      ,p_avr_attribute25                =>  p_avr_attribute25
      ,p_avr_attribute26                =>  p_avr_attribute26
      ,p_avr_attribute27                =>  p_avr_attribute27
      ,p_avr_attribute28                =>  p_avr_attribute28
      ,p_avr_attribute29                =>  p_avr_attribute29
      ,p_avr_attribute30                =>  p_avr_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_acty_vrbl_rate'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_acty_vrbl_rate
    --
  end;
  --
  ben_avr_ins.ins
    (
     p_acty_vrbl_rt_id               => l_acty_vrbl_rt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_acty_base_rt_id               => p_acty_base_rt_id
    ,p_vrbl_rt_prfl_id               => p_vrbl_rt_prfl_id
    ,p_ordr_num                      => p_ordr_num
    ,p_business_group_id             => p_business_group_id
    ,p_avr_attribute_category        => p_avr_attribute_category
    ,p_avr_attribute1                => p_avr_attribute1
    ,p_avr_attribute2                => p_avr_attribute2
    ,p_avr_attribute3                => p_avr_attribute3
    ,p_avr_attribute4                => p_avr_attribute4
    ,p_avr_attribute5                => p_avr_attribute5
    ,p_avr_attribute6                => p_avr_attribute6
    ,p_avr_attribute7                => p_avr_attribute7
    ,p_avr_attribute8                => p_avr_attribute8
    ,p_avr_attribute9                => p_avr_attribute9
    ,p_avr_attribute10               => p_avr_attribute10
    ,p_avr_attribute11               => p_avr_attribute11
    ,p_avr_attribute12               => p_avr_attribute12
    ,p_avr_attribute13               => p_avr_attribute13
    ,p_avr_attribute14               => p_avr_attribute14
    ,p_avr_attribute15               => p_avr_attribute15
    ,p_avr_attribute16               => p_avr_attribute16
    ,p_avr_attribute17               => p_avr_attribute17
    ,p_avr_attribute18               => p_avr_attribute18
    ,p_avr_attribute19               => p_avr_attribute19
    ,p_avr_attribute20               => p_avr_attribute20
    ,p_avr_attribute21               => p_avr_attribute21
    ,p_avr_attribute22               => p_avr_attribute22
    ,p_avr_attribute23               => p_avr_attribute23
    ,p_avr_attribute24               => p_avr_attribute24
    ,p_avr_attribute25               => p_avr_attribute25
    ,p_avr_attribute26               => p_avr_attribute26
    ,p_avr_attribute27               => p_avr_attribute27
    ,p_avr_attribute28               => p_avr_attribute28
    ,p_avr_attribute29               => p_avr_attribute29
    ,p_avr_attribute30               => p_avr_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_acty_vrbl_rate
    --
    ben_acty_vrbl_rate_bk1.create_acty_vrbl_rate_a
      (
       p_acty_vrbl_rt_id                =>  l_acty_vrbl_rt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_ordr_num                       =>  p_ordr_num
      ,p_business_group_id              =>  p_business_group_id
      ,p_avr_attribute_category         =>  p_avr_attribute_category
      ,p_avr_attribute1                 =>  p_avr_attribute1
      ,p_avr_attribute2                 =>  p_avr_attribute2
      ,p_avr_attribute3                 =>  p_avr_attribute3
      ,p_avr_attribute4                 =>  p_avr_attribute4
      ,p_avr_attribute5                 =>  p_avr_attribute5
      ,p_avr_attribute6                 =>  p_avr_attribute6
      ,p_avr_attribute7                 =>  p_avr_attribute7
      ,p_avr_attribute8                 =>  p_avr_attribute8
      ,p_avr_attribute9                 =>  p_avr_attribute9
      ,p_avr_attribute10                =>  p_avr_attribute10
      ,p_avr_attribute11                =>  p_avr_attribute11
      ,p_avr_attribute12                =>  p_avr_attribute12
      ,p_avr_attribute13                =>  p_avr_attribute13
      ,p_avr_attribute14                =>  p_avr_attribute14
      ,p_avr_attribute15                =>  p_avr_attribute15
      ,p_avr_attribute16                =>  p_avr_attribute16
      ,p_avr_attribute17                =>  p_avr_attribute17
      ,p_avr_attribute18                =>  p_avr_attribute18
      ,p_avr_attribute19                =>  p_avr_attribute19
      ,p_avr_attribute20                =>  p_avr_attribute20
      ,p_avr_attribute21                =>  p_avr_attribute21
      ,p_avr_attribute22                =>  p_avr_attribute22
      ,p_avr_attribute23                =>  p_avr_attribute23
      ,p_avr_attribute24                =>  p_avr_attribute24
      ,p_avr_attribute25                =>  p_avr_attribute25
      ,p_avr_attribute26                =>  p_avr_attribute26
      ,p_avr_attribute27                =>  p_avr_attribute27
      ,p_avr_attribute28                =>  p_avr_attribute28
      ,p_avr_attribute29                =>  p_avr_attribute29
      ,p_avr_attribute30                =>  p_avr_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_acty_vrbl_rate'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_acty_vrbl_rate
    --
  end;
  --
  Open c1;
  fetch c1 into l_c1;
  close c1;
  if l_c1.pgm_id is not null then
     ben_derivable_rate.rate_prfl_handler('CREATE','ben_pgm_f','pgm_id',l_c1.pgm_id);
  elsif l_c1.pl_id is not null then
    ben_derivable_rate.rate_prfl_handler('CREATE','ben_pl_f','pl_id',l_c1.pl_id);
  elsif l_c1.plip_id is not null then
     ben_derivable_rate.rate_prfl_handler('CREATE','ben_plip_f','plip_id',l_c1.plip_id);
  elsif l_c1.ptip_id is not null then
     ben_derivable_rate.rate_prfl_handler('CREATE','ben_ptip_f','ptip_id',l_c1.ptip_id);
  elsif l_c1.oipl_id is not null then
     ben_derivable_rate.rate_prfl_handler('CREATE','ben_oipl_f','oipl_id',l_c1.oipl_id);
  elsif l_c1.opt_id is not null then
     --
     --START Option Level Rates
     for l_oipl in c_oipl(l_c1.opt_id) loop
     ben_derivable_rate.rate_prfl_handler('CREATE','ben_oipl_f','oipl_id',l_oipl.oipl_id);
     end loop ;
     --END Option Level Rates
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
  p_acty_vrbl_rt_id := l_acty_vrbl_rt_id;
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
    ROLLBACK TO create_acty_vrbl_rate;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_acty_vrbl_rt_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_acty_vrbl_rate;
    --
    -- NOCOPY changes.
    --
    p_acty_vrbl_rt_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    --
    raise;
    --
end create_acty_vrbl_rate;
-- ----------------------------------------------------------------------------
-- |------------------------< update_acty_vrbl_rate >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_acty_vrbl_rate
  (p_validate                       in  boolean   default false
  ,p_acty_vrbl_rt_id                in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_acty_base_rt_id                in  number    default hr_api.g_number
  ,p_vrbl_rt_prfl_id                in  number    default hr_api.g_number
  ,p_ordr_num                       in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_avr_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_avr_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_avr_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_avr_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_avr_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_avr_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_avr_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_avr_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_avr_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_avr_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_avr_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_avr_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_avr_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_avr_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_avr_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_avr_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_avr_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_avr_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_avr_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_avr_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_avr_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_avr_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_avr_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_avr_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_avr_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_avr_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_avr_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_avr_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_avr_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_avr_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_avr_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_acty_vrbl_rate';
  l_object_version_number ben_acty_vrbl_rt_f.object_version_number%TYPE;
  l_effective_start_date ben_acty_vrbl_rt_f.effective_start_date%TYPE;
  l_effective_end_date ben_acty_vrbl_rt_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_acty_vrbl_rate;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_acty_vrbl_rate
    --
    ben_acty_vrbl_rate_bk2.update_acty_vrbl_rate_b
      (
       p_acty_vrbl_rt_id                =>  p_acty_vrbl_rt_id
      ,p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_ordr_num                       =>  p_ordr_num
      ,p_business_group_id              =>  p_business_group_id
      ,p_avr_attribute_category         =>  p_avr_attribute_category
      ,p_avr_attribute1                 =>  p_avr_attribute1
      ,p_avr_attribute2                 =>  p_avr_attribute2
      ,p_avr_attribute3                 =>  p_avr_attribute3
      ,p_avr_attribute4                 =>  p_avr_attribute4
      ,p_avr_attribute5                 =>  p_avr_attribute5
      ,p_avr_attribute6                 =>  p_avr_attribute6
      ,p_avr_attribute7                 =>  p_avr_attribute7
      ,p_avr_attribute8                 =>  p_avr_attribute8
      ,p_avr_attribute9                 =>  p_avr_attribute9
      ,p_avr_attribute10                =>  p_avr_attribute10
      ,p_avr_attribute11                =>  p_avr_attribute11
      ,p_avr_attribute12                =>  p_avr_attribute12
      ,p_avr_attribute13                =>  p_avr_attribute13
      ,p_avr_attribute14                =>  p_avr_attribute14
      ,p_avr_attribute15                =>  p_avr_attribute15
      ,p_avr_attribute16                =>  p_avr_attribute16
      ,p_avr_attribute17                =>  p_avr_attribute17
      ,p_avr_attribute18                =>  p_avr_attribute18
      ,p_avr_attribute19                =>  p_avr_attribute19
      ,p_avr_attribute20                =>  p_avr_attribute20
      ,p_avr_attribute21                =>  p_avr_attribute21
      ,p_avr_attribute22                =>  p_avr_attribute22
      ,p_avr_attribute23                =>  p_avr_attribute23
      ,p_avr_attribute24                =>  p_avr_attribute24
      ,p_avr_attribute25                =>  p_avr_attribute25
      ,p_avr_attribute26                =>  p_avr_attribute26
      ,p_avr_attribute27                =>  p_avr_attribute27
      ,p_avr_attribute28                =>  p_avr_attribute28
      ,p_avr_attribute29                =>  p_avr_attribute29
      ,p_avr_attribute30                =>  p_avr_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_acty_vrbl_rate'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_acty_vrbl_rate
    --
  end;
  --
  ben_avr_upd.upd
    (
     p_acty_vrbl_rt_id               => p_acty_vrbl_rt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_acty_base_rt_id               => p_acty_base_rt_id
    ,p_vrbl_rt_prfl_id               => p_vrbl_rt_prfl_id
    ,p_ordr_num                      => p_ordr_num
    ,p_business_group_id             => p_business_group_id
    ,p_avr_attribute_category        => p_avr_attribute_category
    ,p_avr_attribute1                => p_avr_attribute1
    ,p_avr_attribute2                => p_avr_attribute2
    ,p_avr_attribute3                => p_avr_attribute3
    ,p_avr_attribute4                => p_avr_attribute4
    ,p_avr_attribute5                => p_avr_attribute5
    ,p_avr_attribute6                => p_avr_attribute6
    ,p_avr_attribute7                => p_avr_attribute7
    ,p_avr_attribute8                => p_avr_attribute8
    ,p_avr_attribute9                => p_avr_attribute9
    ,p_avr_attribute10               => p_avr_attribute10
    ,p_avr_attribute11               => p_avr_attribute11
    ,p_avr_attribute12               => p_avr_attribute12
    ,p_avr_attribute13               => p_avr_attribute13
    ,p_avr_attribute14               => p_avr_attribute14
    ,p_avr_attribute15               => p_avr_attribute15
    ,p_avr_attribute16               => p_avr_attribute16
    ,p_avr_attribute17               => p_avr_attribute17
    ,p_avr_attribute18               => p_avr_attribute18
    ,p_avr_attribute19               => p_avr_attribute19
    ,p_avr_attribute20               => p_avr_attribute20
    ,p_avr_attribute21               => p_avr_attribute21
    ,p_avr_attribute22               => p_avr_attribute22
    ,p_avr_attribute23               => p_avr_attribute23
    ,p_avr_attribute24               => p_avr_attribute24
    ,p_avr_attribute25               => p_avr_attribute25
    ,p_avr_attribute26               => p_avr_attribute26
    ,p_avr_attribute27               => p_avr_attribute27
    ,p_avr_attribute28               => p_avr_attribute28
    ,p_avr_attribute29               => p_avr_attribute29
    ,p_avr_attribute30               => p_avr_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_acty_vrbl_rate
    --
    ben_acty_vrbl_rate_bk2.update_acty_vrbl_rate_a
      (
       p_acty_vrbl_rt_id                =>  p_acty_vrbl_rt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_ordr_num                       =>  p_ordr_num
      ,p_business_group_id              =>  p_business_group_id
      ,p_avr_attribute_category         =>  p_avr_attribute_category
      ,p_avr_attribute1                 =>  p_avr_attribute1
      ,p_avr_attribute2                 =>  p_avr_attribute2
      ,p_avr_attribute3                 =>  p_avr_attribute3
      ,p_avr_attribute4                 =>  p_avr_attribute4
      ,p_avr_attribute5                 =>  p_avr_attribute5
      ,p_avr_attribute6                 =>  p_avr_attribute6
      ,p_avr_attribute7                 =>  p_avr_attribute7
      ,p_avr_attribute8                 =>  p_avr_attribute8
      ,p_avr_attribute9                 =>  p_avr_attribute9
      ,p_avr_attribute10                =>  p_avr_attribute10
      ,p_avr_attribute11                =>  p_avr_attribute11
      ,p_avr_attribute12                =>  p_avr_attribute12
      ,p_avr_attribute13                =>  p_avr_attribute13
      ,p_avr_attribute14                =>  p_avr_attribute14
      ,p_avr_attribute15                =>  p_avr_attribute15
      ,p_avr_attribute16                =>  p_avr_attribute16
      ,p_avr_attribute17                =>  p_avr_attribute17
      ,p_avr_attribute18                =>  p_avr_attribute18
      ,p_avr_attribute19                =>  p_avr_attribute19
      ,p_avr_attribute20                =>  p_avr_attribute20
      ,p_avr_attribute21                =>  p_avr_attribute21
      ,p_avr_attribute22                =>  p_avr_attribute22
      ,p_avr_attribute23                =>  p_avr_attribute23
      ,p_avr_attribute24                =>  p_avr_attribute24
      ,p_avr_attribute25                =>  p_avr_attribute25
      ,p_avr_attribute26                =>  p_avr_attribute26
      ,p_avr_attribute27                =>  p_avr_attribute27
      ,p_avr_attribute28                =>  p_avr_attribute28
      ,p_avr_attribute29                =>  p_avr_attribute29
      ,p_avr_attribute30                =>  p_avr_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_acty_vrbl_rate'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_acty_vrbl_rate
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
    ROLLBACK TO update_acty_vrbl_rate;
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
    ROLLBACK TO update_acty_vrbl_rate;
    --
    -- NOCOPY changes
    --
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number := l_object_version_number;
    --
    raise;
    --
end update_acty_vrbl_rate;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_acty_vrbl_rate >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_acty_vrbl_rate
  (p_validate                       in  boolean  default false
  ,p_acty_vrbl_rt_id                in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  cursor c1 is select pgm_id,pl_id,ptip_id,plip_id,oipl_id,opt_id
     from ben_acty_base_rt_f abr, ben_acty_vrbl_rt_f avr
     where abr.acty_base_rt_id = avr.acty_base_rt_id and
           avr.acty_vrbl_rt_id = p_acty_vrbl_rt_id;

  --
  l_c1 c1%ROWTYPE;
  --
  -- Start Option Level Rates
  --
  cursor c_oipl(p_opt_id number) is
    select distinct oipl_id
      from ben_oipl_f oipl
     where oipl.opt_id = p_opt_id
       and not exists  ( select abr.oipl_id
                                    from ben_acty_base_rt_f abr
                                   where abr.oipl_id = oipl.oipl_id
                                     and p_effective_date between abr.effective_start_date
                                                              and abr.effective_end_date ) ;
  --
  -- End Option Level Rates
  --
  l_proc varchar2(72) := g_package||'update_acty_vrbl_rate';
  l_object_version_number ben_acty_vrbl_rt_f.object_version_number%TYPE;
  l_effective_start_date ben_acty_vrbl_rt_f.effective_start_date%TYPE;
  l_effective_end_date ben_acty_vrbl_rt_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_acty_vrbl_rate;
  --
  hr_utility.set_location(l_proc, 20);
  open c1;
  fetch c1 into l_c1;
  close c1;
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_acty_vrbl_rate
    --
    ben_acty_vrbl_rate_bk3.delete_acty_vrbl_rate_b
      (
       p_acty_vrbl_rt_id                =>  p_acty_vrbl_rt_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_acty_vrbl_rate'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_acty_vrbl_rate
    --
  end;
  --
  ben_avr_del.del
    (
     p_acty_vrbl_rt_id               => p_acty_vrbl_rt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_acty_vrbl_rate
    --
    ben_acty_vrbl_rate_bk3.delete_acty_vrbl_rate_a
      (
       p_acty_vrbl_rt_id                =>  p_acty_vrbl_rt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_acty_vrbl_rate'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_acty_vrbl_rate
    --
  end;
  --
  if l_c1.pgm_id is not null then
     ben_derivable_rate.rate_prfl_handler('DELETE','ben_pgm_f','pgm_id',l_c1.pgm_id);
  elsif l_c1.pl_id is not null then
    ben_derivable_rate.rate_prfl_handler('DELETE','ben_pl_f','pl_id',l_c1.pl_id);
  elsif l_c1.plip_id is not null then
     ben_derivable_rate.rate_prfl_handler('DELETE','ben_plip_f','plip_id',l_c1.plip_id);
  elsif l_c1.ptip_id is not null then
     ben_derivable_rate.rate_prfl_handler('DELETE','ben_ptip_f','ptip_id',l_c1.ptip_id);
  elsif l_c1.oipl_id is not null then
     ben_derivable_rate.rate_prfl_handler('DELETE','ben_oipl_f','oipl_id',l_c1.oipl_id);
  elsif l_c1.opt_id is not null then
    --
    for l_oipl in c_oipl(l_c1.opt_id) loop
      --
      ben_derivable_rate.rate_prfl_handler('DELETE','ben_oipl_f','oipl_id',l_oipl.oipl_id);
      --
    end loop ;
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
    ROLLBACK TO delete_acty_vrbl_rate;
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
    ROLLBACK TO delete_acty_vrbl_rate;
    --
    -- NOCOPY changes
    --
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number := l_object_version_number;
    --
    raise;
    --
end delete_acty_vrbl_rate;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_acty_vrbl_rt_id                   in     number
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
  ben_avr_shd.lck
    (
      p_acty_vrbl_rt_id                 => p_acty_vrbl_rt_id
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
end ben_acty_vrbl_rate_api;

/
