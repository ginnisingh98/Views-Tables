--------------------------------------------------------
--  DDL for Package BEN_ELIGY_PROFILE_RULE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIGY_PROFILE_RULE_BK2" AUTHID CURRENT_USER as
/* $Header: beerlapi.pkh 120.0 2005/05/28 02:52:05 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ELIGY_PROFILE_RULE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIGY_PROFILE_RULE_b
  (
   p_eligy_prfl_rl_id               in  number
  ,p_ordr_to_aply_num               in  number
  ,p_formula_id                     in  number
  ,p_eligy_prfl_id                  in  number
  ,p_drvbl_fctr_apls_flag           in  varchar2
  ,p_business_group_id              in  number
  ,p_erl_attribute_category         in  varchar2
  ,p_erl_attribute1                 in  varchar2
  ,p_erl_attribute2                 in  varchar2
  ,p_erl_attribute3                 in  varchar2
  ,p_erl_attribute4                 in  varchar2
  ,p_erl_attribute5                 in  varchar2
  ,p_erl_attribute6                 in  varchar2
  ,p_erl_attribute7                 in  varchar2
  ,p_erl_attribute8                 in  varchar2
  ,p_erl_attribute9                 in  varchar2
  ,p_erl_attribute10                in  varchar2
  ,p_erl_attribute11                in  varchar2
  ,p_erl_attribute12                in  varchar2
  ,p_erl_attribute13                in  varchar2
  ,p_erl_attribute14                in  varchar2
  ,p_erl_attribute15                in  varchar2
  ,p_erl_attribute17                in  varchar2
  ,p_erl_attribute16                in  varchar2
  ,p_erl_attribute18                in  varchar2
  ,p_erl_attribute19                in  varchar2
  ,p_erl_attribute20                in  varchar2
  ,p_erl_attribute21                in  varchar2
  ,p_erl_attribute22                in  varchar2
  ,p_erl_attribute23                in  varchar2
  ,p_erl_attribute24                in  varchar2
  ,p_erl_attribute25                in  varchar2
  ,p_erl_attribute26                in  varchar2
  ,p_erl_attribute27                in  varchar2
  ,p_erl_attribute28                in  varchar2
  ,p_erl_attribute29                in  varchar2
  ,p_erl_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_criteria_score                in number
  ,p_criteria_weight               in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ELIGY_PROFILE_RULE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIGY_PROFILE_RULE_a
  (
   p_eligy_prfl_rl_id               in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_ordr_to_aply_num               in  number
  ,p_formula_id                     in  number
  ,p_eligy_prfl_id                  in  number
  ,p_drvbl_fctr_apls_flag           in  varchar2
  ,p_business_group_id              in  number
  ,p_erl_attribute_category         in  varchar2
  ,p_erl_attribute1                 in  varchar2
  ,p_erl_attribute2                 in  varchar2
  ,p_erl_attribute3                 in  varchar2
  ,p_erl_attribute4                 in  varchar2
  ,p_erl_attribute5                 in  varchar2
  ,p_erl_attribute6                 in  varchar2
  ,p_erl_attribute7                 in  varchar2
  ,p_erl_attribute8                 in  varchar2
  ,p_erl_attribute9                 in  varchar2
  ,p_erl_attribute10                in  varchar2
  ,p_erl_attribute11                in  varchar2
  ,p_erl_attribute12                in  varchar2
  ,p_erl_attribute13                in  varchar2
  ,p_erl_attribute14                in  varchar2
  ,p_erl_attribute15                in  varchar2
  ,p_erl_attribute17                in  varchar2
  ,p_erl_attribute16                in  varchar2
  ,p_erl_attribute18                in  varchar2
  ,p_erl_attribute19                in  varchar2
  ,p_erl_attribute20                in  varchar2
  ,p_erl_attribute21                in  varchar2
  ,p_erl_attribute22                in  varchar2
  ,p_erl_attribute23                in  varchar2
  ,p_erl_attribute24                in  varchar2
  ,p_erl_attribute25                in  varchar2
  ,p_erl_attribute26                in  varchar2
  ,p_erl_attribute27                in  varchar2
  ,p_erl_attribute28                in  varchar2
  ,p_erl_attribute29                in  varchar2
  ,p_erl_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_criteria_score                in number
  ,p_criteria_weight               in  number
  );
--
end ben_ELIGY_PROFILE_RULE_bk2;

 

/
