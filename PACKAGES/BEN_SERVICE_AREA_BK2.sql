--------------------------------------------------------
--  DDL for Package BEN_SERVICE_AREA_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_SERVICE_AREA_BK2" AUTHID CURRENT_USER as
/* $Header: besvaapi.pkh 120.0 2005/05/28 11:53:46 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_SERVICE_AREA_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_SERVICE_AREA_b
  (
   p_svc_area_id                    in  number
  ,p_name                           in  varchar2
  ,p_org_unit_prdct                 in  varchar2
  ,p_business_group_id              in  number
  ,p_sva_attribute_category         in  varchar2
  ,p_sva_attribute1                 in  varchar2
  ,p_sva_attribute2                 in  varchar2
  ,p_sva_attribute3                 in  varchar2
  ,p_sva_attribute4                 in  varchar2
  ,p_sva_attribute5                 in  varchar2
  ,p_sva_attribute6                 in  varchar2
  ,p_sva_attribute7                 in  varchar2
  ,p_sva_attribute8                 in  varchar2
  ,p_sva_attribute9                 in  varchar2
  ,p_sva_attribute10                in  varchar2
  ,p_sva_attribute11                in  varchar2
  ,p_sva_attribute12                in  varchar2
  ,p_sva_attribute13                in  varchar2
  ,p_sva_attribute14                in  varchar2
  ,p_sva_attribute15                in  varchar2
  ,p_sva_attribute16                in  varchar2
  ,p_sva_attribute17                in  varchar2
  ,p_sva_attribute18                in  varchar2
  ,p_sva_attribute19                in  varchar2
  ,p_sva_attribute20                in  varchar2
  ,p_sva_attribute21                in  varchar2
  ,p_sva_attribute22                in  varchar2
  ,p_sva_attribute23                in  varchar2
  ,p_sva_attribute24                in  varchar2
  ,p_sva_attribute25                in  varchar2
  ,p_sva_attribute26                in  varchar2
  ,p_sva_attribute27                in  varchar2
  ,p_sva_attribute28                in  varchar2
  ,p_sva_attribute29                in  varchar2
  ,p_sva_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_SERVICE_AREA_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_SERVICE_AREA_a
  (
   p_svc_area_id                    in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_name                           in  varchar2
  ,p_org_unit_prdct                 in  varchar2
  ,p_business_group_id              in  number
  ,p_sva_attribute_category         in  varchar2
  ,p_sva_attribute1                 in  varchar2
  ,p_sva_attribute2                 in  varchar2
  ,p_sva_attribute3                 in  varchar2
  ,p_sva_attribute4                 in  varchar2
  ,p_sva_attribute5                 in  varchar2
  ,p_sva_attribute6                 in  varchar2
  ,p_sva_attribute7                 in  varchar2
  ,p_sva_attribute8                 in  varchar2
  ,p_sva_attribute9                 in  varchar2
  ,p_sva_attribute10                in  varchar2
  ,p_sva_attribute11                in  varchar2
  ,p_sva_attribute12                in  varchar2
  ,p_sva_attribute13                in  varchar2
  ,p_sva_attribute14                in  varchar2
  ,p_sva_attribute15                in  varchar2
  ,p_sva_attribute16                in  varchar2
  ,p_sva_attribute17                in  varchar2
  ,p_sva_attribute18                in  varchar2
  ,p_sva_attribute19                in  varchar2
  ,p_sva_attribute20                in  varchar2
  ,p_sva_attribute21                in  varchar2
  ,p_sva_attribute22                in  varchar2
  ,p_sva_attribute23                in  varchar2
  ,p_sva_attribute24                in  varchar2
  ,p_sva_attribute25                in  varchar2
  ,p_sva_attribute26                in  varchar2
  ,p_sva_attribute27                in  varchar2
  ,p_sva_attribute28                in  varchar2
  ,p_sva_attribute29                in  varchar2
  ,p_sva_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_SERVICE_AREA_bk2;

 

/
