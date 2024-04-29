--------------------------------------------------------
--  DDL for Package BEN_OPP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_OPP_RKD" AUTHID CURRENT_USER as
/* $Header: beopprhi.pkh 120.0 2005/05/28 09:54:37 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_oiplip_id                      in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_oipl_id_o                      in number
 ,p_plip_id_o                      in number
 ,p_business_group_id_o            in number
 ,p_legislation_code_o       in varchar2
 ,p_legislation_subgroup_o       in varchar2
 ,p_opp_attribute_category_o       in varchar2
 ,p_opp_attribute1_o               in varchar2
 ,p_opp_attribute2_o               in varchar2
 ,p_opp_attribute3_o               in varchar2
 ,p_opp_attribute4_o               in varchar2
 ,p_opp_attribute5_o               in varchar2
 ,p_opp_attribute6_o               in varchar2
 ,p_opp_attribute7_o               in varchar2
 ,p_opp_attribute8_o               in varchar2
 ,p_opp_attribute9_o               in varchar2
 ,p_opp_attribute10_o              in varchar2
 ,p_opp_attribute11_o              in varchar2
 ,p_opp_attribute12_o              in varchar2
 ,p_opp_attribute13_o              in varchar2
 ,p_opp_attribute14_o              in varchar2
 ,p_opp_attribute15_o              in varchar2
 ,p_opp_attribute16_o              in varchar2
 ,p_opp_attribute17_o              in varchar2
 ,p_opp_attribute18_o              in varchar2
 ,p_opp_attribute19_o              in varchar2
 ,p_opp_attribute20_o              in varchar2
 ,p_opp_attribute21_o              in varchar2
 ,p_opp_attribute22_o              in varchar2
 ,p_opp_attribute23_o              in varchar2
 ,p_opp_attribute24_o              in varchar2
 ,p_opp_attribute25_o              in varchar2
 ,p_opp_attribute26_o              in varchar2
 ,p_opp_attribute27_o              in varchar2
 ,p_opp_attribute28_o              in varchar2
 ,p_opp_attribute29_o              in varchar2
 ,p_opp_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_opp_rkd;

 

/
