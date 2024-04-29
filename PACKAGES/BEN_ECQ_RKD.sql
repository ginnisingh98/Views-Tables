--------------------------------------------------------
--  DDL for Package BEN_ECQ_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ECQ_RKD" AUTHID CURRENT_USER as
/* $Header: beecqrhi.pkh 120.0 2005/05/28 01:52:29 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_elig_cbr_quald_bnf_id          in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
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
 ,p_criteria_score_o	in		number
 ,p_criteria_weight_o	in	number
  );
--
end ben_ecq_rkd;

 

/
