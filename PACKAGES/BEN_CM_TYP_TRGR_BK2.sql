--------------------------------------------------------
--  DDL for Package BEN_CM_TYP_TRGR_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CM_TYP_TRGR_BK2" AUTHID CURRENT_USER as
/* $Header: becttapi.pkh 120.0 2005/05/28 01:27:09 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_cm_typ_trgr_b >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_cm_typ_trgr_b
  (p_cm_typ_trgr_id                 in  number
  ,p_cm_typ_trgr_rl                 in  number
  ,p_cm_trgr_id                     in  number
  ,p_cm_typ_id                      in  number
  ,p_business_group_id              in  number
  ,p_ctt_attribute_category         in  varchar2
  ,p_ctt_attribute1                 in  varchar2
  ,p_ctt_attribute2                 in  varchar2
  ,p_ctt_attribute3                 in  varchar2
  ,p_ctt_attribute4                 in  varchar2
  ,p_ctt_attribute5                 in  varchar2
  ,p_ctt_attribute6                 in  varchar2
  ,p_ctt_attribute7                 in  varchar2
  ,p_ctt_attribute8                 in  varchar2
  ,p_ctt_attribute9                 in  varchar2
  ,p_ctt_attribute10                in  varchar2
  ,p_ctt_attribute11                in  varchar2
  ,p_ctt_attribute12                in  varchar2
  ,p_ctt_attribute13                in  varchar2
  ,p_ctt_attribute14                in  varchar2
  ,p_ctt_attribute15                in  varchar2
  ,p_ctt_attribute16                in  varchar2
  ,p_ctt_attribute17                in  varchar2
  ,p_ctt_attribute18                in  varchar2
  ,p_ctt_attribute19                in  varchar2
  ,p_ctt_attribute20                in  varchar2
  ,p_ctt_attribute21                in  varchar2
  ,p_ctt_attribute22                in  varchar2
  ,p_ctt_attribute23                in  varchar2
  ,p_ctt_attribute24                in  varchar2
  ,p_ctt_attribute25                in  varchar2
  ,p_ctt_attribute26                in  varchar2
  ,p_ctt_attribute27                in  varchar2
  ,p_ctt_attribute28                in  varchar2
  ,p_ctt_attribute29                in  varchar2
  ,p_ctt_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_cm_typ_trgr_a >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_cm_typ_trgr_a
  (p_cm_typ_trgr_id                 in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_cm_typ_trgr_rl                 in  number
  ,p_cm_trgr_id                     in  number
  ,p_cm_typ_id                      in  number
  ,p_business_group_id              in  number
  ,p_ctt_attribute_category         in  varchar2
  ,p_ctt_attribute1                 in  varchar2
  ,p_ctt_attribute2                 in  varchar2
  ,p_ctt_attribute3                 in  varchar2
  ,p_ctt_attribute4                 in  varchar2
  ,p_ctt_attribute5                 in  varchar2
  ,p_ctt_attribute6                 in  varchar2
  ,p_ctt_attribute7                 in  varchar2
  ,p_ctt_attribute8                 in  varchar2
  ,p_ctt_attribute9                 in  varchar2
  ,p_ctt_attribute10                in  varchar2
  ,p_ctt_attribute11                in  varchar2
  ,p_ctt_attribute12                in  varchar2
  ,p_ctt_attribute13                in  varchar2
  ,p_ctt_attribute14                in  varchar2
  ,p_ctt_attribute15                in  varchar2
  ,p_ctt_attribute16                in  varchar2
  ,p_ctt_attribute17                in  varchar2
  ,p_ctt_attribute18                in  varchar2
  ,p_ctt_attribute19                in  varchar2
  ,p_ctt_attribute20                in  varchar2
  ,p_ctt_attribute21                in  varchar2
  ,p_ctt_attribute22                in  varchar2
  ,p_ctt_attribute23                in  varchar2
  ,p_ctt_attribute24                in  varchar2
  ,p_ctt_attribute25                in  varchar2
  ,p_ctt_attribute26                in  varchar2
  ,p_ctt_attribute27                in  varchar2
  ,p_ctt_attribute28                in  varchar2
  ,p_ctt_attribute29                in  varchar2
  ,p_ctt_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2);
--
end ben_cm_typ_trgr_bk2;

 

/
