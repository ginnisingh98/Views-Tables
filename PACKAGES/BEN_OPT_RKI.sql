--------------------------------------------------------
--  DDL for Package BEN_OPT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_OPT_RKI" AUTHID CURRENT_USER as
/* $Header: beoptrhi.pkh 120.0 2005/05/28 09:56:49 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_opt_id                         in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_name                           in varchar2
 ,p_cmbn_ptip_opt_id               in number
 ,p_business_group_id              in number
 ,p_opt_attribute_category         in varchar2
 ,p_opt_attribute1                 in varchar2
 ,p_opt_attribute2                 in varchar2
 ,p_opt_attribute3                 in varchar2
 ,p_opt_attribute4                 in varchar2
 ,p_opt_attribute5                 in varchar2
 ,p_opt_attribute6                 in varchar2
 ,p_opt_attribute7                 in varchar2
 ,p_opt_attribute8                 in varchar2
 ,p_opt_attribute9                 in varchar2
 ,p_opt_attribute10                in varchar2
 ,p_opt_attribute11                in varchar2
 ,p_opt_attribute12                in varchar2
 ,p_opt_attribute13                in varchar2
 ,p_opt_attribute14                in varchar2
 ,p_opt_attribute15                in varchar2
 ,p_opt_attribute16                in varchar2
 ,p_opt_attribute17                in varchar2
 ,p_opt_attribute18                in varchar2
 ,p_opt_attribute19                in varchar2
 ,p_opt_attribute20                in varchar2
 ,p_opt_attribute21                in varchar2
 ,p_opt_attribute22                in varchar2
 ,p_opt_attribute23                in varchar2
 ,p_opt_attribute24                in varchar2
 ,p_opt_attribute25                in varchar2
 ,p_opt_attribute26                in varchar2
 ,p_opt_attribute27                in varchar2
 ,p_opt_attribute28                in varchar2
 ,p_opt_attribute29                in varchar2
 ,p_opt_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_rqd_perd_enrt_nenrt_uom        in varchar2
 ,p_rqd_perd_enrt_nenrt_val        in number
 ,p_rqd_perd_enrt_nenrt_rl         in number
 ,p_invk_wv_opt_flag               in varchar2
 ,p_short_name			   in varchar2
 ,p_short_code			   in varchar2
 ,p_legislation_code		   in varchar2
 ,p_legislation_subgroup	   in varchar2
 ,p_group_opt_id                   in  number
 ,p_component_reason               in varchar2
 ,p_mapping_table_name             in varchar2
 ,p_mapping_table_pk_id            in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_opt_rki;

 

/
