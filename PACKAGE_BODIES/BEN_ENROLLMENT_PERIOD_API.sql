--------------------------------------------------------
--  DDL for Package Body BEN_ENROLLMENT_PERIOD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ENROLLMENT_PERIOD_API" as
/* $Header: beenpapi.pkb 120.0.12000000.2 2007/05/13 22:51:53 rtagarra noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_Enrollment_Period_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Enrollment_Period >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_Enrollment_Period
  (p_validate                       in  boolean   default false
  ,p_enrt_perd_id                   out nocopy number
  ,p_business_group_id              in  number    default null
  ,p_yr_perd_id                     in  number    default null
  ,p_popl_enrt_typ_cycl_id          in  number    default null
  ,p_end_dt                         in  date      default null
  ,p_strt_dt                        in  date      default null
  ,p_asnd_lf_evt_dt                 in  date      default null
  ,p_cls_enrt_dt_to_use_cd          in  varchar2  default null
  ,p_dflt_enrt_dt                   in  date      default null
  ,p_enrt_cvg_strt_dt_cd            in  varchar2  default null
  ,p_rt_strt_dt_rl                  in  number    default null
  ,p_enrt_cvg_end_dt_cd             in  varchar2  default null
  ,p_enrt_cvg_strt_dt_rl            in  number    default null
  ,p_enrt_cvg_end_dt_rl             in  number    default null
  ,p_procg_end_dt                   in  date      default null
  ,p_rt_strt_dt_cd                  in  varchar2  default null
  ,p_rt_end_dt_cd                   in  varchar2  default null
  ,p_rt_end_dt_rl                   in  number    default null
  ,p_bdgt_upd_strt_dt               in  date      default null
  ,p_bdgt_upd_end_dt                in  date      default null
  ,p_ws_upd_strt_dt                 in  date      default null
  ,p_ws_upd_end_dt                  in  date      default null
  ,p_dflt_ws_acc_cd                 in  varchar2  default null
  ,p_prsvr_bdgt_cd                  in  varchar2  default null
  ,p_uses_bdgt_flag                 in  varchar2  default 'N'
  ,p_auto_distr_flag                in  varchar2  default 'N'
  ,p_hrchy_to_use_cd                in  varchar2  default null
  ,p_pos_structure_version_id          in  number    default null
  ,p_emp_interview_type_cd          in  varchar2  default null
  ,p_wthn_yr_perd_id                in  number    default null
  ,p_ler_id                         in  number    default null
  ,p_perf_revw_strt_dt              in  date      default null
  ,p_asg_updt_eff_date              in  date      default null
  ,p_enp_attribute_category         in  varchar2  default null
  ,p_enp_attribute1                 in  varchar2  default null
  ,p_enp_attribute2                 in  varchar2  default null
  ,p_enp_attribute3                 in  varchar2  default null
  ,p_enp_attribute4                 in  varchar2  default null
  ,p_enp_attribute5                 in  varchar2  default null
  ,p_enp_attribute6                 in  varchar2  default null
  ,p_enp_attribute7                 in  varchar2  default null
  ,p_enp_attribute8                 in  varchar2  default null
  ,p_enp_attribute9                 in  varchar2  default null
  ,p_enp_attribute10                in  varchar2  default null
  ,p_enp_attribute11                in  varchar2  default null
  ,p_enp_attribute12                in  varchar2  default null
  ,p_enp_attribute13                in  varchar2  default null
  ,p_enp_attribute14                in  varchar2  default null
  ,p_enp_attribute15                in  varchar2  default null
  ,p_enp_attribute16                in  varchar2  default null
  ,p_enp_attribute17                in  varchar2  default null
  ,p_enp_attribute18                in  varchar2  default null
  ,p_enp_attribute19                in  varchar2  default null
  ,p_enp_attribute20                in  varchar2  default null
  ,p_enp_attribute21                in  varchar2  default null
  ,p_enp_attribute22                in  varchar2  default null
  ,p_enp_attribute23                in  varchar2  default null
  ,p_enp_attribute24                in  varchar2  default null
  ,p_enp_attribute25                in  varchar2  default null
  ,p_enp_attribute26                in  varchar2  default null
  ,p_enp_attribute27                in  varchar2  default null
  ,p_enp_attribute28                in  varchar2  default null
  ,p_enp_attribute29                in  varchar2  default null
  ,p_enp_attribute30                in  varchar2  default null
  ,p_enrt_perd_det_ovrlp_bckdt_cd   in  varchar2  default null
  --cwb
  ,p_data_freeze_date               in  date      default null
  ,p_Sal_chg_reason_cd              in  varchar2  default null
  ,p_Approval_mode_cd               in  varchar2  default null
  ,p_hrchy_ame_trn_cd               in  varchar2  default null
  ,p_hrchy_rl                       in  number    default null
  ,p_hrchy_ame_app_id               in  number    default null
  --
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
,p_reinstate_cd			in varchar2	default null
,p_reinstate_ovrdn_cd		in varchar2	default null
,p_DEFER_DEENROL_FLAG           in varchar2       default 'N'
  ) is
  --
  -- Declare cursors and local variables
  --
  l_enrt_perd_id ben_enrt_perd.enrt_perd_id%TYPE;
  l_proc varchar2(72) := g_package||'create_Enrollment_Period';
  l_object_version_number ben_enrt_perd.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_Enrollment_Period;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_Enrollment_Period
    --
    ben_Enrollment_Period_bk1.create_Enrollment_Period_b
      (
       p_business_group_id              =>  p_business_group_id
      ,p_yr_perd_id                     =>  p_yr_perd_id
      ,p_popl_enrt_typ_cycl_id          =>  p_popl_enrt_typ_cycl_id
      ,p_end_dt                         =>  p_end_dt
      ,p_strt_dt                        =>  p_strt_dt
      ,p_asnd_lf_evt_dt                 =>  p_asnd_lf_Evt_dt
      ,p_cls_enrt_dt_to_use_cd          =>  p_cls_enrt_dt_to_use_cd
      ,p_dflt_enrt_dt                   =>  p_dflt_enrt_dt
      ,p_enrt_cvg_strt_dt_cd            =>  p_enrt_cvg_strt_dt_cd
      ,p_rt_strt_dt_rl                  =>  p_rt_strt_dt_rl
      ,p_enrt_cvg_end_dt_cd             =>  p_enrt_cvg_end_dt_cd
      ,p_enrt_cvg_strt_dt_rl            =>  p_enrt_cvg_strt_dt_rl
      ,p_enrt_cvg_end_dt_rl             =>  p_enrt_cvg_end_dt_rl
      ,p_procg_end_dt                   =>  p_procg_end_dt
      ,p_rt_strt_dt_cd                  =>  p_rt_strt_dt_cd
      ,p_rt_end_dt_cd                   =>  p_rt_end_dt_cd
      ,p_rt_end_dt_rl                   =>  p_rt_end_dt_rl
      ,p_bdgt_upd_strt_dt               => p_bdgt_upd_strt_dt
      ,p_bdgt_upd_end_dt                => p_bdgt_upd_end_dt
      ,p_ws_upd_strt_dt                 => p_ws_upd_strt_dt
      ,p_ws_upd_end_dt                  => p_ws_upd_end_dt
      ,p_dflt_ws_acc_cd                 => p_dflt_ws_acc_cd
      ,p_prsvr_bdgt_cd                  => p_prsvr_bdgt_cd
      ,p_uses_bdgt_flag                 => p_uses_bdgt_flag
      ,p_auto_distr_flag                => p_auto_distr_flag
      ,p_hrchy_to_use_cd                => p_hrchy_to_use_cd
      ,p_pos_structure_version_id          => p_pos_structure_version_id
      ,p_emp_interview_type_cd          => p_emp_interview_type_cd
      ,p_wthn_yr_perd_id                => p_wthn_yr_perd_id
      ,p_ler_id                         => p_ler_id
      ,p_perf_revw_strt_dt              => p_perf_revw_strt_dt
      ,p_asg_updt_eff_date              => p_asg_updt_eff_date
      ,p_enp_attribute_category         =>  p_enp_attribute_category
      ,p_enp_attribute1                 =>  p_enp_attribute1
      ,p_enp_attribute2                 =>  p_enp_attribute2
      ,p_enp_attribute3                 =>  p_enp_attribute3
      ,p_enp_attribute4                 =>  p_enp_attribute4
      ,p_enp_attribute5                 =>  p_enp_attribute5
      ,p_enp_attribute6                 =>  p_enp_attribute6
      ,p_enp_attribute7                 =>  p_enp_attribute7
      ,p_enp_attribute8                 =>  p_enp_attribute8
      ,p_enp_attribute9                 =>  p_enp_attribute9
      ,p_enp_attribute10                =>  p_enp_attribute10
      ,p_enp_attribute11                =>  p_enp_attribute11
      ,p_enp_attribute12                =>  p_enp_attribute12
      ,p_enp_attribute13                =>  p_enp_attribute13
      ,p_enp_attribute14                =>  p_enp_attribute14
      ,p_enp_attribute15                =>  p_enp_attribute15
      ,p_enp_attribute16                =>  p_enp_attribute16
      ,p_enp_attribute17                =>  p_enp_attribute17
      ,p_enp_attribute18                =>  p_enp_attribute18
      ,p_enp_attribute19                =>  p_enp_attribute19
      ,p_enp_attribute20                =>  p_enp_attribute20
      ,p_enp_attribute21                =>  p_enp_attribute21
      ,p_enp_attribute22                =>  p_enp_attribute22
      ,p_enp_attribute23                =>  p_enp_attribute23
      ,p_enp_attribute24                =>  p_enp_attribute24
      ,p_enp_attribute25                =>  p_enp_attribute25
      ,p_enp_attribute26                =>  p_enp_attribute26
      ,p_enp_attribute27                =>  p_enp_attribute27
      ,p_enp_attribute28                =>  p_enp_attribute28
      ,p_enp_attribute29                =>  p_enp_attribute29
      ,p_enp_attribute30                =>  p_enp_attribute30
      ,p_enrt_perd_det_ovrlp_bckdt_cd   =>  p_enrt_perd_det_ovrlp_bckdt_cd
         --cwb
      ,p_data_freeze_date              =>   p_data_freeze_date
      ,p_Sal_chg_reason_cd             =>   p_Sal_chg_reason_cd
      ,p_Approval_mode_cd              =>   p_Approval_mode_cd
      ,p_hrchy_ame_trn_cd              =>   p_hrchy_ame_trn_cd
      ,p_hrchy_rl                      =>   p_hrchy_rl
      ,p_hrchy_ame_app_id              =>   p_hrchy_ame_app_id
    --cwb
      ,p_effective_date               => trunc(p_effective_date)
      ,p_reinstate_cd			=>  p_reinstate_cd
     ,p_reinstate_ovrdn_cd		=>  p_reinstate_ovrdn_cd
     ,p_defer_deenrol_flag              =>  p_defer_deenrol_flag
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_Enrollment_Period'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_Enrollment_Period
    --
  end;
  --
  ben_enp_ins.ins
    (
     p_enrt_perd_id                  => l_enrt_perd_id
    ,p_business_group_id             => p_business_group_id
    ,p_yr_perd_id                    => p_yr_perd_id
    ,p_popl_enrt_typ_cycl_id         => p_popl_enrt_typ_cycl_id
    ,p_end_dt                        => p_end_dt
    ,p_strt_dt                       => p_strt_dt
    ,p_asnd_lf_evt_dt                => p_asnd_lf_evt_dt
    ,p_cls_enrt_dt_to_use_cd         => p_cls_enrt_dt_to_use_cd
    ,p_dflt_enrt_dt                  => p_dflt_enrt_dt
    ,p_enrt_cvg_strt_dt_cd           => p_enrt_cvg_strt_dt_cd
    ,p_rt_strt_dt_rl                 => p_rt_strt_dt_rl
    ,p_enrt_cvg_end_dt_cd            => p_enrt_cvg_end_dt_cd
    ,p_enrt_cvg_strt_dt_rl           => p_enrt_cvg_strt_dt_rl
    ,p_enrt_cvg_end_dt_rl            => p_enrt_cvg_end_dt_rl
    ,p_procg_end_dt                  => p_procg_end_dt
    ,p_rt_strt_dt_cd                 => p_rt_strt_dt_cd
    ,p_rt_end_dt_cd                  => p_rt_end_dt_cd
    ,p_rt_end_dt_rl                  => p_rt_end_dt_rl
    ,p_bdgt_upd_strt_dt              => p_bdgt_upd_strt_dt
    ,p_bdgt_upd_end_dt               => p_bdgt_upd_end_dt
    ,p_ws_upd_strt_dt                => p_ws_upd_strt_dt
    ,p_ws_upd_end_dt                 => p_ws_upd_end_dt
    ,p_dflt_ws_acc_cd                => p_dflt_ws_acc_cd
    ,p_prsvr_bdgt_cd                 => p_prsvr_bdgt_cd
    ,p_uses_bdgt_flag                => p_uses_bdgt_flag
    ,p_auto_distr_flag               => p_auto_distr_flag
    ,p_hrchy_to_use_cd               => p_hrchy_to_use_cd
    ,p_pos_structure_version_id         => p_pos_structure_version_id
    ,p_emp_interview_type_cd         => p_emp_interview_type_cd
    ,p_wthn_yr_perd_id               => p_wthn_yr_perd_id
    ,p_ler_id                        => p_ler_id
    ,p_perf_revw_strt_dt             => p_perf_revw_strt_dt
    ,p_asg_updt_eff_date             => p_asg_updt_eff_date
    ,p_enp_attribute_category        => p_enp_attribute_category
    ,p_enp_attribute1                => p_enp_attribute1
    ,p_enp_attribute2                => p_enp_attribute2
    ,p_enp_attribute3                => p_enp_attribute3
    ,p_enp_attribute4                => p_enp_attribute4
    ,p_enp_attribute5                => p_enp_attribute5
    ,p_enp_attribute6                => p_enp_attribute6
    ,p_enp_attribute7                => p_enp_attribute7
    ,p_enp_attribute8                => p_enp_attribute8
    ,p_enp_attribute9                => p_enp_attribute9
    ,p_enp_attribute10               => p_enp_attribute10
    ,p_enp_attribute11               => p_enp_attribute11
    ,p_enp_attribute12               => p_enp_attribute12
    ,p_enp_attribute13               => p_enp_attribute13
    ,p_enp_attribute14               => p_enp_attribute14
    ,p_enp_attribute15               => p_enp_attribute15
    ,p_enp_attribute16               => p_enp_attribute16
    ,p_enp_attribute17               => p_enp_attribute17
    ,p_enp_attribute18               => p_enp_attribute18
    ,p_enp_attribute19               => p_enp_attribute19
    ,p_enp_attribute20               => p_enp_attribute20
    ,p_enp_attribute21               => p_enp_attribute21
    ,p_enp_attribute22               => p_enp_attribute22
    ,p_enp_attribute23               => p_enp_attribute23
    ,p_enp_attribute24               => p_enp_attribute24
    ,p_enp_attribute25               => p_enp_attribute25
    ,p_enp_attribute26               => p_enp_attribute26
    ,p_enp_attribute27               => p_enp_attribute27
    ,p_enp_attribute28               => p_enp_attribute28
    ,p_enp_attribute29               => p_enp_attribute29
    ,p_enp_attribute30               => p_enp_attribute30
    ,p_enrt_perd_det_ovrlp_bckdt_cd  => p_enrt_perd_det_ovrlp_bckdt_cd
     --cwb
    ,p_data_freeze_date              =>   p_data_freeze_date
    ,p_Sal_chg_reason_cd             =>   p_Sal_chg_reason_cd
    ,p_Approval_mode_cd              =>   p_Approval_mode_cd
    ,p_hrchy_ame_trn_cd              =>   p_hrchy_ame_trn_cd
    ,p_hrchy_rl                      =>   p_hrchy_rl
    ,p_hrchy_ame_app_id              =>   p_hrchy_ame_app_id
    --cwb
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_reinstate_cd		     =>  p_reinstate_cd
    ,p_reinstate_ovrdn_cd	     =>  p_reinstate_ovrdn_cd
    ,p_defer_deenrol_flag            => p_defer_deenrol_flag
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_Enrollment_Period
    --
    ben_Enrollment_Period_bk1.create_Enrollment_Period_a
      (
       p_enrt_perd_id                   =>  l_enrt_perd_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_yr_perd_id                     =>  p_yr_perd_id
      ,p_popl_enrt_typ_cycl_id          =>  p_popl_enrt_typ_cycl_id
      ,p_end_dt                         =>  p_end_dt
      ,p_strt_dt                        =>  p_strt_dt
      ,p_asnd_lf_evt_dt                 =>  p_asnd_lf_Evt_dt
      ,p_cls_enrt_dt_to_use_cd          =>  p_cls_enrt_dt_to_use_cd
      ,p_dflt_enrt_dt                   =>  p_dflt_enrt_dt
      ,p_enrt_cvg_strt_dt_cd            =>  p_enrt_cvg_strt_dt_cd
      ,p_rt_strt_dt_rl                  =>  p_rt_strt_dt_rl
      ,p_enrt_cvg_end_dt_cd             =>  p_enrt_cvg_end_dt_cd
      ,p_enrt_cvg_strt_dt_rl            =>  p_enrt_cvg_strt_dt_rl
      ,p_enrt_cvg_end_dt_rl             =>  p_enrt_cvg_end_dt_rl
      ,p_procg_end_dt                   =>  p_procg_end_dt
      ,p_rt_strt_dt_cd                  =>  p_rt_strt_dt_cd
      ,p_rt_end_dt_cd                   =>  p_rt_end_dt_cd
      ,p_rt_end_dt_rl                   =>  p_rt_end_dt_rl
      ,p_bdgt_upd_strt_dt              => p_bdgt_upd_strt_dt
      ,p_bdgt_upd_end_dt               => p_bdgt_upd_end_dt
      ,p_ws_upd_strt_dt                => p_ws_upd_strt_dt
      ,p_ws_upd_end_dt                 => p_ws_upd_end_dt
      ,p_dflt_ws_acc_cd                => p_dflt_ws_acc_cd
      ,p_prsvr_bdgt_cd                 => p_prsvr_bdgt_cd
      ,p_uses_bdgt_flag                => p_uses_bdgt_flag
      ,p_auto_distr_flag               => p_auto_distr_flag
      ,p_hrchy_to_use_cd               => p_hrchy_to_use_cd
      ,p_pos_structure_version_id         => p_pos_structure_version_id
      ,p_emp_interview_type_cd         => p_emp_interview_type_cd
      ,p_wthn_yr_perd_id               => p_wthn_yr_perd_id
      ,p_ler_id                        => p_ler_id
      ,p_perf_revw_strt_dt             => p_perf_revw_strt_dt
      ,p_asg_updt_eff_date             => p_asg_updt_eff_date
      ,p_enp_attribute_category         =>  p_enp_attribute_category
      ,p_enp_attribute1                 =>  p_enp_attribute1
      ,p_enp_attribute2                 =>  p_enp_attribute2
      ,p_enp_attribute3                 =>  p_enp_attribute3
      ,p_enp_attribute4                 =>  p_enp_attribute4
      ,p_enp_attribute5                 =>  p_enp_attribute5
      ,p_enp_attribute6                 =>  p_enp_attribute6
      ,p_enp_attribute7                 =>  p_enp_attribute7
      ,p_enp_attribute8                 =>  p_enp_attribute8
      ,p_enp_attribute9                 =>  p_enp_attribute9
      ,p_enp_attribute10                =>  p_enp_attribute10
      ,p_enp_attribute11                =>  p_enp_attribute11
      ,p_enp_attribute12                =>  p_enp_attribute12
      ,p_enp_attribute13                =>  p_enp_attribute13
      ,p_enp_attribute14                =>  p_enp_attribute14
      ,p_enp_attribute15                =>  p_enp_attribute15
      ,p_enp_attribute16                =>  p_enp_attribute16
      ,p_enp_attribute17                =>  p_enp_attribute17
      ,p_enp_attribute18                =>  p_enp_attribute18
      ,p_enp_attribute19                =>  p_enp_attribute19
      ,p_enp_attribute20                =>  p_enp_attribute20
      ,p_enp_attribute21                =>  p_enp_attribute21
      ,p_enp_attribute22                =>  p_enp_attribute22
      ,p_enp_attribute23                =>  p_enp_attribute23
      ,p_enp_attribute24                =>  p_enp_attribute24
      ,p_enp_attribute25                =>  p_enp_attribute25
      ,p_enp_attribute26                =>  p_enp_attribute26
      ,p_enp_attribute27                =>  p_enp_attribute27
      ,p_enp_attribute28                =>  p_enp_attribute28
      ,p_enp_attribute29                =>  p_enp_attribute29
      ,p_enp_attribute30                =>  p_enp_attribute30
      ,p_enrt_perd_det_ovrlp_bckdt_cd   =>  p_enrt_perd_det_ovrlp_bckdt_cd
      --cwb
      ,p_data_freeze_date              =>   p_data_freeze_date
      ,p_Sal_chg_reason_cd             =>   p_Sal_chg_reason_cd
      ,p_Approval_mode_cd              =>   p_Approval_mode_cd
      ,p_hrchy_ame_trn_cd              =>   p_hrchy_ame_trn_cd
      ,p_hrchy_rl                      =>   p_hrchy_rl
      ,p_hrchy_ame_app_id              =>   p_hrchy_ame_app_id
      ,p_object_version_number         =>  l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
      ,p_reinstate_cd		       =>  p_reinstate_cd
      ,p_reinstate_ovrdn_cd	       =>  p_reinstate_ovrdn_cd
      ,p_defer_deenrol_flag            =>  p_defer_deenrol_flag
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_Enrollment_Period'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_Enrollment_Period
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
  p_enrt_perd_id := l_enrt_perd_id;
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
    ROLLBACK TO create_Enrollment_Period;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_enrt_perd_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_Enrollment_Period;
    p_enrt_perd_id := null;
    p_object_version_number  := null;
    raise;
    --
end create_Enrollment_Period;
-- ----------------------------------------------------------------------------
-- |------------------------< update_Enrollment_Period >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_Enrollment_Period
  (p_validate                       in  boolean   default false
  ,p_enrt_perd_id                   in  number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_yr_perd_id                     in  number    default hr_api.g_number
  ,p_popl_enrt_typ_cycl_id          in  number    default hr_api.g_number
  ,p_end_dt                         in  date      default hr_api.g_date
  ,p_strt_dt                        in  date      default hr_api.g_date
  ,p_asnd_lf_evt_dt                 in  date      default hr_api.g_date
  ,p_cls_enrt_dt_to_use_cd          in  varchar2  default hr_api.g_varchar2
  ,p_dflt_enrt_dt                   in  date      default hr_api.g_date
  ,p_enrt_cvg_strt_dt_cd            in  varchar2  default hr_api.g_varchar2
  ,p_rt_strt_dt_rl                  in  number    default hr_api.g_number
  ,p_enrt_cvg_end_dt_cd             in  varchar2  default hr_api.g_varchar2
  ,p_enrt_cvg_strt_dt_rl            in  number    default hr_api.g_number
  ,p_enrt_cvg_end_dt_rl             in  number    default hr_api.g_number
  ,p_procg_end_dt                   in  date      default hr_api.g_date
  ,p_rt_strt_dt_cd                  in  varchar2  default hr_api.g_varchar2
  ,p_rt_end_dt_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_rt_end_dt_rl                   in  number    default hr_api.g_number
  ,p_bdgt_upd_strt_dt               in  date      default hr_api.g_date
  ,p_bdgt_upd_end_dt                in  date      default hr_api.g_date
  ,p_ws_upd_strt_dt                 in  date      default hr_api.g_date
  ,p_ws_upd_end_dt                  in  date      default hr_api.g_date
  ,p_dflt_ws_acc_cd                 in  varchar2  default hr_api.g_varchar2
  ,p_prsvr_bdgt_cd                  in  varchar2  default hr_api.g_varchar2
  ,p_uses_bdgt_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_auto_distr_flag                in  varchar2  default hr_api.g_varchar2
  ,p_hrchy_to_use_cd                in  varchar2  default hr_api.g_varchar2
  ,p_pos_structure_version_id          in  number    default hr_api.g_number
  ,p_emp_interview_type_cd          in  varchar2  default hr_api.g_varchar2
  ,p_wthn_yr_perd_id                in  number    default hr_api.g_number
  ,p_ler_id                         in  number    default hr_api.g_number
  ,p_perf_revw_strt_dt              in  date      default hr_api.g_date
  ,p_asg_updt_eff_date              in  date      default hr_api.g_date
  ,p_enp_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_enp_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_enrt_perd_det_ovrlp_bckdt_cd   in  varchar2  default hr_api.g_varchar2
  --cwb
  ,p_data_freeze_date               in  date      default hr_api.g_date
  ,p_Sal_chg_reason_cd              in  varchar2  default hr_api.g_varchar2
  ,p_Approval_mode_cd               in  varchar2  default hr_api.g_varchar2
  ,p_hrchy_ame_trn_cd               in  varchar2  default hr_api.g_varchar2
  ,p_hrchy_rl                       in  number    default hr_api.g_number
  ,p_hrchy_ame_app_id               in  number    default hr_api.g_number
  --
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_reinstate_cd			in varchar2		default hr_api.g_varchar2
  ,p_reinstate_ovrdn_cd		in varchar2		default hr_api.g_varchar2
  ,p_defer_deenrol_flag         in varchar2             default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Enrollment_Period';
  l_object_version_number ben_enrt_perd.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_Enrollment_Period;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_Enrollment_Period
    --
    ben_Enrollment_Period_bk2.update_Enrollment_Period_b
      (
       p_enrt_perd_id                   =>  p_enrt_perd_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_yr_perd_id                     =>  p_yr_perd_id
      ,p_popl_enrt_typ_cycl_id          =>  p_popl_enrt_typ_cycl_id
      ,p_end_dt                         =>  p_end_dt
      ,p_strt_dt                        =>  p_strt_dt
      ,p_asnd_lf_evt_dt                 =>  p_asnd_lf_Evt_dt
      ,p_cls_enrt_dt_to_use_cd          =>  p_cls_enrt_dt_to_use_cd
      ,p_dflt_enrt_dt                   =>  p_dflt_enrt_dt
      ,p_enrt_cvg_strt_dt_cd            =>  p_enrt_cvg_strt_dt_cd
      ,p_rt_strt_dt_rl                  =>  p_rt_strt_dt_rl
      ,p_enrt_cvg_end_dt_cd             =>  p_enrt_cvg_end_dt_cd
      ,p_enrt_cvg_strt_dt_rl            =>  p_enrt_cvg_strt_dt_rl
      ,p_enrt_cvg_end_dt_rl             =>  p_enrt_cvg_end_dt_rl
      ,p_procg_end_dt                   =>  p_procg_end_dt
      ,p_rt_strt_dt_cd                  =>  p_rt_strt_dt_cd
      ,p_rt_end_dt_cd                   =>  p_rt_end_dt_cd
      ,p_rt_end_dt_rl                   =>  p_rt_end_dt_rl
      ,p_bdgt_upd_strt_dt               => p_bdgt_upd_strt_dt
      ,p_bdgt_upd_end_dt                => p_bdgt_upd_end_dt
      ,p_ws_upd_strt_dt                 => p_ws_upd_strt_dt
      ,p_ws_upd_end_dt                  => p_ws_upd_end_dt
      ,p_dflt_ws_acc_cd                 => p_dflt_ws_acc_cd
      ,p_prsvr_bdgt_cd                  => p_prsvr_bdgt_cd
      ,p_uses_bdgt_flag                 => p_uses_bdgt_flag
      ,p_auto_distr_flag                => p_auto_distr_flag
      ,p_hrchy_to_use_cd                => p_hrchy_to_use_cd
      ,p_pos_structure_version_id          => p_pos_structure_version_id
      ,p_emp_interview_type_cd          => p_emp_interview_type_cd
      ,p_wthn_yr_perd_id                => p_wthn_yr_perd_id
      ,p_ler_id                         => p_ler_id
      ,p_perf_revw_strt_dt              => p_perf_revw_strt_dt
      ,p_asg_updt_eff_date              => p_asg_updt_eff_date
      ,p_enp_attribute_category         =>  p_enp_attribute_category
      ,p_enp_attribute1                 =>  p_enp_attribute1
      ,p_enp_attribute2                 =>  p_enp_attribute2
      ,p_enp_attribute3                 =>  p_enp_attribute3
      ,p_enp_attribute4                 =>  p_enp_attribute4
      ,p_enp_attribute5                 =>  p_enp_attribute5
      ,p_enp_attribute6                 =>  p_enp_attribute6
      ,p_enp_attribute7                 =>  p_enp_attribute7
      ,p_enp_attribute8                 =>  p_enp_attribute8
      ,p_enp_attribute9                 =>  p_enp_attribute9
      ,p_enp_attribute10                =>  p_enp_attribute10
      ,p_enp_attribute11                =>  p_enp_attribute11
      ,p_enp_attribute12                =>  p_enp_attribute12
      ,p_enp_attribute13                =>  p_enp_attribute13
      ,p_enp_attribute14                =>  p_enp_attribute14
      ,p_enp_attribute15                =>  p_enp_attribute15
      ,p_enp_attribute16                =>  p_enp_attribute16
      ,p_enp_attribute17                =>  p_enp_attribute17
      ,p_enp_attribute18                =>  p_enp_attribute18
      ,p_enp_attribute19                =>  p_enp_attribute19
      ,p_enp_attribute20                =>  p_enp_attribute20
      ,p_enp_attribute21                =>  p_enp_attribute21
      ,p_enp_attribute22                =>  p_enp_attribute22
      ,p_enp_attribute23                =>  p_enp_attribute23
      ,p_enp_attribute24                =>  p_enp_attribute24
      ,p_enp_attribute25                =>  p_enp_attribute25
      ,p_enp_attribute26                =>  p_enp_attribute26
      ,p_enp_attribute27                =>  p_enp_attribute27
      ,p_enp_attribute28                =>  p_enp_attribute28
      ,p_enp_attribute29                =>  p_enp_attribute29
      ,p_enp_attribute30                =>  p_enp_attribute30
      ,p_enrt_perd_det_ovrlp_bckdt_cd   =>  p_enrt_perd_det_ovrlp_bckdt_cd
      --cwb
      ,p_data_freeze_date              =>   p_data_freeze_date
      ,p_Sal_chg_reason_cd             =>   p_Sal_chg_reason_cd
      ,p_Approval_mode_cd              =>   p_Approval_mode_cd
      ,p_hrchy_ame_trn_cd              =>   p_hrchy_ame_trn_cd
      ,p_hrchy_rl                      =>   p_hrchy_rl
      ,p_hrchy_ame_app_id              =>   p_hrchy_ame_app_id
      --
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_reinstate_cd			=>  p_reinstate_cd
      ,p_reinstate_ovrdn_cd		=>  p_reinstate_ovrdn_cd
      ,p_defer_deenrol_flag             =>  p_defer_deenrol_flag
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Enrollment_Period'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_Enrollment_Period
    --
  end;
  --
  ben_enp_upd.upd
    (
     p_enrt_perd_id                  => p_enrt_perd_id
    ,p_business_group_id             => p_business_group_id
    ,p_yr_perd_id                    => p_yr_perd_id
    ,p_popl_enrt_typ_cycl_id         => p_popl_enrt_typ_cycl_id
    ,p_end_dt                        => p_end_dt
    ,p_strt_dt                       => p_strt_dt
    ,p_asnd_lf_evt_dt                =>  p_asnd_lf_Evt_dt
    ,p_cls_enrt_dt_to_use_cd         => p_cls_enrt_dt_to_use_cd
    ,p_dflt_enrt_dt                  => p_dflt_enrt_dt
    ,p_enrt_cvg_strt_dt_cd           => p_enrt_cvg_strt_dt_cd
    ,p_rt_strt_dt_rl                 => p_rt_strt_dt_rl
    ,p_enrt_cvg_end_dt_cd            => p_enrt_cvg_end_dt_cd
    ,p_enrt_cvg_strt_dt_rl           => p_enrt_cvg_strt_dt_rl
    ,p_enrt_cvg_end_dt_rl            => p_enrt_cvg_end_dt_rl
    ,p_procg_end_dt                  => p_procg_end_dt
    ,p_rt_strt_dt_cd                 => p_rt_strt_dt_cd
    ,p_rt_end_dt_cd                  => p_rt_end_dt_cd
    ,p_rt_end_dt_rl                  => p_rt_end_dt_rl
    ,p_bdgt_upd_strt_dt              => p_bdgt_upd_strt_dt
    ,p_bdgt_upd_end_dt               => p_bdgt_upd_end_dt
    ,p_ws_upd_strt_dt                => p_ws_upd_strt_dt
    ,p_ws_upd_end_dt                 => p_ws_upd_end_dt
    ,p_dflt_ws_acc_cd                => p_dflt_ws_acc_cd
    ,p_prsvr_bdgt_cd                 => p_prsvr_bdgt_cd
    ,p_uses_bdgt_flag                => p_uses_bdgt_flag
    ,p_auto_distr_flag               => p_auto_distr_flag
    ,p_hrchy_to_use_cd               => p_hrchy_to_use_cd
    ,p_pos_structure_version_id         => p_pos_structure_version_id
    ,p_emp_interview_type_cd         => p_emp_interview_type_cd
    ,p_wthn_yr_perd_id               => p_wthn_yr_perd_id
    ,p_ler_id                        => p_ler_id
    ,p_perf_revw_strt_dt             => p_perf_revw_strt_dt
    ,p_asg_updt_eff_date             => p_asg_updt_eff_date
    ,p_enp_attribute_category        => p_enp_attribute_category
    ,p_enp_attribute1                => p_enp_attribute1
    ,p_enp_attribute2                => p_enp_attribute2
    ,p_enp_attribute3                => p_enp_attribute3
    ,p_enp_attribute4                => p_enp_attribute4
    ,p_enp_attribute5                => p_enp_attribute5
    ,p_enp_attribute6                => p_enp_attribute6
    ,p_enp_attribute7                => p_enp_attribute7
    ,p_enp_attribute8                => p_enp_attribute8
    ,p_enp_attribute9                => p_enp_attribute9
    ,p_enp_attribute10               => p_enp_attribute10
    ,p_enp_attribute11               => p_enp_attribute11
    ,p_enp_attribute12               => p_enp_attribute12
    ,p_enp_attribute13               => p_enp_attribute13
    ,p_enp_attribute14               => p_enp_attribute14
    ,p_enp_attribute15               => p_enp_attribute15
    ,p_enp_attribute16               => p_enp_attribute16
    ,p_enp_attribute17               => p_enp_attribute17
    ,p_enp_attribute18               => p_enp_attribute18
    ,p_enp_attribute19               => p_enp_attribute19
    ,p_enp_attribute20               => p_enp_attribute20
    ,p_enp_attribute21               => p_enp_attribute21
    ,p_enp_attribute22               => p_enp_attribute22
    ,p_enp_attribute23               => p_enp_attribute23
    ,p_enp_attribute24               => p_enp_attribute24
    ,p_enp_attribute25               => p_enp_attribute25
    ,p_enp_attribute26               => p_enp_attribute26
    ,p_enp_attribute27               => p_enp_attribute27
    ,p_enp_attribute28               => p_enp_attribute28
    ,p_enp_attribute29               => p_enp_attribute29
    ,p_enp_attribute30               => p_enp_attribute30
    ,p_enrt_perd_det_ovrlp_bckdt_cd  => p_enrt_perd_det_ovrlp_bckdt_cd
    --cwb
    ,p_data_freeze_date              =>   p_data_freeze_date
    ,p_Sal_chg_reason_cd             =>   p_Sal_chg_reason_cd
    ,p_Approval_mode_cd              =>   p_Approval_mode_cd
    ,p_hrchy_ame_trn_cd              =>   p_hrchy_ame_trn_cd
    ,p_hrchy_rl                      =>   p_hrchy_rl
    ,p_hrchy_ame_app_id              =>   p_hrchy_ame_app_id
    --
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_reinstate_cd		     =>  p_reinstate_cd
    ,p_reinstate_ovrdn_cd	     =>	p_reinstate_ovrdn_cd
    ,p_defer_deenrol_flag            => p_defer_deenrol_flag
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_Enrollment_Period
    --
    ben_Enrollment_Period_bk2.update_Enrollment_Period_a
      (
       p_enrt_perd_id                   =>  p_enrt_perd_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_yr_perd_id                     =>  p_yr_perd_id
      ,p_popl_enrt_typ_cycl_id          =>  p_popl_enrt_typ_cycl_id
      ,p_end_dt                         =>  p_end_dt
      ,p_strt_dt                        =>  p_strt_dt
      ,p_asnd_lf_evt_dt                 =>  p_asnd_lf_Evt_dt
      ,p_cls_enrt_dt_to_use_cd          =>  p_cls_enrt_dt_to_use_cd
      ,p_dflt_enrt_dt                   =>  p_dflt_enrt_dt
      ,p_enrt_cvg_strt_dt_cd            =>  p_enrt_cvg_strt_dt_cd
      ,p_rt_strt_dt_rl                  =>  p_rt_strt_dt_rl
      ,p_enrt_cvg_end_dt_cd             =>  p_enrt_cvg_end_dt_cd
      ,p_enrt_cvg_strt_dt_rl            =>  p_enrt_cvg_strt_dt_rl
      ,p_enrt_cvg_end_dt_rl             =>  p_enrt_cvg_end_dt_rl
      ,p_procg_end_dt                   =>  p_procg_end_dt
      ,p_rt_strt_dt_cd                  =>  p_rt_strt_dt_cd
      ,p_rt_end_dt_cd                   =>  p_rt_end_dt_cd
      ,p_rt_end_dt_rl                   =>  p_rt_end_dt_rl
      ,p_bdgt_upd_strt_dt               => p_bdgt_upd_strt_dt
      ,p_bdgt_upd_end_dt                => p_bdgt_upd_end_dt
      ,p_ws_upd_strt_dt                 => p_ws_upd_strt_dt
      ,p_ws_upd_end_dt                  => p_ws_upd_end_dt
      ,p_dflt_ws_acc_cd                 => p_dflt_ws_acc_cd
      ,p_prsvr_bdgt_cd                  => p_prsvr_bdgt_cd
      ,p_uses_bdgt_flag                 => p_uses_bdgt_flag
      ,p_auto_distr_flag                => p_auto_distr_flag
      ,p_hrchy_to_use_cd                => p_hrchy_to_use_cd
      ,p_pos_structure_version_id          => p_pos_structure_version_id
      ,p_emp_interview_type_cd          => p_emp_interview_type_cd
      ,p_wthn_yr_perd_id                => p_wthn_yr_perd_id
      ,p_ler_id                         => p_ler_id
      ,p_perf_revw_strt_dt              => p_perf_revw_strt_dt
      ,p_asg_updt_eff_date              => p_asg_updt_eff_date
      ,p_enp_attribute_category         =>  p_enp_attribute_category
      ,p_enp_attribute1                 =>  p_enp_attribute1
      ,p_enp_attribute2                 =>  p_enp_attribute2
      ,p_enp_attribute3                 =>  p_enp_attribute3
      ,p_enp_attribute4                 =>  p_enp_attribute4
      ,p_enp_attribute5                 =>  p_enp_attribute5
      ,p_enp_attribute6                 =>  p_enp_attribute6
      ,p_enp_attribute7                 =>  p_enp_attribute7
      ,p_enp_attribute8                 =>  p_enp_attribute8
      ,p_enp_attribute9                 =>  p_enp_attribute9
      ,p_enp_attribute10                =>  p_enp_attribute10
      ,p_enp_attribute11                =>  p_enp_attribute11
      ,p_enp_attribute12                =>  p_enp_attribute12
      ,p_enp_attribute13                =>  p_enp_attribute13
      ,p_enp_attribute14                =>  p_enp_attribute14
      ,p_enp_attribute15                =>  p_enp_attribute15
      ,p_enp_attribute16                =>  p_enp_attribute16
      ,p_enp_attribute17                =>  p_enp_attribute17
      ,p_enp_attribute18                =>  p_enp_attribute18
      ,p_enp_attribute19                =>  p_enp_attribute19
      ,p_enp_attribute20                =>  p_enp_attribute20
      ,p_enp_attribute21                =>  p_enp_attribute21
      ,p_enp_attribute22                =>  p_enp_attribute22
      ,p_enp_attribute23                =>  p_enp_attribute23
      ,p_enp_attribute24                =>  p_enp_attribute24
      ,p_enp_attribute25                =>  p_enp_attribute25
      ,p_enp_attribute26                =>  p_enp_attribute26
      ,p_enp_attribute27                =>  p_enp_attribute27
      ,p_enp_attribute28                =>  p_enp_attribute28
      ,p_enp_attribute29                =>  p_enp_attribute29
      ,p_enp_attribute30                =>  p_enp_attribute30
      ,p_enrt_perd_det_ovrlp_bckdt_cd   =>  p_enrt_perd_det_ovrlp_bckdt_cd
      --cwb
      ,p_data_freeze_date              =>   p_data_freeze_date
      ,p_Sal_chg_reason_cd             =>   p_Sal_chg_reason_cd
      ,p_Approval_mode_cd              =>   p_Approval_mode_cd
      ,p_hrchy_ame_trn_cd              =>   p_hrchy_ame_trn_cd
      ,p_hrchy_rl                      =>   p_hrchy_rl
      ,p_hrchy_ame_app_id              =>   p_hrchy_ame_app_id
      --
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
      ,p_reinstate_cd			=>  p_reinstate_cd
      ,p_reinstate_ovrdn_cd		=>	p_reinstate_ovrdn_cd
      ,p_defer_deenrol_flag             => p_defer_deenrol_flag
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Enrollment_Period'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_Enrollment_Period
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
    ROLLBACK TO update_Enrollment_Period;
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
    ROLLBACK TO update_Enrollment_Period;
    raise;
    --
end update_Enrollment_Period;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Enrollment_Period >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Enrollment_Period
  (p_validate                       in  boolean  default false
  ,p_enrt_perd_id                   in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Enrollment_Period';
  l_object_version_number ben_enrt_perd.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_Enrollment_Period;
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
    -- Start of API User Hook for the before hook of delete_Enrollment_Period
    --
    ben_Enrollment_Period_bk3.delete_Enrollment_Period_b
      (
       p_enrt_perd_id                   =>  p_enrt_perd_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Enrollment_Period'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_Enrollment_Period
    --
  end;
  --
  ben_enp_del.del
    (
     p_enrt_perd_id                  => p_enrt_perd_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_Enrollment_Period
    --
    ben_Enrollment_Period_bk3.delete_Enrollment_Period_a
      (
       p_enrt_perd_id                   =>  p_enrt_perd_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Enrollment_Period'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_Enrollment_Period
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
    ROLLBACK TO delete_Enrollment_Period;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_Enrollment_Period;
    raise;
    --
end delete_Enrollment_Period;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_enrt_perd_id                   in     number
  ,p_object_version_number          in     number
  ) is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'lck';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  ben_enp_shd.lck
    (
      p_enrt_perd_id                 => p_enrt_perd_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_Enrollment_Period_api;

/
