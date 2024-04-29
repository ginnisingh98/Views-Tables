--------------------------------------------------------
--  DDL for Package BEN_WYP_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_WYP_RKU" AUTHID CURRENT_USER as
/* $Header: bewyprhi.pkh 120.0 2005/05/28 12:21:53 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_wthn_yr_perd_id                in number
 ,p_strt_day                       in number
 ,p_end_day                        in number
 ,p_strt_mo                        in number
 ,p_end_mo                         in number
 ,p_tm_uom                         in varchar2
 ,p_yr_perd_id                     in number
 ,p_business_group_id              in number
 ,p_wyp_attribute_category         in varchar2
 ,p_wyp_attribute1                 in varchar2
 ,p_wyp_attribute2                 in varchar2
 ,p_wyp_attribute3                 in varchar2
 ,p_wyp_attribute4                 in varchar2
 ,p_wyp_attribute5                 in varchar2
 ,p_wyp_attribute6                 in varchar2
 ,p_wyp_attribute7                 in varchar2
 ,p_wyp_attribute8                 in varchar2
 ,p_wyp_attribute9                 in varchar2
 ,p_wyp_attribute10                in varchar2
 ,p_wyp_attribute11                in varchar2
 ,p_wyp_attribute12                in varchar2
 ,p_wyp_attribute13                in varchar2
 ,p_wyp_attribute14                in varchar2
 ,p_wyp_attribute15                in varchar2
 ,p_wyp_attribute16                in varchar2
 ,p_wyp_attribute17                in varchar2
 ,p_wyp_attribute18                in varchar2
 ,p_wyp_attribute19                in varchar2
 ,p_wyp_attribute20                in varchar2
 ,p_wyp_attribute21                in varchar2
 ,p_wyp_attribute22                in varchar2
 ,p_wyp_attribute23                in varchar2
 ,p_wyp_attribute24                in varchar2
 ,p_wyp_attribute25                in varchar2
 ,p_wyp_attribute26                in varchar2
 ,p_wyp_attribute27                in varchar2
 ,p_wyp_attribute28                in varchar2
 ,p_wyp_attribute29                in varchar2
 ,p_wyp_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_strt_day_o                     in number
 ,p_end_day_o                      in number
 ,p_strt_mo_o                      in number
 ,p_end_mo_o                       in number
 ,p_tm_uom_o                       in varchar2
 ,p_yr_perd_id_o                   in number
 ,p_business_group_id_o            in number
 ,p_wyp_attribute_category_o       in varchar2
 ,p_wyp_attribute1_o               in varchar2
 ,p_wyp_attribute2_o               in varchar2
 ,p_wyp_attribute3_o               in varchar2
 ,p_wyp_attribute4_o               in varchar2
 ,p_wyp_attribute5_o               in varchar2
 ,p_wyp_attribute6_o               in varchar2
 ,p_wyp_attribute7_o               in varchar2
 ,p_wyp_attribute8_o               in varchar2
 ,p_wyp_attribute9_o               in varchar2
 ,p_wyp_attribute10_o              in varchar2
 ,p_wyp_attribute11_o              in varchar2
 ,p_wyp_attribute12_o              in varchar2
 ,p_wyp_attribute13_o              in varchar2
 ,p_wyp_attribute14_o              in varchar2
 ,p_wyp_attribute15_o              in varchar2
 ,p_wyp_attribute16_o              in varchar2
 ,p_wyp_attribute17_o              in varchar2
 ,p_wyp_attribute18_o              in varchar2
 ,p_wyp_attribute19_o              in varchar2
 ,p_wyp_attribute20_o              in varchar2
 ,p_wyp_attribute21_o              in varchar2
 ,p_wyp_attribute22_o              in varchar2
 ,p_wyp_attribute23_o              in varchar2
 ,p_wyp_attribute24_o              in varchar2
 ,p_wyp_attribute25_o              in varchar2
 ,p_wyp_attribute26_o              in varchar2
 ,p_wyp_attribute27_o              in varchar2
 ,p_wyp_attribute28_o              in varchar2
 ,p_wyp_attribute29_o              in varchar2
 ,p_wyp_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_wyp_rku;

 

/
