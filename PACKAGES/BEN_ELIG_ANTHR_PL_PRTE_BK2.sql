--------------------------------------------------------
--  DDL for Package BEN_ELIG_ANTHR_PL_PRTE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_ANTHR_PL_PRTE_BK2" AUTHID CURRENT_USER as
/* $Header: beeopapi.pkh 120.0 2005/05/28 02:32:35 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ELIG_ANTHR_PL_PRTE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIG_ANTHR_PL_PRTE_b
  (
   p_ELIG_ANTHR_PL_PRTE_id          in  number
  ,p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_pl_id                          in  number
  ,p_eligy_prfl_id                  in  number
  ,p_business_group_id              in  number
  ,p_eop_attribute_category         in  varchar2
  ,p_eop_attribute1                 in  varchar2
  ,p_eop_attribute2                 in  varchar2
  ,p_eop_attribute3                 in  varchar2
  ,p_eop_attribute4                 in  varchar2
  ,p_eop_attribute5                 in  varchar2
  ,p_eop_attribute6                 in  varchar2
  ,p_eop_attribute7                 in  varchar2
  ,p_eop_attribute8                 in  varchar2
  ,p_eop_attribute9                 in  varchar2
  ,p_eop_attribute10                in  varchar2
  ,p_eop_attribute11                in  varchar2
  ,p_eop_attribute12                in  varchar2
  ,p_eop_attribute13                in  varchar2
  ,p_eop_attribute14                in  varchar2
  ,p_eop_attribute15                in  varchar2
  ,p_eop_attribute16                in  varchar2
  ,p_eop_attribute17                in  varchar2
  ,p_eop_attribute18                in  varchar2
  ,p_eop_attribute19                in  varchar2
  ,p_eop_attribute20                in  varchar2
  ,p_eop_attribute21                in  varchar2
  ,p_eop_attribute22                in  varchar2
  ,p_eop_attribute23                in  varchar2
  ,p_eop_attribute24                in  varchar2
  ,p_eop_attribute25                in  varchar2
  ,p_eop_attribute26                in  varchar2
  ,p_eop_attribute27                in  varchar2
  ,p_eop_attribute28                in  varchar2
  ,p_eop_attribute29                in  varchar2
  ,p_eop_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ELIG_ANTHR_PL_PRTE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIG_ANTHR_PL_PRTE_a
  (
   p_ELIG_ANTHR_PL_PRTE_id          in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_pl_id                          in  number
  ,p_eligy_prfl_id                  in  number
  ,p_business_group_id              in  number
  ,p_eop_attribute_category         in  varchar2
  ,p_eop_attribute1                 in  varchar2
  ,p_eop_attribute2                 in  varchar2
  ,p_eop_attribute3                 in  varchar2
  ,p_eop_attribute4                 in  varchar2
  ,p_eop_attribute5                 in  varchar2
  ,p_eop_attribute6                 in  varchar2
  ,p_eop_attribute7                 in  varchar2
  ,p_eop_attribute8                 in  varchar2
  ,p_eop_attribute9                 in  varchar2
  ,p_eop_attribute10                in  varchar2
  ,p_eop_attribute11                in  varchar2
  ,p_eop_attribute12                in  varchar2
  ,p_eop_attribute13                in  varchar2
  ,p_eop_attribute14                in  varchar2
  ,p_eop_attribute15                in  varchar2
  ,p_eop_attribute16                in  varchar2
  ,p_eop_attribute17                in  varchar2
  ,p_eop_attribute18                in  varchar2
  ,p_eop_attribute19                in  varchar2
  ,p_eop_attribute20                in  varchar2
  ,p_eop_attribute21                in  varchar2
  ,p_eop_attribute22                in  varchar2
  ,p_eop_attribute23                in  varchar2
  ,p_eop_attribute24                in  varchar2
  ,p_eop_attribute25                in  varchar2
  ,p_eop_attribute26                in  varchar2
  ,p_eop_attribute27                in  varchar2
  ,p_eop_attribute28                in  varchar2
  ,p_eop_attribute29                in  varchar2
  ,p_eop_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_ELIG_ANTHR_PL_PRTE_bk2;

 

/
