--------------------------------------------------------
--  DDL for Package BEN_COMPTNCY_RT_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_COMPTNCY_RT_BK1" AUTHID CURRENT_USER as
/* $Header: bectyapi.pkh 120.0 2005/05/28 01:28:53 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_comptncy_rt_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_comptncy_rt_b
  (
   p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_competence_id                  in  number
  ,p_rating_level_id                in  number
  ,p_vrbl_rt_prfl_id                in  number
  ,p_business_group_id              in  number
  ,p_cty_attribute_category         in  varchar2
  ,p_cty_attribute1                 in  varchar2
  ,p_cty_attribute2                 in  varchar2
  ,p_cty_attribute3                 in  varchar2
  ,p_cty_attribute4                 in  varchar2
  ,p_cty_attribute5                 in  varchar2
  ,p_cty_attribute6                 in  varchar2
  ,p_cty_attribute7                 in  varchar2
  ,p_cty_attribute8                 in  varchar2
  ,p_cty_attribute9                 in  varchar2
  ,p_cty_attribute10                in  varchar2
  ,p_cty_attribute11                in  varchar2
  ,p_cty_attribute12                in  varchar2
  ,p_cty_attribute13                in  varchar2
  ,p_cty_attribute14                in  varchar2
  ,p_cty_attribute15                in  varchar2
  ,p_cty_attribute16                in  varchar2
  ,p_cty_attribute17                in  varchar2
  ,p_cty_attribute18                in  varchar2
  ,p_cty_attribute19                in  varchar2
  ,p_cty_attribute20                in  varchar2
  ,p_cty_attribute21                in  varchar2
  ,p_cty_attribute22                in  varchar2
  ,p_cty_attribute23                in  varchar2
  ,p_cty_attribute24                in  varchar2
  ,p_cty_attribute25                in  varchar2
  ,p_cty_attribute26                in  varchar2
  ,p_cty_attribute27                in  varchar2
  ,p_cty_attribute28                in  varchar2
  ,p_cty_attribute29                in  varchar2
  ,p_cty_attribute30                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_comptncy_rt_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_comptncy_rt_a
  (
   p_comptncy_rt_id                 in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_ordr_num                       in  number
  ,p_excld_flag                     in  varchar2
  ,p_competence_id                  in  number
  ,p_rating_level_id                in  number
  ,p_vrbl_rt_prfl_id                in  number
  ,p_business_group_id              in  number
  ,p_cty_attribute_category         in  varchar2
  ,p_cty_attribute1                 in  varchar2
  ,p_cty_attribute2                 in  varchar2
  ,p_cty_attribute3                 in  varchar2
  ,p_cty_attribute4                 in  varchar2
  ,p_cty_attribute5                 in  varchar2
  ,p_cty_attribute6                 in  varchar2
  ,p_cty_attribute7                 in  varchar2
  ,p_cty_attribute8                 in  varchar2
  ,p_cty_attribute9                 in  varchar2
  ,p_cty_attribute10                in  varchar2
  ,p_cty_attribute11                in  varchar2
  ,p_cty_attribute12                in  varchar2
  ,p_cty_attribute13                in  varchar2
  ,p_cty_attribute14                in  varchar2
  ,p_cty_attribute15                in  varchar2
  ,p_cty_attribute16                in  varchar2
  ,p_cty_attribute17                in  varchar2
  ,p_cty_attribute18                in  varchar2
  ,p_cty_attribute19                in  varchar2
  ,p_cty_attribute20                in  varchar2
  ,p_cty_attribute21                in  varchar2
  ,p_cty_attribute22                in  varchar2
  ,p_cty_attribute23                in  varchar2
  ,p_cty_attribute24                in  varchar2
  ,p_cty_attribute25                in  varchar2
  ,p_cty_attribute26                in  varchar2
  ,p_cty_attribute27                in  varchar2
  ,p_cty_attribute28                in  varchar2
  ,p_cty_attribute29                in  varchar2
  ,p_cty_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_comptncy_rt_bk1;

 

/
