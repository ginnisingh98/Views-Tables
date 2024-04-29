--------------------------------------------------------
--  DDL for Package BEN_PRTT_RT_VAL_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PRTT_RT_VAL_BK1" AUTHID CURRENT_USER as
/* $Header: beprvapi.pkh 120.0.12000000.1 2007/01/19 22:14:35 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_prtt_rt_val_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_prtt_rt_val_b
  (
   p_rt_strt_dt                     in  date
  ,p_rt_end_dt                      in  date
  ,p_rt_typ_cd                      in  varchar2
  ,p_tx_typ_cd                      in  varchar2
  ,p_ordr_num			    in number
  ,p_acty_typ_cd                    in  varchar2
  ,p_mlt_cd                         in  varchar2
  ,p_acty_ref_perd_cd               in  varchar2
  ,p_rt_val                         in  number
  ,p_ann_rt_val                     in  number
  ,p_cmcd_rt_val                    in  number
  ,p_cmcd_ref_perd_cd               in  varchar2
  ,p_bnft_rt_typ_cd                 in  varchar2
  ,p_dsply_on_enrt_flag             in  varchar2
  ,p_rt_ovridn_flag                 in  varchar2
  ,p_rt_ovridn_thru_dt              in  date
  ,p_elctns_made_dt                 in  date
  ,p_prtt_rt_val_stat_cd            in  varchar2
  ,p_prtt_enrt_rslt_id              in  number
  ,p_cvg_amt_calc_mthd_id           in  number
  ,p_actl_prem_id                   in  number
  ,p_comp_lvl_fctr_id               in  number
  ,p_element_entry_value_id         in  number
  ,p_per_in_ler_id                  in  number
  ,p_ended_per_in_ler_id            in  number
  ,p_acty_base_rt_id                in  number
  ,p_prtt_reimbmt_rqst_id           in  number
  ,p_prtt_rmt_aprvd_fr_pymt_id      in  number
  ,p_pp_in_yr_used_num              in  number
  ,p_business_group_id              in  number
  ,p_prv_attribute_category         in  varchar2
  ,p_prv_attribute1                 in  varchar2
  ,p_prv_attribute2                 in  varchar2
  ,p_prv_attribute3                 in  varchar2
  ,p_prv_attribute4                 in  varchar2
  ,p_prv_attribute5                 in  varchar2
  ,p_prv_attribute6                 in  varchar2
  ,p_prv_attribute7                 in  varchar2
  ,p_prv_attribute8                 in  varchar2
  ,p_prv_attribute9                 in  varchar2
  ,p_prv_attribute10                in  varchar2
  ,p_prv_attribute11                in  varchar2
  ,p_prv_attribute12                in  varchar2
  ,p_prv_attribute13                in  varchar2
  ,p_prv_attribute14                in  varchar2
  ,p_prv_attribute15                in  varchar2
  ,p_prv_attribute16                in  varchar2
  ,p_prv_attribute17                in  varchar2
  ,p_prv_attribute18                in  varchar2
  ,p_prv_attribute19                in  varchar2
  ,p_prv_attribute20                in  varchar2
  ,p_prv_attribute21                in  varchar2
  ,p_prv_attribute22                in  varchar2
  ,p_prv_attribute23                in  varchar2
  ,p_prv_attribute24                in  varchar2
  ,p_prv_attribute25                in  varchar2
  ,p_prv_attribute26                in  varchar2
  ,p_prv_attribute27                in  varchar2
  ,p_prv_attribute28                in  varchar2
  ,p_prv_attribute29                in  varchar2
  ,p_prv_attribute30                in  varchar2
  ,p_pk_id_table_name               in  varchar2
  ,p_pk_id                          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_prtt_rt_val_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_prtt_rt_val_a
  (
   p_prtt_rt_val_id                 in  number
  ,p_rt_strt_dt                     in  date
  ,p_rt_end_dt                      in  date
  ,p_rt_typ_cd                      in  varchar2
  ,p_tx_typ_cd                      in  varchar2
  ,p_ordr_num			    in number
  ,p_acty_typ_cd                    in  varchar2
  ,p_mlt_cd                         in  varchar2
  ,p_acty_ref_perd_cd               in  varchar2
  ,p_rt_val                         in  number
  ,p_ann_rt_val                     in  number
  ,p_cmcd_rt_val                    in  number
  ,p_cmcd_ref_perd_cd               in  varchar2
  ,p_bnft_rt_typ_cd                 in  varchar2
  ,p_dsply_on_enrt_flag             in  varchar2
  ,p_rt_ovridn_flag                 in  varchar2
  ,p_rt_ovridn_thru_dt              in  date
  ,p_elctns_made_dt                 in  date
  ,p_prtt_rt_val_stat_cd            in  varchar2
  ,p_prtt_enrt_rslt_id              in  number
  ,p_cvg_amt_calc_mthd_id           in  number
  ,p_actl_prem_id                   in  number
  ,p_comp_lvl_fctr_id               in  number
  ,p_element_entry_value_id         in  number
  ,p_per_in_ler_id                  in  number
  ,p_ended_per_in_ler_id            in  number
  ,p_acty_base_rt_id                in  number
  ,p_prtt_reimbmt_rqst_id           in  number
  ,p_prtt_rmt_aprvd_fr_pymt_id      in  number
  ,p_pp_in_yr_used_num              in  number
  ,p_business_group_id              in  number
  ,p_prv_attribute_category         in  varchar2
  ,p_prv_attribute1                 in  varchar2
  ,p_prv_attribute2                 in  varchar2
  ,p_prv_attribute3                 in  varchar2
  ,p_prv_attribute4                 in  varchar2
  ,p_prv_attribute5                 in  varchar2
  ,p_prv_attribute6                 in  varchar2
  ,p_prv_attribute7                 in  varchar2
  ,p_prv_attribute8                 in  varchar2
  ,p_prv_attribute9                 in  varchar2
  ,p_prv_attribute10                in  varchar2
  ,p_prv_attribute11                in  varchar2
  ,p_prv_attribute12                in  varchar2
  ,p_prv_attribute13                in  varchar2
  ,p_prv_attribute14                in  varchar2
  ,p_prv_attribute15                in  varchar2
  ,p_prv_attribute16                in  varchar2
  ,p_prv_attribute17                in  varchar2
  ,p_prv_attribute18                in  varchar2
  ,p_prv_attribute19                in  varchar2
  ,p_prv_attribute20                in  varchar2
  ,p_prv_attribute21                in  varchar2
  ,p_prv_attribute22                in  varchar2
  ,p_prv_attribute23                in  varchar2
  ,p_prv_attribute24                in  varchar2
  ,p_prv_attribute25                in  varchar2
  ,p_prv_attribute26                in  varchar2
  ,p_prv_attribute27                in  varchar2
  ,p_prv_attribute28                in  varchar2
  ,p_prv_attribute29                in  varchar2
  ,p_prv_attribute30                in  varchar2
  ,p_pk_id_table_name               in  varchar2
  ,p_pk_id                          in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_prtt_rt_val_bk1;

 

/
