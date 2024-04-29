--------------------------------------------------------
--  DDL for Package BEN_ADE_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ADE_RKU" AUTHID CURRENT_USER as
/* $Header: beaderhi.pkh 120.0.12010000.1 2008/07/29 10:48:26 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_apld_dpnt_cvg_elig_prfl_id     in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_apld_dpnt_cvg_elig_rl          in number
 ,p_mndtry_flag                    in varchar2
 ,p_dpnt_cvg_eligy_prfl_id         in number
 ,p_pgm_id                         in number
 ,p_pl_id                          in number
 ,p_ptip_id                        in number
 ,p_ade_attribute_category         in varchar2
 ,p_ade_attribute1                 in varchar2
 ,p_ade_attribute2                 in varchar2
 ,p_ade_attribute3                 in varchar2
 ,p_ade_attribute4                 in varchar2
 ,p_ade_attribute5                 in varchar2
 ,p_ade_attribute6                 in varchar2
 ,p_ade_attribute7                 in varchar2
 ,p_ade_attribute8                 in varchar2
 ,p_ade_attribute9                 in varchar2
 ,p_ade_attribute10                in varchar2
 ,p_ade_attribute11                in varchar2
 ,p_ade_attribute12                in varchar2
 ,p_ade_attribute13                in varchar2
 ,p_ade_attribute14                in varchar2
 ,p_ade_attribute15                in varchar2
 ,p_ade_attribute16                in varchar2
 ,p_ade_attribute17                in varchar2
 ,p_ade_attribute18                in varchar2
 ,p_ade_attribute19                in varchar2
 ,p_ade_attribute20                in varchar2
 ,p_ade_attribute21                in varchar2
 ,p_ade_attribute22                in varchar2
 ,p_ade_attribute23                in varchar2
 ,p_ade_attribute24                in varchar2
 ,p_ade_attribute25                in varchar2
 ,p_ade_attribute26                in varchar2
 ,p_ade_attribute27                in varchar2
 ,p_ade_attribute28                in varchar2
 ,p_ade_attribute29                in varchar2
 ,p_ade_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_apld_dpnt_cvg_elig_rl_o        in number
 ,p_mndtry_flag_o                  in varchar2
 ,p_dpnt_cvg_eligy_prfl_id_o       in number
 ,p_pgm_id_o                       in number
 ,p_pl_id_o                        in number
 ,p_ptip_id_o                      in number
 ,p_ade_attribute_category_o       in varchar2
 ,p_ade_attribute1_o               in varchar2
 ,p_ade_attribute2_o               in varchar2
 ,p_ade_attribute3_o               in varchar2
 ,p_ade_attribute4_o               in varchar2
 ,p_ade_attribute5_o               in varchar2
 ,p_ade_attribute6_o               in varchar2
 ,p_ade_attribute7_o               in varchar2
 ,p_ade_attribute8_o               in varchar2
 ,p_ade_attribute9_o               in varchar2
 ,p_ade_attribute10_o              in varchar2
 ,p_ade_attribute11_o              in varchar2
 ,p_ade_attribute12_o              in varchar2
 ,p_ade_attribute13_o              in varchar2
 ,p_ade_attribute14_o              in varchar2
 ,p_ade_attribute15_o              in varchar2
 ,p_ade_attribute16_o              in varchar2
 ,p_ade_attribute17_o              in varchar2
 ,p_ade_attribute18_o              in varchar2
 ,p_ade_attribute19_o              in varchar2
 ,p_ade_attribute20_o              in varchar2
 ,p_ade_attribute21_o              in varchar2
 ,p_ade_attribute22_o              in varchar2
 ,p_ade_attribute23_o              in varchar2
 ,p_ade_attribute24_o              in varchar2
 ,p_ade_attribute25_o              in varchar2
 ,p_ade_attribute26_o              in varchar2
 ,p_ade_attribute27_o              in varchar2
 ,p_ade_attribute28_o              in varchar2
 ,p_ade_attribute29_o              in varchar2
 ,p_ade_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_ade_rku;

/
