--------------------------------------------------------
--  DDL for Package Body BEN_VRBL_MATCHING_RATE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_VRBL_MATCHING_RATE_API" as
/* $Header: bevmrapi.pkb 120.0 2005/05/28 12:05:20 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_VRBL_MATCHING_RATE_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_VRBL_MATCHING_RATE >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_VRBL_MATCHING_RATE
  (p_validate                       in  boolean   default false
  ,p_vrbl_mtchg_rt_id               out nocopy number
  ,p_effective_end_date             out nocopy date
  ,p_effective_start_date           out nocopy date
  ,p_no_mx_pct_of_py_num_flag       in  varchar2  default null
  ,p_to_pct_val                     in  number    default null
  ,p_no_mx_amt_of_py_num_flag       in  varchar2  default null
  ,p_mx_pct_of_py_num               in  number    default null
  ,p_no_mx_mtch_amt_flag            in  varchar2  default null
  ,p_ordr_num                       in  number    default null
  ,p_pct_val                        in  number    default null
  ,p_mx_mtch_amt                    in  number    default null
  ,p_mx_amt_of_py_num               in  number    default null
  ,p_mn_mtch_amt                    in  number    default null
  ,p_mtchg_rt_calc_rl               in  number    default null
  ,p_cntnu_mtch_aftr_max_rl_flag    in  varchar2  default null
  ,p_from_pct_val                   in  number    default null
  ,p_vrbl_rt_prfl_id                in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_vmr_attribute_category         in  varchar2  default null
  ,p_vmr_attribute1                 in  varchar2  default null
  ,p_vmr_attribute2                 in  varchar2  default null
  ,p_vmr_attribute3                 in  varchar2  default null
  ,p_vmr_attribute4                 in  varchar2  default null
  ,p_vmr_attribute5                 in  varchar2  default null
  ,p_vmr_attribute6                 in  varchar2  default null
  ,p_vmr_attribute7                 in  varchar2  default null
  ,p_vmr_attribute8                 in  varchar2  default null
  ,p_vmr_attribute9                 in  varchar2  default null
  ,p_vmr_attribute10                in  varchar2  default null
  ,p_vmr_attribute11                in  varchar2  default null
  ,p_vmr_attribute12                in  varchar2  default null
  ,p_vmr_attribute13                in  varchar2  default null
  ,p_vmr_attribute14                in  varchar2  default null
  ,p_vmr_attribute15                in  varchar2  default null
  ,p_vmr_attribute16                in  varchar2  default null
  ,p_vmr_attribute17                in  varchar2  default null
  ,p_vmr_attribute18                in  varchar2  default null
  ,p_vmr_attribute19                in  varchar2  default null
  ,p_vmr_attribute20                in  varchar2  default null
  ,p_vmr_attribute21                in  varchar2  default null
  ,p_vmr_attribute22                in  varchar2  default null
  ,p_vmr_attribute23                in  varchar2  default null
  ,p_vmr_attribute24                in  varchar2  default null
  ,p_vmr_attribute25                in  varchar2  default null
  ,p_vmr_attribute26                in  varchar2  default null
  ,p_vmr_attribute27                in  varchar2  default null
  ,p_vmr_attribute28                in  varchar2  default null
  ,p_vmr_attribute29                in  varchar2  default null
  ,p_vmr_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_vrbl_mtchg_rt_id ben_vrbl_mtchg_rt_f.vrbl_mtchg_rt_id%TYPE;
  l_effective_end_date ben_vrbl_mtchg_rt_f.effective_end_date%TYPE;
  l_effective_start_date ben_vrbl_mtchg_rt_f.effective_start_date%TYPE;
  l_proc varchar2(72) := g_package||'create_VRBL_MATCHING_RATE';
  l_object_version_number ben_vrbl_mtchg_rt_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_VRBL_MATCHING_RATE;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_VRBL_MATCHING_RATE
    --
    ben_VRBL_MATCHING_RATE_bk1.create_VRBL_MATCHING_RATE_b
      (
       p_no_mx_pct_of_py_num_flag       =>  p_no_mx_pct_of_py_num_flag
      ,p_to_pct_val                     =>  p_to_pct_val
      ,p_no_mx_amt_of_py_num_flag       =>  p_no_mx_amt_of_py_num_flag
      ,p_mx_pct_of_py_num               =>  p_mx_pct_of_py_num
      ,p_no_mx_mtch_amt_flag            =>  p_no_mx_mtch_amt_flag
      ,p_ordr_num                       =>  p_ordr_num
      ,p_pct_val                        =>  p_pct_val
      ,p_mx_mtch_amt                    =>  p_mx_mtch_amt
      ,p_mx_amt_of_py_num               =>  p_mx_amt_of_py_num
      ,p_mn_mtch_amt                    =>  p_mn_mtch_amt
      ,p_mtchg_rt_calc_rl               =>  p_mtchg_rt_calc_rl
      ,p_cntnu_mtch_aftr_max_rl_flag    =>  p_cntnu_mtch_aftr_max_rl_flag
      ,p_from_pct_val                   =>  p_from_pct_val
      ,p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_vmr_attribute_category         =>  p_vmr_attribute_category
      ,p_vmr_attribute1                 =>  p_vmr_attribute1
      ,p_vmr_attribute2                 =>  p_vmr_attribute2
      ,p_vmr_attribute3                 =>  p_vmr_attribute3
      ,p_vmr_attribute4                 =>  p_vmr_attribute4
      ,p_vmr_attribute5                 =>  p_vmr_attribute5
      ,p_vmr_attribute6                 =>  p_vmr_attribute6
      ,p_vmr_attribute7                 =>  p_vmr_attribute7
      ,p_vmr_attribute8                 =>  p_vmr_attribute8
      ,p_vmr_attribute9                 =>  p_vmr_attribute9
      ,p_vmr_attribute10                =>  p_vmr_attribute10
      ,p_vmr_attribute11                =>  p_vmr_attribute11
      ,p_vmr_attribute12                =>  p_vmr_attribute12
      ,p_vmr_attribute13                =>  p_vmr_attribute13
      ,p_vmr_attribute14                =>  p_vmr_attribute14
      ,p_vmr_attribute15                =>  p_vmr_attribute15
      ,p_vmr_attribute16                =>  p_vmr_attribute16
      ,p_vmr_attribute17                =>  p_vmr_attribute17
      ,p_vmr_attribute18                =>  p_vmr_attribute18
      ,p_vmr_attribute19                =>  p_vmr_attribute19
      ,p_vmr_attribute20                =>  p_vmr_attribute20
      ,p_vmr_attribute21                =>  p_vmr_attribute21
      ,p_vmr_attribute22                =>  p_vmr_attribute22
      ,p_vmr_attribute23                =>  p_vmr_attribute23
      ,p_vmr_attribute24                =>  p_vmr_attribute24
      ,p_vmr_attribute25                =>  p_vmr_attribute25
      ,p_vmr_attribute26                =>  p_vmr_attribute26
      ,p_vmr_attribute27                =>  p_vmr_attribute27
      ,p_vmr_attribute28                =>  p_vmr_attribute28
      ,p_vmr_attribute29                =>  p_vmr_attribute29
      ,p_vmr_attribute30                =>  p_vmr_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_VRBL_MATCHING_RATE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_VRBL_MATCHING_RATE
    --
  end;
  --
  ben_vmr_ins.ins
    (
     p_vrbl_mtchg_rt_id              => l_vrbl_mtchg_rt_id
    ,p_effective_end_date            => l_effective_end_date
    ,p_effective_start_date          => l_effective_start_date
    ,p_no_mx_pct_of_py_num_flag      => p_no_mx_pct_of_py_num_flag
    ,p_to_pct_val                    => p_to_pct_val
    ,p_no_mx_amt_of_py_num_flag      => p_no_mx_amt_of_py_num_flag
    ,p_mx_pct_of_py_num              => p_mx_pct_of_py_num
    ,p_no_mx_mtch_amt_flag           => p_no_mx_mtch_amt_flag
    ,p_ordr_num                      => p_ordr_num
    ,p_pct_val                       => p_pct_val
    ,p_mx_mtch_amt                   => p_mx_mtch_amt
    ,p_mx_amt_of_py_num              => p_mx_amt_of_py_num
    ,p_mn_mtch_amt                   => p_mn_mtch_amt
    ,p_mtchg_rt_calc_rl              => p_mtchg_rt_calc_rl
    ,p_cntnu_mtch_aftr_max_rl_flag   => p_cntnu_mtch_aftr_max_rl_flag
    ,p_from_pct_val                  => p_from_pct_val
    ,p_vrbl_rt_prfl_id               => p_vrbl_rt_prfl_id
    ,p_business_group_id             => p_business_group_id
    ,p_vmr_attribute_category        => p_vmr_attribute_category
    ,p_vmr_attribute1                => p_vmr_attribute1
    ,p_vmr_attribute2                => p_vmr_attribute2
    ,p_vmr_attribute3                => p_vmr_attribute3
    ,p_vmr_attribute4                => p_vmr_attribute4
    ,p_vmr_attribute5                => p_vmr_attribute5
    ,p_vmr_attribute6                => p_vmr_attribute6
    ,p_vmr_attribute7                => p_vmr_attribute7
    ,p_vmr_attribute8                => p_vmr_attribute8
    ,p_vmr_attribute9                => p_vmr_attribute9
    ,p_vmr_attribute10               => p_vmr_attribute10
    ,p_vmr_attribute11               => p_vmr_attribute11
    ,p_vmr_attribute12               => p_vmr_attribute12
    ,p_vmr_attribute13               => p_vmr_attribute13
    ,p_vmr_attribute14               => p_vmr_attribute14
    ,p_vmr_attribute15               => p_vmr_attribute15
    ,p_vmr_attribute16               => p_vmr_attribute16
    ,p_vmr_attribute17               => p_vmr_attribute17
    ,p_vmr_attribute18               => p_vmr_attribute18
    ,p_vmr_attribute19               => p_vmr_attribute19
    ,p_vmr_attribute20               => p_vmr_attribute20
    ,p_vmr_attribute21               => p_vmr_attribute21
    ,p_vmr_attribute22               => p_vmr_attribute22
    ,p_vmr_attribute23               => p_vmr_attribute23
    ,p_vmr_attribute24               => p_vmr_attribute24
    ,p_vmr_attribute25               => p_vmr_attribute25
    ,p_vmr_attribute26               => p_vmr_attribute26
    ,p_vmr_attribute27               => p_vmr_attribute27
    ,p_vmr_attribute28               => p_vmr_attribute28
    ,p_vmr_attribute29               => p_vmr_attribute29
    ,p_vmr_attribute30               => p_vmr_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_VRBL_MATCHING_RATE
    --
    ben_VRBL_MATCHING_RATE_bk1.create_VRBL_MATCHING_RATE_a
      (
       p_vrbl_mtchg_rt_id               =>  l_vrbl_mtchg_rt_id
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_no_mx_pct_of_py_num_flag       =>  p_no_mx_pct_of_py_num_flag
      ,p_to_pct_val                     =>  p_to_pct_val
      ,p_no_mx_amt_of_py_num_flag       =>  p_no_mx_amt_of_py_num_flag
      ,p_mx_pct_of_py_num               =>  p_mx_pct_of_py_num
      ,p_no_mx_mtch_amt_flag            =>  p_no_mx_mtch_amt_flag
      ,p_ordr_num                       =>  p_ordr_num
      ,p_pct_val                        =>  p_pct_val
      ,p_mx_mtch_amt                    =>  p_mx_mtch_amt
      ,p_mx_amt_of_py_num               =>  p_mx_amt_of_py_num
      ,p_mn_mtch_amt                    =>  p_mn_mtch_amt
      ,p_mtchg_rt_calc_rl               =>  p_mtchg_rt_calc_rl
      ,p_cntnu_mtch_aftr_max_rl_flag    =>  p_cntnu_mtch_aftr_max_rl_flag
      ,p_from_pct_val                   =>  p_from_pct_val
      ,p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_vmr_attribute_category         =>  p_vmr_attribute_category
      ,p_vmr_attribute1                 =>  p_vmr_attribute1
      ,p_vmr_attribute2                 =>  p_vmr_attribute2
      ,p_vmr_attribute3                 =>  p_vmr_attribute3
      ,p_vmr_attribute4                 =>  p_vmr_attribute4
      ,p_vmr_attribute5                 =>  p_vmr_attribute5
      ,p_vmr_attribute6                 =>  p_vmr_attribute6
      ,p_vmr_attribute7                 =>  p_vmr_attribute7
      ,p_vmr_attribute8                 =>  p_vmr_attribute8
      ,p_vmr_attribute9                 =>  p_vmr_attribute9
      ,p_vmr_attribute10                =>  p_vmr_attribute10
      ,p_vmr_attribute11                =>  p_vmr_attribute11
      ,p_vmr_attribute12                =>  p_vmr_attribute12
      ,p_vmr_attribute13                =>  p_vmr_attribute13
      ,p_vmr_attribute14                =>  p_vmr_attribute14
      ,p_vmr_attribute15                =>  p_vmr_attribute15
      ,p_vmr_attribute16                =>  p_vmr_attribute16
      ,p_vmr_attribute17                =>  p_vmr_attribute17
      ,p_vmr_attribute18                =>  p_vmr_attribute18
      ,p_vmr_attribute19                =>  p_vmr_attribute19
      ,p_vmr_attribute20                =>  p_vmr_attribute20
      ,p_vmr_attribute21                =>  p_vmr_attribute21
      ,p_vmr_attribute22                =>  p_vmr_attribute22
      ,p_vmr_attribute23                =>  p_vmr_attribute23
      ,p_vmr_attribute24                =>  p_vmr_attribute24
      ,p_vmr_attribute25                =>  p_vmr_attribute25
      ,p_vmr_attribute26                =>  p_vmr_attribute26
      ,p_vmr_attribute27                =>  p_vmr_attribute27
      ,p_vmr_attribute28                =>  p_vmr_attribute28
      ,p_vmr_attribute29                =>  p_vmr_attribute29
      ,p_vmr_attribute30                =>  p_vmr_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_VRBL_MATCHING_RATE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_VRBL_MATCHING_RATE
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
  p_vrbl_mtchg_rt_id := l_vrbl_mtchg_rt_id;
  p_effective_end_date := l_effective_end_date;
  p_effective_start_date := l_effective_start_date;
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
    ROLLBACK TO create_VRBL_MATCHING_RATE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_vrbl_mtchg_rt_id := null;
    p_effective_end_date := null;
    p_effective_start_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_VRBL_MATCHING_RATE;
    raise;
    --
end create_VRBL_MATCHING_RATE;
-- ----------------------------------------------------------------------------
-- |------------------------< update_VRBL_MATCHING_RATE >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_VRBL_MATCHING_RATE
  (p_validate                       in  boolean   default false
  ,p_vrbl_mtchg_rt_id               in  number
  ,p_effective_end_date             out nocopy date
  ,p_effective_start_date           out nocopy date
  ,p_no_mx_pct_of_py_num_flag       in  varchar2  default hr_api.g_varchar2
  ,p_to_pct_val                     in  number    default hr_api.g_number
  ,p_no_mx_amt_of_py_num_flag       in  varchar2  default hr_api.g_varchar2
  ,p_mx_pct_of_py_num               in  number    default hr_api.g_number
  ,p_no_mx_mtch_amt_flag            in  varchar2  default hr_api.g_varchar2
  ,p_ordr_num                       in  number    default hr_api.g_number
  ,p_pct_val                        in  number    default hr_api.g_number
  ,p_mx_mtch_amt                    in  number    default hr_api.g_number
  ,p_mx_amt_of_py_num               in  number    default hr_api.g_number
  ,p_mn_mtch_amt                    in  number    default hr_api.g_number
  ,p_mtchg_rt_calc_rl               in  number    default hr_api.g_number
  ,p_cntnu_mtch_aftr_max_rl_flag    in  varchar2  default hr_api.g_varchar2
  ,p_from_pct_val                   in  number    default hr_api.g_number
  ,p_vrbl_rt_prfl_id                in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_vmr_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_vmr_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_VRBL_MATCHING_RATE';
  l_object_version_number ben_vrbl_mtchg_rt_f.object_version_number%TYPE;
  l_effective_end_date ben_vrbl_mtchg_rt_f.effective_end_date%TYPE;
  l_effective_start_date ben_vrbl_mtchg_rt_f.effective_start_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_VRBL_MATCHING_RATE;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_VRBL_MATCHING_RATE
    --
    ben_VRBL_MATCHING_RATE_bk2.update_VRBL_MATCHING_RATE_b
      (
       p_vrbl_mtchg_rt_id               =>  p_vrbl_mtchg_rt_id
      ,p_no_mx_pct_of_py_num_flag       =>  p_no_mx_pct_of_py_num_flag
      ,p_to_pct_val                     =>  p_to_pct_val
      ,p_no_mx_amt_of_py_num_flag       =>  p_no_mx_amt_of_py_num_flag
      ,p_mx_pct_of_py_num               =>  p_mx_pct_of_py_num
      ,p_no_mx_mtch_amt_flag            =>  p_no_mx_mtch_amt_flag
      ,p_ordr_num                       =>  p_ordr_num
      ,p_pct_val                        =>  p_pct_val
      ,p_mx_mtch_amt                    =>  p_mx_mtch_amt
      ,p_mx_amt_of_py_num               =>  p_mx_amt_of_py_num
      ,p_mn_mtch_amt                    =>  p_mn_mtch_amt
      ,p_mtchg_rt_calc_rl               =>  p_mtchg_rt_calc_rl
      ,p_cntnu_mtch_aftr_max_rl_flag    =>  p_cntnu_mtch_aftr_max_rl_flag
      ,p_from_pct_val                   =>  p_from_pct_val
      ,p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_vmr_attribute_category         =>  p_vmr_attribute_category
      ,p_vmr_attribute1                 =>  p_vmr_attribute1
      ,p_vmr_attribute2                 =>  p_vmr_attribute2
      ,p_vmr_attribute3                 =>  p_vmr_attribute3
      ,p_vmr_attribute4                 =>  p_vmr_attribute4
      ,p_vmr_attribute5                 =>  p_vmr_attribute5
      ,p_vmr_attribute6                 =>  p_vmr_attribute6
      ,p_vmr_attribute7                 =>  p_vmr_attribute7
      ,p_vmr_attribute8                 =>  p_vmr_attribute8
      ,p_vmr_attribute9                 =>  p_vmr_attribute9
      ,p_vmr_attribute10                =>  p_vmr_attribute10
      ,p_vmr_attribute11                =>  p_vmr_attribute11
      ,p_vmr_attribute12                =>  p_vmr_attribute12
      ,p_vmr_attribute13                =>  p_vmr_attribute13
      ,p_vmr_attribute14                =>  p_vmr_attribute14
      ,p_vmr_attribute15                =>  p_vmr_attribute15
      ,p_vmr_attribute16                =>  p_vmr_attribute16
      ,p_vmr_attribute17                =>  p_vmr_attribute17
      ,p_vmr_attribute18                =>  p_vmr_attribute18
      ,p_vmr_attribute19                =>  p_vmr_attribute19
      ,p_vmr_attribute20                =>  p_vmr_attribute20
      ,p_vmr_attribute21                =>  p_vmr_attribute21
      ,p_vmr_attribute22                =>  p_vmr_attribute22
      ,p_vmr_attribute23                =>  p_vmr_attribute23
      ,p_vmr_attribute24                =>  p_vmr_attribute24
      ,p_vmr_attribute25                =>  p_vmr_attribute25
      ,p_vmr_attribute26                =>  p_vmr_attribute26
      ,p_vmr_attribute27                =>  p_vmr_attribute27
      ,p_vmr_attribute28                =>  p_vmr_attribute28
      ,p_vmr_attribute29                =>  p_vmr_attribute29
      ,p_vmr_attribute30                =>  p_vmr_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_VRBL_MATCHING_RATE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_VRBL_MATCHING_RATE
    --
  end;
  --
  ben_vmr_upd.upd
    (
     p_vrbl_mtchg_rt_id              => p_vrbl_mtchg_rt_id
    ,p_effective_end_date            => l_effective_end_date
    ,p_effective_start_date          => l_effective_start_date
    ,p_no_mx_pct_of_py_num_flag      => p_no_mx_pct_of_py_num_flag
    ,p_to_pct_val                    => p_to_pct_val
    ,p_no_mx_amt_of_py_num_flag      => p_no_mx_amt_of_py_num_flag
    ,p_mx_pct_of_py_num              => p_mx_pct_of_py_num
    ,p_no_mx_mtch_amt_flag           => p_no_mx_mtch_amt_flag
    ,p_ordr_num                      => p_ordr_num
    ,p_pct_val                       => p_pct_val
    ,p_mx_mtch_amt                   => p_mx_mtch_amt
    ,p_mx_amt_of_py_num              => p_mx_amt_of_py_num
    ,p_mn_mtch_amt                   => p_mn_mtch_amt
    ,p_mtchg_rt_calc_rl              => p_mtchg_rt_calc_rl
    ,p_cntnu_mtch_aftr_max_rl_flag   => p_cntnu_mtch_aftr_max_rl_flag
    ,p_from_pct_val                  => p_from_pct_val
    ,p_vrbl_rt_prfl_id               => p_vrbl_rt_prfl_id
    ,p_business_group_id             => p_business_group_id
    ,p_vmr_attribute_category        => p_vmr_attribute_category
    ,p_vmr_attribute1                => p_vmr_attribute1
    ,p_vmr_attribute2                => p_vmr_attribute2
    ,p_vmr_attribute3                => p_vmr_attribute3
    ,p_vmr_attribute4                => p_vmr_attribute4
    ,p_vmr_attribute5                => p_vmr_attribute5
    ,p_vmr_attribute6                => p_vmr_attribute6
    ,p_vmr_attribute7                => p_vmr_attribute7
    ,p_vmr_attribute8                => p_vmr_attribute8
    ,p_vmr_attribute9                => p_vmr_attribute9
    ,p_vmr_attribute10               => p_vmr_attribute10
    ,p_vmr_attribute11               => p_vmr_attribute11
    ,p_vmr_attribute12               => p_vmr_attribute12
    ,p_vmr_attribute13               => p_vmr_attribute13
    ,p_vmr_attribute14               => p_vmr_attribute14
    ,p_vmr_attribute15               => p_vmr_attribute15
    ,p_vmr_attribute16               => p_vmr_attribute16
    ,p_vmr_attribute17               => p_vmr_attribute17
    ,p_vmr_attribute18               => p_vmr_attribute18
    ,p_vmr_attribute19               => p_vmr_attribute19
    ,p_vmr_attribute20               => p_vmr_attribute20
    ,p_vmr_attribute21               => p_vmr_attribute21
    ,p_vmr_attribute22               => p_vmr_attribute22
    ,p_vmr_attribute23               => p_vmr_attribute23
    ,p_vmr_attribute24               => p_vmr_attribute24
    ,p_vmr_attribute25               => p_vmr_attribute25
    ,p_vmr_attribute26               => p_vmr_attribute26
    ,p_vmr_attribute27               => p_vmr_attribute27
    ,p_vmr_attribute28               => p_vmr_attribute28
    ,p_vmr_attribute29               => p_vmr_attribute29
    ,p_vmr_attribute30               => p_vmr_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_VRBL_MATCHING_RATE
    --
    ben_VRBL_MATCHING_RATE_bk2.update_VRBL_MATCHING_RATE_a
      (
       p_vrbl_mtchg_rt_id               =>  p_vrbl_mtchg_rt_id
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_no_mx_pct_of_py_num_flag       =>  p_no_mx_pct_of_py_num_flag
      ,p_to_pct_val                     =>  p_to_pct_val
      ,p_no_mx_amt_of_py_num_flag       =>  p_no_mx_amt_of_py_num_flag
      ,p_mx_pct_of_py_num               =>  p_mx_pct_of_py_num
      ,p_no_mx_mtch_amt_flag            =>  p_no_mx_mtch_amt_flag
      ,p_ordr_num                       =>  p_ordr_num
      ,p_pct_val                        =>  p_pct_val
      ,p_mx_mtch_amt                    =>  p_mx_mtch_amt
      ,p_mx_amt_of_py_num               =>  p_mx_amt_of_py_num
      ,p_mn_mtch_amt                    =>  p_mn_mtch_amt
      ,p_mtchg_rt_calc_rl               =>  p_mtchg_rt_calc_rl
      ,p_cntnu_mtch_aftr_max_rl_flag    =>  p_cntnu_mtch_aftr_max_rl_flag
      ,p_from_pct_val                   =>  p_from_pct_val
      ,p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_vmr_attribute_category         =>  p_vmr_attribute_category
      ,p_vmr_attribute1                 =>  p_vmr_attribute1
      ,p_vmr_attribute2                 =>  p_vmr_attribute2
      ,p_vmr_attribute3                 =>  p_vmr_attribute3
      ,p_vmr_attribute4                 =>  p_vmr_attribute4
      ,p_vmr_attribute5                 =>  p_vmr_attribute5
      ,p_vmr_attribute6                 =>  p_vmr_attribute6
      ,p_vmr_attribute7                 =>  p_vmr_attribute7
      ,p_vmr_attribute8                 =>  p_vmr_attribute8
      ,p_vmr_attribute9                 =>  p_vmr_attribute9
      ,p_vmr_attribute10                =>  p_vmr_attribute10
      ,p_vmr_attribute11                =>  p_vmr_attribute11
      ,p_vmr_attribute12                =>  p_vmr_attribute12
      ,p_vmr_attribute13                =>  p_vmr_attribute13
      ,p_vmr_attribute14                =>  p_vmr_attribute14
      ,p_vmr_attribute15                =>  p_vmr_attribute15
      ,p_vmr_attribute16                =>  p_vmr_attribute16
      ,p_vmr_attribute17                =>  p_vmr_attribute17
      ,p_vmr_attribute18                =>  p_vmr_attribute18
      ,p_vmr_attribute19                =>  p_vmr_attribute19
      ,p_vmr_attribute20                =>  p_vmr_attribute20
      ,p_vmr_attribute21                =>  p_vmr_attribute21
      ,p_vmr_attribute22                =>  p_vmr_attribute22
      ,p_vmr_attribute23                =>  p_vmr_attribute23
      ,p_vmr_attribute24                =>  p_vmr_attribute24
      ,p_vmr_attribute25                =>  p_vmr_attribute25
      ,p_vmr_attribute26                =>  p_vmr_attribute26
      ,p_vmr_attribute27                =>  p_vmr_attribute27
      ,p_vmr_attribute28                =>  p_vmr_attribute28
      ,p_vmr_attribute29                =>  p_vmr_attribute29
      ,p_vmr_attribute30                =>  p_vmr_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_VRBL_MATCHING_RATE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_VRBL_MATCHING_RATE
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
  p_effective_end_date := l_effective_end_date;
  p_effective_start_date := l_effective_start_date;
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
    ROLLBACK TO update_VRBL_MATCHING_RATE;
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
    ROLLBACK TO update_VRBL_MATCHING_RATE;
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;

    raise;
    --
end update_VRBL_MATCHING_RATE;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_VRBL_MATCHING_RATE >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_VRBL_MATCHING_RATE
  (p_validate                       in  boolean  default false
  ,p_vrbl_mtchg_rt_id               in  number
  ,p_effective_end_date             out nocopy date
  ,p_effective_start_date           out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_VRBL_MATCHING_RATE';
  l_object_version_number ben_vrbl_mtchg_rt_f.object_version_number%TYPE;
  l_effective_end_date ben_vrbl_mtchg_rt_f.effective_end_date%TYPE;
  l_effective_start_date ben_vrbl_mtchg_rt_f.effective_start_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_VRBL_MATCHING_RATE;
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
    -- Start of API User Hook for the before hook of delete_VRBL_MATCHING_RATE
    --
    ben_VRBL_MATCHING_RATE_bk3.delete_VRBL_MATCHING_RATE_b
      (
       p_vrbl_mtchg_rt_id               =>  p_vrbl_mtchg_rt_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_VRBL_MATCHING_RATE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_VRBL_MATCHING_RATE
    --
  end;
  --
  ben_vmr_del.del
    (
     p_vrbl_mtchg_rt_id              => p_vrbl_mtchg_rt_id
    ,p_effective_end_date            => l_effective_end_date
    ,p_effective_start_date          => l_effective_start_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_VRBL_MATCHING_RATE
    --
    ben_VRBL_MATCHING_RATE_bk3.delete_VRBL_MATCHING_RATE_a
      (
       p_vrbl_mtchg_rt_id               =>  p_vrbl_mtchg_rt_id
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_VRBL_MATCHING_RATE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_VRBL_MATCHING_RATE
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
    ROLLBACK TO delete_VRBL_MATCHING_RATE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_end_date := null;
    p_effective_start_date := null;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_VRBL_MATCHING_RATE;
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;

    raise;
    --
end delete_VRBL_MATCHING_RATE;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_vrbl_mtchg_rt_id                   in     number
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
  ben_vmr_shd.lck
    (
      p_vrbl_mtchg_rt_id                 => p_vrbl_mtchg_rt_id
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
end ben_VRBL_MATCHING_RATE_api;

/
