--------------------------------------------------------
--  DDL for Package BEN_ESH_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ESH_RKD" AUTHID CURRENT_USER as
/* $Header: beeshrhi.pkh 120.0 2005/05/28 02:56:49 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_elig_schedd_hrs_prte_id        in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_hrs_num_o                      in number
 ,p_determination_cd_o		   in  varchar2
 ,p_determination_rl_o		   in  number
 ,p_rounding_cd_o		   in  varchar2
 ,p_rounding_rl_o		   in  number
 ,p_max_hrs_num_o	           in  number
 ,p_schedd_hrs_rl_o		   in  number
 ,p_freq_cd_o                      in varchar2
 ,p_ordr_num_o                     in number
 ,p_excld_flag_o                   in varchar2
 ,p_eligy_prfl_id_o                in number
 ,p_esh_attribute_category_o       in varchar2
 ,p_esh_attribute1_o               in varchar2
 ,p_esh_attribute2_o               in varchar2
 ,p_esh_attribute3_o               in varchar2
 ,p_esh_attribute4_o               in varchar2
 ,p_esh_attribute5_o               in varchar2
 ,p_esh_attribute6_o               in varchar2
 ,p_esh_attribute7_o               in varchar2
 ,p_esh_attribute8_o               in varchar2
 ,p_esh_attribute9_o               in varchar2
 ,p_esh_attribute10_o              in varchar2
 ,p_esh_attribute11_o              in varchar2
 ,p_esh_attribute12_o              in varchar2
 ,p_esh_attribute13_o              in varchar2
 ,p_esh_attribute14_o              in varchar2
 ,p_esh_attribute15_o              in varchar2
 ,p_esh_attribute16_o              in varchar2
 ,p_esh_attribute17_o              in varchar2
 ,p_esh_attribute18_o              in varchar2
 ,p_esh_attribute19_o              in varchar2
 ,p_esh_attribute20_o              in varchar2
 ,p_esh_attribute21_o              in varchar2
 ,p_esh_attribute22_o              in varchar2
 ,p_esh_attribute23_o              in varchar2
 ,p_esh_attribute24_o              in varchar2
 ,p_esh_attribute25_o              in varchar2
 ,p_esh_attribute26_o              in varchar2
 ,p_esh_attribute27_o              in varchar2
 ,p_esh_attribute28_o              in varchar2
 ,p_esh_attribute29_o              in varchar2
 ,p_esh_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_criteria_score_o                in number
 ,p_criteria_weight_o               in  number
  );
--
end ben_esh_rkd;

 

/
