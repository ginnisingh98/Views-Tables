--------------------------------------------------------
--  DDL for Package BEN_ELIG_DPNT_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_DPNT_BK2" AUTHID CURRENT_USER as
/* $Header: beegdapi.pkh 120.3.12010000.3 2009/04/10 04:29:26 pvelvano ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ELIG_DPNT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIG_DPNT_b
  (
   p_elig_dpnt_id                   in  number
  ,p_create_dt                      in  date
  ,p_elig_strt_dt                   in  date
  ,p_elig_thru_dt                   in  date
  ,p_ovrdn_flag                     in  varchar2
  ,p_ovrdn_thru_dt                  in  date
  ,p_inelg_rsn_cd                   in  varchar2
  ,p_dpnt_inelig_flag               in  varchar2
  ,p_elig_per_elctbl_chc_id         in  number
  ,p_per_in_ler_id                  in  number
  ,p_elig_per_id                    in  number
  ,p_elig_per_opt_id                in  number
  ,p_elig_cvrd_dpnt_id              in  number
  ,p_dpnt_person_id                 in  number
  ,p_business_group_id              in  number
  ,p_egd_attribute_category         in  varchar2
  ,p_egd_attribute1                 in  varchar2
  ,p_egd_attribute2                 in  varchar2
  ,p_egd_attribute3                 in  varchar2
  ,p_egd_attribute4                 in  varchar2
  ,p_egd_attribute5                 in  varchar2
  ,p_egd_attribute6                 in  varchar2
  ,p_egd_attribute7                 in  varchar2
  ,p_egd_attribute8                 in  varchar2
  ,p_egd_attribute9                 in  varchar2
  ,p_egd_attribute10                in  varchar2
  ,p_egd_attribute11                in  varchar2
  ,p_egd_attribute12                in  varchar2
  ,p_egd_attribute13                in  varchar2
  ,p_egd_attribute14                in  varchar2
  ,p_egd_attribute15                in  varchar2
  ,p_egd_attribute16                in  varchar2
  ,p_egd_attribute17                in  varchar2
  ,p_egd_attribute18                in  varchar2
  ,p_egd_attribute19                in  varchar2
  ,p_egd_attribute20                in  varchar2
  ,p_egd_attribute21                in  varchar2
  ,p_egd_attribute22                in  varchar2
  ,p_egd_attribute23                in  varchar2
  ,p_egd_attribute24                in  varchar2
  ,p_egd_attribute25                in  varchar2
  ,p_egd_attribute26                in  varchar2
  ,p_egd_attribute27                in  varchar2
  ,p_egd_attribute28                in  varchar2
  ,p_egd_attribute29                in  varchar2
  ,p_egd_attribute30                in  varchar2
  ,p_request_id                     in  number
  ,p_program_application_id         in  number
  ,p_program_id                     in  number
  ,p_program_update_date            in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ELIG_DPNT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIG_DPNT_a
  (
   p_elig_dpnt_id                   in  number
  ,p_create_dt                      in  date
  ,p_elig_strt_dt                   in  date
  ,p_elig_thru_dt                   in  date
  ,p_ovrdn_flag                     in  varchar2
  ,p_ovrdn_thru_dt                  in  date
  ,p_inelg_rsn_cd                   in  varchar2
  ,p_dpnt_inelig_flag               in  varchar2
  ,p_elig_per_elctbl_chc_id         in  number
  ,p_per_in_ler_id                  in  number
  ,p_elig_per_id                    in  number
  ,p_elig_per_opt_id                in  number
  ,p_elig_cvrd_dpnt_id              in  number
  ,p_dpnt_person_id                 in  number
  ,p_business_group_id              in  number
  ,p_egd_attribute_category         in  varchar2
  ,p_egd_attribute1                 in  varchar2
  ,p_egd_attribute2                 in  varchar2
  ,p_egd_attribute3                 in  varchar2
  ,p_egd_attribute4                 in  varchar2
  ,p_egd_attribute5                 in  varchar2
  ,p_egd_attribute6                 in  varchar2
  ,p_egd_attribute7                 in  varchar2
  ,p_egd_attribute8                 in  varchar2
  ,p_egd_attribute9                 in  varchar2
  ,p_egd_attribute10                in  varchar2
  ,p_egd_attribute11                in  varchar2
  ,p_egd_attribute12                in  varchar2
  ,p_egd_attribute13                in  varchar2
  ,p_egd_attribute14                in  varchar2
  ,p_egd_attribute15                in  varchar2
  ,p_egd_attribute16                in  varchar2
  ,p_egd_attribute17                in  varchar2
  ,p_egd_attribute18                in  varchar2
  ,p_egd_attribute19                in  varchar2
  ,p_egd_attribute20                in  varchar2
  ,p_egd_attribute21                in  varchar2
  ,p_egd_attribute22                in  varchar2
  ,p_egd_attribute23                in  varchar2
  ,p_egd_attribute24                in  varchar2
  ,p_egd_attribute25                in  varchar2
  ,p_egd_attribute26                in  varchar2
  ,p_egd_attribute27                in  varchar2
  ,p_egd_attribute28                in  varchar2
  ,p_egd_attribute29                in  varchar2
  ,p_egd_attribute30                in  varchar2
  ,p_request_id                     in  number
  ,p_program_application_id         in  number
  ,p_program_id                     in  number
  ,p_program_update_date            in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_ELIG_DPNT_bk2;

/
