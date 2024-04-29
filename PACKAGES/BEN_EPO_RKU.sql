--------------------------------------------------------
--  DDL for Package BEN_EPO_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EPO_RKU" AUTHID CURRENT_USER as
/* $Header: beeporhi.pkh 120.0 2005/05/28 02:42:36 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_elig_per_opt_id                in number
 ,p_elig_per_id                    in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_prtn_ovridn_flag               in varchar2
 ,p_prtn_ovridn_thru_dt            in date
 ,p_no_mx_prtn_ovrid_thru_flag     in varchar2
 ,p_elig_flag                      in varchar2
 ,p_prtn_strt_dt                   in date
 ,p_prtn_end_dt                    in date
 ,p_wait_perd_cmpltn_date            in date
 ,p_wait_perd_strt_dt              in date
 ,p_prtn_ovridn_rsn_cd             in varchar2
 ,p_pct_fl_tm_val                  in number
 ,p_rt_comp_ref_amt                in number
 ,p_rt_cmbn_age_n_los_val          in number
 ,p_rt_comp_ref_uom                in varchar2
 ,p_rt_age_val                     in number
 ,p_rt_los_val                     in number
 ,p_rt_hrs_wkd_val                 in number
 ,p_rt_hrs_wkd_bndry_perd_cd       in varchar2
 ,p_rt_age_uom                     in varchar2
 ,p_rt_los_uom                     in varchar2
 ,p_rt_pct_fl_tm_val               in number
 ,p_rt_frz_los_flag                in varchar2
 ,p_rt_frz_age_flag                in varchar2
 ,p_rt_frz_cmp_lvl_flag            in varchar2
 ,p_rt_frz_pct_fl_tm_flag          in varchar2
 ,p_rt_frz_hrs_wkd_flag            in varchar2
 ,p_rt_frz_comb_age_and_los_flag   in varchar2
 ,p_comp_ref_amt                   in number
 ,p_cmbn_age_n_los_val             in number
 ,p_comp_ref_uom                   in varchar2
 ,p_age_val                        in number
 ,p_los_val                        in number
 ,p_hrs_wkd_val                    in number
 ,p_hrs_wkd_bndry_perd_cd          in varchar2
 ,p_age_uom                        in varchar2
 ,p_los_uom                        in varchar2
 ,p_frz_los_flag                   in varchar2
 ,p_frz_age_flag                   in varchar2
 ,p_frz_cmp_lvl_flag               in varchar2
 ,p_frz_pct_fl_tm_flag             in varchar2
 ,p_frz_hrs_wkd_flag               in varchar2
 ,p_frz_comb_age_and_los_flag      in varchar2
 ,p_ovrid_svc_dt                   in date
 ,p_inelg_rsn_cd                   in varchar2
 ,p_once_r_cntug_cd                in varchar2
 ,p_oipl_ordr_num                  in number
 ,p_opt_id                         in number
 ,p_per_in_ler_id                  in number
 ,p_business_group_id              in number
 ,p_epo_attribute_category         in varchar2
 ,p_epo_attribute1                 in varchar2
 ,p_epo_attribute2                 in varchar2
 ,p_epo_attribute3                 in varchar2
 ,p_epo_attribute4                 in varchar2
 ,p_epo_attribute5                 in varchar2
 ,p_epo_attribute6                 in varchar2
 ,p_epo_attribute7                 in varchar2
 ,p_epo_attribute8                 in varchar2
 ,p_epo_attribute9                 in varchar2
 ,p_epo_attribute10                in varchar2
 ,p_epo_attribute11                in varchar2
 ,p_epo_attribute12                in varchar2
 ,p_epo_attribute13                in varchar2
 ,p_epo_attribute14                in varchar2
 ,p_epo_attribute15                in varchar2
 ,p_epo_attribute16                in varchar2
 ,p_epo_attribute17                in varchar2
 ,p_epo_attribute18                in varchar2
 ,p_epo_attribute19                in varchar2
 ,p_epo_attribute20                in varchar2
 ,p_epo_attribute21                in varchar2
 ,p_epo_attribute22                in varchar2
 ,p_epo_attribute23                in varchar2
 ,p_epo_attribute24                in varchar2
 ,p_epo_attribute25                in varchar2
 ,p_epo_attribute26                in varchar2
 ,p_epo_attribute27                in varchar2
 ,p_epo_attribute28                in varchar2
 ,p_epo_attribute29                in varchar2
 ,p_epo_attribute30                in varchar2
 ,p_request_id                     in number
 ,p_program_application_id         in number
 ,p_program_id                     in number
 ,p_program_update_date            in date
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_elig_per_id_o                  in number
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_prtn_ovridn_flag_o             in varchar2
 ,p_prtn_ovridn_thru_dt_o          in date
 ,p_no_mx_prtn_ovrid_thru_flag_o   in varchar2
 ,p_elig_flag_o                    in varchar2
 ,p_prtn_strt_dt_o                 in date
 ,p_prtn_end_dt_o                  in date
 ,p_wait_perd_cmpltn_date_o          in date
 ,p_wait_perd_strt_dt_o            in date
 ,p_prtn_ovridn_rsn_cd_o           in varchar2
 ,p_pct_fl_tm_val_o                in number
 ,p_opt_id_o                       in number
 ,p_per_in_ler_id_o                in number
 ,p_rt_comp_ref_amt_o              in number
 ,p_rt_cmbn_age_n_los_val_o        in number
 ,p_rt_comp_ref_uom_o              in varchar2
 ,p_rt_age_val_o                   in number
 ,p_rt_los_val_o                   in number
 ,p_rt_hrs_wkd_val_o               in number
 ,p_rt_hrs_wkd_bndry_perd_cd_o     in varchar2
 ,p_rt_age_uom_o                   in varchar2
 ,p_rt_los_uom_o                   in varchar2
 ,p_rt_pct_fl_tm_val_o             in number
 ,p_rt_frz_los_flag_o              in varchar2
 ,p_rt_frz_age_flag_o              in varchar2
 ,p_rt_frz_cmp_lvl_flag_o          in varchar2
 ,p_rt_frz_pct_fl_tm_flag_o        in varchar2
 ,p_rt_frz_hrs_wkd_flag_o          in varchar2
 ,p_rt_frz_comb_age_and_los_fl_o   in varchar2
 ,p_comp_ref_amt_o                 in number
 ,p_cmbn_age_n_los_val_o           in number
 ,p_comp_ref_uom_o                 in varchar2
 ,p_age_val_o                      in number
 ,p_los_val_o                      in number
 ,p_hrs_wkd_val_o                  in number
 ,p_hrs_wkd_bndry_perd_cd_o        in varchar2
 ,p_age_uom_o                      in varchar2
 ,p_los_uom_o                      in varchar2
 ,p_frz_los_flag_o                 in varchar2
 ,p_frz_age_flag_o                 in varchar2
 ,p_frz_cmp_lvl_flag_o             in varchar2
 ,p_frz_pct_fl_tm_flag_o           in varchar2
 ,p_frz_hrs_wkd_flag_o             in varchar2
 ,p_frz_comb_age_and_los_flag_o    in varchar2
 ,p_ovrid_svc_dt_o                 in date
 ,p_inelg_rsn_cd_o                 in varchar2
 ,p_once_r_cntug_cd_o              in varchar2
 ,p_oipl_ordr_num_o                  in number
 ,p_business_group_id_o            in number
 ,p_epo_attribute_category_o       in varchar2
 ,p_epo_attribute1_o               in varchar2
 ,p_epo_attribute2_o               in varchar2
 ,p_epo_attribute3_o               in varchar2
 ,p_epo_attribute4_o               in varchar2
 ,p_epo_attribute5_o               in varchar2
 ,p_epo_attribute6_o               in varchar2
 ,p_epo_attribute7_o               in varchar2
 ,p_epo_attribute8_o               in varchar2
 ,p_epo_attribute9_o               in varchar2
 ,p_epo_attribute10_o              in varchar2
 ,p_epo_attribute11_o              in varchar2
 ,p_epo_attribute12_o              in varchar2
 ,p_epo_attribute13_o              in varchar2
 ,p_epo_attribute14_o              in varchar2
 ,p_epo_attribute15_o              in varchar2
 ,p_epo_attribute16_o              in varchar2
 ,p_epo_attribute17_o              in varchar2
 ,p_epo_attribute18_o              in varchar2
 ,p_epo_attribute19_o              in varchar2
 ,p_epo_attribute20_o              in varchar2
 ,p_epo_attribute21_o              in varchar2
 ,p_epo_attribute22_o              in varchar2
 ,p_epo_attribute23_o              in varchar2
 ,p_epo_attribute24_o              in varchar2
 ,p_epo_attribute25_o              in varchar2
 ,p_epo_attribute26_o              in varchar2
 ,p_epo_attribute27_o              in varchar2
 ,p_epo_attribute28_o              in varchar2
 ,p_epo_attribute29_o              in varchar2
 ,p_epo_attribute30_o              in varchar2
 ,p_request_id_o                   in number
 ,p_program_application_id_o       in number
 ,p_program_id_o                   in number
 ,p_program_update_date_o          in date
 ,p_object_version_number_o        in number
  );
--
end ben_epo_rku;

 

/
