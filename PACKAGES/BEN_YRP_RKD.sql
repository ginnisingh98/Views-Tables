--------------------------------------------------------
--  DDL for Package BEN_YRP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_YRP_RKD" AUTHID CURRENT_USER as
/* $Header: beyrprhi.pkh 120.0 2005/05/28 12:44:58 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_yr_perd_id                     in number
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
end ben_yrp_rkd;

 

/
