--------------------------------------------------------
--  DDL for Package BEN_CBP_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CBP_RKI" AUTHID CURRENT_USER as
/* $Header: becbprhi.pkh 120.0 2005/05/28 00:55:32 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_cmbn_ptip_id                   in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_name                           in varchar2
 ,p_business_group_id              in number
 ,p_cbp_attribute_category         in varchar2
 ,p_cbp_attribute1                 in varchar2
 ,p_cbp_attribute2                 in varchar2
 ,p_cbp_attribute3                 in varchar2
 ,p_cbp_attribute4                 in varchar2
 ,p_cbp_attribute5                 in varchar2
 ,p_cbp_attribute6                 in varchar2
 ,p_cbp_attribute7                 in varchar2
 ,p_cbp_attribute8                 in varchar2
 ,p_cbp_attribute9                 in varchar2
 ,p_cbp_attribute10                in varchar2
 ,p_cbp_attribute11                in varchar2
 ,p_cbp_attribute12                in varchar2
 ,p_cbp_attribute13                in varchar2
 ,p_cbp_attribute14                in varchar2
 ,p_cbp_attribute15                in varchar2
 ,p_cbp_attribute16                in varchar2
 ,p_cbp_attribute17                in varchar2
 ,p_cbp_attribute18                in varchar2
 ,p_cbp_attribute19                in varchar2
 ,p_cbp_attribute20                in varchar2
 ,p_cbp_attribute21                in varchar2
 ,p_cbp_attribute22                in varchar2
 ,p_cbp_attribute23                in varchar2
 ,p_cbp_attribute24                in varchar2
 ,p_cbp_attribute25                in varchar2
 ,p_cbp_attribute26                in varchar2
 ,p_cbp_attribute27                in varchar2
 ,p_cbp_attribute28                in varchar2
 ,p_cbp_attribute29                in varchar2
 ,p_cbp_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_pgm_id                         in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_cbp_rki;

 

/
