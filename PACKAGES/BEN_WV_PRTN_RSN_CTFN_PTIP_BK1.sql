--------------------------------------------------------
--  DDL for Package BEN_WV_PRTN_RSN_CTFN_PTIP_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_WV_PRTN_RSN_CTFN_PTIP_BK1" AUTHID CURRENT_USER as
/* $Header: bewctapi.pkh 120.0 2005/05/28 12:16:06 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_wv_prtn_rsn_ctfn_ptip_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_wv_prtn_rsn_ctfn_ptip_b
  (
   p_wv_prtn_ctfn_cd                in  varchar2
  ,p_wv_prtn_rsn_ptip_id            in  number
  ,p_lack_ctfn_sspnd_wvr_flag       in  varchar2
  ,p_rqd_flag                       in  varchar2
  ,p_ctfn_rqd_when_rl               in  number
  ,p_pfd_flag                       in  varchar2
  ,p_wv_prtn_ctfn_typ_cd            in  varchar2
  ,p_business_group_id              in  number
  ,p_wct_attribute_category         in  varchar2
  ,p_wct_attribute1                 in  varchar2
  ,p_wct_attribute2                 in  varchar2
  ,p_wct_attribute3                 in  varchar2
  ,p_wct_attribute4                 in  varchar2
  ,p_wct_attribute5                 in  varchar2
  ,p_wct_attribute6                 in  varchar2
  ,p_wct_attribute7                 in  varchar2
  ,p_wct_attribute8                 in  varchar2
  ,p_wct_attribute9                 in  varchar2
  ,p_wct_attribute10                in  varchar2
  ,p_wct_attribute11                in  varchar2
  ,p_wct_attribute12                in  varchar2
  ,p_wct_attribute13                in  varchar2
  ,p_wct_attribute14                in  varchar2
  ,p_wct_attribute15                in  varchar2
  ,p_wct_attribute16                in  varchar2
  ,p_wct_attribute17                in  varchar2
  ,p_wct_attribute18                in  varchar2
  ,p_wct_attribute19                in  varchar2
  ,p_wct_attribute20                in  varchar2
  ,p_wct_attribute21                in  varchar2
  ,p_wct_attribute22                in  varchar2
  ,p_wct_attribute23                in  varchar2
  ,p_wct_attribute24                in  varchar2
  ,p_wct_attribute25                in  varchar2
  ,p_wct_attribute26                in  varchar2
  ,p_wct_attribute27                in  varchar2
  ,p_wct_attribute28                in  varchar2
  ,p_wct_attribute29                in  varchar2
  ,p_wct_attribute30                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_wv_prtn_rsn_ctfn_ptip_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_wv_prtn_rsn_ctfn_ptip_a
  (
   p_wv_prtn_rsn_ctfn_ptip_id       in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_wv_prtn_ctfn_cd                in  varchar2
  ,p_wv_prtn_rsn_ptip_id            in  number
  ,p_lack_ctfn_sspnd_wvr_flag       in  varchar2
  ,p_rqd_flag                       in  varchar2
  ,p_ctfn_rqd_when_rl               in  number
  ,p_pfd_flag                       in  varchar2
  ,p_wv_prtn_ctfn_typ_cd            in  varchar2
  ,p_business_group_id              in  number
  ,p_wct_attribute_category         in  varchar2
  ,p_wct_attribute1                 in  varchar2
  ,p_wct_attribute2                 in  varchar2
  ,p_wct_attribute3                 in  varchar2
  ,p_wct_attribute4                 in  varchar2
  ,p_wct_attribute5                 in  varchar2
  ,p_wct_attribute6                 in  varchar2
  ,p_wct_attribute7                 in  varchar2
  ,p_wct_attribute8                 in  varchar2
  ,p_wct_attribute9                 in  varchar2
  ,p_wct_attribute10                in  varchar2
  ,p_wct_attribute11                in  varchar2
  ,p_wct_attribute12                in  varchar2
  ,p_wct_attribute13                in  varchar2
  ,p_wct_attribute14                in  varchar2
  ,p_wct_attribute15                in  varchar2
  ,p_wct_attribute16                in  varchar2
  ,p_wct_attribute17                in  varchar2
  ,p_wct_attribute18                in  varchar2
  ,p_wct_attribute19                in  varchar2
  ,p_wct_attribute20                in  varchar2
  ,p_wct_attribute21                in  varchar2
  ,p_wct_attribute22                in  varchar2
  ,p_wct_attribute23                in  varchar2
  ,p_wct_attribute24                in  varchar2
  ,p_wct_attribute25                in  varchar2
  ,p_wct_attribute26                in  varchar2
  ,p_wct_attribute27                in  varchar2
  ,p_wct_attribute28                in  varchar2
  ,p_wct_attribute29                in  varchar2
  ,p_wct_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_wv_prtn_rsn_ctfn_ptip_bk1;

 

/
