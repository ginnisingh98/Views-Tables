--------------------------------------------------------
--  DDL for Package BEN_APF_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_APF_RKI" AUTHID CURRENT_USER as
/* $Header: beapfrhi.pkh 120.0.12010000.1 2008/07/29 10:49:46 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_acty_rt_pymt_sched_id          in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_pymt_sched_rl                  in number
 ,p_acty_base_rt_id                in number
 ,p_pymt_sched_cd                  in varchar2
 ,p_apf_attribute_category         in varchar2
 ,p_apf_attribute1                 in varchar2
 ,p_apf_attribute2                 in varchar2
 ,p_apf_attribute3                 in varchar2
 ,p_apf_attribute4                 in varchar2
 ,p_apf_attribute5                 in varchar2
 ,p_apf_attribute6                 in varchar2
 ,p_apf_attribute7                 in varchar2
 ,p_apf_attribute8                 in varchar2
 ,p_apf_attribute9                 in varchar2
 ,p_apf_attribute10                in varchar2
 ,p_apf_attribute11                in varchar2
 ,p_apf_attribute12                in varchar2
 ,p_apf_attribute13                in varchar2
 ,p_apf_attribute14                in varchar2
 ,p_apf_attribute15                in varchar2
 ,p_apf_attribute16                in varchar2
 ,p_apf_attribute17                in varchar2
 ,p_apf_attribute18                in varchar2
 ,p_apf_attribute19                in varchar2
 ,p_apf_attribute20                in varchar2
 ,p_apf_attribute21                in varchar2
 ,p_apf_attribute22                in varchar2
 ,p_apf_attribute23                in varchar2
 ,p_apf_attribute24                in varchar2
 ,p_apf_attribute25                in varchar2
 ,p_apf_attribute26                in varchar2
 ,p_apf_attribute27                in varchar2
 ,p_apf_attribute28                in varchar2
 ,p_apf_attribute29                in varchar2
 ,p_apf_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_apf_rki;

/
