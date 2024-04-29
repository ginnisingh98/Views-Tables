--------------------------------------------------------
--  DDL for Package BEN_EPA_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EPA_RKU" AUTHID CURRENT_USER as
/* $Header: beeparhi.pkh 120.0 2005/05/28 02:35:28 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
   p_prtn_elig_id                  in number
  ,p_effective_start_date          in date
  ,p_effective_end_date            in date
  ,p_business_group_id             in number
  ,p_pgm_id                        in number
  ,p_pl_id                         in number
  ,p_oipl_id                       in number
  ,p_ptip_id                       in number
  ,p_plip_id                       in number
  ,p_trk_scr_for_inelg_flag        in varchar2
  ,p_prtn_eff_strt_dt_cd           in varchar2
  ,p_prtn_eff_end_dt_cd            in varchar2
  ,p_prtn_eff_strt_dt_rl           in number
  ,p_prtn_eff_end_dt_rl            in number
  ,p_wait_perd_dt_to_use_cd        in varchar2
  ,p_wait_perd_dt_to_use_rl        in number
  ,p_wait_perd_val                 in number
  ,p_wait_perd_uom                 in varchar2
  ,p_wait_perd_rl                  in number
  ,p_mx_poe_det_dt_cd              in varchar2
  ,p_mx_poe_det_dt_rl              in number
  ,p_mx_poe_val                    in number
  ,p_mx_poe_uom                    in varchar2
  ,p_mx_poe_rl                     in number
  ,p_mx_poe_apls_cd                in varchar2
  ,p_epa_attribute_category        in varchar2
  ,p_epa_attribute1                in varchar2
  ,p_epa_attribute2                in varchar2
  ,p_epa_attribute3                in varchar2
  ,p_epa_attribute4                in varchar2
  ,p_epa_attribute5                in varchar2
  ,p_epa_attribute6                in varchar2
  ,p_epa_attribute7                in varchar2
  ,p_epa_attribute8                in varchar2
  ,p_epa_attribute9                in varchar2
  ,p_epa_attribute10               in varchar2
  ,p_epa_attribute11               in varchar2
  ,p_epa_attribute12               in varchar2
  ,p_epa_attribute13               in varchar2
  ,p_epa_attribute14               in varchar2
  ,p_epa_attribute15               in varchar2
  ,p_epa_attribute16               in varchar2
  ,p_epa_attribute17               in varchar2
  ,p_epa_attribute18               in varchar2
  ,p_epa_attribute19               in varchar2
  ,p_epa_attribute20               in varchar2
  ,p_epa_attribute21               in varchar2
  ,p_epa_attribute22               in varchar2
  ,p_epa_attribute23               in varchar2
  ,p_epa_attribute24               in varchar2
  ,p_epa_attribute25               in varchar2
  ,p_epa_attribute26               in varchar2
  ,p_epa_attribute27               in varchar2
  ,p_epa_attribute28               in varchar2
  ,p_epa_attribute29               in varchar2
  ,p_epa_attribute30               in varchar2
  ,p_object_version_number         in number
  ,p_effective_date                in date
  ,p_datetrack_mode                in varchar2
  ,p_validation_start_date         in date
  ,p_validation_end_date           in date
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
end ben_epa_rku;

 

/
