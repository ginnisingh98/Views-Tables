--------------------------------------------------------
--  DDL for Package Body BEN_BENEFIT_ACTIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BENEFIT_ACTIONS_API" as
/* $Header: bebftapi.pkb 115.19 2003/08/18 05:06:05 rpgupta ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_benefit_actions_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_benefit_actions >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_benefit_actions
  (p_validate                       in  boolean   default false
  ,p_benefit_action_id              out nocopy number
  ,p_process_date                   in  date      default null
  ,p_uneai_effective_date           in  date      default null
  ,p_mode_cd                        in  varchar2  default null
  ,p_derivable_factors_flag         in  varchar2  default null
  ,p_close_uneai_flag               in  varchar2  default 'N'
  ,p_validate_flag                  in  varchar2  default null
  ,p_person_id                      in  number    default null
  ,p_person_type_id                 in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_popl_enrt_typ_cycl_id          in  number    default null
  ,p_no_programs_flag               in  varchar2  default null
  ,p_no_plans_flag                  in  varchar2  default null
  ,p_comp_selection_rl              in  number    default null
  ,p_person_selection_rl            in  number    default null
  ,p_ler_id                         in  number    default null
  ,p_organization_id                in  number    default null
  ,p_benfts_grp_id                  in  number    default null
  ,p_location_id                    in  number    default null
  ,p_pstl_zip_rng_id                in  number    default null
  ,p_rptg_grp_id                    in  number    default null
  ,p_pl_typ_id                      in  number    default null
  ,p_opt_id                         in  number    default null
  ,p_eligy_prfl_id                  in  number    default null
  ,p_vrbl_rt_prfl_id                in  number    default null
  ,p_legal_entity_id                in  number    default null
  ,p_payroll_id                     in  number    default null
  ,p_debug_messages_flag            in  varchar2  default null
  ,p_cm_trgr_typ_cd                 in  varchar2  default null
  ,p_cm_typ_id                      in  number    default null
  ,p_age_fctr_id                    in  number    default null
  ,p_min_age                        in  number    default null
  ,p_max_age                        in  number    default null
  ,p_los_fctr_id                    in  number    default null
  ,p_min_los                        in  number    default null
  ,p_max_los                        in  number    default null
  ,p_cmbn_age_los_fctr_id           in  number    default null
  ,p_min_cmbn                       in  number    default null
  ,p_max_cmbn                       in  number    default null
  ,p_date_from                      in  date      default null
  ,p_elig_enrol_cd                  in  varchar2  default null
  ,p_actn_typ_id                    in  number    default null
  ,p_use_fctr_to_sel_flag           in  varchar2  default 'N'
  ,p_los_det_to_use_cd              in  varchar2  default null
  ,p_audit_log_flag                 in  varchar2  default 'N'
  ,p_lmt_prpnip_by_org_flag         in  varchar2  default 'N'
  ,p_lf_evt_ocrd_dt                 in  date      default null
  ,p_ptnl_ler_for_per_stat_cd       in  varchar2  default null
  ,p_bft_attribute_category         in  varchar2  default null
  ,p_bft_attribute1                 in  varchar2  default null
  ,p_bft_attribute3                 in  varchar2  default null
  ,p_bft_attribute4                 in  varchar2  default null
  ,p_bft_attribute5                 in  varchar2  default null
  ,p_bft_attribute6                 in  varchar2  default null
  ,p_bft_attribute7                 in  varchar2  default null
  ,p_bft_attribute8                 in  varchar2  default null
  ,p_bft_attribute9                 in  varchar2  default null
  ,p_bft_attribute10                in  varchar2  default null
  ,p_bft_attribute11                in  varchar2  default null
  ,p_bft_attribute12                in  varchar2  default null
  ,p_bft_attribute13                in  varchar2  default null
  ,p_bft_attribute14                in  varchar2  default null
  ,p_bft_attribute15                in  varchar2  default null
  ,p_bft_attribute16                in  varchar2  default null
  ,p_bft_attribute17                in  varchar2  default null
  ,p_bft_attribute18                in  varchar2  default null
  ,p_bft_attribute19                in  varchar2  default null
  ,p_bft_attribute20                in  varchar2  default null
  ,p_bft_attribute21                in  varchar2  default null
  ,p_bft_attribute22                in  varchar2  default null
  ,p_bft_attribute23                in  varchar2  default null
  ,p_bft_attribute24                in  varchar2  default null
  ,p_bft_attribute25                in  varchar2  default null
  ,p_bft_attribute26                in  varchar2  default null
  ,p_bft_attribute27                in  varchar2  default null
  ,p_bft_attribute28                in  varchar2  default null
  ,p_bft_attribute29                in  varchar2  default null
  ,p_bft_attribute30                in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_enrt_perd_id                   in  number    default null
  ,p_inelg_action_cd                in  varchar2  default null
  ,p_org_hierarchy_id                in  number  default null
  ,p_org_starting_node_id                in  number  default null
  ,p_grade_ladder_id                in  number  default null
  ,p_asg_events_to_all_sel_dt                in  varchar2  default null
  ,p_rate_id                in  number  default null
  ,p_per_sel_dt_cd                in  varchar2  default null
  ,p_per_sel_freq_cd                in  varchar2  default null
  ,p_per_sel_dt_from                in  date  default null
  ,p_per_sel_dt_to                in  date  default null
  ,p_year_from                in  number  default null
  ,p_year_to                in  number  default null
  ,p_cagr_id                in  number  default null
  ,p_qual_type                in  number  default null
  ,p_qual_status                in  varchar2  default null
  ,p_concat_segs                in  varchar2  default null
  ,p_grant_price_val                in  number    default null) is
  --
  -- Declare cursors and local variables
  --
  l_benefit_action_id     ben_benefit_actions.benefit_action_id%TYPE;
  l_proc                  varchar2(72) := g_package||'create_benefit_actions';
  l_object_version_number ben_benefit_actions.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_benefit_actions;
  --
  /*
  hr_utility.set_location(l_proc, 20);
  */

  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_benefit_actions
    --
    ben_benefit_actions_bk1.create_benefit_actions_b
      (p_process_date                   =>  p_process_date
      ,p_uneai_effective_date           =>  p_uneai_effective_date
      ,p_mode_cd                        =>  p_mode_cd
      ,p_derivable_factors_flag         =>  p_derivable_factors_flag
      ,p_close_uneai_flag               =>  p_close_uneai_flag
      ,p_validate_flag                  =>  p_validate_flag
      ,p_person_id                      =>  p_person_id
      ,p_person_type_id                 =>  p_person_type_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pl_id                          =>  p_pl_id
      ,p_popl_enrt_typ_cycl_id          =>  p_popl_enrt_typ_cycl_id
      ,p_no_programs_flag               =>  p_no_programs_flag
      ,p_no_plans_flag                  =>  p_no_plans_flag
      ,p_comp_selection_rl              =>  p_comp_selection_rl
      ,p_person_selection_rl            =>  p_person_selection_rl
      ,p_ler_id                         =>  p_ler_id
      ,p_organization_id                =>  p_organization_id
      ,p_benfts_grp_id                  =>  p_benfts_grp_id
      ,p_location_id                    =>  p_location_id
      ,p_pstl_zip_rng_id                =>  p_pstl_zip_rng_id
      ,p_rptg_grp_id                    =>  p_rptg_grp_id
      ,p_pl_typ_id                      =>  p_pl_typ_id
      ,p_opt_id                         =>  p_opt_id
      ,p_eligy_prfl_id                  =>  p_eligy_prfl_id
      ,p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_legal_entity_id                =>  p_legal_entity_id
      ,p_payroll_id                     =>  p_payroll_id
      ,p_debug_messages_flag            =>  p_debug_messages_flag
      ,p_cm_trgr_typ_cd                 =>  p_cm_trgr_typ_cd
      ,p_cm_typ_id                      =>  p_cm_typ_id
      ,p_age_fctr_id                    =>  p_age_fctr_id
      ,p_min_age                        =>  p_min_age
      ,p_max_age                        =>  p_max_age
      ,p_los_fctr_id                    =>  p_los_fctr_id
      ,p_min_los                        =>  p_min_los
      ,p_max_los                        =>  p_max_los
      ,p_cmbn_age_los_fctr_id           =>  p_cmbn_age_los_fctr_id
      ,p_min_cmbn                       =>  p_min_cmbn
      ,p_max_cmbn                       =>  p_max_cmbn
      ,p_date_from                      =>  p_date_from
      ,p_elig_enrol_cd                  =>  p_elig_enrol_cd
      ,p_actn_typ_id                    =>  p_actn_typ_id
      ,p_use_fctr_to_sel_flag           =>  p_use_fctr_to_sel_flag
      ,p_los_det_to_use_cd              =>  p_los_det_to_use_cd
      ,p_audit_log_flag                 =>  p_audit_log_flag
      ,p_lmt_prpnip_by_org_flag         =>  p_lmt_prpnip_by_org_flag
      ,p_lf_evt_ocrd_dt                 =>  p_lf_evt_ocrd_dt
      ,p_ptnl_ler_for_per_stat_cd       =>  p_ptnl_ler_for_per_stat_cd
      ,p_bft_attribute_category         =>  p_bft_attribute_category
      ,p_bft_attribute1                 =>  p_bft_attribute1
      ,p_bft_attribute3                 =>  p_bft_attribute3
      ,p_bft_attribute4                 =>  p_bft_attribute4
      ,p_bft_attribute5                 =>  p_bft_attribute5
      ,p_bft_attribute6                 =>  p_bft_attribute6
      ,p_bft_attribute7                 =>  p_bft_attribute7
      ,p_bft_attribute8                 =>  p_bft_attribute8
      ,p_bft_attribute9                 =>  p_bft_attribute9
      ,p_bft_attribute10                =>  p_bft_attribute10
      ,p_bft_attribute11                =>  p_bft_attribute11
      ,p_bft_attribute12                =>  p_bft_attribute12
      ,p_bft_attribute13                =>  p_bft_attribute13
      ,p_bft_attribute14                =>  p_bft_attribute14
      ,p_bft_attribute15                =>  p_bft_attribute15
      ,p_bft_attribute16                =>  p_bft_attribute16
      ,p_bft_attribute17                =>  p_bft_attribute17
      ,p_bft_attribute18                =>  p_bft_attribute18
      ,p_bft_attribute19                =>  p_bft_attribute19
      ,p_bft_attribute20                =>  p_bft_attribute20
      ,p_bft_attribute21                =>  p_bft_attribute21
      ,p_bft_attribute22                =>  p_bft_attribute22
      ,p_bft_attribute23                =>  p_bft_attribute23
      ,p_bft_attribute24                =>  p_bft_attribute24
      ,p_bft_attribute25                =>  p_bft_attribute25
      ,p_bft_attribute26                =>  p_bft_attribute26
      ,p_bft_attribute27                =>  p_bft_attribute27
      ,p_bft_attribute28                =>  p_bft_attribute28
      ,p_bft_attribute29                =>  p_bft_attribute29
      ,p_bft_attribute30                =>  p_bft_attribute30
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_enrt_perd_id                   =>  p_enrt_perd_id
      ,p_inelg_action_cd                =>  p_inelg_action_cd
      ,p_org_hierarchy_id                =>  p_org_hierarchy_id
      ,p_org_starting_node_id                =>  p_org_starting_node_id
      ,p_grade_ladder_id                =>  p_grade_ladder_id
      ,p_asg_events_to_all_sel_dt                =>  p_asg_events_to_all_sel_dt
      ,p_rate_id                =>  p_rate_id
      ,p_per_sel_dt_cd                =>  p_per_sel_dt_cd
      ,p_per_sel_freq_cd                =>  p_per_sel_freq_cd
      ,p_per_sel_dt_from                =>  p_per_sel_dt_from
      ,p_per_sel_dt_to                =>  p_per_sel_dt_to
      ,p_year_from                =>  p_year_from
      ,p_year_to                =>  p_year_to
      ,p_cagr_id                =>  p_cagr_id
      ,p_qual_type                =>  p_qual_type
      ,p_qual_status                =>  p_qual_status
      ,p_concat_segs                =>  p_concat_segs
      ,p_grant_price_val                =>  p_grant_price_val);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_benefit_actions'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of create_benefit_actions
    --
  end;
  --
  ben_bft_ins.ins
    (p_benefit_action_id             => l_benefit_action_id
    ,p_process_date                  => p_process_date
    ,p_uneai_effective_date          => p_uneai_effective_date
    ,p_mode_cd                       => p_mode_cd
    ,p_derivable_factors_flag        => p_derivable_factors_flag
    ,p_close_uneai_flag              => p_close_uneai_flag
    ,p_validate_flag                 => p_validate_flag
    ,p_person_id                     => p_person_id
    ,p_person_type_id                => p_person_type_id
    ,p_pgm_id                        => p_pgm_id
    ,p_business_group_id             => p_business_group_id
    ,p_pl_id                         => p_pl_id
    ,p_popl_enrt_typ_cycl_id         => p_popl_enrt_typ_cycl_id
    ,p_no_programs_flag              => p_no_programs_flag
    ,p_no_plans_flag                 => p_no_plans_flag
    ,p_comp_selection_rl             => p_comp_selection_rl
    ,p_person_selection_rl           => p_person_selection_rl
    ,p_ler_id                        => p_ler_id
    ,p_organization_id               => p_organization_id
    ,p_benfts_grp_id                 => p_benfts_grp_id
    ,p_location_id                   => p_location_id
    ,p_pstl_zip_rng_id               => p_pstl_zip_rng_id
    ,p_rptg_grp_id                   => p_rptg_grp_id
    ,p_pl_typ_id                     => p_pl_typ_id
    ,p_opt_id                        => p_opt_id
    ,p_eligy_prfl_id                 => p_eligy_prfl_id
    ,p_vrbl_rt_prfl_id               => p_vrbl_rt_prfl_id
    ,p_legal_entity_id               => p_legal_entity_id
    ,p_payroll_id                    => p_payroll_id
    ,p_debug_messages_flag           => p_debug_messages_flag
    ,p_cm_trgr_typ_cd                => p_cm_trgr_typ_cd
    ,p_cm_typ_id                     => p_cm_typ_id
    ,p_age_fctr_id                   => p_age_fctr_id
    ,p_min_age                       => p_min_age
    ,p_max_age                       => p_max_age
    ,p_los_fctr_id                   => p_los_fctr_id
    ,p_min_los                       => p_min_los
    ,p_max_los                       => p_max_los
    ,p_cmbn_age_los_fctr_id          => p_cmbn_age_los_fctr_id
    ,p_min_cmbn                      => p_min_cmbn
    ,p_max_cmbn                      => p_max_cmbn
    ,p_date_from                     => p_date_from
    ,p_elig_enrol_cd                 => p_elig_enrol_cd
    ,p_actn_typ_id                   => p_actn_typ_id
    ,p_use_fctr_to_sel_flag          => p_use_fctr_to_sel_flag
    ,p_los_det_to_use_cd             => p_los_det_to_use_cd
    ,p_audit_log_flag                => p_audit_log_flag
    ,p_lmt_prpnip_by_org_flag        => p_lmt_prpnip_by_org_flag
    ,p_lf_evt_ocrd_dt                => p_lf_evt_ocrd_dt
    ,p_ptnl_ler_for_per_stat_cd      => p_ptnl_ler_for_per_stat_cd
    ,p_bft_attribute_category        => p_bft_attribute_category
    ,p_bft_attribute1                => p_bft_attribute1
    ,p_bft_attribute3                => p_bft_attribute3
    ,p_bft_attribute4                => p_bft_attribute4
    ,p_bft_attribute5                => p_bft_attribute5
    ,p_bft_attribute6                => p_bft_attribute6
    ,p_bft_attribute7                => p_bft_attribute7
    ,p_bft_attribute8                => p_bft_attribute8
    ,p_bft_attribute9                => p_bft_attribute9
    ,p_bft_attribute10               => p_bft_attribute10
    ,p_bft_attribute11               => p_bft_attribute11
    ,p_bft_attribute12               => p_bft_attribute12
    ,p_bft_attribute13               => p_bft_attribute13
    ,p_bft_attribute14               => p_bft_attribute14
    ,p_bft_attribute15               => p_bft_attribute15
    ,p_bft_attribute16               => p_bft_attribute16
    ,p_bft_attribute17               => p_bft_attribute17
    ,p_bft_attribute18               => p_bft_attribute18
    ,p_bft_attribute19               => p_bft_attribute19
    ,p_bft_attribute20               => p_bft_attribute20
    ,p_bft_attribute21               => p_bft_attribute21
    ,p_bft_attribute22               => p_bft_attribute22
    ,p_bft_attribute23               => p_bft_attribute23
    ,p_bft_attribute24               => p_bft_attribute24
    ,p_bft_attribute25               => p_bft_attribute25
    ,p_bft_attribute26               => p_bft_attribute26
    ,p_bft_attribute27               => p_bft_attribute27
    ,p_bft_attribute28               => p_bft_attribute28
    ,p_bft_attribute29               => p_bft_attribute29
    ,p_bft_attribute30               => p_bft_attribute30
    ,p_request_id                    => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_enrt_perd_id                  => p_enrt_perd_id
    ,p_inelg_action_cd               => p_inelg_action_cd
    ,p_org_hierarchy_id               => p_org_hierarchy_id
    ,p_org_starting_node_id               => p_org_starting_node_id
    ,p_grade_ladder_id               => p_grade_ladder_id
    ,p_asg_events_to_all_sel_dt               => p_asg_events_to_all_sel_dt
    ,p_rate_id               => p_rate_id
    ,p_per_sel_dt_cd               => p_per_sel_dt_cd
    ,p_per_sel_freq_cd               => p_per_sel_freq_cd
    ,p_per_sel_dt_from               => p_per_sel_dt_from
    ,p_per_sel_dt_to               => p_per_sel_dt_to
    ,p_year_from               => p_year_from
    ,p_year_to               => p_year_to
    ,p_cagr_id               => p_cagr_id
    ,p_qual_type               => p_qual_type
    ,p_qual_status               => p_qual_status
    ,p_concat_segs               => p_concat_segs
    ,p_grant_price_val               => p_grant_price_val);
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_benefit_actions
    --
    ben_benefit_actions_bk1.create_benefit_actions_a
      (p_benefit_action_id              =>  l_benefit_action_id
      ,p_process_date                   =>  p_process_date
      ,p_uneai_effective_date           =>  p_uneai_effective_date
      ,p_mode_cd                        =>  p_mode_cd
      ,p_derivable_factors_flag         =>  p_derivable_factors_flag
      ,p_close_uneai_flag               =>  p_close_uneai_flag
      ,p_validate_flag                  =>  p_validate_flag
      ,p_person_id                      =>  p_person_id
      ,p_person_type_id                 =>  p_person_type_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pl_id                          =>  p_pl_id
      ,p_popl_enrt_typ_cycl_id          =>  p_popl_enrt_typ_cycl_id
      ,p_no_programs_flag               =>  p_no_programs_flag
      ,p_no_plans_flag                  =>  p_no_plans_flag
      ,p_comp_selection_rl              =>  p_comp_selection_rl
      ,p_person_selection_rl            =>  p_person_selection_rl
      ,p_ler_id                         =>  p_ler_id
      ,p_organization_id                =>  p_organization_id
      ,p_benfts_grp_id                  =>  p_benfts_grp_id
      ,p_location_id                    =>  p_location_id
      ,p_pstl_zip_rng_id                =>  p_pstl_zip_rng_id
      ,p_rptg_grp_id                    =>  p_rptg_grp_id
      ,p_pl_typ_id                      =>  p_pl_typ_id
      ,p_opt_id                         =>  p_opt_id
      ,p_eligy_prfl_id                  =>  p_eligy_prfl_id
      ,p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_legal_entity_id                =>  p_legal_entity_id
      ,p_payroll_id                     =>  p_payroll_id
      ,p_debug_messages_flag            =>  p_debug_messages_flag
      ,p_cm_trgr_typ_cd                 =>  p_cm_trgr_typ_cd
      ,p_cm_typ_id                      =>  p_cm_typ_id
      ,p_age_fctr_id                    =>  p_age_fctr_id
      ,p_min_age                        =>  p_min_age
      ,p_max_age                        =>  p_max_age
      ,p_los_fctr_id                    =>  p_los_fctr_id
      ,p_min_los                        =>  p_min_los
      ,p_max_los                        =>  p_max_los
      ,p_cmbn_age_los_fctr_id           =>  p_cmbn_age_los_fctr_id
      ,p_min_cmbn                       =>  p_min_cmbn
      ,p_max_cmbn                       =>  p_max_cmbn
      ,p_date_from                      =>  p_date_from
      ,p_elig_enrol_cd                  =>  p_elig_enrol_cd
      ,p_actn_typ_id                    =>  p_actn_typ_id
      ,p_use_fctr_to_sel_flag           =>  p_use_fctr_to_sel_flag
      ,p_los_det_to_use_cd              =>  p_los_det_to_use_cd
      ,p_audit_log_flag                 =>  p_audit_log_flag
      ,p_lmt_prpnip_by_org_flag         =>  p_lmt_prpnip_by_org_flag
      ,p_lf_evt_ocrd_dt                 =>  p_lf_evt_ocrd_dt
      ,p_ptnl_ler_for_per_stat_cd       =>  p_ptnl_ler_for_per_stat_cd
      ,p_bft_attribute_category         =>  p_bft_attribute_category
      ,p_bft_attribute1                 =>  p_bft_attribute1
      ,p_bft_attribute3                 =>  p_bft_attribute3
      ,p_bft_attribute4                 =>  p_bft_attribute4
      ,p_bft_attribute5                 =>  p_bft_attribute5
      ,p_bft_attribute6                 =>  p_bft_attribute6
      ,p_bft_attribute7                 =>  p_bft_attribute7
      ,p_bft_attribute8                 =>  p_bft_attribute8
      ,p_bft_attribute9                 =>  p_bft_attribute9
      ,p_bft_attribute10                =>  p_bft_attribute10
      ,p_bft_attribute11                =>  p_bft_attribute11
      ,p_bft_attribute12                =>  p_bft_attribute12
      ,p_bft_attribute13                =>  p_bft_attribute13
      ,p_bft_attribute14                =>  p_bft_attribute14
      ,p_bft_attribute15                =>  p_bft_attribute15
      ,p_bft_attribute16                =>  p_bft_attribute16
      ,p_bft_attribute17                =>  p_bft_attribute17
      ,p_bft_attribute18                =>  p_bft_attribute18
      ,p_bft_attribute19                =>  p_bft_attribute19
      ,p_bft_attribute20                =>  p_bft_attribute20
      ,p_bft_attribute21                =>  p_bft_attribute21
      ,p_bft_attribute22                =>  p_bft_attribute22
      ,p_bft_attribute23                =>  p_bft_attribute23
      ,p_bft_attribute24                =>  p_bft_attribute24
      ,p_bft_attribute25                =>  p_bft_attribute25
      ,p_bft_attribute26                =>  p_bft_attribute26
      ,p_bft_attribute27                =>  p_bft_attribute27
      ,p_bft_attribute28                =>  p_bft_attribute28
      ,p_bft_attribute29                =>  p_bft_attribute29
      ,p_bft_attribute30                =>  p_bft_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_enrt_perd_id                   =>  p_enrt_perd_id
      ,p_inelg_action_cd                =>  p_inelg_action_cd
      ,p_org_hierarchy_id                =>  p_org_hierarchy_id
      ,p_org_starting_node_id                =>  p_org_starting_node_id
      ,p_grade_ladder_id                =>  p_grade_ladder_id
      ,p_asg_events_to_all_sel_dt                =>  p_asg_events_to_all_sel_dt
      ,p_rate_id                =>  p_rate_id
      ,p_per_sel_dt_cd                =>  p_per_sel_dt_cd
      ,p_per_sel_freq_cd                =>  p_per_sel_freq_cd
      ,p_per_sel_dt_from                =>  p_per_sel_dt_from
      ,p_per_sel_dt_to                =>  p_per_sel_dt_to
      ,p_year_from                =>  p_year_from
      ,p_year_to                =>  p_year_to
      ,p_cagr_id                =>  p_cagr_id
      ,p_qual_type                =>  p_qual_type
      ,p_qual_status                =>  p_qual_status
      ,p_concat_segs                =>  p_concat_segs
      ,p_grant_price_val                =>  p_grant_price_val);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_benefit_actions'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of create_benefit_actions
    --
  end;
  --
  /*
  hr_utility.set_location(l_proc, 60);
  */

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_benefit_action_id := l_benefit_action_id;
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
    ROLLBACK TO create_benefit_actions;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_benefit_action_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_benefit_actions;
    --nocopy, reset
    p_benefit_action_id := null;
    p_object_version_number  := null;
    raise;
    --
