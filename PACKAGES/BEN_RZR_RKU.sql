--------------------------------------------------------
--  DDL for Package BEN_RZR_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_RZR_RKU" AUTHID CURRENT_USER as
/* $Header: berzrrhi.pkh 120.0.12010000.1 2008/07/29 13:03:06 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_pstl_zip_rng_id                in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_from_value                     in varchar2
 ,p_to_value                       in varchar2
 ,p_business_group_id              in number
 ,p_rzr_attribute_category         in varchar2
 ,p_rzr_attribute1                 in varchar2
 ,p_rzr_attribute10                in varchar2
 ,p_rzr_attribute11                in varchar2
 ,p_rzr_attribute12                in varchar2
 ,p_rzr_attribute13                in varchar2
 ,p_rzr_attribute14                in varchar2
 ,p_rzr_attribute15                in varchar2
 ,p_rzr_attribute16                in varchar2
 ,p_rzr_attribute17                in varchar2
 ,p_rzr_attribute18                in varchar2
 ,p_rzr_attribute19                in varchar2
 ,p_rzr_attribute2                 in varchar2
 ,p_rzr_attribute20                in varchar2
 ,p_rzr_attribute21                in varchar2
 ,p_rzr_attribute22                in varchar2
 ,p_rzr_attribute23                in varchar2
 ,p_rzr_attribute24                in varchar2
 ,p_rzr_attribute25                in varchar2
 ,p_rzr_attribute26                in varchar2
 ,p_rzr_attribute27                in varchar2
 ,p_rzr_attribute28                in varchar2
 ,p_rzr_attribute29                in varchar2
 ,p_rzr_attribute3                 in varchar2
 ,p_rzr_attribute30                in varchar2
 ,p_rzr_attribute4                 in varchar2
 ,p_rzr_attribute5                 in varchar2
 ,p_rzr_attribute6                 in varchar2
 ,p_rzr_attribute7                 in varchar2
 ,p_rzr_attribute8                 in varchar2
 ,p_rzr_attribute9                 in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_from_value_o                   in varchar2
 ,p_to_value_o                     in varchar2
 ,p_business_group_id_o            in number
 ,p_rzr_attribute_category_o       in varchar2
 ,p_rzr_attribute1_o               in varchar2
 ,p_rzr_attribute10_o              in varchar2
 ,p_rzr_attribute11_o              in varchar2
 ,p_rzr_attribute12_o              in varchar2
 ,p_rzr_attribute13_o              in varchar2
 ,p_rzr_attribute14_o              in varchar2
 ,p_rzr_attribute15_o              in varchar2
 ,p_rzr_attribute16_o              in varchar2
 ,p_rzr_attribute17_o              in varchar2
 ,p_rzr_attribute18_o              in varchar2
 ,p_rzr_attribute19_o              in varchar2
 ,p_rzr_attribute2_o               in varchar2
 ,p_rzr_attribute20_o              in varchar2
 ,p_rzr_attribute21_o              in varchar2
 ,p_rzr_attribute22_o              in varchar2
 ,p_rzr_attribute23_o              in varchar2
 ,p_rzr_attribute24_o              in varchar2
 ,p_rzr_attribute25_o              in varchar2
 ,p_rzr_attribute26_o              in varchar2
 ,p_rzr_attribute27_o              in varchar2
 ,p_rzr_attribute28_o              in varchar2
 ,p_rzr_attribute29_o              in varchar2
 ,p_rzr_attribute3_o               in varchar2
 ,p_rzr_attribute30_o              in varchar2
 ,p_rzr_attribute4_o               in varchar2
 ,p_rzr_attribute5_o               in varchar2
 ,p_rzr_attribute6_o               in varchar2
 ,p_rzr_attribute7_o               in varchar2
 ,p_rzr_attribute8_o               in varchar2
 ,p_rzr_attribute9_o               in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_rzr_rku;

/
