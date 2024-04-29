--------------------------------------------------------
--  DDL for Package Body BEN_PRTL_MO_RT_PRTN_VAL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PRTL_MO_RT_PRTN_VAL_API" as
/* $Header: beppvapi.pkb 120.0 2005/05/28 11:01:32 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_Prtl_Mo_Rt_Prtn_Val_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Prtl_Mo_Rt_Prtn_Val >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_Prtl_Mo_Rt_Prtn_Val
  (p_validate                       in  boolean   default false
  ,p_prtl_mo_rt_prtn_val_id         out nocopy number
  ,p_effective_end_date             out nocopy date
  ,p_effective_start_date           out nocopy date
  ,p_acty_base_rt_id                in  number    default null
  ,p_rndg_rl                        in  number    default null
  ,p_rndg_cd                        in  varchar2  default null
  ,p_to_dy_mo_num                   in  number    default null
  ,p_from_dy_mo_num                 in  number    default null
  ,p_pct_val                        in  number    default null
  ,p_strt_r_stp_cvg_cd              in  varchar2  default null
  ,p_prtl_mo_prortn_rl              in  number    default null
  ,p_actl_prem_id                   in  number    default null
  ,p_cvg_amt_calc_mthd_id           in  number    default null
  ,p_num_days_month                 in  number
  ,p_prorate_by_day_to_mon_flag     in  varchar2
  ,p_business_group_id              in  number    default null
  ,p_pmrpv_attribute_category       in  varchar2  default null
  ,p_pmrpv_attribute1               in  varchar2  default null
  ,p_pmrpv_attribute2               in  varchar2  default null
  ,p_pmrpv_attribute3               in  varchar2  default null
  ,p_pmrpv_attribute4               in  varchar2  default null
  ,p_pmrpv_attribute5               in  varchar2  default null
  ,p_pmrpv_attribute6               in  varchar2  default null
  ,p_pmrpv_attribute7               in  varchar2  default null
  ,p_pmrpv_attribute8               in  varchar2  default null
  ,p_pmrpv_attribute9               in  varchar2  default null
  ,p_pmrpv_attribute10              in  varchar2  default null
  ,p_pmrpv_attribute11              in  varchar2  default null
  ,p_pmrpv_attribute12              in  varchar2  default null
  ,p_pmrpv_attribute13              in  varchar2  default null
  ,p_pmrpv_attribute14              in  varchar2  default null
  ,p_pmrpv_attribute15              in  varchar2  default null
  ,p_pmrpv_attribute16              in  varchar2  default null
  ,p_pmrpv_attribute17              in  varchar2  default null
  ,p_pmrpv_attribute18              in  varchar2  default null
  ,p_pmrpv_attribute19              in  varchar2  default null
  ,p_pmrpv_attribute20              in  varchar2  default null
  ,p_pmrpv_attribute21              in  varchar2  default null
  ,p_pmrpv_attribute22              in  varchar2  default null
  ,p_pmrpv_attribute23              in  varchar2  default null
  ,p_pmrpv_attribute24              in  varchar2  default null
  ,p_pmrpv_attribute25              in  varchar2  default null
  ,p_pmrpv_attribute26              in  varchar2  default null
  ,p_pmrpv_attribute27              in  varchar2  default null
  ,p_pmrpv_attribute28              in  varchar2  default null
  ,p_pmrpv_attribute29              in  varchar2  default null
  ,p_pmrpv_attribute30              in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_prtl_mo_rt_prtn_val_id ben_prtl_mo_rt_prtn_val_f.prtl_mo_rt_prtn_val_id%TYPE;
  l_effective_end_date ben_prtl_mo_rt_prtn_val_f.effective_end_date%TYPE;
  l_effective_start_date ben_prtl_mo_rt_prtn_val_f.effective_start_date%TYPE;
  l_proc varchar2(72) := g_package||'create_Prtl_Mo_Rt_Prtn_Val';
  l_object_version_number ben_prtl_mo_rt_prtn_val_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_Prtl_Mo_Rt_Prtn_Val;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_Prtl_Mo_Rt_Prtn_Val
    --
    ben_Prtl_Mo_Rt_Prtn_Val_bk1.create_Prtl_Mo_Rt_Prtn_Val_b
      (
       p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_rndg_rl                        =>  p_rndg_rl
      ,p_rndg_cd                        =>  p_rndg_cd
      ,p_to_dy_mo_num                   =>  p_to_dy_mo_num
      ,p_from_dy_mo_num                 =>  p_from_dy_mo_num
      ,p_pct_val                        =>  p_pct_val
      ,p_strt_r_stp_cvg_cd              =>  p_strt_r_stp_cvg_cd
      ,p_prtl_mo_prortn_rl              =>  p_prtl_mo_prortn_rl
      ,p_actl_prem_id                   =>  p_actl_prem_id
      ,p_cvg_amt_calc_mthd_id           =>  p_cvg_amt_calc_mthd_id
      ,p_num_days_month                 =>  p_num_days_month
      ,p_prorate_by_day_to_mon_flag     =>  p_prorate_by_day_to_mon_flag
      ,p_business_group_id              =>  p_business_group_id
      ,p_pmrpv_attribute_category       =>  p_pmrpv_attribute_category
      ,p_pmrpv_attribute1               =>  p_pmrpv_attribute1
      ,p_pmrpv_attribute2               =>  p_pmrpv_attribute2
      ,p_pmrpv_attribute3               =>  p_pmrpv_attribute3
      ,p_pmrpv_attribute4               =>  p_pmrpv_attribute4
      ,p_pmrpv_attribute5               =>  p_pmrpv_attribute5
      ,p_pmrpv_attribute6               =>  p_pmrpv_attribute6
      ,p_pmrpv_attribute7               =>  p_pmrpv_attribute7
      ,p_pmrpv_attribute8               =>  p_pmrpv_attribute8
      ,p_pmrpv_attribute9               =>  p_pmrpv_attribute9
      ,p_pmrpv_attribute10              =>  p_pmrpv_attribute10
      ,p_pmrpv_attribute11              =>  p_pmrpv_attribute11
      ,p_pmrpv_attribute12              =>  p_pmrpv_attribute12
      ,p_pmrpv_attribute13              =>  p_pmrpv_attribute13
      ,p_pmrpv_attribute14              =>  p_pmrpv_attribute14
      ,p_pmrpv_attribute15              =>  p_pmrpv_attribute15
      ,p_pmrpv_attribute16              =>  p_pmrpv_attribute16
      ,p_pmrpv_attribute17              =>  p_pmrpv_attribute17
      ,p_pmrpv_attribute18              =>  p_pmrpv_attribute18
      ,p_pmrpv_attribute19              =>  p_pmrpv_attribute19
      ,p_pmrpv_attribute20              =>  p_pmrpv_attribute20
      ,p_pmrpv_attribute21              =>  p_pmrpv_attribute21
      ,p_pmrpv_attribute22              =>  p_pmrpv_attribute22
      ,p_pmrpv_attribute23              =>  p_pmrpv_attribute23
      ,p_pmrpv_attribute24              =>  p_pmrpv_attribute24
      ,p_pmrpv_attribute25              =>  p_pmrpv_attribute25
      ,p_pmrpv_attribute26              =>  p_pmrpv_attribute26
      ,p_pmrpv_attribute27              =>  p_pmrpv_attribute27
      ,p_pmrpv_attribute28              =>  p_pmrpv_attribute28
      ,p_pmrpv_attribute29              =>  p_pmrpv_attribute29
      ,p_pmrpv_attribute30              =>  p_pmrpv_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_Prtl_Mo_Rt_Prtn_Val'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_Prtl_Mo_Rt_Prtn_Val
    --
  end;
  --
  ben_ppv_ins.ins
    (
     p_prtl_mo_rt_prtn_val_id        => l_prtl_mo_rt_prtn_val_id
    ,p_effective_end_date            => l_effective_end_date
    ,p_effective_start_date          => l_effective_start_date
    ,p_acty_base_rt_id               => p_acty_base_rt_id
    ,p_rndg_rl                       => p_rndg_rl
    ,p_rndg_cd                       => p_rndg_cd
    ,p_to_dy_mo_num                  => p_to_dy_mo_num
    ,p_from_dy_mo_num                => p_from_dy_mo_num
    ,p_pct_val                       => p_pct_val
    ,p_strt_r_stp_cvg_cd              =>  p_strt_r_stp_cvg_cd
    ,p_prtl_mo_prortn_rl              =>  p_prtl_mo_prortn_rl
    ,p_actl_prem_id                   =>  p_actl_prem_id
    ,p_cvg_amt_calc_mthd_id           =>  p_cvg_amt_calc_mthd_id
    ,p_num_days_month                 =>  p_num_days_month
    ,p_prorate_by_day_to_mon_flag     =>  p_prorate_by_day_to_mon_flag
    ,p_business_group_id             => p_business_group_id
    ,p_pmrpv_attribute_category      => p_pmrpv_attribute_category
    ,p_pmrpv_attribute1              => p_pmrpv_attribute1
    ,p_pmrpv_attribute2              => p_pmrpv_attribute2
    ,p_pmrpv_attribute3              => p_pmrpv_attribute3
    ,p_pmrpv_attribute4              => p_pmrpv_attribute4
    ,p_pmrpv_attribute5              => p_pmrpv_attribute5
    ,p_pmrpv_attribute6              => p_pmrpv_attribute6
    ,p_pmrpv_attribute7              => p_pmrpv_attribute7
    ,p_pmrpv_attribute8              => p_pmrpv_attribute8
    ,p_pmrpv_attribute9              => p_pmrpv_attribute9
    ,p_pmrpv_attribute10             => p_pmrpv_attribute10
    ,p_pmrpv_attribute11             => p_pmrpv_attribute11
    ,p_pmrpv_attribute12             => p_pmrpv_attribute12
    ,p_pmrpv_attribute13             => p_pmrpv_attribute13
    ,p_pmrpv_attribute14             => p_pmrpv_attribute14
    ,p_pmrpv_attribute15             => p_pmrpv_attribute15
    ,p_pmrpv_attribute16             => p_pmrpv_attribute16
    ,p_pmrpv_attribute17             => p_pmrpv_attribute17
    ,p_pmrpv_attribute18             => p_pmrpv_attribute18
    ,p_pmrpv_attribute19             => p_pmrpv_attribute19
    ,p_pmrpv_attribute20             => p_pmrpv_attribute20
    ,p_pmrpv_attribute21             => p_pmrpv_attribute21
    ,p_pmrpv_attribute22             => p_pmrpv_attribute22
    ,p_pmrpv_attribute23             => p_pmrpv_attribute23
    ,p_pmrpv_attribute24             => p_pmrpv_attribute24
    ,p_pmrpv_attribute25             => p_pmrpv_attribute25
    ,p_pmrpv_attribute26             => p_pmrpv_attribute26
    ,p_pmrpv_attribute27             => p_pmrpv_attribute27
    ,p_pmrpv_attribute28             => p_pmrpv_attribute28
    ,p_pmrpv_attribute29             => p_pmrpv_attribute29
    ,p_pmrpv_attribute30             => p_pmrpv_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_Prtl_Mo_Rt_Prtn_Val
    --
    ben_Prtl_Mo_Rt_Prtn_Val_bk1.create_Prtl_Mo_Rt_Prtn_Val_a
      (
       p_prtl_mo_rt_prtn_val_id         =>  l_prtl_mo_rt_prtn_val_id
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_rndg_rl                        =>  p_rndg_rl
      ,p_rndg_cd                        =>  p_rndg_cd
      ,p_to_dy_mo_num                   =>  p_to_dy_mo_num
      ,p_from_dy_mo_num                 =>  p_from_dy_mo_num
      ,p_pct_val                        =>  p_pct_val
    ,p_strt_r_stp_cvg_cd              =>  p_strt_r_stp_cvg_cd
    ,p_prtl_mo_prortn_rl              =>  p_prtl_mo_prortn_rl
    ,p_actl_prem_id                   =>  p_actl_prem_id
    ,p_cvg_amt_calc_mthd_id           =>  p_cvg_amt_calc_mthd_id
      ,p_num_days_month                 =>  p_num_days_month
      ,p_prorate_by_day_to_mon_flag     =>  p_prorate_by_day_to_mon_flag
      ,p_business_group_id              =>  p_business_group_id
      ,p_pmrpv_attribute_category       =>  p_pmrpv_attribute_category
      ,p_pmrpv_attribute1               =>  p_pmrpv_attribute1
      ,p_pmrpv_attribute2               =>  p_pmrpv_attribute2
      ,p_pmrpv_attribute3               =>  p_pmrpv_attribute3
      ,p_pmrpv_attribute4               =>  p_pmrpv_attribute4
      ,p_pmrpv_attribute5               =>  p_pmrpv_attribute5
      ,p_pmrpv_attribute6               =>  p_pmrpv_attribute6
      ,p_pmrpv_attribute7               =>  p_pmrpv_attribute7
      ,p_pmrpv_attribute8               =>  p_pmrpv_attribute8
      ,p_pmrpv_attribute9               =>  p_pmrpv_attribute9
      ,p_pmrpv_attribute10              =>  p_pmrpv_attribute10
      ,p_pmrpv_attribute11              =>  p_pmrpv_attribute11
      ,p_pmrpv_attribute12              =>  p_pmrpv_attribute12
      ,p_pmrpv_attribute13              =>  p_pmrpv_attribute13
      ,p_pmrpv_attribute14              =>  p_pmrpv_attribute14
      ,p_pmrpv_attribute15              =>  p_pmrpv_attribute15
      ,p_pmrpv_attribute16              =>  p_pmrpv_attribute16
      ,p_pmrpv_attribute17              =>  p_pmrpv_attribute17
      ,p_pmrpv_attribute18              =>  p_pmrpv_attribute18
      ,p_pmrpv_attribute19              =>  p_pmrpv_attribute19
      ,p_pmrpv_attribute20              =>  p_pmrpv_attribute20
      ,p_pmrpv_attribute21              =>  p_pmrpv_attribute21
      ,p_pmrpv_attribute22              =>  p_pmrpv_attribute22
      ,p_pmrpv_attribute23              =>  p_pmrpv_attribute23
      ,p_pmrpv_attribute24              =>  p_pmrpv_attribute24
      ,p_pmrpv_attribute25              =>  p_pmrpv_attribute25
      ,p_pmrpv_attribute26              =>  p_pmrpv_attribute26
      ,p_pmrpv_attribute27              =>  p_pmrpv_attribute27
      ,p_pmrpv_attribute28              =>  p_pmrpv_attribute28
      ,p_pmrpv_attribute29              =>  p_pmrpv_attribute29
      ,p_pmrpv_attribute30              =>  p_pmrpv_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_Prtl_Mo_Rt_Prtn_Val'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_Prtl_Mo_Rt_Prtn_Val
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
  p_prtl_mo_rt_prtn_val_id := l_prtl_mo_rt_prtn_val_id;
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
    ROLLBACK TO create_Prtl_Mo_Rt_Prtn_Val;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_prtl_mo_rt_prtn_val_id := null;
    p_effective_end_date := null;
    p_effective_start_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_Prtl_Mo_Rt_Prtn_Val;
    raise;
    --
end create_Prtl_Mo_Rt_Prtn_Val;
-- ----------------------------------------------------------------------------
-- |------------------------< update_Prtl_Mo_Rt_Prtn_Val >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_Prtl_Mo_Rt_Prtn_Val
  (p_validate                       in  boolean   default false
  ,p_prtl_mo_rt_prtn_val_id         in  number
  ,p_effective_end_date             out nocopy date
  ,p_effective_start_date           out nocopy date
  ,p_acty_base_rt_id                in  number    default hr_api.g_number
  ,p_rndg_rl                        in  number    default hr_api.g_number
  ,p_rndg_cd                        in  varchar2  default hr_api.g_varchar2
  ,p_to_dy_mo_num                   in  number    default hr_api.g_number
  ,p_from_dy_mo_num                 in  number    default hr_api.g_number
  ,p_pct_val                        in  number    default hr_api.g_number
  ,p_strt_r_stp_cvg_cd              in  varchar2  default hr_api.g_varchar2
  ,p_prtl_mo_prortn_rl              in  number    default hr_api.g_number
  ,p_actl_prem_id                   in  number    default hr_api.g_number
  ,p_cvg_amt_calc_mthd_id           in  number    default hr_api.g_number
  ,p_num_days_month                 in  number
  ,p_prorate_by_day_to_mon_flag     in  varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pmrpv_attribute_category       in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute1               in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute2               in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute3               in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute4               in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute5               in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute6               in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute7               in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute8               in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute9               in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute10              in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute11              in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute12              in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute13              in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute14              in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute15              in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute16              in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute17              in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute18              in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute19              in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute20              in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute21              in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute22              in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute23              in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute24              in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute25              in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute26              in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute27              in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute28              in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute29              in  varchar2  default hr_api.g_varchar2
  ,p_pmrpv_attribute30              in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Prtl_Mo_Rt_Prtn_Val';
  l_object_version_number ben_prtl_mo_rt_prtn_val_f.object_version_number%TYPE;
  l_effective_end_date ben_prtl_mo_rt_prtn_val_f.effective_end_date%TYPE;
  l_effective_start_date ben_prtl_mo_rt_prtn_val_f.effective_start_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_Prtl_Mo_Rt_Prtn_Val;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_Prtl_Mo_Rt_Prtn_Val
    --
    ben_Prtl_Mo_Rt_Prtn_Val_bk2.update_Prtl_Mo_Rt_Prtn_Val_b
      (
       p_prtl_mo_rt_prtn_val_id         =>  p_prtl_mo_rt_prtn_val_id
      ,p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_rndg_rl                        =>  p_rndg_rl
      ,p_rndg_cd                        =>  p_rndg_cd
      ,p_to_dy_mo_num                   =>  p_to_dy_mo_num
      ,p_from_dy_mo_num                 =>  p_from_dy_mo_num
      ,p_pct_val                        =>  p_pct_val
    ,p_strt_r_stp_cvg_cd              =>  p_strt_r_stp_cvg_cd
    ,p_prtl_mo_prortn_rl              =>  p_prtl_mo_prortn_rl
    ,p_actl_prem_id                   =>  p_actl_prem_id
    ,p_cvg_amt_calc_mthd_id           =>  p_cvg_amt_calc_mthd_id
      ,p_num_days_month                 =>  p_num_days_month
      ,p_prorate_by_day_to_mon_flag     =>  p_prorate_by_day_to_mon_flag
      ,p_business_group_id              =>  p_business_group_id
      ,p_pmrpv_attribute_category       =>  p_pmrpv_attribute_category
      ,p_pmrpv_attribute1               =>  p_pmrpv_attribute1
      ,p_pmrpv_attribute2               =>  p_pmrpv_attribute2
      ,p_pmrpv_attribute3               =>  p_pmrpv_attribute3
      ,p_pmrpv_attribute4               =>  p_pmrpv_attribute4
      ,p_pmrpv_attribute5               =>  p_pmrpv_attribute5
      ,p_pmrpv_attribute6               =>  p_pmrpv_attribute6
      ,p_pmrpv_attribute7               =>  p_pmrpv_attribute7
      ,p_pmrpv_attribute8               =>  p_pmrpv_attribute8
      ,p_pmrpv_attribute9               =>  p_pmrpv_attribute9
      ,p_pmrpv_attribute10              =>  p_pmrpv_attribute10
      ,p_pmrpv_attribute11              =>  p_pmrpv_attribute11
      ,p_pmrpv_attribute12              =>  p_pmrpv_attribute12
      ,p_pmrpv_attribute13              =>  p_pmrpv_attribute13
      ,p_pmrpv_attribute14              =>  p_pmrpv_attribute14
      ,p_pmrpv_attribute15              =>  p_pmrpv_attribute15
      ,p_pmrpv_attribute16              =>  p_pmrpv_attribute16
      ,p_pmrpv_attribute17              =>  p_pmrpv_attribute17
      ,p_pmrpv_attribute18              =>  p_pmrpv_attribute18
      ,p_pmrpv_attribute19              =>  p_pmrpv_attribute19
      ,p_pmrpv_attribute20              =>  p_pmrpv_attribute20
      ,p_pmrpv_attribute21              =>  p_pmrpv_attribute21
      ,p_pmrpv_attribute22              =>  p_pmrpv_attribute22
      ,p_pmrpv_attribute23              =>  p_pmrpv_attribute23
      ,p_pmrpv_attribute24              =>  p_pmrpv_attribute24
      ,p_pmrpv_attribute25              =>  p_pmrpv_attribute25
      ,p_pmrpv_attribute26              =>  p_pmrpv_attribute26
      ,p_pmrpv_attribute27              =>  p_pmrpv_attribute27
      ,p_pmrpv_attribute28              =>  p_pmrpv_attribute28
      ,p_pmrpv_attribute29              =>  p_pmrpv_attribute29
      ,p_pmrpv_attribute30              =>  p_pmrpv_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Prtl_Mo_Rt_Prtn_Val'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_Prtl_Mo_Rt_Prtn_Val
    --
  end;
  --
  ben_ppv_upd.upd
    (
     p_prtl_mo_rt_prtn_val_id        => p_prtl_mo_rt_prtn_val_id
    ,p_effective_end_date            => l_effective_end_date
    ,p_effective_start_date          => l_effective_start_date
    ,p_acty_base_rt_id               => p_acty_base_rt_id
    ,p_rndg_rl                       => p_rndg_rl
    ,p_rndg_cd                       => p_rndg_cd
    ,p_to_dy_mo_num                  => p_to_dy_mo_num
    ,p_from_dy_mo_num                => p_from_dy_mo_num
    ,p_pct_val                       => p_pct_val
    ,p_strt_r_stp_cvg_cd              =>  p_strt_r_stp_cvg_cd
    ,p_prtl_mo_prortn_rl              =>  p_prtl_mo_prortn_rl
    ,p_actl_prem_id                   =>  p_actl_prem_id
    ,p_cvg_amt_calc_mthd_id           =>  p_cvg_amt_calc_mthd_id
    ,p_num_days_month                =>  p_num_days_month
    ,p_prorate_by_day_to_mon_flag    =>  p_prorate_by_day_to_mon_flag
    ,p_business_group_id             => p_business_group_id
    ,p_pmrpv_attribute_category      => p_pmrpv_attribute_category
    ,p_pmrpv_attribute1              => p_pmrpv_attribute1
    ,p_pmrpv_attribute2              => p_pmrpv_attribute2
    ,p_pmrpv_attribute3              => p_pmrpv_attribute3
    ,p_pmrpv_attribute4              => p_pmrpv_attribute4
    ,p_pmrpv_attribute5              => p_pmrpv_attribute5
    ,p_pmrpv_attribute6              => p_pmrpv_attribute6
    ,p_pmrpv_attribute7              => p_pmrpv_attribute7
    ,p_pmrpv_attribute8              => p_pmrpv_attribute8
    ,p_pmrpv_attribute9              => p_pmrpv_attribute9
    ,p_pmrpv_attribute10             => p_pmrpv_attribute10
    ,p_pmrpv_attribute11             => p_pmrpv_attribute11
    ,p_pmrpv_attribute12             => p_pmrpv_attribute12
    ,p_pmrpv_attribute13             => p_pmrpv_attribute13
    ,p_pmrpv_attribute14             => p_pmrpv_attribute14
    ,p_pmrpv_attribute15             => p_pmrpv_attribute15
    ,p_pmrpv_attribute16             => p_pmrpv_attribute16
    ,p_pmrpv_attribute17             => p_pmrpv_attribute17
    ,p_pmrpv_attribute18             => p_pmrpv_attribute18
    ,p_pmrpv_attribute19             => p_pmrpv_attribute19
    ,p_pmrpv_attribute20             => p_pmrpv_attribute20
    ,p_pmrpv_attribute21             => p_pmrpv_attribute21
    ,p_pmrpv_attribute22             => p_pmrpv_attribute22
    ,p_pmrpv_attribute23             => p_pmrpv_attribute23
    ,p_pmrpv_attribute24             => p_pmrpv_attribute24
    ,p_pmrpv_attribute25             => p_pmrpv_attribute25
    ,p_pmrpv_attribute26             => p_pmrpv_attribute26
    ,p_pmrpv_attribute27             => p_pmrpv_attribute27
    ,p_pmrpv_attribute28             => p_pmrpv_attribute28
    ,p_pmrpv_attribute29             => p_pmrpv_attribute29
    ,p_pmrpv_attribute30             => p_pmrpv_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_Prtl_Mo_Rt_Prtn_Val
    --
    ben_Prtl_Mo_Rt_Prtn_Val_bk2.update_Prtl_Mo_Rt_Prtn_Val_a
      (
       p_prtl_mo_rt_prtn_val_id         =>  p_prtl_mo_rt_prtn_val_id
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_rndg_rl                        =>  p_rndg_rl
      ,p_rndg_cd                        =>  p_rndg_cd
      ,p_to_dy_mo_num                   =>  p_to_dy_mo_num
      ,p_from_dy_mo_num                 =>  p_from_dy_mo_num
      ,p_pct_val                        =>  p_pct_val
    ,p_strt_r_stp_cvg_cd              =>  p_strt_r_stp_cvg_cd
    ,p_prtl_mo_prortn_rl              =>  p_prtl_mo_prortn_rl
    ,p_actl_prem_id                   =>  p_actl_prem_id
    ,p_cvg_amt_calc_mthd_id           =>  p_cvg_amt_calc_mthd_id
      ,p_num_days_month                 =>  p_num_days_month
      ,p_prorate_by_day_to_mon_flag     =>  p_prorate_by_day_to_mon_flag
      ,p_business_group_id              =>  p_business_group_id
      ,p_pmrpv_attribute_category       =>  p_pmrpv_attribute_category
      ,p_pmrpv_attribute1               =>  p_pmrpv_attribute1
      ,p_pmrpv_attribute2               =>  p_pmrpv_attribute2
      ,p_pmrpv_attribute3               =>  p_pmrpv_attribute3
      ,p_pmrpv_attribute4               =>  p_pmrpv_attribute4
      ,p_pmrpv_attribute5               =>  p_pmrpv_attribute5
      ,p_pmrpv_attribute6               =>  p_pmrpv_attribute6
      ,p_pmrpv_attribute7               =>  p_pmrpv_attribute7
      ,p_pmrpv_attribute8               =>  p_pmrpv_attribute8
      ,p_pmrpv_attribute9               =>  p_pmrpv_attribute9
      ,p_pmrpv_attribute10              =>  p_pmrpv_attribute10
      ,p_pmrpv_attribute11              =>  p_pmrpv_attribute11
      ,p_pmrpv_attribute12              =>  p_pmrpv_attribute12
      ,p_pmrpv_attribute13              =>  p_pmrpv_attribute13
      ,p_pmrpv_attribute14              =>  p_pmrpv_attribute14
      ,p_pmrpv_attribute15              =>  p_pmrpv_attribute15
      ,p_pmrpv_attribute16              =>  p_pmrpv_attribute16
      ,p_pmrpv_attribute17              =>  p_pmrpv_attribute17
      ,p_pmrpv_attribute18              =>  p_pmrpv_attribute18
      ,p_pmrpv_attribute19              =>  p_pmrpv_attribute19
      ,p_pmrpv_attribute20              =>  p_pmrpv_attribute20
      ,p_pmrpv_attribute21              =>  p_pmrpv_attribute21
      ,p_pmrpv_attribute22              =>  p_pmrpv_attribute22
      ,p_pmrpv_attribute23              =>  p_pmrpv_attribute23
      ,p_pmrpv_attribute24              =>  p_pmrpv_attribute24
      ,p_pmrpv_attribute25              =>  p_pmrpv_attribute25
      ,p_pmrpv_attribute26              =>  p_pmrpv_attribute26
      ,p_pmrpv_attribute27              =>  p_pmrpv_attribute27
      ,p_pmrpv_attribute28              =>  p_pmrpv_attribute28
      ,p_pmrpv_attribute29              =>  p_pmrpv_attribute29
      ,p_pmrpv_attribute30              =>  p_pmrpv_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Prtl_Mo_Rt_Prtn_Val'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_Prtl_Mo_Rt_Prtn_Val
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
    ROLLBACK TO update_Prtl_Mo_Rt_Prtn_Val;
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
    ROLLBACK TO update_Prtl_Mo_Rt_Prtn_Val;
    raise;
    --
end update_Prtl_Mo_Rt_Prtn_Val;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Prtl_Mo_Rt_Prtn_Val >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Prtl_Mo_Rt_Prtn_Val
  (p_validate                       in  boolean  default false
  ,p_prtl_mo_rt_prtn_val_id         in  number
  ,p_effective_end_date             out nocopy date
  ,p_effective_start_date           out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Prtl_Mo_Rt_Prtn_Val';
  l_object_version_number ben_prtl_mo_rt_prtn_val_f.object_version_number%TYPE;
  l_effective_end_date ben_prtl_mo_rt_prtn_val_f.effective_end_date%TYPE;
  l_effective_start_date ben_prtl_mo_rt_prtn_val_f.effective_start_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_Prtl_Mo_Rt_Prtn_Val;
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
    -- Start of API User Hook for the before hook of delete_Prtl_Mo_Rt_Prtn_Val
    --
    ben_Prtl_Mo_Rt_Prtn_Val_bk3.delete_Prtl_Mo_Rt_Prtn_Val_b
      (
       p_prtl_mo_rt_prtn_val_id         =>  p_prtl_mo_rt_prtn_val_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Prtl_Mo_Rt_Prtn_Val'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_Prtl_Mo_Rt_Prtn_Val
    --
  end;
  --
  ben_ppv_del.del
    (
     p_prtl_mo_rt_prtn_val_id        => p_prtl_mo_rt_prtn_val_id
    ,p_effective_end_date            => l_effective_end_date
    ,p_effective_start_date          => l_effective_start_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_Prtl_Mo_Rt_Prtn_Val
    --
    ben_Prtl_Mo_Rt_Prtn_Val_bk3.delete_Prtl_Mo_Rt_Prtn_Val_a
      (
       p_prtl_mo_rt_prtn_val_id         =>  p_prtl_mo_rt_prtn_val_id
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Prtl_Mo_Rt_Prtn_Val'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_Prtl_Mo_Rt_Prtn_Val
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
    ROLLBACK TO delete_Prtl_Mo_Rt_Prtn_Val;
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
    ROLLBACK TO delete_Prtl_Mo_Rt_Prtn_Val;
    raise;
    --
end delete_Prtl_Mo_Rt_Prtn_Val;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_prtl_mo_rt_prtn_val_id                   in     number
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
  ben_ppv_shd.lck
    (
      p_prtl_mo_rt_prtn_val_id                 => p_prtl_mo_rt_prtn_val_id
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
procedure update_old_rows
  (p_acty_base_rt_id     in number default null
  ,p_actl_prem_id        in number default null
  ,p_effective_date      in date
  ,p_business_group_id   in number
 ) is
 --
 cursor c_ppv is
   select distinct prtl_mo_rt_prtn_val_id
   from ben_Prtl_Mo_Rt_Prtn_Val_f ppv
   where (ppv.acty_base_rt_id = p_acty_base_rt_id or
          ppv.actl_prem_id = p_actl_prem_id)
   and  ppv.prorate_by_day_to_mon_flag = 'N'
   and  p_effective_date between ppv.effective_start_date
     and ppv.effective_end_date;
 --
 cursor c_ppv2 (p_prtl_mo_rt_prtn_val_id number) is
   select *
   from ben_Prtl_Mo_Rt_Prtn_Val_f ppv
   where ppv.prtl_mo_rt_prtn_val_id = p_prtl_mo_rt_prtn_val_id
   and   p_effective_date between ppv.effective_start_date
     and ppv.effective_end_date
   order by ppv.effective_start_date;
 --
 l_ppv   c_ppv%rowtype;
 l_ppv2  c_ppv2%rowtype;
 l_delete_mode  varchar2(300);
 l_effective_date  date;
 l_effective_start_date date;
 l_effective_end_date   date;
 --
begin
  --
  hr_utility.set_location('Update old rows',1);
  open c_ppv;
  loop
    fetch c_ppv into l_ppv;
    if c_ppv%notfound then
      exit;
    end if;
    --
    open c_ppv2 (l_ppv.prtl_mo_rt_prtn_val_id);
    fetch c_ppv2 into l_ppv2;
    close c_ppv2;
    --
    if l_ppv2.effective_start_date = p_effective_date then
      --
      l_delete_mode := hr_api.g_zap;
      l_effective_date := p_effective_date;
    else
      --
      l_delete_mode := hr_api.g_delete;
      l_effective_date := p_effective_date -1 ;
    end if;
    --
    hr_utility.set_location ('ID '||l_ppv2.prtl_mo_rt_prtn_val_id,9);
    delete_Prtl_Mo_Rt_Prtn_Val
     (
      p_prtl_mo_rt_prtn_val_id   => l_ppv2.prtl_mo_rt_prtn_val_id
     ,p_effective_end_date       => l_effective_end_date
     ,p_effective_start_date     => l_effective_start_date
     ,p_object_version_number    => l_ppv2.object_version_number
     ,p_effective_date           => l_effective_date
     ,p_datetrack_mode           => l_delete_mode
     );

 end loop;
 close c_ppv;
 --
 hr_utility.set_location ('Leaving - Update old rows',10);
end;


end ben_Prtl_Mo_Rt_Prtn_Val_api;

/
