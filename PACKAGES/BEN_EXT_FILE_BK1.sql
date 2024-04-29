--------------------------------------------------------
--  DDL for Package BEN_EXT_FILE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_FILE_BK1" AUTHID CURRENT_USER as
/* $Header: bexfiapi.pkh 120.0 2005/05/28 12:33:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_EXT_FILE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_EXT_FILE_b
  (
   p_name                           in  varchar2
  ,p_xml_tag_name                   in  varchar2
  ,p_business_group_id              in  number
  ,p_legislation_code               in  varchar2
  ,p_xfi_attribute_category         in  varchar2
  ,p_xfi_attribute1                 in  varchar2
  ,p_xfi_attribute2                 in  varchar2
  ,p_xfi_attribute3                 in  varchar2
  ,p_xfi_attribute4                 in  varchar2
  ,p_xfi_attribute5                 in  varchar2
  ,p_xfi_attribute6                 in  varchar2
  ,p_xfi_attribute7                 in  varchar2
  ,p_xfi_attribute8                 in  varchar2
  ,p_xfi_attribute9                 in  varchar2
  ,p_xfi_attribute10                in  varchar2
  ,p_xfi_attribute11                in  varchar2
  ,p_xfi_attribute12                in  varchar2
  ,p_xfi_attribute13                in  varchar2
  ,p_xfi_attribute14                in  varchar2
  ,p_xfi_attribute15                in  varchar2
  ,p_xfi_attribute16                in  varchar2
  ,p_xfi_attribute17                in  varchar2
  ,p_xfi_attribute18                in  varchar2
  ,p_xfi_attribute19                in  varchar2
  ,p_xfi_attribute20                in  varchar2
  ,p_xfi_attribute21                in  varchar2
  ,p_xfi_attribute22                in  varchar2
  ,p_xfi_attribute23                in  varchar2
  ,p_xfi_attribute24                in  varchar2
  ,p_xfi_attribute25                in  varchar2
  ,p_xfi_attribute26                in  varchar2
  ,p_xfi_attribute27                in  varchar2
  ,p_xfi_attribute28                in  varchar2
  ,p_xfi_attribute29                in  varchar2
  ,p_xfi_attribute30                in  varchar2
  ,p_ext_rcd_in_file_id             in  Number
  ,p_ext_data_elmt_in_rcd_id1       in  Number
  ,p_ext_data_elmt_in_rcd_id2       in  Number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_EXT_FILE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_EXT_FILE_a
  (
   p_ext_file_id                    in  number
  ,p_name                           in  varchar2
  ,p_xml_tag_name                   in  varchar2
  ,p_business_group_id              in  number
  ,p_legislation_code               in  varchar2
  ,p_xfi_attribute_category         in  varchar2
  ,p_xfi_attribute1                 in  varchar2
  ,p_xfi_attribute2                 in  varchar2
  ,p_xfi_attribute3                 in  varchar2
  ,p_xfi_attribute4                 in  varchar2
  ,p_xfi_attribute5                 in  varchar2
  ,p_xfi_attribute6                 in  varchar2
  ,p_xfi_attribute7                 in  varchar2
  ,p_xfi_attribute8                 in  varchar2
  ,p_xfi_attribute9                 in  varchar2
  ,p_xfi_attribute10                in  varchar2
  ,p_xfi_attribute11                in  varchar2
  ,p_xfi_attribute12                in  varchar2
  ,p_xfi_attribute13                in  varchar2
  ,p_xfi_attribute14                in  varchar2
  ,p_xfi_attribute15                in  varchar2
  ,p_xfi_attribute16                in  varchar2
  ,p_xfi_attribute17                in  varchar2
  ,p_xfi_attribute18                in  varchar2
  ,p_xfi_attribute19                in  varchar2
  ,p_xfi_attribute20                in  varchar2
  ,p_xfi_attribute21                in  varchar2
  ,p_xfi_attribute22                in  varchar2
  ,p_xfi_attribute23                in  varchar2
  ,p_xfi_attribute24                in  varchar2
  ,p_xfi_attribute25                in  varchar2
  ,p_xfi_attribute26                in  varchar2
  ,p_xfi_attribute27                in  varchar2
  ,p_xfi_attribute28                in  varchar2
  ,p_xfi_attribute29                in  varchar2
  ,p_xfi_attribute30                in  varchar2
  ,p_ext_rcd_in_file_id             in  Number
  ,p_ext_data_elmt_in_rcd_id1       in  Number
  ,p_ext_data_elmt_in_rcd_id2       in  Number
  ,p_object_version_number          in  number
  );
--
end ben_EXT_FILE_bk1;

 

/
