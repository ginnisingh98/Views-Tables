--------------------------------------------------------
--  DDL for Package BEN_PER_CM_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PER_CM_BK1" AUTHID CURRENT_USER as
/* $Header: bepcmapi.pkh 120.0 2005/05/28 10:11:52 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_PER_CM_b >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_PER_CM_b
  (p_lf_evt_ocrd_dt                 in  date
  ,p_rqstbl_untl_dt                 in  date
  ,p_ler_id                         in  number
  ,p_per_in_ler_id                  in  number
  ,p_prtt_enrt_actn_id              in  number
  ,p_person_id                      in  number
  ,p_bnf_person_id                  in  number
  ,p_dpnt_person_id                 in  number
  ,p_cm_typ_id                      in  number
  ,p_business_group_id              in  number
  ,p_pcm_attribute_category         in  varchar2
  ,p_pcm_attribute1                 in  varchar2
  ,p_pcm_attribute2                 in  varchar2
  ,p_pcm_attribute3                 in  varchar2
  ,p_pcm_attribute4                 in  varchar2
  ,p_pcm_attribute5                 in  varchar2
  ,p_pcm_attribute6                 in  varchar2
  ,p_pcm_attribute7                 in  varchar2
  ,p_pcm_attribute8                 in  varchar2
  ,p_pcm_attribute9                 in  varchar2
  ,p_pcm_attribute10                in  varchar2
  ,p_pcm_attribute11                in  varchar2
  ,p_pcm_attribute12                in  varchar2
  ,p_pcm_attribute13                in  varchar2
  ,p_pcm_attribute14                in  varchar2
  ,p_pcm_attribute15                in  varchar2
  ,p_pcm_attribute16                in  varchar2
  ,p_pcm_attribute17                in  varchar2
  ,p_pcm_attribute18                in  varchar2
  ,p_pcm_attribute19                in  varchar2
  ,p_pcm_attribute20                in  varchar2
  ,p_pcm_attribute21                in  varchar2
  ,p_pcm_attribute22                in  varchar2
  ,p_pcm_attribute23                in  varchar2
  ,p_pcm_attribute24                in  varchar2
  ,p_pcm_attribute25                in  varchar2
  ,p_pcm_attribute26                in  varchar2
  ,p_pcm_attribute27                in  varchar2
  ,p_pcm_attribute28                in  varchar2
  ,p_pcm_attribute29                in  varchar2
  ,p_pcm_attribute30                in  varchar2
  ,p_request_id                     in  number
  ,p_program_application_id         in  number
  ,p_program_id                     in  number
  ,p_program_update_date            in  date
  ,p_effective_date                 in  date);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_PER_CM_a >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_PER_CM_a
  (p_per_cm_id                      in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_lf_evt_ocrd_dt                 in  date
  ,p_rqstbl_untl_dt                 in  date
  ,p_ler_id                         in  number
  ,p_per_in_ler_id                  in  number
  ,p_prtt_enrt_actn_id              in  number
  ,p_person_id                      in  number
  ,p_bnf_person_id                  in  number
  ,p_dpnt_person_id                 in  number
  ,p_cm_typ_id                      in  number
  ,p_business_group_id              in  number
  ,p_pcm_attribute_category         in  varchar2
  ,p_pcm_attribute1                 in  varchar2
  ,p_pcm_attribute2                 in  varchar2
  ,p_pcm_attribute3                 in  varchar2
  ,p_pcm_attribute4                 in  varchar2
  ,p_pcm_attribute5                 in  varchar2
  ,p_pcm_attribute6                 in  varchar2
  ,p_pcm_attribute7                 in  varchar2
  ,p_pcm_attribute8                 in  varchar2
  ,p_pcm_attribute9                 in  varchar2
  ,p_pcm_attribute10                in  varchar2
  ,p_pcm_attribute11                in  varchar2
  ,p_pcm_attribute12                in  varchar2
  ,p_pcm_attribute13                in  varchar2
  ,p_pcm_attribute14                in  varchar2
  ,p_pcm_attribute15                in  varchar2
  ,p_pcm_attribute16                in  varchar2
  ,p_pcm_attribute17                in  varchar2
  ,p_pcm_attribute18                in  varchar2
  ,p_pcm_attribute19                in  varchar2
  ,p_pcm_attribute20                in  varchar2
  ,p_pcm_attribute21                in  varchar2
  ,p_pcm_attribute22                in  varchar2
  ,p_pcm_attribute23                in  varchar2
  ,p_pcm_attribute24                in  varchar2
  ,p_pcm_attribute25                in  varchar2
  ,p_pcm_attribute26                in  varchar2
  ,p_pcm_attribute27                in  varchar2
  ,p_pcm_attribute28                in  varchar2
  ,p_pcm_attribute29                in  varchar2
  ,p_pcm_attribute30                in  varchar2
  ,p_request_id                     in  number
  ,p_program_application_id         in  number
  ,p_program_id                     in  number
  ,p_program_update_date            in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date);
--
end ben_PER_CM_bk1;

 

/
