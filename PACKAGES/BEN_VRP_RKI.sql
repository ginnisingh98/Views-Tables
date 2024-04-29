--------------------------------------------------------
--  DDL for Package BEN_VRP_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_VRP_RKI" AUTHID CURRENT_USER as
/* $Header: bevrprhi.pkh 120.0.12010000.1 2008/07/29 13:08:28 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_vald_rlshp_for_reimb_id        in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_pl_id                          in number
 ,p_rlshp_typ_cd                   in varchar2
 ,p_vrp_attribute_category         in varchar2
 ,p_vrp_attribute1                 in varchar2
 ,p_vrp_attribute2                 in varchar2
 ,p_vrp_attribute3                 in varchar2
 ,p_vrp_attribute4                 in varchar2
 ,p_vrp_attribute5                 in varchar2
 ,p_vrp_attribute6                 in varchar2
 ,p_vrp_attribute7                 in varchar2
 ,p_vrp_attribute8                 in varchar2
 ,p_vrp_attribute9                 in varchar2
 ,p_vrp_attribute10                in varchar2
 ,p_vrp_attribute11                in varchar2
 ,p_vrp_attribute12                in varchar2
 ,p_vrp_attribute13                in varchar2
 ,p_vrp_attribute14                in varchar2
 ,p_vrp_attribute15                in varchar2
 ,p_vrp_attribute16                in varchar2
 ,p_vrp_attribute17                in varchar2
 ,p_vrp_attribute18                in varchar2
 ,p_vrp_attribute19                in varchar2
 ,p_vrp_attribute20                in varchar2
 ,p_vrp_attribute21                in varchar2
 ,p_vrp_attribute22                in varchar2
 ,p_vrp_attribute23                in varchar2
 ,p_vrp_attribute24                in varchar2
 ,p_vrp_attribute25                in varchar2
 ,p_vrp_attribute26                in varchar2
 ,p_vrp_attribute27                in varchar2
 ,p_vrp_attribute28                in varchar2
 ,p_vrp_attribute29                in varchar2
 ,p_vrp_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_vrp_rki;

/
