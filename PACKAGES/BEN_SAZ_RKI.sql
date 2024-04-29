--------------------------------------------------------
--  DDL for Package BEN_SAZ_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_SAZ_RKI" AUTHID CURRENT_USER as
/* $Header: besazrhi.pkh 120.0.12010000.1 2008/07/29 13:03:39 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_svc_area_pstl_zip_rng_id       in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_svc_area_id                    in number
 ,p_pstl_zip_rng_id                in number
 ,p_business_group_id              in number
 ,p_saz_attribute_category         in varchar2
 ,p_saz_attribute1                 in varchar2
 ,p_saz_attribute2                 in varchar2
 ,p_saz_attribute3                 in varchar2
 ,p_saz_attribute4                 in varchar2
 ,p_saz_attribute5                 in varchar2
 ,p_saz_attribute6                 in varchar2
 ,p_saz_attribute7                 in varchar2
 ,p_saz_attribute8                 in varchar2
 ,p_saz_attribute9                 in varchar2
 ,p_saz_attribute10                in varchar2
 ,p_saz_attribute11                in varchar2
 ,p_saz_attribute12                in varchar2
 ,p_saz_attribute13                in varchar2
 ,p_saz_attribute14                in varchar2
 ,p_saz_attribute15                in varchar2
 ,p_saz_attribute16                in varchar2
 ,p_saz_attribute17                in varchar2
 ,p_saz_attribute18                in varchar2
 ,p_saz_attribute19                in varchar2
 ,p_saz_attribute20                in varchar2
 ,p_saz_attribute21                in varchar2
 ,p_saz_attribute22                in varchar2
 ,p_saz_attribute23                in varchar2
 ,p_saz_attribute24                in varchar2
 ,p_saz_attribute25                in varchar2
 ,p_saz_attribute26                in varchar2
 ,p_saz_attribute27                in varchar2
 ,p_saz_attribute28                in varchar2
 ,p_saz_attribute29                in varchar2
 ,p_saz_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_saz_rki;

/
