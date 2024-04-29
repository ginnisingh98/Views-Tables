--------------------------------------------------------
--  DDL for Package BEN_CBS_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CBS_RKU" AUTHID CURRENT_USER as
/* $Header: becbsrhi.pkh 120.0 2005/05/28 00:56:49 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_prem_cstg_by_sgmt_id           in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_sgmt_num                       in number
 ,p_sgmt_cstg_mthd_cd              in varchar2
 ,p_sgmt_cstg_mthd_rl              in number
 ,p_business_group_id              in number
 ,p_actl_prem_id                   in number
 ,p_cbs_attribute_category         in varchar2
 ,p_cbs_attribute1                 in varchar2
 ,p_cbs_attribute2                 in varchar2
 ,p_cbs_attribute3                 in varchar2
 ,p_cbs_attribute4                 in varchar2
 ,p_cbs_attribute5                 in varchar2
 ,p_cbs_attribute6                 in varchar2
 ,p_cbs_attribute7                 in varchar2
 ,p_cbs_attribute8                 in varchar2
 ,p_cbs_attribute9                 in varchar2
 ,p_cbs_attribute10                in varchar2
 ,p_cbs_attribute11                in varchar2
 ,p_cbs_attribute12                in varchar2
 ,p_cbs_attribute13                in varchar2
 ,p_cbs_attribute14                in varchar2
 ,p_cbs_attribute15                in varchar2
 ,p_cbs_attribute16                in varchar2
 ,p_cbs_attribute17                in varchar2
 ,p_cbs_attribute18                in varchar2
 ,p_cbs_attribute19                in varchar2
 ,p_cbs_attribute20                in varchar2
 ,p_cbs_attribute21                in varchar2
 ,p_cbs_attribute22                in varchar2
 ,p_cbs_attribute23                in varchar2
 ,p_cbs_attribute24                in varchar2
 ,p_cbs_attribute25                in varchar2
 ,p_cbs_attribute26                in varchar2
 ,p_cbs_attribute27                in varchar2
 ,p_cbs_attribute28                in varchar2
 ,p_cbs_attribute29                in varchar2
 ,p_cbs_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_sgmt_num_o                     in number
 ,p_sgmt_cstg_mthd_cd_o            in varchar2
 ,p_sgmt_cstg_mthd_rl_o            in number
 ,p_business_group_id_o            in number
 ,p_actl_prem_id_o                 in number
 ,p_cbs_attribute_category_o       in varchar2
 ,p_cbs_attribute1_o               in varchar2
 ,p_cbs_attribute2_o               in varchar2
 ,p_cbs_attribute3_o               in varchar2
 ,p_cbs_attribute4_o               in varchar2
 ,p_cbs_attribute5_o               in varchar2
 ,p_cbs_attribute6_o               in varchar2
 ,p_cbs_attribute7_o               in varchar2
 ,p_cbs_attribute8_o               in varchar2
 ,p_cbs_attribute9_o               in varchar2
 ,p_cbs_attribute10_o              in varchar2
 ,p_cbs_attribute11_o              in varchar2
 ,p_cbs_attribute12_o              in varchar2
 ,p_cbs_attribute13_o              in varchar2
 ,p_cbs_attribute14_o              in varchar2
 ,p_cbs_attribute15_o              in varchar2
 ,p_cbs_attribute16_o              in varchar2
 ,p_cbs_attribute17_o              in varchar2
 ,p_cbs_attribute18_o              in varchar2
 ,p_cbs_attribute19_o              in varchar2
 ,p_cbs_attribute20_o              in varchar2
 ,p_cbs_attribute21_o              in varchar2
 ,p_cbs_attribute22_o              in varchar2
 ,p_cbs_attribute23_o              in varchar2
 ,p_cbs_attribute24_o              in varchar2
 ,p_cbs_attribute25_o              in varchar2
 ,p_cbs_attribute26_o              in varchar2
 ,p_cbs_attribute27_o              in varchar2
 ,p_cbs_attribute28_o              in varchar2
 ,p_cbs_attribute29_o              in varchar2
 ,p_cbs_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_cbs_rku;

 

/
