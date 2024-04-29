--------------------------------------------------------
--  DDL for Package BEN_LGL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LGL_RKD" AUTHID CURRENT_USER as
/* $Header: belglrhi.pkh 120.0 2005/05/28 03:24:00 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_lgl_enty_rt_id                 in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_vrbl_rt_prfl_id_o              in number
 ,p_organization_id_o              in number
 ,p_excld_flag_o                   in varchar2
 ,p_ordr_num_o                     in number
 ,p_business_group_id_o            in number
 ,p_ler1_attribute_category_o      in varchar2
 ,p_ler1_attribute1_o              in varchar2
 ,p_ler1_attribute2_o              in varchar2
 ,p_ler1_attribute3_o              in varchar2
 ,p_ler1_attribute4_o              in varchar2
 ,p_ler1_attribute5_o              in varchar2
 ,p_ler1_attribute6_o              in varchar2
 ,p_ler1_attribute7_o              in varchar2
 ,p_ler1_attribute8_o              in varchar2
 ,p_ler1_attribute9_o              in varchar2
 ,p_ler1_attribute10_o             in varchar2
 ,p_ler1_attribute11_o             in varchar2
 ,p_ler1_attribute12_o             in varchar2
 ,p_ler1_attribute13_o             in varchar2
 ,p_ler1_attribute14_o             in varchar2
 ,p_ler1_attribute15_o             in varchar2
 ,p_ler1_attribute16_o             in varchar2
 ,p_ler1_attribute17_o             in varchar2
 ,p_ler1_attribute18_o             in varchar2
 ,p_ler1_attribute19_o             in varchar2
 ,p_ler1_attribute20_o             in varchar2
 ,p_ler1_attribute21_o             in varchar2
 ,p_ler1_attribute22_o             in varchar2
 ,p_ler1_attribute23_o             in varchar2
 ,p_ler1_attribute24_o             in varchar2
 ,p_ler1_attribute25_o             in varchar2
 ,p_ler1_attribute26_o             in varchar2
 ,p_ler1_attribute27_o             in varchar2
 ,p_ler1_attribute28_o             in varchar2
 ,p_ler1_attribute29_o             in varchar2
 ,p_ler1_attribute30_o             in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_lgl_rkd;

 

/
