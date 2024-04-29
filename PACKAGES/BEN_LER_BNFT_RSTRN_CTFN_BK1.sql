--------------------------------------------------------
--  DDL for Package BEN_LER_BNFT_RSTRN_CTFN_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LER_BNFT_RSTRN_CTFN_BK1" AUTHID CURRENT_USER as
/* $Header: belbcapi.pkh 120.0 2005/05/28 03:15:33 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_LER_BNFT_RSTRN_CTFN_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_LER_BNFT_RSTRN_CTFN_b
  (
   p_rqd_flag                       in  varchar2
  ,p_enrt_ctfn_typ_cd               in  varchar2
  ,p_ctfn_rqd_when_rl               in  number
  ,p_ler_bnft_rstrn_id              in  number
  ,p_business_group_id              in  number
  ,p_lbc_attribute_category         in  varchar2
  ,p_lbc_attribute1                 in  varchar2
  ,p_lbc_attribute2                 in  varchar2
  ,p_lbc_attribute3                 in  varchar2
  ,p_lbc_attribute4                 in  varchar2
  ,p_lbc_attribute5                 in  varchar2
  ,p_lbc_attribute6                 in  varchar2
  ,p_lbc_attribute7                 in  varchar2
  ,p_lbc_attribute8                 in  varchar2
  ,p_lbc_attribute9                 in  varchar2
  ,p_lbc_attribute10                in  varchar2
  ,p_lbc_attribute11                in  varchar2
  ,p_lbc_attribute12                in  varchar2
  ,p_lbc_attribute13                in  varchar2
  ,p_lbc_attribute14                in  varchar2
  ,p_lbc_attribute15                in  varchar2
  ,p_lbc_attribute16                in  varchar2
  ,p_lbc_attribute17                in  varchar2
  ,p_lbc_attribute18                in  varchar2
  ,p_lbc_attribute19                in  varchar2
  ,p_lbc_attribute20                in  varchar2
  ,p_lbc_attribute21                in  varchar2
  ,p_lbc_attribute22                in  varchar2
  ,p_lbc_attribute23                in  varchar2
  ,p_lbc_attribute24                in  varchar2
  ,p_lbc_attribute25                in  varchar2
  ,p_lbc_attribute26                in  varchar2
  ,p_lbc_attribute27                in  varchar2
  ,p_lbc_attribute28                in  varchar2
  ,p_lbc_attribute29                in  varchar2
  ,p_lbc_attribute30                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_LER_BNFT_RSTRN_CTFN_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_LER_BNFT_RSTRN_CTFN_a
  (
   p_ler_bnft_rstrn_ctfn_id         in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_rqd_flag                       in  varchar2
  ,p_enrt_ctfn_typ_cd               in  varchar2
  ,p_ctfn_rqd_when_rl               in  number
  ,p_ler_bnft_rstrn_id              in  number
  ,p_business_group_id              in  number
  ,p_lbc_attribute_category         in  varchar2
  ,p_lbc_attribute1                 in  varchar2
  ,p_lbc_attribute2                 in  varchar2
  ,p_lbc_attribute3                 in  varchar2
  ,p_lbc_attribute4                 in  varchar2
  ,p_lbc_attribute5                 in  varchar2
  ,p_lbc_attribute6                 in  varchar2
  ,p_lbc_attribute7                 in  varchar2
  ,p_lbc_attribute8                 in  varchar2
  ,p_lbc_attribute9                 in  varchar2
  ,p_lbc_attribute10                in  varchar2
  ,p_lbc_attribute11                in  varchar2
  ,p_lbc_attribute12                in  varchar2
  ,p_lbc_attribute13                in  varchar2
  ,p_lbc_attribute14                in  varchar2
  ,p_lbc_attribute15                in  varchar2
  ,p_lbc_attribute16                in  varchar2
  ,p_lbc_attribute17                in  varchar2
  ,p_lbc_attribute18                in  varchar2
  ,p_lbc_attribute19                in  varchar2
  ,p_lbc_attribute20                in  varchar2
  ,p_lbc_attribute21                in  varchar2
  ,p_lbc_attribute22                in  varchar2
  ,p_lbc_attribute23                in  varchar2
  ,p_lbc_attribute24                in  varchar2
  ,p_lbc_attribute25                in  varchar2
  ,p_lbc_attribute26                in  varchar2
  ,p_lbc_attribute27                in  varchar2
  ,p_lbc_attribute28                in  varchar2
  ,p_lbc_attribute29                in  varchar2
  ,p_lbc_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_LER_BNFT_RSTRN_CTFN_bk1;

 

/
