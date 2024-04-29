--------------------------------------------------------
--  DDL for Package BEN_ELIG_FL_TM_PT_TM_PRTE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_FL_TM_PT_TM_PRTE_BK2" AUTHID CURRENT_USER as
/* $Header: beefpapi.pkh 120.0 2005/05/28 02:09:30 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ELIG_FL_TM_PT_TM_PRTE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIG_FL_TM_PT_TM_PRTE_b
  (
   p_elig_fl_tm_pt_tm_prte_id       in  number
  ,p_business_group_id              in  number
  ,p_eligy_prfl_id                  in  number
  ,p_ordr_num                       in  number
  ,p_fl_tm_pt_tm_cd                 in  varchar2
  ,p_excld_flag                     in  varchar2
  ,p_efp_attribute_category         in  varchar2
  ,p_efp_attribute1                 in  varchar2
  ,p_efp_attribute2                 in  varchar2
  ,p_efp_attribute3                 in  varchar2
  ,p_efp_attribute4                 in  varchar2
  ,p_efp_attribute5                 in  varchar2
  ,p_efp_attribute6                 in  varchar2
  ,p_efp_attribute7                 in  varchar2
  ,p_efp_attribute8                 in  varchar2
  ,p_efp_attribute9                 in  varchar2
  ,p_efp_attribute10                in  varchar2
  ,p_efp_attribute11                in  varchar2
  ,p_efp_attribute12                in  varchar2
  ,p_efp_attribute13                in  varchar2
  ,p_efp_attribute14                in  varchar2
  ,p_efp_attribute15                in  varchar2
  ,p_efp_attribute16                in  varchar2
  ,p_efp_attribute17                in  varchar2
  ,p_efp_attribute18                in  varchar2
  ,p_efp_attribute19                in  varchar2
  ,p_efp_attribute20                in  varchar2
  ,p_efp_attribute21                in  varchar2
  ,p_efp_attribute22                in  varchar2
  ,p_efp_attribute23                in  varchar2
  ,p_efp_attribute24                in  varchar2
  ,p_efp_attribute25                in  varchar2
  ,p_efp_attribute26                in  varchar2
  ,p_efp_attribute27                in  varchar2
  ,p_efp_attribute28                in  varchar2
  ,p_efp_attribute29                in  varchar2
  ,p_efp_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_criteria_score                in number
  ,p_criteria_weight               in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ELIG_FL_TM_PT_TM_PRTE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIG_FL_TM_PT_TM_PRTE_a
  (
   p_elig_fl_tm_pt_tm_prte_id       in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_eligy_prfl_id                  in  number
  ,p_ordr_num                       in  number
  ,p_fl_tm_pt_tm_cd                 in  varchar2
  ,p_excld_flag                     in  varchar2
  ,p_efp_attribute_category         in  varchar2
  ,p_efp_attribute1                 in  varchar2
  ,p_efp_attribute2                 in  varchar2
  ,p_efp_attribute3                 in  varchar2
  ,p_efp_attribute4                 in  varchar2
  ,p_efp_attribute5                 in  varchar2
  ,p_efp_attribute6                 in  varchar2
  ,p_efp_attribute7                 in  varchar2
  ,p_efp_attribute8                 in  varchar2
  ,p_efp_attribute9                 in  varchar2
  ,p_efp_attribute10                in  varchar2
  ,p_efp_attribute11                in  varchar2
  ,p_efp_attribute12                in  varchar2
  ,p_efp_attribute13                in  varchar2
  ,p_efp_attribute14                in  varchar2
  ,p_efp_attribute15                in  varchar2
  ,p_efp_attribute16                in  varchar2
  ,p_efp_attribute17                in  varchar2
  ,p_efp_attribute18                in  varchar2
  ,p_efp_attribute19                in  varchar2
  ,p_efp_attribute20                in  varchar2
  ,p_efp_attribute21                in  varchar2
  ,p_efp_attribute22                in  varchar2
  ,p_efp_attribute23                in  varchar2
  ,p_efp_attribute24                in  varchar2
  ,p_efp_attribute25                in  varchar2
  ,p_efp_attribute26                in  varchar2
  ,p_efp_attribute27                in  varchar2
  ,p_efp_attribute28                in  varchar2
  ,p_efp_attribute29                in  varchar2
  ,p_efp_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_criteria_score                in number
  ,p_criteria_weight               in  number
  );
--
end ben_ELIG_FL_TM_PT_TM_PRTE_bk2;

 

/
