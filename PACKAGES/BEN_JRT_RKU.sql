--------------------------------------------------------
--  DDL for Package BEN_JRT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_JRT_RKU" AUTHID CURRENT_USER as
/* $Header: bejrtrhi.pkh 120.0 2005/05/28 03:14:12 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_datetrack_mode               in varchar2
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_job_rt_id                    in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_job_id                       in number
  ,p_excld_flag                   in varchar2
  ,p_business_group_id            in number
  ,p_vrbl_rt_prfl_id              in number
  ,p_object_version_number        in number
  ,p_ordr_num                     in number
  ,p_jrt_attribute_category       in varchar2
  ,p_jrt_attribute1               in varchar2
  ,p_jrt_attribute2               in varchar2
  ,p_jrt_attribute3               in varchar2
  ,p_jrt_attribute4               in varchar2
  ,p_jrt_attribute5               in varchar2
  ,p_jrt_attribute6               in varchar2
  ,p_jrt_attribute7               in varchar2
  ,p_jrt_attribute8               in varchar2
  ,p_jrt_attribute9               in varchar2
  ,p_jrt_attribute10              in varchar2
  ,p_jrt_attribute11              in varchar2
  ,p_jrt_attribute12              in varchar2
  ,p_jrt_attribute13              in varchar2
  ,p_jrt_attribute14              in varchar2
  ,p_jrt_attribute15              in varchar2
  ,p_jrt_attribute16              in varchar2
  ,p_jrt_attribute17              in varchar2
  ,p_jrt_attribute18              in varchar2
  ,p_jrt_attribute19              in varchar2
  ,p_jrt_attribute20              in varchar2
  ,p_jrt_attribute21              in varchar2
  ,p_jrt_attribute22              in varchar2
  ,p_jrt_attribute23              in varchar2
  ,p_jrt_attribute24              in varchar2
  ,p_jrt_attribute25              in varchar2
  ,p_jrt_attribute26              in varchar2
  ,p_jrt_attribute27              in varchar2
  ,p_jrt_attribute28              in varchar2
  ,p_jrt_attribute29              in varchar2
  ,p_jrt_attribute30              in varchar2
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_job_id_o                     in number
  ,p_excld_flag_o                 in varchar2
  ,p_business_group_id_o          in number
  ,p_vrbl_rt_prfl_id_o            in number
  ,p_object_version_number_o      in number
  ,p_ordr_num_o                   in number
  ,p_jrt_attribute_category_o     in varchar2
  ,p_jrt_attribute1_o             in varchar2
  ,p_jrt_attribute2_o             in varchar2
  ,p_jrt_attribute3_o             in varchar2
  ,p_jrt_attribute4_o             in varchar2
  ,p_jrt_attribute5_o             in varchar2
  ,p_jrt_attribute6_o             in varchar2
  ,p_jrt_attribute7_o             in varchar2
  ,p_jrt_attribute8_o             in varchar2
  ,p_jrt_attribute9_o             in varchar2
  ,p_jrt_attribute10_o            in varchar2
  ,p_jrt_attribute11_o            in varchar2
  ,p_jrt_attribute12_o            in varchar2
  ,p_jrt_attribute13_o            in varchar2
  ,p_jrt_attribute14_o            in varchar2
  ,p_jrt_attribute15_o            in varchar2
  ,p_jrt_attribute16_o            in varchar2
  ,p_jrt_attribute17_o            in varchar2
  ,p_jrt_attribute18_o            in varchar2
  ,p_jrt_attribute19_o            in varchar2
  ,p_jrt_attribute20_o            in varchar2
  ,p_jrt_attribute21_o            in varchar2
  ,p_jrt_attribute22_o            in varchar2
  ,p_jrt_attribute23_o            in varchar2
  ,p_jrt_attribute24_o            in varchar2
  ,p_jrt_attribute25_o            in varchar2
  ,p_jrt_attribute26_o            in varchar2
  ,p_jrt_attribute27_o            in varchar2
  ,p_jrt_attribute28_o            in varchar2
  ,p_jrt_attribute29_o            in varchar2
  ,p_jrt_attribute30_o            in varchar2
  );
--
end ben_jrt_rku;

 

/
