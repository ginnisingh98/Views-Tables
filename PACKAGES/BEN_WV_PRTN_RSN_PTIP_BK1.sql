--------------------------------------------------------
--  DDL for Package BEN_WV_PRTN_RSN_PTIP_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_WV_PRTN_RSN_PTIP_BK1" AUTHID CURRENT_USER as
/* $Header: bewptapi.pkh 120.0 2005/05/28 12:19:50 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_WV_PRTN_RSN_PTIP_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_WV_PRTN_RSN_PTIP_b
  (
   p_business_group_id              in  number
  ,p_ptip_id                        in  number
  ,p_dflt_flag                      in  varchar2
  ,p_wv_prtn_rsn_cd                 in  varchar2
  ,p_wpt_attribute_category         in  varchar2
  ,p_wpt_attribute1                 in  varchar2
  ,p_wpt_attribute2                 in  varchar2
  ,p_wpt_attribute3                 in  varchar2
  ,p_wpt_attribute4                 in  varchar2
  ,p_wpt_attribute5                 in  varchar2
  ,p_wpt_attribute6                 in  varchar2
  ,p_wpt_attribute7                 in  varchar2
  ,p_wpt_attribute8                 in  varchar2
  ,p_wpt_attribute9                 in  varchar2
  ,p_wpt_attribute10                in  varchar2
  ,p_wpt_attribute11                in  varchar2
  ,p_wpt_attribute12                in  varchar2
  ,p_wpt_attribute13                in  varchar2
  ,p_wpt_attribute14                in  varchar2
  ,p_wpt_attribute15                in  varchar2
  ,p_wpt_attribute16                in  varchar2
  ,p_wpt_attribute17                in  varchar2
  ,p_wpt_attribute18                in  varchar2
  ,p_wpt_attribute19                in  varchar2
  ,p_wpt_attribute20                in  varchar2
  ,p_wpt_attribute21                in  varchar2
  ,p_wpt_attribute22                in  varchar2
  ,p_wpt_attribute23                in  varchar2
  ,p_wpt_attribute24                in  varchar2
  ,p_wpt_attribute25                in  varchar2
  ,p_wpt_attribute26                in  varchar2
  ,p_wpt_attribute27                in  varchar2
  ,p_wpt_attribute28                in  varchar2
  ,p_wpt_attribute29                in  varchar2
  ,p_wpt_attribute30                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_WV_PRTN_RSN_PTIP_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_WV_PRTN_RSN_PTIP_a
  (
   p_wv_prtn_rsn_ptip_id            in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_ptip_id                        in  number
  ,p_dflt_flag                      in  varchar2
  ,p_wv_prtn_rsn_cd                 in  varchar2
  ,p_wpt_attribute_category         in  varchar2
  ,p_wpt_attribute1                 in  varchar2
  ,p_wpt_attribute2                 in  varchar2
  ,p_wpt_attribute3                 in  varchar2
  ,p_wpt_attribute4                 in  varchar2
  ,p_wpt_attribute5                 in  varchar2
  ,p_wpt_attribute6                 in  varchar2
  ,p_wpt_attribute7                 in  varchar2
  ,p_wpt_attribute8                 in  varchar2
  ,p_wpt_attribute9                 in  varchar2
  ,p_wpt_attribute10                in  varchar2
  ,p_wpt_attribute11                in  varchar2
  ,p_wpt_attribute12                in  varchar2
  ,p_wpt_attribute13                in  varchar2
  ,p_wpt_attribute14                in  varchar2
  ,p_wpt_attribute15                in  varchar2
  ,p_wpt_attribute16                in  varchar2
  ,p_wpt_attribute17                in  varchar2
  ,p_wpt_attribute18                in  varchar2
  ,p_wpt_attribute19                in  varchar2
  ,p_wpt_attribute20                in  varchar2
  ,p_wpt_attribute21                in  varchar2
  ,p_wpt_attribute22                in  varchar2
  ,p_wpt_attribute23                in  varchar2
  ,p_wpt_attribute24                in  varchar2
  ,p_wpt_attribute25                in  varchar2
  ,p_wpt_attribute26                in  varchar2
  ,p_wpt_attribute27                in  varchar2
  ,p_wpt_attribute28                in  varchar2
  ,p_wpt_attribute29                in  varchar2
  ,p_wpt_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_WV_PRTN_RSN_PTIP_bk1;

 

/
