--------------------------------------------------------
--  DDL for Package BEN_BENEFIT_ACTIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BENEFIT_ACTIONS_API" AUTHID CURRENT_USER as
/* $Header: bebftapi.pkh 120.0 2005/05/28 00:40:35 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_benefit_actions >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_process_date                 Yes  date
--   p_uneai_effective_date         No   date
--   p_mode_cd                      Yes  varchar2
--   p_derivable_factors_flag       Yes  varchar2
--   p_close_uneai_flag             No   varchar2
--   p_validate_flag                Yes  varchar2
--   p_person_id                    No   number
--   p_person_type_id               No   number
--   p_pgm_id                       No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_pl_id                        No   number
--   p_popl_enrt_typ_cycl_id        No   number
--   p_no_programs_flag             Yes  varchar2
--   p_no_plans_flag                Yes  varchar2
--   p_comp_selection_rl            No   number
--   p_person_selection_rl          No   number
--   p_ler_id                       No   number
--   p_organization_id              No   number
--   p_benfts_grp_id                No   number
--   p_location_id                  No   number
--   p_pstl_zip_rng_id              No   number
--   p_rptg_grp_id                  No   number
--   p_pl_typ_id                    No   number
--   p_opt_id                       No   number
--   p_eligy_prfl_id                No   number
--   p_vrbl_rt_prfl_id              No   number
--   p_legal_entity_id              No   number
--   p_payroll_id                   No   number
--   p_debug_messages_flag          Yes  varchar2
--   p_cm_trgr_typ_cd               No   varchar2
--   p_cm_typ_id                    No   number
--   p_age_fctr_id                  No   number
--   p_min_age                      No   number
--   p_max_age                      No   number
--   p_los_fctr_id                  No   number
--   p_min_los                      No   number
--   p_max_los                      No   number
--   p_cmbn_age_los_fctr_id         No   number
--   p_min_cmbn                     No   number
--   p_max_cmbn                     No   number
--   p_date_from                    No   date
--   p_elig_enrol_cd                No   varchar2
--   p_actn_typ_id                  No   number
--   p_use_fctr_to_sel_flag         No   varchar2
--   p_los_det_to_use_cd            No   varchar2
--   p_audit_log_flag               No   varchar2
--   p_lmt_prpnip_by_org_flag       No   varchar2
--   p_bft_attribute_category       No   varchar2  Descriptive Flexfield
--   p_bft_attribute1               No   varchar2  Descriptive Flexfield
--   p_bft_attribute3               No   varchar2  Descriptive Flexfield
--   p_bft_attribute4               No   varchar2  Descriptive Flexfield
--   p_bft_attribute5               No   varchar2  Descriptive Flexfield
--   p_bft_attribute6               No   varchar2  Descriptive Flexfield
--   p_bft_attribute7               No   varchar2  Descriptive Flexfield
--   p_bft_attribute8               No   varchar2  Descriptive Flexfield
--   p_bft_attribute9               No   varchar2  Descriptive Flexfield
--   p_bft_attribute10              No   varchar2  Descriptive Flexfield
--   p_bft_attribute11              No   varchar2  Descriptive Flexfield
--   p_bft_attribute12              No   varchar2  Descriptive Flexfield
--   p_bft_attribute13              No   varchar2  Descriptive Flexfield
--   p_bft_attribute14              No   varchar2  Descriptive Flexfield
--   p_bft_attribute15              No   varchar2  Descriptive Flexfield
--   p_bft_attribute16              No   varchar2  Descriptive Flexfield
--   p_bft_attribute17              No   varchar2  Descriptive Flexfield
--   p_bft_attribute18              No   varchar2  Descriptive Flexfield
--   p_bft_attribute19              No   varchar2  Descriptive Flexfield
--   p_bft_attribute20              No   varchar2  Descriptive Flexfield
--   p_bft_attribute21              No   varchar2  Descriptive Flexfield
--   p_bft_attribute22              No   varchar2  Descriptive Flexfield
--   p_bft_attribute23              No   varchar2  Descriptive Flexfield
--   p_bft_attribute24              No   varchar2  Descriptive Flexfield
--   p_bft_attribute25              No   varchar2  Descriptive Flexfield
--   p_bft_attribute26              No   varchar2  Descriptive Flexfield
--   p_bft_attribute27              No   varchar2  Descriptive Flexfield
--   p_bft_attribute28              No   varchar2  Descriptive Flexfield
--   p_bft_attribute29              No   varchar2  Descriptive Flexfield
--   p_bft_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_benefit_action_id            Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_benefit_actions
(
   p_validate                       in boolean    default false
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
  );
-- ----------------------------------------------------------------------------
-- |------------------------< create_perf_benefit_actions >-------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_process_date                 Yes  date
--   p_uneai_effective_date         No   date
--   p_mode_cd                      Yes  varchar2
--   p_derivable_factors_flag       Yes  varchar2
--   p_close_uneai_flag             No   varchar2
--   p_validate_flag                Yes  varchar2
--   p_person_id                    No   number
--   p_person_type_id               No   number
--   p_pgm_id                       No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_pl_id                        No   number
--   p_popl_enrt_typ_cycl_id        No   number
--   p_no_programs_flag             Yes  varchar2
--   p_no_plans_flag                Yes  varchar2
--   p_comp_selection_rl            No   number
--   p_person_selection_rl          No   number
--   p_ler_id                       No   number
--   p_organization_id              No   number
--   p_benfts_grp_id                No   number
--   p_location_id                  No   number
--   p_pstl_zip_rng_id              No   number
--   p_rptg_grp_id                  No   number
--   p_pl_typ_id                    No   number
--   p_opt_id                       No   number
--   p_eligy_prfl_id                No   number
--   p_vrbl_rt_prfl_id              No   number
--   p_legal_entity_id              No   number
--   p_payroll_id                   No   number
--   p_debug_messages_flag          Yes  varchar2
--   p_cm_trgr_typ_cd               No   varchar2
--   p_cm_typ_id                    No   number
--   p_age_fctr_id                  No   number
--   p_min_age                      No   number
--   p_max_age                      No   number
--   p_los_fctr_id                  No   number
--   p_min_los                      No   number
--   p_max_los                      No   number
--   p_cmbn_age_los_fctr_id         No   number
--   p_min_cmbn                     No   number
--   p_max_cmbn                     No   number
--   p_date_from                    No   date
--   p_elig_enrol_cd                No   varchar2
--   p_actn_typ_id                  No   number
--   p_use_fctr_to_sel_flag         No   varchar2
--   p_los_det_to_use_cd            No   varchar2
--   p_audit_log_flag               No   varchar2
--   p_lmt_prpnip_by_org_flag       No   varchar2
--   p_bft_attribute_category       No   varchar2  Descriptive Flexfield
--   p_bft_attribute1               No   varchar2  Descriptive Flexfield
--   p_bft_attribute3               No   varchar2  Descriptive Flexfield
--   p_bft_attribute4               No   varchar2  Descriptive Flexfield
--   p_bft_attribute5               No   varchar2  Descriptive Flexfield
--   p_bft_attribute6               No   varchar2  Descriptive Flexfield
--   p_bft_attribute7               No   varchar2  Descriptive Flexfield
--   p_bft_attribute8               No   varchar2  Descriptive Flexfield
--   p_bft_attribute9               No   varchar2  Descriptive Flexfield
--   p_bft_attribute10              No   varchar2  Descriptive Flexfield
--   p_bft_attribute11              No   varchar2  Descriptive Flexfield
--   p_bft_attribute12              No   varchar2  Descriptive Flexfield
--   p_bft_attribute13              No   varchar2  Descriptive Flexfield
--   p_bft_attribute14              No   varchar2  Descriptive Flexfield
--   p_bft_attribute15              No   varchar2  Descriptive Flexfield
--   p_bft_attribute16              No   varchar2  Descriptive Flexfield
--   p_bft_attribute17              No   varchar2  Descriptive Flexfield
--   p_bft_attribute18              No   varchar2  Descriptive Flexfield
--   p_bft_attribute19              No   varchar2  Descriptive Flexfield
--   p_bft_attribute20              No   varchar2  Descriptive Flexfield
--   p_bft_attribute21              No   varchar2  Descriptive Flexfield
--   p_bft_attribute22              No   varchar2  Descriptive Flexfield
--   p_bft_attribute23              No   varchar2  Descriptive Flexfield
--   p_bft_attribute24              No   varchar2  Descriptive Flexfield
--   p_bft_attribute25              No   varchar2  Descriptive Flexfield
--   p_bft_attribute26              No   varchar2  Descriptive Flexfield
--   p_bft_attribute27              No   varchar2  Descriptive Flexfield
--   p_bft_attribute28              No   varchar2  Descriptive Flexfield
--   p_bft_attribute29              No   varchar2  Descriptive Flexfield
--   p_bft_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_benefit_action_id            Yes  number    PK of record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_perf_benefit_actions
(
   p_validate                       in boolean    default false
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
  );
-- ----------------------------------------------------------------------------
-- |------------------------< update_benefit_actions >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_benefit_action_id            Yes  number    PK of record
--   p_process_date                 Yes  date
--   p_uneai_effective_date         Yes  date
--   p_mode_cd                      Yes  varchar2
--   p_derivable_factors_flag       Yes  varchar2
--   p_close_uneai_flag             Yes  varchar2
--   p_validate_flag                Yes  varchar2
--   p_person_id                    No   number
--   p_person_type_id               No   number
--   p_pgm_id                       No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_pl_id                        No   number
--   p_popl_enrt_typ_cycl_id        No   number
--   p_no_programs_flag             Yes  varchar2
--   p_no_plans_flag                Yes  varchar2
--   p_comp_selection_rl            No   number
--   p_person_selection_rl          No   number
--   p_ler_id                       No   number
--   p_organization_id              No   number
--   p_benfts_grp_id                No   number
--   p_location_id                  No   number
--   p_pstl_zip_rng_id              No   number
--   p_rptg_grp_id                  No   number
--   p_pl_typ_id                    No   number
--   p_opt_id                       No   number
--   p_eligy_prfl_id                No   number
--   p_vrbl_rt_prfl_id              No   number
--   p_legal_entity_id              No   number
--   p_payroll_id                   No   number
--   p_debug_messages_flag          Yes  varchar2
--   p_cm_trgr_typ_cd               No   varchar2
--   p_cm_typ_id                    No   number
--   p_age_fctr_id                  No   number
--   p_min_age                      No   number
--   p_max_age                      No   number
--   p_los_fctr_id                  No   number
--   p_min_los                      No   number
--   p_max_los                      No   number
--   p_cmbn_age_los_fctr_id         No   number
--   p_min_cmbn                     No   number
--   p_max_cmbn                     No   number
--   p_date_from                    No   date
--   p_elig_enrol_cd                No   varchar2
--   p_actn_typ_id                  No   number
--   p_use_fctr_to_sel_flag         No   varchar2
--   p_los_det_to_use_cd            No   varchar2
--   p_audit_log_flag               No   varchar2
--   p_lmt_prpnip_by_org_flag       No   varchar2
--   p_bft_attribute_category       No   varchar2  Descriptive Flexfield
--   p_bft_attribute1               No   varchar2  Descriptive Flexfield
--   p_bft_attribute3               No   varchar2  Descriptive Flexfield
--   p_bft_attribute4               No   varchar2  Descriptive Flexfield
--   p_bft_attribute5               No   varchar2  Descriptive Flexfield
--   p_bft_attribute6               No   varchar2  Descriptive Flexfield
--   p_bft_attribute7               No   varchar2  Descriptive Flexfield
--   p_bft_attribute8               No   varchar2  Descriptive Flexfield
--   p_bft_attribute9               No   varchar2  Descriptive Flexfield
--   p_bft_attribute10              No   varchar2  Descriptive Flexfield
--   p_bft_attribute11              No   varchar2  Descriptive Flexfield
--   p_bft_attribute12              No   varchar2  Descriptive Flexfield
--   p_bft_attribute13              No   varchar2  Descriptive Flexfield
--   p_bft_attribute14              No   varchar2  Descriptive Flexfield
--   p_bft_attribute15              No   varchar2  Descriptive Flexfield
--   p_bft_attribute16              No   varchar2  Descriptive Flexfield
--   p_bft_attribute17              No   varchar2  Descriptive Flexfield
--   p_bft_attribute18              No   varchar2  Descriptive Flexfield
--   p_bft_attribute19              No   varchar2  Descriptive Flexfield
--   p_bft_attribute20              No   varchar2  Descriptive Flexfield
--   p_bft_attribute21              No   varchar2  Descriptive Flexfield
--   p_bft_attribute22              No   varchar2  Descriptive Flexfield
--   p_bft_attribute23              No   varchar2  Descriptive Flexfield
--   p_bft_attribute24              No   varchar2  Descriptive Flexfield
--   p_bft_attribute25              No   varchar2  Descriptive Flexfield
--   p_bft_attribute26              No   varchar2  Descriptive Flexfield
--   p_bft_attribute27              No   varchar2  Descriptive Flexfield
--   p_bft_attribute28              No   varchar2  Descriptive Flexfield
--   p_bft_attribute29              No   varchar2  Descriptive Flexfield
--   p_bft_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date          Yes  date       Session Date.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_benefit_actions
  (p_validate                       in boolean    default false
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
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
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
  ,p_grant_price_val                in  number    default hr_api.g_number);
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_benefit_actions >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_benefit_action_id            Yes  number   PK of record
--   p_effective_date               Yes  date     Session Date.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_benefit_actions
  (p_validate                       in boolean        default false
  ,p_benefit_action_id              in number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in date);
--
-- ----------------------------------------------------------------------------
-- |----------------------------------< lck >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_benefit_action_id            Yes  number   PK of record
--   p_object_version_number        Yes  number   OVN of record
--
-- Post Success:
--
--   Name                           Type     Description
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure lck
  (p_benefit_action_id            in number
  ,p_object_version_number        in number);
--
end ben_benefit_actions_api;

 

/
