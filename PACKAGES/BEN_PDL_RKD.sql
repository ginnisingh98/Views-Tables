--------------------------------------------------------
--  DDL for Package BEN_PDL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PDL_RKD" AUTHID CURRENT_USER as
/* $Header: bepdlrhi.pkh 120.0 2005/05/28 10:27:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_ptd_lmt_id                     in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
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
end ben_pdl_rkd;

 

/
