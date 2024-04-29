--------------------------------------------------------
--  DDL for Package BEN_BVR_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BVR_RKU" AUTHID CURRENT_USER as
/* $Header: bebvrrhi.pkh 120.0 2005/05/28 00:54:51 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_bnft_vrbl_rt_id                in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_cvg_amt_calc_mthd_id           in number
 ,p_vrbl_rt_prfl_id                in number
 ,p_business_group_id              in number
 ,p_bvr_attribute_category         in varchar2
 ,p_bvr_attribute1                 in varchar2
 ,p_bvr_attribute2                 in varchar2
 ,p_bvr_attribute3                 in varchar2
 ,p_bvr_attribute4                 in varchar2
 ,p_bvr_attribute5                 in varchar2
 ,p_bvr_attribute6                 in varchar2
 ,p_bvr_attribute7                 in varchar2
 ,p_bvr_attribute8                 in varchar2
 ,p_bvr_attribute9                 in varchar2
 ,p_bvr_attribute10                in varchar2
 ,p_bvr_attribute11                in varchar2
 ,p_bvr_attribute12                in varchar2
 ,p_bvr_attribute13                in varchar2
 ,p_bvr_attribute14                in varchar2
 ,p_bvr_attribute15                in varchar2
 ,p_bvr_attribute16                in varchar2
 ,p_bvr_attribute17                in varchar2
 ,p_bvr_attribute18                in varchar2
 ,p_bvr_attribute19                in varchar2
 ,p_bvr_attribute20                in varchar2
 ,p_bvr_attribute21                in varchar2
 ,p_bvr_attribute22                in varchar2
 ,p_bvr_attribute23                in varchar2
 ,p_bvr_attribute24                in varchar2
 ,p_bvr_attribute25                in varchar2
 ,p_bvr_attribute26                in varchar2
 ,p_bvr_attribute27                in varchar2
 ,p_bvr_attribute28                in varchar2
 ,p_bvr_attribute29                in varchar2
 ,p_bvr_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_ordr_num                       in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_cvg_amt_calc_mthd_id_o         in number
 ,p_vrbl_rt_prfl_id_o              in number
 ,p_business_group_id_o            in number
 ,p_bvr_attribute_category_o       in varchar2
 ,p_bvr_attribute1_o               in varchar2
 ,p_bvr_attribute2_o               in varchar2
 ,p_bvr_attribute3_o               in varchar2
 ,p_bvr_attribute4_o               in varchar2
 ,p_bvr_attribute5_o               in varchar2
 ,p_bvr_attribute6_o               in varchar2
 ,p_bvr_attribute7_o               in varchar2
 ,p_bvr_attribute8_o               in varchar2
 ,p_bvr_attribute9_o               in varchar2
 ,p_bvr_attribute10_o              in varchar2
 ,p_bvr_attribute11_o              in varchar2
 ,p_bvr_attribute12_o              in varchar2
 ,p_bvr_attribute13_o              in varchar2
 ,p_bvr_attribute14_o              in varchar2
 ,p_bvr_attribute15_o              in varchar2
 ,p_bvr_attribute16_o              in varchar2
 ,p_bvr_attribute17_o              in varchar2
 ,p_bvr_attribute18_o              in varchar2
 ,p_bvr_attribute19_o              in varchar2
 ,p_bvr_attribute20_o              in varchar2
 ,p_bvr_attribute21_o              in varchar2
 ,p_bvr_attribute22_o              in varchar2
 ,p_bvr_attribute23_o              in varchar2
 ,p_bvr_attribute24_o              in varchar2
 ,p_bvr_attribute25_o              in varchar2
 ,p_bvr_attribute26_o              in varchar2
 ,p_bvr_attribute27_o              in varchar2
 ,p_bvr_attribute28_o              in varchar2
 ,p_bvr_attribute29_o              in varchar2
 ,p_bvr_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_ordr_num_o                     in number
  );
--
end ben_bvr_rku;

 

/
