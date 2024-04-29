--------------------------------------------------------
--  DDL for Package BEN_ELIG_ORG_UNIT_PRTE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_ORG_UNIT_PRTE_BK1" AUTHID CURRENT_USER as
/* $Header: beeouapi.pkh 120.0 2005/05/28 02:33:22 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ELIG_ORG_UNIT_PRTE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELIG_ORG_UNIT_PRTE_b
  (
   p_business_group_id              in  number
  ,p_eligy_prfl_id                  in  number
  ,p_organization_id                in  number
  ,p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_eou_attribute_category         in  varchar2
  ,p_eou_attribute1                 in  varchar2
  ,p_eou_attribute2                 in  varchar2
  ,p_eou_attribute3                 in  varchar2
  ,p_eou_attribute4                 in  varchar2
  ,p_eou_attribute5                 in  varchar2
  ,p_eou_attribute6                 in  varchar2
  ,p_eou_attribute7                 in  varchar2
  ,p_eou_attribute8                 in  varchar2
  ,p_eou_attribute9                 in  varchar2
  ,p_eou_attribute10                in  varchar2
  ,p_eou_attribute11                in  varchar2
  ,p_eou_attribute12                in  varchar2
  ,p_eou_attribute13                in  varchar2
  ,p_eou_attribute14                in  varchar2
  ,p_eou_attribute15                in  varchar2
  ,p_eou_attribute16                in  varchar2
  ,p_eou_attribute17                in  varchar2
  ,p_eou_attribute18                in  varchar2
  ,p_eou_attribute19                in  varchar2
  ,p_eou_attribute20                in  varchar2
  ,p_eou_attribute21                in  varchar2
  ,p_eou_attribute22                in  varchar2
  ,p_eou_attribute23                in  varchar2
  ,p_eou_attribute24                in  varchar2
  ,p_eou_attribute25                in  varchar2
  ,p_eou_attribute26                in  varchar2
  ,p_eou_attribute27                in  varchar2
  ,p_eou_attribute28                in  varchar2
  ,p_eou_attribute29                in  varchar2
  ,p_eou_attribute30                in  varchar2
  ,p_effective_date                 in  date
  ,p_criteria_score                in number
  ,p_criteria_weight               in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ELIG_ORG_UNIT_PRTE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELIG_ORG_UNIT_PRTE_a
  (
   p_elig_org_unit_prte_id          in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_eligy_prfl_id                  in  number
  ,p_organization_id                in  number
  ,p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_eou_attribute_category         in  varchar2
  ,p_eou_attribute1                 in  varchar2
  ,p_eou_attribute2                 in  varchar2
  ,p_eou_attribute3                 in  varchar2
  ,p_eou_attribute4                 in  varchar2
  ,p_eou_attribute5                 in  varchar2
  ,p_eou_attribute6                 in  varchar2
  ,p_eou_attribute7                 in  varchar2
  ,p_eou_attribute8                 in  varchar2
  ,p_eou_attribute9                 in  varchar2
  ,p_eou_attribute10                in  varchar2
  ,p_eou_attribute11                in  varchar2
  ,p_eou_attribute12                in  varchar2
  ,p_eou_attribute13                in  varchar2
  ,p_eou_attribute14                in  varchar2
  ,p_eou_attribute15                in  varchar2
  ,p_eou_attribute16                in  varchar2
  ,p_eou_attribute17                in  varchar2
  ,p_eou_attribute18                in  varchar2
  ,p_eou_attribute19                in  varchar2
  ,p_eou_attribute20                in  varchar2
  ,p_eou_attribute21                in  varchar2
  ,p_eou_attribute22                in  varchar2
  ,p_eou_attribute23                in  varchar2
  ,p_eou_attribute24                in  varchar2
  ,p_eou_attribute25                in  varchar2
  ,p_eou_attribute26                in  varchar2
  ,p_eou_attribute27                in  varchar2
  ,p_eou_attribute28                in  varchar2
  ,p_eou_attribute29                in  varchar2
  ,p_eou_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_criteria_score                in number
  ,p_criteria_weight               in  number
  );
--
end ben_ELIG_ORG_UNIT_PRTE_bk1;

 

/
