--------------------------------------------------------
--  DDL for Package BEN_LDC_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LDC_RKU" AUTHID CURRENT_USER as
/* $Header: beldcrhi.pkh 120.0 2005/05/28 03:19:54 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_ler_chg_dpnt_cvg_id            in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_pl_id                          in number
 ,p_pgm_id                         in number
 ,p_business_group_id              in number
 ,p_ler_id                         in number
 ,p_ptip_id                        in number
 ,p_add_rmv_cvg_cd                 in varchar2
 ,p_cvg_eff_end_cd                 in varchar2
 ,p_cvg_eff_strt_cd                in varchar2
 ,p_ler_chg_dpnt_cvg_rl            in number
 ,p_ler_chg_dpnt_cvg_cd            in varchar2
 ,p_cvg_eff_strt_rl                in number
 ,p_cvg_eff_end_rl                 in number
 ,p_ldc_attribute_category         in varchar2
 ,p_ldc_attribute1                 in varchar2
 ,p_ldc_attribute2                 in varchar2
 ,p_ldc_attribute3                 in varchar2
 ,p_ldc_attribute4                 in varchar2
 ,p_ldc_attribute5                 in varchar2
 ,p_ldc_attribute6                 in varchar2
 ,p_ldc_attribute7                 in varchar2
 ,p_ldc_attribute8                 in varchar2
 ,p_ldc_attribute9                 in varchar2
 ,p_ldc_attribute10                in varchar2
 ,p_ldc_attribute11                in varchar2
 ,p_ldc_attribute12                in varchar2
 ,p_ldc_attribute13                in varchar2
 ,p_ldc_attribute14                in varchar2
 ,p_ldc_attribute15                in varchar2
 ,p_ldc_attribute16                in varchar2
 ,p_ldc_attribute17                in varchar2
 ,p_ldc_attribute18                in varchar2
 ,p_ldc_attribute19                in varchar2
 ,p_ldc_attribute20                in varchar2
 ,p_ldc_attribute21                in varchar2
 ,p_ldc_attribute22                in varchar2
 ,p_ldc_attribute23                in varchar2
 ,p_ldc_attribute24                in varchar2
 ,p_ldc_attribute25                in varchar2
 ,p_ldc_attribute26                in varchar2
 ,p_ldc_attribute27                in varchar2
 ,p_ldc_attribute28                in varchar2
 ,p_ldc_attribute29                in varchar2
 ,p_ldc_attribute30                in varchar2
 ,p_susp_if_ctfn_not_prvd_flag     in varchar2
 ,p_ctfn_determine_cd              in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_pl_id_o                        in number
 ,p_pgm_id_o                       in number
 ,p_business_group_id_o            in number
 ,p_ler_id_o                       in number
 ,p_ptip_id_o                      in number
 ,p_add_rmv_cvg_cd_o               in varchar2
 ,p_cvg_eff_end_cd_o               in varchar2
 ,p_cvg_eff_strt_cd_o              in varchar2
 ,p_ler_chg_dpnt_cvg_rl_o          in number
 ,p_ler_chg_dpnt_cvg_cd_o          in varchar2
 ,p_cvg_eff_strt_rl_o              in number
 ,p_cvg_eff_end_rl_o               in number
 ,p_ldc_attribute_category_o       in varchar2
 ,p_ldc_attribute1_o               in varchar2
 ,p_ldc_attribute2_o               in varchar2
 ,p_ldc_attribute3_o               in varchar2
 ,p_ldc_attribute4_o               in varchar2
 ,p_ldc_attribute5_o               in varchar2
 ,p_ldc_attribute6_o               in varchar2
 ,p_ldc_attribute7_o               in varchar2
 ,p_ldc_attribute8_o               in varchar2
 ,p_ldc_attribute9_o               in varchar2
 ,p_ldc_attribute10_o              in varchar2
 ,p_ldc_attribute11_o              in varchar2
 ,p_ldc_attribute12_o              in varchar2
 ,p_ldc_attribute13_o              in varchar2
 ,p_ldc_attribute14_o              in varchar2
 ,p_ldc_attribute15_o              in varchar2
 ,p_ldc_attribute16_o              in varchar2
 ,p_ldc_attribute17_o              in varchar2
 ,p_ldc_attribute18_o              in varchar2
 ,p_ldc_attribute19_o              in varchar2
 ,p_ldc_attribute20_o              in varchar2
 ,p_ldc_attribute21_o              in varchar2
 ,p_ldc_attribute22_o              in varchar2
 ,p_ldc_attribute23_o              in varchar2
 ,p_ldc_attribute24_o              in varchar2
 ,p_ldc_attribute25_o              in varchar2
 ,p_ldc_attribute26_o              in varchar2
 ,p_ldc_attribute27_o              in varchar2
 ,p_ldc_attribute28_o              in varchar2
 ,p_ldc_attribute29_o              in varchar2
 ,p_ldc_attribute30_o              in varchar2
 ,p_susp_if_ctfn_not_prvd_flag_o   in varchar2
 ,p_ctfn_determine_cd_o            in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_ldc_rku;

 

/
