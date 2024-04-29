--------------------------------------------------------
--  DDL for Package BEN_CRT_ORDERS_CVRD_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CRT_ORDERS_CVRD_BK1" AUTHID CURRENT_USER as
/* $Header: becrdapi.pkh 120.0 2005/05/28 01:21:00 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_crt_orders_cvrd_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_crt_orders_cvrd_b
  (
   p_crt_ordr_id                    in  number
  ,p_person_id                      in  number
  ,p_business_group_id              in  number
  ,p_crd_attribute_category         in  varchar2
  ,p_crd_attribute1                 in  varchar2
  ,p_crd_attribute2                 in  varchar2
  ,p_crd_attribute3                 in  varchar2
  ,p_crd_attribute4                 in  varchar2
  ,p_crd_attribute5                 in  varchar2
  ,p_crd_attribute6                 in  varchar2
  ,p_crd_attribute7                 in  varchar2
  ,p_crd_attribute8                 in  varchar2
  ,p_crd_attribute9                 in  varchar2
  ,p_crd_attribute10                in  varchar2
  ,p_crd_attribute11                in  varchar2
  ,p_crd_attribute12                in  varchar2
  ,p_crd_attribute13                in  varchar2
  ,p_crd_attribute14                in  varchar2
  ,p_crd_attribute15                in  varchar2
  ,p_crd_attribute16                in  varchar2
  ,p_crd_attribute17                in  varchar2
  ,p_crd_attribute18                in  varchar2
  ,p_crd_attribute19                in  varchar2
  ,p_crd_attribute20                in  varchar2
  ,p_crd_attribute21                in  varchar2
  ,p_crd_attribute22                in  varchar2
  ,p_crd_attribute23                in  varchar2
  ,p_crd_attribute24                in  varchar2
  ,p_crd_attribute25                in  varchar2
  ,p_crd_attribute26                in  varchar2
  ,p_crd_attribute27                in  varchar2
  ,p_crd_attribute28                in  varchar2
  ,p_crd_attribute29                in  varchar2
  ,p_crd_attribute30                in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_crt_orders_cvrd_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_crt_orders_cvrd_a
  (
   p_crt_ordr_cvrd_per_id           in  number
  ,p_crt_ordr_id                    in  number
  ,p_person_id                      in  number
  ,p_business_group_id              in  number
  ,p_crd_attribute_category         in  varchar2
  ,p_crd_attribute1                 in  varchar2
  ,p_crd_attribute2                 in  varchar2
  ,p_crd_attribute3                 in  varchar2
  ,p_crd_attribute4                 in  varchar2
  ,p_crd_attribute5                 in  varchar2
  ,p_crd_attribute6                 in  varchar2
  ,p_crd_attribute7                 in  varchar2
  ,p_crd_attribute8                 in  varchar2
  ,p_crd_attribute9                 in  varchar2
  ,p_crd_attribute10                in  varchar2
  ,p_crd_attribute11                in  varchar2
  ,p_crd_attribute12                in  varchar2
  ,p_crd_attribute13                in  varchar2
  ,p_crd_attribute14                in  varchar2
  ,p_crd_attribute15                in  varchar2
  ,p_crd_attribute16                in  varchar2
  ,p_crd_attribute17                in  varchar2
  ,p_crd_attribute18                in  varchar2
  ,p_crd_attribute19                in  varchar2
  ,p_crd_attribute20                in  varchar2
  ,p_crd_attribute21                in  varchar2
  ,p_crd_attribute22                in  varchar2
  ,p_crd_attribute23                in  varchar2
  ,p_crd_attribute24                in  varchar2
  ,p_crd_attribute25                in  varchar2
  ,p_crd_attribute26                in  varchar2
  ,p_crd_attribute27                in  varchar2
  ,p_crd_attribute28                in  varchar2
  ,p_crd_attribute29                in  varchar2
  ,p_crd_attribute30                in  varchar2
  ,p_object_version_number          in  number
  );
--
end ben_crt_orders_cvrd_bk1;

 

/
