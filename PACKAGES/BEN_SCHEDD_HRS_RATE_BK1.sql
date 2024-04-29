--------------------------------------------------------
--  DDL for Package BEN_SCHEDD_HRS_RATE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_SCHEDD_HRS_RATE_BK1" AUTHID CURRENT_USER as
/* $Header: beshrapi.pkh 120.0 2005/05/28 11:51:30 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_SCHEDD_HRS_RATE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_SCHEDD_HRS_RATE_b
  (
   p_vrbl_rt_prfl_id                in  number
  ,p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_freq_cd                        in  varchar2
  ,p_hrs_num                        in  number
  ,p_max_hrs_num                    in number
  ,p_schedd_hrs_rl                  in number
  ,p_determination_cd               in varchar2
  ,p_determination_rl               in number
  ,p_rounding_cd                    in varchar2
  ,p_rounding_rl                    in number
  ,p_business_group_id              in  number
  ,p_shr_attribute_category         in  varchar2
  ,p_shr_attribute1                 in  varchar2
  ,p_shr_attribute2                 in  varchar2
  ,p_shr_attribute3                 in  varchar2
  ,p_shr_attribute4                 in  varchar2
  ,p_shr_attribute5                 in  varchar2
  ,p_shr_attribute6                 in  varchar2
  ,p_shr_attribute7                 in  varchar2
  ,p_shr_attribute8                 in  varchar2
  ,p_shr_attribute9                 in  varchar2
  ,p_shr_attribute10                in  varchar2
  ,p_shr_attribute11                in  varchar2
  ,p_shr_attribute12                in  varchar2
  ,p_shr_attribute13                in  varchar2
  ,p_shr_attribute14                in  varchar2
  ,p_shr_attribute15                in  varchar2
  ,p_shr_attribute16                in  varchar2
  ,p_shr_attribute17                in  varchar2
  ,p_shr_attribute18                in  varchar2
  ,p_shr_attribute19                in  varchar2
  ,p_shr_attribute20                in  varchar2
  ,p_shr_attribute21                in  varchar2
  ,p_shr_attribute22                in  varchar2
  ,p_shr_attribute23                in  varchar2
  ,p_shr_attribute24                in  varchar2
  ,p_shr_attribute25                in  varchar2
  ,p_shr_attribute26                in  varchar2
  ,p_shr_attribute27                in  varchar2
  ,p_shr_attribute28                in  varchar2
  ,p_shr_attribute29                in  varchar2
  ,p_shr_attribute30                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_SCHEDD_HRS_RATE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_SCHEDD_HRS_RATE_a
  (
   p_schedd_hrs_rt_id               in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_vrbl_rt_prfl_id                in  number
  ,p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_freq_cd                        in  varchar2
  ,p_hrs_num                        in  number
  ,p_max_hrs_num                    in number
  ,p_schedd_hrs_rl                  in number
  ,p_determination_cd               in varchar2
  ,p_determination_rl               in number
  ,p_rounding_cd                    in varchar2
  ,p_rounding_rl                    in number
  ,p_business_group_id              in  number
  ,p_shr_attribute_category         in  varchar2
  ,p_shr_attribute1                 in  varchar2
  ,p_shr_attribute2                 in  varchar2
  ,p_shr_attribute3                 in  varchar2
  ,p_shr_attribute4                 in  varchar2
  ,p_shr_attribute5                 in  varchar2
  ,p_shr_attribute6                 in  varchar2
  ,p_shr_attribute7                 in  varchar2
  ,p_shr_attribute8                 in  varchar2
  ,p_shr_attribute9                 in  varchar2
  ,p_shr_attribute10                in  varchar2
  ,p_shr_attribute11                in  varchar2
  ,p_shr_attribute12                in  varchar2
  ,p_shr_attribute13                in  varchar2
  ,p_shr_attribute14                in  varchar2
  ,p_shr_attribute15                in  varchar2
  ,p_shr_attribute16                in  varchar2
  ,p_shr_attribute17                in  varchar2
  ,p_shr_attribute18                in  varchar2
  ,p_shr_attribute19                in  varchar2
  ,p_shr_attribute20                in  varchar2
  ,p_shr_attribute21                in  varchar2
  ,p_shr_attribute22                in  varchar2
  ,p_shr_attribute23                in  varchar2
  ,p_shr_attribute24                in  varchar2
  ,p_shr_attribute25                in  varchar2
  ,p_shr_attribute26                in  varchar2
  ,p_shr_attribute27                in  varchar2
  ,p_shr_attribute28                in  varchar2
  ,p_shr_attribute29                in  varchar2
  ,p_shr_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_SCHEDD_HRS_RATE_bk1;

 

/
