--------------------------------------------------------
--  DDL for Package BEN_DSQ_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DSQ_RKI" AUTHID CURRENT_USER as
/* $Header: bedsqrhi.pkh 120.0 2005/05/28 01:41:14 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_ded_sched_py_freq_id           in number
 ,p_py_freq_cd                     in varchar2
 ,p_dflt_flag                      in varchar2
 ,p_acty_rt_ded_sched_id           in number
 ,p_business_group_id              in number
 ,p_dsq_attribute_category         in varchar2
 ,p_dsq_attribute1                 in varchar2
 ,p_dsq_attribute2                 in varchar2
 ,p_dsq_attribute3                 in varchar2
 ,p_dsq_attribute4                 in varchar2
 ,p_dsq_attribute5                 in varchar2
 ,p_dsq_attribute6                 in varchar2
 ,p_dsq_attribute7                 in varchar2
 ,p_dsq_attribute8                 in varchar2
 ,p_dsq_attribute9                 in varchar2
 ,p_dsq_attribute10                in varchar2
 ,p_dsq_attribute11                in varchar2
 ,p_dsq_attribute12                in varchar2
 ,p_dsq_attribute13                in varchar2
 ,p_dsq_attribute14                in varchar2
 ,p_dsq_attribute15                in varchar2
 ,p_dsq_attribute16                in varchar2
 ,p_dsq_attribute17                in varchar2
 ,p_dsq_attribute18                in varchar2
 ,p_dsq_attribute19                in varchar2
 ,p_dsq_attribute20                in varchar2
 ,p_dsq_attribute21                in varchar2
 ,p_dsq_attribute22                in varchar2
 ,p_dsq_attribute23                in varchar2
 ,p_dsq_attribute24                in varchar2
 ,p_dsq_attribute25                in varchar2
 ,p_dsq_attribute26                in varchar2
 ,p_dsq_attribute27                in varchar2
 ,p_dsq_attribute28                in varchar2
 ,p_dsq_attribute29                in varchar2
 ,p_dsq_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
  );
end ben_dsq_rki;

 

/
