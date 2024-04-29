--------------------------------------------------------
--  DDL for Package BEN_LRN_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LRN_RKD" AUTHID CURRENT_USER as
/* $Header: belrnrhi.pkh 120.0 2005/05/28 03:36:14 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_lvg_rsn_rt_id           in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_excld_flag_o                   in varchar2
 ,p_ordr_num_o                     in number
 ,p_lvg_rsn_cd_o                   in varchar2
 ,p_vrbl_rt_prfl_id_o                in number
 ,p_business_group_id_o            in number
 ,p_lrn_attribute_category_o       in varchar2
 ,p_lrn_attribute1_o               in varchar2
 ,p_lrn_attribute2_o               in varchar2
 ,p_lrn_attribute3_o               in varchar2
 ,p_lrn_attribute4_o               in varchar2
 ,p_lrn_attribute5_o               in varchar2
 ,p_lrn_attribute6_o               in varchar2
 ,p_lrn_attribute7_o               in varchar2
 ,p_lrn_attribute8_o               in varchar2
 ,p_lrn_attribute9_o               in varchar2
 ,p_lrn_attribute10_o              in varchar2
 ,p_lrn_attribute11_o              in varchar2
 ,p_lrn_attribute12_o              in varchar2
 ,p_lrn_attribute13_o              in varchar2
 ,p_lrn_attribute14_o              in varchar2
 ,p_lrn_attribute15_o              in varchar2
 ,p_lrn_attribute16_o              in varchar2
 ,p_lrn_attribute17_o              in varchar2
 ,p_lrn_attribute18_o              in varchar2
 ,p_lrn_attribute19_o              in varchar2
 ,p_lrn_attribute20_o              in varchar2
 ,p_lrn_attribute21_o              in varchar2
 ,p_lrn_attribute22_o              in varchar2
 ,p_lrn_attribute23_o              in varchar2
 ,p_lrn_attribute24_o              in varchar2
 ,p_lrn_attribute25_o              in varchar2
 ,p_lrn_attribute26_o              in varchar2
 ,p_lrn_attribute27_o              in varchar2
 ,p_lrn_attribute28_o              in varchar2
 ,p_lrn_attribute29_o              in varchar2
 ,p_lrn_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_lrn_rkd;

 

/
