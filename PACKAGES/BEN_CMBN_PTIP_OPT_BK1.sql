--------------------------------------------------------
--  DDL for Package BEN_CMBN_PTIP_OPT_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CMBN_PTIP_OPT_BK1" AUTHID CURRENT_USER as
/* $Header: becptapi.pkh 120.0 2005/05/28 01:18:04 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_CMBN_PTIP_OPT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_CMBN_PTIP_OPT_b
  (
   p_name                           in  varchar2
  ,p_business_group_id              in  number
  ,p_cpt_attribute_category         in  varchar2
  ,p_cpt_attribute1                 in  varchar2
  ,p_cpt_attribute2                 in  varchar2
  ,p_cpt_attribute3                 in  varchar2
  ,p_cpt_attribute4                 in  varchar2
  ,p_cpt_attribute5                 in  varchar2
  ,p_cpt_attribute6                 in  varchar2
  ,p_cpt_attribute7                 in  varchar2
  ,p_cpt_attribute8                 in  varchar2
  ,p_cpt_attribute9                 in  varchar2
  ,p_cpt_attribute10                in  varchar2
  ,p_cpt_attribute11                in  varchar2
  ,p_cpt_attribute12                in  varchar2
  ,p_cpt_attribute13                in  varchar2
  ,p_cpt_attribute14                in  varchar2
  ,p_cpt_attribute15                in  varchar2
  ,p_cpt_attribute16                in  varchar2
  ,p_cpt_attribute17                in  varchar2
  ,p_cpt_attribute18                in  varchar2
  ,p_cpt_attribute19                in  varchar2
  ,p_cpt_attribute20                in  varchar2
  ,p_cpt_attribute21                in  varchar2
  ,p_cpt_attribute22                in  varchar2
  ,p_cpt_attribute23                in  varchar2
  ,p_cpt_attribute24                in  varchar2
  ,p_cpt_attribute25                in  varchar2
  ,p_cpt_attribute26                in  varchar2
  ,p_cpt_attribute27                in  varchar2
  ,p_cpt_attribute28                in  varchar2
  ,p_cpt_attribute29                in  varchar2
  ,p_cpt_attribute30                in  varchar2
  ,p_ptip_id                        in  number
  ,p_pgm_id                         in  number
  ,p_opt_id                         in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_CMBN_PTIP_OPT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_CMBN_PTIP_OPT_a
  (
   p_cmbn_ptip_opt_id               in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_name                           in  varchar2
  ,p_business_group_id              in  number
  ,p_cpt_attribute_category         in  varchar2
  ,p_cpt_attribute1                 in  varchar2
  ,p_cpt_attribute2                 in  varchar2
  ,p_cpt_attribute3                 in  varchar2
  ,p_cpt_attribute4                 in  varchar2
  ,p_cpt_attribute5                 in  varchar2
  ,p_cpt_attribute6                 in  varchar2
  ,p_cpt_attribute7                 in  varchar2
  ,p_cpt_attribute8                 in  varchar2
  ,p_cpt_attribute9                 in  varchar2
  ,p_cpt_attribute10                in  varchar2
  ,p_cpt_attribute11                in  varchar2
  ,p_cpt_attribute12                in  varchar2
  ,p_cpt_attribute13                in  varchar2
  ,p_cpt_attribute14                in  varchar2
  ,p_cpt_attribute15                in  varchar2
  ,p_cpt_attribute16                in  varchar2
  ,p_cpt_attribute17                in  varchar2
  ,p_cpt_attribute18                in  varchar2
  ,p_cpt_attribute19                in  varchar2
  ,p_cpt_attribute20                in  varchar2
  ,p_cpt_attribute21                in  varchar2
  ,p_cpt_attribute22                in  varchar2
  ,p_cpt_attribute23                in  varchar2
  ,p_cpt_attribute24                in  varchar2
  ,p_cpt_attribute25                in  varchar2
  ,p_cpt_attribute26                in  varchar2
  ,p_cpt_attribute27                in  varchar2
  ,p_cpt_attribute28                in  varchar2
  ,p_cpt_attribute29                in  varchar2
  ,p_cpt_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_ptip_id                        in  number
  ,p_pgm_id                         in  number
  ,p_opt_id                         in  number
  ,p_effective_date                 in  date
  );
--
end ben_CMBN_PTIP_OPT_bk1;

 

/
