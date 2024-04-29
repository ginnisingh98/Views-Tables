--------------------------------------------------------
--  DDL for Package BEN_CPL_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CPL_RKI" AUTHID CURRENT_USER as
/* $Header: becplrhi.pkh 120.0 2005/05/28 01:14:38 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_cmbn_plip_id                   in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_name                           in varchar2
 ,p_business_group_id              in number
 ,p_cpl_attribute_category         in varchar2
 ,p_cpl_attribute1                 in varchar2
 ,p_cpl_attribute2                 in varchar2
 ,p_cpl_attribute3                 in varchar2
 ,p_cpl_attribute4                 in varchar2
 ,p_cpl_attribute5                 in varchar2
 ,p_cpl_attribute6                 in varchar2
 ,p_cpl_attribute7                 in varchar2
 ,p_cpl_attribute8                 in varchar2
 ,p_cpl_attribute9                 in varchar2
 ,p_cpl_attribute10                in varchar2
 ,p_cpl_attribute11                in varchar2
 ,p_cpl_attribute12                in varchar2
 ,p_cpl_attribute13                in varchar2
 ,p_cpl_attribute14                in varchar2
 ,p_cpl_attribute15                in varchar2
 ,p_cpl_attribute16                in varchar2
 ,p_cpl_attribute17                in varchar2
 ,p_cpl_attribute18                in varchar2
 ,p_cpl_attribute19                in varchar2
 ,p_cpl_attribute20                in varchar2
 ,p_cpl_attribute21                in varchar2
 ,p_cpl_attribute22                in varchar2
 ,p_cpl_attribute23                in varchar2
 ,p_cpl_attribute24                in varchar2
 ,p_cpl_attribute25                in varchar2
 ,p_cpl_attribute26                in varchar2
 ,p_cpl_attribute27                in varchar2
 ,p_cpl_attribute28                in varchar2
 ,p_cpl_attribute29                in varchar2
 ,p_cpl_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_pgm_id                         in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_cpl_rki;

 

/
