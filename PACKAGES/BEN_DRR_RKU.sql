--------------------------------------------------------
--  DDL for Package BEN_DRR_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DRR_RKU" AUTHID CURRENT_USER as
/* $Header: bedrrrhi.pkh 120.0 2005/05/28 01:40:29 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_dsgn_rqmt_rlshp_typ_id         in number
 ,p_rlshp_typ_cd                   in varchar2
 ,p_dsgn_rqmt_id                   in number
 ,p_business_group_id              in number
 ,p_drr_attribute_category         in varchar2
 ,p_drr_attribute1                 in varchar2
 ,p_drr_attribute2                 in varchar2
 ,p_drr_attribute3                 in varchar2
 ,p_drr_attribute4                 in varchar2
 ,p_drr_attribute5                 in varchar2
 ,p_drr_attribute6                 in varchar2
 ,p_drr_attribute7                 in varchar2
 ,p_drr_attribute8                 in varchar2
 ,p_drr_attribute9                 in varchar2
 ,p_drr_attribute10                in varchar2
 ,p_drr_attribute11                in varchar2
 ,p_drr_attribute12                in varchar2
 ,p_drr_attribute13                in varchar2
 ,p_drr_attribute14                in varchar2
 ,p_drr_attribute15                in varchar2
 ,p_drr_attribute16                in varchar2
 ,p_drr_attribute17                in varchar2
 ,p_drr_attribute18                in varchar2
 ,p_drr_attribute19                in varchar2
 ,p_drr_attribute20                in varchar2
 ,p_drr_attribute21                in varchar2
 ,p_drr_attribute22                in varchar2
 ,p_drr_attribute23                in varchar2
 ,p_drr_attribute24                in varchar2
 ,p_drr_attribute25                in varchar2
 ,p_drr_attribute26                in varchar2
 ,p_drr_attribute27                in varchar2
 ,p_drr_attribute28                in varchar2
 ,p_drr_attribute29                in varchar2
 ,p_drr_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_rlshp_typ_cd_o                 in varchar2
 ,p_dsgn_rqmt_id_o                 in number
 ,p_business_group_id_o            in number
 ,p_drr_attribute_category_o       in varchar2
 ,p_drr_attribute1_o               in varchar2
 ,p_drr_attribute2_o               in varchar2
 ,p_drr_attribute3_o               in varchar2
 ,p_drr_attribute4_o               in varchar2
 ,p_drr_attribute5_o               in varchar2
 ,p_drr_attribute6_o               in varchar2
 ,p_drr_attribute7_o               in varchar2
 ,p_drr_attribute8_o               in varchar2
 ,p_drr_attribute9_o               in varchar2
 ,p_drr_attribute10_o              in varchar2
 ,p_drr_attribute11_o              in varchar2
 ,p_drr_attribute12_o              in varchar2
 ,p_drr_attribute13_o              in varchar2
 ,p_drr_attribute14_o              in varchar2
 ,p_drr_attribute15_o              in varchar2
 ,p_drr_attribute16_o              in varchar2
 ,p_drr_attribute17_o              in varchar2
 ,p_drr_attribute18_o              in varchar2
 ,p_drr_attribute19_o              in varchar2
 ,p_drr_attribute20_o              in varchar2
 ,p_drr_attribute21_o              in varchar2
 ,p_drr_attribute22_o              in varchar2
 ,p_drr_attribute23_o              in varchar2
 ,p_drr_attribute24_o              in varchar2
 ,p_drr_attribute25_o              in varchar2
 ,p_drr_attribute26_o              in varchar2
 ,p_drr_attribute27_o              in varchar2
 ,p_drr_attribute28_o              in varchar2
 ,p_drr_attribute29_o              in varchar2
 ,p_drr_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_drr_rku;

 

/
