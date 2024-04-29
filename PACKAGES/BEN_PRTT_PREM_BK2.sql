--------------------------------------------------------
--  DDL for Package BEN_PRTT_PREM_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PRTT_PREM_BK2" AUTHID CURRENT_USER as
/* $Header: beppeapi.pkh 120.0.12000000.1 2007/01/19 21:44:45 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_PRTT_PREM_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_PRTT_PREM_b
  (
   p_prtt_prem_id                   in  number
  ,p_std_prem_uom                   in  varchar2
  ,p_std_prem_val                   in  number
  ,p_actl_prem_id                   in  number
  ,p_prtt_enrt_rslt_id              in  number
  ,p_per_in_ler_id              in  number
  ,p_business_group_id              in  number
  ,p_ppe_attribute_category         in  varchar2
  ,p_ppe_attribute1                 in  varchar2
  ,p_ppe_attribute2                 in  varchar2
  ,p_ppe_attribute3                 in  varchar2
  ,p_ppe_attribute4                 in  varchar2
  ,p_ppe_attribute5                 in  varchar2
  ,p_ppe_attribute6                 in  varchar2
  ,p_ppe_attribute7                 in  varchar2
  ,p_ppe_attribute8                 in  varchar2
  ,p_ppe_attribute9                 in  varchar2
  ,p_ppe_attribute10                in  varchar2
  ,p_ppe_attribute11                in  varchar2
  ,p_ppe_attribute12                in  varchar2
  ,p_ppe_attribute13                in  varchar2
  ,p_ppe_attribute14                in  varchar2
  ,p_ppe_attribute15                in  varchar2
  ,p_ppe_attribute16                in  varchar2
  ,p_ppe_attribute17                in  varchar2
  ,p_ppe_attribute18                in  varchar2
  ,p_ppe_attribute19                in  varchar2
  ,p_ppe_attribute20                in  varchar2
  ,p_ppe_attribute21                in  varchar2
  ,p_ppe_attribute22                in  varchar2
  ,p_ppe_attribute23                in  varchar2
  ,p_ppe_attribute24                in  varchar2
  ,p_ppe_attribute25                in  varchar2
  ,p_ppe_attribute26                in  varchar2
  ,p_ppe_attribute27                in  varchar2
  ,p_ppe_attribute28                in  varchar2
  ,p_ppe_attribute29                in  varchar2
  ,p_ppe_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_request_id                     in  number
  ,p_program_application_id         in  number
  ,p_program_id                     in  number
  ,p_program_update_date            in  date
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_PRTT_PREM_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_PRTT_PREM_a
  (
   p_prtt_prem_id                   in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_std_prem_uom                   in  varchar2
  ,p_std_prem_val                   in  number
  ,p_actl_prem_id                   in  number
  ,p_prtt_enrt_rslt_id              in  number
  ,p_per_in_ler_id              in  number
  ,p_business_group_id              in  number
  ,p_ppe_attribute_category         in  varchar2
  ,p_ppe_attribute1                 in  varchar2
  ,p_ppe_attribute2                 in  varchar2
  ,p_ppe_attribute3                 in  varchar2
  ,p_ppe_attribute4                 in  varchar2
  ,p_ppe_attribute5                 in  varchar2
  ,p_ppe_attribute6                 in  varchar2
  ,p_ppe_attribute7                 in  varchar2
  ,p_ppe_attribute8                 in  varchar2
  ,p_ppe_attribute9                 in  varchar2
  ,p_ppe_attribute10                in  varchar2
  ,p_ppe_attribute11                in  varchar2
  ,p_ppe_attribute12                in  varchar2
  ,p_ppe_attribute13                in  varchar2
  ,p_ppe_attribute14                in  varchar2
  ,p_ppe_attribute15                in  varchar2
  ,p_ppe_attribute16                in  varchar2
  ,p_ppe_attribute17                in  varchar2
  ,p_ppe_attribute18                in  varchar2
  ,p_ppe_attribute19                in  varchar2
  ,p_ppe_attribute20                in  varchar2
  ,p_ppe_attribute21                in  varchar2
  ,p_ppe_attribute22                in  varchar2
  ,p_ppe_attribute23                in  varchar2
  ,p_ppe_attribute24                in  varchar2
  ,p_ppe_attribute25                in  varchar2
  ,p_ppe_attribute26                in  varchar2
  ,p_ppe_attribute27                in  varchar2
  ,p_ppe_attribute28                in  varchar2
  ,p_ppe_attribute29                in  varchar2
  ,p_ppe_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_request_id                     in  number
  ,p_program_application_id         in  number
  ,p_program_id                     in  number
  ,p_program_update_date            in  date
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_PRTT_PREM_bk2;

 

/
