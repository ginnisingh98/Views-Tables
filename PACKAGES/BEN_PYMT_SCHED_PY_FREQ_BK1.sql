--------------------------------------------------------
--  DDL for Package BEN_PYMT_SCHED_PY_FREQ_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PYMT_SCHED_PY_FREQ_BK1" AUTHID CURRENT_USER as
/* $Header: bepsqapi.pkh 120.0 2005/05/28 11:19:54 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_pymt_sched_py_freq_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_pymt_sched_py_freq_b
  (
   p_py_freq_cd                     in  varchar2
  ,p_dflt_flag                      in  varchar2
  ,p_business_group_id              in  number
  ,p_acty_rt_pymt_sched_id          in  number
  ,p_psq_attribute_category         in  varchar2
  ,p_psq_attribute1                 in  varchar2
  ,p_psq_attribute2                 in  varchar2
  ,p_psq_attribute3                 in  varchar2
  ,p_psq_attribute4                 in  varchar2
  ,p_psq_attribute5                 in  varchar2
  ,p_psq_attribute6                 in  varchar2
  ,p_psq_attribute7                 in  varchar2
  ,p_psq_attribute8                 in  varchar2
  ,p_psq_attribute9                 in  varchar2
  ,p_psq_attribute10                in  varchar2
  ,p_psq_attribute11                in  varchar2
  ,p_psq_attribute12                in  varchar2
  ,p_psq_attribute13                in  varchar2
  ,p_psq_attribute14                in  varchar2
  ,p_psq_attribute15                in  varchar2
  ,p_psq_attribute16                in  varchar2
  ,p_psq_attribute17                in  varchar2
  ,p_psq_attribute18                in  varchar2
  ,p_psq_attribute19                in  varchar2
  ,p_psq_attribute20                in  varchar2
  ,p_psq_attribute21                in  varchar2
  ,p_psq_attribute22                in  varchar2
  ,p_psq_attribute23                in  varchar2
  ,p_psq_attribute24                in  varchar2
  ,p_psq_attribute25                in  varchar2
  ,p_psq_attribute26                in  varchar2
  ,p_psq_attribute27                in  varchar2
  ,p_psq_attribute28                in  varchar2
  ,p_psq_attribute29                in  varchar2
  ,p_psq_attribute30                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_pymt_sched_py_freq_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_pymt_sched_py_freq_a
  (
   p_pymt_sched_py_freq_id          in  number
  ,p_py_freq_cd                     in  varchar2
  ,p_dflt_flag                      in  varchar2
  ,p_business_group_id              in  number
  ,p_acty_rt_pymt_sched_id          in  number
  ,p_psq_attribute_category         in  varchar2
  ,p_psq_attribute1                 in  varchar2
  ,p_psq_attribute2                 in  varchar2
  ,p_psq_attribute3                 in  varchar2
  ,p_psq_attribute4                 in  varchar2
  ,p_psq_attribute5                 in  varchar2
  ,p_psq_attribute6                 in  varchar2
  ,p_psq_attribute7                 in  varchar2
  ,p_psq_attribute8                 in  varchar2
  ,p_psq_attribute9                 in  varchar2
  ,p_psq_attribute10                in  varchar2
  ,p_psq_attribute11                in  varchar2
  ,p_psq_attribute12                in  varchar2
  ,p_psq_attribute13                in  varchar2
  ,p_psq_attribute14                in  varchar2
  ,p_psq_attribute15                in  varchar2
  ,p_psq_attribute16                in  varchar2
  ,p_psq_attribute17                in  varchar2
  ,p_psq_attribute18                in  varchar2
  ,p_psq_attribute19                in  varchar2
  ,p_psq_attribute20                in  varchar2
  ,p_psq_attribute21                in  varchar2
  ,p_psq_attribute22                in  varchar2
  ,p_psq_attribute23                in  varchar2
  ,p_psq_attribute24                in  varchar2
  ,p_psq_attribute25                in  varchar2
  ,p_psq_attribute26                in  varchar2
  ,p_psq_attribute27                in  varchar2
  ,p_psq_attribute28                in  varchar2
  ,p_psq_attribute29                in  varchar2
  ,p_psq_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_pymt_sched_py_freq_bk1;

 

/
