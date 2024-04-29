--------------------------------------------------------
--  DDL for Package BEN_BTR_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BTR_RKI" AUTHID CURRENT_USER as
/* $Header: bebtrrhi.pkh 120.0.12010000.1 2008/07/29 11:01:43 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_comp_lvl_acty_rt_id            in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_dflt_flag                      in varchar2
 ,p_comp_lvl_fctr_id               in number
 ,p_acty_base_rt_id                in number
 ,p_business_group_id              in number
 ,p_btr_attribute_category         in varchar2
 ,p_btr_attribute1                 in varchar2
 ,p_btr_attribute2                 in varchar2
 ,p_btr_attribute3                 in varchar2
 ,p_btr_attribute4                 in varchar2
 ,p_btr_attribute5                 in varchar2
 ,p_btr_attribute6                 in varchar2
 ,p_btr_attribute7                 in varchar2
 ,p_btr_attribute8                 in varchar2
 ,p_btr_attribute9                 in varchar2
 ,p_btr_attribute10                in varchar2
 ,p_btr_attribute11                in varchar2
 ,p_btr_attribute12                in varchar2
 ,p_btr_attribute13                in varchar2
 ,p_btr_attribute14                in varchar2
 ,p_btr_attribute15                in varchar2
 ,p_btr_attribute16                in varchar2
 ,p_btr_attribute17                in varchar2
 ,p_btr_attribute18                in varchar2
 ,p_btr_attribute19                in varchar2
 ,p_btr_attribute20                in varchar2
 ,p_btr_attribute21                in varchar2
 ,p_btr_attribute22                in varchar2
 ,p_btr_attribute23                in varchar2
 ,p_btr_attribute24                in varchar2
 ,p_btr_attribute25                in varchar2
 ,p_btr_attribute26                in varchar2
 ,p_btr_attribute27                in varchar2
 ,p_btr_attribute28                in varchar2
 ,p_btr_attribute29                in varchar2
 ,p_btr_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_btr_rki;

/
