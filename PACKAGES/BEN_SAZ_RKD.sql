--------------------------------------------------------
--  DDL for Package BEN_SAZ_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_SAZ_RKD" AUTHID CURRENT_USER as
/* $Header: besazrhi.pkh 120.0.12010000.1 2008/07/29 13:03:39 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_svc_area_pstl_zip_rng_id       in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_svc_area_id_o                  in number
 ,p_pstl_zip_rng_id_o              in number
 ,p_business_group_id_o            in number
 ,p_saz_attribute_category_o       in varchar2
 ,p_saz_attribute1_o               in varchar2
 ,p_saz_attribute2_o               in varchar2
 ,p_saz_attribute3_o               in varchar2
 ,p_saz_attribute4_o               in varchar2
 ,p_saz_attribute5_o               in varchar2
 ,p_saz_attribute6_o               in varchar2
 ,p_saz_attribute7_o               in varchar2
 ,p_saz_attribute8_o               in varchar2
 ,p_saz_attribute9_o               in varchar2
 ,p_saz_attribute10_o              in varchar2
 ,p_saz_attribute11_o              in varchar2
 ,p_saz_attribute12_o              in varchar2
 ,p_saz_attribute13_o              in varchar2
 ,p_saz_attribute14_o              in varchar2
 ,p_saz_attribute15_o              in varchar2
 ,p_saz_attribute16_o              in varchar2
 ,p_saz_attribute17_o              in varchar2
 ,p_saz_attribute18_o              in varchar2
 ,p_saz_attribute19_o              in varchar2
 ,p_saz_attribute20_o              in varchar2
 ,p_saz_attribute21_o              in varchar2
 ,p_saz_attribute22_o              in varchar2
 ,p_saz_attribute23_o              in varchar2
 ,p_saz_attribute24_o              in varchar2
 ,p_saz_attribute25_o              in varchar2
 ,p_saz_attribute26_o              in varchar2
 ,p_saz_attribute27_o              in varchar2
 ,p_saz_attribute28_o              in varchar2
 ,p_saz_attribute29_o              in varchar2
 ,p_saz_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_saz_rkd;

/