end create_benefit_actions;
-- ----------------------------------------------------------------------------
-- |------------------------< create_perf_benefit_actions >-------------------|
-- ----------------------------------------------------------------------------
--
procedure create_perf_benefit_actions
  (p_validate                       in  boolean   default false
  ,p_benefit_action_id              out nocopy number
  ,p_process_date                   in  date      default null
  ,p_uneai_effective_date           in  date      default null
  ,p_mode_cd                        in  varchar2  default null
  ,p_derivable_factors_flag         in  varchar2  default null
  ,p_close_uneai_flag               in  varchar2  default 'N'
  ,p_validate_flag                  in  varchar2  default null
  ,p_person_id                      in  number    default null
  ,p_person_type_id                 in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_popl_enrt_typ_cycl_id          in  number    default null
  ,p_no_programs_flag               in  varchar2  default null
  ,p_no_plans_flag                  in  varchar2  default null
  ,p_comp_selection_rl              in  number    default null
  ,p_person_selection_rl            in  number    default null
  ,p_ler_id                         in  number    default null
  ,p_organization_id                in  number    default null
  ,p_benfts_grp_id                  in  number    default null
  ,p_location_id                    in  number    default null
  ,p_pstl_zip_rng_id                in  number    default null
  ,p_rptg_grp_id                    in  number    default null
  ,p_pl_typ_id                      in  number    default null
  ,p_opt_id                         in  number    default null
  ,p_eligy_prfl_id                  in  number    default null
  ,p_vrbl_rt_prfl_id                in  number    default null
  ,p_legal_entity_id                in  number    default null
  ,p_payroll_id                     in  number    default null
  ,p_debug_messages_flag            in  varchar2  default null
  ,p_cm_trgr_typ_cd                 in  varchar2  default null
  ,p_cm_typ_id                      in  number    default null
  ,p_age_fctr_id                    in  number    default null
  ,p_min_age                        in  number    default null
  ,p_max_age                        in  number    default null
  ,p_los_fctr_id                    in  number    default null
  ,p_min_los                        in  number    default null
  ,p_max_los                        in  number    default null
  ,p_cmbn_age_los_fctr_id           in  number    default null
  ,p_min_cmbn                       in  number    default null
  ,p_max_cmbn                       in  number    default null
  ,p_date_from                      in  date      default null
  ,p_elig_enrol_cd                  in  varchar2  default null
  ,p_actn_typ_id                    in  number    default null
  ,p_use_fctr_to_sel_flag           in  varchar2  default 'N'
  ,p_los_det_to_use_cd              in  varchar2  default null
  ,p_audit_log_flag                 in  varchar2  default 'N'
  ,p_lmt_prpnip_by_org_flag         in  varchar2  default 'N'
  ,p_lf_evt_ocrd_dt                 in  date      default null
  ,p_ptnl_ler_for_per_stat_cd       in  varchar2  default null
  ,p_bft_attribute_category         in  varchar2  default null
  ,p_bft_attribute1                 in  varchar2  default null
  ,p_bft_attribute3                 in  varchar2  default null
  ,p_bft_attribute4                 in  varchar2  default null
  ,p_bft_attribute5                 in  varchar2  default null
  ,p_bft_attribute6                 in  varchar2  default null
  ,p_bft_attribute7                 in  varchar2  default null
  ,p_bft_attribute8                 in  varchar2  default null
  ,p_bft_attribute9                 in  varchar2  default null
  ,p_bft_attribute10                in  varchar2  default null
  ,p_bft_attribute11                in  varchar2  default null
  ,p_bft_attribute12                in  varchar2  default null
  ,p_bft_attribute13                in  varchar2  default null
  ,p_bft_attribute14                in  varchar2  default null
  ,p_bft_attribute15                in  varchar2  default null
  ,p_bft_attribute16                in  varchar2  default null
  ,p_bft_attribute17                in  varchar2  default null
  ,p_bft_attribute18                in  varchar2  default null
  ,p_bft_attribute19                in  varchar2  default null
  ,p_bft_attribute20                in  varchar2  default null
  ,p_bft_attribute21                in  varchar2  default null
  ,p_bft_attribute22                in  varchar2  default null
  ,p_bft_attribute23                in  varchar2  default null
  ,p_bft_attribute24                in  varchar2  default null
  ,p_bft_attribute25                in  varchar2  default null
  ,p_bft_attribute26                in  varchar2  default null
  ,p_bft_attribute27                in  varchar2  default null
  ,p_bft_attribute28                in  varchar2  default null
  ,p_bft_attribute29                in  varchar2  default null
  ,p_bft_attribute30                in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_enrt_perd_id                   in  number    default null
  ,p_inelg_action_cd                in  varchar2  default null
  ,p_org_hierarchy_id                in  number  default null
  ,p_org_starting_node_id                in  number  default null
  ,p_grade_ladder_id                in  number  default null
  ,p_asg_events_to_all_sel_dt                in  varchar2  default null
  ,p_rate_id                in  number  default null
  ,p_per_sel_dt_cd                in  varchar2  default null
  ,p_per_sel_freq_cd                in  varchar2  default null
  ,p_per_sel_dt_from                in  date  default null
  ,p_per_sel_dt_to                in  date  default null
  ,p_year_from                in  number  default null
  ,p_year_to                in  number  default null
  ,p_cagr_id                in  number  default null
  ,p_qual_type                in  number  default null
  ,p_qual_status                in  varchar2  default null
  ,p_concat_segs                in  varchar2  default null
  ,p_grant_price_val                in  number    default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_benefit_action_id     ben_benefit_actions.benefit_action_id%TYPE;
  l_proc                  varchar2(72) := g_package||'create_perf_benefit_actions';
  l_object_version_number ben_benefit_actions.object_version_number%TYPE;
  --
begin
  --

  hr_utility.set_location('Entering:'|| l_proc, 10);

  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_perf_benefit_actions;
  --
/*
  hr_utility.set_location(l_proc, 20);
*/
  --
  -- Process Logic
  --
  l_object_version_number := 1;
  --
  select ben_benefit_actions_s.nextval
  into   l_benefit_action_id
  from   sys.dual;
  --
  insert into ben_benefit_actions
    (benefit_action_id
    ,process_date
    ,uneai_effective_date
    ,mode_cd
    ,derivable_factors_flag
    ,close_uneai_flag
    ,validate_flag
    ,person_id
    ,person_type_id
    ,pgm_id
    ,business_group_id
    ,pl_id
    ,popl_enrt_typ_cycl_id
    ,no_programs_flag
    ,no_plans_flag
    ,comp_selection_rl
    ,person_selection_rl
    ,ler_id
    ,organization_id
    ,benfts_grp_id
    ,location_id
    ,pstl_zip_rng_id
    ,rptg_grp_id
    ,pl_typ_id
    ,opt_id
    ,eligy_prfl_id
    ,vrbl_rt_prfl_id
    ,legal_entity_id
    ,payroll_id
    ,debug_messages_flag
    ,cm_trgr_typ_cd
    ,cm_typ_id
    ,age_fctr_id
    ,min_age
    ,max_age
    ,los_fctr_id
    ,min_los
    ,max_los
    ,cmbn_age_los_fctr_id
    ,min_cmbn
    ,max_cmbn
    ,date_from
    ,elig_enrol_cd
    ,actn_typ_id
    ,use_fctr_to_sel_flag
    ,los_det_to_use_cd
    ,audit_log_flag
    ,lmt_prpnip_by_org_flag
    ,lf_evt_ocrd_dt
    ,ptnl_ler_for_per_stat_cd
    ,bft_attribute_category
    ,bft_attribute1
    ,bft_attribute3
    ,bft_attribute4
    ,bft_attribute5
    ,bft_attribute6
    ,bft_attribute7
    ,bft_attribute8
    ,bft_attribute9
    ,bft_attribute10
    ,bft_attribute11
    ,bft_attribute12
    ,bft_attribute13
    ,bft_attribute14
    ,bft_attribute15
    ,bft_attribute16
    ,bft_attribute17
    ,bft_attribute18
    ,bft_attribute19
    ,bft_attribute20
    ,bft_attribute21
    ,bft_attribute22
    ,bft_attribute23
    ,bft_attribute24
    ,bft_attribute25
    ,bft_attribute26
    ,bft_attribute27
    ,bft_attribute28
    ,bft_attribute29
    ,bft_attribute30
    ,request_id
    ,program_application_id
    ,program_id
    ,program_update_date
    ,object_version_number
    ,enrt_perd_id
    ,inelg_action_cd
    ,org_hierarchy_id
    ,org_starting_node_id
    ,grade_ladder_id
    ,asg_events_to_all_sel_dt
    ,rate_id
    ,per_sel_dt_cd
    ,per_sel_freq_cd
    ,per_sel_dt_from
    ,per_sel_dt_to
    ,year_from
    ,year_to
    ,cagr_id
    ,qual_type
    ,qual_status
    ,concat_segs
    ,grant_price_val)
  values
    (l_benefit_action_id
    ,p_process_date
    ,p_uneai_effective_date
    ,p_mode_cd
    ,p_derivable_factors_flag
    ,p_close_uneai_flag
    ,p_validate_flag
    ,p_person_id
    ,p_person_type_id
    ,p_pgm_id
    ,p_business_group_id
    ,p_pl_id
    ,p_popl_enrt_typ_cycl_id
    ,p_no_programs_flag
    ,p_no_plans_flag
    ,p_comp_selection_rl
    ,p_person_selection_rl
    ,p_ler_id
    ,p_organization_id
    ,p_benfts_grp_id
    ,p_location_id
    ,p_pstl_zip_rng_id
    ,p_rptg_grp_id
    ,p_pl_typ_id
    ,p_opt_id
    ,p_eligy_prfl_id
    ,p_vrbl_rt_prfl_id
    ,p_legal_entity_id
    ,p_payroll_id
    ,p_debug_messages_flag
    ,p_cm_trgr_typ_cd
    ,p_cm_typ_id
    ,p_age_fctr_id
    ,p_min_age
    ,p_max_age
    ,p_los_fctr_id
    ,p_min_los
    ,p_max_los
    ,p_cmbn_age_los_fctr_id
    ,p_min_cmbn
    ,p_max_cmbn
    ,p_date_from
    ,p_elig_enrol_cd
    ,p_actn_typ_id
    ,p_use_fctr_to_sel_flag
    ,p_los_det_to_use_cd
    ,p_audit_log_flag
    ,p_lmt_prpnip_by_org_flag
    ,p_lf_evt_ocrd_dt
    ,p_ptnl_ler_for_per_stat_cd
    ,p_bft_attribute_category
    ,p_bft_attribute1
    ,p_bft_attribute3
    ,p_bft_attribute4
    ,p_bft_attribute5
    ,p_bft_attribute6
    ,p_bft_attribute7
    ,p_bft_attribute8
    ,p_bft_attribute9
    ,p_bft_attribute10
    ,p_bft_attribute11
    ,p_bft_attribute12
    ,p_bft_attribute13
    ,p_bft_attribute14
    ,p_bft_attribute15
    ,p_bft_attribute16
    ,p_bft_attribute17
    ,p_bft_attribute18
    ,p_bft_attribute19
    ,p_bft_attribute20
    ,p_bft_attribute21
    ,p_bft_attribute22
    ,p_bft_attribute23
    ,p_bft_attribute24
    ,p_bft_attribute25
    ,p_bft_attribute26
    ,p_bft_attribute27
    ,p_bft_attribute28
    ,p_bft_attribute29
    ,p_bft_attribute30
    ,p_request_id
    ,p_program_application_id
    ,p_program_id
    ,p_program_update_date
    ,l_object_version_number
    ,p_enrt_perd_id
    ,p_inelg_action_cd
    ,p_org_hierarchy_id
    ,p_org_starting_node_id
    ,p_grade_ladder_id
    ,p_asg_events_to_all_sel_dt
    ,p_rate_id
    ,p_per_sel_dt_cd
    ,p_per_sel_freq_cd
    ,p_per_sel_dt_from
    ,p_per_sel_dt_to
    ,p_year_from
    ,p_year_to
    ,p_cagr_id
    ,p_qual_type
    ,p_qual_status
    ,p_concat_segs
    ,p_grant_price_val);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  -- Set all output arguments
  --
  p_benefit_action_id := l_benefit_action_id;
  p_object_version_number := l_object_version_number;
  --
/*
  hr_utility.set_location(' Leaving:'||l_proc, 70);
*/
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_perf_benefit_actions;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_benefit_action_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_perf_benefit_actions;
    -- nocopy, reset
    p_benefit_action_id := null;
    p_object_version_number  := null;
    raise;
    --
end create_perf_benefit_actions;
-- ----------------------------------------------------------------------------
-- |------------------------< update_benefit_actions >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_benefit_actions
  (p_validate                       in  boolean   default false
  ,p_benefit_action_id              in  number
  ,p_process_date                   in  date      default hr_api.g_date
  ,p_uneai_effective_date           in  date      default hr_api.g_date
  ,p_mode_cd                        in  varchar2  default hr_api.g_varchar2
  ,p_derivable_factors_flag         in  varchar2  default hr_api.g_varchar2
  ,p_close_uneai_flag               in  varchar2  default hr_api.g_varchar2
  ,p_validate_flag                  in  varchar2  default hr_api.g_varchar2
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_person_type_id                 in  number    default hr_api.g_number
  ,p_pgm_id                         in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_popl_enrt_typ_cycl_id          in  number    default hr_api.g_number
  ,p_no_programs_flag               in  varchar2  default hr_api.g_varchar2
  ,p_no_plans_flag                  in  varchar2  default hr_api.g_varchar2
  ,p_comp_selection_rl              in  number    default hr_api.g_number
  ,p_person_selection_rl            in  number    default hr_api.g_number
  ,p_ler_id                         in  number    default hr_api.g_number
  ,p_organization_id                in  number    default hr_api.g_number
  ,p_benfts_grp_id                  in  number    default hr_api.g_number
  ,p_location_id                    in  number    default hr_api.g_number
  ,p_pstl_zip_rng_id                in  number    default hr_api.g_number
  ,p_rptg_grp_id                    in  number    default hr_api.g_number
  ,p_pl_typ_id                      in  number    default hr_api.g_number
  ,p_opt_id                         in  number    default hr_api.g_number
  ,p_eligy_prfl_id                  in  number    default hr_api.g_number
  ,p_vrbl_rt_prfl_id                in  number    default hr_api.g_number
  ,p_legal_entity_id                in  number    default hr_api.g_number
  ,p_payroll_id                     in  number    default hr_api.g_number
  ,p_debug_messages_flag            in  varchar2  default hr_api.g_varchar2
  ,p_cm_trgr_typ_cd                 in  varchar2  default hr_api.g_varchar2
  ,p_cm_typ_id                      in  number    default hr_api.g_number
  ,p_age_fctr_id                    in  number    default hr_api.g_number
  ,p_min_age                        in  number    default hr_api.g_number
  ,p_max_age                        in  number    default hr_api.g_number
  ,p_los_fctr_id                    in  number    default hr_api.g_number
  ,p_min_los                        in  number    default hr_api.g_number
  ,p_max_los                        in  number    default hr_api.g_number
  ,p_cmbn_age_los_fctr_id           in  number    default hr_api.g_number
  ,p_min_cmbn                       in  number    default hr_api.g_number
  ,p_max_cmbn                       in  number    default hr_api.g_number
  ,p_date_from                      in  date      default hr_api.g_date
  ,p_elig_enrol_cd                  in  varchar2  default hr_api.g_varchar2
  ,p_actn_typ_id                    in  number    default hr_api.g_number
  ,p_use_fctr_to_sel_flag           in  varchar2  default hr_api.g_varchar2
  ,p_los_det_to_use_cd              in  varchar2  default hr_api.g_varchar2
  ,p_audit_log_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_lmt_prpnip_by_org_flag         in  varchar2  default hr_api.g_varchar2
  ,p_lf_evt_ocrd_dt                 in  date      default hr_api.g_date
  ,p_ptnl_ler_for_per_stat_cd       in  varchar2  default hr_api.g_varchar2
  ,p_bft_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_bft_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_bft_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_bft_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_bft_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_bft_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_bft_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_bft_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_bft_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_bft_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_bft_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_bft_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_bft_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_bft_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_bft_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_bft_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_bft_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_bft_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_bft_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_bft_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_bft_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_bft_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_bft_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_bft_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_bft_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_bft_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_bft_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_bft_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_bft_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_bft_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_request_id                     in  number
  ,p_program_application_id         in  number
  ,p_program_id                     in  number
  ,p_program_update_date            in  date
  ,p_object_version_number          in  out nocopy number
  ,p_effective_date                 in  date
  ,p_enrt_perd_id                   in  number    default hr_api.g_number
  ,p_inelg_action_cd                in  varchar2  default hr_api.g_varchar2
  ,p_org_hierarchy_id                in  number  default hr_api.g_number
  ,p_org_starting_node_id                in  number  default hr_api.g_number
  ,p_grade_ladder_id                in  number  default hr_api.g_number
  ,p_asg_events_to_all_sel_dt                in  varchar2  default hr_api.g_varchar2
  ,p_rate_id                in  number  default hr_api.g_number
  ,p_per_sel_dt_cd                in  varchar2  default hr_api.g_varchar2
  ,p_per_sel_freq_cd                in  varchar2  default hr_api.g_varchar2
  ,p_per_sel_dt_from                in  date  default hr_api.g_date
  ,p_per_sel_dt_to                in  date  default hr_api.g_date
  ,p_year_from                in  number  default hr_api.g_number
  ,p_year_to                in  number  default hr_api.g_number
  ,p_cagr_id                in  number  default hr_api.g_number
  ,p_qual_type                in  number  default hr_api.g_number
  ,p_qual_status                in  varchar2  default hr_api.g_varchar2
  ,p_concat_segs                in  varchar2  default hr_api.g_varchar2
  ,p_grant_price_val                in  number    default hr_api.g_number) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'update_benefit_actions';
  l_object_version_number ben_benefit_actions.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_benefit_actions;
  --
  /*hr_utility.set_location(l_proc, 20); */
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_benefit_actions
    --
    ben_benefit_actions_bk2.update_benefit_actions_b
      (p_benefit_action_id              =>  p_benefit_action_id
      ,p_process_date                   =>  p_process_date
      ,p_uneai_effective_date                   =>  p_uneai_effective_date
      ,p_mode_cd                        =>  p_mode_cd
      ,p_derivable_factors_flag         =>  p_derivable_factors_flag
      ,p_close_uneai_flag               =>  p_close_uneai_flag
      ,p_validate_flag                  =>  p_validate_flag
      ,p_person_id                      =>  p_person_id
      ,p_person_type_id                 =>  p_person_type_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pl_id                          =>  p_pl_id
      ,p_popl_enrt_typ_cycl_id          =>  p_popl_enrt_typ_cycl_id
      ,p_no_programs_flag               =>  p_no_programs_flag
      ,p_no_plans_flag                  =>  p_no_plans_flag
      ,p_comp_selection_rl              =>  p_comp_selection_rl
      ,p_person_selection_rl            =>  p_person_selection_rl
      ,p_ler_id                         =>  p_ler_id
      ,p_organization_id                =>  p_organization_id
      ,p_benfts_grp_id                  =>  p_benfts_grp_id
      ,p_location_id                    =>  p_location_id
      ,p_pstl_zip_rng_id                =>  p_pstl_zip_rng_id
      ,p_rptg_grp_id                    =>  p_rptg_grp_id
      ,p_pl_typ_id                      =>  p_pl_typ_id
      ,p_opt_id                         =>  p_opt_id
      ,p_eligy_prfl_id                  =>  p_eligy_prfl_id
      ,p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_legal_entity_id                =>  p_legal_entity_id
      ,p_payroll_id                     =>  p_payroll_id
      ,p_debug_messages_flag            =>  p_debug_messages_flag
      ,p_cm_trgr_typ_cd                 =>  p_cm_trgr_typ_cd
      ,p_cm_typ_id                      =>  p_cm_typ_id
      ,p_age_fctr_id                    =>  p_age_fctr_id
      ,p_min_age                        =>  p_min_age
      ,p_max_age                        =>  p_max_age
      ,p_los_fctr_id                    =>  p_los_fctr_id
      ,p_min_los                        =>  p_min_los
      ,p_max_los                        =>  p_max_los
      ,p_cmbn_age_los_fctr_id           =>  p_cmbn_age_los_fctr_id
      ,p_min_cmbn                       =>  p_min_cmbn
      ,p_max_cmbn                       =>  p_max_cmbn
      ,p_date_from                      =>  p_date_from
      ,p_elig_enrol_cd                  =>  p_elig_enrol_cd
      ,p_actn_typ_id                    =>  p_actn_typ_id
      ,p_use_fctr_to_sel_flag           =>  p_use_fctr_to_sel_flag
      ,p_los_det_to_use_cd              =>  p_los_det_to_use_cd
      ,p_audit_log_flag                 =>  p_audit_log_flag
      ,p_lmt_prpnip_by_org_flag         =>  p_lmt_prpnip_by_org_flag
      ,p_lf_evt_ocrd_dt                 =>  p_lf_evt_ocrd_dt
      ,p_ptnl_ler_for_per_stat_cd       =>  p_ptnl_ler_for_per_stat_cd
      ,p_bft_attribute_category         =>  p_bft_attribute_category
      ,p_bft_attribute1                 =>  p_bft_attribute1
      ,p_bft_attribute3                 =>  p_bft_attribute3
      ,p_bft_attribute4                 =>  p_bft_attribute4
      ,p_bft_attribute5                 =>  p_bft_attribute5
      ,p_bft_attribute6                 =>  p_bft_attribute6
      ,p_bft_attribute7                 =>  p_bft_attribute7
      ,p_bft_attribute8                 =>  p_bft_attribute8
      ,p_bft_attribute9                 =>  p_bft_attribute9
      ,p_bft_attribute10                =>  p_bft_attribute10
      ,p_bft_attribute11                =>  p_bft_attribute11
      ,p_bft_attribute12                =>  p_bft_attribute12
      ,p_bft_attribute13                =>  p_bft_attribute13
      ,p_bft_attribute14                =>  p_bft_attribute14
      ,p_bft_attribute15                =>  p_bft_attribute15
      ,p_bft_attribute16                =>  p_bft_attribute16
      ,p_bft_attribute17                =>  p_bft_attribute17
      ,p_bft_attribute18                =>  p_bft_attribute18
      ,p_bft_attribute19                =>  p_bft_attribute19
      ,p_bft_attribute20                =>  p_bft_attribute20
      ,p_bft_attribute21                =>  p_bft_attribute21
      ,p_bft_attribute22                =>  p_bft_attribute22
      ,p_bft_attribute23                =>  p_bft_attribute23
      ,p_bft_attribute24                =>  p_bft_attribute24
      ,p_bft_attribute25                =>  p_bft_attribute25
      ,p_bft_attribute26                =>  p_bft_attribute26
      ,p_bft_attribute27                =>  p_bft_attribute27
      ,p_bft_attribute28                =>  p_bft_attribute28
      ,p_bft_attribute29                =>  p_bft_attribute29
      ,p_bft_attribute30                =>  p_bft_attribute30
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_enrt_perd_id                   =>  p_enrt_perd_id
      ,p_inelg_action_cd                =>  p_inelg_action_cd
      ,p_org_hierarchy_id                =>  p_org_hierarchy_id
      ,p_org_starting_node_id                =>  p_org_starting_node_id
      ,p_grade_ladder_id                =>  p_grade_ladder_id
      ,p_asg_events_to_all_sel_dt                =>  p_asg_events_to_all_sel_dt
      ,p_rate_id                =>  p_rate_id
      ,p_per_sel_dt_cd                =>  p_per_sel_dt_cd
      ,p_per_sel_freq_cd                =>  p_per_sel_freq_cd
      ,p_per_sel_dt_from                =>  p_per_sel_dt_from
      ,p_per_sel_dt_to                =>  p_per_sel_dt_to
      ,p_year_from                =>  p_year_from
      ,p_year_to                =>  p_year_to
      ,p_cagr_id                =>  p_cagr_id
      ,p_qual_type                =>  p_qual_type
      ,p_qual_status                =>  p_qual_status
      ,p_concat_segs                =>  p_concat_segs
      ,p_grant_price_val                =>  p_grant_price_val);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_benefit_actions'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of update_benefit_actions
    --
  end;
  --
  ben_bft_upd.upd
    (p_benefit_action_id             => p_benefit_action_id
    ,p_process_date                  => p_process_date
    ,p_uneai_effective_date          => p_uneai_effective_date
    ,p_mode_cd                       => p_mode_cd
    ,p_derivable_factors_flag        => p_derivable_factors_flag
    ,p_close_uneai_flag              => p_close_uneai_flag
    ,p_validate_flag                 => p_validate_flag
    ,p_person_id                     => p_person_id
    ,p_person_type_id                => p_person_type_id
    ,p_pgm_id                        => p_pgm_id
    ,p_business_group_id             => p_business_group_id
    ,p_pl_id                         => p_pl_id
    ,p_popl_enrt_typ_cycl_id         => p_popl_enrt_typ_cycl_id
    ,p_no_programs_flag              => p_no_programs_flag
    ,p_no_plans_flag                 => p_no_plans_flag
    ,p_comp_selection_rl             => p_comp_selection_rl
    ,p_person_selection_rl           => p_person_selection_rl
    ,p_ler_id                        => p_ler_id
    ,p_organization_id               => p_organization_id
    ,p_benfts_grp_id                 => p_benfts_grp_id
    ,p_location_id                   => p_location_id
    ,p_pstl_zip_rng_id               => p_pstl_zip_rng_id
    ,p_rptg_grp_id                   => p_rptg_grp_id
    ,p_pl_typ_id                     => p_pl_typ_id
    ,p_opt_id                        => p_opt_id
    ,p_eligy_prfl_id                 => p_eligy_prfl_id
    ,p_vrbl_rt_prfl_id               => p_vrbl_rt_prfl_id
    ,p_legal_entity_id               => p_legal_entity_id
    ,p_payroll_id                    => p_payroll_id
    ,p_debug_messages_flag           => p_debug_messages_flag
    ,p_cm_trgr_typ_cd                => p_cm_trgr_typ_cd
    ,p_cm_typ_id                     => p_cm_typ_id
    ,p_age_fctr_id                   => p_age_fctr_id
    ,p_min_age                       => p_min_age
    ,p_max_age                       => p_max_age
    ,p_los_fctr_id                   => p_los_fctr_id
    ,p_min_los                       => p_min_los
    ,p_max_los                       => p_max_los
    ,p_cmbn_age_los_fctr_id          => p_cmbn_age_los_fctr_id
    ,p_min_cmbn                      => p_min_cmbn
    ,p_max_cmbn                      => p_max_cmbn
    ,p_date_from                     => p_date_from
    ,p_elig_enrol_cd                 => p_elig_enrol_cd
    ,p_actn_typ_id                   => p_actn_typ_id
    ,p_use_fctr_to_sel_flag          => p_use_fctr_to_sel_flag
    ,p_los_det_to_use_cd             => p_los_det_to_use_cd
    ,p_audit_log_flag                => p_audit_log_flag
    ,p_lmt_prpnip_by_org_flag        => p_lmt_prpnip_by_org_flag
    ,p_lf_evt_ocrd_dt                => p_lf_evt_ocrd_dt
    ,p_ptnl_ler_for_per_stat_cd      => p_ptnl_ler_for_per_stat_cd
    ,p_bft_attribute_category        => p_bft_attribute_category
    ,p_bft_attribute1                => p_bft_attribute1
    ,p_bft_attribute3                => p_bft_attribute3
    ,p_bft_attribute4                => p_bft_attribute4
    ,p_bft_attribute5                => p_bft_attribute5
    ,p_bft_attribute6                => p_bft_attribute6
    ,p_bft_attribute7                => p_bft_attribute7
    ,p_bft_attribute8                => p_bft_attribute8
    ,p_bft_attribute9                => p_bft_attribute9
    ,p_bft_attribute10               => p_bft_attribute10
    ,p_bft_attribute11               => p_bft_attribute11
    ,p_bft_attribute12               => p_bft_attribute12
    ,p_bft_attribute13               => p_bft_attribute13
    ,p_bft_attribute14               => p_bft_attribute14
    ,p_bft_attribute15               => p_bft_attribute15
    ,p_bft_attribute16               => p_bft_attribute16
    ,p_bft_attribute17               => p_bft_attribute17
    ,p_bft_attribute18               => p_bft_attribute18
    ,p_bft_attribute19               => p_bft_attribute19
    ,p_bft_attribute20               => p_bft_attribute20
    ,p_bft_attribute21               => p_bft_attribute21
    ,p_bft_attribute22               => p_bft_attribute22
    ,p_bft_attribute23               => p_bft_attribute23
    ,p_bft_attribute24               => p_bft_attribute24
    ,p_bft_attribute25               => p_bft_attribute25
    ,p_bft_attribute26               => p_bft_attribute26
    ,p_bft_attribute27               => p_bft_attribute27
    ,p_bft_attribute28               => p_bft_attribute28
    ,p_bft_attribute29               => p_bft_attribute29
    ,p_bft_attribute30               => p_bft_attribute30
    ,p_request_id                    => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_enrt_perd_id                  => p_enrt_perd_id
    ,p_inelg_action_cd               => p_inelg_action_cd
    ,p_org_hierarchy_id               => p_org_hierarchy_id
    ,p_org_starting_node_id               => p_org_starting_node_id
    ,p_grade_ladder_id               => p_grade_ladder_id
    ,p_asg_events_to_all_sel_dt               => p_asg_events_to_all_sel_dt
    ,p_rate_id               => p_rate_id
    ,p_per_sel_dt_cd               => p_per_sel_dt_cd
    ,p_per_sel_freq_cd               => p_per_sel_freq_cd
    ,p_per_sel_dt_from               => p_per_sel_dt_from
    ,p_per_sel_dt_to               => p_per_sel_dt_to
    ,p_year_from               => p_year_from
    ,p_year_to               => p_year_to
    ,p_cagr_id               => p_cagr_id
    ,p_qual_type               => p_qual_type
    ,p_qual_status               => p_qual_status
    ,p_concat_segs               => p_concat_segs
    ,p_grant_price_val               => p_grant_price_val);
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_benefit_actions
    --
    ben_benefit_actions_bk2.update_benefit_actions_a
      (p_benefit_action_id              =>  p_benefit_action_id
      ,p_process_date                   =>  p_process_date
      ,p_uneai_effective_date                   =>  p_uneai_effective_date
      ,p_mode_cd                        =>  p_mode_cd
      ,p_derivable_factors_flag         =>  p_derivable_factors_flag
      ,p_close_uneai_flag               =>  p_close_uneai_flag
      ,p_validate_flag                  =>  p_validate_flag
      ,p_person_id                      =>  p_person_id
      ,p_person_type_id                 =>  p_person_type_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pl_id                          =>  p_pl_id
      ,p_popl_enrt_typ_cycl_id          =>  p_popl_enrt_typ_cycl_id
      ,p_no_programs_flag               =>  p_no_programs_flag
      ,p_no_plans_flag                  =>  p_no_plans_flag
      ,p_comp_selection_rl              =>  p_comp_selection_rl
      ,p_person_selection_rl            =>  p_person_selection_rl
      ,p_ler_id                         =>  p_ler_id
      ,p_organization_id                =>  p_organization_id
      ,p_benfts_grp_id                  =>  p_benfts_grp_id
      ,p_location_id                    =>  p_location_id
      ,p_pstl_zip_rng_id                =>  p_pstl_zip_rng_id
      ,p_rptg_grp_id                    =>  p_rptg_grp_id
      ,p_pl_typ_id                      =>  p_pl_typ_id
      ,p_opt_id                         =>  p_opt_id
      ,p_eligy_prfl_id                  =>  p_eligy_prfl_id
      ,p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_legal_entity_id                =>  p_legal_entity_id
      ,p_payroll_id                     =>  p_payroll_id
      ,p_debug_messages_flag            =>  p_debug_messages_flag
      ,p_cm_trgr_typ_cd                 =>  p_cm_trgr_typ_cd
      ,p_cm_typ_id                      =>  p_cm_typ_id
      ,p_age_fctr_id                    =>  p_age_fctr_id
      ,p_min_age                        =>  p_min_age
      ,p_max_age                        =>  p_max_age
      ,p_los_fctr_id                    =>  p_los_fctr_id
      ,p_min_los                        =>  p_min_los
      ,p_max_los                        =>  p_max_los
      ,p_cmbn_age_los_fctr_id           =>  p_cmbn_age_los_fctr_id
      ,p_min_cmbn                       =>  p_min_cmbn
      ,p_max_cmbn                       =>  p_max_cmbn
      ,p_date_from                      =>  p_date_from
      ,p_elig_enrol_cd                  =>  p_elig_enrol_cd
      ,p_actn_typ_id                    =>  p_actn_typ_id
      ,p_use_fctr_to_sel_flag           =>  p_use_fctr_to_sel_flag
      ,p_los_det_to_use_cd              =>  p_los_det_to_use_cd
      ,p_audit_log_flag                 =>  p_audit_log_flag
      ,p_lmt_prpnip_by_org_flag         =>  p_lmt_prpnip_by_org_flag
      ,p_lf_evt_ocrd_dt                 =>  p_lf_evt_ocrd_dt
      ,p_ptnl_ler_for_per_stat_cd       =>  p_ptnl_ler_for_per_stat_cd
      ,p_bft_attribute_category         =>  p_bft_attribute_category
      ,p_bft_attribute1                 =>  p_bft_attribute1
      ,p_bft_attribute3                 =>  p_bft_attribute3
      ,p_bft_attribute4                 =>  p_bft_attribute4
      ,p_bft_attribute5                 =>  p_bft_attribute5
      ,p_bft_attribute6                 =>  p_bft_attribute6
      ,p_bft_attribute7                 =>  p_bft_attribute7
      ,p_bft_attribute8                 =>  p_bft_attribute8
      ,p_bft_attribute9                 =>  p_bft_attribute9
      ,p_bft_attribute10                =>  p_bft_attribute10
      ,p_bft_attribute11                =>  p_bft_attribute11
      ,p_bft_attribute12                =>  p_bft_attribute12
      ,p_bft_attribute13                =>  p_bft_attribute13
      ,p_bft_attribute14                =>  p_bft_attribute14
      ,p_bft_attribute15                =>  p_bft_attribute15
      ,p_bft_attribute16                =>  p_bft_attribute16
      ,p_bft_attribute17                =>  p_bft_attribute17
      ,p_bft_attribute18                =>  p_bft_attribute18
      ,p_bft_attribute19                =>  p_bft_attribute19
      ,p_bft_attribute20                =>  p_bft_attribute20
      ,p_bft_attribute21                =>  p_bft_attribute21
      ,p_bft_attribute22                =>  p_bft_attribute22
      ,p_bft_attribute23                =>  p_bft_attribute23
      ,p_bft_attribute24                =>  p_bft_attribute24
      ,p_bft_attribute25                =>  p_bft_attribute25
      ,p_bft_attribute26                =>  p_bft_attribute26
      ,p_bft_attribute27                =>  p_bft_attribute27
      ,p_bft_attribute28                =>  p_bft_attribute28
      ,p_bft_attribute29                =>  p_bft_attribute29
      ,p_bft_attribute30                =>  p_bft_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_enrt_perd_id                   =>  p_enrt_perd_id
      ,p_inelg_action_cd                =>  p_inelg_action_cd
      ,p_org_hierarchy_id                =>  p_org_hierarchy_id
      ,p_org_starting_node_id                =>  p_org_starting_node_id
      ,p_grade_ladder_id                =>  p_grade_ladder_id
      ,p_asg_events_to_all_sel_dt                =>  p_asg_events_to_all_sel_dt
      ,p_rate_id                =>  p_rate_id
      ,p_per_sel_dt_cd                =>  p_per_sel_dt_cd
      ,p_per_sel_freq_cd                =>  p_per_sel_freq_cd
      ,p_per_sel_dt_from                =>  p_per_sel_dt_from
      ,p_per_sel_dt_to                =>  p_per_sel_dt_to
      ,p_year_from                =>  p_year_from
      ,p_year_to                =>  p_year_to
      ,p_cagr_id                =>  p_cagr_id
      ,p_qual_type                =>  p_qual_type
      ,p_qual_status                =>  p_qual_status
      ,p_concat_segs                =>  p_concat_segs
      ,p_grant_price_val                =>  p_grant_price_val);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_benefit_actions'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of update_benefit_actions
    --
  end;
  --
  /*hr_utility.set_location(l_proc, 60); */
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
    ROLLBACK TO update_benefit_actions;
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
    ROLLBACK TO update_benefit_actions;
    raise;
    --
end update_benefit_actions;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_benefit_actions >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_benefit_actions
  (p_validate                       in  boolean  default false
  ,p_benefit_action_id              in  number
  ,p_object_version_number          in  out nocopy number
  ,p_effective_date                 in  date) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_benefit_actions';
  l_object_version_number ben_benefit_actions.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_benefit_actions;
  --
  /*hr_utility.set_location(l_proc, 20); */
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_benefit_actions
    --
    ben_benefit_actions_bk3.delete_benefit_actions_b
      (p_benefit_action_id              => p_benefit_action_id
      ,p_object_version_number          => p_object_version_number
      ,p_effective_date                 => trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_benefit_actions'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of delete_benefit_actions
    --
  end;
  --
  ben_bft_del.del
    (p_benefit_action_id             => p_benefit_action_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date);
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_benefit_actions
    --
    ben_benefit_actions_bk3.delete_benefit_actions_a
      (p_benefit_action_id              => p_benefit_action_id
      ,p_object_version_number          => l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_benefit_actions'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of delete_benefit_actions
    --
  end;
  --
  /*hr_utility.set_location(l_proc, 60); */
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
    ROLLBACK TO delete_benefit_actions;
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
    ROLLBACK TO delete_benefit_actions;
    raise;
    --
end delete_benefit_actions;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (p_benefit_action_id             in number
  ,p_object_version_number         in number) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'lck';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  ben_bft_shd.lck
    (p_benefit_action_id          => p_benefit_action_id
    ,p_object_version_number      => p_object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_benefit_actions_api;

/
