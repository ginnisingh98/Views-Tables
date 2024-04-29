--------------------------------------------------------
--  DDL for Package BEN_ENRT_PREM_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ENRT_PREM_BK2" AUTHID CURRENT_USER as
/* $Header: beeprapi.pkh 120.0 2005/05/28 02:43:54 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_enrt_prem_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_enrt_prem_b
  (
   p_enrt_prem_id                   in  number
  ,p_val                            in  number
  ,p_uom                            in  varchar2
  ,p_elig_per_elctbl_chc_id         in  number
  ,p_enrt_bnft_id                   in  number
  ,p_actl_prem_id                   in  number
  ,p_business_group_id              in  number
  ,p_epr_attribute_category         in  varchar2
  ,p_epr_attribute1                 in  varchar2
  ,p_epr_attribute2                 in  varchar2
  ,p_epr_attribute3                 in  varchar2
  ,p_epr_attribute4                 in  varchar2
  ,p_epr_attribute5                 in  varchar2
  ,p_epr_attribute6                 in  varchar2
  ,p_epr_attribute7                 in  varchar2
  ,p_epr_attribute8                 in  varchar2
  ,p_epr_attribute9                 in  varchar2
  ,p_epr_attribute10                in  varchar2
  ,p_epr_attribute11                in  varchar2
  ,p_epr_attribute12                in  varchar2
  ,p_epr_attribute13                in  varchar2
  ,p_epr_attribute14                in  varchar2
  ,p_epr_attribute15                in  varchar2
  ,p_epr_attribute16                in  varchar2
  ,p_epr_attribute17                in  varchar2
  ,p_epr_attribute18                in  varchar2
  ,p_epr_attribute19                in  varchar2
  ,p_epr_attribute20                in  varchar2
  ,p_epr_attribute21                in  varchar2
  ,p_epr_attribute22                in  varchar2
  ,p_epr_attribute23                in  varchar2
  ,p_epr_attribute24                in  varchar2
  ,p_epr_attribute25                in  varchar2
  ,p_epr_attribute26                in  varchar2
  ,p_epr_attribute27                in  varchar2
  ,p_epr_attribute28                in  varchar2
  ,p_epr_attribute29                in  varchar2
  ,p_epr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_request_id                     in  number
  ,p_program_application_id         in  number
  ,p_program_id                     in  number
  ,p_program_update_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_enrt_prem_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_enrt_prem_a
  (
   p_enrt_prem_id                   in  number
  ,p_val                            in  number
  ,p_uom                            in  varchar2
  ,p_elig_per_elctbl_chc_id         in  number
  ,p_enrt_bnft_id                   in  number
  ,p_actl_prem_id                   in  number
  ,p_business_group_id              in  number
  ,p_epr_attribute_category         in  varchar2
  ,p_epr_attribute1                 in  varchar2
  ,p_epr_attribute2                 in  varchar2
  ,p_epr_attribute3                 in  varchar2
  ,p_epr_attribute4                 in  varchar2
  ,p_epr_attribute5                 in  varchar2
  ,p_epr_attribute6                 in  varchar2
  ,p_epr_attribute7                 in  varchar2
  ,p_epr_attribute8                 in  varchar2
  ,p_epr_attribute9                 in  varchar2
  ,p_epr_attribute10                in  varchar2
  ,p_epr_attribute11                in  varchar2
  ,p_epr_attribute12                in  varchar2
  ,p_epr_attribute13                in  varchar2
  ,p_epr_attribute14                in  varchar2
  ,p_epr_attribute15                in  varchar2
  ,p_epr_attribute16                in  varchar2
  ,p_epr_attribute17                in  varchar2
  ,p_epr_attribute18                in  varchar2
  ,p_epr_attribute19                in  varchar2
  ,p_epr_attribute20                in  varchar2
  ,p_epr_attribute21                in  varchar2
  ,p_epr_attribute22                in  varchar2
  ,p_epr_attribute23                in  varchar2
  ,p_epr_attribute24                in  varchar2
  ,p_epr_attribute25                in  varchar2
  ,p_epr_attribute26                in  varchar2
  ,p_epr_attribute27                in  varchar2
  ,p_epr_attribute28                in  varchar2
  ,p_epr_attribute29                in  varchar2
  ,p_epr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_request_id                     in  number
  ,p_program_application_id         in  number
  ,p_program_id                     in  number
  ,p_program_update_date            in  date
  );
--
end ben_enrt_prem_bk2;

 

/
