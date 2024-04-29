--------------------------------------------------------
--  DDL for Package BEN_ERG_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ERG_RKU" AUTHID CURRENT_USER as
/* $Header: beergrhi.pkh 120.0 2005/05/28 02:51:42 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_ELIG_PERF_RTNG_PRTE_id           in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_ELIGY_PRFL_id                in number
 ,p_ordr_num                       in number
 ,p_excld_flag                     in varchar2
 ,p_event_type         		   in varchar2
 ,p_perf_rtng_cd                   in varchar2
 ,p_erg_attribute_category         in varchar2
 ,p_erg_attribute1                 in varchar2
 ,p_erg_attribute2                 in varchar2
 ,p_erg_attribute3                 in varchar2
 ,p_erg_attribute4                 in varchar2
 ,p_erg_attribute5                 in varchar2
 ,p_erg_attribute6                 in varchar2
 ,p_erg_attribute7                 in varchar2
 ,p_erg_attribute8                 in varchar2
 ,p_erg_attribute9                 in varchar2
 ,p_erg_attribute10                in varchar2
 ,p_erg_attribute11                in varchar2
 ,p_erg_attribute12                in varchar2
 ,p_erg_attribute13                in varchar2
 ,p_erg_attribute14                in varchar2
 ,p_erg_attribute15                in varchar2
 ,p_erg_attribute16                in varchar2
 ,p_erg_attribute17                in varchar2
 ,p_erg_attribute18                in varchar2
 ,p_erg_attribute19                in varchar2
 ,p_erg_attribute20                in varchar2
 ,p_erg_attribute21                in varchar2
 ,p_erg_attribute22                in varchar2
 ,p_erg_attribute23                in varchar2
 ,p_erg_attribute24                in varchar2
 ,p_erg_attribute25                in varchar2
 ,p_erg_attribute26                in varchar2
 ,p_erg_attribute27                in varchar2
 ,p_erg_attribute28                in varchar2
 ,p_erg_attribute29                in varchar2
 ,p_erg_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_ELIGY_PRFL_id_o              in number
 ,p_ordr_num_o                     in number
 ,p_excld_flag_o                   in varchar2
 ,p_event_type_o        	   in varchar2
 ,p_perf_rtng_cd_o                 in varchar2
 ,p_erg_attribute_category_o       in varchar2
 ,p_erg_attribute1_o               in varchar2
 ,p_erg_attribute2_o               in varchar2
 ,p_erg_attribute3_o               in varchar2
 ,p_erg_attribute4_o               in varchar2
 ,p_erg_attribute5_o               in varchar2
 ,p_erg_attribute6_o               in varchar2
 ,p_erg_attribute7_o               in varchar2
 ,p_erg_attribute8_o               in varchar2
 ,p_erg_attribute9_o               in varchar2
 ,p_erg_attribute10_o              in varchar2
 ,p_erg_attribute11_o              in varchar2
 ,p_erg_attribute12_o              in varchar2
 ,p_erg_attribute13_o              in varchar2
 ,p_erg_attribute14_o              in varchar2
 ,p_erg_attribute15_o              in varchar2
 ,p_erg_attribute16_o              in varchar2
 ,p_erg_attribute17_o              in varchar2
 ,p_erg_attribute18_o              in varchar2
 ,p_erg_attribute19_o              in varchar2
 ,p_erg_attribute20_o              in varchar2
 ,p_erg_attribute21_o              in varchar2
 ,p_erg_attribute22_o              in varchar2
 ,p_erg_attribute23_o              in varchar2
 ,p_erg_attribute24_o              in varchar2
 ,p_erg_attribute25_o              in varchar2
 ,p_erg_attribute26_o              in varchar2
 ,p_erg_attribute27_o              in varchar2
 ,p_erg_attribute28_o              in varchar2
 ,p_erg_attribute29_o              in varchar2
 ,p_erg_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_criteria_score                 in number
 ,p_criteria_weight                in  number
 ,p_criteria_score_o                in number
 ,p_criteria_weight_o               in  number
  );
--
end ben_erg_rku;

 

/
