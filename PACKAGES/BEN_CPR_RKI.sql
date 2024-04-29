--------------------------------------------------------
--  DDL for Package BEN_CPR_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CPR_RKI" AUTHID CURRENT_USER as
/* $Header: becprrhi.pkh 120.0 2005/05/28 01:17:44 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_popl_org_role_id               in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_name                           in varchar2
 ,p_org_role_typ_cd                in varchar2
 ,p_popl_org_id                    in number
 ,p_business_group_id              in number
 ,p_cpr_attribute_category         in varchar2
 ,p_cpr_attribute1                 in varchar2
 ,p_cpr_attribute2                 in varchar2
 ,p_cpr_attribute3                 in varchar2
 ,p_cpr_attribute4                 in varchar2
 ,p_cpr_attribute5                 in varchar2
 ,p_cpr_attribute6                 in varchar2
 ,p_cpr_attribute7                 in varchar2
 ,p_cpr_attribute8                 in varchar2
 ,p_cpr_attribute9                 in varchar2
 ,p_cpr_attribute10                in varchar2
 ,p_cpr_attribute11                in varchar2
 ,p_cpr_attribute12                in varchar2
 ,p_cpr_attribute13                in varchar2
 ,p_cpr_attribute14                in varchar2
 ,p_cpr_attribute15                in varchar2
 ,p_cpr_attribute16                in varchar2
 ,p_cpr_attribute17                in varchar2
 ,p_cpr_attribute18                in varchar2
 ,p_cpr_attribute19                in varchar2
 ,p_cpr_attribute20                in varchar2
 ,p_cpr_attribute21                in varchar2
 ,p_cpr_attribute22                in varchar2
 ,p_cpr_attribute23                in varchar2
 ,p_cpr_attribute24                in varchar2
 ,p_cpr_attribute25                in varchar2
 ,p_cpr_attribute26                in varchar2
 ,p_cpr_attribute27                in varchar2
 ,p_cpr_attribute28                in varchar2
 ,p_cpr_attribute29                in varchar2
 ,p_cpr_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_cpr_rki;

 

/
