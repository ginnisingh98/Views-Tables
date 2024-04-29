--------------------------------------------------------
--  DDL for Package BEN_RRB_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_RRB_RKU" AUTHID CURRENT_USER as
/* $Header: berrbrhi.pkh 120.0.12010000.1 2008/07/29 13:02:04 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_regn_for_regy_body_id          in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_regn_admin_cd                  in varchar2
 ,p_regn_id                        in number
 ,p_organization_id                in number
 ,p_business_group_id              in number
 ,p_rrb_attribute_category         in varchar2
 ,p_rrb_attribute1                 in varchar2
 ,p_rrb_attribute2                 in varchar2
 ,p_rrb_attribute3                 in varchar2
 ,p_rrb_attribute4                 in varchar2
 ,p_rrb_attribute5                 in varchar2
 ,p_rrb_attribute6                 in varchar2
 ,p_rrb_attribute7                 in varchar2
 ,p_rrb_attribute8                 in varchar2
 ,p_rrb_attribute9                 in varchar2
 ,p_rrb_attribute10                in varchar2
 ,p_rrb_attribute11                in varchar2
 ,p_rrb_attribute12                in varchar2
 ,p_rrb_attribute13                in varchar2
 ,p_rrb_attribute14                in varchar2
 ,p_rrb_attribute15                in varchar2
 ,p_rrb_attribute16                in varchar2
 ,p_rrb_attribute17                in varchar2
 ,p_rrb_attribute18                in varchar2
 ,p_rrb_attribute19                in varchar2
 ,p_rrb_attribute20                in varchar2
 ,p_rrb_attribute21                in varchar2
 ,p_rrb_attribute22                in varchar2
 ,p_rrb_attribute23                in varchar2
 ,p_rrb_attribute24                in varchar2
 ,p_rrb_attribute25                in varchar2
 ,p_rrb_attribute26                in varchar2
 ,p_rrb_attribute27                in varchar2
 ,p_rrb_attribute28                in varchar2
 ,p_rrb_attribute29                in varchar2
 ,p_rrb_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_regn_admin_cd_o                in varchar2
 ,p_regn_id_o                      in number
 ,p_organization_id_o              in number
 ,p_business_group_id_o            in number
 ,p_rrb_attribute_category_o       in varchar2
 ,p_rrb_attribute1_o               in varchar2
 ,p_rrb_attribute2_o               in varchar2
 ,p_rrb_attribute3_o               in varchar2
 ,p_rrb_attribute4_o               in varchar2
 ,p_rrb_attribute5_o               in varchar2
 ,p_rrb_attribute6_o               in varchar2
 ,p_rrb_attribute7_o               in varchar2
 ,p_rrb_attribute8_o               in varchar2
 ,p_rrb_attribute9_o               in varchar2
 ,p_rrb_attribute10_o              in varchar2
 ,p_rrb_attribute11_o              in varchar2
 ,p_rrb_attribute12_o              in varchar2
 ,p_rrb_attribute13_o              in varchar2
 ,p_rrb_attribute14_o              in varchar2
 ,p_rrb_attribute15_o              in varchar2
 ,p_rrb_attribute16_o              in varchar2
 ,p_rrb_attribute17_o              in varchar2
 ,p_rrb_attribute18_o              in varchar2
 ,p_rrb_attribute19_o              in varchar2
 ,p_rrb_attribute20_o              in varchar2
 ,p_rrb_attribute21_o              in varchar2
 ,p_rrb_attribute22_o              in varchar2
 ,p_rrb_attribute23_o              in varchar2
 ,p_rrb_attribute24_o              in varchar2
 ,p_rrb_attribute25_o              in varchar2
 ,p_rrb_attribute26_o              in varchar2
 ,p_rrb_attribute27_o              in varchar2
 ,p_rrb_attribute28_o              in varchar2
 ,p_rrb_attribute29_o              in varchar2
 ,p_rrb_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_rrb_rku;

/
