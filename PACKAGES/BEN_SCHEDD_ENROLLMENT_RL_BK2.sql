--------------------------------------------------------
--  DDL for Package BEN_SCHEDD_ENROLLMENT_RL_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_SCHEDD_ENROLLMENT_RL_BK2" AUTHID CURRENT_USER as
/* $Header: beserapi.pkh 120.0 2005/05/28 11:50:19 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_Schedd_Enrollment_Rl_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_Schedd_Enrollment_Rl_b
  (
   p_schedd_enrt_rl_id              in  number
  ,p_ordr_to_aply_num               in  number
  ,p_enrt_perd_id                   in  number
  ,p_formula_id                     in  number
  ,p_business_group_id              in  number
  ,p_ser_attribute_category         in  varchar2
  ,p_ser_attribute1                 in  varchar2
  ,p_ser_attribute2                 in  varchar2
  ,p_ser_attribute3                 in  varchar2
  ,p_ser_attribute4                 in  varchar2
  ,p_ser_attribute5                 in  varchar2
  ,p_ser_attribute6                 in  varchar2
  ,p_ser_attribute7                 in  varchar2
  ,p_ser_attribute8                 in  varchar2
  ,p_ser_attribute9                 in  varchar2
  ,p_ser_attribute10                in  varchar2
  ,p_ser_attribute11                in  varchar2
  ,p_ser_attribute12                in  varchar2
  ,p_ser_attribute13                in  varchar2
  ,p_ser_attribute14                in  varchar2
  ,p_ser_attribute15                in  varchar2
  ,p_ser_attribute16                in  varchar2
  ,p_ser_attribute17                in  varchar2
  ,p_ser_attribute18                in  varchar2
  ,p_ser_attribute19                in  varchar2
  ,p_ser_attribute20                in  varchar2
  ,p_ser_attribute21                in  varchar2
  ,p_ser_attribute22                in  varchar2
  ,p_ser_attribute23                in  varchar2
  ,p_ser_attribute24                in  varchar2
  ,p_ser_attribute25                in  varchar2
  ,p_ser_attribute26                in  varchar2
  ,p_ser_attribute27                in  varchar2
  ,p_ser_attribute28                in  varchar2
  ,p_ser_attribute29                in  varchar2
  ,p_ser_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_Schedd_Enrollment_Rl_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_Schedd_Enrollment_Rl_a
  (
   p_schedd_enrt_rl_id              in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_ordr_to_aply_num               in  number
  ,p_enrt_perd_id                   in  number
  ,p_formula_id                     in  number
  ,p_business_group_id              in  number
  ,p_ser_attribute_category         in  varchar2
  ,p_ser_attribute1                 in  varchar2
  ,p_ser_attribute2                 in  varchar2
  ,p_ser_attribute3                 in  varchar2
  ,p_ser_attribute4                 in  varchar2
  ,p_ser_attribute5                 in  varchar2
  ,p_ser_attribute6                 in  varchar2
  ,p_ser_attribute7                 in  varchar2
  ,p_ser_attribute8                 in  varchar2
  ,p_ser_attribute9                 in  varchar2
  ,p_ser_attribute10                in  varchar2
  ,p_ser_attribute11                in  varchar2
  ,p_ser_attribute12                in  varchar2
  ,p_ser_attribute13                in  varchar2
  ,p_ser_attribute14                in  varchar2
  ,p_ser_attribute15                in  varchar2
  ,p_ser_attribute16                in  varchar2
  ,p_ser_attribute17                in  varchar2
  ,p_ser_attribute18                in  varchar2
  ,p_ser_attribute19                in  varchar2
  ,p_ser_attribute20                in  varchar2
  ,p_ser_attribute21                in  varchar2
  ,p_ser_attribute22                in  varchar2
  ,p_ser_attribute23                in  varchar2
  ,p_ser_attribute24                in  varchar2
  ,p_ser_attribute25                in  varchar2
  ,p_ser_attribute26                in  varchar2
  ,p_ser_attribute27                in  varchar2
  ,p_ser_attribute28                in  varchar2
  ,p_ser_attribute29                in  varchar2
  ,p_ser_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_Schedd_Enrollment_Rl_bk2;

 

/
