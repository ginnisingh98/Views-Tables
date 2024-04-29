--------------------------------------------------------
--  DDL for Package BEN_ELIG_CBR_QUALD_BNF_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_CBR_QUALD_BNF_BK1" AUTHID CURRENT_USER as
/* $Header: beecqapi.pkh 120.0 2005/05/28 01:52:08 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ELIG_CBR_QUALD_BNF_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELIG_CBR_QUALD_BNF_b
  (
   p_quald_bnf_flag                 in  varchar2
  ,p_ordr_num                       in  number
  ,p_eligy_prfl_id                  in  number
  ,p_pgm_id                         in  number
  ,p_ptip_id                        in  number
  ,p_business_group_id              in  number
  ,p_ecq_attribute_category         in  varchar2
  ,p_ecq_attribute1                 in  varchar2
  ,p_ecq_attribute2                 in  varchar2
  ,p_ecq_attribute3                 in  varchar2
  ,p_ecq_attribute4                 in  varchar2
  ,p_ecq_attribute5                 in  varchar2
  ,p_ecq_attribute6                 in  varchar2
  ,p_ecq_attribute7                 in  varchar2
  ,p_ecq_attribute8                 in  varchar2
  ,p_ecq_attribute9                 in  varchar2
  ,p_ecq_attribute10                in  varchar2
  ,p_ecq_attribute11                in  varchar2
  ,p_ecq_attribute12                in  varchar2
  ,p_ecq_attribute13                in  varchar2
  ,p_ecq_attribute14                in  varchar2
  ,p_ecq_attribute15                in  varchar2
  ,p_ecq_attribute16                in  varchar2
  ,p_ecq_attribute17                in  varchar2
  ,p_ecq_attribute18                in  varchar2
  ,p_ecq_attribute19                in  varchar2
  ,p_ecq_attribute20                in  varchar2
  ,p_ecq_attribute21                in  varchar2
  ,p_ecq_attribute22                in  varchar2
  ,p_ecq_attribute23                in  varchar2
  ,p_ecq_attribute24                in  varchar2
  ,p_ecq_attribute25                in  varchar2
  ,p_ecq_attribute26                in  varchar2
  ,p_ecq_attribute27                in  varchar2
  ,p_ecq_attribute28                in  varchar2
  ,p_ecq_attribute29                in  varchar2
  ,p_ecq_attribute30                in  varchar2
  ,p_effective_date                 in  date
  ,p_criteria_score                in number
  ,p_criteria_weight               in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ELIG_CBR_QUALD_BNF_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELIG_CBR_QUALD_BNF_a
  (
   p_elig_cbr_quald_bnf_id          in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_quald_bnf_flag                 in  varchar2
  ,p_ordr_num                       in  number
  ,p_eligy_prfl_id                  in  number
  ,p_pgm_id                         in  number
  ,p_ptip_id                        in  number
  ,p_business_group_id              in  number
  ,p_ecq_attribute_category         in  varchar2
  ,p_ecq_attribute1                 in  varchar2
  ,p_ecq_attribute2                 in  varchar2
  ,p_ecq_attribute3                 in  varchar2
  ,p_ecq_attribute4                 in  varchar2
  ,p_ecq_attribute5                 in  varchar2
  ,p_ecq_attribute6                 in  varchar2
  ,p_ecq_attribute7                 in  varchar2
  ,p_ecq_attribute8                 in  varchar2
  ,p_ecq_attribute9                 in  varchar2
  ,p_ecq_attribute10                in  varchar2
  ,p_ecq_attribute11                in  varchar2
  ,p_ecq_attribute12                in  varchar2
  ,p_ecq_attribute13                in  varchar2
  ,p_ecq_attribute14                in  varchar2
  ,p_ecq_attribute15                in  varchar2
  ,p_ecq_attribute16                in  varchar2
  ,p_ecq_attribute17                in  varchar2
  ,p_ecq_attribute18                in  varchar2
  ,p_ecq_attribute19                in  varchar2
  ,p_ecq_attribute20                in  varchar2
  ,p_ecq_attribute21                in  varchar2
  ,p_ecq_attribute22                in  varchar2
  ,p_ecq_attribute23                in  varchar2
  ,p_ecq_attribute24                in  varchar2
  ,p_ecq_attribute25                in  varchar2
  ,p_ecq_attribute26                in  varchar2
  ,p_ecq_attribute27                in  varchar2
  ,p_ecq_attribute28                in  varchar2
  ,p_ecq_attribute29                in  varchar2
  ,p_ecq_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_criteria_score                in number
  ,p_criteria_weight               in  number
  );
--
end ben_ELIG_CBR_QUALD_BNF_bk1;

 

/
