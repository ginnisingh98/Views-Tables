--------------------------------------------------------
--  DDL for Package BEN_CCM_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CCM_RKU" AUTHID CURRENT_USER as
/* $Header: beccmrhi.pkh 120.0 2005/05/28 00:57:41 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_cvg_amt_calc_mthd_id           in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_name                           in varchar2
 ,p_incrmt_val                     in number
 ,p_mx_val                         in number
 ,p_mn_val                         in number
 ,p_no_mx_val_dfnd_flag            in varchar2
 ,p_no_mn_val_dfnd_flag            in varchar2
 ,p_rndg_cd                        in varchar2
 ,p_rndg_rl                        in number
 ,p_lwr_lmt_val                    in number
 ,p_lwr_lmt_calc_rl                in number
 ,p_upr_lmt_val                    in number
 ,p_upr_lmt_calc_rl                in number
 ,p_val                            in number
 ,p_val_ovrid_alwd_flag            in varchar2
 ,p_val_calc_rl                    in number
 ,p_uom                            in varchar2
 ,p_nnmntry_uom                    in varchar2
 ,p_bndry_perd_cd                  in varchar2
 ,p_bnft_typ_cd                    in varchar2
 ,p_cvg_mlt_cd                     in varchar2
 ,p_rt_typ_cd                      in varchar2
 ,p_dflt_val                       in number
 ,p_entr_val_at_enrt_flag          in varchar2
 ,p_dflt_flag                      in varchar2
 ,p_comp_lvl_fctr_id               in number
 ,p_oipl_id                        in number
 ,p_pl_id                          in number
 ,p_plip_id                        in number
 ,p_business_group_id              in number
 ,p_ccm_attribute_category         in varchar2
 ,p_ccm_attribute1                 in varchar2
 ,p_ccm_attribute2                 in varchar2
 ,p_ccm_attribute3                 in varchar2
 ,p_ccm_attribute4                 in varchar2
 ,p_ccm_attribute5                 in varchar2
 ,p_ccm_attribute6                 in varchar2
 ,p_ccm_attribute7                 in varchar2
 ,p_ccm_attribute8                 in varchar2
 ,p_ccm_attribute9                 in varchar2
 ,p_ccm_attribute10                in varchar2
 ,p_ccm_attribute11                in varchar2
 ,p_ccm_attribute12                in varchar2
 ,p_ccm_attribute13                in varchar2
 ,p_ccm_attribute14                in varchar2
 ,p_ccm_attribute15                in varchar2
 ,p_ccm_attribute16                in varchar2
 ,p_ccm_attribute17                in varchar2
 ,p_ccm_attribute18                in varchar2
 ,p_ccm_attribute19                in varchar2
 ,p_ccm_attribute20                in varchar2
 ,p_ccm_attribute21                in varchar2
 ,p_ccm_attribute22                in varchar2
 ,p_ccm_attribute23                in varchar2
 ,p_ccm_attribute24                in varchar2
 ,p_ccm_attribute25                in varchar2
 ,p_ccm_attribute26                in varchar2
 ,p_ccm_attribute27                in varchar2
 ,p_ccm_attribute28                in varchar2
 ,p_ccm_attribute29                in varchar2
 ,p_ccm_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_name_o                         in varchar2
 ,p_incrmt_val_o                   in number
 ,p_mx_val_o                       in number
 ,p_mn_val_o                       in number
 ,p_no_mx_val_dfnd_flag_o          in varchar2
 ,p_no_mn_val_dfnd_flag_o          in varchar2
 ,p_rndg_cd_o                      in varchar2
 ,p_rndg_rl_o                      in number
 ,p_lwr_lmt_val_o                  in number
 ,p_lwr_lmt_calc_rl_o              in number
 ,p_upr_lmt_val_o                  in number
 ,p_upr_lmt_calc_rl_o              in number
 ,p_val_o                          in number
 ,p_val_ovrid_alwd_flag_o          in varchar2
 ,p_val_calc_rl_o                  in number
 ,p_uom_o                          in varchar2
 ,p_nnmntry_uom_o                  in varchar2
 ,p_bndry_perd_cd_o                in varchar2
 ,p_bnft_typ_cd_o                  in varchar2
 ,p_cvg_mlt_cd_o                   in varchar2
 ,p_rt_typ_cd_o                    in varchar2
 ,p_dflt_val_o                     in number
 ,p_entr_val_at_enrt_flag_o        in varchar2
 ,p_dflt_flag_o                    in varchar2
 ,p_comp_lvl_fctr_id_o             in number
 ,p_oipl_id_o                      in number
 ,p_pl_id_o                        in number
 ,p_plip_id_o                      in number
 ,p_business_group_id_o            in number
 ,p_ccm_attribute_category_o       in varchar2
 ,p_ccm_attribute1_o               in varchar2
 ,p_ccm_attribute2_o               in varchar2
 ,p_ccm_attribute3_o               in varchar2
 ,p_ccm_attribute4_o               in varchar2
 ,p_ccm_attribute5_o               in varchar2
 ,p_ccm_attribute6_o               in varchar2
 ,p_ccm_attribute7_o               in varchar2
 ,p_ccm_attribute8_o               in varchar2
 ,p_ccm_attribute9_o               in varchar2
 ,p_ccm_attribute10_o              in varchar2
 ,p_ccm_attribute11_o              in varchar2
 ,p_ccm_attribute12_o              in varchar2
 ,p_ccm_attribute13_o              in varchar2
 ,p_ccm_attribute14_o              in varchar2
 ,p_ccm_attribute15_o              in varchar2
 ,p_ccm_attribute16_o              in varchar2
 ,p_ccm_attribute17_o              in varchar2
 ,p_ccm_attribute18_o              in varchar2
 ,p_ccm_attribute19_o              in varchar2
 ,p_ccm_attribute20_o              in varchar2
 ,p_ccm_attribute21_o              in varchar2
 ,p_ccm_attribute22_o              in varchar2
 ,p_ccm_attribute23_o              in varchar2
 ,p_ccm_attribute24_o              in varchar2
 ,p_ccm_attribute25_o              in varchar2
 ,p_ccm_attribute26_o              in varchar2
 ,p_ccm_attribute27_o              in varchar2
 ,p_ccm_attribute28_o              in varchar2
 ,p_ccm_attribute29_o              in varchar2
 ,p_ccm_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_ccm_rku;

 

/
