--------------------------------------------------------
--  DDL for Package BEN_LPL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LPL_RKD" AUTHID CURRENT_USER as
/* $Header: belplrhi.pkh 120.0 2005/05/28 03:31:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_ler_per_info_cs_ler_id         in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_ler_per_info_cs_ler_rl_o       in number
 ,p_per_info_chg_cs_ler_id_o       in number
 ,p_ler_id_o                       in number
 ,p_business_group_id_o            in number
 ,p_lpl_attribute_category_o       in varchar2
 ,p_lpl_attribute1_o               in varchar2
 ,p_lpl_attribute2_o               in varchar2
 ,p_lpl_attribute3_o               in varchar2
 ,p_lpl_attribute4_o               in varchar2
 ,p_lpl_attribute5_o               in varchar2
 ,p_lpl_attribute6_o               in varchar2
 ,p_lpl_attribute7_o               in varchar2
 ,p_lpl_attribute8_o               in varchar2
 ,p_lpl_attribute9_o               in varchar2
 ,p_lpl_attribute10_o              in varchar2
 ,p_lpl_attribute11_o              in varchar2
 ,p_lpl_attribute12_o              in varchar2
 ,p_lpl_attribute13_o              in varchar2
 ,p_lpl_attribute14_o              in varchar2
 ,p_lpl_attribute15_o              in varchar2
 ,p_lpl_attribute16_o              in varchar2
 ,p_lpl_attribute17_o              in varchar2
 ,p_lpl_attribute18_o              in varchar2
 ,p_lpl_attribute19_o              in varchar2
 ,p_lpl_attribute20_o              in varchar2
 ,p_lpl_attribute21_o              in varchar2
 ,p_lpl_attribute22_o              in varchar2
 ,p_lpl_attribute23_o              in varchar2
 ,p_lpl_attribute24_o              in varchar2
 ,p_lpl_attribute25_o              in varchar2
 ,p_lpl_attribute26_o              in varchar2
 ,p_lpl_attribute27_o              in varchar2
 ,p_lpl_attribute28_o              in varchar2
 ,p_lpl_attribute29_o              in varchar2
 ,p_lpl_attribute30_o              in varchar2
 ,p_chg_mandatory_cd_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_lpl_rkd;

 

/
