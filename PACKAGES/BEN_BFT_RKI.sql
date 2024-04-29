--------------------------------------------------------
--  DDL for Package BEN_BFT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BFT_RKI" AUTHID CURRENT_USER as
/* $Header: bebftrhi.pkh 120.0 2005/05/28 00:40:56 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_benefit_action_id              in number
 ,p_process_date                   in date
 ,p_uneai_effective_date           in date
 ,p_mode_cd                        in varchar2
 ,p_derivable_factors_flag         in varchar2
 ,p_close_uneai_flag               in varchar2
 ,p_validate_flag                  in varchar2
 ,p_person_id                      in number
 ,p_person_type_id                 in number
 ,p_pgm_id                         in number
 ,p_business_group_id              in number
 ,p_pl_id                          in number
 ,p_popl_enrt_typ_cycl_id          in number
 ,p_no_programs_flag               in varchar2
 ,p_no_plans_flag                  in varchar2
 ,p_comp_selection_rl              in number
 ,p_person_selection_rl            in number
 ,p_ler_id                         in number
 ,p_organization_id                in number
 ,p_benfts_grp_id                  in number
 ,p_location_id                    in number
 ,p_pstl_zip_rng_id                in number
 ,p_rptg_grp_id                    in number
 ,p_pl_typ_id                      in number
 ,p_opt_id                         in number
 ,p_eligy_prfl_id                  in number
 ,p_vrbl_rt_prfl_id                in number
 ,p_legal_entity_id                in number
 ,p_payroll_id                     in number
 ,p_debug_messages_flag            in varchar2
 ,p_cm_trgr_typ_cd                 in varchar2
 ,p_cm_typ_id                      in number
 ,p_age_fctr_id                    in number
 ,p_min_age                        in number
 ,p_max_age                        in number
 ,p_los_fctr_id                    in number
 ,p_min_los                        in number
 ,p_max_los                        in number
 ,p_cmbn_age_los_fctr_id           in number
 ,p_min_cmbn                       in number
 ,p_max_cmbn                       in number
 ,p_date_from                      in date
 ,p_elig_enrol_cd                  in varchar2
 ,p_actn_typ_id                    in number
 ,p_use_fctr_to_sel_flag           in varchar2
 ,p_los_det_to_use_cd              in varchar2
 ,p_audit_log_flag                 in varchar2
 ,p_lmt_prpnip_by_org_flag         in varchar2
 ,p_lf_evt_ocrd_dt                 in date
 ,p_ptnl_ler_for_per_stat_cd       in varchar2
 ,p_bft_attribute_category         in varchar2
 ,p_bft_attribute1                 in varchar2
 ,p_bft_attribute3                 in varchar2
 ,p_bft_attribute4                 in varchar2
 ,p_bft_attribute5                 in varchar2
 ,p_bft_attribute6                 in varchar2
 ,p_bft_attribute7                 in varchar2
 ,p_bft_attribute8                 in varchar2
 ,p_bft_attribute9                 in varchar2
 ,p_bft_attribute10                in varchar2
 ,p_bft_attribute11                in varchar2
 ,p_bft_attribute12                in varchar2
 ,p_bft_attribute13                in varchar2
 ,p_bft_attribute14                in varchar2
 ,p_bft_attribute15                in varchar2
 ,p_bft_attribute16                in varchar2
 ,p_bft_attribute17                in varchar2
 ,p_bft_attribute18                in varchar2
 ,p_bft_attribute19                in varchar2
 ,p_bft_attribute20                in varchar2
 ,p_bft_attribute21                in varchar2
 ,p_bft_attribute22                in varchar2
 ,p_bft_attribute23                in varchar2
 ,p_bft_attribute24                in varchar2
 ,p_bft_attribute25                in varchar2
 ,p_bft_attribute26                in varchar2
 ,p_bft_attribute27                in varchar2
 ,p_bft_attribute28                in varchar2
 ,p_bft_attribute29                in varchar2
 ,p_bft_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_enrt_perd_id                   in number
 ,p_inelg_action_cd                in varchar2
 ,p_org_hierarchy_id                in number
 ,p_org_starting_node_id                in number
 ,p_grade_ladder_id                in number
 ,p_asg_events_to_all_sel_dt                in varchar2
 ,p_rate_id                in number
 ,p_per_sel_dt_cd                in varchar2
 ,p_per_sel_freq_cd                in varchar2
 ,p_per_sel_dt_from                in date
 ,p_per_sel_dt_to                in date
 ,p_year_from                in number
 ,p_year_to                in number
 ,p_cagr_id                in number
 ,p_qual_type                in number
 ,p_qual_status                in varchar2
 ,p_concat_segs                in varchar2
 ,p_grant_price_val                in number
  );
end ben_bft_rki;

 

/
