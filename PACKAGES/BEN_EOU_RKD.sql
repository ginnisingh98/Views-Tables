--------------------------------------------------------
--  DDL for Package BEN_EOU_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EOU_RKD" AUTHID CURRENT_USER as
/* $Header: beeourhi.pkh 120.1 2006/02/21 03:58:52 sturlapa noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_elig_org_unit_prte_id          in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_eligy_prfl_id_o                in number
 ,p_organization_id_o              in number
 ,p_excld_flag_o                   in varchar2
 ,p_ordr_num_o                     in number
 ,p_eou_attribute_category_o       in varchar2
 ,p_eou_attribute1_o               in varchar2
 ,p_eou_attribute2_o               in varchar2
 ,p_eou_attribute3_o               in varchar2
 ,p_eou_attribute4_o               in varchar2
 ,p_eou_attribute5_o               in varchar2
 ,p_eou_attribute6_o               in varchar2
 ,p_eou_attribute7_o               in varchar2
 ,p_eou_attribute8_o               in varchar2
 ,p_eou_attribute9_o               in varchar2
 ,p_eou_attribute10_o              in varchar2
 ,p_eou_attribute11_o              in varchar2
 ,p_eou_attribute12_o              in varchar2
 ,p_eou_attribute13_o              in varchar2
 ,p_eou_attribute14_o              in varchar2
 ,p_eou_attribute15_o              in varchar2
 ,p_eou_attribute16_o              in varchar2
 ,p_eou_attribute17_o              in varchar2
 ,p_eou_attribute18_o              in varchar2
 ,p_eou_attribute19_o              in varchar2
 ,p_eou_attribute20_o              in varchar2
 ,p_eou_attribute21_o              in varchar2
 ,p_eou_attribute22_o              in varchar2
 ,p_eou_attribute23_o              in varchar2
 ,p_eou_attribute24_o              in varchar2
 ,p_eou_attribute25_o              in varchar2
 ,p_eou_attribute26_o              in varchar2
 ,p_eou_attribute27_o              in varchar2
 ,p_eou_attribute28_o              in varchar2
 ,p_eou_attribute29_o              in varchar2
 ,p_eou_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_criteria_score_o                in number
 ,p_criteria_weight_o               in  number
  );
--
end ben_eou_rkd;

 

/
