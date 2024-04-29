--------------------------------------------------------
--  DDL for Package BEN_NOC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_NOC_RKD" AUTHID CURRENT_USER as
/* $Header: benocrhi.pkh 120.0 2005/05/28 09:10:34 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_no_othr_cvg_rt_id       in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_coord_ben_no_cvg_flag_o        in varchar2
 ,p_vrbl_rt_prfl_id_o                in number
 ,p_business_group_id_o            in number
 ,p_noc_attribute_category_o       in varchar2
 ,p_noc_attribute1_o               in varchar2
 ,p_noc_attribute2_o               in varchar2
 ,p_noc_attribute3_o               in varchar2
 ,p_noc_attribute4_o               in varchar2
 ,p_noc_attribute5_o               in varchar2
 ,p_noc_attribute6_o               in varchar2
 ,p_noc_attribute7_o               in varchar2
 ,p_noc_attribute8_o               in varchar2
 ,p_noc_attribute9_o               in varchar2
 ,p_noc_attribute10_o              in varchar2
 ,p_noc_attribute11_o              in varchar2
 ,p_noc_attribute12_o              in varchar2
 ,p_noc_attribute13_o              in varchar2
 ,p_noc_attribute14_o              in varchar2
 ,p_noc_attribute15_o              in varchar2
 ,p_noc_attribute16_o              in varchar2
 ,p_noc_attribute17_o              in varchar2
 ,p_noc_attribute18_o              in varchar2
 ,p_noc_attribute19_o              in varchar2
 ,p_noc_attribute20_o              in varchar2
 ,p_noc_attribute21_o              in varchar2
 ,p_noc_attribute22_o              in varchar2
 ,p_noc_attribute23_o              in varchar2
 ,p_noc_attribute24_o              in varchar2
 ,p_noc_attribute25_o              in varchar2
 ,p_noc_attribute26_o              in varchar2
 ,p_noc_attribute27_o              in varchar2
 ,p_noc_attribute28_o              in varchar2
 ,p_noc_attribute29_o              in varchar2
 ,p_noc_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_noc_rkd;

 

/