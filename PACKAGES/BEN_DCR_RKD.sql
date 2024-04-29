--------------------------------------------------------
--  DDL for Package BEN_DCR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DCR_RKD" AUTHID CURRENT_USER as
/* $Header: bedcrrhi.pkh 120.0 2005/05/28 01:34:48 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_dpnt_cvg_rqd_rlshp_id          in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_per_relshp_typ_cd_o            in varchar2
 ,p_cvg_strt_dt_cd_o               in varchar2
 ,p_cvg_thru_dt_rl_o               in number
 ,p_cvg_thru_dt_cd_o               in varchar2
 ,p_cvg_strt_dt_rl_o               in number
 ,p_dpnt_cvg_eligy_prfl_id_o       in number
 ,p_dcr_attribute_category_o       in varchar2
 ,p_dcr_attribute1_o               in varchar2
 ,p_dcr_attribute2_o               in varchar2
 ,p_dcr_attribute3_o               in varchar2
 ,p_dcr_attribute4_o               in varchar2
 ,p_dcr_attribute5_o               in varchar2
 ,p_dcr_attribute6_o               in varchar2
 ,p_dcr_attribute7_o               in varchar2
 ,p_dcr_attribute8_o               in varchar2
 ,p_dcr_attribute9_o               in varchar2
 ,p_dcr_attribute10_o              in varchar2
 ,p_dcr_attribute11_o              in varchar2
 ,p_dcr_attribute12_o              in varchar2
 ,p_dcr_attribute13_o              in varchar2
 ,p_dcr_attribute14_o              in varchar2
 ,p_dcr_attribute15_o              in varchar2
 ,p_dcr_attribute16_o              in varchar2
 ,p_dcr_attribute17_o              in varchar2
 ,p_dcr_attribute18_o              in varchar2
 ,p_dcr_attribute19_o              in varchar2
 ,p_dcr_attribute20_o              in varchar2
 ,p_dcr_attribute21_o              in varchar2
 ,p_dcr_attribute22_o              in varchar2
 ,p_dcr_attribute23_o              in varchar2
 ,p_dcr_attribute24_o              in varchar2
 ,p_dcr_attribute25_o              in varchar2
 ,p_dcr_attribute26_o              in varchar2
 ,p_dcr_attribute27_o              in varchar2
 ,p_dcr_attribute28_o              in varchar2
 ,p_dcr_attribute29_o              in varchar2
 ,p_dcr_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_dcr_rkd;

 

/
