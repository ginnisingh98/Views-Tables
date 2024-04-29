--------------------------------------------------------
--  DDL for Package BEN_XEL_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_XEL_RKU" AUTHID CURRENT_USER as
/* $Header: bexelrhi.pkh 120.1 2005/06/08 13:15:50 tjesumic noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_ext_data_elmt_id               in number
 ,p_name                           in varchar2
 ,p_xml_tag_name                   in varchar2
 ,p_data_elmt_typ_cd               in varchar2
 ,p_data_elmt_rl                   in number
 ,p_frmt_mask_cd                   in varchar2
 ,p_string_val                     in varchar2
 ,p_dflt_val                       in varchar2
 ,p_max_length_num                 in number
 ,p_just_cd                       in varchar2
  ,p_ttl_fnctn_cd                          in varchar2,
  p_ttl_cond_oper_cd                          in varchar2,
  p_ttl_cond_val                          in varchar2,
  p_ttl_sum_ext_data_elmt_id                        in number,
  p_ttl_cond_ext_data_elmt_id                        in number,
 p_ext_fld_id                     in number
 ,p_business_group_id              in number
 ,p_legislation_code               in varchar2
 ,p_xel_attribute_category         in varchar2
 ,p_xel_attribute1                 in varchar2
 ,p_xel_attribute2                 in varchar2
 ,p_xel_attribute3                 in varchar2
 ,p_xel_attribute4                 in varchar2
 ,p_xel_attribute5                 in varchar2
 ,p_xel_attribute6                 in varchar2
 ,p_xel_attribute7                 in varchar2
 ,p_xel_attribute8                 in varchar2
 ,p_xel_attribute9                 in varchar2
 ,p_xel_attribute10                in varchar2
 ,p_xel_attribute11                in varchar2
 ,p_xel_attribute12                in varchar2
 ,p_xel_attribute13                in varchar2
 ,p_xel_attribute14                in varchar2
 ,p_xel_attribute15                in varchar2
 ,p_xel_attribute16                in varchar2
 ,p_xel_attribute17                in varchar2
 ,p_xel_attribute18                in varchar2
 ,p_xel_attribute19                in varchar2
 ,p_xel_attribute20                in varchar2
 ,p_xel_attribute21                in varchar2
 ,p_xel_attribute22                in varchar2
 ,p_xel_attribute23                in varchar2
 ,p_xel_attribute24                in varchar2
 ,p_xel_attribute25                in varchar2
 ,p_xel_attribute26                in varchar2
 ,p_xel_attribute27                in varchar2
 ,p_xel_attribute28                in varchar2
 ,p_xel_attribute29                in varchar2
 ,p_xel_attribute30                in varchar2
 ,p_defined_balance_id             in number
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_name_o                         in varchar2
 ,p_xml_tag_name_o                 in varchar2
 ,p_data_elmt_typ_cd_o             in varchar2
 ,p_data_elmt_rl_o                 in number
 ,p_frmt_mask_cd_o                 in varchar2
 ,p_string_val_o                   in varchar2
 ,p_dflt_val_o                     in varchar2
 ,p_max_length_num_o               in number
 ,p_just_cd_o                     in varchar2
  ,p_ttl_fnctn_cd_o                          in varchar2,
  p_ttl_cond_oper_cd_o                          in varchar2,
  p_ttl_cond_val_o                          in varchar2,
  p_ttl_sum_ext_data_elmt_id_o                        in number,
  p_ttl_cond_ext_data_elmt_id_o                        in number,
 p_ext_fld_id_o                   in number
 ,p_business_group_id_o            in number
 ,p_legislation_code_o             in varchar2
 ,p_xel_attribute_category_o       in varchar2
 ,p_xel_attribute1_o               in varchar2
 ,p_xel_attribute2_o               in varchar2
 ,p_xel_attribute3_o               in varchar2
 ,p_xel_attribute4_o               in varchar2
 ,p_xel_attribute5_o               in varchar2
 ,p_xel_attribute6_o               in varchar2
 ,p_xel_attribute7_o               in varchar2
 ,p_xel_attribute8_o               in varchar2
 ,p_xel_attribute9_o               in varchar2
 ,p_xel_attribute10_o              in varchar2
 ,p_xel_attribute11_o              in varchar2
 ,p_xel_attribute12_o              in varchar2
 ,p_xel_attribute13_o              in varchar2
 ,p_xel_attribute14_o              in varchar2
 ,p_xel_attribute15_o              in varchar2
 ,p_xel_attribute16_o              in varchar2
 ,p_xel_attribute17_o              in varchar2
 ,p_xel_attribute18_o              in varchar2
 ,p_xel_attribute19_o              in varchar2
 ,p_xel_attribute20_o              in varchar2
 ,p_xel_attribute21_o              in varchar2
 ,p_xel_attribute22_o              in varchar2
 ,p_xel_attribute23_o              in varchar2
 ,p_xel_attribute24_o              in varchar2
 ,p_xel_attribute25_o              in varchar2
 ,p_xel_attribute26_o              in varchar2
 ,p_xel_attribute27_o              in varchar2
 ,p_xel_attribute28_o              in varchar2
 ,p_xel_attribute29_o              in varchar2
 ,p_xel_attribute30_o              in varchar2
 ,p_defined_balance_id_o           in number
 ,p_object_version_number_o        in number
  );
--
end ben_xel_rku;

 

/
