--------------------------------------------------------
--  DDL for Package BEN_REGULATORY_PURPOSE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_REGULATORY_PURPOSE_BK2" AUTHID CURRENT_USER as
/* $Header: beprpapi.pkh 120.0 2005/05/28 11:11:02 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_regulatory_purpose_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_regulatory_purpose_b
  (
   p_pl_regy_prps_id                in  number
  ,p_pl_regy_prps_cd                in  varchar2
  ,p_pl_regy_bod_id                 in  number
  ,p_business_group_id              in  number
  ,p_prp_attribute_category         in  varchar2
  ,p_prp_attribute1                 in  varchar2
  ,p_prp_attribute2                 in  varchar2
  ,p_prp_attribute3                 in  varchar2
  ,p_prp_attribute4                 in  varchar2
  ,p_prp_attribute5                 in  varchar2
  ,p_prp_attribute6                 in  varchar2
  ,p_prp_attribute7                 in  varchar2
  ,p_prp_attribute8                 in  varchar2
  ,p_prp_attribute9                 in  varchar2
  ,p_prp_attribute10                in  varchar2
  ,p_prp_attribute11                in  varchar2
  ,p_prp_attribute12                in  varchar2
  ,p_prp_attribute13                in  varchar2
  ,p_prp_attribute14                in  varchar2
  ,p_prp_attribute15                in  varchar2
  ,p_prp_attribute16                in  varchar2
  ,p_prp_attribute17                in  varchar2
  ,p_prp_attribute18                in  varchar2
  ,p_prp_attribute19                in  varchar2
  ,p_prp_attribute20                in  varchar2
  ,p_prp_attribute21                in  varchar2
  ,p_prp_attribute22                in  varchar2
  ,p_prp_attribute23                in  varchar2
  ,p_prp_attribute24                in  varchar2
  ,p_prp_attribute25                in  varchar2
  ,p_prp_attribute26                in  varchar2
  ,p_prp_attribute27                in  varchar2
  ,p_prp_attribute28                in  varchar2
  ,p_prp_attribute29                in  varchar2
  ,p_prp_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_regulatory_purpose_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_regulatory_purpose_a
  (
   p_pl_regy_prps_id                in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_pl_regy_prps_cd                in  varchar2
  ,p_pl_regy_bod_id                 in  number
  ,p_business_group_id              in  number
  ,p_prp_attribute_category         in  varchar2
  ,p_prp_attribute1                 in  varchar2
  ,p_prp_attribute2                 in  varchar2
  ,p_prp_attribute3                 in  varchar2
  ,p_prp_attribute4                 in  varchar2
  ,p_prp_attribute5                 in  varchar2
  ,p_prp_attribute6                 in  varchar2
  ,p_prp_attribute7                 in  varchar2
  ,p_prp_attribute8                 in  varchar2
  ,p_prp_attribute9                 in  varchar2
  ,p_prp_attribute10                in  varchar2
  ,p_prp_attribute11                in  varchar2
  ,p_prp_attribute12                in  varchar2
  ,p_prp_attribute13                in  varchar2
  ,p_prp_attribute14                in  varchar2
  ,p_prp_attribute15                in  varchar2
  ,p_prp_attribute16                in  varchar2
  ,p_prp_attribute17                in  varchar2
  ,p_prp_attribute18                in  varchar2
  ,p_prp_attribute19                in  varchar2
  ,p_prp_attribute20                in  varchar2
  ,p_prp_attribute21                in  varchar2
  ,p_prp_attribute22                in  varchar2
  ,p_prp_attribute23                in  varchar2
  ,p_prp_attribute24                in  varchar2
  ,p_prp_attribute25                in  varchar2
  ,p_prp_attribute26                in  varchar2
  ,p_prp_attribute27                in  varchar2
  ,p_prp_attribute28                in  varchar2
  ,p_prp_attribute29                in  varchar2
  ,p_prp_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_regulatory_purpose_bk2;

 

/
