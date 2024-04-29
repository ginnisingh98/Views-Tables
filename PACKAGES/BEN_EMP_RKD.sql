--------------------------------------------------------
--  DDL for Package BEN_EMP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EMP_RKD" AUTHID CURRENT_USER as
/* $Header: beemprhi.pkh 120.0 2005/05/28 02:25:57 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_elig_mrtl_sts_prte_id         in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_excld_flag_o                   in varchar2
 ,p_marital_status_o               in varchar2
 ,p_eligy_prfl_id_o                in number
 ,p_business_group_id_o            in number
 ,p_emp_attribute_category_o       in varchar2
 ,p_emp_attribute1_o               in varchar2
 ,p_emp_attribute2_o               in varchar2
 ,p_emp_attribute3_o               in varchar2
 ,p_emp_attribute4_o               in varchar2
 ,p_emp_attribute5_o               in varchar2
 ,p_emp_attribute6_o               in varchar2
 ,p_emp_attribute7_o               in varchar2
 ,p_emp_attribute8_o               in varchar2
 ,p_emp_attribute9_o               in varchar2
 ,p_emp_attribute10_o              in varchar2
 ,p_emp_attribute11_o              in varchar2
 ,p_emp_attribute12_o              in varchar2
 ,p_emp_attribute13_o              in varchar2
 ,p_emp_attribute14_o              in varchar2
 ,p_emp_attribute15_o              in varchar2
 ,p_emp_attribute16_o              in varchar2
 ,p_emp_attribute17_o              in varchar2
 ,p_emp_attribute18_o              in varchar2
 ,p_emp_attribute19_o              in varchar2
 ,p_emp_attribute20_o              in varchar2
 ,p_emp_attribute21_o              in varchar2
 ,p_emp_attribute22_o              in varchar2
 ,p_emp_attribute23_o              in varchar2
 ,p_emp_attribute24_o              in varchar2
 ,p_emp_attribute25_o              in varchar2
 ,p_emp_attribute26_o              in varchar2
 ,p_emp_attribute27_o              in varchar2
 ,p_emp_attribute28_o              in varchar2
 ,p_emp_attribute29_o              in varchar2
 ,p_emp_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_criteria_score_o                in number
 ,p_criteria_weight_o               in  number
  );
--
end ben_emp_rkd;

 

/