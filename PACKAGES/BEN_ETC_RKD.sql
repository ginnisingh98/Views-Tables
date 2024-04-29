--------------------------------------------------------
--  DDL for Package BEN_ETC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ETC_RKD" AUTHID CURRENT_USER as
/* $Header: beetcrhi.pkh 120.0 2005/05/28 03:00:55 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_elig_ttl_cvg_vol_prte_id       in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_excld_flag_o                   in varchar2
 ,p_no_mn_cvg_vol_amt_apls_fla_o   in varchar2
 ,p_no_mx_cvg_vol_amt_apls_fla_o   in varchar2
 ,p_ordr_num_o                     in number
 ,p_mn_cvg_vol_amt_o               in number
 ,p_mx_cvg_vol_amt_o               in number
 ,p_cvg_vol_det_cd_o               in varchar2
 ,p_cvg_vol_det_rl_o               in number
 ,p_eligy_prfl_id_o                in number
 ,p_etc_attribute_category_o       in varchar2
 ,p_etc_attribute1_o               in varchar2
 ,p_etc_attribute2_o               in varchar2
 ,p_etc_attribute3_o               in varchar2
 ,p_etc_attribute4_o               in varchar2
 ,p_etc_attribute5_o               in varchar2
 ,p_etc_attribute6_o               in varchar2
 ,p_etc_attribute7_o               in varchar2
 ,p_etc_attribute8_o               in varchar2
 ,p_etc_attribute9_o               in varchar2
 ,p_etc_attribute10_o              in varchar2
 ,p_etc_attribute11_o              in varchar2
 ,p_etc_attribute12_o              in varchar2
 ,p_etc_attribute13_o              in varchar2
 ,p_etc_attribute14_o              in varchar2
 ,p_etc_attribute15_o              in varchar2
 ,p_etc_attribute16_o              in varchar2
 ,p_etc_attribute17_o              in varchar2
 ,p_etc_attribute18_o              in varchar2
 ,p_etc_attribute19_o              in varchar2
 ,p_etc_attribute20_o              in varchar2
 ,p_etc_attribute21_o              in varchar2
 ,p_etc_attribute22_o              in varchar2
 ,p_etc_attribute23_o              in varchar2
 ,p_etc_attribute24_o              in varchar2
 ,p_etc_attribute25_o              in varchar2
 ,p_etc_attribute26_o              in varchar2
 ,p_etc_attribute27_o              in varchar2
 ,p_etc_attribute28_o              in varchar2
 ,p_etc_attribute29_o              in varchar2
 ,p_etc_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_etc_rkd;

 

/
