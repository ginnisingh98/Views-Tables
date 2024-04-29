--------------------------------------------------------
--  DDL for Package BEN_EPA_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EPA_RKD" AUTHID CURRENT_USER as
/* $Header: beeparhi.pkh 120.0 2005/05/28 02:35:28 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
   p_prtn_elig_id                  in number
  ,p_datetrack_mode                in varchar2
  ,p_validation_start_date         in date
  ,p_validation_end_date           in date
  ,p_effective_start_date          in date
  ,p_effective_end_date            in date
  ,p_effective_start_date_o        in date
  ,p_effective_end_date_o          in date
  ,p_business_group_id_o           in number
  ,p_pgm_id_o                      in number
  ,p_pl_id_o                       in number
  ,p_oipl_id_o                     in number
  ,p_ptip_id_o                     in number
  ,p_plip_id_o                     in number
  ,p_trk_scr_for_inelg_flag_o      in varchar2
  ,p_prtn_eff_strt_dt_cd_o         in varchar2
  ,p_prtn_eff_end_dt_cd_o          in varchar2
  ,p_prtn_eff_strt_dt_rl_o         in number
  ,p_prtn_eff_end_dt_rl_o          in number
  ,p_wait_perd_dt_to_use_cd_o      in varchar2
  ,p_wait_perd_dt_to_use_rl_o      in number
  ,p_wait_perd_val_o               in number
  ,p_wait_perd_uom_o               in varchar2
  ,p_wait_perd_rl_o                in number
  ,p_mx_poe_det_dt_cd_o            in varchar2
  ,p_mx_poe_det_dt_rl_o            in number
  ,p_mx_poe_val_o                  in number
  ,p_mx_poe_uom_o                  in varchar2
  ,p_mx_poe_rl_o                   in number
  ,p_mx_poe_apls_cd_o              in varchar2
  ,p_epa_attribute_category_o      in varchar2
  ,p_epa_attribute1_o              in varchar2
  ,p_epa_attribute2_o              in varchar2
  ,p_epa_attribute3_o              in varchar2
  ,p_epa_attribute4_o              in varchar2
  ,p_epa_attribute5_o              in varchar2
  ,p_epa_attribute6_o              in varchar2
  ,p_epa_attribute7_o              in varchar2
  ,p_epa_attribute8_o              in varchar2
  ,p_epa_attribute9_o              in varchar2
  ,p_epa_attribute10_o             in varchar2
  ,p_epa_attribute11_o             in varchar2
  ,p_epa_attribute12_o             in varchar2
  ,p_epa_attribute13_o             in varchar2
  ,p_epa_attribute14_o             in varchar2
  ,p_epa_attribute15_o             in varchar2
  ,p_epa_attribute16_o             in varchar2
  ,p_epa_attribute17_o             in varchar2
  ,p_epa_attribute18_o             in varchar2
  ,p_epa_attribute19_o             in varchar2
  ,p_epa_attribute20_o             in varchar2
  ,p_epa_attribute21_o             in varchar2
  ,p_epa_attribute22_o             in varchar2
  ,p_epa_attribute23_o             in varchar2
  ,p_epa_attribute24_o             in varchar2
  ,p_epa_attribute25_o             in varchar2
  ,p_epa_attribute26_o             in varchar2
  ,p_epa_attribute27_o             in varchar2
  ,p_epa_attribute28_o             in varchar2
  ,p_epa_attribute29_o             in varchar2
  ,p_epa_attribute30_o             in varchar2
  ,p_object_version_number_o       in number
  );
--
end ben_epa_rkd;

 

/
