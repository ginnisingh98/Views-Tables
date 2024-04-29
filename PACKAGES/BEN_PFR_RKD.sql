--------------------------------------------------------
--  DDL for Package BEN_PFR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PFR_RKD" AUTHID CURRENT_USER as
/* $Header: bepfrrhi.pkh 120.0 2005/05/28 10:43:47 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_pct_fl_tm_rt_id                in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_vrbl_rt_prfl_id_o              in number
 ,p_pct_fl_tm_fctr_id_o            in number
 ,p_excld_flag_o                   in varchar2
 ,p_ordr_num_o                     in number
 ,p_pfr_attribute_category_o       in varchar2
 ,p_pfr_attribute1_o               in varchar2
 ,p_pfr_attribute2_o               in varchar2
 ,p_pfr_attribute3_o               in varchar2
 ,p_pfr_attribute4_o               in varchar2
 ,p_pfr_attribute5_o               in varchar2
 ,p_pfr_attribute6_o               in varchar2
 ,p_pfr_attribute7_o               in varchar2
 ,p_pfr_attribute8_o               in varchar2
 ,p_pfr_attribute9_o               in varchar2
 ,p_pfr_attribute10_o              in varchar2
 ,p_pfr_attribute11_o              in varchar2
 ,p_pfr_attribute12_o              in varchar2
 ,p_pfr_attribute13_o              in varchar2
 ,p_pfr_attribute14_o              in varchar2
 ,p_pfr_attribute15_o              in varchar2
 ,p_pfr_attribute16_o              in varchar2
 ,p_pfr_attribute17_o              in varchar2
 ,p_pfr_attribute18_o              in varchar2
 ,p_pfr_attribute19_o              in varchar2
 ,p_pfr_attribute20_o              in varchar2
 ,p_pfr_attribute21_o              in varchar2
 ,p_pfr_attribute22_o              in varchar2
 ,p_pfr_attribute23_o              in varchar2
 ,p_pfr_attribute24_o              in varchar2
 ,p_pfr_attribute25_o              in varchar2
 ,p_pfr_attribute26_o              in varchar2
 ,p_pfr_attribute27_o              in varchar2
 ,p_pfr_attribute28_o              in varchar2
 ,p_pfr_attribute29_o              in varchar2
 ,p_pfr_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_pfr_rkd;

 

/
