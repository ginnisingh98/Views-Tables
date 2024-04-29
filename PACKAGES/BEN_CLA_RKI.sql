--------------------------------------------------------
--  DDL for Package BEN_CLA_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CLA_RKI" AUTHID CURRENT_USER as
/* $Header: beclarhi.pkh 120.0 2005/05/28 01:03:27 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_cmbn_age_los_fctr_id           in number
 ,p_business_group_id              in number
 ,p_los_fctr_id                    in number
 ,p_age_fctr_id                    in number
 ,p_cmbnd_min_val                  in number
 ,p_cmbnd_max_val                  in number
 ,p_ordr_num                       in number
 ,p_cla_attribute_category         in varchar2
 ,p_cla_attribute1                 in varchar2
 ,p_cla_attribute2                 in varchar2
 ,p_cla_attribute3                 in varchar2
 ,p_cla_attribute4                 in varchar2
 ,p_cla_attribute5                 in varchar2
 ,p_cla_attribute6                 in varchar2
 ,p_cla_attribute7                 in varchar2
 ,p_cla_attribute8                 in varchar2
 ,p_cla_attribute9                 in varchar2
 ,p_cla_attribute10                in varchar2
 ,p_cla_attribute11                in varchar2
 ,p_cla_attribute12                in varchar2
 ,p_cla_attribute13                in varchar2
 ,p_cla_attribute14                in varchar2
 ,p_cla_attribute15                in varchar2
 ,p_cla_attribute16                in varchar2
 ,p_cla_attribute17                in varchar2
 ,p_cla_attribute18                in varchar2
 ,p_cla_attribute19                in varchar2
 ,p_cla_attribute20                in varchar2
 ,p_cla_attribute21                in varchar2
 ,p_cla_attribute22                in varchar2
 ,p_cla_attribute23                in varchar2
 ,p_cla_attribute24                in varchar2
 ,p_cla_attribute25                in varchar2
 ,p_cla_attribute26                in varchar2
 ,p_cla_attribute27                in varchar2
 ,p_cla_attribute28                in varchar2
 ,p_cla_attribute29                in varchar2
 ,p_cla_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_name                           in varchar2
  );
end ben_cla_rki;

 

/
