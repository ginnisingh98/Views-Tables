--------------------------------------------------------
--  DDL for Package BEN_ELIGIBILITY_RULE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIGIBILITY_RULE_BK1" AUTHID CURRENT_USER as
/* $Header: becerapi.pkh 120.0 2005/05/28 01:00:35 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ELIGIBILITY_RULE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELIGIBILITY_RULE_b
  (
   p_business_group_id              in  number
  ,p_prtn_elig_id                   in  number
  ,p_formula_id                     in  number
  ,p_drvbl_fctr_apls_flag           in  varchar2
  ,p_mndtry_flag                    in  varchar2
  ,p_ordr_to_aply_num               in  number
  ,p_cer_attribute_category         in  varchar2
  ,p_cer_attribute1                 in  varchar2
  ,p_cer_attribute2                 in  varchar2
  ,p_cer_attribute3                 in  varchar2
  ,p_cer_attribute4                 in  varchar2
  ,p_cer_attribute5                 in  varchar2
  ,p_cer_attribute6                 in  varchar2
  ,p_cer_attribute7                 in  varchar2
  ,p_cer_attribute8                 in  varchar2
  ,p_cer_attribute9                 in  varchar2
  ,p_cer_attribute10                in  varchar2
  ,p_cer_attribute11                in  varchar2
  ,p_cer_attribute12                in  varchar2
  ,p_cer_attribute13                in  varchar2
  ,p_cer_attribute14                in  varchar2
  ,p_cer_attribute15                in  varchar2
  ,p_cer_attribute16                in  varchar2
  ,p_cer_attribute17                in  varchar2
  ,p_cer_attribute18                in  varchar2
  ,p_cer_attribute19                in  varchar2
  ,p_cer_attribute20                in  varchar2
  ,p_cer_attribute21                in  varchar2
  ,p_cer_attribute22                in  varchar2
  ,p_cer_attribute23                in  varchar2
  ,p_cer_attribute24                in  varchar2
  ,p_cer_attribute25                in  varchar2
  ,p_cer_attribute26                in  varchar2
  ,p_cer_attribute27                in  varchar2
  ,p_cer_attribute28                in  varchar2
  ,p_cer_attribute29                in  varchar2
  ,p_cer_attribute30                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ELIGIBILITY_RULE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELIGIBILITY_RULE_a
  (
   p_prtn_eligy_rl_id               in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_prtn_elig_id                   in  number
  ,p_formula_id                     in  number
  ,p_drvbl_fctr_apls_flag           in  varchar2
  ,p_mndtry_flag                    in  varchar2
  ,p_ordr_to_aply_num               in  number
  ,p_cer_attribute_category         in  varchar2
  ,p_cer_attribute1                 in  varchar2
  ,p_cer_attribute2                 in  varchar2
  ,p_cer_attribute3                 in  varchar2
  ,p_cer_attribute4                 in  varchar2
  ,p_cer_attribute5                 in  varchar2
  ,p_cer_attribute6                 in  varchar2
  ,p_cer_attribute7                 in  varchar2
  ,p_cer_attribute8                 in  varchar2
  ,p_cer_attribute9                 in  varchar2
  ,p_cer_attribute10                in  varchar2
  ,p_cer_attribute11                in  varchar2
  ,p_cer_attribute12                in  varchar2
  ,p_cer_attribute13                in  varchar2
  ,p_cer_attribute14                in  varchar2
  ,p_cer_attribute15                in  varchar2
  ,p_cer_attribute16                in  varchar2
  ,p_cer_attribute17                in  varchar2
  ,p_cer_attribute18                in  varchar2
  ,p_cer_attribute19                in  varchar2
  ,p_cer_attribute20                in  varchar2
  ,p_cer_attribute21                in  varchar2
  ,p_cer_attribute22                in  varchar2
  ,p_cer_attribute23                in  varchar2
  ,p_cer_attribute24                in  varchar2
  ,p_cer_attribute25                in  varchar2
  ,p_cer_attribute26                in  varchar2
  ,p_cer_attribute27                in  varchar2
  ,p_cer_attribute28                in  varchar2
  ,p_cer_attribute29                in  varchar2
  ,p_cer_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_ELIGIBILITY_RULE_bk1;

 

/
