--------------------------------------------------------
--  DDL for Package BEN_REG_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_REG_RKI" AUTHID CURRENT_USER as
/* $Header: beregrhi.pkh 120.0.12010000.1 2008/07/29 13:01:25 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_regn_id                        in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_name                           in varchar2
 ,p_organization_id                in number
 ,p_business_group_id              in number
 ,p_sttry_citn_name                in varchar2
 ,p_reg_attribute_category         in varchar2
 ,p_reg_attribute1                 in varchar2
 ,p_reg_attribute2                 in varchar2
 ,p_reg_attribute3                 in varchar2
 ,p_reg_attribute4                 in varchar2
 ,p_reg_attribute5                 in varchar2
 ,p_reg_attribute6                 in varchar2
 ,p_reg_attribute7                 in varchar2
 ,p_reg_attribute8                 in varchar2
 ,p_reg_attribute9                 in varchar2
 ,p_reg_attribute10                in varchar2
 ,p_reg_attribute11                in varchar2
 ,p_reg_attribute12                in varchar2
 ,p_reg_attribute13                in varchar2
 ,p_reg_attribute14                in varchar2
 ,p_reg_attribute15                in varchar2
 ,p_reg_attribute16                in varchar2
 ,p_reg_attribute17                in varchar2
 ,p_reg_attribute18                in varchar2
 ,p_reg_attribute19                in varchar2
 ,p_reg_attribute20                in varchar2
 ,p_reg_attribute21                in varchar2
 ,p_reg_attribute22                in varchar2
 ,p_reg_attribute23                in varchar2
 ,p_reg_attribute24                in varchar2
 ,p_reg_attribute25                in varchar2
 ,p_reg_attribute26                in varchar2
 ,p_reg_attribute27                in varchar2
 ,p_reg_attribute28                in varchar2
 ,p_reg_attribute29                in varchar2
 ,p_reg_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_reg_rki;

/
