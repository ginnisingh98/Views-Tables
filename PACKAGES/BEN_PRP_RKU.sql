--------------------------------------------------------
--  DDL for Package BEN_PRP_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PRP_RKU" AUTHID CURRENT_USER as
/* $Header: beprprhi.pkh 120.0.12010000.1 2008/07/29 12:54:50 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_pl_regy_prps_id                in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_pl_regy_prps_cd                in varchar2
 ,p_pl_regy_bod_id                 in number
 ,p_business_group_id              in number
 ,p_prp_attribute_category         in varchar2
 ,p_prp_attribute1                 in varchar2
 ,p_prp_attribute2                 in varchar2
 ,p_prp_attribute3                 in varchar2
 ,p_prp_attribute4                 in varchar2
 ,p_prp_attribute5                 in varchar2
 ,p_prp_attribute6                 in varchar2
 ,p_prp_attribute7                 in varchar2
 ,p_prp_attribute8                 in varchar2
 ,p_prp_attribute9                 in varchar2
 ,p_prp_attribute10                in varchar2
 ,p_prp_attribute11                in varchar2
 ,p_prp_attribute12                in varchar2
 ,p_prp_attribute13                in varchar2
 ,p_prp_attribute14                in varchar2
 ,p_prp_attribute15                in varchar2
 ,p_prp_attribute16                in varchar2
 ,p_prp_attribute17                in varchar2
 ,p_prp_attribute18                in varchar2
 ,p_prp_attribute19                in varchar2
 ,p_prp_attribute20                in varchar2
 ,p_prp_attribute21                in varchar2
 ,p_prp_attribute22                in varchar2
 ,p_prp_attribute23                in varchar2
 ,p_prp_attribute24                in varchar2
 ,p_prp_attribute25                in varchar2
 ,p_prp_attribute26                in varchar2
 ,p_prp_attribute27                in varchar2
 ,p_prp_attribute28                in varchar2
 ,p_prp_attribute29                in varchar2
 ,p_prp_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_pl_regy_prps_cd_o              in varchar2
 ,p_pl_regy_bod_id_o               in number
 ,p_business_group_id_o            in number
 ,p_prp_attribute_category_o       in varchar2
 ,p_prp_attribute1_o               in varchar2
 ,p_prp_attribute2_o               in varchar2
 ,p_prp_attribute3_o               in varchar2
 ,p_prp_attribute4_o               in varchar2
 ,p_prp_attribute5_o               in varchar2
 ,p_prp_attribute6_o               in varchar2
 ,p_prp_attribute7_o               in varchar2
 ,p_prp_attribute8_o               in varchar2
 ,p_prp_attribute9_o               in varchar2
 ,p_prp_attribute10_o              in varchar2
 ,p_prp_attribute11_o              in varchar2
 ,p_prp_attribute12_o              in varchar2
 ,p_prp_attribute13_o              in varchar2
 ,p_prp_attribute14_o              in varchar2
 ,p_prp_attribute15_o              in varchar2
 ,p_prp_attribute16_o              in varchar2
 ,p_prp_attribute17_o              in varchar2
 ,p_prp_attribute18_o              in varchar2
 ,p_prp_attribute19_o              in varchar2
 ,p_prp_attribute20_o              in varchar2
 ,p_prp_attribute21_o              in varchar2
 ,p_prp_attribute22_o              in varchar2
 ,p_prp_attribute23_o              in varchar2
 ,p_prp_attribute24_o              in varchar2
 ,p_prp_attribute25_o              in varchar2
 ,p_prp_attribute26_o              in varchar2
 ,p_prp_attribute27_o              in varchar2
 ,p_prp_attribute28_o              in varchar2
 ,p_prp_attribute29_o              in varchar2
 ,p_prp_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_prp_rku;

/
