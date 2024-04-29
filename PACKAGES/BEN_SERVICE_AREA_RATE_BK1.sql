--------------------------------------------------------
--  DDL for Package BEN_SERVICE_AREA_RATE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_SERVICE_AREA_RATE_BK1" AUTHID CURRENT_USER as
/* $Header: besarapi.pkh 120.0 2005/05/28 11:47:00 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_service_area_rate_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_service_area_rate_b
  (
   p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_svc_area_id                    in  number
  ,p_vrbl_rt_prfl_id                in  number
  ,p_business_group_id              in  number
  ,p_sar_attribute_category         in  varchar2
  ,p_sar_attribute1                 in  varchar2
  ,p_sar_attribute2                 in  varchar2
  ,p_sar_attribute3                 in  varchar2
  ,p_sar_attribute4                 in  varchar2
  ,p_sar_attribute5                 in  varchar2
  ,p_sar_attribute6                 in  varchar2
  ,p_sar_attribute7                 in  varchar2
  ,p_sar_attribute8                 in  varchar2
  ,p_sar_attribute9                 in  varchar2
  ,p_sar_attribute10                in  varchar2
  ,p_sar_attribute11                in  varchar2
  ,p_sar_attribute12                in  varchar2
  ,p_sar_attribute13                in  varchar2
  ,p_sar_attribute14                in  varchar2
  ,p_sar_attribute15                in  varchar2
  ,p_sar_attribute16                in  varchar2
  ,p_sar_attribute17                in  varchar2
  ,p_sar_attribute18                in  varchar2
  ,p_sar_attribute19                in  varchar2
  ,p_sar_attribute20                in  varchar2
  ,p_sar_attribute21                in  varchar2
  ,p_sar_attribute22                in  varchar2
  ,p_sar_attribute23                in  varchar2
  ,p_sar_attribute24                in  varchar2
  ,p_sar_attribute25                in  varchar2
  ,p_sar_attribute26                in  varchar2
  ,p_sar_attribute27                in  varchar2
  ,p_sar_attribute28                in  varchar2
  ,p_sar_attribute29                in  varchar2
  ,p_sar_attribute30                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_service_area_rate_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_service_area_rate_a
  (
   p_svc_area_rt_id                 in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_excld_flag                     in  varchar2
  ,p_ordr_num                       in  number
  ,p_svc_area_id                    in  number
  ,p_vrbl_rt_prfl_id                in  number
  ,p_business_group_id              in  number
  ,p_sar_attribute_category         in  varchar2
  ,p_sar_attribute1                 in  varchar2
  ,p_sar_attribute2                 in  varchar2
  ,p_sar_attribute3                 in  varchar2
  ,p_sar_attribute4                 in  varchar2
  ,p_sar_attribute5                 in  varchar2
  ,p_sar_attribute6                 in  varchar2
  ,p_sar_attribute7                 in  varchar2
  ,p_sar_attribute8                 in  varchar2
  ,p_sar_attribute9                 in  varchar2
  ,p_sar_attribute10                in  varchar2
  ,p_sar_attribute11                in  varchar2
  ,p_sar_attribute12                in  varchar2
  ,p_sar_attribute13                in  varchar2
  ,p_sar_attribute14                in  varchar2
  ,p_sar_attribute15                in  varchar2
  ,p_sar_attribute16                in  varchar2
  ,p_sar_attribute17                in  varchar2
  ,p_sar_attribute18                in  varchar2
  ,p_sar_attribute19                in  varchar2
  ,p_sar_attribute20                in  varchar2
  ,p_sar_attribute21                in  varchar2
  ,p_sar_attribute22                in  varchar2
  ,p_sar_attribute23                in  varchar2
  ,p_sar_attribute24                in  varchar2
  ,p_sar_attribute25                in  varchar2
  ,p_sar_attribute26                in  varchar2
  ,p_sar_attribute27                in  varchar2
  ,p_sar_attribute28                in  varchar2
  ,p_sar_attribute29                in  varchar2
  ,p_sar_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_service_area_rate_bk1;

 

/
