--------------------------------------------------------
--  DDL for Package BEN_ENRT_RT_CTFN_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ENRT_RT_CTFN_BK2" AUTHID CURRENT_USER as
/* $Header: beercapi.pkh 120.0 2005/05/28 02:50:32 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_enrt_rt_ctfn_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_enrt_rt_ctfn_b
  (
   p_enrt_rt_ctfn_id             in  number
  ,p_enrt_ctfn_typ_cd               in  varchar2
  ,p_rqd_flag                       in  varchar2
  ,p_enrt_rt_id         in  number
  ,p_business_group_id              in  number
  ,p_erc_attribute_category         in  varchar2
  ,p_erc_attribute1                 in  varchar2
  ,p_erc_attribute2                 in  varchar2
  ,p_erc_attribute3                 in  varchar2
  ,p_erc_attribute4                 in  varchar2
  ,p_erc_attribute5                 in  varchar2
  ,p_erc_attribute6                 in  varchar2
  ,p_erc_attribute7                 in  varchar2
  ,p_erc_attribute8                 in  varchar2
  ,p_erc_attribute9                 in  varchar2
  ,p_erc_attribute10                in  varchar2
  ,p_erc_attribute11                in  varchar2
  ,p_erc_attribute12                in  varchar2
  ,p_erc_attribute13                in  varchar2
  ,p_erc_attribute14                in  varchar2
  ,p_erc_attribute15                in  varchar2
  ,p_erc_attribute16                in  varchar2
  ,p_erc_attribute17                in  varchar2
  ,p_erc_attribute18                in  varchar2
  ,p_erc_attribute19                in  varchar2
  ,p_erc_attribute20                in  varchar2
  ,p_erc_attribute21                in  varchar2
  ,p_erc_attribute22                in  varchar2
  ,p_erc_attribute23                in  varchar2
  ,p_erc_attribute24                in  varchar2
  ,p_erc_attribute25                in  varchar2
  ,p_erc_attribute26                in  varchar2
  ,p_erc_attribute27                in  varchar2
  ,p_erc_attribute28                in  varchar2
  ,p_erc_attribute29                in  varchar2
  ,p_erc_attribute30                in  varchar2
  ,p_request_id                     in  number
  ,p_program_application_id         in  number
  ,p_program_id                     in  number
  ,p_program_update_date            in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_enrt_rt_ctfn_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_enrt_rt_ctfn_a
  (
   p_enrt_rt_ctfn_id             in  number
  ,p_enrt_ctfn_typ_cd               in  varchar2
  ,p_rqd_flag                       in  varchar2
  ,p_enrt_rt_id         in  number
  ,p_business_group_id              in  number
  ,p_erc_attribute_category         in  varchar2
  ,p_erc_attribute1                 in  varchar2
  ,p_erc_attribute2                 in  varchar2
  ,p_erc_attribute3                 in  varchar2
  ,p_erc_attribute4                 in  varchar2
  ,p_erc_attribute5                 in  varchar2
  ,p_erc_attribute6                 in  varchar2
  ,p_erc_attribute7                 in  varchar2
  ,p_erc_attribute8                 in  varchar2
  ,p_erc_attribute9                 in  varchar2
  ,p_erc_attribute10                in  varchar2
  ,p_erc_attribute11                in  varchar2
  ,p_erc_attribute12                in  varchar2
  ,p_erc_attribute13                in  varchar2
  ,p_erc_attribute14                in  varchar2
  ,p_erc_attribute15                in  varchar2
  ,p_erc_attribute16                in  varchar2
  ,p_erc_attribute17                in  varchar2
  ,p_erc_attribute18                in  varchar2
  ,p_erc_attribute19                in  varchar2
  ,p_erc_attribute20                in  varchar2
  ,p_erc_attribute21                in  varchar2
  ,p_erc_attribute22                in  varchar2
  ,p_erc_attribute23                in  varchar2
  ,p_erc_attribute24                in  varchar2
  ,p_erc_attribute25                in  varchar2
  ,p_erc_attribute26                in  varchar2
  ,p_erc_attribute27                in  varchar2
  ,p_erc_attribute28                in  varchar2
  ,p_erc_attribute29                in  varchar2
  ,p_erc_attribute30                in  varchar2
  ,p_request_id                     in  number
  ,p_program_application_id         in  number
  ,p_program_id                     in  number
  ,p_program_update_date            in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_enrt_rt_ctfn_bk2;

 

/
