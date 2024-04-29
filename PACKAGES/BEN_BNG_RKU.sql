--------------------------------------------------------
--  DDL for Package BEN_BNG_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BNG_RKU" AUTHID CURRENT_USER as
/* $Header: bebngrhi.pkh 120.0 2005/05/28 00:45:30 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_benfts_grp_id                  in number
 ,p_business_group_id              in number
 ,p_name                           in varchar2
 ,p_bng_desc                       in varchar2
 ,p_bng_attribute_category         in varchar2
 ,p_bng_attribute1                 in varchar2
 ,p_bng_attribute2                 in varchar2
 ,p_bng_attribute3                 in varchar2
 ,p_bng_attribute4                 in varchar2
 ,p_bng_attribute5                 in varchar2
 ,p_bng_attribute6                 in varchar2
 ,p_bng_attribute7                 in varchar2
 ,p_bng_attribute8                 in varchar2
 ,p_bng_attribute9                 in varchar2
 ,p_bng_attribute10                in varchar2
 ,p_bng_attribute11                in varchar2
 ,p_bng_attribute12                in varchar2
 ,p_bng_attribute13                in varchar2
 ,p_bng_attribute14                in varchar2
 ,p_bng_attribute15                in varchar2
 ,p_bng_attribute16                in varchar2
 ,p_bng_attribute17                in varchar2
 ,p_bng_attribute18                in varchar2
 ,p_bng_attribute19                in varchar2
 ,p_bng_attribute20                in varchar2
 ,p_bng_attribute21                in varchar2
 ,p_bng_attribute22                in varchar2
 ,p_bng_attribute23                in varchar2
 ,p_bng_attribute24                in varchar2
 ,p_bng_attribute25                in varchar2
 ,p_bng_attribute26                in varchar2
 ,p_bng_attribute27                in varchar2
 ,p_bng_attribute28                in varchar2
 ,p_bng_attribute29                in varchar2
 ,p_bng_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_business_group_id_o            in number
 ,p_name_o                         in varchar2
 ,p_bng_desc_o                     in varchar2
 ,p_bng_attribute_category_o       in varchar2
 ,p_bng_attribute1_o               in varchar2
 ,p_bng_attribute2_o               in varchar2
 ,p_bng_attribute3_o               in varchar2
 ,p_bng_attribute4_o               in varchar2
 ,p_bng_attribute5_o               in varchar2
 ,p_bng_attribute6_o               in varchar2
 ,p_bng_attribute7_o               in varchar2
 ,p_bng_attribute8_o               in varchar2
 ,p_bng_attribute9_o               in varchar2
 ,p_bng_attribute10_o              in varchar2
 ,p_bng_attribute11_o              in varchar2
 ,p_bng_attribute12_o              in varchar2
 ,p_bng_attribute13_o              in varchar2
 ,p_bng_attribute14_o              in varchar2
 ,p_bng_attribute15_o              in varchar2
 ,p_bng_attribute16_o              in varchar2
 ,p_bng_attribute17_o              in varchar2
 ,p_bng_attribute18_o              in varchar2
 ,p_bng_attribute19_o              in varchar2
 ,p_bng_attribute20_o              in varchar2
 ,p_bng_attribute21_o              in varchar2
 ,p_bng_attribute22_o              in varchar2
 ,p_bng_attribute23_o              in varchar2
 ,p_bng_attribute24_o              in varchar2
 ,p_bng_attribute25_o              in varchar2
 ,p_bng_attribute26_o              in varchar2
 ,p_bng_attribute27_o              in varchar2
 ,p_bng_attribute28_o              in varchar2
 ,p_bng_attribute29_o              in varchar2
 ,p_bng_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_bng_rku;

 

/
