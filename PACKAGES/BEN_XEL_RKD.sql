--------------------------------------------------------
--  DDL for Package BEN_XEL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_XEL_RKD" AUTHID CURRENT_USER as
/* $Header: bexelrhi.pkh 120.1 2005/06/08 13:15:50 tjesumic noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_ext_data_elmt_id               in number
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
end ben_xel_rkd;

 

/
