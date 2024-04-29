--------------------------------------------------------
--  DDL for Package BEN_SVA_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_SVA_RKU" AUTHID CURRENT_USER as
/* $Header: besvarhi.pkh 120.0.12010000.1 2008/07/29 13:04:36 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_svc_area_id                    in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_name                           in varchar2
 ,p_org_unit_prdct                 in varchar2
 ,p_business_group_id              in number
 ,p_sva_attribute_category         in varchar2
 ,p_sva_attribute1                 in varchar2
 ,p_sva_attribute2                 in varchar2
 ,p_sva_attribute3                 in varchar2
 ,p_sva_attribute4                 in varchar2
 ,p_sva_attribute5                 in varchar2
 ,p_sva_attribute6                 in varchar2
 ,p_sva_attribute7                 in varchar2
 ,p_sva_attribute8                 in varchar2
 ,p_sva_attribute9                 in varchar2
 ,p_sva_attribute10                in varchar2
 ,p_sva_attribute11                in varchar2
 ,p_sva_attribute12                in varchar2
 ,p_sva_attribute13                in varchar2
 ,p_sva_attribute14                in varchar2
 ,p_sva_attribute15                in varchar2
 ,p_sva_attribute16                in varchar2
 ,p_sva_attribute17                in varchar2
 ,p_sva_attribute18                in varchar2
 ,p_sva_attribute19                in varchar2
 ,p_sva_attribute20                in varchar2
 ,p_sva_attribute21                in varchar2
 ,p_sva_attribute22                in varchar2
 ,p_sva_attribute23                in varchar2
 ,p_sva_attribute24                in varchar2
 ,p_sva_attribute25                in varchar2
 ,p_sva_attribute26                in varchar2
 ,p_sva_attribute27                in varchar2
 ,p_sva_attribute28                in varchar2
 ,p_sva_attribute29                in varchar2
 ,p_sva_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_name_o                         in varchar2
 ,p_org_unit_prdct_o               in varchar2
 ,p_business_group_id_o            in number
 ,p_sva_attribute_category_o       in varchar2
 ,p_sva_attribute1_o               in varchar2
 ,p_sva_attribute2_o               in varchar2
 ,p_sva_attribute3_o               in varchar2
 ,p_sva_attribute4_o               in varchar2
 ,p_sva_attribute5_o               in varchar2
 ,p_sva_attribute6_o               in varchar2
 ,p_sva_attribute7_o               in varchar2
 ,p_sva_attribute8_o               in varchar2
 ,p_sva_attribute9_o               in varchar2
 ,p_sva_attribute10_o              in varchar2
 ,p_sva_attribute11_o              in varchar2
 ,p_sva_attribute12_o              in varchar2
 ,p_sva_attribute13_o              in varchar2
 ,p_sva_attribute14_o              in varchar2
 ,p_sva_attribute15_o              in varchar2
 ,p_sva_attribute16_o              in varchar2
 ,p_sva_attribute17_o              in varchar2
 ,p_sva_attribute18_o              in varchar2
 ,p_sva_attribute19_o              in varchar2
 ,p_sva_attribute20_o              in varchar2
 ,p_sva_attribute21_o              in varchar2
 ,p_sva_attribute22_o              in varchar2
 ,p_sva_attribute23_o              in varchar2
 ,p_sva_attribute24_o              in varchar2
 ,p_sva_attribute25_o              in varchar2
 ,p_sva_attribute26_o              in varchar2
 ,p_sva_attribute27_o              in varchar2
 ,p_sva_attribute28_o              in varchar2
 ,p_sva_attribute29_o              in varchar2
 ,p_sva_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_sva_rku;

/
