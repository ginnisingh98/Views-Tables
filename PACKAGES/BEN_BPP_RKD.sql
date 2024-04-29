--------------------------------------------------------
--  DDL for Package BEN_BPP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BPP_RKD" AUTHID CURRENT_USER as
/* $Header: bebpprhi.pkh 120.0 2005/05/28 00:48:43 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_bnft_prvdr_pool_id             in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_name_o                         in varchar2
 ,p_pgm_pool_flag_o                in varchar2
 ,p_excs_alwys_fftd_flag_o         in varchar2
 ,p_use_for_pgm_pool_flag_o        in varchar2
 ,p_pct_rndg_cd_o                  in varchar2
 ,p_pct_rndg_rl_o                  in number
 ,p_val_rndg_cd_o                  in varchar2
 ,p_val_rndg_rl_o                  in number
 ,p_dflt_excs_trtmt_cd_o           in varchar2
 ,p_dflt_excs_trtmt_rl_o           in number
 ,p_rlovr_rstrcn_cd_o              in varchar2
 ,p_no_mn_dstrbl_pct_flag_o        in varchar2
 ,p_no_mn_dstrbl_val_flag_o        in varchar2
 ,p_no_mx_dstrbl_pct_flag_o        in varchar2
 ,p_no_mx_dstrbl_val_flag_o        in varchar2
 ,p_auto_alct_excs_flag_o          in varchar2
 ,p_alws_ngtv_crs_flag_o           in varchar2
 ,p_uses_net_crs_mthd_flag_o       in varchar2
 ,p_mx_dfcit_pct_pool_crs_num_o    in number
 ,p_mx_dfcit_pct_comp_num_o        in number
 ,p_comp_lvl_fctr_id_o             in number
 ,p_mn_dstrbl_pct_num_o            in number
 ,p_mn_dstrbl_val_o                in number
 ,p_mx_dstrbl_pct_num_o            in number
 ,p_mx_dstrbl_val_o                in number
 ,p_excs_trtmt_cd_o                in varchar2
 ,p_ptip_id_o                      in number
 ,p_plip_id_o                      in number
 ,p_pgm_id_o                       in number
 ,p_oiplip_id_o                    in number
 ,p_cmbn_plip_id_o                 in number
 ,p_cmbn_ptip_id_o                 in number
 ,p_cmbn_ptip_opt_id_o             in number
 ,p_business_group_id_o            in number
 ,p_bpp_attribute_category_o       in varchar2
 ,p_bpp_attribute1_o               in varchar2
 ,p_bpp_attribute2_o               in varchar2
 ,p_bpp_attribute3_o               in varchar2
 ,p_bpp_attribute4_o               in varchar2
 ,p_bpp_attribute5_o               in varchar2
 ,p_bpp_attribute6_o               in varchar2
 ,p_bpp_attribute7_o               in varchar2
 ,p_bpp_attribute8_o               in varchar2
 ,p_bpp_attribute9_o               in varchar2
 ,p_bpp_attribute10_o              in varchar2
 ,p_bpp_attribute11_o              in varchar2
 ,p_bpp_attribute12_o              in varchar2
 ,p_bpp_attribute13_o              in varchar2
 ,p_bpp_attribute14_o              in varchar2
 ,p_bpp_attribute15_o              in varchar2
 ,p_bpp_attribute16_o              in varchar2
 ,p_bpp_attribute17_o              in varchar2
 ,p_bpp_attribute18_o              in varchar2
 ,p_bpp_attribute19_o              in varchar2
 ,p_bpp_attribute20_o              in varchar2
 ,p_bpp_attribute21_o              in varchar2
 ,p_bpp_attribute22_o              in varchar2
 ,p_bpp_attribute23_o              in varchar2
 ,p_bpp_attribute24_o              in varchar2
 ,p_bpp_attribute25_o              in varchar2
 ,p_bpp_attribute26_o              in varchar2
 ,p_bpp_attribute27_o              in varchar2
 ,p_bpp_attribute28_o              in varchar2
 ,p_bpp_attribute29_o              in varchar2
 ,p_bpp_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_bpp_rkd;

 

/
