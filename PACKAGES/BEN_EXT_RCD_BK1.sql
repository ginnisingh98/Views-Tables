--------------------------------------------------------
--  DDL for Package BEN_EXT_RCD_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_RCD_BK1" AUTHID CURRENT_USER as
/* $Header: bexrcapi.pkh 120.0 2005/05/28 12:37:37 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_EXT_RCD_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_EXT_RCD_b
  (
   p_name                           in  varchar2
  ,p_xml_tag_name                   in  varchar2
  ,p_rcd_type_cd                    in  varchar2
  ,p_low_lvl_cd                     in  varchar2
  ,p_business_group_id              in  number
  ,p_legislation_code               in  varchar2
  ,p_xrc_attribute_category         in  varchar2
  ,p_xrc_attribute1                 in  varchar2
  ,p_xrc_attribute2                 in  varchar2
  ,p_xrc_attribute3                 in  varchar2
  ,p_xrc_attribute4                 in  varchar2
  ,p_xrc_attribute5                 in  varchar2
  ,p_xrc_attribute6                 in  varchar2
  ,p_xrc_attribute7                 in  varchar2
  ,p_xrc_attribute8                 in  varchar2
  ,p_xrc_attribute9                 in  varchar2
  ,p_xrc_attribute10                in  varchar2
  ,p_xrc_attribute11                in  varchar2
  ,p_xrc_attribute12                in  varchar2
  ,p_xrc_attribute13                in  varchar2
  ,p_xrc_attribute14                in  varchar2
  ,p_xrc_attribute15                in  varchar2
  ,p_xrc_attribute16                in  varchar2
  ,p_xrc_attribute17                in  varchar2
  ,p_xrc_attribute18                in  varchar2
  ,p_xrc_attribute19                in  varchar2
  ,p_xrc_attribute20                in  varchar2
  ,p_xrc_attribute21                in  varchar2
  ,p_xrc_attribute22                in  varchar2
  ,p_xrc_attribute23                in  varchar2
  ,p_xrc_attribute24                in  varchar2
  ,p_xrc_attribute25                in  varchar2
  ,p_xrc_attribute26                in  varchar2
  ,p_xrc_attribute27                in  varchar2
  ,p_xrc_attribute28                in  varchar2
  ,p_xrc_attribute29                in  varchar2
  ,p_xrc_attribute30                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_EXT_RCD_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_EXT_RCD_a
  (
   p_ext_rcd_id                     in  number
  ,p_name                           in  varchar2
  ,p_xml_tag_name                   in  varchar2
  ,p_rcd_type_cd                    in  varchar2
  ,p_low_lvl_cd                     in  varchar2
  ,p_business_group_id              in  number
  ,p_legislation_code               in  varchar2
  ,p_xrc_attribute_category         in  varchar2
  ,p_xrc_attribute1                 in  varchar2
  ,p_xrc_attribute2                 in  varchar2
  ,p_xrc_attribute3                 in  varchar2
  ,p_xrc_attribute4                 in  varchar2
  ,p_xrc_attribute5                 in  varchar2
  ,p_xrc_attribute6                 in  varchar2
  ,p_xrc_attribute7                 in  varchar2
  ,p_xrc_attribute8                 in  varchar2
  ,p_xrc_attribute9                 in  varchar2
  ,p_xrc_attribute10                in  varchar2
  ,p_xrc_attribute11                in  varchar2
  ,p_xrc_attribute12                in  varchar2
  ,p_xrc_attribute13                in  varchar2
  ,p_xrc_attribute14                in  varchar2
  ,p_xrc_attribute15                in  varchar2
  ,p_xrc_attribute16                in  varchar2
  ,p_xrc_attribute17                in  varchar2
  ,p_xrc_attribute18                in  varchar2
  ,p_xrc_attribute19                in  varchar2
  ,p_xrc_attribute20                in  varchar2
  ,p_xrc_attribute21                in  varchar2
  ,p_xrc_attribute22                in  varchar2
  ,p_xrc_attribute23                in  varchar2
  ,p_xrc_attribute24                in  varchar2
  ,p_xrc_attribute25                in  varchar2
  ,p_xrc_attribute26                in  varchar2
  ,p_xrc_attribute27                in  varchar2
  ,p_xrc_attribute28                in  varchar2
  ,p_xrc_attribute29                in  varchar2
  ,p_xrc_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_EXT_RCD_bk1;

 

/
