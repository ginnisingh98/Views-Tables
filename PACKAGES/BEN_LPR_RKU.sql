--------------------------------------------------------
--  DDL for Package BEN_LPR_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LPR_RKU" AUTHID CURRENT_USER as
/* $Header: belprrhi.pkh 120.0 2005/05/28 03:32:31 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_ler_chg_plip_enrt_id           in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_auto_enrt_mthd_rl              in number
 ,p_plip_id                        in number
 ,p_ler_id                         in number
 ,p_tco_chg_enrt_cd                in varchar2
 ,p_crnt_enrt_prclds_chg_flag      in varchar2
 ,p_dflt_flag                      in varchar2
 ,p_dflt_enrt_rl                   in number
 ,p_enrt_rl                        in number
 ,p_dflt_enrt_cd                   in varchar2
 ,p_enrt_mthd_cd                   in varchar2
 ,p_stl_elig_cant_chg_flag         in varchar2
 ,p_enrt_cd                        in varchar2
 ,p_lpr_attribute_category         in varchar2
 ,p_lpr_attribute1                 in varchar2
 ,p_lpr_attribute2                 in varchar2
 ,p_lpr_attribute3                 in varchar2
 ,p_lpr_attribute4                 in varchar2
 ,p_lpr_attribute5                 in varchar2
 ,p_lpr_attribute6                 in varchar2
 ,p_lpr_attribute7                 in varchar2
 ,p_lpr_attribute8                 in varchar2
 ,p_lpr_attribute9                 in varchar2
 ,p_lpr_attribute10                in varchar2
 ,p_lpr_attribute11                in varchar2
 ,p_lpr_attribute12                in varchar2
 ,p_lpr_attribute13                in varchar2
 ,p_lpr_attribute14                in varchar2
 ,p_lpr_attribute15                in varchar2
 ,p_lpr_attribute16                in varchar2
 ,p_lpr_attribute17                in varchar2
 ,p_lpr_attribute18                in varchar2
 ,p_lpr_attribute19                in varchar2
 ,p_lpr_attribute20                in varchar2
 ,p_lpr_attribute21                in varchar2
 ,p_lpr_attribute22                in varchar2
 ,p_lpr_attribute23                in varchar2
 ,p_lpr_attribute24                in varchar2
 ,p_lpr_attribute25                in varchar2
 ,p_lpr_attribute26                in varchar2
 ,p_lpr_attribute27                in varchar2
 ,p_lpr_attribute28                in varchar2
 ,p_lpr_attribute29                in varchar2
 ,p_lpr_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_auto_enrt_mthd_rl_o            in number
 ,p_plip_id_o                      in number
 ,p_ler_id_o                       in number
 ,p_tco_chg_enrt_cd_o              in varchar2
 ,p_crnt_enrt_prclds_chg_flag_o    in varchar2
 ,p_dflt_flag_o                    in varchar2
 ,p_dflt_enrt_rl_o                 in number
 ,p_enrt_rl_o                      in number
 ,p_dflt_enrt_cd_o                 in varchar2
 ,p_enrt_mthd_cd_o                 in varchar2
 ,p_stl_elig_cant_chg_flag_o       in varchar2
 ,p_enrt_cd_o                      in varchar2
 ,p_lpr_attribute_category_o       in varchar2
 ,p_lpr_attribute1_o               in varchar2
 ,p_lpr_attribute2_o               in varchar2
 ,p_lpr_attribute3_o               in varchar2
 ,p_lpr_attribute4_o               in varchar2
 ,p_lpr_attribute5_o               in varchar2
 ,p_lpr_attribute6_o               in varchar2
 ,p_lpr_attribute7_o               in varchar2
 ,p_lpr_attribute8_o               in varchar2
 ,p_lpr_attribute9_o               in varchar2
 ,p_lpr_attribute10_o              in varchar2
 ,p_lpr_attribute11_o              in varchar2
 ,p_lpr_attribute12_o              in varchar2
 ,p_lpr_attribute13_o              in varchar2
 ,p_lpr_attribute14_o              in varchar2
 ,p_lpr_attribute15_o              in varchar2
 ,p_lpr_attribute16_o              in varchar2
 ,p_lpr_attribute17_o              in varchar2
 ,p_lpr_attribute18_o              in varchar2
 ,p_lpr_attribute19_o              in varchar2
 ,p_lpr_attribute20_o              in varchar2
 ,p_lpr_attribute21_o              in varchar2
 ,p_lpr_attribute22_o              in varchar2
 ,p_lpr_attribute23_o              in varchar2
 ,p_lpr_attribute24_o              in varchar2
 ,p_lpr_attribute25_o              in varchar2
 ,p_lpr_attribute26_o              in varchar2
 ,p_lpr_attribute27_o              in varchar2
 ,p_lpr_attribute28_o              in varchar2
 ,p_lpr_attribute29_o              in varchar2
 ,p_lpr_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_lpr_rku;

 

/
