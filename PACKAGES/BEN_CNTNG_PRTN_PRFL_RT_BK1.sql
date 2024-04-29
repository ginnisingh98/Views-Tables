--------------------------------------------------------
--  DDL for Package BEN_CNTNG_PRTN_PRFL_RT_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CNTNG_PRTN_PRFL_RT_BK1" AUTHID CURRENT_USER as
/* $Header: becpnapi.pkh 120.0 2005/05/28 01:15:05 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_cntng_prtn_prfl_rt_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_cntng_prtn_prfl_rt_b
  (
   p_vrbl_rt_prfl_id                  in  number
  ,p_name                           in  varchar2
  ,p_pymt_must_be_rcvd_uom          in  varchar2
  ,p_pymt_must_be_rcvd_num          in  number
  ,p_pymt_must_be_rcvd_rl           in  number
  ,p_business_group_id              in  number
  ,p_cpn_attribute_category         in  varchar2
  ,p_cpn_attribute1                 in  varchar2
  ,p_cpn_attribute2                 in  varchar2
  ,p_cpn_attribute3                 in  varchar2
  ,p_cpn_attribute4                 in  varchar2
  ,p_cpn_attribute5                 in  varchar2
  ,p_cpn_attribute6                 in  varchar2
  ,p_cpn_attribute7                 in  varchar2
  ,p_cpn_attribute8                 in  varchar2
  ,p_cpn_attribute9                 in  varchar2
  ,p_cpn_attribute10                in  varchar2
  ,p_cpn_attribute11                in  varchar2
  ,p_cpn_attribute12                in  varchar2
  ,p_cpn_attribute13                in  varchar2
  ,p_cpn_attribute14                in  varchar2
  ,p_cpn_attribute15                in  varchar2
  ,p_cpn_attribute16                in  varchar2
  ,p_cpn_attribute17                in  varchar2
  ,p_cpn_attribute18                in  varchar2
  ,p_cpn_attribute19                in  varchar2
  ,p_cpn_attribute20                in  varchar2
  ,p_cpn_attribute21                in  varchar2
  ,p_cpn_attribute22                in  varchar2
  ,p_cpn_attribute23                in  varchar2
  ,p_cpn_attribute24                in  varchar2
  ,p_cpn_attribute25                in  varchar2
  ,p_cpn_attribute26                in  varchar2
  ,p_cpn_attribute27                in  varchar2
  ,p_cpn_attribute28                in  varchar2
  ,p_cpn_attribute29                in  varchar2
  ,p_cpn_attribute30                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_cntng_prtn_prfl_rt_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_cntng_prtn_prfl_rt_a
  (
   p_cntng_prtn_prfl_rt_id        in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_vrbl_rt_prfl_id                  in  number
  ,p_name                           in  varchar2
  ,p_pymt_must_be_rcvd_uom          in  varchar2
  ,p_pymt_must_be_rcvd_num          in  number
  ,p_pymt_must_be_rcvd_rl           in  number
  ,p_business_group_id              in  number
  ,p_cpn_attribute_category         in  varchar2
  ,p_cpn_attribute1                 in  varchar2
  ,p_cpn_attribute2                 in  varchar2
  ,p_cpn_attribute3                 in  varchar2
  ,p_cpn_attribute4                 in  varchar2
  ,p_cpn_attribute5                 in  varchar2
  ,p_cpn_attribute6                 in  varchar2
  ,p_cpn_attribute7                 in  varchar2
  ,p_cpn_attribute8                 in  varchar2
  ,p_cpn_attribute9                 in  varchar2
  ,p_cpn_attribute10                in  varchar2
  ,p_cpn_attribute11                in  varchar2
  ,p_cpn_attribute12                in  varchar2
  ,p_cpn_attribute13                in  varchar2
  ,p_cpn_attribute14                in  varchar2
  ,p_cpn_attribute15                in  varchar2
  ,p_cpn_attribute16                in  varchar2
  ,p_cpn_attribute17                in  varchar2
  ,p_cpn_attribute18                in  varchar2
  ,p_cpn_attribute19                in  varchar2
  ,p_cpn_attribute20                in  varchar2
  ,p_cpn_attribute21                in  varchar2
  ,p_cpn_attribute22                in  varchar2
  ,p_cpn_attribute23                in  varchar2
  ,p_cpn_attribute24                in  varchar2
  ,p_cpn_attribute25                in  varchar2
  ,p_cpn_attribute26                in  varchar2
  ,p_cpn_attribute27                in  varchar2
  ,p_cpn_attribute28                in  varchar2
  ,p_cpn_attribute29                in  varchar2
  ,p_cpn_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_cntng_prtn_prfl_rt_bk1;

 

/
