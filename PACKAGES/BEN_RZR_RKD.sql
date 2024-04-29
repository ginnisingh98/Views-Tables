--------------------------------------------------------
--  DDL for Package BEN_RZR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_RZR_RKD" AUTHID CURRENT_USER as
/* $Header: berzrrhi.pkh 120.0.12010000.1 2008/07/29 13:03:06 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_pstl_zip_rng_id                in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
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
end ben_rzr_rkd;

/
