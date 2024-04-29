--------------------------------------------------------
--  DDL for Package BEN_GNR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_GNR_RKD" AUTHID CURRENT_USER as
/* $Header: begnrrhi.pkh 120.0 2005/05/28 03:07:39 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_gndr_rt_id                     in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_vrbl_rt_prfl_id_o              in number
 ,p_ordr_num_o                     in number
 ,p_gndr_cd_o                      in varchar2
 ,p_excld_flag_o                   in varchar2
 ,p_gnr_attribute_category_o       in varchar2
 ,p_gnr_attribute1_o               in varchar2
 ,p_gnr_attribute2_o               in varchar2
 ,p_gnr_attribute3_o               in varchar2
 ,p_gnr_attribute4_o               in varchar2
 ,p_gnr_attribute5_o               in varchar2
 ,p_gnr_attribute6_o               in varchar2
 ,p_gnr_attribute7_o               in varchar2
 ,p_gnr_attribute8_o               in varchar2
 ,p_gnr_attribute9_o               in varchar2
 ,p_gnr_attribute10_o              in varchar2
 ,p_gnr_attribute11_o              in varchar2
 ,p_gnr_attribute12_o              in varchar2
 ,p_gnr_attribute13_o              in varchar2
 ,p_gnr_attribute14_o              in varchar2
 ,p_gnr_attribute15_o              in varchar2
 ,p_gnr_attribute16_o              in varchar2
 ,p_gnr_attribute17_o              in varchar2
 ,p_gnr_attribute18_o              in varchar2
 ,p_gnr_attribute19_o              in varchar2
 ,p_gnr_attribute20_o              in varchar2
 ,p_gnr_attribute21_o              in varchar2
 ,p_gnr_attribute22_o              in varchar2
 ,p_gnr_attribute23_o              in varchar2
 ,p_gnr_attribute24_o              in varchar2
 ,p_gnr_attribute25_o              in varchar2
 ,p_gnr_attribute26_o              in varchar2
 ,p_gnr_attribute27_o              in varchar2
 ,p_gnr_attribute28_o              in varchar2
 ,p_gnr_attribute29_o              in varchar2
 ,p_gnr_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_gnr_rkd;

 

/
