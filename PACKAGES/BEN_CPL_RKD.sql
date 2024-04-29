--------------------------------------------------------
--  DDL for Package BEN_CPL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CPL_RKD" AUTHID CURRENT_USER as
/* $Header: becplrhi.pkh 120.0 2005/05/28 01:14:38 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_cmbn_plip_id                   in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_name_o                         in varchar2
 ,p_business_group_id_o            in number
 ,p_cpl_attribute_category_o       in varchar2
 ,p_cpl_attribute1_o               in varchar2
 ,p_cpl_attribute2_o               in varchar2
 ,p_cpl_attribute3_o               in varchar2
 ,p_cpl_attribute4_o               in varchar2
 ,p_cpl_attribute5_o               in varchar2
 ,p_cpl_attribute6_o               in varchar2
 ,p_cpl_attribute7_o               in varchar2
 ,p_cpl_attribute8_o               in varchar2
 ,p_cpl_attribute9_o               in varchar2
 ,p_cpl_attribute10_o              in varchar2
 ,p_cpl_attribute11_o              in varchar2
 ,p_cpl_attribute12_o              in varchar2
 ,p_cpl_attribute13_o              in varchar2
 ,p_cpl_attribute14_o              in varchar2
 ,p_cpl_attribute15_o              in varchar2
 ,p_cpl_attribute16_o              in varchar2
 ,p_cpl_attribute17_o              in varchar2
 ,p_cpl_attribute18_o              in varchar2
 ,p_cpl_attribute19_o              in varchar2
 ,p_cpl_attribute20_o              in varchar2
 ,p_cpl_attribute21_o              in varchar2
 ,p_cpl_attribute22_o              in varchar2
 ,p_cpl_attribute23_o              in varchar2
 ,p_cpl_attribute24_o              in varchar2
 ,p_cpl_attribute25_o              in varchar2
 ,p_cpl_attribute26_o              in varchar2
 ,p_cpl_attribute27_o              in varchar2
 ,p_cpl_attribute28_o              in varchar2
 ,p_cpl_attribute29_o              in varchar2
 ,p_cpl_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_pgm_id_o                       in number
  );
--
end ben_cpl_rkd;

 

/
