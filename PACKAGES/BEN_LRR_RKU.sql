--------------------------------------------------------
--  DDL for Package BEN_LRR_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LRR_RKU" AUTHID CURRENT_USER as
/* $Header: belrrrhi.pkh 120.0 2005/05/28 03:37:03 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_lee_rsn_rl_id                  in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_formula_id            in number
 ,p_ordr_to_aply_num               in number
 ,p_lee_rsn_id                     in number
 ,p_lrr_attribute_category         in varchar2
 ,p_lrr_attribute1                 in varchar2
 ,p_lrr_attribute2                 in varchar2
 ,p_lrr_attribute3                 in varchar2
 ,p_lrr_attribute4                 in varchar2
 ,p_lrr_attribute5                 in varchar2
 ,p_lrr_attribute6                 in varchar2
 ,p_lrr_attribute7                 in varchar2
 ,p_lrr_attribute8                 in varchar2
 ,p_lrr_attribute9                 in varchar2
 ,p_lrr_attribute10                in varchar2
 ,p_lrr_attribute11                in varchar2
 ,p_lrr_attribute12                in varchar2
 ,p_lrr_attribute13                in varchar2
 ,p_lrr_attribute14                in varchar2
 ,p_lrr_attribute15                in varchar2
 ,p_lrr_attribute16                in varchar2
 ,p_lrr_attribute17                in varchar2
 ,p_lrr_attribute18                in varchar2
 ,p_lrr_attribute19                in varchar2
 ,p_lrr_attribute20                in varchar2
 ,p_lrr_attribute21                in varchar2
 ,p_lrr_attribute22                in varchar2
 ,p_lrr_attribute23                in varchar2
 ,p_lrr_attribute24                in varchar2
 ,p_lrr_attribute25                in varchar2
 ,p_lrr_attribute26                in varchar2
 ,p_lrr_attribute27                in varchar2
 ,p_lrr_attribute28                in varchar2
 ,p_lrr_attribute29                in varchar2
 ,p_lrr_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_formula_id_o          in number
 ,p_ordr_to_aply_num_o             in number
 ,p_lee_rsn_id_o                   in number
 ,p_lrr_attribute_category_o       in varchar2
 ,p_lrr_attribute1_o               in varchar2
 ,p_lrr_attribute2_o               in varchar2
 ,p_lrr_attribute3_o               in varchar2
 ,p_lrr_attribute4_o               in varchar2
 ,p_lrr_attribute5_o               in varchar2
 ,p_lrr_attribute6_o               in varchar2
 ,p_lrr_attribute7_o               in varchar2
 ,p_lrr_attribute8_o               in varchar2
 ,p_lrr_attribute9_o               in varchar2
 ,p_lrr_attribute10_o              in varchar2
 ,p_lrr_attribute11_o              in varchar2
 ,p_lrr_attribute12_o              in varchar2
 ,p_lrr_attribute13_o              in varchar2
 ,p_lrr_attribute14_o              in varchar2
 ,p_lrr_attribute15_o              in varchar2
 ,p_lrr_attribute16_o              in varchar2
 ,p_lrr_attribute17_o              in varchar2
 ,p_lrr_attribute18_o              in varchar2
 ,p_lrr_attribute19_o              in varchar2
 ,p_lrr_attribute20_o              in varchar2
 ,p_lrr_attribute21_o              in varchar2
 ,p_lrr_attribute22_o              in varchar2
 ,p_lrr_attribute23_o              in varchar2
 ,p_lrr_attribute24_o              in varchar2
 ,p_lrr_attribute25_o              in varchar2
 ,p_lrr_attribute26_o              in varchar2
 ,p_lrr_attribute27_o              in varchar2
 ,p_lrr_attribute28_o              in varchar2
 ,p_lrr_attribute29_o              in varchar2
 ,p_lrr_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_lrr_rku;

 

/
