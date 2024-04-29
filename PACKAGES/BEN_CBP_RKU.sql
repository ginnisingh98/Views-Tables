--------------------------------------------------------
--  DDL for Package BEN_CBP_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CBP_RKU" AUTHID CURRENT_USER as
/* $Header: becbprhi.pkh 120.0 2005/05/28 00:55:32 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_cmbn_ptip_id                   in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_name                           in varchar2
 ,p_business_group_id              in number
 ,p_cbp_attribute_category         in varchar2
 ,p_cbp_attribute1                 in varchar2
 ,p_cbp_attribute2                 in varchar2
 ,p_cbp_attribute3                 in varchar2
 ,p_cbp_attribute4                 in varchar2
 ,p_cbp_attribute5                 in varchar2
 ,p_cbp_attribute6                 in varchar2
 ,p_cbp_attribute7                 in varchar2
 ,p_cbp_attribute8                 in varchar2
 ,p_cbp_attribute9                 in varchar2
 ,p_cbp_attribute10                in varchar2
 ,p_cbp_attribute11                in varchar2
 ,p_cbp_attribute12                in varchar2
 ,p_cbp_attribute13                in varchar2
 ,p_cbp_attribute14                in varchar2
 ,p_cbp_attribute15                in varchar2
 ,p_cbp_attribute16                in varchar2
 ,p_cbp_attribute17                in varchar2
 ,p_cbp_attribute18                in varchar2
 ,p_cbp_attribute19                in varchar2
 ,p_cbp_attribute20                in varchar2
 ,p_cbp_attribute21                in varchar2
 ,p_cbp_attribute22                in varchar2
 ,p_cbp_attribute23                in varchar2
 ,p_cbp_attribute24                in varchar2
 ,p_cbp_attribute25                in varchar2
 ,p_cbp_attribute26                in varchar2
 ,p_cbp_attribute27                in varchar2
 ,p_cbp_attribute28                in varchar2
 ,p_cbp_attribute29                in varchar2
 ,p_cbp_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_pgm_id                         in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_name_o                         in varchar2
 ,p_business_group_id_o            in number
 ,p_cbp_attribute_category_o       in varchar2
 ,p_cbp_attribute1_o               in varchar2
 ,p_cbp_attribute2_o               in varchar2
 ,p_cbp_attribute3_o               in varchar2
 ,p_cbp_attribute4_o               in varchar2
 ,p_cbp_attribute5_o               in varchar2
 ,p_cbp_attribute6_o               in varchar2
 ,p_cbp_attribute7_o               in varchar2
 ,p_cbp_attribute8_o               in varchar2
 ,p_cbp_attribute9_o               in varchar2
 ,p_cbp_attribute10_o              in varchar2
 ,p_cbp_attribute11_o              in varchar2
 ,p_cbp_attribute12_o              in varchar2
 ,p_cbp_attribute13_o              in varchar2
 ,p_cbp_attribute14_o              in varchar2
 ,p_cbp_attribute15_o              in varchar2
 ,p_cbp_attribute16_o              in varchar2
 ,p_cbp_attribute17_o              in varchar2
 ,p_cbp_attribute18_o              in varchar2
 ,p_cbp_attribute19_o              in varchar2
 ,p_cbp_attribute20_o              in varchar2
 ,p_cbp_attribute21_o              in varchar2
 ,p_cbp_attribute22_o              in varchar2
 ,p_cbp_attribute23_o              in varchar2
 ,p_cbp_attribute24_o              in varchar2
 ,p_cbp_attribute25_o              in varchar2
 ,p_cbp_attribute26_o              in varchar2
 ,p_cbp_attribute27_o              in varchar2
 ,p_cbp_attribute28_o              in varchar2
 ,p_cbp_attribute29_o              in varchar2
 ,p_cbp_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_pgm_id_o                       in number
  );
--
end ben_cbp_rku;

 

/
