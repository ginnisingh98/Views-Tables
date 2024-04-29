--------------------------------------------------------
--  DDL for Package BEN_ACTUAL_PREMIUM_RULE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ACTUAL_PREMIUM_RULE_BK1" AUTHID CURRENT_USER as
/* $Header: beavaapi.pkh 120.0 2005/05/28 00:31:34 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_actual_premium_rule_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_actual_premium_rule_b
  (
   p_actl_prem_id                   in  number
  ,p_formula_id                     in  number
  ,p_ordr_to_aply_num               in  number
  ,p_rt_trtmt_cd                    in  varchar2
  ,p_business_group_id              in  number
  ,p_ava_attribute_category         in  varchar2
  ,p_ava_attribute1                 in  varchar2
  ,p_ava_attribute2                 in  varchar2
  ,p_ava_attribute3                 in  varchar2
  ,p_ava_attribute4                 in  varchar2
  ,p_ava_attribute5                 in  varchar2
  ,p_ava_attribute6                 in  varchar2
  ,p_ava_attribute7                 in  varchar2
  ,p_ava_attribute8                 in  varchar2
  ,p_ava_attribute9                 in  varchar2
  ,p_ava_attribute10                in  varchar2
  ,p_ava_attribute11                in  varchar2
  ,p_ava_attribute12                in  varchar2
  ,p_ava_attribute13                in  varchar2
  ,p_ava_attribute14                in  varchar2
  ,p_ava_attribute15                in  varchar2
  ,p_ava_attribute16                in  varchar2
  ,p_ava_attribute17                in  varchar2
  ,p_ava_attribute18                in  varchar2
  ,p_ava_attribute19                in  varchar2
  ,p_ava_attribute20                in  varchar2
  ,p_ava_attribute21                in  varchar2
  ,p_ava_attribute22                in  varchar2
  ,p_ava_attribute23                in  varchar2
  ,p_ava_attribute24                in  varchar2
  ,p_ava_attribute25                in  varchar2
  ,p_ava_attribute26                in  varchar2
  ,p_ava_attribute27                in  varchar2
  ,p_ava_attribute28                in  varchar2
  ,p_ava_attribute29                in  varchar2
  ,p_ava_attribute30                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_actual_premium_rule_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_actual_premium_rule_a
  (
   p_actl_prem_vrbl_rt_rl_id        in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_actl_prem_id                   in  number
  ,p_formula_id                     in  number
  ,p_ordr_to_aply_num               in  number
  ,p_rt_trtmt_cd                    in  varchar2
  ,p_business_group_id              in  number
  ,p_ava_attribute_category         in  varchar2
  ,p_ava_attribute1                 in  varchar2
  ,p_ava_attribute2                 in  varchar2
  ,p_ava_attribute3                 in  varchar2
  ,p_ava_attribute4                 in  varchar2
  ,p_ava_attribute5                 in  varchar2
  ,p_ava_attribute6                 in  varchar2
  ,p_ava_attribute7                 in  varchar2
  ,p_ava_attribute8                 in  varchar2
  ,p_ava_attribute9                 in  varchar2
  ,p_ava_attribute10                in  varchar2
  ,p_ava_attribute11                in  varchar2
  ,p_ava_attribute12                in  varchar2
  ,p_ava_attribute13                in  varchar2
  ,p_ava_attribute14                in  varchar2
  ,p_ava_attribute15                in  varchar2
  ,p_ava_attribute16                in  varchar2
  ,p_ava_attribute17                in  varchar2
  ,p_ava_attribute18                in  varchar2
  ,p_ava_attribute19                in  varchar2
  ,p_ava_attribute20                in  varchar2
  ,p_ava_attribute21                in  varchar2
  ,p_ava_attribute22                in  varchar2
  ,p_ava_attribute23                in  varchar2
  ,p_ava_attribute24                in  varchar2
  ,p_ava_attribute25                in  varchar2
  ,p_ava_attribute26                in  varchar2
  ,p_ava_attribute27                in  varchar2
  ,p_ava_attribute28                in  varchar2
  ,p_ava_attribute29                in  varchar2
  ,p_ava_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_actual_premium_rule_bk1;

 

/
