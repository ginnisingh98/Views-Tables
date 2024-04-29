--------------------------------------------------------
--  DDL for Package BEN_ASR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ASR_RKD" AUTHID CURRENT_USER as
/* $Header: beasrrhi.pkh 120.0.12010000.1 2008/07/29 10:51:51 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_asnt_set_rt_id                 in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_vrbl_rt_prfl_id_o              in number
 ,p_assignment_set_id_o            in number
 ,p_ordr_num_o                     in number
 ,p_excld_flag_o                   in varchar2
 ,p_business_group_id_o            in number
 ,p_asr_attribute_category_o       in varchar2
 ,p_asr_attribute1_o               in varchar2
 ,p_asr_attribute2_o               in varchar2
 ,p_asr_attribute3_o               in varchar2
 ,p_asr_attribute4_o               in varchar2
 ,p_asr_attribute5_o               in varchar2
 ,p_asr_attribute6_o               in varchar2
 ,p_asr_attribute7_o               in varchar2
 ,p_asr_attribute8_o               in varchar2
 ,p_asr_attribute9_o               in varchar2
 ,p_asr_attribute10_o              in varchar2
 ,p_asr_attribute11_o              in varchar2
 ,p_asr_attribute12_o              in varchar2
 ,p_asr_attribute13_o              in varchar2
 ,p_asr_attribute14_o              in varchar2
 ,p_asr_attribute15_o              in varchar2
 ,p_asr_attribute16_o              in varchar2
 ,p_asr_attribute17_o              in varchar2
 ,p_asr_attribute18_o              in varchar2
 ,p_asr_attribute19_o              in varchar2
 ,p_asr_attribute20_o              in varchar2
 ,p_asr_attribute21_o              in varchar2
 ,p_asr_attribute22_o              in varchar2
 ,p_asr_attribute23_o              in varchar2
 ,p_asr_attribute24_o              in varchar2
 ,p_asr_attribute25_o              in varchar2
 ,p_asr_attribute26_o              in varchar2
 ,p_asr_attribute27_o              in varchar2
 ,p_asr_attribute28_o              in varchar2
 ,p_asr_attribute29_o              in varchar2
 ,p_asr_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_asr_rkd;

/
