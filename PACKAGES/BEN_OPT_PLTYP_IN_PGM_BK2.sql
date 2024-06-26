--------------------------------------------------------
--  DDL for Package BEN_OPT_PLTYP_IN_PGM_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_OPT_PLTYP_IN_PGM_BK2" AUTHID CURRENT_USER as
/* $Header: beotpapi.pkh 120.0 2005/05/28 09:57:50 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_opt_pltyp_in_pgm_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_opt_pltyp_in_pgm_b
  (
   p_optip_id                       in  number
  ,p_business_group_id              in  number
  ,p_pgm_id                         in  number
  ,p_ptip_id                        in  number
  ,p_pl_typ_id                      in  number
  ,p_opt_id                         in  number
  ,p_cmbn_ptip_opt_id               in  number
  ,p_legislation_code         in  varchar2
  ,p_legislation_subgroup         in  varchar2
  ,p_otp_attribute_category         in  varchar2
  ,p_otp_attribute1                 in  varchar2
  ,p_otp_attribute2                 in  varchar2
  ,p_otp_attribute3                 in  varchar2
  ,p_otp_attribute4                 in  varchar2
  ,p_otp_attribute5                 in  varchar2
  ,p_otp_attribute6                 in  varchar2
  ,p_otp_attribute7                 in  varchar2
  ,p_otp_attribute8                 in  varchar2
  ,p_otp_attribute9                 in  varchar2
  ,p_otp_attribute10                in  varchar2
  ,p_otp_attribute11                in  varchar2
  ,p_otp_attribute12                in  varchar2
  ,p_otp_attribute13                in  varchar2
  ,p_otp_attribute14                in  varchar2
  ,p_otp_attribute15                in  varchar2
  ,p_otp_attribute16                in  varchar2
  ,p_otp_attribute17                in  varchar2
  ,p_otp_attribute18                in  varchar2
  ,p_otp_attribute19                in  varchar2
  ,p_otp_attribute20                in  varchar2
  ,p_otp_attribute21                in  varchar2
  ,p_otp_attribute22                in  varchar2
  ,p_otp_attribute23                in  varchar2
  ,p_otp_attribute24                in  varchar2
  ,p_otp_attribute25                in  varchar2
  ,p_otp_attribute26                in  varchar2
  ,p_otp_attribute27                in  varchar2
  ,p_otp_attribute28                in  varchar2
  ,p_otp_attribute29                in  varchar2
  ,p_otp_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_opt_pltyp_in_pgm_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_opt_pltyp_in_pgm_a
  (
   p_optip_id                       in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_pgm_id                         in  number
  ,p_ptip_id                        in  number
  ,p_pl_typ_id                      in  number
  ,p_opt_id                         in  number
  ,p_cmbn_ptip_opt_id               in  number
  ,p_legislation_code         in  varchar2
  ,p_legislation_subgroup         in  varchar2
  ,p_otp_attribute_category         in  varchar2
  ,p_otp_attribute1                 in  varchar2
  ,p_otp_attribute2                 in  varchar2
  ,p_otp_attribute3                 in  varchar2
  ,p_otp_attribute4                 in  varchar2
  ,p_otp_attribute5                 in  varchar2
  ,p_otp_attribute6                 in  varchar2
  ,p_otp_attribute7                 in  varchar2
  ,p_otp_attribute8                 in  varchar2
  ,p_otp_attribute9                 in  varchar2
  ,p_otp_attribute10                in  varchar2
  ,p_otp_attribute11                in  varchar2
  ,p_otp_attribute12                in  varchar2
  ,p_otp_attribute13                in  varchar2
  ,p_otp_attribute14                in  varchar2
  ,p_otp_attribute15                in  varchar2
  ,p_otp_attribute16                in  varchar2
  ,p_otp_attribute17                in  varchar2
  ,p_otp_attribute18                in  varchar2
  ,p_otp_attribute19                in  varchar2
  ,p_otp_attribute20                in  varchar2
  ,p_otp_attribute21                in  varchar2
  ,p_otp_attribute22                in  varchar2
  ,p_otp_attribute23                in  varchar2
  ,p_otp_attribute24                in  varchar2
  ,p_otp_attribute25                in  varchar2
  ,p_otp_attribute26                in  varchar2
  ,p_otp_attribute27                in  varchar2
  ,p_otp_attribute28                in  varchar2
  ,p_otp_attribute29                in  varchar2
  ,p_otp_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_opt_pltyp_in_pgm_bk2;

 

/
