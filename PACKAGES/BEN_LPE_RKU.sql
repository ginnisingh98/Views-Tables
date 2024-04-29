--------------------------------------------------------
--  DDL for Package BEN_LPE_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LPE_RKU" AUTHID CURRENT_USER as
/* $Header: belperhi.pkh 120.0 2005/05/28 03:30:23 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_ler_chg_pl_nip_enrt_id         in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_pl_id                          in number
 ,p_ler_id                         in number
 ,p_tco_chg_enrt_cd                in varchar2
 ,p_crnt_enrt_prclds_chg_flag      in varchar2
 ,p_dflt_enrt_cd                   in varchar2
 ,p_dflt_enrt_rl                   in number
 ,p_dflt_flag                      in varchar2
 ,p_enrt_rl                        in number
 ,p_enrt_cd                        in varchar2
 ,p_stl_elig_cant_chg_flag         in varchar2
 ,p_enrt_mthd_cd                   in varchar2
 ,p_auto_enrt_mthd_rl              in number
 ,p_lpe_attribute_category         in varchar2
 ,p_lpe_attribute1                 in varchar2
 ,p_lpe_attribute2                 in varchar2
 ,p_lpe_attribute3                 in varchar2
 ,p_lpe_attribute4                 in varchar2
 ,p_lpe_attribute5                 in varchar2
 ,p_lpe_attribute6                 in varchar2
 ,p_lpe_attribute7                 in varchar2
 ,p_lpe_attribute8                 in varchar2
 ,p_lpe_attribute9                 in varchar2
 ,p_lpe_attribute10                in varchar2
 ,p_lpe_attribute11                in varchar2
 ,p_lpe_attribute12                in varchar2
 ,p_lpe_attribute13                in varchar2
 ,p_lpe_attribute14                in varchar2
 ,p_lpe_attribute15                in varchar2
 ,p_lpe_attribute16                in varchar2
 ,p_lpe_attribute17                in varchar2
 ,p_lpe_attribute18                in varchar2
 ,p_lpe_attribute19                in varchar2
 ,p_lpe_attribute20                in varchar2
 ,p_lpe_attribute21                in varchar2
 ,p_lpe_attribute22                in varchar2
 ,p_lpe_attribute23                in varchar2
 ,p_lpe_attribute24                in varchar2
 ,p_lpe_attribute25                in varchar2
 ,p_lpe_attribute26                in varchar2
 ,p_lpe_attribute27                in varchar2
 ,p_lpe_attribute28                in varchar2
 ,p_lpe_attribute29                in varchar2
 ,p_lpe_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_pl_id_o                        in number
 ,p_ler_id_o                       in number
 ,p_tco_chg_enrt_cd_o              in varchar2
 ,p_crnt_enrt_prclds_chg_flag_o    in varchar2
 ,p_dflt_enrt_cd_o                 in varchar2
 ,p_dflt_enrt_rl_o                 in number
 ,p_dflt_flag_o                    in varchar2
 ,p_enrt_rl_o                      in number
 ,p_enrt_cd_o                      in varchar2
 ,p_stl_elig_cant_chg_flag_o       in varchar2
 ,p_enrt_mthd_cd_o                 in varchar2
 ,p_auto_enrt_mthd_rl_o            in number
 ,p_lpe_attribute_category_o       in varchar2
 ,p_lpe_attribute1_o               in varchar2
 ,p_lpe_attribute2_o               in varchar2
 ,p_lpe_attribute3_o               in varchar2
 ,p_lpe_attribute4_o               in varchar2
 ,p_lpe_attribute5_o               in varchar2
 ,p_lpe_attribute6_o               in varchar2
 ,p_lpe_attribute7_o               in varchar2
 ,p_lpe_attribute8_o               in varchar2
 ,p_lpe_attribute9_o               in varchar2
 ,p_lpe_attribute10_o              in varchar2
 ,p_lpe_attribute11_o              in varchar2
 ,p_lpe_attribute12_o              in varchar2
 ,p_lpe_attribute13_o              in varchar2
 ,p_lpe_attribute14_o              in varchar2
 ,p_lpe_attribute15_o              in varchar2
 ,p_lpe_attribute16_o              in varchar2
 ,p_lpe_attribute17_o              in varchar2
 ,p_lpe_attribute18_o              in varchar2
 ,p_lpe_attribute19_o              in varchar2
 ,p_lpe_attribute20_o              in varchar2
 ,p_lpe_attribute21_o              in varchar2
 ,p_lpe_attribute22_o              in varchar2
 ,p_lpe_attribute23_o              in varchar2
 ,p_lpe_attribute24_o              in varchar2
 ,p_lpe_attribute25_o              in varchar2
 ,p_lpe_attribute26_o              in varchar2
 ,p_lpe_attribute27_o              in varchar2
 ,p_lpe_attribute28_o              in varchar2
 ,p_lpe_attribute29_o              in varchar2
 ,p_lpe_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_lpe_rku;

 

/
