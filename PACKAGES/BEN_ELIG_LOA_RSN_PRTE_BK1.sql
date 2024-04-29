--------------------------------------------------------
--  DDL for Package BEN_ELIG_LOA_RSN_PRTE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_LOA_RSN_PRTE_BK1" AUTHID CURRENT_USER as
/* $Header: beelrapi.pkh 120.0 2005/05/28 02:21:01 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ELIG_LOA_RSN_PRTE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELIG_LOA_RSN_PRTE_b
  (
   p_business_group_id              in  number
  ,p_eligy_prfl_id                  in  number
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_elr_attribute_category         in  varchar2
  ,p_elr_attribute1                 in  varchar2
  ,p_elr_attribute2                 in  varchar2
  ,p_elr_attribute3                 in  varchar2
  ,p_elr_attribute4                 in  varchar2
  ,p_elr_attribute5                 in  varchar2
  ,p_elr_attribute6                 in  varchar2
  ,p_elr_attribute7                 in  varchar2
  ,p_elr_attribute8                 in  varchar2
  ,p_elr_attribute9                 in  varchar2
  ,p_elr_attribute10                in  varchar2
  ,p_elr_attribute11                in  varchar2
  ,p_elr_attribute12                in  varchar2
  ,p_elr_attribute13                in  varchar2
  ,p_elr_attribute14                in  varchar2
  ,p_elr_attribute15                in  varchar2
  ,p_elr_attribute16                in  varchar2
  ,p_elr_attribute17                in  varchar2
  ,p_elr_attribute18                in  varchar2
  ,p_elr_attribute19                in  varchar2
  ,p_elr_attribute20                in  varchar2
  ,p_elr_attribute21                in  varchar2
  ,p_elr_attribute22                in  varchar2
  ,p_elr_attribute23                in  varchar2
  ,p_elr_attribute24                in  varchar2
  ,p_elr_attribute25                in  varchar2
  ,p_elr_attribute26                in  varchar2
  ,p_elr_attribute27                in  varchar2
  ,p_elr_attribute28                in  varchar2
  ,p_elr_attribute29                in  varchar2
  ,p_elr_attribute30                in  varchar2
  ,p_absence_attendance_type_id     in  number
  ,p_abs_attendance_reason_id       in  number
  ,p_effective_date                 in  date
  ,p_criteria_score                in number
  ,p_criteria_weight               in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ELIG_LOA_RSN_PRTE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELIG_LOA_RSN_PRTE_a
  (
   p_elig_loa_rsn_prte_id           in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_eligy_prfl_id                  in  number
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_elr_attribute_category         in  varchar2
  ,p_elr_attribute1                 in  varchar2
  ,p_elr_attribute2                 in  varchar2
  ,p_elr_attribute3                 in  varchar2
  ,p_elr_attribute4                 in  varchar2
  ,p_elr_attribute5                 in  varchar2
  ,p_elr_attribute6                 in  varchar2
  ,p_elr_attribute7                 in  varchar2
  ,p_elr_attribute8                 in  varchar2
  ,p_elr_attribute9                 in  varchar2
  ,p_elr_attribute10                in  varchar2
  ,p_elr_attribute11                in  varchar2
  ,p_elr_attribute12                in  varchar2
  ,p_elr_attribute13                in  varchar2
  ,p_elr_attribute14                in  varchar2
  ,p_elr_attribute15                in  varchar2
  ,p_elr_attribute16                in  varchar2
  ,p_elr_attribute17                in  varchar2
  ,p_elr_attribute18                in  varchar2
  ,p_elr_attribute19                in  varchar2
  ,p_elr_attribute20                in  varchar2
  ,p_elr_attribute21                in  varchar2
  ,p_elr_attribute22                in  varchar2
  ,p_elr_attribute23                in  varchar2
  ,p_elr_attribute24                in  varchar2
  ,p_elr_attribute25                in  varchar2
  ,p_elr_attribute26                in  varchar2
  ,p_elr_attribute27                in  varchar2
  ,p_elr_attribute28                in  varchar2
  ,p_elr_attribute29                in  varchar2
  ,p_elr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_absence_attendance_type_id     in  number
  ,p_abs_attendance_reason_id       in  number
  ,p_effective_date                 in  date
  ,p_criteria_score                in number
  ,p_criteria_weight               in  number
  );
--
end ben_ELIG_LOA_RSN_PRTE_bk1;

 

/
