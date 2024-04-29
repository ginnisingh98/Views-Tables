--------------------------------------------------------
--  DDL for Package BEN_EMP_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EMP_RKI" AUTHID CURRENT_USER as
/* $Header: beemprhi.pkh 120.0 2005/05/28 02:25:57 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_elig_mrtl_sts_prte_id         in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_excld_flag                     in varchar2
 ,p_marital_status                 in varchar2
 ,p_eligy_prfl_id                  in number
 ,p_business_group_id              in number
 ,p_emp_attribute_category         in varchar2
 ,p_emp_attribute1                 in varchar2
 ,p_emp_attribute2                 in varchar2
 ,p_emp_attribute3                 in varchar2
 ,p_emp_attribute4                 in varchar2
 ,p_emp_attribute5                 in varchar2
 ,p_emp_attribute6                 in varchar2
 ,p_emp_attribute7                 in varchar2
 ,p_emp_attribute8                 in varchar2
 ,p_emp_attribute9                 in varchar2
 ,p_emp_attribute10                in varchar2
 ,p_emp_attribute11                in varchar2
 ,p_emp_attribute12                in varchar2
 ,p_emp_attribute13                in varchar2
 ,p_emp_attribute14                in varchar2
 ,p_emp_attribute15                in varchar2
 ,p_emp_attribute16                in varchar2
 ,p_emp_attribute17                in varchar2
 ,p_emp_attribute18                in varchar2
 ,p_emp_attribute19                in varchar2
 ,p_emp_attribute20                in varchar2
 ,p_emp_attribute21                in varchar2
 ,p_emp_attribute22                in varchar2
 ,p_emp_attribute23                in varchar2
 ,p_emp_attribute24                in varchar2
 ,p_emp_attribute25                in varchar2
 ,p_emp_attribute26                in varchar2
 ,p_emp_attribute27                in varchar2
 ,p_emp_attribute28                in varchar2
 ,p_emp_attribute29                in varchar2
 ,p_emp_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_criteria_score                 in number
 ,p_criteria_weight                in  number
  );
end ben_emp_rki;

 

/
