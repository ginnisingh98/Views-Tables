--------------------------------------------------------
--  DDL for Package BEN_EAT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EAT_RKD" AUTHID CURRENT_USER as
/* $Header: beeatrhi.pkh 120.1 2007/04/20 03:03:42 rtagarra noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_actn_typ_id                    in number
 ,p_business_group_id_o            in number
 ,p_type_cd_o                      in varchar2
 ,p_name_o                         in varchar2
 ,p_description_o                  in varchar2
 ,p_eat_attribute_category_o       in varchar2
 ,p_eat_attribute1_o               in varchar2
 ,p_eat_attribute2_o               in varchar2
 ,p_eat_attribute3_o               in varchar2
 ,p_eat_attribute4_o               in varchar2
 ,p_eat_attribute5_o               in varchar2
 ,p_eat_attribute6_o               in varchar2
 ,p_eat_attribute7_o               in varchar2
 ,p_eat_attribute8_o               in varchar2
 ,p_eat_attribute9_o               in varchar2
 ,p_eat_attribute10_o              in varchar2
 ,p_eat_attribute11_o              in varchar2
 ,p_eat_attribute12_o              in varchar2
 ,p_eat_attribute13_o              in varchar2
 ,p_eat_attribute14_o              in varchar2
 ,p_eat_attribute15_o              in varchar2
 ,p_eat_attribute16_o              in varchar2
 ,p_eat_attribute17_o              in varchar2
 ,p_eat_attribute18_o              in varchar2
 ,p_eat_attribute19_o              in varchar2
 ,p_eat_attribute20_o              in varchar2
 ,p_eat_attribute21_o              in varchar2
 ,p_eat_attribute22_o              in varchar2
 ,p_eat_attribute23_o              in varchar2
 ,p_eat_attribute24_o              in varchar2
 ,p_eat_attribute25_o              in varchar2
 ,p_eat_attribute26_o              in varchar2
 ,p_eat_attribute27_o              in varchar2
 ,p_eat_attribute28_o              in varchar2
 ,p_eat_attribute29_o              in varchar2
 ,p_eat_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_eat_rkd;

/
