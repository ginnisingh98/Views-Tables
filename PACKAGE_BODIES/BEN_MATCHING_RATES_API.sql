--------------------------------------------------------
--  DDL for Package Body BEN_MATCHING_RATES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_MATCHING_RATES_API" as
/* $Header: bemtrapi.pkb 115.4 2002/12/16 17:38:59 glingapp ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_MATCHING_RATES_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_MATCHING_RATES >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_MATCHING_RATES
  (p_validate                       in  boolean   default false
  ,p_mtchg_rt_id                    out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_ordr_num                       in  number    default null
  ,p_from_pct_val                   in  number    default null
  ,p_to_pct_val                     in  number    default null
  ,p_pct_val                        in  number    default null
  ,p_mx_amt_of_py_num               in  number    default null
  ,p_mx_pct_of_py_num               in  number    default null
  ,p_mx_mtch_amt                    in  number    default null
  ,p_mn_mtch_amt                    in  number    default null
  ,p_mtchg_rt_calc_rl               in  number    default null
  ,p_no_mx_mtch_amt_flag            in  varchar2  default null
  ,p_no_mx_pct_of_py_num_flag       in  varchar2  default null
  ,p_cntnu_mtch_aftr_mx_rl_flag     in  varchar2  default null
  ,p_no_mx_amt_of_py_num_flag       in  varchar2  default null
  ,p_acty_base_rt_id                in  number    default null
  ,p_comp_lvl_fctr_id               in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_mtr_attribute_category         in  varchar2  default null
  ,p_mtr_attribute1                 in  varchar2  default null
  ,p_mtr_attribute2                 in  varchar2  default null
  ,p_mtr_attribute3                 in  varchar2  default null
  ,p_mtr_attribute4                 in  varchar2  default null
  ,p_mtr_attribute5                 in  varchar2  default null
  ,p_mtr_attribute6                 in  varchar2  default null
  ,p_mtr_attribute7                 in  varchar2  default null
  ,p_mtr_attribute8                 in  varchar2  default null
  ,p_mtr_attribute9                 in  varchar2  default null
  ,p_mtr_attribute10                in  varchar2  default null
  ,p_mtr_attribute11                in  varchar2  default null
  ,p_mtr_attribute12                in  varchar2  default null
  ,p_mtr_attribute13                in  varchar2  default null
  ,p_mtr_attribute14                in  varchar2  default null
  ,p_mtr_attribute15                in  varchar2  default null
  ,p_mtr_attribute16                in  varchar2  default null
  ,p_mtr_attribute17                in  varchar2  default null
  ,p_mtr_attribute18                in  varchar2  default null
  ,p_mtr_attribute19                in  varchar2  default null
  ,p_mtr_attribute20                in  varchar2  default null
  ,p_mtr_attribute21                in  varchar2  default null
  ,p_mtr_attribute22                in  varchar2  default null
  ,p_mtr_attribute23                in  varchar2  default null
  ,p_mtr_attribute24                in  varchar2  default null
  ,p_mtr_attribute25                in  varchar2  default null
  ,p_mtr_attribute26                in  varchar2  default null
  ,p_mtr_attribute27                in  varchar2  default null
  ,p_mtr_attribute28                in  varchar2  default null
  ,p_mtr_attribute29                in  varchar2  default null
  ,p_mtr_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_mtchg_rt_id ben_mtchg_rt_f.mtchg_rt_id%TYPE;
  l_effective_start_date ben_mtchg_rt_f.effective_start_date%TYPE;
  l_effective_end_date ben_mtchg_rt_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_MATCHING_RATES';
  l_object_version_number ben_mtchg_rt_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_MATCHING_RATES;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_MATCHING_RATES
    --
    ben_MATCHING_RATES_bk1.create_MATCHING_RATES_b
      (
       p_ordr_num                       =>  p_ordr_num
      ,p_from_pct_val                   =>  p_from_pct_val
      ,p_to_pct_val                     =>  p_to_pct_val
      ,p_pct_val                        =>  p_pct_val
      ,p_mx_amt_of_py_num               =>  p_mx_amt_of_py_num
      ,p_mx_pct_of_py_num               =>  p_mx_pct_of_py_num
      ,p_mx_mtch_amt                    =>  p_mx_mtch_amt
      ,p_mn_mtch_amt                    =>  p_mn_mtch_amt
      ,p_mtchg_rt_calc_rl               =>  p_mtchg_rt_calc_rl
      ,p_no_mx_mtch_amt_flag            =>  p_no_mx_mtch_amt_flag
      ,p_no_mx_pct_of_py_num_flag       =>  p_no_mx_pct_of_py_num_flag
      ,p_cntnu_mtch_aftr_mx_rl_flag     =>  p_cntnu_mtch_aftr_mx_rl_flag
      ,p_no_mx_amt_of_py_num_flag       =>  p_no_mx_amt_of_py_num_flag
      ,p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_comp_lvl_fctr_id               =>  p_comp_lvl_fctr_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_mtr_attribute_category         =>  p_mtr_attribute_category
      ,p_mtr_attribute1                 =>  p_mtr_attribute1
      ,p_mtr_attribute2                 =>  p_mtr_attribute2
      ,p_mtr_attribute3                 =>  p_mtr_attribute3
      ,p_mtr_attribute4                 =>  p_mtr_attribute4
      ,p_mtr_attribute5                 =>  p_mtr_attribute5
      ,p_mtr_attribute6                 =>  p_mtr_attribute6
      ,p_mtr_attribute7                 =>  p_mtr_attribute7
      ,p_mtr_attribute8                 =>  p_mtr_attribute8
      ,p_mtr_attribute9                 =>  p_mtr_attribute9
      ,p_mtr_attribute10                =>  p_mtr_attribute10
      ,p_mtr_attribute11                =>  p_mtr_attribute11
      ,p_mtr_attribute12                =>  p_mtr_attribute12
      ,p_mtr_attribute13                =>  p_mtr_attribute13
      ,p_mtr_attribute14                =>  p_mtr_attribute14
      ,p_mtr_attribute15                =>  p_mtr_attribute15
      ,p_mtr_attribute16                =>  p_mtr_attribute16
      ,p_mtr_attribute17                =>  p_mtr_attribute17
      ,p_mtr_attribute18                =>  p_mtr_attribute18
      ,p_mtr_attribute19                =>  p_mtr_attribute19
      ,p_mtr_attribute20                =>  p_mtr_attribute20
      ,p_mtr_attribute21                =>  p_mtr_attribute21
      ,p_mtr_attribute22                =>  p_mtr_attribute22
      ,p_mtr_attribute23                =>  p_mtr_attribute23
      ,p_mtr_attribute24                =>  p_mtr_attribute24
      ,p_mtr_attribute25                =>  p_mtr_attribute25
      ,p_mtr_attribute26                =>  p_mtr_attribute26
      ,p_mtr_attribute27                =>  p_mtr_attribute27
      ,p_mtr_attribute28                =>  p_mtr_attribute28
      ,p_mtr_attribute29                =>  p_mtr_attribute29
      ,p_mtr_attribute30                =>  p_mtr_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_MATCHING_RATES'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_MATCHING_RATES
    --
  end;
  --
  ben_mtr_ins.ins
    (
     p_mtchg_rt_id                   => l_mtchg_rt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_ordr_num                      => p_ordr_num
    ,p_from_pct_val                  => p_from_pct_val
    ,p_to_pct_val                    => p_to_pct_val
    ,p_pct_val                       => p_pct_val
    ,p_mx_amt_of_py_num              => p_mx_amt_of_py_num
    ,p_mx_pct_of_py_num              => p_mx_pct_of_py_num
    ,p_mx_mtch_amt                   => p_mx_mtch_amt
    ,p_mn_mtch_amt                   => p_mn_mtch_amt
    ,p_mtchg_rt_calc_rl              => p_mtchg_rt_calc_rl
    ,p_no_mx_mtch_amt_flag           => p_no_mx_mtch_amt_flag
    ,p_no_mx_pct_of_py_num_flag      => p_no_mx_pct_of_py_num_flag
    ,p_cntnu_mtch_aftr_mx_rl_flag    => p_cntnu_mtch_aftr_mx_rl_flag
    ,p_no_mx_amt_of_py_num_flag      => p_no_mx_amt_of_py_num_flag
    ,p_acty_base_rt_id               => p_acty_base_rt_id
    ,p_comp_lvl_fctr_id              => p_comp_lvl_fctr_id
    ,p_business_group_id             => p_business_group_id
    ,p_mtr_attribute_category        => p_mtr_attribute_category
    ,p_mtr_attribute1                => p_mtr_attribute1
    ,p_mtr_attribute2                => p_mtr_attribute2
    ,p_mtr_attribute3                => p_mtr_attribute3
    ,p_mtr_attribute4                => p_mtr_attribute4
    ,p_mtr_attribute5                => p_mtr_attribute5
    ,p_mtr_attribute6                => p_mtr_attribute6
    ,p_mtr_attribute7                => p_mtr_attribute7
    ,p_mtr_attribute8                => p_mtr_attribute8
    ,p_mtr_attribute9                => p_mtr_attribute9
    ,p_mtr_attribute10               => p_mtr_attribute10
    ,p_mtr_attribute11               => p_mtr_attribute11
    ,p_mtr_attribute12               => p_mtr_attribute12
    ,p_mtr_attribute13               => p_mtr_attribute13
    ,p_mtr_attribute14               => p_mtr_attribute14
    ,p_mtr_attribute15               => p_mtr_attribute15
    ,p_mtr_attribute16               => p_mtr_attribute16
    ,p_mtr_attribute17               => p_mtr_attribute17
    ,p_mtr_attribute18               => p_mtr_attribute18
    ,p_mtr_attribute19               => p_mtr_attribute19
    ,p_mtr_attribute20               => p_mtr_attribute20
    ,p_mtr_attribute21               => p_mtr_attribute21
    ,p_mtr_attribute22               => p_mtr_attribute22
    ,p_mtr_attribute23               => p_mtr_attribute23
    ,p_mtr_attribute24               => p_mtr_attribute24
    ,p_mtr_attribute25               => p_mtr_attribute25
    ,p_mtr_attribute26               => p_mtr_attribute26
    ,p_mtr_attribute27               => p_mtr_attribute27
    ,p_mtr_attribute28               => p_mtr_attribute28
    ,p_mtr_attribute29               => p_mtr_attribute29
    ,p_mtr_attribute30               => p_mtr_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_MATCHING_RATES
    --
    ben_MATCHING_RATES_bk1.create_MATCHING_RATES_a
      (
       p_mtchg_rt_id                    =>  l_mtchg_rt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_ordr_num                       =>  p_ordr_num
      ,p_from_pct_val                   =>  p_from_pct_val
      ,p_to_pct_val                     =>  p_to_pct_val
      ,p_pct_val                        =>  p_pct_val
      ,p_mx_amt_of_py_num               =>  p_mx_amt_of_py_num
      ,p_mx_pct_of_py_num               =>  p_mx_pct_of_py_num
      ,p_mx_mtch_amt                    =>  p_mx_mtch_amt
      ,p_mn_mtch_amt                    =>  p_mn_mtch_amt
      ,p_mtchg_rt_calc_rl               =>  p_mtchg_rt_calc_rl
      ,p_no_mx_mtch_amt_flag            =>  p_no_mx_mtch_amt_flag
      ,p_no_mx_pct_of_py_num_flag       =>  p_no_mx_pct_of_py_num_flag
      ,p_cntnu_mtch_aftr_mx_rl_flag     =>  p_cntnu_mtch_aftr_mx_rl_flag
      ,p_no_mx_amt_of_py_num_flag       =>  p_no_mx_amt_of_py_num_flag
      ,p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_comp_lvl_fctr_id               =>  p_comp_lvl_fctr_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_mtr_attribute_category         =>  p_mtr_attribute_category
      ,p_mtr_attribute1                 =>  p_mtr_attribute1
      ,p_mtr_attribute2                 =>  p_mtr_attribute2
      ,p_mtr_attribute3                 =>  p_mtr_attribute3
      ,p_mtr_attribute4                 =>  p_mtr_attribute4
      ,p_mtr_attribute5                 =>  p_mtr_attribute5
      ,p_mtr_attribute6                 =>  p_mtr_attribute6
      ,p_mtr_attribute7                 =>  p_mtr_attribute7
      ,p_mtr_attribute8                 =>  p_mtr_attribute8
      ,p_mtr_attribute9                 =>  p_mtr_attribute9
      ,p_mtr_attribute10                =>  p_mtr_attribute10
      ,p_mtr_attribute11                =>  p_mtr_attribute11
      ,p_mtr_attribute12                =>  p_mtr_attribute12
      ,p_mtr_attribute13                =>  p_mtr_attribute13
      ,p_mtr_attribute14                =>  p_mtr_attribute14
      ,p_mtr_attribute15                =>  p_mtr_attribute15
      ,p_mtr_attribute16                =>  p_mtr_attribute16
      ,p_mtr_attribute17                =>  p_mtr_attribute17
      ,p_mtr_attribute18                =>  p_mtr_attribute18
      ,p_mtr_attribute19                =>  p_mtr_attribute19
      ,p_mtr_attribute20                =>  p_mtr_attribute20
      ,p_mtr_attribute21                =>  p_mtr_attribute21
      ,p_mtr_attribute22                =>  p_mtr_attribute22
      ,p_mtr_attribute23                =>  p_mtr_attribute23
      ,p_mtr_attribute24                =>  p_mtr_attribute24
      ,p_mtr_attribute25                =>  p_mtr_attribute25
      ,p_mtr_attribute26                =>  p_mtr_attribute26
      ,p_mtr_attribute27                =>  p_mtr_attribute27
      ,p_mtr_attribute28                =>  p_mtr_attribute28
      ,p_mtr_attribute29                =>  p_mtr_attribute29
      ,p_mtr_attribute30                =>  p_mtr_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_MATCHING_RATES'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_MATCHING_RATES
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
  p_mtchg_rt_id := l_mtchg_rt_id;
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
    ROLLBACK TO create_MATCHING_RATES;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_mtchg_rt_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_MATCHING_RATES;
    p_mtchg_rt_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    raise;
    --
end create_MATCHING_RATES;
-- ----------------------------------------------------------------------------
-- |------------------------< update_MATCHING_RATES >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_MATCHING_RATES
  (p_validate                       in  boolean   default false
  ,p_mtchg_rt_id                    in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_ordr_num                       in  number    default hr_api.g_number
  ,p_from_pct_val                   in  number    default hr_api.g_number
  ,p_to_pct_val                     in  number    default hr_api.g_number
  ,p_pct_val                        in  number    default hr_api.g_number
  ,p_mx_amt_of_py_num               in  number    default hr_api.g_number
  ,p_mx_pct_of_py_num               in  number    default hr_api.g_number
  ,p_mx_mtch_amt                    in  number    default hr_api.g_number
  ,p_mn_mtch_amt                    in  number    default hr_api.g_number
  ,p_mtchg_rt_calc_rl               in  number    default hr_api.g_number
  ,p_no_mx_mtch_amt_flag            in  varchar2  default hr_api.g_varchar2
  ,p_no_mx_pct_of_py_num_flag       in  varchar2  default hr_api.g_varchar2
  ,p_cntnu_mtch_aftr_mx_rl_flag     in  varchar2  default hr_api.g_varchar2
  ,p_no_mx_amt_of_py_num_flag       in  varchar2  default hr_api.g_varchar2
  ,p_acty_base_rt_id                in  number    default hr_api.g_number
  ,p_comp_lvl_fctr_id               in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_mtr_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_mtr_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_mtr_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_mtr_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_mtr_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_mtr_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_mtr_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_mtr_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_mtr_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_mtr_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_mtr_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_mtr_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_mtr_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_mtr_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_mtr_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_mtr_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_mtr_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_mtr_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_mtr_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_mtr_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_mtr_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_mtr_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_mtr_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_mtr_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_mtr_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_mtr_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_mtr_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_mtr_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_mtr_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_mtr_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_mtr_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_MATCHING_RATES';
  l_object_version_number ben_mtchg_rt_f.object_version_number%TYPE;
  l_effective_start_date ben_mtchg_rt_f.effective_start_date%TYPE;
  l_effective_end_date ben_mtchg_rt_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_MATCHING_RATES;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_MATCHING_RATES
    --
    ben_MATCHING_RATES_bk2.update_MATCHING_RATES_b
      (
       p_mtchg_rt_id                    =>  p_mtchg_rt_id
      ,p_ordr_num                       =>  p_ordr_num
      ,p_from_pct_val                   =>  p_from_pct_val
      ,p_to_pct_val                     =>  p_to_pct_val
      ,p_pct_val                        =>  p_pct_val
      ,p_mx_amt_of_py_num               =>  p_mx_amt_of_py_num
      ,p_mx_pct_of_py_num               =>  p_mx_pct_of_py_num
      ,p_mx_mtch_amt                    =>  p_mx_mtch_amt
      ,p_mn_mtch_amt                    =>  p_mn_mtch_amt
      ,p_mtchg_rt_calc_rl               =>  p_mtchg_rt_calc_rl
      ,p_no_mx_mtch_amt_flag            =>  p_no_mx_mtch_amt_flag
      ,p_no_mx_pct_of_py_num_flag       =>  p_no_mx_pct_of_py_num_flag
      ,p_cntnu_mtch_aftr_mx_rl_flag     =>  p_cntnu_mtch_aftr_mx_rl_flag
      ,p_no_mx_amt_of_py_num_flag       =>  p_no_mx_amt_of_py_num_flag
      ,p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_comp_lvl_fctr_id               =>  p_comp_lvl_fctr_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_mtr_attribute_category         =>  p_mtr_attribute_category
      ,p_mtr_attribute1                 =>  p_mtr_attribute1
      ,p_mtr_attribute2                 =>  p_mtr_attribute2
      ,p_mtr_attribute3                 =>  p_mtr_attribute3
      ,p_mtr_attribute4                 =>  p_mtr_attribute4
      ,p_mtr_attribute5                 =>  p_mtr_attribute5
      ,p_mtr_attribute6                 =>  p_mtr_attribute6
      ,p_mtr_attribute7                 =>  p_mtr_attribute7
      ,p_mtr_attribute8                 =>  p_mtr_attribute8
      ,p_mtr_attribute9                 =>  p_mtr_attribute9
      ,p_mtr_attribute10                =>  p_mtr_attribute10
      ,p_mtr_attribute11                =>  p_mtr_attribute11
      ,p_mtr_attribute12                =>  p_mtr_attribute12
      ,p_mtr_attribute13                =>  p_mtr_attribute13
      ,p_mtr_attribute14                =>  p_mtr_attribute14
      ,p_mtr_attribute15                =>  p_mtr_attribute15
      ,p_mtr_attribute16                =>  p_mtr_attribute16
      ,p_mtr_attribute17                =>  p_mtr_attribute17
      ,p_mtr_attribute18                =>  p_mtr_attribute18
      ,p_mtr_attribute19                =>  p_mtr_attribute19
      ,p_mtr_attribute20                =>  p_mtr_attribute20
      ,p_mtr_attribute21                =>  p_mtr_attribute21
      ,p_mtr_attribute22                =>  p_mtr_attribute22
      ,p_mtr_attribute23                =>  p_mtr_attribute23
      ,p_mtr_attribute24                =>  p_mtr_attribute24
      ,p_mtr_attribute25                =>  p_mtr_attribute25
      ,p_mtr_attribute26                =>  p_mtr_attribute26
      ,p_mtr_attribute27                =>  p_mtr_attribute27
      ,p_mtr_attribute28                =>  p_mtr_attribute28
      ,p_mtr_attribute29                =>  p_mtr_attribute29
      ,p_mtr_attribute30                =>  p_mtr_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_MATCHING_RATES'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_MATCHING_RATES
    --
  end;
  --
  ben_mtr_upd.upd
    (
     p_mtchg_rt_id                   => p_mtchg_rt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_ordr_num                      => p_ordr_num
    ,p_from_pct_val                  => p_from_pct_val
    ,p_to_pct_val                    => p_to_pct_val
    ,p_pct_val                       => p_pct_val
    ,p_mx_amt_of_py_num              => p_mx_amt_of_py_num
    ,p_mx_pct_of_py_num              => p_mx_pct_of_py_num
    ,p_mx_mtch_amt                   => p_mx_mtch_amt
    ,p_mn_mtch_amt                   => p_mn_mtch_amt
    ,p_mtchg_rt_calc_rl              => p_mtchg_rt_calc_rl
    ,p_no_mx_mtch_amt_flag           => p_no_mx_mtch_amt_flag
    ,p_no_mx_pct_of_py_num_flag      => p_no_mx_pct_of_py_num_flag
    ,p_cntnu_mtch_aftr_mx_rl_flag    => p_cntnu_mtch_aftr_mx_rl_flag
    ,p_no_mx_amt_of_py_num_flag      => p_no_mx_amt_of_py_num_flag
    ,p_acty_base_rt_id               => p_acty_base_rt_id
    ,p_comp_lvl_fctr_id              => p_comp_lvl_fctr_id
    ,p_business_group_id             => p_business_group_id
    ,p_mtr_attribute_category        => p_mtr_attribute_category
    ,p_mtr_attribute1                => p_mtr_attribute1
    ,p_mtr_attribute2                => p_mtr_attribute2
    ,p_mtr_attribute3                => p_mtr_attribute3
    ,p_mtr_attribute4                => p_mtr_attribute4
    ,p_mtr_attribute5                => p_mtr_attribute5
    ,p_mtr_attribute6                => p_mtr_attribute6
    ,p_mtr_attribute7                => p_mtr_attribute7
    ,p_mtr_attribute8                => p_mtr_attribute8
    ,p_mtr_attribute9                => p_mtr_attribute9
    ,p_mtr_attribute10               => p_mtr_attribute10
    ,p_mtr_attribute11               => p_mtr_attribute11
    ,p_mtr_attribute12               => p_mtr_attribute12
    ,p_mtr_attribute13               => p_mtr_attribute13
    ,p_mtr_attribute14               => p_mtr_attribute14
    ,p_mtr_attribute15               => p_mtr_attribute15
    ,p_mtr_attribute16               => p_mtr_attribute16
    ,p_mtr_attribute17               => p_mtr_attribute17
    ,p_mtr_attribute18               => p_mtr_attribute18
    ,p_mtr_attribute19               => p_mtr_attribute19
    ,p_mtr_attribute20               => p_mtr_attribute20
    ,p_mtr_attribute21               => p_mtr_attribute21
    ,p_mtr_attribute22               => p_mtr_attribute22
    ,p_mtr_attribute23               => p_mtr_attribute23
    ,p_mtr_attribute24               => p_mtr_attribute24
    ,p_mtr_attribute25               => p_mtr_attribute25
    ,p_mtr_attribute26               => p_mtr_attribute26
    ,p_mtr_attribute27               => p_mtr_attribute27
    ,p_mtr_attribute28               => p_mtr_attribute28
    ,p_mtr_attribute29               => p_mtr_attribute29
    ,p_mtr_attribute30               => p_mtr_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_MATCHING_RATES
    --
    ben_MATCHING_RATES_bk2.update_MATCHING_RATES_a
      (
       p_mtchg_rt_id                    =>  p_mtchg_rt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_ordr_num                       =>  p_ordr_num
      ,p_from_pct_val                   =>  p_from_pct_val
      ,p_to_pct_val                     =>  p_to_pct_val
      ,p_pct_val                        =>  p_pct_val
      ,p_mx_amt_of_py_num               =>  p_mx_amt_of_py_num
      ,p_mx_pct_of_py_num               =>  p_mx_pct_of_py_num
      ,p_mx_mtch_amt                    =>  p_mx_mtch_amt
      ,p_mn_mtch_amt                    =>  p_mn_mtch_amt
      ,p_mtchg_rt_calc_rl               =>  p_mtchg_rt_calc_rl
      ,p_no_mx_mtch_amt_flag            =>  p_no_mx_mtch_amt_flag
      ,p_no_mx_pct_of_py_num_flag       =>  p_no_mx_pct_of_py_num_flag
      ,p_cntnu_mtch_aftr_mx_rl_flag     =>  p_cntnu_mtch_aftr_mx_rl_flag
      ,p_no_mx_amt_of_py_num_flag       =>  p_no_mx_amt_of_py_num_flag
      ,p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_comp_lvl_fctr_id               =>  p_comp_lvl_fctr_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_mtr_attribute_category         =>  p_mtr_attribute_category
      ,p_mtr_attribute1                 =>  p_mtr_attribute1
      ,p_mtr_attribute2                 =>  p_mtr_attribute2
      ,p_mtr_attribute3                 =>  p_mtr_attribute3
      ,p_mtr_attribute4                 =>  p_mtr_attribute4
      ,p_mtr_attribute5                 =>  p_mtr_attribute5
      ,p_mtr_attribute6                 =>  p_mtr_attribute6
      ,p_mtr_attribute7                 =>  p_mtr_attribute7
      ,p_mtr_attribute8                 =>  p_mtr_attribute8
      ,p_mtr_attribute9                 =>  p_mtr_attribute9
      ,p_mtr_attribute10                =>  p_mtr_attribute10
      ,p_mtr_attribute11                =>  p_mtr_attribute11
      ,p_mtr_attribute12                =>  p_mtr_attribute12
      ,p_mtr_attribute13                =>  p_mtr_attribute13
      ,p_mtr_attribute14                =>  p_mtr_attribute14
      ,p_mtr_attribute15                =>  p_mtr_attribute15
      ,p_mtr_attribute16                =>  p_mtr_attribute16
      ,p_mtr_attribute17                =>  p_mtr_attribute17
      ,p_mtr_attribute18                =>  p_mtr_attribute18
      ,p_mtr_attribute19                =>  p_mtr_attribute19
      ,p_mtr_attribute20                =>  p_mtr_attribute20
      ,p_mtr_attribute21                =>  p_mtr_attribute21
      ,p_mtr_attribute22                =>  p_mtr_attribute22
      ,p_mtr_attribute23                =>  p_mtr_attribute23
      ,p_mtr_attribute24                =>  p_mtr_attribute24
      ,p_mtr_attribute25                =>  p_mtr_attribute25
      ,p_mtr_attribute26                =>  p_mtr_attribute26
      ,p_mtr_attribute27                =>  p_mtr_attribute27
      ,p_mtr_attribute28                =>  p_mtr_attribute28
      ,p_mtr_attribute29                =>  p_mtr_attribute29
      ,p_mtr_attribute30                =>  p_mtr_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_MATCHING_RATES'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_MATCHING_RATES
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
    ROLLBACK TO update_MATCHING_RATES;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_start_date := null;
    p_effective_end_date := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_MATCHING_RATES;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end update_MATCHING_RATES;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_MATCHING_RATES >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_MATCHING_RATES
  (p_validate                       in  boolean  default false
  ,p_mtchg_rt_id                    in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_MATCHING_RATES';
  l_object_version_number ben_mtchg_rt_f.object_version_number%TYPE;
  l_effective_start_date ben_mtchg_rt_f.effective_start_date%TYPE;
  l_effective_end_date ben_mtchg_rt_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_MATCHING_RATES;
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
    -- Start of API User Hook for the before hook of delete_MATCHING_RATES
    --
    ben_MATCHING_RATES_bk3.delete_MATCHING_RATES_b
      (
       p_mtchg_rt_id                    =>  p_mtchg_rt_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_MATCHING_RATES'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_MATCHING_RATES
    --
  end;
  --
  ben_mtr_del.del
    (
     p_mtchg_rt_id                   => p_mtchg_rt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_MATCHING_RATES
    --
    ben_MATCHING_RATES_bk3.delete_MATCHING_RATES_a
      (
       p_mtchg_rt_id                    =>  p_mtchg_rt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_MATCHING_RATES'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_MATCHING_RATES
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
    ROLLBACK TO delete_MATCHING_RATES;
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
    ROLLBACK TO delete_MATCHING_RATES;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end delete_MATCHING_RATES;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_mtchg_rt_id                   in     number
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
  ben_mtr_shd.lck
    (
      p_mtchg_rt_id                 => p_mtchg_rt_id
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
end ben_MATCHING_RATES_api;

/
