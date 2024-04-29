--------------------------------------------------------
--  DDL for Package BEN_ELIG_ENRLD_ANTHR_PGM_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_ENRLD_ANTHR_PGM_BK2" AUTHID CURRENT_USER as
/* $Header: beeegapi.pkh 120.0 2005/05/28 02:03:20 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ELIG_ENRLD_ANTHR_PGM_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIG_ENRLD_ANTHR_PGM_b
  (
   p_elig_enrld_anthr_pgm_id        in  number
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_enrl_det_dt_cd                 in  varchar2
  ,p_pgm_id                         in  number
  ,p_eligy_prfl_id                  in  number
  ,p_business_group_id              in  number
  ,p_eeg_attribute_category         in  varchar2
  ,p_eeg_attribute1                 in  varchar2
  ,p_eeg_attribute2                 in  varchar2
  ,p_eeg_attribute3                 in  varchar2
  ,p_eeg_attribute4                 in  varchar2
  ,p_eeg_attribute5                 in  varchar2
  ,p_eeg_attribute6                 in  varchar2
  ,p_eeg_attribute7                 in  varchar2
  ,p_eeg_attribute8                 in  varchar2
  ,p_eeg_attribute9                 in  varchar2
  ,p_eeg_attribute10                in  varchar2
  ,p_eeg_attribute11                in  varchar2
  ,p_eeg_attribute12                in  varchar2
  ,p_eeg_attribute13                in  varchar2
  ,p_eeg_attribute14                in  varchar2
  ,p_eeg_attribute15                in  varchar2
  ,p_eeg_attribute16                in  varchar2
  ,p_eeg_attribute17                in  varchar2
  ,p_eeg_attribute18                in  varchar2
  ,p_eeg_attribute19                in  varchar2
  ,p_eeg_attribute20                in  varchar2
  ,p_eeg_attribute21                in  varchar2
  ,p_eeg_attribute22                in  varchar2
  ,p_eeg_attribute23                in  varchar2
  ,p_eeg_attribute24                in  varchar2
  ,p_eeg_attribute25                in  varchar2
  ,p_eeg_attribute26                in  varchar2
  ,p_eeg_attribute27                in  varchar2
  ,p_eeg_attribute28                in  varchar2
  ,p_eeg_attribute29                in  varchar2
  ,p_eeg_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ELIG_ENRLD_ANTHR_PGM_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIG_ENRLD_ANTHR_PGM_a
  (
   p_elig_enrld_anthr_pgm_id        in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_enrl_det_dt_cd                 in  varchar2
  ,p_pgm_id                         in  number
  ,p_eligy_prfl_id                  in  number
  ,p_business_group_id              in  number
  ,p_eeg_attribute_category         in  varchar2
  ,p_eeg_attribute1                 in  varchar2
  ,p_eeg_attribute2                 in  varchar2
  ,p_eeg_attribute3                 in  varchar2
  ,p_eeg_attribute4                 in  varchar2
  ,p_eeg_attribute5                 in  varchar2
  ,p_eeg_attribute6                 in  varchar2
  ,p_eeg_attribute7                 in  varchar2
  ,p_eeg_attribute8                 in  varchar2
  ,p_eeg_attribute9                 in  varchar2
  ,p_eeg_attribute10                in  varchar2
  ,p_eeg_attribute11                in  varchar2
  ,p_eeg_attribute12                in  varchar2
  ,p_eeg_attribute13                in  varchar2
  ,p_eeg_attribute14                in  varchar2
  ,p_eeg_attribute15                in  varchar2
  ,p_eeg_attribute16                in  varchar2
  ,p_eeg_attribute17                in  varchar2
  ,p_eeg_attribute18                in  varchar2
  ,p_eeg_attribute19                in  varchar2
  ,p_eeg_attribute20                in  varchar2
  ,p_eeg_attribute21                in  varchar2
  ,p_eeg_attribute22                in  varchar2
  ,p_eeg_attribute23                in  varchar2
  ,p_eeg_attribute24                in  varchar2
  ,p_eeg_attribute25                in  varchar2
  ,p_eeg_attribute26                in  varchar2
  ,p_eeg_attribute27                in  varchar2
  ,p_eeg_attribute28                in  varchar2
  ,p_eeg_attribute29                in  varchar2
  ,p_eeg_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_ELIG_ENRLD_ANTHR_PGM_bk2;

 

/
