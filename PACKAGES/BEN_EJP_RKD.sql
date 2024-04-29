--------------------------------------------------------
--  DDL for Package BEN_EJP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EJP_RKD" AUTHID CURRENT_USER as
/* $Header: beejprhi.pkh 120.1 2006/02/21 04:00:39 sturlapa noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_elig_job_prte_id               in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_ordr_num_o                     in number
 ,p_excld_flag_o                   in varchar2
 ,p_job_id_o                       in number
 ,p_eligy_prfl_id_o                in number
 ,p_business_group_id_o            in number
 ,p_ejp_attribute_category_o       in varchar2
 ,p_ejp_attribute1_o               in varchar2
 ,p_ejp_attribute2_o               in varchar2
 ,p_ejp_attribute3_o               in varchar2
 ,p_ejp_attribute4_o               in varchar2
 ,p_ejp_attribute5_o               in varchar2
 ,p_ejp_attribute6_o               in varchar2
 ,p_ejp_attribute7_o               in varchar2
 ,p_ejp_attribute8_o               in varchar2
 ,p_ejp_attribute9_o               in varchar2
 ,p_ejp_attribute10_o              in varchar2
 ,p_ejp_attribute11_o              in varchar2
 ,p_ejp_attribute12_o              in varchar2
 ,p_ejp_attribute13_o              in varchar2
 ,p_ejp_attribute14_o              in varchar2
 ,p_ejp_attribute15_o              in varchar2
 ,p_ejp_attribute16_o              in varchar2
 ,p_ejp_attribute17_o              in varchar2
 ,p_ejp_attribute18_o              in varchar2
 ,p_ejp_attribute19_o              in varchar2
 ,p_ejp_attribute20_o              in varchar2
 ,p_ejp_attribute21_o              in varchar2
 ,p_ejp_attribute22_o              in varchar2
 ,p_ejp_attribute23_o              in varchar2
 ,p_ejp_attribute24_o              in varchar2
 ,p_ejp_attribute25_o              in varchar2
 ,p_ejp_attribute26_o              in varchar2
 ,p_ejp_attribute27_o              in varchar2
 ,p_ejp_attribute28_o              in varchar2
 ,p_ejp_attribute29_o              in varchar2
 ,p_ejp_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_criteria_score_o                in number
 ,p_criteria_weight_o               in  number
  );
--
end ben_ejp_rkd;

 

/
