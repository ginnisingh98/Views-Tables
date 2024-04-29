--------------------------------------------------------
--  DDL for Package BEN_ENRT_CTFN_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ENRT_CTFN_BK1" AUTHID CURRENT_USER as
/* $Header: beecfapi.pkh 120.0 2005/05/28 01:49:46 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_Enrt_Ctfn_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_Enrt_Ctfn_b
  (
   p_enrt_ctfn_typ_cd               in  varchar2
  ,p_ctfn_rqd_when_rl               in  number
  ,p_rqd_flag                       in  varchar2
  ,p_pl_id                          in  number
  ,p_business_group_id              in  number
  ,p_ecf_attribute_category         in  varchar2
  ,p_ecf_attribute1                 in  varchar2
  ,p_ecf_attribute2                 in  varchar2
  ,p_ecf_attribute3                 in  varchar2
  ,p_ecf_attribute4                 in  varchar2
  ,p_ecf_attribute5                 in  varchar2
  ,p_ecf_attribute6                 in  varchar2
  ,p_ecf_attribute7                 in  varchar2
  ,p_ecf_attribute8                 in  varchar2
  ,p_ecf_attribute9                 in  varchar2
  ,p_ecf_attribute10                in  varchar2
  ,p_ecf_attribute11                in  varchar2
  ,p_ecf_attribute12                in  varchar2
  ,p_ecf_attribute13                in  varchar2
  ,p_ecf_attribute14                in  varchar2
  ,p_ecf_attribute15                in  varchar2
  ,p_ecf_attribute16                in  varchar2
  ,p_ecf_attribute17                in  varchar2
  ,p_ecf_attribute18                in  varchar2
  ,p_ecf_attribute19                in  varchar2
  ,p_ecf_attribute20                in  varchar2
  ,p_ecf_attribute21                in  varchar2
  ,p_ecf_attribute22                in  varchar2
  ,p_ecf_attribute23                in  varchar2
  ,p_ecf_attribute24                in  varchar2
  ,p_ecf_attribute25                in  varchar2
  ,p_ecf_attribute26                in  varchar2
  ,p_ecf_attribute27                in  varchar2
  ,p_ecf_attribute28                in  varchar2
  ,p_ecf_attribute29                in  varchar2
  ,p_ecf_attribute30                in  varchar2
  ,p_oipl_id                        in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_Enrt_Ctfn_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_Enrt_Ctfn_a
  (
   p_enrt_ctfn_id                   in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_enrt_ctfn_typ_cd               in  varchar2
  ,p_ctfn_rqd_when_rl               in  number
  ,p_rqd_flag                       in  varchar2
  ,p_pl_id                          in  number
  ,p_business_group_id              in  number
  ,p_ecf_attribute_category         in  varchar2
  ,p_ecf_attribute1                 in  varchar2
  ,p_ecf_attribute2                 in  varchar2
  ,p_ecf_attribute3                 in  varchar2
  ,p_ecf_attribute4                 in  varchar2
  ,p_ecf_attribute5                 in  varchar2
  ,p_ecf_attribute6                 in  varchar2
  ,p_ecf_attribute7                 in  varchar2
  ,p_ecf_attribute8                 in  varchar2
  ,p_ecf_attribute9                 in  varchar2
  ,p_ecf_attribute10                in  varchar2
  ,p_ecf_attribute11                in  varchar2
  ,p_ecf_attribute12                in  varchar2
  ,p_ecf_attribute13                in  varchar2
  ,p_ecf_attribute14                in  varchar2
  ,p_ecf_attribute15                in  varchar2
  ,p_ecf_attribute16                in  varchar2
  ,p_ecf_attribute17                in  varchar2
  ,p_ecf_attribute18                in  varchar2
  ,p_ecf_attribute19                in  varchar2
  ,p_ecf_attribute20                in  varchar2
  ,p_ecf_attribute21                in  varchar2
  ,p_ecf_attribute22                in  varchar2
  ,p_ecf_attribute23                in  varchar2
  ,p_ecf_attribute24                in  varchar2
  ,p_ecf_attribute25                in  varchar2
  ,p_ecf_attribute26                in  varchar2
  ,p_ecf_attribute27                in  varchar2
  ,p_ecf_attribute28                in  varchar2
  ,p_ecf_attribute29                in  varchar2
  ,p_ecf_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_oipl_id                        in  number
  ,p_effective_date                 in  date
  );
--
end ben_Enrt_Ctfn_bk1;

 

/
