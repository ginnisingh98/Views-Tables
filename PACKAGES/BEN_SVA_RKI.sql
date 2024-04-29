--------------------------------------------------------
--  DDL for Package BEN_SVA_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_SVA_RKI" AUTHID CURRENT_USER as
/* $Header: besvarhi.pkh 120.0.12010000.1 2008/07/29 13:04:36 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
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
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_sva_rki;

/
