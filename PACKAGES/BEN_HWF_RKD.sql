--------------------------------------------------------
--  DDL for Package BEN_HWF_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_HWF_RKD" AUTHID CURRENT_USER as
/* $Header: behwfrhi.pkh 120.0 2005/05/28 03:12:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_hrs_wkd_in_perd_fctr_id        in number
 ,p_name_o                         in varchar2
 ,p_business_group_id_o            in number
 ,p_hrs_src_cd_o                   in varchar2
 ,p_rndg_cd_o                      in varchar2
 ,p_rndg_rl_o                      in number
 ,p_hrs_wkd_det_cd_o               in varchar2
 ,p_hrs_wkd_det_rl_o               in number
 ,p_no_mn_hrs_wkd_flag_o           in varchar2
 ,p_mx_hrs_num_o                   in number
 ,p_no_mx_hrs_wkd_flag_o           in varchar2
 ,p_once_r_cntug_cd_o              in varchar2
 ,p_mn_hrs_num_o                   in number
 ,p_hrs_alt_val_to_use_cd_o        in varchar2
 ,p_pyrl_freq_cd_o                 in varchar2
 ,p_hrs_wkd_calc_rl_o              in number
 ,p_defined_balance_id_o           in number
 ,p_bnfts_bal_id_o                 in number
 ,p_hwf_attribute_category_o       in varchar2
 ,p_hwf_attribute1_o               in varchar2
 ,p_hwf_attribute2_o               in varchar2
 ,p_hwf_attribute3_o               in varchar2
 ,p_hwf_attribute4_o               in varchar2
 ,p_hwf_attribute5_o               in varchar2
 ,p_hwf_attribute6_o               in varchar2
 ,p_hwf_attribute7_o               in varchar2
 ,p_hwf_attribute8_o               in varchar2
 ,p_hwf_attribute9_o               in varchar2
 ,p_hwf_attribute10_o              in varchar2
 ,p_hwf_attribute11_o              in varchar2
 ,p_hwf_attribute12_o              in varchar2
 ,p_hwf_attribute13_o              in varchar2
 ,p_hwf_attribute14_o              in varchar2
 ,p_hwf_attribute15_o              in varchar2
 ,p_hwf_attribute16_o              in varchar2
 ,p_hwf_attribute17_o              in varchar2
 ,p_hwf_attribute18_o              in varchar2
 ,p_hwf_attribute19_o              in varchar2
 ,p_hwf_attribute20_o              in varchar2
 ,p_hwf_attribute21_o              in varchar2
 ,p_hwf_attribute22_o              in varchar2
 ,p_hwf_attribute23_o              in varchar2
 ,p_hwf_attribute24_o              in varchar2
 ,p_hwf_attribute25_o              in varchar2
 ,p_hwf_attribute26_o              in varchar2
 ,p_hwf_attribute27_o              in varchar2
 ,p_hwf_attribute28_o              in varchar2
 ,p_hwf_attribute29_o              in varchar2
 ,p_hwf_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_hwf_rkd;

 

/
