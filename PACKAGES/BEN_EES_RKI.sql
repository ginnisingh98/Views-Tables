--------------------------------------------------------
--  DDL for Package BEN_EES_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EES_RKI" AUTHID CURRENT_USER as
/* $Header: beeesrhi.pkh 120.0 2005/05/28 02:06:10 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_elig_ee_stat_prte_id           in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_eligy_prfl_id                  in number
 ,p_excld_flag                     in varchar2
 ,p_ordr_num                       in number
 ,p_assignment_status_type_id      in number
 ,p_ees_attribute_category         in varchar2
 ,p_ees_attribute1                 in varchar2
 ,p_ees_attribute2                 in varchar2
 ,p_ees_attribute3                 in varchar2
 ,p_ees_attribute4                 in varchar2
 ,p_ees_attribute5                 in varchar2
 ,p_ees_attribute6                 in varchar2
 ,p_ees_attribute7                 in varchar2
 ,p_ees_attribute8                 in varchar2
 ,p_ees_attribute9                 in varchar2
 ,p_ees_attribute10                in varchar2
 ,p_ees_attribute11                in varchar2
 ,p_ees_attribute12                in varchar2
 ,p_ees_attribute13                in varchar2
 ,p_ees_attribute14                in varchar2
 ,p_ees_attribute15                in varchar2
 ,p_ees_attribute16                in varchar2
 ,p_ees_attribute17                in varchar2
 ,p_ees_attribute18                in varchar2
 ,p_ees_attribute19                in varchar2
 ,p_ees_attribute20                in varchar2
 ,p_ees_attribute21                in varchar2
 ,p_ees_attribute22                in varchar2
 ,p_ees_attribute23                in varchar2
 ,p_ees_attribute24                in varchar2
 ,p_ees_attribute25                in varchar2
 ,p_ees_attribute26                in varchar2
 ,p_ees_attribute27                in varchar2
 ,p_ees_attribute28                in varchar2
 ,p_ees_attribute29                in varchar2
 ,p_ees_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_criteria_score                 in number
 ,p_criteria_weight                in  number
  );
end ben_ees_rki;

 

/
