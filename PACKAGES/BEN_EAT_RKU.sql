--------------------------------------------------------
--  DDL for Package BEN_EAT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EAT_RKU" AUTHID CURRENT_USER as
/* $Header: beeatrhi.pkh 120.1 2007/04/20 03:03:42 rtagarra noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_actn_typ_id                    in number
 ,p_business_group_id              in number
 ,p_type_cd                        in varchar2
 ,p_name                           in varchar2
 ,p_description                    in varchar2
 ,p_eat_attribute_category         in varchar2
 ,p_eat_attribute1                 in varchar2
 ,p_eat_attribute2                 in varchar2
 ,p_eat_attribute3                 in varchar2
 ,p_eat_attribute4                 in varchar2
 ,p_eat_attribute5                 in varchar2
 ,p_eat_attribute6                 in varchar2
 ,p_eat_attribute7                 in varchar2
 ,p_eat_attribute8                 in varchar2
 ,p_eat_attribute9                 in varchar2
 ,p_eat_attribute10                in varchar2
 ,p_eat_attribute11                in varchar2
 ,p_eat_attribute12                in varchar2
 ,p_eat_attribute13                in varchar2
 ,p_eat_attribute14                in varchar2
 ,p_eat_attribute15                in varchar2
 ,p_eat_attribute16                in varchar2
 ,p_eat_attribute17                in varchar2
 ,p_eat_attribute18                in varchar2
 ,p_eat_attribute19                in varchar2
 ,p_eat_attribute20                in varchar2
 ,p_eat_attribute21                in varchar2
 ,p_eat_attribute22                in varchar2
 ,p_eat_attribute23                in varchar2
 ,p_eat_attribute24                in varchar2
 ,p_eat_attribute25                in varchar2
 ,p_eat_attribute26                in varchar2
 ,p_eat_attribute27                in varchar2
 ,p_eat_attribute28                in varchar2
 ,p_eat_attribute29                in varchar2
 ,p_eat_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
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
end ben_eat_rku;

/
