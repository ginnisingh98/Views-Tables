--------------------------------------------------------
--  DDL for Package BEN_RRB_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_RRB_RKD" AUTHID CURRENT_USER as
/* $Header: berrbrhi.pkh 120.0.12010000.1 2008/07/29 13:02:04 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_regn_for_regy_body_id          in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
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
end ben_rrb_rkd;

/
