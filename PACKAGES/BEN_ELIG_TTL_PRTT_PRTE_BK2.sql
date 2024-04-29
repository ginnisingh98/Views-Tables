--------------------------------------------------------
--  DDL for Package BEN_ELIG_TTL_PRTT_PRTE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_TTL_PRTT_PRTE_BK2" AUTHID CURRENT_USER as
/* $Header: beetpapi.pkh 120.0 2005/05/28 03:02:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ELIG_TTL_PRTT_PRTE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIG_TTL_PRTT_PRTE_b
  (
   p_ELIG_TTL_PRTT_PRTE_id          in  number
  ,p_business_group_id              in  number
  ,p_excld_flag                     in  varchar2
  ,p_no_mn_prtt_num_apls_flag       in  varchar2
  ,p_no_mx_prtt_num_apls_flag       in  varchar2
  ,p_ordr_num                       in  number
  ,p_mn_prtt_num                    in  number
  ,p_mx_prtt_num                    in  number
  ,p_prtt_det_cd                    in  varchar2
  ,p_prtt_det_rl                    in  number
  ,p_eligy_prfl_id                  in  number
  ,p_etp_attribute_category         in  varchar2
  ,p_etp_attribute1                 in  varchar2
  ,p_etp_attribute2                 in  varchar2
  ,p_etp_attribute3                 in  varchar2
  ,p_etp_attribute4                 in  varchar2
  ,p_etp_attribute5                 in  varchar2
  ,p_etp_attribute6                 in  varchar2
  ,p_etp_attribute7                 in  varchar2
  ,p_etp_attribute8                 in  varchar2
  ,p_etp_attribute9                 in  varchar2
  ,p_etp_attribute10                in  varchar2
  ,p_etp_attribute11                in  varchar2
  ,p_etp_attribute12                in  varchar2
  ,p_etp_attribute13                in  varchar2
  ,p_etp_attribute14                in  varchar2
  ,p_etp_attribute15                in  varchar2
  ,p_etp_attribute16                in  varchar2
  ,p_etp_attribute17                in  varchar2
  ,p_etp_attribute18                in  varchar2
  ,p_etp_attribute19                in  varchar2
  ,p_etp_attribute20                in  varchar2
  ,p_etp_attribute21                in  varchar2
  ,p_etp_attribute22                in  varchar2
  ,p_etp_attribute23                in  varchar2
  ,p_etp_attribute24                in  varchar2
  ,p_etp_attribute25                in  varchar2
  ,p_etp_attribute26                in  varchar2
  ,p_etp_attribute27                in  varchar2
  ,p_etp_attribute28                in  varchar2
  ,p_etp_attribute29                in  varchar2
  ,p_etp_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ELIG_TTL_PRTT_PRTE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIG_TTL_PRTT_PRTE_a
  (
   p_ELIG_TTL_PRTT_PRTE_id          in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_excld_flag                     in  varchar2
  ,p_no_mn_prtt_num_apls_flag       in  varchar2
  ,p_no_mx_prtt_num_apls_flag       in  varchar2
  ,p_ordr_num                       in  number
  ,p_mn_prtt_num                    in  number
  ,p_mx_prtt_num                    in  number
  ,p_prtt_det_cd                    in  varchar2
  ,p_prtt_det_rl                    in  number
  ,p_eligy_prfl_id                  in  number
  ,p_etp_attribute_category         in  varchar2
  ,p_etp_attribute1                 in  varchar2
  ,p_etp_attribute2                 in  varchar2
  ,p_etp_attribute3                 in  varchar2
  ,p_etp_attribute4                 in  varchar2
  ,p_etp_attribute5                 in  varchar2
  ,p_etp_attribute6                 in  varchar2
  ,p_etp_attribute7                 in  varchar2
  ,p_etp_attribute8                 in  varchar2
  ,p_etp_attribute9                 in  varchar2
  ,p_etp_attribute10                in  varchar2
  ,p_etp_attribute11                in  varchar2
  ,p_etp_attribute12                in  varchar2
  ,p_etp_attribute13                in  varchar2
  ,p_etp_attribute14                in  varchar2
  ,p_etp_attribute15                in  varchar2
  ,p_etp_attribute16                in  varchar2
  ,p_etp_attribute17                in  varchar2
  ,p_etp_attribute18                in  varchar2
  ,p_etp_attribute19                in  varchar2
  ,p_etp_attribute20                in  varchar2
  ,p_etp_attribute21                in  varchar2
  ,p_etp_attribute22                in  varchar2
  ,p_etp_attribute23                in  varchar2
  ,p_etp_attribute24                in  varchar2
  ,p_etp_attribute25                in  varchar2
  ,p_etp_attribute26                in  varchar2
  ,p_etp_attribute27                in  varchar2
  ,p_etp_attribute28                in  varchar2
  ,p_etp_attribute29                in  varchar2
  ,p_etp_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_ELIG_TTL_PRTT_PRTE_bk2;

 

/
