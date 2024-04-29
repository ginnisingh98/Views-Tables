--------------------------------------------------------
--  DDL for Package BEN_ECQ_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ECQ_RKU" AUTHID CURRENT_USER as
/* $Header: beecqrhi.pkh 120.0 2005/05/28 01:52:29 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_elig_cbr_quald_bnf_id          in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_quald_bnf_flag                 in varchar2
 ,p_ordr_num                       in number
 ,p_eligy_prfl_id                  in number
 ,p_pgm_id                         in number
 ,p_ptip_id                        in number
 ,p_business_group_id              in number
 ,p_ecq_attribute_category         in varchar2
 ,p_ecq_attribute1                 in varchar2
 ,p_ecq_attribute2                 in varchar2
 ,p_ecq_attribute3                 in varchar2
 ,p_ecq_attribute4                 in varchar2
 ,p_ecq_attribute5                 in varchar2
 ,p_ecq_attribute6                 in varchar2
 ,p_ecq_attribute7                 in varchar2
 ,p_ecq_attribute8                 in varchar2
 ,p_ecq_attribute9                 in varchar2
 ,p_ecq_attribute10                in varchar2
 ,p_ecq_attribute11                in varchar2
 ,p_ecq_attribute12                in varchar2
 ,p_ecq_attribute13                in varchar2
 ,p_ecq_attribute14                in varchar2
 ,p_ecq_attribute15                in varchar2
 ,p_ecq_attribute16                in varchar2
 ,p_ecq_attribute17                in varchar2
 ,p_ecq_attribute18                in varchar2
 ,p_ecq_attribute19                in varchar2
 ,p_ecq_attribute20                in varchar2
 ,p_ecq_attribute21                in varchar2
 ,p_ecq_attribute22                in varchar2
 ,p_ecq_attribute23                in varchar2
 ,p_ecq_attribute24                in varchar2
 ,p_ecq_attribute25                in varchar2
 ,p_ecq_attribute26                in varchar2
 ,p_ecq_attribute27                in varchar2
 ,p_ecq_attribute28                in varchar2
 ,p_ecq_attribute29                in varchar2
 ,p_ecq_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_quald_bnf_flag_o               in varchar2
 ,p_ordr_num_o                     in number
 ,p_eligy_prfl_id_o                in number
 ,p_pgm_id_o                       in number
 ,p_ptip_id_o                      in number
 ,p_business_group_id_o            in number
 ,p_ecq_attribute_category_o       in varchar2
 ,p_ecq_attribute1_o               in varchar2
 ,p_ecq_attribute2_o               in varchar2
 ,p_ecq_attribute3_o               in varchar2
 ,p_ecq_attribute4_o               in varchar2
 ,p_ecq_attribute5_o               in varchar2
 ,p_ecq_attribute6_o               in varchar2
 ,p_ecq_attribute7_o               in varchar2
 ,p_ecq_attribute8_o               in varchar2
 ,p_ecq_attribute9_o               in varchar2
 ,p_ecq_attribute10_o              in varchar2
 ,p_ecq_attribute11_o              in varchar2
 ,p_ecq_attribute12_o              in varchar2
 ,p_ecq_attribute13_o              in varchar2
 ,p_ecq_attribute14_o              in varchar2
 ,p_ecq_attribute15_o              in varchar2
 ,p_ecq_attribute16_o              in varchar2
 ,p_ecq_attribute17_o              in varchar2
 ,p_ecq_attribute18_o              in varchar2
 ,p_ecq_attribute19_o              in varchar2
 ,p_ecq_attribute20_o              in varchar2
 ,p_ecq_attribute21_o              in varchar2
 ,p_ecq_attribute22_o              in varchar2
 ,p_ecq_attribute23_o              in varchar2
 ,p_ecq_attribute24_o              in varchar2
 ,p_ecq_attribute25_o              in varchar2
 ,p_ecq_attribute26_o              in varchar2
 ,p_ecq_attribute27_o              in varchar2
 ,p_ecq_attribute28_o              in varchar2
 ,p_ecq_attribute29_o              in varchar2
 ,p_ecq_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_criteria_score		in	number
  ,p_criteria_weight	in		number
  ,p_criteria_score_o	in		number
  ,p_criteria_weight_o	in		number
  );
--
end ben_ecq_rku;

 

/
