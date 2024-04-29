--------------------------------------------------------
--  DDL for Package BEN_APR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_APR_RKD" AUTHID CURRENT_USER as
/* $Header: beaprrhi.pkh 120.0 2005/05/28 00:27:01 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_actl_prem_id                   in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_name_o                         in varchar2
 ,p_acty_ref_perd_cd_o             in varchar2
 ,p_uom_o                          in varchar2
 ,p_rt_typ_cd_o                    in varchar2
 ,p_bnft_rt_typ_cd_o               in varchar2
 ,p_val_o                          in number
 ,p_mlt_cd_o                       in varchar2
 ,p_prdct_cd_o                     in varchar2
 ,p_rndg_cd_o                      in varchar2
 ,p_rndg_rl_o                      in number
 ,p_val_calc_rl_o                   in number
 ,p_prem_asnmt_cd_o                 in varchar2
 ,p_prem_asnmt_lvl_cd_o             in varchar2
 ,p_actl_prem_typ_cd_o              in varchar2
 ,p_prem_pyr_cd_o                   in varchar2
 ,p_cr_lkbk_val_o                   in number
 ,p_cr_lkbk_uom_o                   in varchar2
 ,p_cr_lkbk_crnt_py_only_flag_o     in varchar2
 ,p_prsptv_r_rtsptv_cd_o            in varchar2
 ,p_upr_lmt_val_o                   in number
 ,p_upr_lmt_calc_rl_o               in number
 ,p_lwr_lmt_val_o                   in number
 ,p_lwr_lmt_calc_rl_o               in number
 ,p_cost_allocation_keyflex_id_o    in number
 ,p_organization_id_o               in number
 ,p_oipl_id_o                       in number
 ,p_pl_id_o                         in number
 ,p_comp_lvl_fctr_id_o             in number
 ,p_business_group_id_o            in number
 ,p_prtl_mo_det_mthd_cd_o           in varchar2
 ,p_prtl_mo_det_mthd_rl_o           in number
 ,p_wsh_rl_dy_mo_num_o              in number
 ,p_vrbl_rt_add_on_calc_rl_o        in number
 ,p_apr_attribute_category_o       in varchar2
 ,p_apr_attribute1_o               in varchar2
 ,p_apr_attribute2_o               in varchar2
 ,p_apr_attribute3_o               in varchar2
 ,p_apr_attribute4_o               in varchar2
 ,p_apr_attribute5_o               in varchar2
 ,p_apr_attribute6_o               in varchar2
 ,p_apr_attribute7_o               in varchar2
 ,p_apr_attribute8_o               in varchar2
 ,p_apr_attribute9_o               in varchar2
 ,p_apr_attribute10_o              in varchar2
 ,p_apr_attribute11_o              in varchar2
 ,p_apr_attribute12_o              in varchar2
 ,p_apr_attribute13_o              in varchar2
 ,p_apr_attribute14_o              in varchar2
 ,p_apr_attribute15_o              in varchar2
 ,p_apr_attribute16_o              in varchar2
 ,p_apr_attribute17_o              in varchar2
 ,p_apr_attribute18_o              in varchar2
 ,p_apr_attribute19_o              in varchar2
 ,p_apr_attribute20_o              in varchar2
 ,p_apr_attribute21_o              in varchar2
 ,p_apr_attribute22_o              in varchar2
 ,p_apr_attribute23_o              in varchar2
 ,p_apr_attribute24_o              in varchar2
 ,p_apr_attribute25_o              in varchar2
 ,p_apr_attribute26_o              in varchar2
 ,p_apr_attribute27_o              in varchar2
 ,p_apr_attribute28_o              in varchar2
 ,p_apr_attribute29_o              in varchar2
 ,p_apr_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_apr_rkd;

 

/
