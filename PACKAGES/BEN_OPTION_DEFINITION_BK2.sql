--------------------------------------------------------
--  DDL for Package BEN_OPTION_DEFINITION_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_OPTION_DEFINITION_BK2" AUTHID CURRENT_USER as
/* $Header: beoptapi.pkh 120.0 2005/05/28 09:56:18 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_option_definition_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_option_definition_b
  (
   p_opt_id                         in  number
  ,p_name                           in  varchar2
  ,p_cmbn_ptip_opt_id               in  number
  ,p_business_group_id              in  number
  ,p_opt_attribute_category         in  varchar2
  ,p_opt_attribute1                 in  varchar2
  ,p_opt_attribute2                 in  varchar2
  ,p_opt_attribute3                 in  varchar2
  ,p_opt_attribute4                 in  varchar2
  ,p_opt_attribute5                 in  varchar2
  ,p_opt_attribute6                 in  varchar2
  ,p_opt_attribute7                 in  varchar2
  ,p_opt_attribute8                 in  varchar2
  ,p_opt_attribute9                 in  varchar2
  ,p_opt_attribute10                in  varchar2
  ,p_opt_attribute11                in  varchar2
  ,p_opt_attribute12                in  varchar2
  ,p_opt_attribute13                in  varchar2
  ,p_opt_attribute14                in  varchar2
  ,p_opt_attribute15                in  varchar2
  ,p_opt_attribute16                in  varchar2
  ,p_opt_attribute17                in  varchar2
  ,p_opt_attribute18                in  varchar2
  ,p_opt_attribute19                in  varchar2
  ,p_opt_attribute20                in  varchar2
  ,p_opt_attribute21                in  varchar2
  ,p_opt_attribute22                in  varchar2
  ,p_opt_attribute23                in  varchar2
  ,p_opt_attribute24                in  varchar2
  ,p_opt_attribute25                in  varchar2
  ,p_opt_attribute26                in  varchar2
  ,p_opt_attribute27                in  varchar2
  ,p_opt_attribute28                in  varchar2
  ,p_opt_attribute29                in  varchar2
  ,p_opt_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_rqd_perd_enrt_nenrt_uom        in  varchar2
  ,p_rqd_perd_enrt_nenrt_val        in  number
  ,p_rqd_perd_enrt_nenrt_rl         in  number
  ,p_invk_wv_opt_flag               in  varchar2
  ,p_short_name			    in  varchar2
  ,p_short_code			    in  varchar2
  ,p_legislation_code		    in  varchar2
  ,p_legislation_subgroup	    in  varchar2
  ,p_group_opt_id          	    in  number
  ,p_component_reason               in  varchar2
  ,p_mapping_table_name             in  varchar2
  ,p_mapping_table_pk_id            in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_option_definition_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_option_definition_a
  (
   p_opt_id                         in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_name                           in  varchar2
  ,p_cmbn_ptip_opt_id               in  number
  ,p_business_group_id              in  number
  ,p_opt_attribute_category         in  varchar2
  ,p_opt_attribute1                 in  varchar2
  ,p_opt_attribute2                 in  varchar2
  ,p_opt_attribute3                 in  varchar2
  ,p_opt_attribute4                 in  varchar2
  ,p_opt_attribute5                 in  varchar2
  ,p_opt_attribute6                 in  varchar2
  ,p_opt_attribute7                 in  varchar2
  ,p_opt_attribute8                 in  varchar2
  ,p_opt_attribute9                 in  varchar2
  ,p_opt_attribute10                in  varchar2
  ,p_opt_attribute11                in  varchar2
  ,p_opt_attribute12                in  varchar2
  ,p_opt_attribute13                in  varchar2
  ,p_opt_attribute14                in  varchar2
  ,p_opt_attribute15                in  varchar2
  ,p_opt_attribute16                in  varchar2
  ,p_opt_attribute17                in  varchar2
  ,p_opt_attribute18                in  varchar2
  ,p_opt_attribute19                in  varchar2
  ,p_opt_attribute20                in  varchar2
  ,p_opt_attribute21                in  varchar2
  ,p_opt_attribute22                in  varchar2
  ,p_opt_attribute23                in  varchar2
  ,p_opt_attribute24                in  varchar2
  ,p_opt_attribute25                in  varchar2
  ,p_opt_attribute26                in  varchar2
  ,p_opt_attribute27                in  varchar2
  ,p_opt_attribute28                in  varchar2
  ,p_opt_attribute29                in  varchar2
  ,p_opt_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_rqd_perd_enrt_nenrt_uom        in  varchar2
  ,p_rqd_perd_enrt_nenrt_val        in  number
  ,p_rqd_perd_enrt_nenrt_rl         in  number
  ,p_invk_wv_opt_flag               in  varchar2
  ,p_short_name			    in  varchar2
  ,p_short_code			    in  varchar2
  ,p_legislation_code		    in  varchar2
  ,p_legislation_subgroup	    in  varchar2
  ,p_group_opt_id          	    in  number
  ,p_component_reason               in  varchar2
  ,p_mapping_table_name             in  varchar2
  ,p_mapping_table_pk_id            in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_option_definition_bk2;

 

/
