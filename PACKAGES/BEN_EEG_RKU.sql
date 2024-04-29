--------------------------------------------------------
--  DDL for Package BEN_EEG_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EEG_RKU" AUTHID CURRENT_USER as
/* $Header: beeegrhi.pkh 120.0 2005/05/28 02:03:41 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_elig_enrld_anthr_pgm_id        in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_ordr_num                       in number
 ,p_excld_flag                     in varchar2
 ,p_enrl_det_dt_cd                 in varchar2
 ,p_pgm_id                         in number
 ,p_eligy_prfl_id                  in number
 ,p_business_group_id              in number
 ,p_eeg_attribute_category         in varchar2
 ,p_eeg_attribute1                 in varchar2
 ,p_eeg_attribute2                 in varchar2
 ,p_eeg_attribute3                 in varchar2
 ,p_eeg_attribute4                 in varchar2
 ,p_eeg_attribute5                 in varchar2
 ,p_eeg_attribute6                 in varchar2
 ,p_eeg_attribute7                 in varchar2
 ,p_eeg_attribute8                 in varchar2
 ,p_eeg_attribute9                 in varchar2
 ,p_eeg_attribute10                in varchar2
 ,p_eeg_attribute11                in varchar2
 ,p_eeg_attribute12                in varchar2
 ,p_eeg_attribute13                in varchar2
 ,p_eeg_attribute14                in varchar2
 ,p_eeg_attribute15                in varchar2
 ,p_eeg_attribute16                in varchar2
 ,p_eeg_attribute17                in varchar2
 ,p_eeg_attribute18                in varchar2
 ,p_eeg_attribute19                in varchar2
 ,p_eeg_attribute20                in varchar2
 ,p_eeg_attribute21                in varchar2
 ,p_eeg_attribute22                in varchar2
 ,p_eeg_attribute23                in varchar2
 ,p_eeg_attribute24                in varchar2
 ,p_eeg_attribute25                in varchar2
 ,p_eeg_attribute26                in varchar2
 ,p_eeg_attribute27                in varchar2
 ,p_eeg_attribute28                in varchar2
 ,p_eeg_attribute29                in varchar2
 ,p_eeg_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_ordr_num_o                     in number
 ,p_excld_flag_o                   in varchar2
 ,p_enrl_det_dt_cd_o               in varchar2
 ,p_pgm_id_o                       in number
 ,p_eligy_prfl_id_o                in number
 ,p_business_group_id_o            in number
 ,p_eeg_attribute_category_o       in varchar2
 ,p_eeg_attribute1_o               in varchar2
 ,p_eeg_attribute2_o               in varchar2
 ,p_eeg_attribute3_o               in varchar2
 ,p_eeg_attribute4_o               in varchar2
 ,p_eeg_attribute5_o               in varchar2
 ,p_eeg_attribute6_o               in varchar2
 ,p_eeg_attribute7_o               in varchar2
 ,p_eeg_attribute8_o               in varchar2
 ,p_eeg_attribute9_o               in varchar2
 ,p_eeg_attribute10_o              in varchar2
 ,p_eeg_attribute11_o              in varchar2
 ,p_eeg_attribute12_o              in varchar2
 ,p_eeg_attribute13_o              in varchar2
 ,p_eeg_attribute14_o              in varchar2
 ,p_eeg_attribute15_o              in varchar2
 ,p_eeg_attribute16_o              in varchar2
 ,p_eeg_attribute17_o              in varchar2
 ,p_eeg_attribute18_o              in varchar2
 ,p_eeg_attribute19_o              in varchar2
 ,p_eeg_attribute20_o              in varchar2
 ,p_eeg_attribute21_o              in varchar2
 ,p_eeg_attribute22_o              in varchar2
 ,p_eeg_attribute23_o              in varchar2
 ,p_eeg_attribute24_o              in varchar2
 ,p_eeg_attribute25_o              in varchar2
 ,p_eeg_attribute26_o              in varchar2
 ,p_eeg_attribute27_o              in varchar2
 ,p_eeg_attribute28_o              in varchar2
 ,p_eeg_attribute29_o              in varchar2
 ,p_eeg_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_eeg_rku;

 

/