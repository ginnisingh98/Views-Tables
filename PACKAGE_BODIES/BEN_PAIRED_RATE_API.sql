--------------------------------------------------------
--  DDL for Package Body BEN_PAIRED_RATE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PAIRED_RATE_API" as
/* $Header: beprdapi.pkb 115.2 2002/12/16 07:24:00 rpgupta ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_PAIRED_RATE_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_PAIRED_RATE >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_PAIRED_RATE
  (p_validate                       in  boolean   default false
  ,p_paird_rt_id                    out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_use_parnt_ded_sched_flag       in  varchar2  default null
  ,p_asn_on_chc_of_parnt_flag       in  varchar2  default null
  ,p_use_parnt_prtl_mo_cd_flag      in  varchar2  default null
  ,p_alloc_sme_as_parnt_flag        in  varchar2  default null
  ,p_use_parnt_pymt_sched_flag      in  varchar2  default null
  ,p_no_cmbnd_mx_amt_dfnd_flag      in  varchar2  default null
  ,p_cmbnd_mx_amt                   in  number    default null
  ,p_cmbnd_mn_amt                   in  number    default null
  ,p_cmbnd_mx_pct_num               in  number    default null
  ,p_cmbnd_mn_pct_num               in  number    default null
  ,p_no_cmbnd_mn_amt_dfnd_flag      in  varchar2  default null
  ,p_no_cmbnd_mn_pct_dfnd_flag      in  varchar2  default null
  ,p_no_cmbnd_mx_pct_dfnd_flag      in  varchar2  default null
  ,p_parnt_acty_base_rt_id          in  number    default null
  ,p_chld_acty_base_rt_id           in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_prd_attribute_category         in  varchar2  default null
  ,p_prd_attribute1                 in  varchar2  default null
  ,p_prd_attribute2                 in  varchar2  default null
  ,p_prd_attribute3                 in  varchar2  default null
  ,p_prd_attribute4                 in  varchar2  default null
  ,p_prd_attribute5                 in  varchar2  default null
  ,p_prd_attribute6                 in  varchar2  default null
  ,p_prd_attribute7                 in  varchar2  default null
  ,p_prd_attribute8                 in  varchar2  default null
  ,p_prd_attribute9                 in  varchar2  default null
  ,p_prd_attribute10                in  varchar2  default null
  ,p_prd_attribute11                in  varchar2  default null
  ,p_prd_attribute12                in  varchar2  default null
  ,p_prd_attribute13                in  varchar2  default null
  ,p_prd_attribute14                in  varchar2  default null
  ,p_prd_attribute15                in  varchar2  default null
  ,p_prd_attribute16                in  varchar2  default null
  ,p_prd_attribute17                in  varchar2  default null
  ,p_prd_attribute18                in  varchar2  default null
  ,p_prd_attribute19                in  varchar2  default null
  ,p_prd_attribute20                in  varchar2  default null
  ,p_prd_attribute21                in  varchar2  default null
  ,p_prd_attribute22                in  varchar2  default null
  ,p_prd_attribute23                in  varchar2  default null
  ,p_prd_attribute24                in  varchar2  default null
  ,p_prd_attribute25                in  varchar2  default null
  ,p_prd_attribute26                in  varchar2  default null
  ,p_prd_attribute27                in  varchar2  default null
  ,p_prd_attribute28                in  varchar2  default null
  ,p_prd_attribute29                in  varchar2  default null
  ,p_prd_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_paird_rt_id ben_paird_rt_f.paird_rt_id%TYPE;
  l_effective_start_date ben_paird_rt_f.effective_start_date%TYPE;
  l_effective_end_date ben_paird_rt_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_PAIRED_RATE';
  l_object_version_number ben_paird_rt_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_PAIRED_RATE;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_PAIRED_RATE
    --
    ben_PAIRED_RATE_bk1.create_PAIRED_RATE_b
      (
       p_use_parnt_ded_sched_flag       =>  p_use_parnt_ded_sched_flag
      ,p_asn_on_chc_of_parnt_flag       =>  p_asn_on_chc_of_parnt_flag
      ,p_use_parnt_prtl_mo_cd_flag      =>  p_use_parnt_prtl_mo_cd_flag
      ,p_alloc_sme_as_parnt_flag        =>  p_alloc_sme_as_parnt_flag
      ,p_use_parnt_pymt_sched_flag      =>  p_use_parnt_pymt_sched_flag
      ,p_no_cmbnd_mx_amt_dfnd_flag      =>  p_no_cmbnd_mx_amt_dfnd_flag
      ,p_cmbnd_mx_amt                   =>  p_cmbnd_mx_amt
      ,p_cmbnd_mn_amt                   =>  p_cmbnd_mn_amt
      ,p_cmbnd_mx_pct_num               =>  p_cmbnd_mx_pct_num
      ,p_cmbnd_mn_pct_num               =>  p_cmbnd_mn_pct_num
      ,p_no_cmbnd_mn_amt_dfnd_flag      =>  p_no_cmbnd_mn_amt_dfnd_flag
      ,p_no_cmbnd_mn_pct_dfnd_flag      =>  p_no_cmbnd_mn_pct_dfnd_flag
      ,p_no_cmbnd_mx_pct_dfnd_flag      =>  p_no_cmbnd_mx_pct_dfnd_flag
      ,p_parnt_acty_base_rt_id          =>  p_parnt_acty_base_rt_id
      ,p_chld_acty_base_rt_id           =>  p_chld_acty_base_rt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_prd_attribute_category         =>  p_prd_attribute_category
      ,p_prd_attribute1                 =>  p_prd_attribute1
      ,p_prd_attribute2                 =>  p_prd_attribute2
      ,p_prd_attribute3                 =>  p_prd_attribute3
      ,p_prd_attribute4                 =>  p_prd_attribute4
      ,p_prd_attribute5                 =>  p_prd_attribute5
      ,p_prd_attribute6                 =>  p_prd_attribute6
      ,p_prd_attribute7                 =>  p_prd_attribute7
      ,p_prd_attribute8                 =>  p_prd_attribute8
      ,p_prd_attribute9                 =>  p_prd_attribute9
      ,p_prd_attribute10                =>  p_prd_attribute10
      ,p_prd_attribute11                =>  p_prd_attribute11
      ,p_prd_attribute12                =>  p_prd_attribute12
      ,p_prd_attribute13                =>  p_prd_attribute13
      ,p_prd_attribute14                =>  p_prd_attribute14
      ,p_prd_attribute15                =>  p_prd_attribute15
      ,p_prd_attribute16                =>  p_prd_attribute16
      ,p_prd_attribute17                =>  p_prd_attribute17
      ,p_prd_attribute18                =>  p_prd_attribute18
      ,p_prd_attribute19                =>  p_prd_attribute19
      ,p_prd_attribute20                =>  p_prd_attribute20
      ,p_prd_attribute21                =>  p_prd_attribute21
      ,p_prd_attribute22                =>  p_prd_attribute22
      ,p_prd_attribute23                =>  p_prd_attribute23
      ,p_prd_attribute24                =>  p_prd_attribute24
      ,p_prd_attribute25                =>  p_prd_attribute25
      ,p_prd_attribute26                =>  p_prd_attribute26
      ,p_prd_attribute27                =>  p_prd_attribute27
      ,p_prd_attribute28                =>  p_prd_attribute28
      ,p_prd_attribute29                =>  p_prd_attribute29
      ,p_prd_attribute30                =>  p_prd_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_PAIRED_RATE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_PAIRED_RATE
    --
  end;
  --
  ben_prd_ins.ins
    (
     p_paird_rt_id                   => l_paird_rt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_use_parnt_ded_sched_flag      => p_use_parnt_ded_sched_flag
    ,p_asn_on_chc_of_parnt_flag      => p_asn_on_chc_of_parnt_flag
    ,p_use_parnt_prtl_mo_cd_flag     => p_use_parnt_prtl_mo_cd_flag
    ,p_alloc_sme_as_parnt_flag       => p_alloc_sme_as_parnt_flag
    ,p_use_parnt_pymt_sched_flag     => p_use_parnt_pymt_sched_flag
    ,p_no_cmbnd_mx_amt_dfnd_flag     => p_no_cmbnd_mx_amt_dfnd_flag
    ,p_cmbnd_mx_amt                  => p_cmbnd_mx_amt
    ,p_cmbnd_mn_amt                  => p_cmbnd_mn_amt
    ,p_cmbnd_mx_pct_num              => p_cmbnd_mx_pct_num
    ,p_cmbnd_mn_pct_num              => p_cmbnd_mn_pct_num
    ,p_no_cmbnd_mn_amt_dfnd_flag     => p_no_cmbnd_mn_amt_dfnd_flag
    ,p_no_cmbnd_mn_pct_dfnd_flag     => p_no_cmbnd_mn_pct_dfnd_flag
    ,p_no_cmbnd_mx_pct_dfnd_flag     => p_no_cmbnd_mx_pct_dfnd_flag
    ,p_parnt_acty_base_rt_id         => p_parnt_acty_base_rt_id
    ,p_chld_acty_base_rt_id          => p_chld_acty_base_rt_id
    ,p_business_group_id             => p_business_group_id
    ,p_prd_attribute_category        => p_prd_attribute_category
    ,p_prd_attribute1                => p_prd_attribute1
    ,p_prd_attribute2                => p_prd_attribute2
    ,p_prd_attribute3                => p_prd_attribute3
    ,p_prd_attribute4                => p_prd_attribute4
    ,p_prd_attribute5                => p_prd_attribute5
    ,p_prd_attribute6                => p_prd_attribute6
    ,p_prd_attribute7                => p_prd_attribute7
    ,p_prd_attribute8                => p_prd_attribute8
    ,p_prd_attribute9                => p_prd_attribute9
    ,p_prd_attribute10               => p_prd_attribute10
    ,p_prd_attribute11               => p_prd_attribute11
    ,p_prd_attribute12               => p_prd_attribute12
    ,p_prd_attribute13               => p_prd_attribute13
    ,p_prd_attribute14               => p_prd_attribute14
    ,p_prd_attribute15               => p_prd_attribute15
    ,p_prd_attribute16               => p_prd_attribute16
    ,p_prd_attribute17               => p_prd_attribute17
    ,p_prd_attribute18               => p_prd_attribute18
    ,p_prd_attribute19               => p_prd_attribute19
    ,p_prd_attribute20               => p_prd_attribute20
    ,p_prd_attribute21               => p_prd_attribute21
    ,p_prd_attribute22               => p_prd_attribute22
    ,p_prd_attribute23               => p_prd_attribute23
    ,p_prd_attribute24               => p_prd_attribute24
    ,p_prd_attribute25               => p_prd_attribute25
    ,p_prd_attribute26               => p_prd_attribute26
    ,p_prd_attribute27               => p_prd_attribute27
    ,p_prd_attribute28               => p_prd_attribute28
    ,p_prd_attribute29               => p_prd_attribute29
    ,p_prd_attribute30               => p_prd_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_PAIRED_RATE
    --
    ben_PAIRED_RATE_bk1.create_PAIRED_RATE_a
      (
       p_paird_rt_id                    =>  l_paird_rt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_use_parnt_ded_sched_flag       =>  p_use_parnt_ded_sched_flag
      ,p_asn_on_chc_of_parnt_flag       =>  p_asn_on_chc_of_parnt_flag
      ,p_use_parnt_prtl_mo_cd_flag      =>  p_use_parnt_prtl_mo_cd_flag
      ,p_alloc_sme_as_parnt_flag        =>  p_alloc_sme_as_parnt_flag
      ,p_use_parnt_pymt_sched_flag      =>  p_use_parnt_pymt_sched_flag
      ,p_no_cmbnd_mx_amt_dfnd_flag      =>  p_no_cmbnd_mx_amt_dfnd_flag
      ,p_cmbnd_mx_amt                   =>  p_cmbnd_mx_amt
      ,p_cmbnd_mn_amt                   =>  p_cmbnd_mn_amt
      ,p_cmbnd_mx_pct_num               =>  p_cmbnd_mx_pct_num
      ,p_cmbnd_mn_pct_num               =>  p_cmbnd_mn_pct_num
      ,p_no_cmbnd_mn_amt_dfnd_flag      =>  p_no_cmbnd_mn_amt_dfnd_flag
      ,p_no_cmbnd_mn_pct_dfnd_flag      =>  p_no_cmbnd_mn_pct_dfnd_flag
      ,p_no_cmbnd_mx_pct_dfnd_flag      =>  p_no_cmbnd_mx_pct_dfnd_flag
      ,p_parnt_acty_base_rt_id          =>  p_parnt_acty_base_rt_id
      ,p_chld_acty_base_rt_id           =>  p_chld_acty_base_rt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_prd_attribute_category         =>  p_prd_attribute_category
      ,p_prd_attribute1                 =>  p_prd_attribute1
      ,p_prd_attribute2                 =>  p_prd_attribute2
      ,p_prd_attribute3                 =>  p_prd_attribute3
      ,p_prd_attribute4                 =>  p_prd_attribute4
      ,p_prd_attribute5                 =>  p_prd_attribute5
      ,p_prd_attribute6                 =>  p_prd_attribute6
      ,p_prd_attribute7                 =>  p_prd_attribute7
      ,p_prd_attribute8                 =>  p_prd_attribute8
      ,p_prd_attribute9                 =>  p_prd_attribute9
      ,p_prd_attribute10                =>  p_prd_attribute10
      ,p_prd_attribute11                =>  p_prd_attribute11
      ,p_prd_attribute12                =>  p_prd_attribute12
      ,p_prd_attribute13                =>  p_prd_attribute13
      ,p_prd_attribute14                =>  p_prd_attribute14
      ,p_prd_attribute15                =>  p_prd_attribute15
      ,p_prd_attribute16                =>  p_prd_attribute16
      ,p_prd_attribute17                =>  p_prd_attribute17
      ,p_prd_attribute18                =>  p_prd_attribute18
      ,p_prd_attribute19                =>  p_prd_attribute19
      ,p_prd_attribute20                =>  p_prd_attribute20
      ,p_prd_attribute21                =>  p_prd_attribute21
      ,p_prd_attribute22                =>  p_prd_attribute22
      ,p_prd_attribute23                =>  p_prd_attribute23
      ,p_prd_attribute24                =>  p_prd_attribute24
      ,p_prd_attribute25                =>  p_prd_attribute25
      ,p_prd_attribute26                =>  p_prd_attribute26
      ,p_prd_attribute27                =>  p_prd_attribute27
      ,p_prd_attribute28                =>  p_prd_attribute28
      ,p_prd_attribute29                =>  p_prd_attribute29
      ,p_prd_attribute30                =>  p_prd_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PAIRED_RATE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_PAIRED_RATE
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
  p_paird_rt_id := l_paird_rt_id;
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
    ROLLBACK TO create_PAIRED_RATE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_paird_rt_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_PAIRED_RATE;
    p_paird_rt_id := null; --nocopy change
    p_effective_start_date := null; --nocopy change
    p_effective_end_date := null; --nocopy change
    p_object_version_number  := null; --nocopy change
    raise;
    --
end create_PAIRED_RATE;
-- ----------------------------------------------------------------------------
-- |------------------------< update_PAIRED_RATE >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_PAIRED_RATE
  (p_validate                       in  boolean   default false
  ,p_paird_rt_id                    in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_use_parnt_ded_sched_flag       in  varchar2  default hr_api.g_varchar2
  ,p_asn_on_chc_of_parnt_flag       in  varchar2  default hr_api.g_varchar2
  ,p_use_parnt_prtl_mo_cd_flag      in  varchar2  default hr_api.g_varchar2
  ,p_alloc_sme_as_parnt_flag        in  varchar2  default hr_api.g_varchar2
  ,p_use_parnt_pymt_sched_flag      in  varchar2  default hr_api.g_varchar2
  ,p_no_cmbnd_mx_amt_dfnd_flag      in  varchar2  default hr_api.g_varchar2
  ,p_cmbnd_mx_amt                   in  number    default hr_api.g_number
  ,p_cmbnd_mn_amt                   in  number    default hr_api.g_number
  ,p_cmbnd_mx_pct_num               in  number    default hr_api.g_number
  ,p_cmbnd_mn_pct_num               in  number    default hr_api.g_number
  ,p_no_cmbnd_mn_amt_dfnd_flag      in  varchar2  default hr_api.g_varchar2
  ,p_no_cmbnd_mn_pct_dfnd_flag      in  varchar2  default hr_api.g_varchar2
  ,p_no_cmbnd_mx_pct_dfnd_flag      in  varchar2  default hr_api.g_varchar2
  ,p_parnt_acty_base_rt_id          in  number    default hr_api.g_number
  ,p_chld_acty_base_rt_id           in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_prd_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_prd_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_prd_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_prd_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_prd_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_prd_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_prd_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_prd_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_prd_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_prd_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_prd_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_prd_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_prd_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_prd_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_prd_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_prd_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_prd_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_prd_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_prd_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_prd_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_prd_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_prd_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_prd_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_prd_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_prd_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_prd_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_prd_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_prd_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_prd_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_prd_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_prd_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_PAIRED_RATE';
  l_object_version_number ben_paird_rt_f.object_version_number%TYPE;
  l_effective_start_date ben_paird_rt_f.effective_start_date%TYPE;
  l_effective_end_date ben_paird_rt_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_PAIRED_RATE;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_PAIRED_RATE
    --
    ben_PAIRED_RATE_bk2.update_PAIRED_RATE_b
      (
       p_paird_rt_id                    =>  p_paird_rt_id
      ,p_use_parnt_ded_sched_flag       =>  p_use_parnt_ded_sched_flag
      ,p_asn_on_chc_of_parnt_flag       =>  p_asn_on_chc_of_parnt_flag
      ,p_use_parnt_prtl_mo_cd_flag      =>  p_use_parnt_prtl_mo_cd_flag
      ,p_alloc_sme_as_parnt_flag        =>  p_alloc_sme_as_parnt_flag
      ,p_use_parnt_pymt_sched_flag      =>  p_use_parnt_pymt_sched_flag
      ,p_no_cmbnd_mx_amt_dfnd_flag      =>  p_no_cmbnd_mx_amt_dfnd_flag
      ,p_cmbnd_mx_amt                   =>  p_cmbnd_mx_amt
      ,p_cmbnd_mn_amt                   =>  p_cmbnd_mn_amt
      ,p_cmbnd_mx_pct_num               =>  p_cmbnd_mx_pct_num
      ,p_cmbnd_mn_pct_num               =>  p_cmbnd_mn_pct_num
      ,p_no_cmbnd_mn_amt_dfnd_flag      =>  p_no_cmbnd_mn_amt_dfnd_flag
      ,p_no_cmbnd_mn_pct_dfnd_flag      =>  p_no_cmbnd_mn_pct_dfnd_flag
      ,p_no_cmbnd_mx_pct_dfnd_flag      =>  p_no_cmbnd_mx_pct_dfnd_flag
      ,p_parnt_acty_base_rt_id          =>  p_parnt_acty_base_rt_id
      ,p_chld_acty_base_rt_id           =>  p_chld_acty_base_rt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_prd_attribute_category         =>  p_prd_attribute_category
      ,p_prd_attribute1                 =>  p_prd_attribute1
      ,p_prd_attribute2                 =>  p_prd_attribute2
      ,p_prd_attribute3                 =>  p_prd_attribute3
      ,p_prd_attribute4                 =>  p_prd_attribute4
      ,p_prd_attribute5                 =>  p_prd_attribute5
      ,p_prd_attribute6                 =>  p_prd_attribute6
      ,p_prd_attribute7                 =>  p_prd_attribute7
      ,p_prd_attribute8                 =>  p_prd_attribute8
      ,p_prd_attribute9                 =>  p_prd_attribute9
      ,p_prd_attribute10                =>  p_prd_attribute10
      ,p_prd_attribute11                =>  p_prd_attribute11
      ,p_prd_attribute12                =>  p_prd_attribute12
      ,p_prd_attribute13                =>  p_prd_attribute13
      ,p_prd_attribute14                =>  p_prd_attribute14
      ,p_prd_attribute15                =>  p_prd_attribute15
      ,p_prd_attribute16                =>  p_prd_attribute16
      ,p_prd_attribute17                =>  p_prd_attribute17
      ,p_prd_attribute18                =>  p_prd_attribute18
      ,p_prd_attribute19                =>  p_prd_attribute19
      ,p_prd_attribute20                =>  p_prd_attribute20
      ,p_prd_attribute21                =>  p_prd_attribute21
      ,p_prd_attribute22                =>  p_prd_attribute22
      ,p_prd_attribute23                =>  p_prd_attribute23
      ,p_prd_attribute24                =>  p_prd_attribute24
      ,p_prd_attribute25                =>  p_prd_attribute25
      ,p_prd_attribute26                =>  p_prd_attribute26
      ,p_prd_attribute27                =>  p_prd_attribute27
      ,p_prd_attribute28                =>  p_prd_attribute28
      ,p_prd_attribute29                =>  p_prd_attribute29
      ,p_prd_attribute30                =>  p_prd_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PAIRED_RATE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_PAIRED_RATE
    --
  end;
  --
  ben_prd_upd.upd
    (
     p_paird_rt_id                   => p_paird_rt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_use_parnt_ded_sched_flag      => p_use_parnt_ded_sched_flag
    ,p_asn_on_chc_of_parnt_flag      => p_asn_on_chc_of_parnt_flag
    ,p_use_parnt_prtl_mo_cd_flag     => p_use_parnt_prtl_mo_cd_flag
    ,p_alloc_sme_as_parnt_flag       => p_alloc_sme_as_parnt_flag
    ,p_use_parnt_pymt_sched_flag     => p_use_parnt_pymt_sched_flag
    ,p_no_cmbnd_mx_amt_dfnd_flag     => p_no_cmbnd_mx_amt_dfnd_flag
    ,p_cmbnd_mx_amt                  => p_cmbnd_mx_amt
    ,p_cmbnd_mn_amt                  => p_cmbnd_mn_amt
    ,p_cmbnd_mx_pct_num              => p_cmbnd_mx_pct_num
    ,p_cmbnd_mn_pct_num              => p_cmbnd_mn_pct_num
    ,p_no_cmbnd_mn_amt_dfnd_flag     => p_no_cmbnd_mn_amt_dfnd_flag
    ,p_no_cmbnd_mn_pct_dfnd_flag     => p_no_cmbnd_mn_pct_dfnd_flag
    ,p_no_cmbnd_mx_pct_dfnd_flag     => p_no_cmbnd_mx_pct_dfnd_flag
    ,p_parnt_acty_base_rt_id         => p_parnt_acty_base_rt_id
    ,p_chld_acty_base_rt_id          => p_chld_acty_base_rt_id
    ,p_business_group_id             => p_business_group_id
    ,p_prd_attribute_category        => p_prd_attribute_category
    ,p_prd_attribute1                => p_prd_attribute1
    ,p_prd_attribute2                => p_prd_attribute2
    ,p_prd_attribute3                => p_prd_attribute3
    ,p_prd_attribute4                => p_prd_attribute4
    ,p_prd_attribute5                => p_prd_attribute5
    ,p_prd_attribute6                => p_prd_attribute6
    ,p_prd_attribute7                => p_prd_attribute7
    ,p_prd_attribute8                => p_prd_attribute8
    ,p_prd_attribute9                => p_prd_attribute9
    ,p_prd_attribute10               => p_prd_attribute10
    ,p_prd_attribute11               => p_prd_attribute11
    ,p_prd_attribute12               => p_prd_attribute12
    ,p_prd_attribute13               => p_prd_attribute13
    ,p_prd_attribute14               => p_prd_attribute14
    ,p_prd_attribute15               => p_prd_attribute15
    ,p_prd_attribute16               => p_prd_attribute16
    ,p_prd_attribute17               => p_prd_attribute17
    ,p_prd_attribute18               => p_prd_attribute18
    ,p_prd_attribute19               => p_prd_attribute19
    ,p_prd_attribute20               => p_prd_attribute20
    ,p_prd_attribute21               => p_prd_attribute21
    ,p_prd_attribute22               => p_prd_attribute22
    ,p_prd_attribute23               => p_prd_attribute23
    ,p_prd_attribute24               => p_prd_attribute24
    ,p_prd_attribute25               => p_prd_attribute25
    ,p_prd_attribute26               => p_prd_attribute26
    ,p_prd_attribute27               => p_prd_attribute27
    ,p_prd_attribute28               => p_prd_attribute28
    ,p_prd_attribute29               => p_prd_attribute29
    ,p_prd_attribute30               => p_prd_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_PAIRED_RATE
    --
    ben_PAIRED_RATE_bk2.update_PAIRED_RATE_a
      (
       p_paird_rt_id                    =>  p_paird_rt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_use_parnt_ded_sched_flag       =>  p_use_parnt_ded_sched_flag
      ,p_asn_on_chc_of_parnt_flag       =>  p_asn_on_chc_of_parnt_flag
      ,p_use_parnt_prtl_mo_cd_flag      =>  p_use_parnt_prtl_mo_cd_flag
      ,p_alloc_sme_as_parnt_flag        =>  p_alloc_sme_as_parnt_flag
      ,p_use_parnt_pymt_sched_flag      =>  p_use_parnt_pymt_sched_flag
      ,p_no_cmbnd_mx_amt_dfnd_flag      =>  p_no_cmbnd_mx_amt_dfnd_flag
      ,p_cmbnd_mx_amt                   =>  p_cmbnd_mx_amt
      ,p_cmbnd_mn_amt                   =>  p_cmbnd_mn_amt
      ,p_cmbnd_mx_pct_num               =>  p_cmbnd_mx_pct_num
      ,p_cmbnd_mn_pct_num               =>  p_cmbnd_mn_pct_num
      ,p_no_cmbnd_mn_amt_dfnd_flag      =>  p_no_cmbnd_mn_amt_dfnd_flag
      ,p_no_cmbnd_mn_pct_dfnd_flag      =>  p_no_cmbnd_mn_pct_dfnd_flag
      ,p_no_cmbnd_mx_pct_dfnd_flag      =>  p_no_cmbnd_mx_pct_dfnd_flag
      ,p_parnt_acty_base_rt_id          =>  p_parnt_acty_base_rt_id
      ,p_chld_acty_base_rt_id           =>  p_chld_acty_base_rt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_prd_attribute_category         =>  p_prd_attribute_category
      ,p_prd_attribute1                 =>  p_prd_attribute1
      ,p_prd_attribute2                 =>  p_prd_attribute2
      ,p_prd_attribute3                 =>  p_prd_attribute3
      ,p_prd_attribute4                 =>  p_prd_attribute4
      ,p_prd_attribute5                 =>  p_prd_attribute5
      ,p_prd_attribute6                 =>  p_prd_attribute6
      ,p_prd_attribute7                 =>  p_prd_attribute7
      ,p_prd_attribute8                 =>  p_prd_attribute8
      ,p_prd_attribute9                 =>  p_prd_attribute9
      ,p_prd_attribute10                =>  p_prd_attribute10
      ,p_prd_attribute11                =>  p_prd_attribute11
      ,p_prd_attribute12                =>  p_prd_attribute12
      ,p_prd_attribute13                =>  p_prd_attribute13
      ,p_prd_attribute14                =>  p_prd_attribute14
      ,p_prd_attribute15                =>  p_prd_attribute15
      ,p_prd_attribute16                =>  p_prd_attribute16
      ,p_prd_attribute17                =>  p_prd_attribute17
      ,p_prd_attribute18                =>  p_prd_attribute18
      ,p_prd_attribute19                =>  p_prd_attribute19
      ,p_prd_attribute20                =>  p_prd_attribute20
      ,p_prd_attribute21                =>  p_prd_attribute21
      ,p_prd_attribute22                =>  p_prd_attribute22
      ,p_prd_attribute23                =>  p_prd_attribute23
      ,p_prd_attribute24                =>  p_prd_attribute24
      ,p_prd_attribute25                =>  p_prd_attribute25
      ,p_prd_attribute26                =>  p_prd_attribute26
      ,p_prd_attribute27                =>  p_prd_attribute27
      ,p_prd_attribute28                =>  p_prd_attribute28
      ,p_prd_attribute29                =>  p_prd_attribute29
      ,p_prd_attribute30                =>  p_prd_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PAIRED_RATE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_PAIRED_RATE
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
    ROLLBACK TO update_PAIRED_RATE;
    p_effective_start_date := null; --nocopy change
    p_effective_end_date := null; --nocopy change
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
    ROLLBACK TO update_PAIRED_RATE;

    p_effective_start_date := null; --nocopy change
    p_effective_end_date := null; --nocopy change
    raise;
    --
end update_PAIRED_RATE;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_PAIRED_RATE >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PAIRED_RATE
  (p_validate                       in  boolean  default false
  ,p_paird_rt_id                    in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_PAIRED_RATE';
  l_object_version_number ben_paird_rt_f.object_version_number%TYPE;
  l_effective_start_date ben_paird_rt_f.effective_start_date%TYPE;
  l_effective_end_date ben_paird_rt_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_PAIRED_RATE;
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
    -- Start of API User Hook for the before hook of delete_PAIRED_RATE
    --
    ben_PAIRED_RATE_bk3.delete_PAIRED_RATE_b
      (
       p_paird_rt_id                    =>  p_paird_rt_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PAIRED_RATE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_PAIRED_RATE
    --
  end;
  --
  ben_prd_del.del
    (
     p_paird_rt_id                   => p_paird_rt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_PAIRED_RATE
    --
    ben_PAIRED_RATE_bk3.delete_PAIRED_RATE_a
      (
       p_paird_rt_id                    =>  p_paird_rt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PAIRED_RATE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_PAIRED_RATE
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
    ROLLBACK TO delete_PAIRED_RATE;
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
    ROLLBACK TO delete_PAIRED_RATE;
    p_effective_start_date := null; --nocopy change
    p_effective_end_date := null; --nocopy change

    raise;
    --
end delete_PAIRED_RATE;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_paird_rt_id                   in     number
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
  ben_prd_shd.lck
    (
      p_paird_rt_id                 => p_paird_rt_id
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
end ben_PAIRED_RATE_api;

/
