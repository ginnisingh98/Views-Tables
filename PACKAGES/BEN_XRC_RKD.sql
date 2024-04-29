--------------------------------------------------------
--  DDL for Package BEN_XRC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_XRC_RKD" AUTHID CURRENT_USER as
/* $Header: bexrcrhi.pkh 120.0 2005/05/28 12:38:10 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_ext_rcd_id                     in number
 ,p_name_o                         in varchar2
 ,p_xml_tag_name_o                 in varchar2
 ,p_rcd_type_cd_o                  in varchar2
 ,p_low_lvl_cd_o                   in varchar2
 ,p_business_group_id_o            in number
 ,p_legislation_code_o             in varchar2
 ,p_xrc_attribute_category_o       in varchar2
 ,p_xrc_attribute1_o               in varchar2
 ,p_xrc_attribute2_o               in varchar2
 ,p_xrc_attribute3_o               in varchar2
 ,p_xrc_attribute4_o               in varchar2
 ,p_xrc_attribute5_o               in varchar2
 ,p_xrc_attribute6_o               in varchar2
 ,p_xrc_attribute7_o               in varchar2
 ,p_xrc_attribute8_o               in varchar2
 ,p_xrc_attribute9_o               in varchar2
 ,p_xrc_attribute10_o              in varchar2
 ,p_xrc_attribute11_o              in varchar2
 ,p_xrc_attribute12_o              in varchar2
 ,p_xrc_attribute13_o              in varchar2
 ,p_xrc_attribute14_o              in varchar2
 ,p_xrc_attribute15_o              in varchar2
 ,p_xrc_attribute16_o              in varchar2
 ,p_xrc_attribute17_o              in varchar2
 ,p_xrc_attribute18_o              in varchar2
 ,p_xrc_attribute19_o              in varchar2
 ,p_xrc_attribute20_o              in varchar2
 ,p_xrc_attribute21_o              in varchar2
 ,p_xrc_attribute22_o              in varchar2
 ,p_xrc_attribute23_o              in varchar2
 ,p_xrc_attribute24_o              in varchar2
 ,p_xrc_attribute25_o              in varchar2
 ,p_xrc_attribute26_o              in varchar2
 ,p_xrc_attribute27_o              in varchar2
 ,p_xrc_attribute28_o              in varchar2
 ,p_xrc_attribute29_o              in varchar2
 ,p_xrc_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_xrc_rkd;

 

/
