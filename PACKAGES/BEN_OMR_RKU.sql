--------------------------------------------------------
--  DDL for Package BEN_OMR_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_OMR_RKU" AUTHID CURRENT_USER as
/* $Header: beomrrhi.pkh 120.0 2005/05/28 09:52:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_optd_mdcr_rt_id         in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_optd_mdcr_flag                 in varchar2
 ,p_exlcd_flag                     in varchar2
 ,p_vrbl_rt_prfl_id                  in number
 ,p_business_group_id              in number
 ,p_omr_attribute_category         in varchar2
 ,p_omr_attribute1                 in varchar2
 ,p_omr_attribute2                 in varchar2
 ,p_omr_attribute3                 in varchar2
 ,p_omr_attribute4                 in varchar2
 ,p_omr_attribute5                 in varchar2
 ,p_omr_attribute6                 in varchar2
 ,p_omr_attribute7                 in varchar2
 ,p_omr_attribute8                 in varchar2
 ,p_omr_attribute9                 in varchar2
 ,p_omr_attribute10                in varchar2
 ,p_omr_attribute11                in varchar2
 ,p_omr_attribute12                in varchar2
 ,p_omr_attribute13                in varchar2
 ,p_omr_attribute14                in varchar2
 ,p_omr_attribute15                in varchar2
 ,p_omr_attribute16                in varchar2
 ,p_omr_attribute17                in varchar2
 ,p_omr_attribute18                in varchar2
 ,p_omr_attribute19                in varchar2
 ,p_omr_attribute20                in varchar2
 ,p_omr_attribute21                in varchar2
 ,p_omr_attribute22                in varchar2
 ,p_omr_attribute23                in varchar2
 ,p_omr_attribute24                in varchar2
 ,p_omr_attribute25                in varchar2
 ,p_omr_attribute26                in varchar2
 ,p_omr_attribute27                in varchar2
 ,p_omr_attribute28                in varchar2
 ,p_omr_attribute29                in varchar2
 ,p_omr_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_optd_mdcr_flag_o               in varchar2
 ,p_exlcd_flag_o                   in varchar2
 ,p_vrbl_rt_prfl_id_o                in number
 ,p_business_group_id_o            in number
 ,p_omr_attribute_category_o       in varchar2
 ,p_omr_attribute1_o               in varchar2
 ,p_omr_attribute2_o               in varchar2
 ,p_omr_attribute3_o               in varchar2
 ,p_omr_attribute4_o               in varchar2
 ,p_omr_attribute5_o               in varchar2
 ,p_omr_attribute6_o               in varchar2
 ,p_omr_attribute7_o               in varchar2
 ,p_omr_attribute8_o               in varchar2
 ,p_omr_attribute9_o               in varchar2
 ,p_omr_attribute10_o              in varchar2
 ,p_omr_attribute11_o              in varchar2
 ,p_omr_attribute12_o              in varchar2
 ,p_omr_attribute13_o              in varchar2
 ,p_omr_attribute14_o              in varchar2
 ,p_omr_attribute15_o              in varchar2
 ,p_omr_attribute16_o              in varchar2
 ,p_omr_attribute17_o              in varchar2
 ,p_omr_attribute18_o              in varchar2
 ,p_omr_attribute19_o              in varchar2
 ,p_omr_attribute20_o              in varchar2
 ,p_omr_attribute21_o              in varchar2
 ,p_omr_attribute22_o              in varchar2
 ,p_omr_attribute23_o              in varchar2
 ,p_omr_attribute24_o              in varchar2
 ,p_omr_attribute25_o              in varchar2
 ,p_omr_attribute26_o              in varchar2
 ,p_omr_attribute27_o              in varchar2
 ,p_omr_attribute28_o              in varchar2
 ,p_omr_attribute29_o              in varchar2
 ,p_omr_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_omr_rku;

 

/
