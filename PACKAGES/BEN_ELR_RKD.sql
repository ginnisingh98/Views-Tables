--------------------------------------------------------
--  DDL for Package BEN_ELR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELR_RKD" AUTHID CURRENT_USER as
/* $Header: beelrrhi.pkh 120.0 2005/05/28 02:21:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_elig_loa_rsn_prte_id           in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_eligy_prfl_id_o                in number
 ,p_ordr_num_o                     in number
 ,p_excld_flag_o                   in varchar2
 ,p_elr_attribute_category_o       in varchar2
 ,p_elr_attribute1_o               in varchar2
 ,p_elr_attribute2_o               in varchar2
 ,p_elr_attribute3_o               in varchar2
 ,p_elr_attribute4_o               in varchar2
 ,p_elr_attribute5_o               in varchar2
 ,p_elr_attribute6_o               in varchar2
 ,p_elr_attribute7_o               in varchar2
 ,p_elr_attribute8_o               in varchar2
 ,p_elr_attribute9_o               in varchar2
 ,p_elr_attribute10_o              in varchar2
 ,p_elr_attribute11_o              in varchar2
 ,p_elr_attribute12_o              in varchar2
 ,p_elr_attribute13_o              in varchar2
 ,p_elr_attribute14_o              in varchar2
 ,p_elr_attribute15_o              in varchar2
 ,p_elr_attribute16_o              in varchar2
 ,p_elr_attribute17_o              in varchar2
 ,p_elr_attribute18_o              in varchar2
 ,p_elr_attribute19_o              in varchar2
 ,p_elr_attribute20_o              in varchar2
 ,p_elr_attribute21_o              in varchar2
 ,p_elr_attribute22_o              in varchar2
 ,p_elr_attribute23_o              in varchar2
 ,p_elr_attribute24_o              in varchar2
 ,p_elr_attribute25_o              in varchar2
 ,p_elr_attribute26_o              in varchar2
 ,p_elr_attribute27_o              in varchar2
 ,p_elr_attribute28_o              in varchar2
 ,p_elr_attribute29_o              in varchar2
 ,p_elr_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_absence_attendance_type_id_o   in number
 ,p_abs_attendance_reason_id_o     in number
 ,p_criteria_score                 in number
 ,p_criteria_weight                in number
  );
--
end ben_elr_rkd;

 

/
