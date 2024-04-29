--------------------------------------------------------
--  DDL for Package BEN_XFI_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_XFI_RKU" AUTHID CURRENT_USER as
/* $Header: bexfirhi.pkh 120.0 2005/05/28 12:33:47 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_ext_file_id                    in number
 ,p_name                           in varchar2
 ,p_xml_tag_name                   in varchar2
 ,p_business_group_id              in number
 ,p_legislation_code               in varchar2
 ,p_xfi_attribute_category         in varchar2
 ,p_xfi_attribute1                 in varchar2
 ,p_xfi_attribute2                 in varchar2
 ,p_xfi_attribute3                 in varchar2
 ,p_xfi_attribute4                 in varchar2
 ,p_xfi_attribute5                 in varchar2
 ,p_xfi_attribute6                 in varchar2
 ,p_xfi_attribute7                 in varchar2
 ,p_xfi_attribute8                 in varchar2
 ,p_xfi_attribute9                 in varchar2
 ,p_xfi_attribute10                in varchar2
 ,p_xfi_attribute11                in varchar2
 ,p_xfi_attribute12                in varchar2
 ,p_xfi_attribute13                in varchar2
 ,p_xfi_attribute14                in varchar2
 ,p_xfi_attribute15                in varchar2
 ,p_xfi_attribute16                in varchar2
 ,p_xfi_attribute17                in varchar2
 ,p_xfi_attribute18                in varchar2
 ,p_xfi_attribute19                in varchar2
 ,p_xfi_attribute20                in varchar2
 ,p_xfi_attribute21                in varchar2
 ,p_xfi_attribute22                in varchar2
 ,p_xfi_attribute23                in varchar2
 ,p_xfi_attribute24                in varchar2
 ,p_xfi_attribute25                in varchar2
 ,p_xfi_attribute26                in varchar2
 ,p_xfi_attribute27                in varchar2
 ,p_xfi_attribute28                in varchar2
 ,p_xfi_attribute29                in varchar2
 ,p_xfi_attribute30                in varchar2
 ,P_ext_rcd_in_file_id             in number
 ,p_ext_data_elmt_in_rcd_id1       in number
 ,p_ext_data_elmt_in_rcd_id2       in number
 ,p_object_version_number          in number
 ,p_name_o                         in varchar2
 ,p_xml_tag_name_o                 in varchar2
 ,p_business_group_id_o            in number
 ,p_legislation_code_o             in varchar2
 ,p_xfi_attribute_category_o       in varchar2
 ,p_xfi_attribute1_o               in varchar2
 ,p_xfi_attribute2_o               in varchar2
 ,p_xfi_attribute3_o               in varchar2
 ,p_xfi_attribute4_o               in varchar2
 ,p_xfi_attribute5_o               in varchar2
 ,p_xfi_attribute6_o               in varchar2
 ,p_xfi_attribute7_o               in varchar2
 ,p_xfi_attribute8_o               in varchar2
 ,p_xfi_attribute9_o               in varchar2
 ,p_xfi_attribute10_o              in varchar2
 ,p_xfi_attribute11_o              in varchar2
 ,p_xfi_attribute12_o              in varchar2
 ,p_xfi_attribute13_o              in varchar2
 ,p_xfi_attribute14_o              in varchar2
 ,p_xfi_attribute15_o              in varchar2
 ,p_xfi_attribute16_o              in varchar2
 ,p_xfi_attribute17_o              in varchar2
 ,p_xfi_attribute18_o              in varchar2
 ,p_xfi_attribute19_o              in varchar2
 ,p_xfi_attribute20_o              in varchar2
 ,p_xfi_attribute21_o              in varchar2
 ,p_xfi_attribute22_o              in varchar2
 ,p_xfi_attribute23_o              in varchar2
 ,p_xfi_attribute24_o              in varchar2
 ,p_xfi_attribute25_o              in varchar2
 ,p_xfi_attribute26_o              in varchar2
 ,p_xfi_attribute27_o              in varchar2
 ,p_xfi_attribute28_o              in varchar2
 ,p_xfi_attribute29_o              in varchar2
 ,p_xfi_attribute30_o              in varchar2
 ,P_ext_rcd_in_file_id_o           in number
 ,p_ext_data_elmt_in_rcd_id1_o     in number
 ,p_ext_data_elmt_in_rcd_id2_o     in number
 ,p_object_version_number_o        in number
  );
--
end ben_xfi_rku;

 

/
