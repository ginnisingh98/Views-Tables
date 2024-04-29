--------------------------------------------------------
--  DDL for Package BEN_BNFT_RSTRN_CTFN_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BNFT_RSTRN_CTFN_BK2" AUTHID CURRENT_USER as
/* $Header: bebrcapi.pkh 120.0 2005/05/28 00:49:57 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_BNFT_RSTRN_CTFN_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_BNFT_RSTRN_CTFN_b
  (
   p_bnft_rstrn_ctfn_id             in  number
  ,p_rqd_flag                       in  varchar2
  ,p_enrt_ctfn_typ_cd               in  varchar2
  ,p_ctfn_rqd_when_rl               in  number
  ,p_pl_id                          in  number
  ,p_business_group_id              in  number
  ,p_brc_attribute_category         in  varchar2
  ,p_brc_attribute1                 in  varchar2
  ,p_brc_attribute2                 in  varchar2
  ,p_brc_attribute3                 in  varchar2
  ,p_brc_attribute4                 in  varchar2
  ,p_brc_attribute5                 in  varchar2
  ,p_brc_attribute6                 in  varchar2
  ,p_brc_attribute7                 in  varchar2
  ,p_brc_attribute8                 in  varchar2
  ,p_brc_attribute9                 in  varchar2
  ,p_brc_attribute10                in  varchar2
  ,p_brc_attribute11                in  varchar2
  ,p_brc_attribute12                in  varchar2
  ,p_brc_attribute13                in  varchar2
  ,p_brc_attribute14                in  varchar2
  ,p_brc_attribute15                in  varchar2
  ,p_brc_attribute16                in  varchar2
  ,p_brc_attribute17                in  varchar2
  ,p_brc_attribute18                in  varchar2
  ,p_brc_attribute19                in  varchar2
  ,p_brc_attribute20                in  varchar2
  ,p_brc_attribute21                in  varchar2
  ,p_brc_attribute22                in  varchar2
  ,p_brc_attribute23                in  varchar2
  ,p_brc_attribute24                in  varchar2
  ,p_brc_attribute25                in  varchar2
  ,p_brc_attribute26                in  varchar2
  ,p_brc_attribute27                in  varchar2
  ,p_brc_attribute28                in  varchar2
  ,p_brc_attribute29                in  varchar2
  ,p_brc_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_BNFT_RSTRN_CTFN_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_BNFT_RSTRN_CTFN_a
  (
   p_bnft_rstrn_ctfn_id             in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_rqd_flag                       in  varchar2
  ,p_enrt_ctfn_typ_cd               in  varchar2
  ,p_ctfn_rqd_when_rl               in  number
  ,p_pl_id                          in  number
  ,p_business_group_id              in  number
  ,p_brc_attribute_category         in  varchar2
  ,p_brc_attribute1                 in  varchar2
  ,p_brc_attribute2                 in  varchar2
  ,p_brc_attribute3                 in  varchar2
  ,p_brc_attribute4                 in  varchar2
  ,p_brc_attribute5                 in  varchar2
  ,p_brc_attribute6                 in  varchar2
  ,p_brc_attribute7                 in  varchar2
  ,p_brc_attribute8                 in  varchar2
  ,p_brc_attribute9                 in  varchar2
  ,p_brc_attribute10                in  varchar2
  ,p_brc_attribute11                in  varchar2
  ,p_brc_attribute12                in  varchar2
  ,p_brc_attribute13                in  varchar2
  ,p_brc_attribute14                in  varchar2
  ,p_brc_attribute15                in  varchar2
  ,p_brc_attribute16                in  varchar2
  ,p_brc_attribute17                in  varchar2
  ,p_brc_attribute18                in  varchar2
  ,p_brc_attribute19                in  varchar2
  ,p_brc_attribute20                in  varchar2
  ,p_brc_attribute21                in  varchar2
  ,p_brc_attribute22                in  varchar2
  ,p_brc_attribute23                in  varchar2
  ,p_brc_attribute24                in  varchar2
  ,p_brc_attribute25                in  varchar2
  ,p_brc_attribute26                in  varchar2
  ,p_brc_attribute27                in  varchar2
  ,p_brc_attribute28                in  varchar2
  ,p_brc_attribute29                in  varchar2
  ,p_brc_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_BNFT_RSTRN_CTFN_bk2;

 

/
