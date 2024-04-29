--------------------------------------------------------
--  DDL for Package BEN_XCR_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_XCR_RKU" AUTHID CURRENT_USER as
/* $Header: bexcrrhi.pkh 120.0 2005/05/28 12:25:51 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_ext_crit_prfl_id               in number
 ,p_name                           in varchar2
 ,p_business_group_id              in number
 ,p_legislation_code               in varchar2
 ,p_xcr_attribute_category         in varchar2
 ,p_xcr_attribute1                 in varchar2
 ,p_xcr_attribute2                 in varchar2
 ,p_xcr_attribute3                 in varchar2
 ,p_xcr_attribute4                 in varchar2
 ,p_xcr_attribute5                 in varchar2
 ,p_xcr_attribute6                 in varchar2
 ,p_xcr_attribute7                 in varchar2
 ,p_xcr_attribute8                 in varchar2
 ,p_xcr_attribute9                 in varchar2
 ,p_xcr_attribute10                in varchar2
 ,p_xcr_attribute11                in varchar2
 ,p_xcr_attribute12                in varchar2
 ,p_xcr_attribute13                in varchar2
 ,p_xcr_attribute14                in varchar2
 ,p_xcr_attribute15                in varchar2
 ,p_xcr_attribute16                in varchar2
 ,p_xcr_attribute17                in varchar2
 ,p_xcr_attribute18                in varchar2
 ,p_xcr_attribute19                in varchar2
 ,p_xcr_attribute20                in varchar2
 ,p_xcr_attribute21                in varchar2
 ,p_xcr_attribute22                in varchar2
 ,p_xcr_attribute23                in varchar2
 ,p_xcr_attribute24                in varchar2
 ,p_xcr_attribute25                in varchar2
 ,p_xcr_attribute26                in varchar2
 ,p_xcr_attribute27                in varchar2
 ,p_xcr_attribute28                in varchar2
 ,p_xcr_attribute29                in varchar2
 ,p_xcr_attribute30                in varchar2
 ,p_ext_global_flag                in varchar2
 ,p_object_version_number          in number
 ,p_name_o                         in varchar2
 ,p_business_group_id_o            in number
 ,p_legislation_code_o             in varchar2
 ,p_xcr_attribute_category_o       in varchar2
 ,p_xcr_attribute1_o               in varchar2
 ,p_xcr_attribute2_o               in varchar2
 ,p_xcr_attribute3_o               in varchar2
 ,p_xcr_attribute4_o               in varchar2
 ,p_xcr_attribute5_o               in varchar2
 ,p_xcr_attribute6_o               in varchar2
 ,p_xcr_attribute7_o               in varchar2
 ,p_xcr_attribute8_o               in varchar2
 ,p_xcr_attribute9_o               in varchar2
 ,p_xcr_attribute10_o              in varchar2
 ,p_xcr_attribute11_o              in varchar2
 ,p_xcr_attribute12_o              in varchar2
 ,p_xcr_attribute13_o              in varchar2
 ,p_xcr_attribute14_o              in varchar2
 ,p_xcr_attribute15_o              in varchar2
 ,p_xcr_attribute16_o              in varchar2
 ,p_xcr_attribute17_o              in varchar2
 ,p_xcr_attribute18_o              in varchar2
 ,p_xcr_attribute19_o              in varchar2
 ,p_xcr_attribute20_o              in varchar2
 ,p_xcr_attribute21_o              in varchar2
 ,p_xcr_attribute22_o              in varchar2
 ,p_xcr_attribute23_o              in varchar2
 ,p_xcr_attribute24_o              in varchar2
 ,p_xcr_attribute25_o              in varchar2
 ,p_xcr_attribute26_o              in varchar2
 ,p_xcr_attribute27_o              in varchar2
 ,p_xcr_attribute28_o              in varchar2
 ,p_xcr_attribute29_o              in varchar2
 ,p_xcr_attribute30_o              in varchar2
 ,p_ext_global_flag_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_xcr_rku;

 

/
