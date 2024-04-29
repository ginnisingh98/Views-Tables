--------------------------------------------------------
--  DDL for Package BEN_ACTY_BASE_RT_CTFN_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ACTY_BASE_RT_CTFN_BK2" AUTHID CURRENT_USER as
/* $Header: beabcapi.pkh 120.0 2005/05/28 00:16:42 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_acty_base_rt_ctfn_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_acty_base_rt_ctfn_b
  (
   p_acty_base_rt_ctfn_id                   in  number
  ,p_enrt_ctfn_typ_cd               in  varchar2
  ,p_ctfn_rqd_when_rl               in  number
  ,p_rqd_flag                       in  varchar2
  ,p_acty_base_rt_id                          in  number
  ,p_business_group_id              in  number
  ,p_abc_attribute_category         in  varchar2
  ,p_abc_attribute1                 in  varchar2
  ,p_abc_attribute2                 in  varchar2
  ,p_abc_attribute3                 in  varchar2
  ,p_abc_attribute4                 in  varchar2
  ,p_abc_attribute5                 in  varchar2
  ,p_abc_attribute6                 in  varchar2
  ,p_abc_attribute7                 in  varchar2
  ,p_abc_attribute8                 in  varchar2
  ,p_abc_attribute9                 in  varchar2
  ,p_abc_attribute10                in  varchar2
  ,p_abc_attribute11                in  varchar2
  ,p_abc_attribute12                in  varchar2
  ,p_abc_attribute13                in  varchar2
  ,p_abc_attribute14                in  varchar2
  ,p_abc_attribute15                in  varchar2
  ,p_abc_attribute16                in  varchar2
  ,p_abc_attribute17                in  varchar2
  ,p_abc_attribute18                in  varchar2
  ,p_abc_attribute19                in  varchar2
  ,p_abc_attribute20                in  varchar2
  ,p_abc_attribute21                in  varchar2
  ,p_abc_attribute22                in  varchar2
  ,p_abc_attribute23                in  varchar2
  ,p_abc_attribute24                in  varchar2
  ,p_abc_attribute25                in  varchar2
  ,p_abc_attribute26                in  varchar2
  ,p_abc_attribute27                in  varchar2
  ,p_abc_attribute28                in  varchar2
  ,p_abc_attribute29                in  varchar2
  ,p_abc_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_acty_base_rt_ctfn_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_acty_base_rt_ctfn_a
  (
   p_acty_base_rt_ctfn_id                   in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_enrt_ctfn_typ_cd               in  varchar2
  ,p_ctfn_rqd_when_rl               in  number
  ,p_rqd_flag                       in  varchar2
  ,p_acty_base_rt_id                          in  number
  ,p_business_group_id              in  number
  ,p_abc_attribute_category         in  varchar2
  ,p_abc_attribute1                 in  varchar2
  ,p_abc_attribute2                 in  varchar2
  ,p_abc_attribute3                 in  varchar2
  ,p_abc_attribute4                 in  varchar2
  ,p_abc_attribute5                 in  varchar2
  ,p_abc_attribute6                 in  varchar2
  ,p_abc_attribute7                 in  varchar2
  ,p_abc_attribute8                 in  varchar2
  ,p_abc_attribute9                 in  varchar2
  ,p_abc_attribute10                in  varchar2
  ,p_abc_attribute11                in  varchar2
  ,p_abc_attribute12                in  varchar2
  ,p_abc_attribute13                in  varchar2
  ,p_abc_attribute14                in  varchar2
  ,p_abc_attribute15                in  varchar2
  ,p_abc_attribute16                in  varchar2
  ,p_abc_attribute17                in  varchar2
  ,p_abc_attribute18                in  varchar2
  ,p_abc_attribute19                in  varchar2
  ,p_abc_attribute20                in  varchar2
  ,p_abc_attribute21                in  varchar2
  ,p_abc_attribute22                in  varchar2
  ,p_abc_attribute23                in  varchar2
  ,p_abc_attribute24                in  varchar2
  ,p_abc_attribute25                in  varchar2
  ,p_abc_attribute26                in  varchar2
  ,p_abc_attribute27                in  varchar2
  ,p_abc_attribute28                in  varchar2
  ,p_abc_attribute29                in  varchar2
  ,p_abc_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_acty_base_rt_ctfn_bk2;

 

/
