--------------------------------------------------------
--  DDL for Package BEN_PSQ_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PSQ_RKI" AUTHID CURRENT_USER as
/* $Header: bepsqrhi.pkh 120.0 2005/05/28 11:20:25 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_pymt_sched_py_freq_id          in number
 ,p_py_freq_cd                     in varchar2
 ,p_dflt_flag                      in varchar2
 ,p_business_group_id              in number
 ,p_acty_rt_pymt_sched_id          in number
 ,p_psq_attribute_category         in varchar2
 ,p_psq_attribute1                 in varchar2
 ,p_psq_attribute2                 in varchar2
 ,p_psq_attribute3                 in varchar2
 ,p_psq_attribute4                 in varchar2
 ,p_psq_attribute5                 in varchar2
 ,p_psq_attribute6                 in varchar2
 ,p_psq_attribute7                 in varchar2
 ,p_psq_attribute8                 in varchar2
 ,p_psq_attribute9                 in varchar2
 ,p_psq_attribute10                in varchar2
 ,p_psq_attribute11                in varchar2
 ,p_psq_attribute12                in varchar2
 ,p_psq_attribute13                in varchar2
 ,p_psq_attribute14                in varchar2
 ,p_psq_attribute15                in varchar2
 ,p_psq_attribute16                in varchar2
 ,p_psq_attribute17                in varchar2
 ,p_psq_attribute18                in varchar2
 ,p_psq_attribute19                in varchar2
 ,p_psq_attribute20                in varchar2
 ,p_psq_attribute21                in varchar2
 ,p_psq_attribute22                in varchar2
 ,p_psq_attribute23                in varchar2
 ,p_psq_attribute24                in varchar2
 ,p_psq_attribute25                in varchar2
 ,p_psq_attribute26                in varchar2
 ,p_psq_attribute27                in varchar2
 ,p_psq_attribute28                in varchar2
 ,p_psq_attribute29                in varchar2
 ,p_psq_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
  );
end ben_psq_rki;

 

/
