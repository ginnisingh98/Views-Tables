--------------------------------------------------------
--  DDL for Package BEN_ELIG_PER_WV_PL_TYP_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_PER_WV_PL_TYP_BK2" AUTHID CURRENT_USER as
/* $Header: beetwapi.pkh 120.0 2005/05/28 03:03:48 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_elig_per_wv_pl_typ_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_elig_per_wv_pl_typ_b
  (
   p_elig_per_wv_pl_typ_id          in  number
  ,p_pl_typ_id                      in  number
  ,p_elig_per_id                    in  number
  ,p_wv_cftn_typ_cd                 in  varchar2
  ,p_wv_prtn_rsn_cd                 in  varchar2
  ,p_wvd_flag                       in  varchar2
  ,p_business_group_id              in  number
  ,p_etw_attribute_category         in  varchar2
  ,p_etw_attribute1                 in  varchar2
  ,p_etw_attribute2                 in  varchar2
  ,p_etw_attribute3                 in  varchar2
  ,p_etw_attribute4                 in  varchar2
  ,p_etw_attribute5                 in  varchar2
  ,p_etw_attribute6                 in  varchar2
  ,p_etw_attribute7                 in  varchar2
  ,p_etw_attribute8                 in  varchar2
  ,p_etw_attribute9                 in  varchar2
  ,p_etw_attribute10                in  varchar2
  ,p_etw_attribute11                in  varchar2
  ,p_etw_attribute12                in  varchar2
  ,p_etw_attribute13                in  varchar2
  ,p_etw_attribute14                in  varchar2
  ,p_etw_attribute15                in  varchar2
  ,p_etw_attribute16                in  varchar2
  ,p_etw_attribute17                in  varchar2
  ,p_etw_attribute18                in  varchar2
  ,p_etw_attribute19                in  varchar2
  ,p_etw_attribute20                in  varchar2
  ,p_etw_attribute21                in  varchar2
  ,p_etw_attribute22                in  varchar2
  ,p_etw_attribute23                in  varchar2
  ,p_etw_attribute24                in  varchar2
  ,p_etw_attribute25                in  varchar2
  ,p_etw_attribute26                in  varchar2
  ,p_etw_attribute27                in  varchar2
  ,p_etw_attribute28                in  varchar2
  ,p_etw_attribute29                in  varchar2
  ,p_etw_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_elig_per_wv_pl_typ_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_elig_per_wv_pl_typ_a
  (
   p_elig_per_wv_pl_typ_id          in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_pl_typ_id                      in  number
  ,p_elig_per_id                    in  number
  ,p_wv_cftn_typ_cd                 in  varchar2
  ,p_wv_prtn_rsn_cd                 in  varchar2
  ,p_wvd_flag                       in  varchar2
  ,p_business_group_id              in  number
  ,p_etw_attribute_category         in  varchar2
  ,p_etw_attribute1                 in  varchar2
  ,p_etw_attribute2                 in  varchar2
  ,p_etw_attribute3                 in  varchar2
  ,p_etw_attribute4                 in  varchar2
  ,p_etw_attribute5                 in  varchar2
  ,p_etw_attribute6                 in  varchar2
  ,p_etw_attribute7                 in  varchar2
  ,p_etw_attribute8                 in  varchar2
  ,p_etw_attribute9                 in  varchar2
  ,p_etw_attribute10                in  varchar2
  ,p_etw_attribute11                in  varchar2
  ,p_etw_attribute12                in  varchar2
  ,p_etw_attribute13                in  varchar2
  ,p_etw_attribute14                in  varchar2
  ,p_etw_attribute15                in  varchar2
  ,p_etw_attribute16                in  varchar2
  ,p_etw_attribute17                in  varchar2
  ,p_etw_attribute18                in  varchar2
  ,p_etw_attribute19                in  varchar2
  ,p_etw_attribute20                in  varchar2
  ,p_etw_attribute21                in  varchar2
  ,p_etw_attribute22                in  varchar2
  ,p_etw_attribute23                in  varchar2
  ,p_etw_attribute24                in  varchar2
  ,p_etw_attribute25                in  varchar2
  ,p_etw_attribute26                in  varchar2
  ,p_etw_attribute27                in  varchar2
  ,p_etw_attribute28                in  varchar2
  ,p_etw_attribute29                in  varchar2
  ,p_etw_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_elig_per_wv_pl_typ_bk2;

 

/
