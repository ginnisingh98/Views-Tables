--------------------------------------------------------
--  DDL for Package BEN_ELIG_CVRD_DPNT_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_CVRD_DPNT_BK1" AUTHID CURRENT_USER as
/* $Header: bepdpapi.pkh 120.0.12000000.1 2007/01/19 20:54:51 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ELIG_CVRD_DPNT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELIG_CVRD_DPNT_b
  (
   p_business_group_id              in  number
  ,p_prtt_enrt_rslt_id              in  number
  ,p_dpnt_person_id                 in  number
  ,p_cvg_strt_dt                    in  date
  ,p_cvg_thru_dt                    in  date
  ,p_cvg_pndg_flag                  in  varchar2
  ,p_pdp_attribute_category         in  varchar2
  ,p_pdp_attribute1                 in  varchar2
  ,p_pdp_attribute2                 in  varchar2
  ,p_pdp_attribute3                 in  varchar2
  ,p_pdp_attribute4                 in  varchar2
  ,p_pdp_attribute5                 in  varchar2
  ,p_pdp_attribute6                 in  varchar2
  ,p_pdp_attribute7                 in  varchar2
  ,p_pdp_attribute8                 in  varchar2
  ,p_pdp_attribute9                 in  varchar2
  ,p_pdp_attribute10                in  varchar2
  ,p_pdp_attribute11                in  varchar2
  ,p_pdp_attribute12                in  varchar2
  ,p_pdp_attribute13                in  varchar2
  ,p_pdp_attribute14                in  varchar2
  ,p_pdp_attribute15                in  varchar2
  ,p_pdp_attribute16                in  varchar2
  ,p_pdp_attribute17                in  varchar2
  ,p_pdp_attribute18                in  varchar2
  ,p_pdp_attribute19                in  varchar2
  ,p_pdp_attribute20                in  varchar2
  ,p_pdp_attribute21                in  varchar2
  ,p_pdp_attribute22                in  varchar2
  ,p_pdp_attribute23                in  varchar2
  ,p_pdp_attribute24                in  varchar2
  ,p_pdp_attribute25                in  varchar2
  ,p_pdp_attribute26                in  varchar2
  ,p_pdp_attribute27                in  varchar2
  ,p_pdp_attribute28                in  varchar2
  ,p_pdp_attribute29                in  varchar2
  ,p_pdp_attribute30                in  varchar2
  ,p_request_id                     in  number
  ,p_program_application_id         in  number
  ,p_program_id                     in  number
  ,p_program_update_date            in  date
  ,p_ovrdn_flag                     in  varchar2
  ,p_per_in_ler_id                  in  number
  ,p_ovrdn_thru_dt                  in  date
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ELIG_CVRD_DPNT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELIG_CVRD_DPNT_a
  (
   p_elig_cvrd_dpnt_id              in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_prtt_enrt_rslt_id              in  number
  ,p_dpnt_person_id                 in  number
  ,p_cvg_strt_dt                    in  date
  ,p_cvg_thru_dt                    in  date
  ,p_cvg_pndg_flag                  in  varchar2
  ,p_pdp_attribute_category         in  varchar2
  ,p_pdp_attribute1                 in  varchar2
  ,p_pdp_attribute2                 in  varchar2
  ,p_pdp_attribute3                 in  varchar2
  ,p_pdp_attribute4                 in  varchar2
  ,p_pdp_attribute5                 in  varchar2
  ,p_pdp_attribute6                 in  varchar2
  ,p_pdp_attribute7                 in  varchar2
  ,p_pdp_attribute8                 in  varchar2
  ,p_pdp_attribute9                 in  varchar2
  ,p_pdp_attribute10                in  varchar2
  ,p_pdp_attribute11                in  varchar2
  ,p_pdp_attribute12                in  varchar2
  ,p_pdp_attribute13                in  varchar2
  ,p_pdp_attribute14                in  varchar2
  ,p_pdp_attribute15                in  varchar2
  ,p_pdp_attribute16                in  varchar2
  ,p_pdp_attribute17                in  varchar2
  ,p_pdp_attribute18                in  varchar2
  ,p_pdp_attribute19                in  varchar2
  ,p_pdp_attribute20                in  varchar2
  ,p_pdp_attribute21                in  varchar2
  ,p_pdp_attribute22                in  varchar2
  ,p_pdp_attribute23                in  varchar2
  ,p_pdp_attribute24                in  varchar2
  ,p_pdp_attribute25                in  varchar2
  ,p_pdp_attribute26                in  varchar2
  ,p_pdp_attribute27                in  varchar2
  ,p_pdp_attribute28                in  varchar2
  ,p_pdp_attribute29                in  varchar2
  ,p_pdp_attribute30                in  varchar2
  ,p_request_id                     in  number
  ,p_program_application_id         in  number
  ,p_program_id                     in  number
  ,p_program_update_date            in  date
  ,p_object_version_number          in  number
  ,p_ovrdn_flag                     in  varchar2
  ,p_per_in_ler_id                  in  number
  ,p_ovrdn_thru_dt                  in  date
  ,p_effective_date                 in  date
  );
--
end ben_ELIG_CVRD_DPNT_bk1;

 

/
