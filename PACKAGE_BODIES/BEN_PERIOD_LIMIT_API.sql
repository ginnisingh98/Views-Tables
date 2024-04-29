--------------------------------------------------------
--  DDL for Package Body BEN_PERIOD_LIMIT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PERIOD_LIMIT_API" as
/* $Header: bepdlapi.pkb 120.0 2005/05/28 10:26:19 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_period_limit_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_period_limit >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_period_limit
  (p_validate                       in  boolean   default false
  ,p_ptd_lmt_id                     out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default null
  ,p_mx_comp_to_cnsdr               in  number    default null
  ,p_mx_val                         in  number    default null
  ,p_mx_pct_val                     in  number    default null
  ,p_ptd_lmt_calc_rl                in  number    default null
  ,p_lmt_det_cd                     in  varchar2  default null
  ,p_comp_lvl_fctr_id               in  number    default null
  ,p_balance_type_id                in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_pdl_attribute_category         in  varchar2  default null
  ,p_pdl_attribute1                 in  varchar2  default null
  ,p_pdl_attribute2                 in  varchar2  default null
  ,p_pdl_attribute3                 in  varchar2  default null
  ,p_pdl_attribute4                 in  varchar2  default null
  ,p_pdl_attribute5                 in  varchar2  default null
  ,p_pdl_attribute6                 in  varchar2  default null
  ,p_pdl_attribute7                 in  varchar2  default null
  ,p_pdl_attribute8                 in  varchar2  default null
  ,p_pdl_attribute9                 in  varchar2  default null
  ,p_pdl_attribute10                in  varchar2  default null
  ,p_pdl_attribute11                in  varchar2  default null
  ,p_pdl_attribute12                in  varchar2  default null
  ,p_pdl_attribute13                in  varchar2  default null
  ,p_pdl_attribute14                in  varchar2  default null
  ,p_pdl_attribute15                in  varchar2  default null
  ,p_pdl_attribute16                in  varchar2  default null
  ,p_pdl_attribute17                in  varchar2  default null
  ,p_pdl_attribute18                in  varchar2  default null
  ,p_pdl_attribute19                in  varchar2  default null
  ,p_pdl_attribute20                in  varchar2  default null
  ,p_pdl_attribute21                in  varchar2  default null
  ,p_pdl_attribute22                in  varchar2  default null
  ,p_pdl_attribute23                in  varchar2  default null
  ,p_pdl_attribute24                in  varchar2  default null
  ,p_pdl_attribute25                in  varchar2  default null
  ,p_pdl_attribute26                in  varchar2  default null
  ,p_pdl_attribute27                in  varchar2  default null
  ,p_pdl_attribute28                in  varchar2  default null
  ,p_pdl_attribute29                in  varchar2  default null
  ,p_pdl_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_ptd_lmt_id ben_ptd_lmt_f.ptd_lmt_id%TYPE;
  l_effective_start_date ben_ptd_lmt_f.effective_start_date%TYPE;
  l_effective_end_date ben_ptd_lmt_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_period_limit';
  l_object_version_number ben_ptd_lmt_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_period_limit;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_period_limit
    --
    ben_period_limit_bk1.create_period_limit_b
      (
       p_name                           =>  p_name
      ,p_mx_comp_to_cnsdr               =>  p_mx_comp_to_cnsdr
      ,p_mx_val                         =>  p_mx_val
      ,p_mx_pct_val                     =>  p_mx_pct_val
      ,p_ptd_lmt_calc_rl                =>  p_ptd_lmt_calc_rl
      ,p_lmt_det_cd                     =>  p_lmt_det_cd
      ,p_comp_lvl_fctr_id               =>  p_comp_lvl_fctr_id
      ,p_balance_type_id                =>  p_balance_type_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pdl_attribute_category         =>  p_pdl_attribute_category
      ,p_pdl_attribute1                 =>  p_pdl_attribute1
      ,p_pdl_attribute2                 =>  p_pdl_attribute2
      ,p_pdl_attribute3                 =>  p_pdl_attribute3
      ,p_pdl_attribute4                 =>  p_pdl_attribute4
      ,p_pdl_attribute5                 =>  p_pdl_attribute5
      ,p_pdl_attribute6                 =>  p_pdl_attribute6
      ,p_pdl_attribute7                 =>  p_pdl_attribute7
      ,p_pdl_attribute8                 =>  p_pdl_attribute8
      ,p_pdl_attribute9                 =>  p_pdl_attribute9
      ,p_pdl_attribute10                =>  p_pdl_attribute10
      ,p_pdl_attribute11                =>  p_pdl_attribute11
      ,p_pdl_attribute12                =>  p_pdl_attribute12
      ,p_pdl_attribute13                =>  p_pdl_attribute13
      ,p_pdl_attribute14                =>  p_pdl_attribute14
      ,p_pdl_attribute15                =>  p_pdl_attribute15
      ,p_pdl_attribute16                =>  p_pdl_attribute16
      ,p_pdl_attribute17                =>  p_pdl_attribute17
      ,p_pdl_attribute18                =>  p_pdl_attribute18
      ,p_pdl_attribute19                =>  p_pdl_attribute19
      ,p_pdl_attribute20                =>  p_pdl_attribute20
      ,p_pdl_attribute21                =>  p_pdl_attribute21
      ,p_pdl_attribute22                =>  p_pdl_attribute22
      ,p_pdl_attribute23                =>  p_pdl_attribute23
      ,p_pdl_attribute24                =>  p_pdl_attribute24
      ,p_pdl_attribute25                =>  p_pdl_attribute25
      ,p_pdl_attribute26                =>  p_pdl_attribute26
      ,p_pdl_attribute27                =>  p_pdl_attribute27
      ,p_pdl_attribute28                =>  p_pdl_attribute28
      ,p_pdl_attribute29                =>  p_pdl_attribute29
      ,p_pdl_attribute30                =>  p_pdl_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_period_limit'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_period_limit
    --
  end;
  --
  ben_pdl_ins.ins
    (
     p_ptd_lmt_id                    => l_ptd_lmt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_name                          => p_name
    ,p_mx_comp_to_cnsdr              => p_mx_comp_to_cnsdr
    ,p_mx_val                        => p_mx_val
    ,p_mx_pct_val                    => p_mx_pct_val
    ,p_ptd_lmt_calc_rl               => p_ptd_lmt_calc_rl
    ,p_lmt_det_cd                    => p_lmt_det_cd
    ,p_comp_lvl_fctr_id              => p_comp_lvl_fctr_id
    ,p_balance_type_id               => p_balance_type_id
    ,p_business_group_id             => p_business_group_id
    ,p_pdl_attribute_category        => p_pdl_attribute_category
    ,p_pdl_attribute1                => p_pdl_attribute1
    ,p_pdl_attribute2                => p_pdl_attribute2
    ,p_pdl_attribute3                => p_pdl_attribute3
    ,p_pdl_attribute4                => p_pdl_attribute4
    ,p_pdl_attribute5                => p_pdl_attribute5
    ,p_pdl_attribute6                => p_pdl_attribute6
    ,p_pdl_attribute7                => p_pdl_attribute7
    ,p_pdl_attribute8                => p_pdl_attribute8
    ,p_pdl_attribute9                => p_pdl_attribute9
    ,p_pdl_attribute10               => p_pdl_attribute10
    ,p_pdl_attribute11               => p_pdl_attribute11
    ,p_pdl_attribute12               => p_pdl_attribute12
    ,p_pdl_attribute13               => p_pdl_attribute13
    ,p_pdl_attribute14               => p_pdl_attribute14
    ,p_pdl_attribute15               => p_pdl_attribute15
    ,p_pdl_attribute16               => p_pdl_attribute16
    ,p_pdl_attribute17               => p_pdl_attribute17
    ,p_pdl_attribute18               => p_pdl_attribute18
    ,p_pdl_attribute19               => p_pdl_attribute19
    ,p_pdl_attribute20               => p_pdl_attribute20
    ,p_pdl_attribute21               => p_pdl_attribute21
    ,p_pdl_attribute22               => p_pdl_attribute22
    ,p_pdl_attribute23               => p_pdl_attribute23
    ,p_pdl_attribute24               => p_pdl_attribute24
    ,p_pdl_attribute25               => p_pdl_attribute25
    ,p_pdl_attribute26               => p_pdl_attribute26
    ,p_pdl_attribute27               => p_pdl_attribute27
    ,p_pdl_attribute28               => p_pdl_attribute28
    ,p_pdl_attribute29               => p_pdl_attribute29
    ,p_pdl_attribute30               => p_pdl_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_period_limit
    --
    ben_period_limit_bk1.create_period_limit_a
      (
       p_ptd_lmt_id                     =>  l_ptd_lmt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_name                           =>  p_name
      ,p_mx_comp_to_cnsdr               =>  p_mx_comp_to_cnsdr
      ,p_mx_val                         =>  p_mx_val
      ,p_mx_pct_val                     =>  p_mx_pct_val
      ,p_ptd_lmt_calc_rl                =>  p_ptd_lmt_calc_rl
      ,p_lmt_det_cd                     =>  p_lmt_det_cd
      ,p_comp_lvl_fctr_id               =>  p_comp_lvl_fctr_id
      ,p_balance_type_id                =>  p_balance_type_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pdl_attribute_category         =>  p_pdl_attribute_category
      ,p_pdl_attribute1                 =>  p_pdl_attribute1
      ,p_pdl_attribute2                 =>  p_pdl_attribute2
      ,p_pdl_attribute3                 =>  p_pdl_attribute3
      ,p_pdl_attribute4                 =>  p_pdl_attribute4
      ,p_pdl_attribute5                 =>  p_pdl_attribute5
      ,p_pdl_attribute6                 =>  p_pdl_attribute6
      ,p_pdl_attribute7                 =>  p_pdl_attribute7
      ,p_pdl_attribute8                 =>  p_pdl_attribute8
      ,p_pdl_attribute9                 =>  p_pdl_attribute9
      ,p_pdl_attribute10                =>  p_pdl_attribute10
      ,p_pdl_attribute11                =>  p_pdl_attribute11
      ,p_pdl_attribute12                =>  p_pdl_attribute12
      ,p_pdl_attribute13                =>  p_pdl_attribute13
      ,p_pdl_attribute14                =>  p_pdl_attribute14
      ,p_pdl_attribute15                =>  p_pdl_attribute15
      ,p_pdl_attribute16                =>  p_pdl_attribute16
      ,p_pdl_attribute17                =>  p_pdl_attribute17
      ,p_pdl_attribute18                =>  p_pdl_attribute18
      ,p_pdl_attribute19                =>  p_pdl_attribute19
      ,p_pdl_attribute20                =>  p_pdl_attribute20
      ,p_pdl_attribute21                =>  p_pdl_attribute21
      ,p_pdl_attribute22                =>  p_pdl_attribute22
      ,p_pdl_attribute23                =>  p_pdl_attribute23
      ,p_pdl_attribute24                =>  p_pdl_attribute24
      ,p_pdl_attribute25                =>  p_pdl_attribute25
      ,p_pdl_attribute26                =>  p_pdl_attribute26
      ,p_pdl_attribute27                =>  p_pdl_attribute27
      ,p_pdl_attribute28                =>  p_pdl_attribute28
      ,p_pdl_attribute29                =>  p_pdl_attribute29
      ,p_pdl_attribute30                =>  p_pdl_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_period_limit'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_period_limit
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
  p_ptd_lmt_id := l_ptd_lmt_id;
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
    ROLLBACK TO create_period_limit;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_ptd_lmt_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_period_limit;
    -- NOCOPY Changes
    p_ptd_lmt_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number := null ;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end create_period_limit;
-- ----------------------------------------------------------------------------
-- |------------------------< update_period_limit >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_period_limit
  (p_validate                       in  boolean   default false
  ,p_ptd_lmt_id                     in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_mx_comp_to_cnsdr               in  number    default hr_api.g_number
  ,p_mx_val                         in  number    default hr_api.g_number
  ,p_mx_pct_val                     in  number    default hr_api.g_number
  ,p_ptd_lmt_calc_rl                in  number    default hr_api.g_number
  ,p_lmt_det_cd                     in  varchar2  default hr_api.g_varchar2
  ,p_comp_lvl_fctr_id               in  number    default hr_api.g_number
  ,p_balance_type_id                in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pdl_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pdl_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pdl_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pdl_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pdl_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pdl_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pdl_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pdl_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pdl_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pdl_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pdl_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pdl_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pdl_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pdl_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pdl_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pdl_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pdl_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pdl_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pdl_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pdl_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pdl_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pdl_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pdl_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pdl_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pdl_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pdl_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pdl_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pdl_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pdl_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pdl_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pdl_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_period_limit';
  l_object_version_number ben_ptd_lmt_f.object_version_number%TYPE;
  l_effective_start_date ben_ptd_lmt_f.effective_start_date%TYPE;
  l_effective_end_date ben_ptd_lmt_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_period_limit;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_period_limit
    --
    ben_period_limit_bk2.update_period_limit_b
      (
       p_ptd_lmt_id                     =>  p_ptd_lmt_id
      ,p_name                           =>  p_name
      ,p_mx_comp_to_cnsdr               =>  p_mx_comp_to_cnsdr
      ,p_mx_val                         =>  p_mx_val
      ,p_mx_pct_val                     =>  p_mx_pct_val
      ,p_ptd_lmt_calc_rl                =>  p_ptd_lmt_calc_rl
      ,p_lmt_det_cd                     =>  p_lmt_det_cd
      ,p_comp_lvl_fctr_id               =>  p_comp_lvl_fctr_id
      ,p_balance_type_id                =>  p_balance_type_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pdl_attribute_category         =>  p_pdl_attribute_category
      ,p_pdl_attribute1                 =>  p_pdl_attribute1
      ,p_pdl_attribute2                 =>  p_pdl_attribute2
      ,p_pdl_attribute3                 =>  p_pdl_attribute3
      ,p_pdl_attribute4                 =>  p_pdl_attribute4
      ,p_pdl_attribute5                 =>  p_pdl_attribute5
      ,p_pdl_attribute6                 =>  p_pdl_attribute6
      ,p_pdl_attribute7                 =>  p_pdl_attribute7
      ,p_pdl_attribute8                 =>  p_pdl_attribute8
      ,p_pdl_attribute9                 =>  p_pdl_attribute9
      ,p_pdl_attribute10                =>  p_pdl_attribute10
      ,p_pdl_attribute11                =>  p_pdl_attribute11
      ,p_pdl_attribute12                =>  p_pdl_attribute12
      ,p_pdl_attribute13                =>  p_pdl_attribute13
      ,p_pdl_attribute14                =>  p_pdl_attribute14
      ,p_pdl_attribute15                =>  p_pdl_attribute15
      ,p_pdl_attribute16                =>  p_pdl_attribute16
      ,p_pdl_attribute17                =>  p_pdl_attribute17
      ,p_pdl_attribute18                =>  p_pdl_attribute18
      ,p_pdl_attribute19                =>  p_pdl_attribute19
      ,p_pdl_attribute20                =>  p_pdl_attribute20
      ,p_pdl_attribute21                =>  p_pdl_attribute21
      ,p_pdl_attribute22                =>  p_pdl_attribute22
      ,p_pdl_attribute23                =>  p_pdl_attribute23
      ,p_pdl_attribute24                =>  p_pdl_attribute24
      ,p_pdl_attribute25                =>  p_pdl_attribute25
      ,p_pdl_attribute26                =>  p_pdl_attribute26
      ,p_pdl_attribute27                =>  p_pdl_attribute27
      ,p_pdl_attribute28                =>  p_pdl_attribute28
      ,p_pdl_attribute29                =>  p_pdl_attribute29
      ,p_pdl_attribute30                =>  p_pdl_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_period_limit'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_period_limit
    --
  end;
  --
  ben_pdl_upd.upd
    (
     p_ptd_lmt_id                    => p_ptd_lmt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_name                          => p_name
    ,p_mx_comp_to_cnsdr              => p_mx_comp_to_cnsdr
    ,p_mx_val                        => p_mx_val
    ,p_mx_pct_val                    => p_mx_pct_val
    ,p_ptd_lmt_calc_rl               => p_ptd_lmt_calc_rl
    ,p_lmt_det_cd                    => p_lmt_det_cd
    ,p_comp_lvl_fctr_id              => p_comp_lvl_fctr_id
    ,p_balance_type_id               => p_balance_type_id
    ,p_business_group_id             => p_business_group_id
    ,p_pdl_attribute_category        => p_pdl_attribute_category
    ,p_pdl_attribute1                => p_pdl_attribute1
    ,p_pdl_attribute2                => p_pdl_attribute2
    ,p_pdl_attribute3                => p_pdl_attribute3
    ,p_pdl_attribute4                => p_pdl_attribute4
    ,p_pdl_attribute5                => p_pdl_attribute5
    ,p_pdl_attribute6                => p_pdl_attribute6
    ,p_pdl_attribute7                => p_pdl_attribute7
    ,p_pdl_attribute8                => p_pdl_attribute8
    ,p_pdl_attribute9                => p_pdl_attribute9
    ,p_pdl_attribute10               => p_pdl_attribute10
    ,p_pdl_attribute11               => p_pdl_attribute11
    ,p_pdl_attribute12               => p_pdl_attribute12
    ,p_pdl_attribute13               => p_pdl_attribute13
    ,p_pdl_attribute14               => p_pdl_attribute14
    ,p_pdl_attribute15               => p_pdl_attribute15
    ,p_pdl_attribute16               => p_pdl_attribute16
    ,p_pdl_attribute17               => p_pdl_attribute17
    ,p_pdl_attribute18               => p_pdl_attribute18
    ,p_pdl_attribute19               => p_pdl_attribute19
    ,p_pdl_attribute20               => p_pdl_attribute20
    ,p_pdl_attribute21               => p_pdl_attribute21
    ,p_pdl_attribute22               => p_pdl_attribute22
    ,p_pdl_attribute23               => p_pdl_attribute23
    ,p_pdl_attribute24               => p_pdl_attribute24
    ,p_pdl_attribute25               => p_pdl_attribute25
    ,p_pdl_attribute26               => p_pdl_attribute26
    ,p_pdl_attribute27               => p_pdl_attribute27
    ,p_pdl_attribute28               => p_pdl_attribute28
    ,p_pdl_attribute29               => p_pdl_attribute29
    ,p_pdl_attribute30               => p_pdl_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_period_limit
    --
    ben_period_limit_bk2.update_period_limit_a
      (
       p_ptd_lmt_id                     =>  p_ptd_lmt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_name                           =>  p_name
      ,p_mx_comp_to_cnsdr               =>  p_mx_comp_to_cnsdr
      ,p_mx_val                         =>  p_mx_val
      ,p_mx_pct_val                     =>  p_mx_pct_val
      ,p_ptd_lmt_calc_rl                =>  p_ptd_lmt_calc_rl
      ,p_lmt_det_cd                     =>  p_lmt_det_cd
      ,p_comp_lvl_fctr_id               =>  p_comp_lvl_fctr_id
      ,p_balance_type_id                =>  p_balance_type_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pdl_attribute_category         =>  p_pdl_attribute_category
      ,p_pdl_attribute1                 =>  p_pdl_attribute1
      ,p_pdl_attribute2                 =>  p_pdl_attribute2
      ,p_pdl_attribute3                 =>  p_pdl_attribute3
      ,p_pdl_attribute4                 =>  p_pdl_attribute4
      ,p_pdl_attribute5                 =>  p_pdl_attribute5
      ,p_pdl_attribute6                 =>  p_pdl_attribute6
      ,p_pdl_attribute7                 =>  p_pdl_attribute7
      ,p_pdl_attribute8                 =>  p_pdl_attribute8
      ,p_pdl_attribute9                 =>  p_pdl_attribute9
      ,p_pdl_attribute10                =>  p_pdl_attribute10
      ,p_pdl_attribute11                =>  p_pdl_attribute11
      ,p_pdl_attribute12                =>  p_pdl_attribute12
      ,p_pdl_attribute13                =>  p_pdl_attribute13
      ,p_pdl_attribute14                =>  p_pdl_attribute14
      ,p_pdl_attribute15                =>  p_pdl_attribute15
      ,p_pdl_attribute16                =>  p_pdl_attribute16
      ,p_pdl_attribute17                =>  p_pdl_attribute17
      ,p_pdl_attribute18                =>  p_pdl_attribute18
      ,p_pdl_attribute19                =>  p_pdl_attribute19
      ,p_pdl_attribute20                =>  p_pdl_attribute20
      ,p_pdl_attribute21                =>  p_pdl_attribute21
      ,p_pdl_attribute22                =>  p_pdl_attribute22
      ,p_pdl_attribute23                =>  p_pdl_attribute23
      ,p_pdl_attribute24                =>  p_pdl_attribute24
      ,p_pdl_attribute25                =>  p_pdl_attribute25
      ,p_pdl_attribute26                =>  p_pdl_attribute26
      ,p_pdl_attribute27                =>  p_pdl_attribute27
      ,p_pdl_attribute28                =>  p_pdl_attribute28
      ,p_pdl_attribute29                =>  p_pdl_attribute29
      ,p_pdl_attribute30                =>  p_pdl_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_period_limit'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_period_limit
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
    ROLLBACK TO update_period_limit;
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
    ROLLBACK TO update_period_limit;
    -- NOCOPY Changes
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number := l_object_version_number ;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end update_period_limit;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_period_limit >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_period_limit
  (p_validate                       in  boolean  default false
  ,p_ptd_lmt_id                     in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_period_limit';
  l_object_version_number ben_ptd_lmt_f.object_version_number%TYPE;
  l_effective_start_date ben_ptd_lmt_f.effective_start_date%TYPE;
  l_effective_end_date ben_ptd_lmt_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_period_limit;
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
    -- Start of API User Hook for the before hook of delete_period_limit
    --
    ben_period_limit_bk3.delete_period_limit_b
      (
       p_ptd_lmt_id                     =>  p_ptd_lmt_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_period_limit'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_period_limit
    --
  end;
  --
  ben_pdl_del.del
    (
     p_ptd_lmt_id                    => p_ptd_lmt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_period_limit
    --
    ben_period_limit_bk3.delete_period_limit_a
      (
       p_ptd_lmt_id                     =>  p_ptd_lmt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_period_limit'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_period_limit
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
    ROLLBACK TO delete_period_limit;
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
    ROLLBACK TO delete_period_limit;
    -- NOCOPY Changes
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number := l_object_version_number ;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end delete_period_limit;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_ptd_lmt_id                   in     number
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
  ben_pdl_shd.lck
    (
      p_ptd_lmt_id                 => p_ptd_lmt_id
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
end ben_period_limit_api;

/
