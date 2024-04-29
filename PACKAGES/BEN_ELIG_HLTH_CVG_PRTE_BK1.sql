--------------------------------------------------------
--  DDL for Package BEN_ELIG_HLTH_CVG_PRTE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_HLTH_CVG_PRTE_BK1" AUTHID CURRENT_USER as
/* $Header: beehcapi.pkh 120.0 2005/05/28 02:13:57 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ELIG_HLTH_CVG_PRTE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELIG_HLTH_CVG_PRTE_b
  (
   p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_pl_typ_opt_typ_id              in  number
  ,p_oipl_id                        in  number
  ,p_eligy_prfl_id                  in  number
  ,p_business_group_id              in  number
  ,p_ehc_attribute_category         in  varchar2
  ,p_ehc_attribute1                 in  varchar2
  ,p_ehc_attribute2                 in  varchar2
  ,p_ehc_attribute3                 in  varchar2
  ,p_ehc_attribute4                 in  varchar2
  ,p_ehc_attribute5                 in  varchar2
  ,p_ehc_attribute6                 in  varchar2
  ,p_ehc_attribute7                 in  varchar2
  ,p_ehc_attribute8                 in  varchar2
  ,p_ehc_attribute9                 in  varchar2
  ,p_ehc_attribute10                in  varchar2
  ,p_ehc_attribute11                in  varchar2
  ,p_ehc_attribute12                in  varchar2
  ,p_ehc_attribute13                in  varchar2
  ,p_ehc_attribute14                in  varchar2
  ,p_ehc_attribute15                in  varchar2
  ,p_ehc_attribute16                in  varchar2
  ,p_ehc_attribute17                in  varchar2
  ,p_ehc_attribute18                in  varchar2
  ,p_ehc_attribute19                in  varchar2
  ,p_ehc_attribute20                in  varchar2
  ,p_ehc_attribute21                in  varchar2
  ,p_ehc_attribute22                in  varchar2
  ,p_ehc_attribute23                in  varchar2
  ,p_ehc_attribute24                in  varchar2
  ,p_ehc_attribute25                in  varchar2
  ,p_ehc_attribute26                in  varchar2
  ,p_ehc_attribute27                in  varchar2
  ,p_ehc_attribute28                in  varchar2
  ,p_ehc_attribute29                in  varchar2
  ,p_ehc_attribute30                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ELIG_HLTH_CVG_PRTE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELIG_HLTH_CVG_PRTE_a
  (
   p_ELIG_HLTH_CVG_PRTE_id          in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_pl_typ_opt_typ_id              in  number
  ,p_oipl_id                        in  number
  ,p_eligy_prfl_id                  in  number
  ,p_business_group_id              in  number
  ,p_ehc_attribute_category         in  varchar2
  ,p_ehc_attribute1                 in  varchar2
  ,p_ehc_attribute2                 in  varchar2
  ,p_ehc_attribute3                 in  varchar2
  ,p_ehc_attribute4                 in  varchar2
  ,p_ehc_attribute5                 in  varchar2
  ,p_ehc_attribute6                 in  varchar2
  ,p_ehc_attribute7                 in  varchar2
  ,p_ehc_attribute8                 in  varchar2
  ,p_ehc_attribute9                 in  varchar2
  ,p_ehc_attribute10                in  varchar2
  ,p_ehc_attribute11                in  varchar2
  ,p_ehc_attribute12                in  varchar2
  ,p_ehc_attribute13                in  varchar2
  ,p_ehc_attribute14                in  varchar2
  ,p_ehc_attribute15                in  varchar2
  ,p_ehc_attribute16                in  varchar2
  ,p_ehc_attribute17                in  varchar2
  ,p_ehc_attribute18                in  varchar2
  ,p_ehc_attribute19                in  varchar2
  ,p_ehc_attribute20                in  varchar2
  ,p_ehc_attribute21                in  varchar2
  ,p_ehc_attribute22                in  varchar2
  ,p_ehc_attribute23                in  varchar2
  ,p_ehc_attribute24                in  varchar2
  ,p_ehc_attribute25                in  varchar2
  ,p_ehc_attribute26                in  varchar2
  ,p_ehc_attribute27                in  varchar2
  ,p_ehc_attribute28                in  varchar2
  ,p_ehc_attribute29                in  varchar2
  ,p_ehc_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_ELIG_HLTH_CVG_PRTE_bk1;

 

/
