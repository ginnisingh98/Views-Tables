--------------------------------------------------------
--  DDL for Package BEN_CTY_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CTY_RKD" AUTHID CURRENT_USER as
/* $Header: bectyrhi.pkh 120.0 2005/05/28 01:29:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_effective_date               in date
  ,p_datetrack_mode               in varchar2
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_comptncy_rt_id               in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_competence_id_o              in number
  ,p_rating_level_id_o            in number
  ,p_excld_flag_o                 in varchar2
  ,p_business_group_id_o          in number
  ,p_vrbl_rt_prfl_id_o            in number
  ,p_object_version_number_o      in number
  ,p_ordr_num_o                   in number
  ,p_cty_attribute_category_o     in varchar2
  ,p_cty_attribute1_o             in varchar2
  ,p_cty_attribute2_o             in varchar2
  ,p_cty_attribute3_o             in varchar2
  ,p_cty_attribute4_o             in varchar2
  ,p_cty_attribute5_o             in varchar2
  ,p_cty_attribute6_o             in varchar2
  ,p_cty_attribute7_o             in varchar2
  ,p_cty_attribute8_o             in varchar2
  ,p_cty_attribute9_o             in varchar2
  ,p_cty_attribute10_o            in varchar2
  ,p_cty_attribute11_o            in varchar2
  ,p_cty_attribute12_o            in varchar2
  ,p_cty_attribute13_o            in varchar2
  ,p_cty_attribute14_o            in varchar2
  ,p_cty_attribute15_o            in varchar2
  ,p_cty_attribute16_o            in varchar2
  ,p_cty_attribute17_o            in varchar2
  ,p_cty_attribute18_o            in varchar2
  ,p_cty_attribute19_o            in varchar2
  ,p_cty_attribute20_o            in varchar2
  ,p_cty_attribute21_o            in varchar2
  ,p_cty_attribute22_o            in varchar2
  ,p_cty_attribute23_o            in varchar2
  ,p_cty_attribute24_o            in varchar2
  ,p_cty_attribute25_o            in varchar2
  ,p_cty_attribute26_o            in varchar2
  ,p_cty_attribute27_o            in varchar2
  ,p_cty_attribute28_o            in varchar2
  ,p_cty_attribute29_o            in varchar2
  ,p_cty_attribute30_o            in varchar2
  );
--
end ben_cty_rkd;

 

/
