--------------------------------------------------------
--  DDL for Package BEN_ESP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ESP_RKD" AUTHID CURRENT_USER as
/* $Header: beesprhi.pkh 120.0 2005/05/28 02:57:43 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_elig_sp_clng_prg_prte_id       in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_excld_flag_o                   in varchar2
 ,p_ordr_num_o                     in number
 ,p_special_ceiling_step_id_o      in number
 ,p_eligy_prfl_id_o                in number
 ,p_business_group_id_o            in number
 ,p_esp_attribute_category_o       in varchar2
 ,p_esp_attribute1_o               in varchar2
 ,p_esp_attribute2_o               in varchar2
 ,p_esp_attribute3_o               in varchar2
 ,p_esp_attribute4_o               in varchar2
 ,p_esp_attribute5_o               in varchar2
 ,p_esp_attribute6_o               in varchar2
 ,p_esp_attribute7_o               in varchar2
 ,p_esp_attribute8_o               in varchar2
 ,p_esp_attribute9_o               in varchar2
 ,p_esp_attribute10_o              in varchar2
 ,p_esp_attribute11_o              in varchar2
 ,p_esp_attribute12_o              in varchar2
 ,p_esp_attribute13_o              in varchar2
 ,p_esp_attribute14_o              in varchar2
 ,p_esp_attribute15_o              in varchar2
 ,p_esp_attribute16_o              in varchar2
 ,p_esp_attribute17_o              in varchar2
 ,p_esp_attribute18_o              in varchar2
 ,p_esp_attribute19_o              in varchar2
 ,p_esp_attribute20_o              in varchar2
 ,p_esp_attribute21_o              in varchar2
 ,p_esp_attribute22_o              in varchar2
 ,p_esp_attribute23_o              in varchar2
 ,p_esp_attribute24_o              in varchar2
 ,p_esp_attribute25_o              in varchar2
 ,p_esp_attribute26_o              in varchar2
 ,p_esp_attribute27_o              in varchar2
 ,p_esp_attribute28_o              in varchar2
 ,p_esp_attribute29_o              in varchar2
 ,p_esp_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_criteria_score_o                in number
 ,p_criteria_weight_o               in  number
  );
--
end ben_esp_rkd;

 

/
