--------------------------------------------------------
--  DDL for Package BEN_GOS_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_GOS_RKD" AUTHID CURRENT_USER as
/* $Header: begosrhi.pkh 120.0 2005/05/28 03:08:35 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_gd_or_svc_typ_id               in number
 ,p_business_group_id_o            in number
 ,p_name_o                         in varchar2
 ,p_typ_cd_o                       in varchar2
 ,p_description_o                  in varchar2
 ,p_gos_attribute_category_o       in varchar2
 ,p_gos_attribute1_o               in varchar2
 ,p_gos_attribute2_o               in varchar2
 ,p_gos_attribute3_o               in varchar2
 ,p_gos_attribute4_o               in varchar2
 ,p_gos_attribute5_o               in varchar2
 ,p_gos_attribute6_o               in varchar2
 ,p_gos_attribute7_o               in varchar2
 ,p_gos_attribute8_o               in varchar2
 ,p_gos_attribute9_o               in varchar2
 ,p_gos_attribute10_o              in varchar2
 ,p_gos_attribute11_o              in varchar2
 ,p_gos_attribute12_o              in varchar2
 ,p_gos_attribute13_o              in varchar2
 ,p_gos_attribute14_o              in varchar2
 ,p_gos_attribute15_o              in varchar2
 ,p_gos_attribute16_o              in varchar2
 ,p_gos_attribute17_o              in varchar2
 ,p_gos_attribute18_o              in varchar2
 ,p_gos_attribute19_o              in varchar2
 ,p_gos_attribute20_o              in varchar2
 ,p_gos_attribute21_o              in varchar2
 ,p_gos_attribute22_o              in varchar2
 ,p_gos_attribute23_o              in varchar2
 ,p_gos_attribute24_o              in varchar2
 ,p_gos_attribute25_o              in varchar2
 ,p_gos_attribute26_o              in varchar2
 ,p_gos_attribute27_o              in varchar2
 ,p_gos_attribute28_o              in varchar2
 ,p_gos_attribute29_o              in varchar2
 ,p_gos_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_gos_rkd;

 

/
