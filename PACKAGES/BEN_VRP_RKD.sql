--------------------------------------------------------
--  DDL for Package BEN_VRP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_VRP_RKD" AUTHID CURRENT_USER as
/* $Header: bevrprhi.pkh 120.0.12010000.1 2008/07/29 13:08:28 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_vald_rlshp_for_reimb_id        in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_pl_id_o                        in number
 ,p_rlshp_typ_cd_o                 in varchar2
 ,p_vrp_attribute_category_o       in varchar2
 ,p_vrp_attribute1_o               in varchar2
 ,p_vrp_attribute2_o               in varchar2
 ,p_vrp_attribute3_o               in varchar2
 ,p_vrp_attribute4_o               in varchar2
 ,p_vrp_attribute5_o               in varchar2
 ,p_vrp_attribute6_o               in varchar2
 ,p_vrp_attribute7_o               in varchar2
 ,p_vrp_attribute8_o               in varchar2
 ,p_vrp_attribute9_o               in varchar2
 ,p_vrp_attribute10_o              in varchar2
 ,p_vrp_attribute11_o              in varchar2
 ,p_vrp_attribute12_o              in varchar2
 ,p_vrp_attribute13_o              in varchar2
 ,p_vrp_attribute14_o              in varchar2
 ,p_vrp_attribute15_o              in varchar2
 ,p_vrp_attribute16_o              in varchar2
 ,p_vrp_attribute17_o              in varchar2
 ,p_vrp_attribute18_o              in varchar2
 ,p_vrp_attribute19_o              in varchar2
 ,p_vrp_attribute20_o              in varchar2
 ,p_vrp_attribute21_o              in varchar2
 ,p_vrp_attribute22_o              in varchar2
 ,p_vrp_attribute23_o              in varchar2
 ,p_vrp_attribute24_o              in varchar2
 ,p_vrp_attribute25_o              in varchar2
 ,p_vrp_attribute26_o              in varchar2
 ,p_vrp_attribute27_o              in varchar2
 ,p_vrp_attribute28_o              in varchar2
 ,p_vrp_attribute29_o              in varchar2
 ,p_vrp_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_vrp_rkd;

/
