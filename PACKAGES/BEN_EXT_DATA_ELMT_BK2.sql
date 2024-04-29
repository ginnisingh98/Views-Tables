--------------------------------------------------------
--  DDL for Package BEN_EXT_DATA_ELMT_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_DATA_ELMT_BK2" AUTHID CURRENT_USER as
/* $Header: bexelapi.pkh 120.1 2005/06/08 13:17:09 tjesumic noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_EXT_DATA_ELMT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_EXT_DATA_ELMT_b
  (
   p_ext_data_elmt_id               in  number
  ,p_name                           in  varchar2
  ,p_xml_tag_name                   in  varchar2
  ,p_data_elmt_typ_cd               in  varchar2
  ,p_data_elmt_rl                   in  number
  ,p_frmt_mask_cd                   in  varchar2
  ,p_string_val                     in  varchar2
  ,p_dflt_val                       in  varchar2
  ,p_max_length_num                 in  number
  ,p_just_cd                       in  varchar2
  ,p_ttl_fnctn_cd                       in  varchar2
  ,p_ttl_cond_oper_cd                       in  varchar2
  ,p_ttl_cond_val                       in  varchar2
  ,p_ttl_sum_ext_data_elmt_id                     in  number
  ,p_ttl_cond_ext_data_elmt_id                     in  number
  ,p_ext_fld_id                     in  number
  ,p_business_group_id              in  number
  ,p_legislation_code               in  varchar2
  ,p_xel_attribute_category         in  varchar2
  ,p_xel_attribute1                 in  varchar2
  ,p_xel_attribute2                 in  varchar2
  ,p_xel_attribute3                 in  varchar2
  ,p_xel_attribute4                 in  varchar2
  ,p_xel_attribute5                 in  varchar2
  ,p_xel_attribute6                 in  varchar2
  ,p_xel_attribute7                 in  varchar2
  ,p_xel_attribute8                 in  varchar2
  ,p_xel_attribute9                 in  varchar2
  ,p_xel_attribute10                in  varchar2
  ,p_xel_attribute11                in  varchar2
  ,p_xel_attribute12                in  varchar2
  ,p_xel_attribute13                in  varchar2
  ,p_xel_attribute14                in  varchar2
  ,p_xel_attribute15                in  varchar2
  ,p_xel_attribute16                in  varchar2
  ,p_xel_attribute17                in  varchar2
  ,p_xel_attribute18                in  varchar2
  ,p_xel_attribute19                in  varchar2
  ,p_xel_attribute20                in  varchar2
  ,p_xel_attribute21                in  varchar2
  ,p_xel_attribute22                in  varchar2
  ,p_xel_attribute23                in  varchar2
  ,p_xel_attribute24                in  varchar2
  ,p_xel_attribute25                in  varchar2
  ,p_xel_attribute26                in  varchar2
  ,p_xel_attribute27                in  varchar2
  ,p_xel_attribute28                in  varchar2
  ,p_xel_attribute29                in  varchar2
  ,p_xel_attribute30                in  varchar2
  ,p_defined_balance_id             in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_EXT_DATA_ELMT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_EXT_DATA_ELMT_a
  (
   p_ext_data_elmt_id               in  number
  ,p_name                           in  varchar2
  ,p_xml_tag_name                   in  varchar2
  ,p_data_elmt_typ_cd               in  varchar2
  ,p_data_elmt_rl                   in  number
  ,p_frmt_mask_cd                   in  varchar2
  ,p_string_val                     in  varchar2
  ,p_dflt_val                       in  varchar2
  ,p_max_length_num                 in  number
  ,p_just_cd                       in  varchar2
  ,p_ttl_fnctn_cd                       in  varchar2
  ,p_ttl_cond_oper_cd                       in  varchar2
  ,p_ttl_cond_val                       in  varchar2
  ,p_ttl_sum_ext_data_elmt_id                     in  number
  ,p_ttl_cond_ext_data_elmt_id                     in  number
  ,p_ext_fld_id                     in  number
  ,p_business_group_id              in  number
  ,p_legislation_code               in  varchar2
  ,p_xel_attribute_category         in  varchar2
  ,p_xel_attribute1                 in  varchar2
  ,p_xel_attribute2                 in  varchar2
  ,p_xel_attribute3                 in  varchar2
  ,p_xel_attribute4                 in  varchar2
  ,p_xel_attribute5                 in  varchar2
  ,p_xel_attribute6                 in  varchar2
  ,p_xel_attribute7                 in  varchar2
  ,p_xel_attribute8                 in  varchar2
  ,p_xel_attribute9                 in  varchar2
  ,p_xel_attribute10                in  varchar2
  ,p_xel_attribute11                in  varchar2
  ,p_xel_attribute12                in  varchar2
  ,p_xel_attribute13                in  varchar2
  ,p_xel_attribute14                in  varchar2
  ,p_xel_attribute15                in  varchar2
  ,p_xel_attribute16                in  varchar2
  ,p_xel_attribute17                in  varchar2
  ,p_xel_attribute18                in  varchar2
  ,p_xel_attribute19                in  varchar2
  ,p_xel_attribute20                in  varchar2
  ,p_xel_attribute21                in  varchar2
  ,p_xel_attribute22                in  varchar2
  ,p_xel_attribute23                in  varchar2
  ,p_xel_attribute24                in  varchar2
  ,p_xel_attribute25                in  varchar2
  ,p_xel_attribute26                in  varchar2
  ,p_xel_attribute27                in  varchar2
  ,p_xel_attribute28                in  varchar2
  ,p_xel_attribute29                in  varchar2
  ,p_xel_attribute30                in  varchar2
  ,p_defined_balance_id             in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_EXT_DATA_ELMT_bk2;

 

/
