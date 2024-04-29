--------------------------------------------------------
--  DDL for Package BEN_ELIG_PERF_RTNG_PRTE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_PERF_RTNG_PRTE_BK1" AUTHID CURRENT_USER as
/* $Header: beergapi.pkh 120.0 2005/05/28 02:51:18 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ELIG_PERF_RTNG_PRTE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELIG_PERF_RTNG_PRTE_b
  (
   p_business_group_id              in  number
  ,p_ELIGY_PRFL_id                in  number
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_event_type          	    in  varchar2
  ,p_perf_rtng_cd                   in  varchar2
  ,p_erg_attribute_category         in  varchar2
  ,p_erg_attribute1                 in  varchar2
  ,p_erg_attribute2                 in  varchar2
  ,p_erg_attribute3                 in  varchar2
  ,p_erg_attribute4                 in  varchar2
  ,p_erg_attribute5                 in  varchar2
  ,p_erg_attribute6                 in  varchar2
  ,p_erg_attribute7                 in  varchar2
  ,p_erg_attribute8                 in  varchar2
  ,p_erg_attribute9                 in  varchar2
  ,p_erg_attribute10                in  varchar2
  ,p_erg_attribute11                in  varchar2
  ,p_erg_attribute12                in  varchar2
  ,p_erg_attribute13                in  varchar2
  ,p_erg_attribute14                in  varchar2
  ,p_erg_attribute15                in  varchar2
  ,p_erg_attribute16                in  varchar2
  ,p_erg_attribute17                in  varchar2
  ,p_erg_attribute18                in  varchar2
  ,p_erg_attribute19                in  varchar2
  ,p_erg_attribute20                in  varchar2
  ,p_erg_attribute21                in  varchar2
  ,p_erg_attribute22                in  varchar2
  ,p_erg_attribute23                in  varchar2
  ,p_erg_attribute24                in  varchar2
  ,p_erg_attribute25                in  varchar2
  ,p_erg_attribute26                in  varchar2
  ,p_erg_attribute27                in  varchar2
  ,p_erg_attribute28                in  varchar2
  ,p_erg_attribute29                in  varchar2
  ,p_erg_attribute30                in  varchar2
  ,p_effective_date                 in  date
  ,p_criteria_score                in number
  ,p_criteria_weight               in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ELIG_PERF_RTNG_PRTE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELIG_PERF_RTNG_PRTE_a
  (
   p_ELIG_PERF_RTNG_PRTE_id                in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_ELIGY_PRFL_id                in  number
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_event_type           	    in  varchar2
  ,p_perf_rtng_cd                   in  varchar2
  ,p_erg_attribute_category         in  varchar2
  ,p_erg_attribute1                 in  varchar2
  ,p_erg_attribute2                 in  varchar2
  ,p_erg_attribute3                 in  varchar2
  ,p_erg_attribute4                 in  varchar2
  ,p_erg_attribute5                 in  varchar2
  ,p_erg_attribute6                 in  varchar2
  ,p_erg_attribute7                 in  varchar2
  ,p_erg_attribute8                 in  varchar2
  ,p_erg_attribute9                 in  varchar2
  ,p_erg_attribute10                in  varchar2
  ,p_erg_attribute11                in  varchar2
  ,p_erg_attribute12                in  varchar2
  ,p_erg_attribute13                in  varchar2
  ,p_erg_attribute14                in  varchar2
  ,p_erg_attribute15                in  varchar2
  ,p_erg_attribute16                in  varchar2
  ,p_erg_attribute17                in  varchar2
  ,p_erg_attribute18                in  varchar2
  ,p_erg_attribute19                in  varchar2
  ,p_erg_attribute20                in  varchar2
  ,p_erg_attribute21                in  varchar2
  ,p_erg_attribute22                in  varchar2
  ,p_erg_attribute23                in  varchar2
  ,p_erg_attribute24                in  varchar2
  ,p_erg_attribute25                in  varchar2
  ,p_erg_attribute26                in  varchar2
  ,p_erg_attribute27                in  varchar2
  ,p_erg_attribute28                in  varchar2
  ,p_erg_attribute29                in  varchar2
  ,p_erg_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_criteria_score                in number
  ,p_criteria_weight               in  number
  );
--
end ben_ELIG_PERF_RTNG_PRTE_bk1;

 

/
