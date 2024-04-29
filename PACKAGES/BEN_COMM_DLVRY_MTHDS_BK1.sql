--------------------------------------------------------
--  DDL for Package BEN_COMM_DLVRY_MTHDS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_COMM_DLVRY_MTHDS_BK1" AUTHID CURRENT_USER as
/* $Header: becmtapi.pkh 120.0 2005/05/28 01:07:45 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_Comm_Dlvry_Mthds_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_Comm_Dlvry_Mthds_b
  (
   p_cm_dlvry_mthd_typ_cd           in  varchar2
  ,p_business_group_id              in  number
  ,p_cm_typ_id                      in  number
  ,p_cmt_attribute1                 in  varchar2
  ,p_cmt_attribute10                in  varchar2
  ,p_cmt_attribute11                in  varchar2
  ,p_cmt_attribute12                in  varchar2
  ,p_cmt_attribute13                in  varchar2
  ,p_cmt_attribute14                in  varchar2
  ,p_cmt_attribute15                in  varchar2
  ,p_cmt_attribute16                in  varchar2
  ,p_cmt_attribute17                in  varchar2
  ,p_cmt_attribute18                in  varchar2
  ,p_cmt_attribute19                in  varchar2
  ,p_cmt_attribute2                 in  varchar2
  ,p_cmt_attribute20                in  varchar2
  ,p_cmt_attribute21                in  varchar2
  ,p_cmt_attribute22                in  varchar2
  ,p_cmt_attribute23                in  varchar2
  ,p_cmt_attribute24                in  varchar2
  ,p_cmt_attribute25                in  varchar2
  ,p_cmt_attribute26                in  varchar2
  ,p_cmt_attribute27                in  varchar2
  ,p_cmt_attribute28                in  varchar2
  ,p_cmt_attribute29                in  varchar2
  ,p_cmt_attribute3                 in  varchar2
  ,p_cmt_attribute30                in  varchar2
  ,p_rqd_flag                       in  varchar2
  ,p_cmt_attribute_category         in  varchar2
  ,p_cmt_attribute4                 in  varchar2
  ,p_cmt_attribute5                 in  varchar2
  ,p_cmt_attribute6                 in  varchar2
  ,p_cmt_attribute7                 in  varchar2
  ,p_cmt_attribute8                 in  varchar2
  ,p_cmt_attribute9                 in  varchar2
  ,p_dflt_flag                      in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_Comm_Dlvry_Mthds_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_Comm_Dlvry_Mthds_a
  (
   p_cm_dlvry_mthd_typ_id           in  number
  ,p_cm_dlvry_mthd_typ_cd           in  varchar2
  ,p_business_group_id              in  number
  ,p_cm_typ_id                      in  number
  ,p_cmt_attribute1                 in  varchar2
  ,p_cmt_attribute10                in  varchar2
  ,p_cmt_attribute11                in  varchar2
  ,p_cmt_attribute12                in  varchar2
  ,p_cmt_attribute13                in  varchar2
  ,p_cmt_attribute14                in  varchar2
  ,p_cmt_attribute15                in  varchar2
  ,p_cmt_attribute16                in  varchar2
  ,p_cmt_attribute17                in  varchar2
  ,p_cmt_attribute18                in  varchar2
  ,p_cmt_attribute19                in  varchar2
  ,p_cmt_attribute2                 in  varchar2
  ,p_cmt_attribute20                in  varchar2
  ,p_cmt_attribute21                in  varchar2
  ,p_cmt_attribute22                in  varchar2
  ,p_cmt_attribute23                in  varchar2
  ,p_cmt_attribute24                in  varchar2
  ,p_cmt_attribute25                in  varchar2
  ,p_cmt_attribute26                in  varchar2
  ,p_cmt_attribute27                in  varchar2
  ,p_cmt_attribute28                in  varchar2
  ,p_cmt_attribute29                in  varchar2
  ,p_cmt_attribute3                 in  varchar2
  ,p_cmt_attribute30                in  varchar2
  ,p_rqd_flag                       in  varchar2
  ,p_cmt_attribute_category         in  varchar2
  ,p_cmt_attribute4                 in  varchar2
  ,p_cmt_attribute5                 in  varchar2
  ,p_cmt_attribute6                 in  varchar2
  ,p_cmt_attribute7                 in  varchar2
  ,p_cmt_attribute8                 in  varchar2
  ,p_cmt_attribute9                 in  varchar2
  ,p_dflt_flag                      in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_Comm_Dlvry_Mthds_bk1;

 

/
