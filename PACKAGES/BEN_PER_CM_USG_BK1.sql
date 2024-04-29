--------------------------------------------------------
--  DDL for Package BEN_PER_CM_USG_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PER_CM_USG_BK1" AUTHID CURRENT_USER as
/* $Header: bepcuapi.pkh 120.0 2005/05/28 10:19:28 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_PER_CM_USG_b >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_PER_CM_USG_b
  (p_per_cm_id                      in  number
  ,p_cm_typ_usg_id                  in  number
  ,p_business_group_id              in  number
  ,p_pcu_attribute_category         in  varchar2
  ,p_pcu_attribute1                 in  varchar2
  ,p_pcu_attribute2                 in  varchar2
  ,p_pcu_attribute3                 in  varchar2
  ,p_pcu_attribute4                 in  varchar2
  ,p_pcu_attribute5                 in  varchar2
  ,p_pcu_attribute6                 in  varchar2
  ,p_pcu_attribute7                 in  varchar2
  ,p_pcu_attribute8                 in  varchar2
  ,p_pcu_attribute9                 in  varchar2
  ,p_pcu_attribute10                in  varchar2
  ,p_pcu_attribute11                in  varchar2
  ,p_pcu_attribute12                in  varchar2
  ,p_pcu_attribute13                in  varchar2
  ,p_pcu_attribute14                in  varchar2
  ,p_pcu_attribute15                in  varchar2
  ,p_pcu_attribute16                in  varchar2
  ,p_pcu_attribute17                in  varchar2
  ,p_pcu_attribute18                in  varchar2
  ,p_pcu_attribute19                in  varchar2
  ,p_pcu_attribute20                in  varchar2
  ,p_pcu_attribute21                in  varchar2
  ,p_pcu_attribute22                in  varchar2
  ,p_pcu_attribute23                in  varchar2
  ,p_pcu_attribute24                in  varchar2
  ,p_pcu_attribute25                in  varchar2
  ,p_pcu_attribute26                in  varchar2
  ,p_pcu_attribute27                in  varchar2
  ,p_pcu_attribute28                in  varchar2
  ,p_pcu_attribute29                in  varchar2
  ,p_pcu_attribute30                in  varchar2
  ,p_request_id                     in  number
  ,p_program_application_id         in  number
  ,p_program_id                     in  number
  ,p_program_update_date            in  date
  ,p_effective_date                 in  date);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_PER_CM_USG_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_PER_CM_USG_a
  (p_per_cm_usg_id                  in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_per_cm_id                      in  number
  ,p_cm_typ_usg_id                  in  number
  ,p_business_group_id              in  number
  ,p_pcu_attribute_category         in  varchar2
  ,p_pcu_attribute1                 in  varchar2
  ,p_pcu_attribute2                 in  varchar2
  ,p_pcu_attribute3                 in  varchar2
  ,p_pcu_attribute4                 in  varchar2
  ,p_pcu_attribute5                 in  varchar2
  ,p_pcu_attribute6                 in  varchar2
  ,p_pcu_attribute7                 in  varchar2
  ,p_pcu_attribute8                 in  varchar2
  ,p_pcu_attribute9                 in  varchar2
  ,p_pcu_attribute10                in  varchar2
  ,p_pcu_attribute11                in  varchar2
  ,p_pcu_attribute12                in  varchar2
  ,p_pcu_attribute13                in  varchar2
  ,p_pcu_attribute14                in  varchar2
  ,p_pcu_attribute15                in  varchar2
  ,p_pcu_attribute16                in  varchar2
  ,p_pcu_attribute17                in  varchar2
  ,p_pcu_attribute18                in  varchar2
  ,p_pcu_attribute19                in  varchar2
  ,p_pcu_attribute20                in  varchar2
  ,p_pcu_attribute21                in  varchar2
  ,p_pcu_attribute22                in  varchar2
  ,p_pcu_attribute23                in  varchar2
  ,p_pcu_attribute24                in  varchar2
  ,p_pcu_attribute25                in  varchar2
  ,p_pcu_attribute26                in  varchar2
  ,p_pcu_attribute27                in  varchar2
  ,p_pcu_attribute28                in  varchar2
  ,p_pcu_attribute29                in  varchar2
  ,p_pcu_attribute30                in  varchar2
  ,p_request_id                     in  number
  ,p_program_application_id         in  number
  ,p_program_id                     in  number
  ,p_program_update_date            in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date);
--
end ben_PER_CM_USG_bk1;

 

/
