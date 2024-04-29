--------------------------------------------------------
--  DDL for Package BEN_LAR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LAR_RKD" AUTHID CURRENT_USER as
/* $Header: belarrhi.pkh 120.0 2005/05/28 03:15:01 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_loa_rsn_rt_id                  in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_ordr_num_o                     in number
 ,p_excld_flag_o                   in varchar2
 ,p_vrbl_rt_prfl_id_o              in number
 ,p_loa_rsn_cd_o                   in varchar2
 ,p_lar_attribute_category_o       in varchar2
 ,p_lar_attribute1_o               in varchar2
 ,p_lar_attribute2_o               in varchar2
 ,p_lar_attribute3_o               in varchar2
 ,p_lar_attribute4_o               in varchar2
 ,p_lar_attribute5_o               in varchar2
 ,p_lar_attribute6_o               in varchar2
 ,p_lar_attribute7_o               in varchar2
 ,p_lar_attribute8_o               in varchar2
 ,p_lar_attribute9_o               in varchar2
 ,p_lar_attribute10_o              in varchar2
 ,p_lar_attribute11_o              in varchar2
 ,p_lar_attribute12_o              in varchar2
 ,p_lar_attribute13_o              in varchar2
 ,p_lar_attribute14_o              in varchar2
 ,p_lar_attribute15_o              in varchar2
 ,p_lar_attribute16_o              in varchar2
 ,p_lar_attribute17_o              in varchar2
 ,p_lar_attribute18_o              in varchar2
 ,p_lar_attribute19_o              in varchar2
 ,p_lar_attribute20_o              in varchar2
 ,p_lar_attribute21_o              in varchar2
 ,p_lar_attribute22_o              in varchar2
 ,p_lar_attribute23_o              in varchar2
 ,p_lar_attribute24_o              in varchar2
 ,p_lar_attribute25_o              in varchar2
 ,p_lar_attribute26_o              in varchar2
 ,p_lar_attribute27_o              in varchar2
 ,p_lar_attribute28_o              in varchar2
 ,p_lar_attribute29_o              in varchar2
 ,p_lar_attribute30_o              in varchar2
 ,p_absence_attendance_type_id_o   in number
 ,p_abs_attendance_reason_id_o     in number
 ,p_object_version_number_o        in number
  );
--
end ben_lar_rkd;

 

/
