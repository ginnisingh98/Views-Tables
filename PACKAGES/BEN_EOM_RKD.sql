--------------------------------------------------------
--  DDL for Package BEN_EOM_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EOM_RKD" AUTHID CURRENT_USER as
/* $Header: beeomrhi.pkh 120.0 2005/05/28 02:32:05 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_elig_optd_mdcr_prte_id         in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_optd_mdcr_flag_o               in varchar2
 ,p_exlcd_flag_o                   in varchar2
 ,p_eligy_prfl_id_o                in number
 ,p_business_group_id_o            in number
 ,p_eom_attribute_category_o       in varchar2
 ,p_eom_attribute1_o               in varchar2
 ,p_eom_attribute2_o               in varchar2
 ,p_eom_attribute3_o               in varchar2
 ,p_eom_attribute4_o               in varchar2
 ,p_eom_attribute5_o               in varchar2
 ,p_eom_attribute6_o               in varchar2
 ,p_eom_attribute7_o               in varchar2
 ,p_eom_attribute8_o               in varchar2
 ,p_eom_attribute9_o               in varchar2
 ,p_eom_attribute10_o              in varchar2
 ,p_eom_attribute11_o              in varchar2
 ,p_eom_attribute12_o              in varchar2
 ,p_eom_attribute13_o              in varchar2
 ,p_eom_attribute14_o              in varchar2
 ,p_eom_attribute15_o              in varchar2
 ,p_eom_attribute16_o              in varchar2
 ,p_eom_attribute17_o              in varchar2
 ,p_eom_attribute18_o              in varchar2
 ,p_eom_attribute19_o              in varchar2
 ,p_eom_attribute20_o              in varchar2
 ,p_eom_attribute21_o              in varchar2
 ,p_eom_attribute22_o              in varchar2
 ,p_eom_attribute23_o              in varchar2
 ,p_eom_attribute24_o              in varchar2
 ,p_eom_attribute25_o              in varchar2
 ,p_eom_attribute26_o              in varchar2
 ,p_eom_attribute27_o              in varchar2
 ,p_eom_attribute28_o              in varchar2
 ,p_eom_attribute29_o              in varchar2
 ,p_eom_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_eom_rkd;

 

/
