--------------------------------------------------------
--  DDL for Package BEN_ACTION_TYPE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ACTION_TYPE_BK1" AUTHID CURRENT_USER as
/* $Header: beeatapi.pkh 120.0 2005/05/28 01:46:27 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ACTION_TYPE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ACTION_TYPE_b
  (
   p_business_group_id              in  number
  ,p_type_cd                        in  varchar2
  ,p_name                           in  varchar2
  ,p_description                    in  varchar2
  ,p_eat_attribute_category         in  varchar2
  ,p_eat_attribute1                 in  varchar2
  ,p_eat_attribute2                 in  varchar2
  ,p_eat_attribute3                 in  varchar2
  ,p_eat_attribute4                 in  varchar2
  ,p_eat_attribute5                 in  varchar2
  ,p_eat_attribute6                 in  varchar2
  ,p_eat_attribute7                 in  varchar2
  ,p_eat_attribute8                 in  varchar2
  ,p_eat_attribute9                 in  varchar2
  ,p_eat_attribute10                in  varchar2
  ,p_eat_attribute11                in  varchar2
  ,p_eat_attribute12                in  varchar2
  ,p_eat_attribute13                in  varchar2
  ,p_eat_attribute14                in  varchar2
  ,p_eat_attribute15                in  varchar2
  ,p_eat_attribute16                in  varchar2
  ,p_eat_attribute17                in  varchar2
  ,p_eat_attribute18                in  varchar2
  ,p_eat_attribute19                in  varchar2
  ,p_eat_attribute20                in  varchar2
  ,p_eat_attribute21                in  varchar2
  ,p_eat_attribute22                in  varchar2
  ,p_eat_attribute23                in  varchar2
  ,p_eat_attribute24                in  varchar2
  ,p_eat_attribute25                in  varchar2
  ,p_eat_attribute26                in  varchar2
  ,p_eat_attribute27                in  varchar2
  ,p_eat_attribute28                in  varchar2
  ,p_eat_attribute29                in  varchar2
  ,p_eat_attribute30                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ACTION_TYPE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ACTION_TYPE_a
  (
   p_actn_typ_id                    in  number
  ,p_business_group_id              in  number
  ,p_type_cd                        in  varchar2
  ,p_name                           in  varchar2
  ,p_description                    in  varchar2
  ,p_eat_attribute_category         in  varchar2
  ,p_eat_attribute1                 in  varchar2
  ,p_eat_attribute2                 in  varchar2
  ,p_eat_attribute3                 in  varchar2
  ,p_eat_attribute4                 in  varchar2
  ,p_eat_attribute5                 in  varchar2
  ,p_eat_attribute6                 in  varchar2
  ,p_eat_attribute7                 in  varchar2
  ,p_eat_attribute8                 in  varchar2
  ,p_eat_attribute9                 in  varchar2
  ,p_eat_attribute10                in  varchar2
  ,p_eat_attribute11                in  varchar2
  ,p_eat_attribute12                in  varchar2
  ,p_eat_attribute13                in  varchar2
  ,p_eat_attribute14                in  varchar2
  ,p_eat_attribute15                in  varchar2
  ,p_eat_attribute16                in  varchar2
  ,p_eat_attribute17                in  varchar2
  ,p_eat_attribute18                in  varchar2
  ,p_eat_attribute19                in  varchar2
  ,p_eat_attribute20                in  varchar2
  ,p_eat_attribute21                in  varchar2
  ,p_eat_attribute22                in  varchar2
  ,p_eat_attribute23                in  varchar2
  ,p_eat_attribute24                in  varchar2
  ,p_eat_attribute25                in  varchar2
  ,p_eat_attribute26                in  varchar2
  ,p_eat_attribute27                in  varchar2
  ,p_eat_attribute28                in  varchar2
  ,p_eat_attribute29                in  varchar2
  ,p_eat_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_ACTION_TYPE_bk1;

 

/
