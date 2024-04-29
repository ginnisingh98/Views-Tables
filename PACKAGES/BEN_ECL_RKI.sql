--------------------------------------------------------
--  DDL for Package BEN_ECL_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ECL_RKI" AUTHID CURRENT_USER as
/* $Header: beeclrhi.pkh 120.0 2005/05/28 01:50:49 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_elig_comp_lvl_prte_id          in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_comp_lvl_fctr_id               in number
 ,p_eligy_prfl_id                  in number
 ,p_excld_flag                     in varchar2
 ,p_ordr_num                       in number
 ,p_ecl_attribute_category         in varchar2
 ,p_ecl_attribute1                 in varchar2
 ,p_ecl_attribute2                 in varchar2
 ,p_ecl_attribute3                 in varchar2
 ,p_ecl_attribute4                 in varchar2
 ,p_ecl_attribute5                 in varchar2
 ,p_ecl_attribute6                 in varchar2
 ,p_ecl_attribute7                 in varchar2
 ,p_ecl_attribute8                 in varchar2
 ,p_ecl_attribute9                 in varchar2
 ,p_ecl_attribute10                in varchar2
 ,p_ecl_attribute11                in varchar2
 ,p_ecl_attribute12                in varchar2
 ,p_ecl_attribute13                in varchar2
 ,p_ecl_attribute14                in varchar2
 ,p_ecl_attribute15                in varchar2
 ,p_ecl_attribute16                in varchar2
 ,p_ecl_attribute17                in varchar2
 ,p_ecl_attribute18                in varchar2
 ,p_ecl_attribute19                in varchar2
 ,p_ecl_attribute20                in varchar2
 ,p_ecl_attribute21                in varchar2
 ,p_ecl_attribute22                in varchar2
 ,p_ecl_attribute23                in varchar2
 ,p_ecl_attribute24                in varchar2
 ,p_ecl_attribute25                in varchar2
 ,p_ecl_attribute26                in varchar2
 ,p_ecl_attribute27                in varchar2
 ,p_ecl_attribute28                in varchar2
 ,p_ecl_attribute29                in varchar2
 ,p_ecl_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_criteria_score                 in number
 ,p_criteria_weight                in  number
  );
end ben_ecl_rki;

 

/
