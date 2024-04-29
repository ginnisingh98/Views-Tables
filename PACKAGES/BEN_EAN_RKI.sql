--------------------------------------------------------
--  DDL for Package BEN_EAN_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EAN_RKI" AUTHID CURRENT_USER as
/* $Header: beeanrhi.pkh 120.0 2005/05/28 01:43:41 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_elig_asnt_set_prte_id          in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_assignment_set_id              in number
 ,p_ordr_num                       in number
 ,p_eligy_prfl_id                  in number
 ,p_excld_flag                     in varchar2
 ,p_ean_attribute_category         in varchar2
 ,p_ean_attribute1                 in varchar2
 ,p_ean_attribute2                 in varchar2
 ,p_ean_attribute3                 in varchar2
 ,p_ean_attribute4                 in varchar2
 ,p_ean_attribute5                 in varchar2
 ,p_ean_attribute6                 in varchar2
 ,p_ean_attribute7                 in varchar2
 ,p_ean_attribute8                 in varchar2
 ,p_ean_attribute9                 in varchar2
 ,p_ean_attribute10                in varchar2
 ,p_ean_attribute11                in varchar2
 ,p_ean_attribute12                in varchar2
 ,p_ean_attribute13                in varchar2
 ,p_ean_attribute14                in varchar2
 ,p_ean_attribute15                in varchar2
 ,p_ean_attribute16                in varchar2
 ,p_ean_attribute17                in varchar2
 ,p_ean_attribute18                in varchar2
 ,p_ean_attribute19                in varchar2
 ,p_ean_attribute20                in varchar2
 ,p_ean_attribute21                in varchar2
 ,p_ean_attribute22                in varchar2
 ,p_ean_attribute23                in varchar2
 ,p_ean_attribute24                in varchar2
 ,p_ean_attribute25                in varchar2
 ,p_ean_attribute26                in varchar2
 ,p_ean_attribute27                in varchar2
 ,p_ean_attribute28                in varchar2
 ,p_ean_attribute29                in varchar2
 ,p_ean_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_criteria_score                 in number
 ,p_criteria_weight                in  number
  );
end ben_ean_rki;

 

/