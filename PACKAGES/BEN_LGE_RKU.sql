--------------------------------------------------------
--  DDL for Package BEN_LGE_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LGE_RKU" AUTHID CURRENT_USER as
/* $Header: belgerhi.pkh 120.0 2005/05/28 03:23:09 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_ler_chg_pgm_enrt_id            in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_auto_enrt_mthd_rl              in number
 ,p_crnt_enrt_prclds_chg_flag      in varchar2
 ,p_business_group_id              in number
 ,p_pgm_id                         in number
 ,p_ler_id                         in number
 ,p_dflt_enrt_cd                   in varchar2
 ,p_dflt_enrt_rl                   in number
 ,p_enrt_cd                        in varchar2
 ,p_enrt_mthd_cd                   in varchar2
 ,p_enrt_rl                        in number
 ,p_stl_elig_cant_chg_flag         in varchar2
 ,p_lge_attribute_category         in varchar2
 ,p_lge_attribute1                 in varchar2
 ,p_lge_attribute2                 in varchar2
 ,p_lge_attribute3                 in varchar2
 ,p_lge_attribute4                 in varchar2
 ,p_lge_attribute5                 in varchar2
 ,p_lge_attribute6                 in varchar2
 ,p_lge_attribute7                 in varchar2
 ,p_lge_attribute8                 in varchar2
 ,p_lge_attribute9                 in varchar2
 ,p_lge_attribute10                in varchar2
 ,p_lge_attribute11                in varchar2
 ,p_lge_attribute12                in varchar2
 ,p_lge_attribute13                in varchar2
 ,p_lge_attribute14                in varchar2
 ,p_lge_attribute15                in varchar2
 ,p_lge_attribute16                in varchar2
 ,p_lge_attribute17                in varchar2
 ,p_lge_attribute18                in varchar2
 ,p_lge_attribute19                in varchar2
 ,p_lge_attribute20                in varchar2
 ,p_lge_attribute21                in varchar2
 ,p_lge_attribute22                in varchar2
 ,p_lge_attribute23                in varchar2
 ,p_lge_attribute24                in varchar2
 ,p_lge_attribute25                in varchar2
 ,p_lge_attribute26                in varchar2
 ,p_lge_attribute27                in varchar2
 ,p_lge_attribute28                in varchar2
 ,p_lge_attribute29                in varchar2
 ,p_lge_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_auto_enrt_mthd_rl_o            in number
 ,p_crnt_enrt_prclds_chg_flag_o    in varchar2
 ,p_business_group_id_o            in number
 ,p_pgm_id_o                       in number
 ,p_ler_id_o                       in number
 ,p_dflt_enrt_cd_o                 in varchar2
 ,p_dflt_enrt_rl_o                 in number
 ,p_enrt_cd_o                      in varchar2
 ,p_enrt_mthd_cd_o                 in varchar2
 ,p_enrt_rl_o                      in number
 ,p_stl_elig_cant_chg_flag_o       in varchar2
 ,p_lge_attribute_category_o       in varchar2
 ,p_lge_attribute1_o               in varchar2
 ,p_lge_attribute2_o               in varchar2
 ,p_lge_attribute3_o               in varchar2
 ,p_lge_attribute4_o               in varchar2
 ,p_lge_attribute5_o               in varchar2
 ,p_lge_attribute6_o               in varchar2
 ,p_lge_attribute7_o               in varchar2
 ,p_lge_attribute8_o               in varchar2
 ,p_lge_attribute9_o               in varchar2
 ,p_lge_attribute10_o              in varchar2
 ,p_lge_attribute11_o              in varchar2
 ,p_lge_attribute12_o              in varchar2
 ,p_lge_attribute13_o              in varchar2
 ,p_lge_attribute14_o              in varchar2
 ,p_lge_attribute15_o              in varchar2
 ,p_lge_attribute16_o              in varchar2
 ,p_lge_attribute17_o              in varchar2
 ,p_lge_attribute18_o              in varchar2
 ,p_lge_attribute19_o              in varchar2
 ,p_lge_attribute20_o              in varchar2
 ,p_lge_attribute21_o              in varchar2
 ,p_lge_attribute22_o              in varchar2
 ,p_lge_attribute23_o              in varchar2
 ,p_lge_attribute24_o              in varchar2
 ,p_lge_attribute25_o              in varchar2
 ,p_lge_attribute26_o              in varchar2
 ,p_lge_attribute27_o              in varchar2
 ,p_lge_attribute28_o              in varchar2
 ,p_lge_attribute29_o              in varchar2
 ,p_lge_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_lge_rku;

 

/
