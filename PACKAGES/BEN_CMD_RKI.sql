--------------------------------------------------------
--  DDL for Package BEN_CMD_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CMD_RKI" AUTHID CURRENT_USER as
/* $Header: becmdrhi.pkh 120.0 2005/05/28 01:06:37 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_cm_dlvry_med_typ_id            in number
 ,p_cm_dlvry_med_typ_cd            in varchar2
 ,p_cm_dlvry_mthd_typ_id           in number
 ,p_rqd_flag                       in varchar2
 ,p_dflt_flag                      in varchar2
 ,p_business_group_id              in number
 ,p_cmd_attribute_category         in varchar2
 ,p_cmd_attribute1                 in varchar2
 ,p_cmd_attribute2                 in varchar2
 ,p_cmd_attribute3                 in varchar2
 ,p_cmd_attribute4                 in varchar2
 ,p_cmd_attribute5                 in varchar2
 ,p_cmd_attribute6                 in varchar2
 ,p_cmd_attribute7                 in varchar2
 ,p_cmd_attribute8                 in varchar2
 ,p_cmd_attribute9                 in varchar2
 ,p_cmd_attribute10                in varchar2
 ,p_cmd_attribute11                in varchar2
 ,p_cmd_attribute12                in varchar2
 ,p_cmd_attribute13                in varchar2
 ,p_cmd_attribute14                in varchar2
 ,p_cmd_attribute15                in varchar2
 ,p_cmd_attribute16                in varchar2
 ,p_cmd_attribute17                in varchar2
 ,p_cmd_attribute18                in varchar2
 ,p_cmd_attribute19                in varchar2
 ,p_cmd_attribute20                in varchar2
 ,p_cmd_attribute21                in varchar2
 ,p_cmd_attribute22                in varchar2
 ,p_cmd_attribute23                in varchar2
 ,p_cmd_attribute24                in varchar2
 ,p_cmd_attribute25                in varchar2
 ,p_cmd_attribute26                in varchar2
 ,p_cmd_attribute27                in varchar2
 ,p_cmd_attribute28                in varchar2
 ,p_cmd_attribute29                in varchar2
 ,p_cmd_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
  );
end ben_cmd_rki;

 

/
