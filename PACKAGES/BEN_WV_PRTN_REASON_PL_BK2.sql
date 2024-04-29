--------------------------------------------------------
--  DDL for Package BEN_WV_PRTN_REASON_PL_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_WV_PRTN_REASON_PL_BK2" AUTHID CURRENT_USER as
/* $Header: bewpnapi.pkh 120.0 2005/05/28 12:18:28 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_WV_PRTN_REASON_PL_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_WV_PRTN_REASON_PL_b
  (
   p_wv_prtn_rsn_pl_id              in  number
  ,p_business_group_id              in  number
  ,p_pl_id                          in  number
  ,p_dflt_flag                      in  varchar2
  ,p_wv_prtn_rsn_cd                 in  varchar2
  ,p_wpn_attribute_category         in  varchar2
  ,p_wpn_attribute1                 in  varchar2
  ,p_wpn_attribute2                 in  varchar2
  ,p_wpn_attribute3                 in  varchar2
  ,p_wpn_attribute4                 in  varchar2
  ,p_wpn_attribute5                 in  varchar2
  ,p_wpn_attribute6                 in  varchar2
  ,p_wpn_attribute7                 in  varchar2
  ,p_wpn_attribute8                 in  varchar2
  ,p_wpn_attribute9                 in  varchar2
  ,p_wpn_attribute10                in  varchar2
  ,p_wpn_attribute11                in  varchar2
  ,p_wpn_attribute12                in  varchar2
  ,p_wpn_attribute13                in  varchar2
  ,p_wpn_attribute14                in  varchar2
  ,p_wpn_attribute15                in  varchar2
  ,p_wpn_attribute16                in  varchar2
  ,p_wpn_attribute17                in  varchar2
  ,p_wpn_attribute18                in  varchar2
  ,p_wpn_attribute19                in  varchar2
  ,p_wpn_attribute20                in  varchar2
  ,p_wpn_attribute21                in  varchar2
  ,p_wpn_attribute22                in  varchar2
  ,p_wpn_attribute23                in  varchar2
  ,p_wpn_attribute24                in  varchar2
  ,p_wpn_attribute25                in  varchar2
  ,p_wpn_attribute26                in  varchar2
  ,p_wpn_attribute27                in  varchar2
  ,p_wpn_attribute28                in  varchar2
  ,p_wpn_attribute29                in  varchar2
  ,p_wpn_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_WV_PRTN_REASON_PL_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_WV_PRTN_REASON_PL_a
  (
   p_wv_prtn_rsn_pl_id              in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_pl_id                          in  number
  ,p_dflt_flag                      in  varchar2
  ,p_wv_prtn_rsn_cd                 in  varchar2
  ,p_wpn_attribute_category         in  varchar2
  ,p_wpn_attribute1                 in  varchar2
  ,p_wpn_attribute2                 in  varchar2
  ,p_wpn_attribute3                 in  varchar2
  ,p_wpn_attribute4                 in  varchar2
  ,p_wpn_attribute5                 in  varchar2
  ,p_wpn_attribute6                 in  varchar2
  ,p_wpn_attribute7                 in  varchar2
  ,p_wpn_attribute8                 in  varchar2
  ,p_wpn_attribute9                 in  varchar2
  ,p_wpn_attribute10                in  varchar2
  ,p_wpn_attribute11                in  varchar2
  ,p_wpn_attribute12                in  varchar2
  ,p_wpn_attribute13                in  varchar2
  ,p_wpn_attribute14                in  varchar2
  ,p_wpn_attribute15                in  varchar2
  ,p_wpn_attribute16                in  varchar2
  ,p_wpn_attribute17                in  varchar2
  ,p_wpn_attribute18                in  varchar2
  ,p_wpn_attribute19                in  varchar2
  ,p_wpn_attribute20                in  varchar2
  ,p_wpn_attribute21                in  varchar2
  ,p_wpn_attribute22                in  varchar2
  ,p_wpn_attribute23                in  varchar2
  ,p_wpn_attribute24                in  varchar2
  ,p_wpn_attribute25                in  varchar2
  ,p_wpn_attribute26                in  varchar2
  ,p_wpn_attribute27                in  varchar2
  ,p_wpn_attribute28                in  varchar2
  ,p_wpn_attribute29                in  varchar2
  ,p_wpn_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_WV_PRTN_REASON_PL_bk2;

 

/
