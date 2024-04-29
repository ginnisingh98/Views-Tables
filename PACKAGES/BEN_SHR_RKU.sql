--------------------------------------------------------
--  DDL for Package BEN_SHR_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_SHR_RKU" AUTHID CURRENT_USER as
/* $Header: beshrrhi.pkh 120.0.12010000.1 2008/07/29 13:04:12 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_schedd_hrs_rt_id               in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_vrbl_rt_prfl_id                in number
 ,p_excld_flag                     in varchar2
 ,p_ordr_num                       in number
 ,p_freq_cd                        in varchar2
 ,p_hrs_num                        in number
 ,p_max_hrs_num                    in number
 ,p_schedd_hrs_rl                  in number
 ,p_determination_cd               in varchar2
 ,p_determination_rl               in number
 ,p_rounding_cd                    in varchar2
 ,p_rounding_rl                    in number
 ,p_business_group_id              in number
 ,p_shr_attribute_category         in varchar2
 ,p_shr_attribute1                 in varchar2
 ,p_shr_attribute2                 in varchar2
 ,p_shr_attribute3                 in varchar2
 ,p_shr_attribute4                 in varchar2
 ,p_shr_attribute5                 in varchar2
 ,p_shr_attribute6                 in varchar2
 ,p_shr_attribute7                 in varchar2
 ,p_shr_attribute8                 in varchar2
 ,p_shr_attribute9                 in varchar2
 ,p_shr_attribute10                in varchar2
 ,p_shr_attribute11                in varchar2
 ,p_shr_attribute12                in varchar2
 ,p_shr_attribute13                in varchar2
 ,p_shr_attribute14                in varchar2
 ,p_shr_attribute15                in varchar2
 ,p_shr_attribute16                in varchar2
 ,p_shr_attribute17                in varchar2
 ,p_shr_attribute18                in varchar2
 ,p_shr_attribute19                in varchar2
 ,p_shr_attribute20                in varchar2
 ,p_shr_attribute21                in varchar2
 ,p_shr_attribute22                in varchar2
 ,p_shr_attribute23                in varchar2
 ,p_shr_attribute24                in varchar2
 ,p_shr_attribute25                in varchar2
 ,p_shr_attribute26                in varchar2
 ,p_shr_attribute27                in varchar2
 ,p_shr_attribute28                in varchar2
 ,p_shr_attribute29                in varchar2
 ,p_shr_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_vrbl_rt_prfl_id_o              in number
 ,p_excld_flag_o                   in varchar2
 ,p_ordr_num_o                     in number
 ,p_freq_cd_o                      in varchar2
 ,p_hrs_num_o                      in number
 ,p_max_hrs_num_o                  in number
 ,p_schedd_hrs_rl_o                in number
 ,p_determination_cd_o             in varchar2
 ,p_determination_rl_o             in number
 ,p_rounding_cd_o                  in varchar2
 ,p_rounding_rl_o                  in number
 ,p_business_group_id_o            in number
 ,p_shr_attribute_category_o       in varchar2
 ,p_shr_attribute1_o               in varchar2
 ,p_shr_attribute2_o               in varchar2
 ,p_shr_attribute3_o               in varchar2
 ,p_shr_attribute4_o               in varchar2
 ,p_shr_attribute5_o               in varchar2
 ,p_shr_attribute6_o               in varchar2
 ,p_shr_attribute7_o               in varchar2
 ,p_shr_attribute8_o               in varchar2
 ,p_shr_attribute9_o               in varchar2
 ,p_shr_attribute10_o              in varchar2
 ,p_shr_attribute11_o              in varchar2
 ,p_shr_attribute12_o              in varchar2
 ,p_shr_attribute13_o              in varchar2
 ,p_shr_attribute14_o              in varchar2
 ,p_shr_attribute15_o              in varchar2
 ,p_shr_attribute16_o              in varchar2
 ,p_shr_attribute17_o              in varchar2
 ,p_shr_attribute18_o              in varchar2
 ,p_shr_attribute19_o              in varchar2
 ,p_shr_attribute20_o              in varchar2
 ,p_shr_attribute21_o              in varchar2
 ,p_shr_attribute22_o              in varchar2
 ,p_shr_attribute23_o              in varchar2
 ,p_shr_attribute24_o              in varchar2
 ,p_shr_attribute25_o              in varchar2
 ,p_shr_attribute26_o              in varchar2
 ,p_shr_attribute27_o              in varchar2
 ,p_shr_attribute28_o              in varchar2
 ,p_shr_attribute29_o              in varchar2
 ,p_shr_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_shr_rku;

/
