--------------------------------------------------------
--  DDL for Package BEN_EDP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EDP_RKD" AUTHID CURRENT_USER as
/* $Header: beedprhi.pkh 120.0 2005/05/28 02:00:28 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_elig_dpnt_cvrd_othr_pl_id      in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_ordr_num_o                     in number
 ,p_excld_flag_o                   in varchar2
 ,p_cvg_det_dt_cd_o                in varchar2
 ,p_business_group_id_o            in number
 ,p_eligy_prfl_id_o                in number
 ,p_pl_id_o                        in number
 ,p_edp_attribute_category_o       in varchar2
 ,p_edp_attribute1_o               in varchar2
 ,p_edp_attribute2_o               in varchar2
 ,p_edp_attribute3_o               in varchar2
 ,p_edp_attribute4_o               in varchar2
 ,p_edp_attribute5_o               in varchar2
 ,p_edp_attribute6_o               in varchar2
 ,p_edp_attribute7_o               in varchar2
 ,p_edp_attribute8_o               in varchar2
 ,p_edp_attribute9_o               in varchar2
 ,p_edp_attribute10_o              in varchar2
 ,p_edp_attribute11_o              in varchar2
 ,p_edp_attribute12_o              in varchar2
 ,p_edp_attribute13_o              in varchar2
 ,p_edp_attribute14_o              in varchar2
 ,p_edp_attribute15_o              in varchar2
 ,p_edp_attribute16_o              in varchar2
 ,p_edp_attribute17_o              in varchar2
 ,p_edp_attribute18_o              in varchar2
 ,p_edp_attribute19_o              in varchar2
 ,p_edp_attribute20_o              in varchar2
 ,p_edp_attribute21_o              in varchar2
 ,p_edp_attribute22_o              in varchar2
 ,p_edp_attribute23_o              in varchar2
 ,p_edp_attribute24_o              in varchar2
 ,p_edp_attribute25_o              in varchar2
 ,p_edp_attribute26_o              in varchar2
 ,p_edp_attribute27_o              in varchar2
 ,p_edp_attribute28_o              in varchar2
 ,p_edp_attribute29_o              in varchar2
 ,p_edp_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_edp_rkd;

 

/
