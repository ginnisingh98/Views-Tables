--------------------------------------------------------
--  DDL for Package BEN_OPTION_IN_PLAN_IN_PGM_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_OPTION_IN_PLAN_IN_PGM_BK1" AUTHID CURRENT_USER as
/* $Header: beoppapi.pkh 120.0 2005/05/28 09:54:05 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_option_in_plan_in_pgm_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_option_in_plan_in_pgm_b
  (
   p_oipl_id                        in  number
  ,p_plip_id                        in  number
  ,p_business_group_id              in  number
  ,p_legislation_code         in  varchar2
  ,p_legislation_subgroup         in  varchar2
  ,p_opp_attribute_category         in  varchar2
  ,p_opp_attribute1                 in  varchar2
  ,p_opp_attribute2                 in  varchar2
  ,p_opp_attribute3                 in  varchar2
  ,p_opp_attribute4                 in  varchar2
  ,p_opp_attribute5                 in  varchar2
  ,p_opp_attribute6                 in  varchar2
  ,p_opp_attribute7                 in  varchar2
  ,p_opp_attribute8                 in  varchar2
  ,p_opp_attribute9                 in  varchar2
  ,p_opp_attribute10                in  varchar2
  ,p_opp_attribute11                in  varchar2
  ,p_opp_attribute12                in  varchar2
  ,p_opp_attribute13                in  varchar2
  ,p_opp_attribute14                in  varchar2
  ,p_opp_attribute15                in  varchar2
  ,p_opp_attribute16                in  varchar2
  ,p_opp_attribute17                in  varchar2
  ,p_opp_attribute18                in  varchar2
  ,p_opp_attribute19                in  varchar2
  ,p_opp_attribute20                in  varchar2
  ,p_opp_attribute21                in  varchar2
  ,p_opp_attribute22                in  varchar2
  ,p_opp_attribute23                in  varchar2
  ,p_opp_attribute24                in  varchar2
  ,p_opp_attribute25                in  varchar2
  ,p_opp_attribute26                in  varchar2
  ,p_opp_attribute27                in  varchar2
  ,p_opp_attribute28                in  varchar2
  ,p_opp_attribute29                in  varchar2
  ,p_opp_attribute30                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_option_in_plan_in_pgm_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_option_in_plan_in_pgm_a
  (
   p_oiplip_id                      in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_oipl_id                        in  number
  ,p_plip_id                        in  number
  ,p_business_group_id              in  number
  ,p_legislation_code         in  varchar2
  ,p_legislation_subgroup         in  varchar2
  ,p_opp_attribute_category         in  varchar2
  ,p_opp_attribute1                 in  varchar2
  ,p_opp_attribute2                 in  varchar2
  ,p_opp_attribute3                 in  varchar2
  ,p_opp_attribute4                 in  varchar2
  ,p_opp_attribute5                 in  varchar2
  ,p_opp_attribute6                 in  varchar2
  ,p_opp_attribute7                 in  varchar2
  ,p_opp_attribute8                 in  varchar2
  ,p_opp_attribute9                 in  varchar2
  ,p_opp_attribute10                in  varchar2
  ,p_opp_attribute11                in  varchar2
  ,p_opp_attribute12                in  varchar2
  ,p_opp_attribute13                in  varchar2
  ,p_opp_attribute14                in  varchar2
  ,p_opp_attribute15                in  varchar2
  ,p_opp_attribute16                in  varchar2
  ,p_opp_attribute17                in  varchar2
  ,p_opp_attribute18                in  varchar2
  ,p_opp_attribute19                in  varchar2
  ,p_opp_attribute20                in  varchar2
  ,p_opp_attribute21                in  varchar2
  ,p_opp_attribute22                in  varchar2
  ,p_opp_attribute23                in  varchar2
  ,p_opp_attribute24                in  varchar2
  ,p_opp_attribute25                in  varchar2
  ,p_opp_attribute26                in  varchar2
  ,p_opp_attribute27                in  varchar2
  ,p_opp_attribute28                in  varchar2
  ,p_opp_attribute29                in  varchar2
  ,p_opp_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_option_in_plan_in_pgm_bk1;

 

/
