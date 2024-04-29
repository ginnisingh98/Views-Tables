--------------------------------------------------------
--  DDL for Package BEN_LOA_REASON_RATE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LOA_REASON_RATE_BK2" AUTHID CURRENT_USER as
/* $Header: belarapi.pkh 120.0 2005/05/28 03:14:36 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_LOA_REASON_RATE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_LOA_REASON_RATE_b
  (
   p_loa_rsn_rt_id                  in  number
  ,p_business_group_id              in  number
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_vrbl_rt_prfl_id                in  number
  ,p_loa_rsn_cd                     in  varchar2
  ,p_lar_attribute_category         in  varchar2
  ,p_lar_attribute1                 in  varchar2
  ,p_lar_attribute2                 in  varchar2
  ,p_lar_attribute3                 in  varchar2
  ,p_lar_attribute4                 in  varchar2
  ,p_lar_attribute5                 in  varchar2
  ,p_lar_attribute6                 in  varchar2
  ,p_lar_attribute7                 in  varchar2
  ,p_lar_attribute8                 in  varchar2
  ,p_lar_attribute9                 in  varchar2
  ,p_lar_attribute10                in  varchar2
  ,p_lar_attribute11                in  varchar2
  ,p_lar_attribute12                in  varchar2
  ,p_lar_attribute13                in  varchar2
  ,p_lar_attribute14                in  varchar2
  ,p_lar_attribute15                in  varchar2
  ,p_lar_attribute16                in  varchar2
  ,p_lar_attribute17                in  varchar2
  ,p_lar_attribute18                in  varchar2
  ,p_lar_attribute19                in  varchar2
  ,p_lar_attribute20                in  varchar2
  ,p_lar_attribute21                in  varchar2
  ,p_lar_attribute22                in  varchar2
  ,p_lar_attribute23                in  varchar2
  ,p_lar_attribute24                in  varchar2
  ,p_lar_attribute25                in  varchar2
  ,p_lar_attribute26                in  varchar2
  ,p_lar_attribute27                in  varchar2
  ,p_lar_attribute28                in  varchar2
  ,p_lar_attribute29                in  varchar2
  ,p_lar_attribute30                in  varchar2
  ,p_absence_attendance_type_id     in  number
  ,p_abs_attendance_reason_id       in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_LOA_REASON_RATE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_LOA_REASON_RATE_a
  (
   p_loa_rsn_rt_id                  in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_vrbl_rt_prfl_id                in  number
  ,p_loa_rsn_cd                     in  varchar2
  ,p_lar_attribute_category         in  varchar2
  ,p_lar_attribute1                 in  varchar2
  ,p_lar_attribute2                 in  varchar2
  ,p_lar_attribute3                 in  varchar2
  ,p_lar_attribute4                 in  varchar2
  ,p_lar_attribute5                 in  varchar2
  ,p_lar_attribute6                 in  varchar2
  ,p_lar_attribute7                 in  varchar2
  ,p_lar_attribute8                 in  varchar2
  ,p_lar_attribute9                 in  varchar2
  ,p_lar_attribute10                in  varchar2
  ,p_lar_attribute11                in  varchar2
  ,p_lar_attribute12                in  varchar2
  ,p_lar_attribute13                in  varchar2
  ,p_lar_attribute14                in  varchar2
  ,p_lar_attribute15                in  varchar2
  ,p_lar_attribute16                in  varchar2
  ,p_lar_attribute17                in  varchar2
  ,p_lar_attribute18                in  varchar2
  ,p_lar_attribute19                in  varchar2
  ,p_lar_attribute20                in  varchar2
  ,p_lar_attribute21                in  varchar2
  ,p_lar_attribute22                in  varchar2
  ,p_lar_attribute23                in  varchar2
  ,p_lar_attribute24                in  varchar2
  ,p_lar_attribute25                in  varchar2
  ,p_lar_attribute26                in  varchar2
  ,p_lar_attribute27                in  varchar2
  ,p_lar_attribute28                in  varchar2
  ,p_lar_attribute29                in  varchar2
  ,p_lar_attribute30                in  varchar2
  ,p_absence_attendance_type_id     in  number
  ,p_abs_attendance_reason_id       in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_LOA_REASON_RATE_bk2;

 

/
