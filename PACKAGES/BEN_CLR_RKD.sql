--------------------------------------------------------
--  DDL for Package BEN_CLR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CLR_RKD" AUTHID CURRENT_USER as
/* $Header: beclrrhi.pkh 120.0 2005/05/28 01:05:52 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_comp_lvl_rt_id                 in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_comp_lvl_fctr_id_o             in number
 ,p_vrbl_rt_prfl_id_o              in number
 ,p_ordr_num_o                     in number
 ,p_excld_flag_o                   in varchar2
 ,p_clr_attribute_category_o       in varchar2
 ,p_clr_attribute1_o               in varchar2
 ,p_clr_attribute2_o               in varchar2
 ,p_clr_attribute3_o               in varchar2
 ,p_clr_attribute4_o               in varchar2
 ,p_clr_attribute5_o               in varchar2
 ,p_clr_attribute6_o               in varchar2
 ,p_clr_attribute7_o               in varchar2
 ,p_clr_attribute8_o               in varchar2
 ,p_clr_attribute9_o               in varchar2
 ,p_clr_attribute10_o              in varchar2
 ,p_clr_attribute11_o              in varchar2
 ,p_clr_attribute12_o              in varchar2
 ,p_clr_attribute13_o              in varchar2
 ,p_clr_attribute14_o              in varchar2
 ,p_clr_attribute15_o              in varchar2
 ,p_clr_attribute16_o              in varchar2
 ,p_clr_attribute17_o              in varchar2
 ,p_clr_attribute18_o              in varchar2
 ,p_clr_attribute19_o              in varchar2
 ,p_clr_attribute20_o              in varchar2
 ,p_clr_attribute21_o              in varchar2
 ,p_clr_attribute22_o              in varchar2
 ,p_clr_attribute23_o              in varchar2
 ,p_clr_attribute24_o              in varchar2
 ,p_clr_attribute25_o              in varchar2
 ,p_clr_attribute26_o              in varchar2
 ,p_clr_attribute27_o              in varchar2
 ,p_clr_attribute28_o              in varchar2
 ,p_clr_attribute29_o              in varchar2
 ,p_clr_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_clr_rkd;

 

/
