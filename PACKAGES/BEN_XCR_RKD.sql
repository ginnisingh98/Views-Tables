--------------------------------------------------------
--  DDL for Package BEN_XCR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_XCR_RKD" AUTHID CURRENT_USER as
/* $Header: bexcrrhi.pkh 120.0 2005/05/28 12:25:51 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_ext_crit_prfl_id               in number
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
end ben_xcr_rkd;

 

/
