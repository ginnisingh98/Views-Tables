--------------------------------------------------------
--  DDL for Package BEN_ELN_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELN_RKI" AUTHID CURRENT_USER as
/* $Header: beelnrhi.pkh 120.0 2005/05/28 02:19:22 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_elig_lgl_enty_prte_id          in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_ordr_num                       in number
 ,p_excld_flag                     in varchar2
 ,p_organization_id                in number
 ,p_eligy_prfl_id                  in number
 ,p_business_group_id              in number
 ,p_eln_attribute_category         in varchar2
 ,p_eln_attribute1                 in varchar2
 ,p_eln_attribute2                 in varchar2
 ,p_eln_attribute3                 in varchar2
 ,p_eln_attribute4                 in varchar2
 ,p_eln_attribute5                 in varchar2
 ,p_eln_attribute6                 in varchar2
 ,p_eln_attribute7                 in varchar2
 ,p_eln_attribute8                 in varchar2
 ,p_eln_attribute9                 in varchar2
 ,p_eln_attribute10                in varchar2
 ,p_eln_attribute11                in varchar2
 ,p_eln_attribute12                in varchar2
 ,p_eln_attribute13                in varchar2
 ,p_eln_attribute14                in varchar2
 ,p_eln_attribute15                in varchar2
 ,p_eln_attribute16                in varchar2
 ,p_eln_attribute17                in varchar2
 ,p_eln_attribute18                in varchar2
 ,p_eln_attribute19                in varchar2
 ,p_eln_attribute20                in varchar2
 ,p_eln_attribute21                in varchar2
 ,p_eln_attribute22                in varchar2
 ,p_eln_attribute23                in varchar2
 ,p_eln_attribute24                in varchar2
 ,p_eln_attribute25                in varchar2
 ,p_eln_attribute26                in varchar2
 ,p_eln_attribute27                in varchar2
 ,p_eln_attribute28                in varchar2
 ,p_eln_attribute29                in varchar2
 ,p_eln_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_criteria_score                 in number
 ,p_criteria_weight                in  number
  );
end ben_eln_rki;

 

/
