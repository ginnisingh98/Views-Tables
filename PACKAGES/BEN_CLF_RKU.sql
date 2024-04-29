--------------------------------------------------------
--  DDL for Package BEN_CLF_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CLF_RKU" AUTHID CURRENT_USER as
/* $Header: beclfrhi.pkh 120.0 2005/05/28 01:04:18 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_comp_lvl_fctr_id               in number
 ,p_business_group_id              in number
 ,p_name                           in varchar2
 ,p_comp_lvl_det_cd                in varchar2
 ,p_comp_lvl_det_rl                in number
 ,p_comp_lvl_uom                   in varchar2
 ,p_comp_src_cd                    in varchar2
 ,p_defined_balance_id             in number
 ,p_no_mn_comp_flag                in varchar2
 ,p_no_mx_comp_flag                in varchar2
 ,p_mx_comp_val                    in number
 ,p_mn_comp_val                    in number
 ,p_rndg_cd                        in varchar2
 ,p_rndg_rl                        in number
 ,p_bnfts_bal_id                   in number
 ,p_comp_alt_val_to_use_cd         in varchar2
 ,p_comp_calc_rl                   in number
 ,p_proration_flag                 in Varchar2
 ,p_start_day_mo                   in Varchar2
 ,p_end_day_mo                     in Varchar2
 ,p_start_year                     in Varchar2
 ,p_end_year                       in Varchar2
 ,p_clf_attribute_category         in varchar2
 ,p_clf_attribute1                 in varchar2
 ,p_clf_attribute2                 in varchar2
 ,p_clf_attribute3                 in varchar2
 ,p_clf_attribute4                 in varchar2
 ,p_clf_attribute5                 in varchar2
 ,p_clf_attribute6                 in varchar2
 ,p_clf_attribute7                 in varchar2
 ,p_clf_attribute8                 in varchar2
 ,p_clf_attribute9                 in varchar2
 ,p_clf_attribute10                in varchar2
 ,p_clf_attribute11                in varchar2
 ,p_clf_attribute12                in varchar2
 ,p_clf_attribute13                in varchar2
 ,p_clf_attribute14                in varchar2
 ,p_clf_attribute15                in varchar2
 ,p_clf_attribute16                in varchar2
 ,p_clf_attribute17                in varchar2
 ,p_clf_attribute18                in varchar2
 ,p_clf_attribute19                in varchar2
 ,p_clf_attribute20                in varchar2
 ,p_clf_attribute21                in varchar2
 ,p_clf_attribute22                in varchar2
 ,p_clf_attribute23                in varchar2
 ,p_clf_attribute24                in varchar2
 ,p_clf_attribute25                in varchar2
 ,p_clf_attribute26                in varchar2
 ,p_clf_attribute27                in varchar2
 ,p_clf_attribute28                in varchar2
 ,p_clf_attribute29                in varchar2
 ,p_clf_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_sttd_sal_prdcty_cd             in varchar2
 ,p_business_group_id_o            in number
 ,p_name_o                         in varchar2
 ,p_comp_lvl_det_cd_o              in varchar2
 ,p_comp_lvl_det_rl_o              in number
 ,p_comp_lvl_uom_o                 in varchar2
 ,p_comp_src_cd_o                  in varchar2
 ,p_defined_balance_id_o           in number
 ,p_no_mn_comp_flag_o              in varchar2
 ,p_no_mx_comp_flag_o              in varchar2
 ,p_mx_comp_val_o                  in number
 ,p_mn_comp_val_o                  in number
 ,p_rndg_cd_o                      in varchar2
 ,p_rndg_rl_o                      in number
 ,p_bnfts_bal_id_o                 in number
 ,p_comp_alt_val_to_use_cd_o       in varchar2
 ,p_comp_calc_rl_o                 in number
 ,p_proration_flag_o               in Varchar2
 ,p_start_day_mo_o                 in Varchar2
 ,p_end_day_mo_o                   in Varchar2
 ,p_start_year_o                   in Varchar2
 ,p_end_year_o                     in Varchar2
 ,p_clf_attribute_category_o       in varchar2
 ,p_clf_attribute1_o               in varchar2
 ,p_clf_attribute2_o               in varchar2
 ,p_clf_attribute3_o               in varchar2
 ,p_clf_attribute4_o               in varchar2
 ,p_clf_attribute5_o               in varchar2
 ,p_clf_attribute6_o               in varchar2
 ,p_clf_attribute7_o               in varchar2
 ,p_clf_attribute8_o               in varchar2
 ,p_clf_attribute9_o               in varchar2
 ,p_clf_attribute10_o              in varchar2
 ,p_clf_attribute11_o              in varchar2
 ,p_clf_attribute12_o              in varchar2
 ,p_clf_attribute13_o              in varchar2
 ,p_clf_attribute14_o              in varchar2
 ,p_clf_attribute15_o              in varchar2
 ,p_clf_attribute16_o              in varchar2
 ,p_clf_attribute17_o              in varchar2
 ,p_clf_attribute18_o              in varchar2
 ,p_clf_attribute19_o              in varchar2
 ,p_clf_attribute20_o              in varchar2
 ,p_clf_attribute21_o              in varchar2
 ,p_clf_attribute22_o              in varchar2
 ,p_clf_attribute23_o              in varchar2
 ,p_clf_attribute24_o              in varchar2
 ,p_clf_attribute25_o              in varchar2
 ,p_clf_attribute26_o              in varchar2
 ,p_clf_attribute27_o              in varchar2
 ,p_clf_attribute28_o              in varchar2
 ,p_clf_attribute29_o              in varchar2
 ,p_clf_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_sttd_sal_prdcty_cd_o           in varchar2
  );
--
end ben_clf_rku;

 

/
