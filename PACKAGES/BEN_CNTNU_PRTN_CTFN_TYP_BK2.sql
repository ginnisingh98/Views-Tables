--------------------------------------------------------
--  DDL for Package BEN_CNTNU_PRTN_CTFN_TYP_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CNTNU_PRTN_CTFN_TYP_BK2" AUTHID CURRENT_USER as
/* $Header: becpcapi.pkh 120.0 2005/05/28 01:10:50 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_CNTNU_PRTN_CTFN_TYP_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_CNTNU_PRTN_CTFN_TYP_b
  (
   p_cntnu_prtn_ctfn_typ_id         in  number
  ,p_business_group_id              in  number
  ,p_cntng_prtn_elig_prfl_id        in  number
  ,p_pfd_flag                       in  varchar2
  ,p_lack_ctfn_sspnd_elig_flag      in  varchar2
  ,p_ctfn_rqd_when_rl               in  number
  ,p_prtn_ctfn_typ_cd               in  varchar2
  ,p_cpc_attribute_category         in  varchar2
  ,p_cpc_attribute1                 in  varchar2
  ,p_cpc_attribute2                 in  varchar2
  ,p_cpc_attribute3                 in  varchar2
  ,p_cpc_attribute4                 in  varchar2
  ,p_cpc_attribute5                 in  varchar2
  ,p_cpc_attribute6                 in  varchar2
  ,p_cpc_attribute7                 in  varchar2
  ,p_cpc_attribute8                 in  varchar2
  ,p_cpc_attribute9                 in  varchar2
  ,p_cpc_attribute10                in  varchar2
  ,p_cpc_attribute11                in  varchar2
  ,p_cpc_attribute12                in  varchar2
  ,p_cpc_attribute13                in  varchar2
  ,p_cpc_attribute14                in  varchar2
  ,p_cpc_attribute15                in  varchar2
  ,p_cpc_attribute16                in  varchar2
  ,p_cpc_attribute17                in  varchar2
  ,p_cpc_attribute18                in  varchar2
  ,p_cpc_attribute19                in  varchar2
  ,p_cpc_attribute20                in  varchar2
  ,p_cpc_attribute21                in  varchar2
  ,p_cpc_attribute22                in  varchar2
  ,p_cpc_attribute23                in  varchar2
  ,p_cpc_attribute24                in  varchar2
  ,p_cpc_attribute25                in  varchar2
  ,p_cpc_attribute26                in  varchar2
  ,p_cpc_attribute27                in  varchar2
  ,p_cpc_attribute28                in  varchar2
  ,p_cpc_attribute29                in  varchar2
  ,p_cpc_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_CNTNU_PRTN_CTFN_TYP_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_CNTNU_PRTN_CTFN_TYP_a
  (
   p_cntnu_prtn_ctfn_typ_id         in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_cntng_prtn_elig_prfl_id        in  number
  ,p_pfd_flag                       in  varchar2
  ,p_lack_ctfn_sspnd_elig_flag      in  varchar2
  ,p_ctfn_rqd_when_rl               in  number
  ,p_prtn_ctfn_typ_cd               in  varchar2
  ,p_cpc_attribute_category         in  varchar2
  ,p_cpc_attribute1                 in  varchar2
  ,p_cpc_attribute2                 in  varchar2
  ,p_cpc_attribute3                 in  varchar2
  ,p_cpc_attribute4                 in  varchar2
  ,p_cpc_attribute5                 in  varchar2
  ,p_cpc_attribute6                 in  varchar2
  ,p_cpc_attribute7                 in  varchar2
  ,p_cpc_attribute8                 in  varchar2
  ,p_cpc_attribute9                 in  varchar2
  ,p_cpc_attribute10                in  varchar2
  ,p_cpc_attribute11                in  varchar2
  ,p_cpc_attribute12                in  varchar2
  ,p_cpc_attribute13                in  varchar2
  ,p_cpc_attribute14                in  varchar2
  ,p_cpc_attribute15                in  varchar2
  ,p_cpc_attribute16                in  varchar2
  ,p_cpc_attribute17                in  varchar2
  ,p_cpc_attribute18                in  varchar2
  ,p_cpc_attribute19                in  varchar2
  ,p_cpc_attribute20                in  varchar2
  ,p_cpc_attribute21                in  varchar2
  ,p_cpc_attribute22                in  varchar2
  ,p_cpc_attribute23                in  varchar2
  ,p_cpc_attribute24                in  varchar2
  ,p_cpc_attribute25                in  varchar2
  ,p_cpc_attribute26                in  varchar2
  ,p_cpc_attribute27                in  varchar2
  ,p_cpc_attribute28                in  varchar2
  ,p_cpc_attribute29                in  varchar2
  ,p_cpc_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_CNTNU_PRTN_CTFN_TYP_bk2;

 

/
