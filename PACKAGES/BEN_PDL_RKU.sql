--------------------------------------------------------
--  DDL for Package BEN_PDL_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PDL_RKU" AUTHID CURRENT_USER as
/* $Header: bepdlrhi.pkh 120.0 2005/05/28 10:27:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_ptd_lmt_id                     in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_name                           in varchar2
 ,p_mx_comp_to_cnsdr               in number
 ,p_mx_val                         in number
 ,p_mx_pct_val                     in number
 ,p_ptd_lmt_calc_rl                in number
 ,p_lmt_det_cd                     in varchar2
 ,p_comp_lvl_fctr_id               in number
 ,p_balance_type_id                in number
 ,p_business_group_id              in number
 ,p_pdl_attribute_category         in varchar2
 ,p_pdl_attribute1                 in varchar2
 ,p_pdl_attribute2                 in varchar2
 ,p_pdl_attribute3                 in varchar2
 ,p_pdl_attribute4                 in varchar2
 ,p_pdl_attribute5                 in varchar2
 ,p_pdl_attribute6                 in varchar2
 ,p_pdl_attribute7                 in varchar2
 ,p_pdl_attribute8                 in varchar2
 ,p_pdl_attribute9                 in varchar2
 ,p_pdl_attribute10                in varchar2
 ,p_pdl_attribute11                in varchar2
 ,p_pdl_attribute12                in varchar2
 ,p_pdl_attribute13                in varchar2
 ,p_pdl_attribute14                in varchar2
 ,p_pdl_attribute15                in varchar2
 ,p_pdl_attribute16                in varchar2
 ,p_pdl_attribute17                in varchar2
 ,p_pdl_attribute18                in varchar2
 ,p_pdl_attribute19                in varchar2
 ,p_pdl_attribute20                in varchar2
 ,p_pdl_attribute21                in varchar2
 ,p_pdl_attribute22                in varchar2
 ,p_pdl_attribute23                in varchar2
 ,p_pdl_attribute24                in varchar2
 ,p_pdl_attribute25                in varchar2
 ,p_pdl_attribute26                in varchar2
 ,p_pdl_attribute27                in varchar2
 ,p_pdl_attribute28                in varchar2
 ,p_pdl_attribute29                in varchar2
 ,p_pdl_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_name_o                         in varchar2
 ,p_mx_comp_to_cnsdr_o             in number
 ,p_mx_val_o                       in number
 ,p_mx_pct_val_o                   in number
 ,p_ptd_lmt_calc_rl_o              in number
 ,p_lmt_det_cd_o                   in varchar2
 ,p_comp_lvl_fctr_id_o             in number
 ,p_balance_type_id_o              in number
 ,p_business_group_id_o            in number
 ,p_pdl_attribute_category_o       in varchar2
 ,p_pdl_attribute1_o               in varchar2
 ,p_pdl_attribute2_o               in varchar2
 ,p_pdl_attribute3_o               in varchar2
 ,p_pdl_attribute4_o               in varchar2
 ,p_pdl_attribute5_o               in varchar2
 ,p_pdl_attribute6_o               in varchar2
 ,p_pdl_attribute7_o               in varchar2
 ,p_pdl_attribute8_o               in varchar2
 ,p_pdl_attribute9_o               in varchar2
 ,p_pdl_attribute10_o              in varchar2
 ,p_pdl_attribute11_o              in varchar2
 ,p_pdl_attribute12_o              in varchar2
 ,p_pdl_attribute13_o              in varchar2
 ,p_pdl_attribute14_o              in varchar2
 ,p_pdl_attribute15_o              in varchar2
 ,p_pdl_attribute16_o              in varchar2
 ,p_pdl_attribute17_o              in varchar2
 ,p_pdl_attribute18_o              in varchar2
 ,p_pdl_attribute19_o              in varchar2
 ,p_pdl_attribute20_o              in varchar2
 ,p_pdl_attribute21_o              in varchar2
 ,p_pdl_attribute22_o              in varchar2
 ,p_pdl_attribute23_o              in varchar2
 ,p_pdl_attribute24_o              in varchar2
 ,p_pdl_attribute25_o              in varchar2
 ,p_pdl_attribute26_o              in varchar2
 ,p_pdl_attribute27_o              in varchar2
 ,p_pdl_attribute28_o              in varchar2
 ,p_pdl_attribute29_o              in varchar2
 ,p_pdl_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_pdl_rku;

 

/
