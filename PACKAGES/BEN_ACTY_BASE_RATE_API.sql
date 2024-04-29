--------------------------------------------------------
--  DDL for Package BEN_ACTY_BASE_RATE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ACTY_BASE_RATE_API" AUTHID CURRENT_USER as
/* $Header: beabrapi.pkh 120.3 2006/01/19 07:56:21 swjain noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_acty_base_rate >------------------------|
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
--   p_ordr_num			    Yes  number
--   p_acty_typ_cd                  No   varchar2
--   p_sub_acty_typ_cd                  No   varchar2
--   p_name                         No   varchar2
--   p_rt_typ_cd                    No   varchar2
--   p_bnft_rt_typ_cd               No   varchar2
--   p_tx_typ_cd                    No   varchar2
--   p_use_to_calc_net_flx_cr_flag  Yes  varchar2
--   p_asn_on_enrt_flag             Yes  varchar2
--   p_abv_mx_elcn_val_alwd_flag    Yes  varchar2
--   p_blw_mn_elcn_alwd_flag        Yes  varchar2
--   p_dsply_on_enrt_flag           Yes  varchar2
--   p_parnt_chld_cd                No   varchar2
--   p_use_calc_acty_bs_rt_flag     Yes  varchar2
--   p_uses_ded_sched_flag          Yes  varchar2
--   p_uses_varbl_rt_flag           Yes  varchar2
--   p_vstg_sched_apls_flag         Yes  varchar2
--   p_rt_mlt_cd                    No   varchar2
--   p_proc_each_pp_dflt_flag       Yes  varchar2
--   p_prdct_flx_cr_when_elig_flag  Yes  varchar2
--   p_no_std_rt_used_flag          Yes  varchar2
--   p_rcrrg_cd                     No   varchar2
--   p_mn_elcn_val                  No   number
--   p_mx_elcn_val                  No   number
--   p_lwr_lmt_val                  No   number
--   p_lwr_lmt_calc_rl              No   number
--   p_upr_lmt_val                  No   number
--   p_upr_lmt_calc_rl              No   number
--   p_ptd_comp_lvl_fctr_id         No   number
--   p_clm_comp_lvl_fctr_id         No   number
--   p_entr_ann_val_flag            No   varchar2
--   p_ann_mn_elcn_val              No   number
--   p_ann_mx_elcn_val              No   number
--   p_wsh_rl_dy_mo_num             No   number
--   p_uses_pymt_sched_flag         Yes  varchar2
--   p_nnmntry_uom                  No   varchar2
--   p_val                          No   number
--   p_incrmt_elcn_val              No   number
--   p_rndg_cd                      No   varchar2
--   p_val_ovrid_alwd_flag          Yes  varchar2
--   p_prtl_mo_det_mthd_cd          No   varchar2
--   p_acty_base_rt_stat_cd         No   varchar2
--   p_procg_src_cd                 No   varchar2
--   p_dflt_val                     No   number
--   p_dflt_flag                    Yes  varchar2
--   p_frgn_erg_ded_typ_cd          No   varchar2
--   p_frgn_erg_ded_name            No   varchar2
--   p_frgn_erg_ded_ident           No   varchar2
--   p_no_mx_elcn_val_dfnd_flag     Yes  varchar2
--   p_prtl_mo_det_mthd_rl          No   number
--   p_entr_val_at_enrt_flag        Yes  varchar2
--   p_prtl_mo_eff_dt_det_rl        No   number
--   p_rndg_rl                      No   number
--   p_val_calc_rl                  No   number
--   p_no_mn_elcn_val_dfnd_flag     Yes  varchar2
--   p_prtl_mo_eff_dt_det_cd        No   varchar2
--   p_only_one_bal_typ_alwd_flag   Yes  varchar2
--   p_rt_usg_cd                    No   varchar2
--   p_prort_mn_ann_elcn_val_cd     No   varchar2
--   p_prort_mn_ann_elcn_val_rl     No   number
--   p_prort_mx_ann_elcn_val_cd     No   varchar2
--   p_prort_mx_ann_elcn_val_rl     No   number
--   p_one_ann_pymt_cd              No   varchar2
--   p_det_pl_ytd_cntrs_cd          No   varchar2
--   p_asmt_to_use_cd               No   varchar2
--   p_ele_rqd_flag                 Yes  varchar2
--   p_subj_to_imptd_incm_flag      Yes  varchar2
--   p_element_type_id              No   number
--   p_input_value_id               No   number
--   p_input_va_calc_rl            No   number
--   p_comp_lvl_fctr_id             No   number
--   p_parnt_acty_base_rt_id        No   number
--   p_pgm_id                       No   number
--   p_pl_id                        No   number
--   p_oipl_id                      No   number
--   p_oiplip_id                    No   number
--   p_plip_id                      No   number
--   p_ptip_id                      No   number
--   p_cmbn_plip_id                 No   number
--   p_cmbn_ptip_id                 No   number
--   p_cmbn_ptip_opt_id             No   number
--   p_vstg_for_acty_rt_id          No   number
--   p_actl_prem_id                 No   number
--   p_pay_rate_grade_rule_id       No   number
--   p_mn_mx_elcn_rl                No   number --3981982
--   p_business_group_id            Yes  number    Business Group of Record
--   p_abr_attribute_category       No   varchar2  Descriptive Flexfield
--   p_abr_attribute1               No   varchar2  Descriptive Flexfield
--   p_abr_attribute2               No   varchar2  Descriptive Flexfield
--   p_abr_attribute3               No   varchar2  Descriptive Flexfield
--   p_abr_attribute4               No   varchar2  Descriptive Flexfield
--   p_abr_attribute5               No   varchar2  Descriptive Flexfield
--   p_abr_attribute6               No   varchar2  Descriptive Flexfield
--   p_abr_attribute7               No   varchar2  Descriptive Flexfield
--   p_abr_attribute8               No   varchar2  Descriptive Flexfield
--   p_abr_attribute9               No   varchar2  Descriptive Flexfield
--   p_abr_attribute10              No   varchar2  Descriptive Flexfield
--   p_abr_attribute11              No   varchar2  Descriptive Flexfield
--   p_abr_attribute12              No   varchar2  Descriptive Flexfield
--   p_abr_attribute13              No   varchar2  Descriptive Flexfield
--   p_abr_attribute14              No   varchar2  Descriptive Flexfield
--   p_abr_attribute15              No   varchar2  Descriptive Flexfield
--   p_abr_attribute16              No   varchar2  Descriptive Flexfield
--   p_abr_attribute17              No   varchar2  Descriptive Flexfield
--   p_abr_attribute18              No   varchar2  Descriptive Flexfield
--   p_abr_attribute19              No   varchar2  Descriptive Flexfield
--   p_abr_attribute20              No   varchar2  Descriptive Flexfield
--   p_abr_attribute21              No   varchar2  Descriptive Flexfield
--   p_abr_attribute22              No   varchar2  Descriptive Flexfield
--   p_abr_attribute23              No   varchar2  Descriptive Flexfield
--   p_abr_attribute24              No   varchar2  Descriptive Flexfield
--   p_abr_attribute25              No   varchar2  Descriptive Flexfield
--   p_abr_attribute26              No   varchar2  Descriptive Flexfield
--   p_abr_attribute27              No   varchar2  Descriptive Flexfield
--   p_abr_attribute28              No   varchar2  Descriptive Flexfield
--   p_abr_attribute29              No   varchar2  Descriptive Flexfield
--   p_abr_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date                Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_acty_base_rt_id              Yes  number    PK of record
--   p_effective_start_date         Yes  date      Effective Start Date of Record
--   p_effective_end_date           Yes  date      Effective End Date of Record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_acty_base_rate
(
   p_validate                       in boolean    default false
  ,p_acty_base_rt_id                out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_ordr_num			    in  number    default null
  ,p_acty_typ_cd                    in  varchar2  default null
  ,p_sub_acty_typ_cd                    in  varchar2  default null
  ,p_name                           in  varchar2  default null
  ,p_rt_typ_cd                      in  varchar2  default null
  ,p_bnft_rt_typ_cd                 in  varchar2  default null
  ,p_tx_typ_cd                      in  varchar2  default null
  ,p_use_to_calc_net_flx_cr_flag    in  varchar2  default 'N'
  ,p_asn_on_enrt_flag               in  varchar2  default 'N'
  ,p_abv_mx_elcn_val_alwd_flag      in  varchar2  default 'N'
  ,p_blw_mn_elcn_alwd_flag          in  varchar2  default 'N'
  ,p_dsply_on_enrt_flag             in  varchar2  default 'N'
  ,p_parnt_chld_cd                  in  varchar2  default null
  ,p_use_calc_acty_bs_rt_flag       in  varchar2  default 'Y'
  ,p_uses_ded_sched_flag            in  varchar2  default 'N'
  ,p_uses_varbl_rt_flag             in  varchar2  default 'N'
  ,p_vstg_sched_apls_flag           in  varchar2  default 'N'
  ,p_rt_mlt_cd                      in  varchar2  default null
  ,p_proc_each_pp_dflt_flag         in  varchar2  default 'N'
  ,p_prdct_flx_cr_when_elig_flag    in  varchar2  default 'N'
  ,p_no_std_rt_used_flag            in  varchar2  default 'N'
  ,p_rcrrg_cd                       in  varchar2  default null
  ,p_mn_elcn_val                    in  number    default null
  ,p_mx_elcn_val                    in  number    default null
  ,p_lwr_lmt_val                    in  number    default null
  ,p_lwr_lmt_calc_rl                in  number    default null
  ,p_upr_lmt_val                    in  number    default null
  ,p_upr_lmt_calc_rl                in  number    default null
  ,p_ptd_comp_lvl_fctr_id           in  number    default null
  ,p_clm_comp_lvl_fctr_id           in  number    default null
  ,p_entr_ann_val_flag              in  varchar2  default 'N'
  ,p_ann_mn_elcn_val                in  number    default null
  ,p_ann_mx_elcn_val                in  number    default null
  ,p_wsh_rl_dy_mo_num               in  number    default null
  ,p_uses_pymt_sched_flag           in  varchar2  default 'N'
  ,p_nnmntry_uom                    in  varchar2  default null
  ,p_val                            in  number    default null
  ,p_incrmt_elcn_val                in  number    default null
  ,p_rndg_cd                        in  varchar2  default null
  ,p_val_ovrid_alwd_flag            in  varchar2  default 'N'
  ,p_prtl_mo_det_mthd_cd            in  varchar2  default null
  ,p_acty_base_rt_stat_cd           in  varchar2  default null
  ,p_procg_src_cd                   in  varchar2  default null
  ,p_dflt_val                       in  number    default null
  ,p_dflt_flag                      in  varchar2  default 'N'
  ,p_frgn_erg_ded_typ_cd            in  varchar2  default null
  ,p_frgn_erg_ded_name              in  varchar2  default null
  ,p_frgn_erg_ded_ident             in  varchar2  default null
  ,p_no_mx_elcn_val_dfnd_flag       in  varchar2  default 'N'
  ,p_prtl_mo_det_mthd_rl            in  number    default null
  ,p_entr_val_at_enrt_flag          in  varchar2  default 'N'
  ,p_prtl_mo_eff_dt_det_rl          in  number    default null
  ,p_rndg_rl                        in  number    default null
  ,p_val_calc_rl                    in  number    default null
  ,p_no_mn_elcn_val_dfnd_flag       in  varchar2  default 'N'
  ,p_prtl_mo_eff_dt_det_cd          in  varchar2  default null
  ,p_only_one_bal_typ_alwd_flag     in  varchar2  default 'N'
  ,p_rt_usg_cd                      in  varchar2  default null
  ,p_prort_mn_ann_elcn_val_cd       in  varchar2  default null
  ,p_prort_mn_ann_elcn_val_rl       in  number    default null
  ,p_prort_mx_ann_elcn_val_cd       in  varchar2  default null
  ,p_prort_mx_ann_elcn_val_rl       in  number    default null
  ,p_one_ann_pymt_cd                in  varchar2  default null
  ,p_det_pl_ytd_cntrs_cd            in  varchar2  default null
  ,p_asmt_to_use_cd                 in  varchar2  default null
  ,p_ele_rqd_flag                   in  varchar2  default 'Y'
  ,p_subj_to_imptd_incm_flag        in  varchar2  default 'N'
  ,p_element_type_id                in  number    default null
  ,p_input_value_id                 in  number    default null
  ,p_input_va_calc_rl              in  number    default null
  ,p_comp_lvl_fctr_id               in  number    default null
  ,p_parnt_acty_base_rt_id          in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_oipl_id                        in  number    default null
  ,p_opt_id                         in  number    default null
  ,p_oiplip_id                      in  number    default null
  ,p_plip_id                        in  number    default null
  ,p_ptip_id                        in  number    default null
  ,p_cmbn_plip_id                   in  number    default null
  ,p_cmbn_ptip_id                   in  number    default null
  ,p_cmbn_ptip_opt_id               in  number    default null
  ,p_vstg_for_acty_rt_id            in  number    default null
  ,p_actl_prem_id                   in  number    default null
  ,p_TTL_COMP_LVL_FCTR_ID           in  number    default null
  ,p_COST_ALLOCATION_KEYFLEX_ID     in  number    default null
  ,p_ALWS_CHG_CD                    in  varchar2  default null
  ,p_ele_entry_val_cd               in  varchar2  default null
  ,p_pay_rate_grade_rule_id         in  number    default null
  ,p_rate_periodization_cd          in  varchar2  default null
  ,p_rate_periodization_rl          in  number    default null
  ,p_mn_mx_elcn_rl                  in  number    default null
  ,p_mapping_table_name             in  varchar2  default null
  ,p_mapping_table_pk_id            in number     default null
  ,p_business_group_id              in  number    default null
  ,p_context_pgm_id                 in number     default null
  ,p_context_pl_id                  in number     default null
  ,p_context_opt_id                 in number     default null
  ,p_element_det_rl                 in  number    default null
  ,p_currency_det_cd                in  varchar2  default null
  ,p_abr_attribute_category         in  varchar2  default null
  ,p_abr_attribute1                 in  varchar2  default null
  ,p_abr_attribute2                 in  varchar2  default null
  ,p_abr_attribute3                 in  varchar2  default null
  ,p_abr_attribute4                 in  varchar2  default null
  ,p_abr_attribute5                 in  varchar2  default null
  ,p_abr_attribute6                 in  varchar2  default null
  ,p_abr_attribute7                 in  varchar2  default null
  ,p_abr_attribute8                 in  varchar2  default null
  ,p_abr_attribute9                 in  varchar2  default null
  ,p_abr_attribute10                in  varchar2  default null
  ,p_abr_attribute11                in  varchar2  default null
  ,p_abr_attribute12                in  varchar2  default null
  ,p_abr_attribute13                in  varchar2  default null
  ,p_abr_attribute14                in  varchar2  default null
  ,p_abr_attribute15                in  varchar2  default null
  ,p_abr_attribute16                in  varchar2  default null
  ,p_abr_attribute17                in  varchar2  default null
  ,p_abr_attribute18                in  varchar2  default null
  ,p_abr_attribute19                in  varchar2  default null
  ,p_abr_attribute20                in  varchar2  default null
  ,p_abr_attribute21                in  varchar2  default null
  ,p_abr_attribute22                in  varchar2  default null
  ,p_abr_attribute23                in  varchar2  default null
  ,p_abr_attribute24                in  varchar2  default null
  ,p_abr_attribute25                in  varchar2  default null
  ,p_abr_attribute26                in  varchar2  default null
  ,p_abr_attribute27                in  varchar2  default null
  ,p_abr_attribute28                in  varchar2  default null
  ,p_abr_attribute29                in  varchar2  default null
  ,p_abr_attribute30                in  varchar2  default null
  ,p_abr_seq_num                    in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_acty_base_rate >------------------------|
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
--   p_acty_base_rt_id              Yes  number    PK of record
--   p_ordr_num                     Yes  number
--   p_acty_typ_cd                  No   varchar2
--   p_name                         No   varchar2
--   p_rt_typ_cd                    No   varchar2
--   p_bnft_rt_typ_cd               No   varchar2
--   p_tx_typ_cd                    No   varchar2
--   p_use_to_calc_net_flx_cr_flag  Yes  varchar2
--   p_asn_on_enrt_flag             Yes  varchar2
--   p_abv_mx_elcn_val_alwd_flag    Yes  varchar2
--   p_blw_mn_elcn_alwd_flag        Yes  varchar2
--   p_dsply_on_enrt_flag           Yes  varchar2
--   p_parnt_chld_cd                No   varchar2
--   p_use_calc_acty_bs_rt_flag     Yes  varchar2
--   p_uses_ded_sched_flag          Yes  varchar2
--   p_uses_varbl_rt_flag           Yes  varchar2
--   p_vstg_sched_apls_flag         Yes  varchar2
--   p_rt_mlt_cd                    No   varchar2
--   p_proc_each_pp_dflt_flag       Yes  varchar2
--   p_prdct_flx_cr_when_elig_flag  Yes  varchar2
--   p_no_std_rt_used_flag          Yes  varchar2
--   p_rcrrg_cd                     No   varchar2
--   p_mn_elcn_val                  No   number
--   p_mx_elcn_val                  No   number
--   p_lwr_lmt_val                  No   number
--   p_lwr_lmt_calc_rl              No   number
--   p_upr_lmt_val                  No   number
--   p_upr_lmt_calc_rl              No   number
--   p_ptd_comp_lvl_fctr_id         No   number
--   p_clm_comp_lvl_fctr_id         No   number
--   p_entr_ann_val_flag            No   varchar2
--   p_ann_mn_elcn_val              No   number
--   p_ann_mx_elcn_val              No   number
--   p_wsh_rl_dy_mo_num             No   number
--   p_uses_pymt_sched_flag         Yes  varchar2
--   p_nnmntry_uom                  No   varchar2
--   p_val                          No   number
--   p_incrmt_elcn_val              No   number
--   p_rndg_cd                      No   varchar2
--   p_val_ovrid_alwd_flag          Yes  varchar2
--   p_prtl_mo_det_mthd_cd          No   varchar2
--   p_acty_base_rt_stat_cd         No   varchar2
--   p_procg_src_cd                 No   varchar2
--   p_dflt_val                     No   number
--   p_dflt_flag                    Yes  varchar2
--   p_frgn_erg_ded_typ_cd          No   varchar2
--   p_frgn_erg_ded_name            No   varchar2
--   p_frgn_erg_ded_ident           No   varchar2
--   p_no_mx_elcn_val_dfnd_flag     Yes  varchar2
--   p_prtl_mo_det_mthd_rl          No   number
--   p_entr_val_at_enrt_flag        Yes  varchar2
--   p_prtl_mo_eff_dt_det_rl        No   number
--   p_rndg_rl                      No   number
--   p_val_calc_rl                  No   number
--   p_no_mn_elcn_val_dfnd_flag     Yes  varchar2
--   p_prtl_mo_eff_dt_det_cd        No   varchar2
--   p_only_one_bal_typ_alwd_flag   Yes  varchar2
--   p_rt_usg_cd                    No   varchar2
--   p_prort_mn_ann_elcn_val_cd     No   varchar2
--   p_prort_mn_ann_elcn_val_rl     No   number
--   p_prort_mx_ann_elcn_val_cd     No   varchar2
--   p_prort_mx_ann_elcn_val_rl     No   number
--   p_one_ann_pymt_cd              No   varchar2
--   p_det_pl_ytd_cntrs_cd          No   varchar2
--   p_asmt_to_use_cd               No   varchar2
--   p_ele_rqd_flag                 Yes  varchar2
--   p_subj_to_imptd_incm_flag      Yes  varchar2
--   p_element_type_id              No   number
--   p_input_value_id               No   number
--   p_input_va_calc_rl            No   number
--   p_comp_lvl_fctr_id             No   number
--   p_parnt_acty_base_rt_id        No   number
--   p_pgm_id                       No   number
--   p_pl_id                        No   number
--   p_oipl_id                      No   number
--   p_oiplip_id                    No   number
--   p_plip_id                      No   number
--   p_ptip_id                      No   number
--   p_cmbn_plip_id                 No   number
--   p_cmbn_ptip_id                 No   number
--   p_cmbn_ptip_opt_id             No   number
--   p_vstg_for_acty_rt_id          No   number
--   p_actl_prem_id                 No   number
--   p_mn_mx_n_rl                   No   number
--   p_business_group_id            Yes  number    Business Group of Record
--   p_abr_attribute_category       No   varchar2  Descriptive Flexfield
--   p_abr_attribute1               No   varchar2  Descriptive Flexfield
--   p_abr_attribute2               No   varchar2  Descriptive Flexfield
--   p_abr_attribute3               No   varchar2  Descriptive Flexfield
--   p_abr_attribute4               No   varchar2  Descriptive Flexfield
--   p_abr_attribute5               No   varchar2  Descriptive Flexfield
--   p_abr_attribute6               No   varchar2  Descriptive Flexfield
--   p_abr_attribute7               No   varchar2  Descriptive Flexfield
--   p_abr_attribute8               No   varchar2  Descriptive Flexfield
--   p_abr_attribute9               No   varchar2  Descriptive Flexfield
--   p_abr_attribute10              No   varchar2  Descriptive Flexfield
--   p_abr_attribute11              No   varchar2  Descriptive Flexfield
--   p_abr_attribute12              No   varchar2  Descriptive Flexfield
--   p_abr_attribute13              No   varchar2  Descriptive Flexfield
--   p_abr_attribute14              No   varchar2  Descriptive Flexfield
--   p_abr_attribute15              No   varchar2  Descriptive Flexfield
--   p_abr_attribute16              No   varchar2  Descriptive Flexfield
--   p_abr_attribute17              No   varchar2  Descriptive Flexfield
--   p_abr_attribute18              No   varchar2  Descriptive Flexfield
--   p_abr_attribute19              No   varchar2  Descriptive Flexfield
--   p_abr_attribute20              No   varchar2  Descriptive Flexfield
--   p_abr_attribute21              No   varchar2  Descriptive Flexfield
--   p_abr_attribute22              No   varchar2  Descriptive Flexfield
--   p_abr_attribute23              No   varchar2  Descriptive Flexfield
--   p_abr_attribute24              No   varchar2  Descriptive Flexfield
--   p_abr_attribute25              No   varchar2  Descriptive Flexfield
--   p_abr_attribute26              No   varchar2  Descriptive Flexfield
--   p_abr_attribute27              No   varchar2  Descriptive Flexfield
--   p_abr_attribute28              No   varchar2  Descriptive Flexfield
--   p_abr_attribute29              No   varchar2  Descriptive Flexfield
--   p_abr_attribute30              No   varchar2  Descriptive Flexfield
--   p_effective_date               Yes  date       Session Date.
--   p_datetrack_mode               Yes  varchar2   Datetrack mode.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_effective_start_date         Yes  date      Effective Start Date of Record
--   p_effective_end_date           Yes  date      Effective End Date of Record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_acty_base_rate
  (
   p_validate                       in boolean    default false
  ,p_acty_base_rt_id                in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_ordr_num			    in number     default hr_api.g_number
  ,p_acty_typ_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_sub_acty_typ_cd                in  varchar2  default hr_api.g_varchar2
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_rt_typ_cd                      in  varchar2  default hr_api.g_varchar2
  ,p_bnft_rt_typ_cd                 in  varchar2  default hr_api.g_varchar2
  ,p_tx_typ_cd                      in  varchar2  default hr_api.g_varchar2
  ,p_use_to_calc_net_flx_cr_flag    in  varchar2  default hr_api.g_varchar2
  ,p_asn_on_enrt_flag               in  varchar2  default hr_api.g_varchar2
  ,p_abv_mx_elcn_val_alwd_flag      in  varchar2  default hr_api.g_varchar2
  ,p_blw_mn_elcn_alwd_flag          in  varchar2  default hr_api.g_varchar2
  ,p_dsply_on_enrt_flag             in  varchar2  default hr_api.g_varchar2
  ,p_parnt_chld_cd                  in  varchar2  default hr_api.g_varchar2
  ,p_use_calc_acty_bs_rt_flag       in  varchar2  default hr_api.g_varchar2
  ,p_uses_ded_sched_flag            in  varchar2  default hr_api.g_varchar2
  ,p_uses_varbl_rt_flag             in  varchar2  default hr_api.g_varchar2
  ,p_vstg_sched_apls_flag           in  varchar2  default hr_api.g_varchar2
  ,p_rt_mlt_cd                      in  varchar2  default hr_api.g_varchar2
  ,p_proc_each_pp_dflt_flag         in  varchar2  default hr_api.g_varchar2
  ,p_prdct_flx_cr_when_elig_flag    in  varchar2  default hr_api.g_varchar2
  ,p_no_std_rt_used_flag            in  varchar2  default hr_api.g_varchar2
  ,p_rcrrg_cd                       in  varchar2  default hr_api.g_varchar2
  ,p_mn_elcn_val                    in  number    default hr_api.g_number
  ,p_mx_elcn_val                    in  number    default hr_api.g_number
  ,p_lwr_lmt_val                    in  number    default hr_api.g_number
  ,p_lwr_lmt_calc_rl                in  number    default hr_api.g_number
  ,p_upr_lmt_val                    in  number    default hr_api.g_number
  ,p_upr_lmt_calc_rl                in  number    default hr_api.g_number
  ,p_ptd_comp_lvl_fctr_id           in  number    default hr_api.g_number
  ,p_clm_comp_lvl_fctr_id           in  number    default hr_api.g_number
  ,p_entr_ann_val_flag              in  varchar2  default hr_api.g_varchar2
  ,p_ann_mn_elcn_val                in  number    default hr_api.g_number
  ,p_ann_mx_elcn_val                in  number    default hr_api.g_number
  ,p_wsh_rl_dy_mo_num               in  number    default hr_api.g_number
  ,p_uses_pymt_sched_flag           in  varchar2  default hr_api.g_varchar2
  ,p_nnmntry_uom                    in  varchar2  default hr_api.g_varchar2
  ,p_val                            in  number    default hr_api.g_number
  ,p_incrmt_elcn_val                in  number    default hr_api.g_number
  ,p_rndg_cd                        in  varchar2  default hr_api.g_varchar2
  ,p_val_ovrid_alwd_flag            in  varchar2  default hr_api.g_varchar2
  ,p_prtl_mo_det_mthd_cd            in  varchar2  default hr_api.g_varchar2
  ,p_acty_base_rt_stat_cd           in  varchar2  default hr_api.g_varchar2
  ,p_procg_src_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_dflt_val                       in  number    default hr_api.g_number
  ,p_dflt_flag                      in  varchar2  default hr_api.g_varchar2
  ,p_frgn_erg_ded_typ_cd            in  varchar2  default hr_api.g_varchar2
  ,p_frgn_erg_ded_name              in  varchar2  default hr_api.g_varchar2
  ,p_frgn_erg_ded_ident             in  varchar2  default hr_api.g_varchar2
  ,p_no_mx_elcn_val_dfnd_flag       in  varchar2  default hr_api.g_varchar2
  ,p_prtl_mo_det_mthd_rl            in  number    default hr_api.g_number
  ,p_entr_val_at_enrt_flag          in  varchar2  default hr_api.g_varchar2
  ,p_prtl_mo_eff_dt_det_rl          in  number    default hr_api.g_number
  ,p_rndg_rl                        in  number    default hr_api.g_number
  ,p_val_calc_rl                    in  number    default hr_api.g_number
  ,p_no_mn_elcn_val_dfnd_flag       in  varchar2  default hr_api.g_varchar2
  ,p_prtl_mo_eff_dt_det_cd          in  varchar2  default hr_api.g_varchar2
  ,p_only_one_bal_typ_alwd_flag     in  varchar2  default hr_api.g_varchar2
  ,p_rt_usg_cd                      in  varchar2  default hr_api.g_varchar2
  ,p_prort_mn_ann_elcn_val_cd       in  varchar2  default hr_api.g_varchar2
  ,p_prort_mn_ann_elcn_val_rl       in  number    default hr_api.g_number
  ,p_prort_mx_ann_elcn_val_cd       in  varchar2  default hr_api.g_varchar2
  ,p_prort_mx_ann_elcn_val_rl       in  number    default hr_api.g_number
  ,p_one_ann_pymt_cd                in  varchar2  default hr_api.g_varchar2
  ,p_det_pl_ytd_cntrs_cd            in  varchar2  default hr_api.g_varchar2
  ,p_asmt_to_use_cd                 in  varchar2  default hr_api.g_varchar2
  ,p_ele_rqd_flag                   in  varchar2  default hr_api.g_varchar2
  ,p_subj_to_imptd_incm_flag        in  varchar2  default hr_api.g_varchar2
  ,p_element_type_id                in  number    default hr_api.g_number
  ,p_input_value_id                 in  number    default hr_api.g_number
  ,p_input_va_calc_rl              in  number    default hr_api.g_number
  ,p_comp_lvl_fctr_id               in  number    default hr_api.g_number
  ,p_parnt_acty_base_rt_id          in  number    default hr_api.g_number
  ,p_pgm_id                         in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_oipl_id                        in  number    default hr_api.g_number
  ,p_opt_id                         in  number    default hr_api.g_number
  ,p_oiplip_id                      in  number    default hr_api.g_number
  ,p_plip_id                        in  number    default hr_api.g_number
  ,p_ptip_id                        in  number    default hr_api.g_number
  ,p_cmbn_plip_id                   in  number    default hr_api.g_number
  ,p_cmbn_ptip_id                   in  number    default hr_api.g_number
  ,p_cmbn_ptip_opt_id               in  number    default hr_api.g_number
  ,p_vstg_for_acty_rt_id            in  number    default hr_api.g_number
  ,p_actl_prem_id                   in  number    default hr_api.g_number
  ,p_TTL_COMP_LVL_FCTR_ID           in  number    default hr_api.g_number
  ,p_COST_ALLOCATION_KEYFLEX_ID     in  number    default hr_api.g_number
  ,p_ALWS_CHG_CD                    in  varchar2  default hr_api.g_varchar2
  ,p_ele_entry_val_cd               in  varchar2  default hr_api.g_varchar2
  ,p_pay_rate_grade_rule_id         in  number    default hr_api.g_number
  ,p_rate_periodization_cd          in  varchar2  default hr_api.g_varchar2
  ,p_rate_periodization_rl          in  number    default hr_api.g_number
  ,p_mn_mx_elcn_rl                  in  number    default hr_api.g_number
  ,p_mapping_table_name		    in  varchar2  default hr_api.g_varchar2
  ,p_mapping_table_pk_id	    in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_context_pgm_id                 in number     default hr_api.g_number
  ,p_context_pl_id                  in number     default hr_api.g_number
  ,p_context_opt_id                 in number     default hr_api.g_number
  ,p_element_det_rl                 in  number    default hr_api.g_number
  ,p_currency_det_cd                in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_abr_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_abr_seq_num                    in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_acty_base_rate >------------------------|
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
--   p_acty_base_rt_id              Yes  number    PK of record
--   p_effective_date               Yes  date     Session Date.
--   p_datetrack_mode               Yes  varchar2 Datetrack mode.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_effective_start_date         Yes  date      Effective Start Date of Record
--   p_effective_end_date           Yes  date      Effective End Date of Record
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_acty_base_rate
  (
   p_validate                       in boolean        default false
  ,p_acty_base_rt_id                in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in date
  ,p_datetrack_mode                 in varchar2
  );
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
--   p_acty_base_rt_id                 Yes  number   PK of record
--   p_object_version_number        Yes  number   OVN of record
--   p_effective_date               Yes  date     Session Date.
--   p_datetrack_mode               Yes  varchar2 Datetrack mode.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_validation_start_date        Yes      Derived Effective Start Date.
--   p_validation_end_date          Yes      Derived Effective End Date.
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure lck
  (
    p_acty_base_rt_id                 in number
   ,p_object_version_number        in number
   ,p_effective_date              in date
   ,p_datetrack_mode              in varchar2
   ,p_validation_start_date        out nocopy date
   ,p_validation_end_date          out nocopy date
  );
--
end ben_acty_base_rate_api;

 

/
