--------------------------------------------------------
--  DDL for Package BEN_GOS_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_GOS_RKI" AUTHID CURRENT_USER as
/* $Header: begosrhi.pkh 120.0 2005/05/28 03:08:35 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_gd_or_svc_typ_id               in number
 ,p_business_group_id              in number
 ,p_name                           in varchar2
 ,p_typ_cd                         in varchar2
 ,p_description                    in varchar2
 ,p_gos_attribute_category         in varchar2
 ,p_gos_attribute1                 in varchar2
 ,p_gos_attribute2                 in varchar2
 ,p_gos_attribute3                 in varchar2
 ,p_gos_attribute4                 in varchar2
 ,p_gos_attribute5                 in varchar2
 ,p_gos_attribute6                 in varchar2
 ,p_gos_attribute7                 in varchar2
 ,p_gos_attribute8                 in varchar2
 ,p_gos_attribute9                 in varchar2
 ,p_gos_attribute10                in varchar2
 ,p_gos_attribute11                in varchar2
 ,p_gos_attribute12                in varchar2
 ,p_gos_attribute13                in varchar2
 ,p_gos_attribute14                in varchar2
 ,p_gos_attribute15                in varchar2
 ,p_gos_attribute16                in varchar2
 ,p_gos_attribute17                in varchar2
 ,p_gos_attribute18                in varchar2
 ,p_gos_attribute19                in varchar2
 ,p_gos_attribute20                in varchar2
 ,p_gos_attribute21                in varchar2
 ,p_gos_attribute22                in varchar2
 ,p_gos_attribute23                in varchar2
 ,p_gos_attribute24                in varchar2
 ,p_gos_attribute25                in varchar2
 ,p_gos_attribute26                in varchar2
 ,p_gos_attribute27                in varchar2
 ,p_gos_attribute28                in varchar2
 ,p_gos_attribute29                in varchar2
 ,p_gos_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
  );
end ben_gos_rki;

 

/
