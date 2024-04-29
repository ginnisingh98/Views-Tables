--------------------------------------------------------
--  DDL for Package BEN_ECP_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ECP_RKI" AUTHID CURRENT_USER as
/* $Header: beecprhi.pkh 120.0 2005/05/28 01:51:40 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_elig_cmbn_age_los_prte_id      in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_cmbn_age_los_fctr_id           in number
 ,p_eligy_prfl_id                  in number
 ,p_excld_flag                     in varchar2
 ,p_ordr_num                       in number
 ,p_mndtry_flag                    in varchar2
 ,p_ecp_attribute_category         in varchar2
 ,p_ecp_attribute1                 in varchar2
 ,p_ecp_attribute2                 in varchar2
 ,p_ecp_attribute3                 in varchar2
 ,p_ecp_attribute4                 in varchar2
 ,p_ecp_attribute5                 in varchar2
 ,p_ecp_attribute6                 in varchar2
 ,p_ecp_attribute7                 in varchar2
 ,p_ecp_attribute8                 in varchar2
 ,p_ecp_attribute9                 in varchar2
 ,p_ecp_attribute10                in varchar2
 ,p_ecp_attribute11                in varchar2
 ,p_ecp_attribute12                in varchar2
 ,p_ecp_attribute13                in varchar2
 ,p_ecp_attribute14                in varchar2
 ,p_ecp_attribute15                in varchar2
 ,p_ecp_attribute16                in varchar2
 ,p_ecp_attribute17                in varchar2
 ,p_ecp_attribute18                in varchar2
 ,p_ecp_attribute19                in varchar2
 ,p_ecp_attribute20                in varchar2
 ,p_ecp_attribute21                in varchar2
 ,p_ecp_attribute22                in varchar2
 ,p_ecp_attribute23                in varchar2
 ,p_ecp_attribute24                in varchar2
 ,p_ecp_attribute25                in varchar2
 ,p_ecp_attribute26                in varchar2
 ,p_ecp_attribute27                in varchar2
 ,p_ecp_attribute28                in varchar2
 ,p_ecp_attribute29                in varchar2
 ,p_ecp_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_criteria_score                 in number
 ,p_criteria_weight                in  number
  );
end ben_ecp_rki;

 

/
