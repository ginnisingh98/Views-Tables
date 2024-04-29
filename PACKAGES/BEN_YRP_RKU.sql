--------------------------------------------------------
--  DDL for Package BEN_YRP_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_YRP_RKU" AUTHID CURRENT_USER as
/* $Header: beyrprhi.pkh 120.0 2005/05/28 12:44:58 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_yr_perd_id                     in number
 ,p_perds_in_yr_num                in number
 ,p_perd_tm_uom_cd                 in varchar2
 ,p_perd_typ_cd                    in varchar2
 ,p_end_date                       in date
 ,p_start_date                     in date
 ,p_lmtn_yr_strt_dt                in date
 ,p_lmtn_yr_end_dt                 in date
 ,p_business_group_id              in number
 ,p_yrp_attribute_category         in varchar2
 ,p_yrp_attribute1                 in varchar2
 ,p_yrp_attribute2                 in varchar2
 ,p_yrp_attribute3                 in varchar2
 ,p_yrp_attribute4                 in varchar2
 ,p_yrp_attribute5                 in varchar2
 ,p_yrp_attribute6                 in varchar2
 ,p_yrp_attribute7                 in varchar2
 ,p_yrp_attribute8                 in varchar2
 ,p_yrp_attribute9                 in varchar2
 ,p_yrp_attribute10                in varchar2
 ,p_yrp_attribute11                in varchar2
 ,p_yrp_attribute12                in varchar2
 ,p_yrp_attribute13                in varchar2
 ,p_yrp_attribute14                in varchar2
 ,p_yrp_attribute15                in varchar2
 ,p_yrp_attribute16                in varchar2
 ,p_yrp_attribute17                in varchar2
 ,p_yrp_attribute18                in varchar2
 ,p_yrp_attribute19                in varchar2
 ,p_yrp_attribute20                in varchar2
 ,p_yrp_attribute21                in varchar2
 ,p_yrp_attribute22                in varchar2
 ,p_yrp_attribute23                in varchar2
 ,p_yrp_attribute24                in varchar2
 ,p_yrp_attribute25                in varchar2
 ,p_yrp_attribute26                in varchar2
 ,p_yrp_attribute27                in varchar2
 ,p_yrp_attribute28                in varchar2
 ,p_yrp_attribute29                in varchar2
 ,p_yrp_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_perds_in_yr_num_o              in number
 ,p_perd_tm_uom_cd_o               in varchar2
 ,p_perd_typ_cd_o                  in varchar2
 ,p_end_date_o                     in date
 ,p_start_date_o                   in date
 ,p_lmtn_yr_strt_dt_o              in date
 ,p_lmtn_yr_end_dt_o               in date
 ,p_business_group_id_o            in number
 ,p_yrp_attribute_category_o       in varchar2
 ,p_yrp_attribute1_o               in varchar2
 ,p_yrp_attribute2_o               in varchar2
 ,p_yrp_attribute3_o               in varchar2
 ,p_yrp_attribute4_o               in varchar2
 ,p_yrp_attribute5_o               in varchar2
 ,p_yrp_attribute6_o               in varchar2
 ,p_yrp_attribute7_o               in varchar2
 ,p_yrp_attribute8_o               in varchar2
 ,p_yrp_attribute9_o               in varchar2
 ,p_yrp_attribute10_o              in varchar2
 ,p_yrp_attribute11_o              in varchar2
 ,p_yrp_attribute12_o              in varchar2
 ,p_yrp_attribute13_o              in varchar2
 ,p_yrp_attribute14_o              in varchar2
 ,p_yrp_attribute15_o              in varchar2
 ,p_yrp_attribute16_o              in varchar2
 ,p_yrp_attribute17_o              in varchar2
 ,p_yrp_attribute18_o              in varchar2
 ,p_yrp_attribute19_o              in varchar2
 ,p_yrp_attribute20_o              in varchar2
 ,p_yrp_attribute21_o              in varchar2
 ,p_yrp_attribute22_o              in varchar2
 ,p_yrp_attribute23_o              in varchar2
 ,p_yrp_attribute24_o              in varchar2
 ,p_yrp_attribute25_o              in varchar2
 ,p_yrp_attribute26_o              in varchar2
 ,p_yrp_attribute27_o              in varchar2
 ,p_yrp_attribute28_o              in varchar2
 ,p_yrp_attribute29_o              in varchar2
 ,p_yrp_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_yrp_rku;

 

/
