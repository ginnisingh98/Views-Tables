--------------------------------------------------------
--  DDL for Package BEN_ESC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ESC_RKD" AUTHID CURRENT_USER as
/* $Header: beescrhi.pkh 120.0 2005/05/28 02:55:08 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_elig_stdnt_stat_cvg_id         in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_dpnt_cvg_eligy_prfl_id_o       in number
 ,p_cvg_strt_cd_o                  in varchar2
 ,p_cvg_strt_rl_o                  in number
 ,p_cvg_thru_cd_o                  in varchar2
 ,p_cvg_thru_rl_o                  in number
 ,p_stdnt_stat_cd_o                in varchar2
 ,p_esc_attribute_category_o       in varchar2
 ,p_esc_attribute1_o               in varchar2
 ,p_esc_attribute2_o               in varchar2
 ,p_esc_attribute3_o               in varchar2
 ,p_esc_attribute4_o               in varchar2
 ,p_esc_attribute5_o               in varchar2
 ,p_esc_attribute6_o               in varchar2
 ,p_esc_attribute7_o               in varchar2
 ,p_esc_attribute8_o               in varchar2
 ,p_esc_attribute9_o               in varchar2
 ,p_esc_attribute10_o              in varchar2
 ,p_esc_attribute11_o              in varchar2
 ,p_esc_attribute12_o              in varchar2
 ,p_esc_attribute13_o              in varchar2
 ,p_esc_attribute14_o              in varchar2
 ,p_esc_attribute15_o              in varchar2
 ,p_esc_attribute16_o              in varchar2
 ,p_esc_attribute17_o              in varchar2
 ,p_esc_attribute18_o              in varchar2
 ,p_esc_attribute19_o              in varchar2
 ,p_esc_attribute20_o              in varchar2
 ,p_esc_attribute21_o              in varchar2
 ,p_esc_attribute22_o              in varchar2
 ,p_esc_attribute23_o              in varchar2
 ,p_esc_attribute24_o              in varchar2
 ,p_esc_attribute25_o              in varchar2
 ,p_esc_attribute26_o              in varchar2
 ,p_esc_attribute27_o              in varchar2
 ,p_esc_attribute28_o              in varchar2
 ,p_esc_attribute29_o              in varchar2
 ,p_esc_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_esc_rkd;

 

/
