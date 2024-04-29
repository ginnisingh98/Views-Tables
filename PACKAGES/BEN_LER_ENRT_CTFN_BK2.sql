--------------------------------------------------------
--  DDL for Package BEN_LER_ENRT_CTFN_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LER_ENRT_CTFN_BK2" AUTHID CURRENT_USER as
/* $Header: belncapi.pkh 120.0 2005/05/28 03:25:30 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ler_enrt_ctfn_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ler_enrt_ctfn_b
  (
   p_ler_enrt_ctfn_id               in  number
  ,p_rqd_flag                       in  varchar2
  ,p_enrt_ctfn_typ_cd               in  varchar2
  ,p_ctfn_rqd_when_rl               in  number
  ,p_ler_rqrs_enrt_ctfn_id          in  number
  ,p_business_group_id              in  number
  ,p_lnc_attribute_category         in  varchar2
  ,p_lnc_attribute1                 in  varchar2
  ,p_lnc_attribute2                 in  varchar2
  ,p_lnc_attribute3                 in  varchar2
  ,p_lnc_attribute4                 in  varchar2
  ,p_lnc_attribute5                 in  varchar2
  ,p_lnc_attribute6                 in  varchar2
  ,p_lnc_attribute7                 in  varchar2
  ,p_lnc_attribute8                 in  varchar2
  ,p_lnc_attribute9                 in  varchar2
  ,p_lnc_attribute10                in  varchar2
  ,p_lnc_attribute11                in  varchar2
  ,p_lnc_attribute12                in  varchar2
  ,p_lnc_attribute13                in  varchar2
  ,p_lnc_attribute14                in  varchar2
  ,p_lnc_attribute15                in  varchar2
  ,p_lnc_attribute16                in  varchar2
  ,p_lnc_attribute17                in  varchar2
  ,p_lnc_attribute18                in  varchar2
  ,p_lnc_attribute19                in  varchar2
  ,p_lnc_attribute20                in  varchar2
  ,p_lnc_attribute21                in  varchar2
  ,p_lnc_attribute22                in  varchar2
  ,p_lnc_attribute23                in  varchar2
  ,p_lnc_attribute24                in  varchar2
  ,p_lnc_attribute25                in  varchar2
  ,p_lnc_attribute26                in  varchar2
  ,p_lnc_attribute27                in  varchar2
  ,p_lnc_attribute28                in  varchar2
  ,p_lnc_attribute29                in  varchar2
  ,p_lnc_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ler_enrt_ctfn_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ler_enrt_ctfn_a
  (
   p_ler_enrt_ctfn_id               in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_rqd_flag                       in  varchar2
  ,p_enrt_ctfn_typ_cd               in  varchar2
  ,p_ctfn_rqd_when_rl               in  number
  ,p_ler_rqrs_enrt_ctfn_id          in  number
  ,p_business_group_id              in  number
  ,p_lnc_attribute_category         in  varchar2
  ,p_lnc_attribute1                 in  varchar2
  ,p_lnc_attribute2                 in  varchar2
  ,p_lnc_attribute3                 in  varchar2
  ,p_lnc_attribute4                 in  varchar2
  ,p_lnc_attribute5                 in  varchar2
  ,p_lnc_attribute6                 in  varchar2
  ,p_lnc_attribute7                 in  varchar2
  ,p_lnc_attribute8                 in  varchar2
  ,p_lnc_attribute9                 in  varchar2
  ,p_lnc_attribute10                in  varchar2
  ,p_lnc_attribute11                in  varchar2
  ,p_lnc_attribute12                in  varchar2
  ,p_lnc_attribute13                in  varchar2
  ,p_lnc_attribute14                in  varchar2
  ,p_lnc_attribute15                in  varchar2
  ,p_lnc_attribute16                in  varchar2
  ,p_lnc_attribute17                in  varchar2
  ,p_lnc_attribute18                in  varchar2
  ,p_lnc_attribute19                in  varchar2
  ,p_lnc_attribute20                in  varchar2
  ,p_lnc_attribute21                in  varchar2
  ,p_lnc_attribute22                in  varchar2
  ,p_lnc_attribute23                in  varchar2
  ,p_lnc_attribute24                in  varchar2
  ,p_lnc_attribute25                in  varchar2
  ,p_lnc_attribute26                in  varchar2
  ,p_lnc_attribute27                in  varchar2
  ,p_lnc_attribute28                in  varchar2
  ,p_lnc_attribute29                in  varchar2
  ,p_lnc_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_ler_enrt_ctfn_bk2;

 

/
