--------------------------------------------------------
--  DDL for Package BEN_ERL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ERL_RKD" AUTHID CURRENT_USER as
/* $Header: beerlrhi.pkh 120.0 2005/05/28 02:52:29 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_eligy_prfl_rl_id               in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_ordr_to_aply_num_o             in number
 ,p_formula_id_o                   in number
 ,p_eligy_prfl_id_o                in number
 ,p_drvbl_fctr_apls_flag_o	   in varchar2
 ,p_business_group_id_o            in number
 ,p_erl_attribute_category_o       in varchar2
 ,p_erl_attribute1_o               in varchar2
 ,p_erl_attribute2_o               in varchar2
 ,p_erl_attribute3_o               in varchar2
 ,p_erl_attribute4_o               in varchar2
 ,p_erl_attribute5_o               in varchar2
 ,p_erl_attribute6_o               in varchar2
 ,p_erl_attribute7_o               in varchar2
 ,p_erl_attribute8_o               in varchar2
 ,p_erl_attribute9_o               in varchar2
 ,p_erl_attribute10_o              in varchar2
 ,p_erl_attribute11_o              in varchar2
 ,p_erl_attribute12_o              in varchar2
 ,p_erl_attribute13_o              in varchar2
 ,p_erl_attribute14_o              in varchar2
 ,p_erl_attribute15_o              in varchar2
 ,p_erl_attribute17_o              in varchar2
 ,p_erl_attribute16_o              in varchar2
 ,p_erl_attribute18_o              in varchar2
 ,p_erl_attribute19_o              in varchar2
 ,p_erl_attribute20_o              in varchar2
 ,p_erl_attribute21_o              in varchar2
 ,p_erl_attribute22_o              in varchar2
 ,p_erl_attribute23_o              in varchar2
 ,p_erl_attribute24_o              in varchar2
 ,p_erl_attribute25_o              in varchar2
 ,p_erl_attribute26_o              in varchar2
 ,p_erl_attribute27_o              in varchar2
 ,p_erl_attribute28_o              in varchar2
 ,p_erl_attribute29_o              in varchar2
 ,p_erl_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_criteria_score_o                in number
 ,p_criteria_weight_o               in  number
  );
--
end ben_erl_rkd;

 

/
