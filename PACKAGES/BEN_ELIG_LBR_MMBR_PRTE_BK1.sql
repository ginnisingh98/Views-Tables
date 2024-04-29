--------------------------------------------------------
--  DDL for Package BEN_ELIG_LBR_MMBR_PRTE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_LBR_MMBR_PRTE_BK1" AUTHID CURRENT_USER as
/* $Header: beeluapi.pkh 120.0 2005/05/28 02:22:52 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ELIG_LBR_MMBR_PRTE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELIG_LBR_MMBR_PRTE_b
  (
   p_eligy_prfl_id                  in  number
  ,p_excld_flag                     in  varchar2
  ,p_lbr_mmbr_flag                  in  varchar2
  ,p_ordr_num                       in  number
  ,p_business_group_id              in  number
  ,p_elu_attribute_category         in  varchar2
  ,p_elu_attribute1                 in  varchar2
  ,p_elu_attribute2                 in  varchar2
  ,p_elu_attribute3                 in  varchar2
  ,p_elu_attribute4                 in  varchar2
  ,p_elu_attribute5                 in  varchar2
  ,p_elu_attribute6                 in  varchar2
  ,p_elu_attribute7                 in  varchar2
  ,p_elu_attribute8                 in  varchar2
  ,p_elu_attribute9                 in  varchar2
  ,p_elu_attribute10                in  varchar2
  ,p_elu_attribute11                in  varchar2
  ,p_elu_attribute12                in  varchar2
  ,p_elu_attribute13                in  varchar2
  ,p_elu_attribute14                in  varchar2
  ,p_elu_attribute15                in  varchar2
  ,p_elu_attribute16                in  varchar2
  ,p_elu_attribute17                in  varchar2
  ,p_elu_attribute18                in  varchar2
  ,p_elu_attribute19                in  varchar2
  ,p_elu_attribute20                in  varchar2
  ,p_elu_attribute21                in  varchar2
  ,p_elu_attribute22                in  varchar2
  ,p_elu_attribute23                in  varchar2
  ,p_elu_attribute24                in  varchar2
  ,p_elu_attribute25                in  varchar2
  ,p_elu_attribute26                in  varchar2
  ,p_elu_attribute27                in  varchar2
  ,p_elu_attribute28                in  varchar2
  ,p_elu_attribute29                in  varchar2
  ,p_elu_attribute30                in  varchar2
  ,p_effective_date                 in  date
  ,p_criteria_score                in number
  ,p_criteria_weight               in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ELIG_LBR_MMBR_PRTE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELIG_LBR_MMBR_PRTE_a
  (
   p_elig_lbr_mmbr_prte_id          in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_eligy_prfl_id                  in  number
  ,p_excld_flag                     in  varchar2
  ,p_lbr_mmbr_flag                  in  varchar2
  ,p_ordr_num                       in  number
  ,p_business_group_id              in  number
  ,p_elu_attribute_category         in  varchar2
  ,p_elu_attribute1                 in  varchar2
  ,p_elu_attribute2                 in  varchar2
  ,p_elu_attribute3                 in  varchar2
  ,p_elu_attribute4                 in  varchar2
  ,p_elu_attribute5                 in  varchar2
  ,p_elu_attribute6                 in  varchar2
  ,p_elu_attribute7                 in  varchar2
  ,p_elu_attribute8                 in  varchar2
  ,p_elu_attribute9                 in  varchar2
  ,p_elu_attribute10                in  varchar2
  ,p_elu_attribute11                in  varchar2
  ,p_elu_attribute12                in  varchar2
  ,p_elu_attribute13                in  varchar2
  ,p_elu_attribute14                in  varchar2
  ,p_elu_attribute15                in  varchar2
  ,p_elu_attribute16                in  varchar2
  ,p_elu_attribute17                in  varchar2
  ,p_elu_attribute18                in  varchar2
  ,p_elu_attribute19                in  varchar2
  ,p_elu_attribute20                in  varchar2
  ,p_elu_attribute21                in  varchar2
  ,p_elu_attribute22                in  varchar2
  ,p_elu_attribute23                in  varchar2
  ,p_elu_attribute24                in  varchar2
  ,p_elu_attribute25                in  varchar2
  ,p_elu_attribute26                in  varchar2
  ,p_elu_attribute27                in  varchar2
  ,p_elu_attribute28                in  varchar2
  ,p_elu_attribute29                in  varchar2
  ,p_elu_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_criteria_score                in number
  ,p_criteria_weight               in  number
  );
--
end ben_ELIG_LBR_MMBR_PRTE_bk1;

 

/
