--------------------------------------------------------
--  DDL for Package BEN_CNTNG_PRTN_ELIG_PRFL_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CNTNG_PRTN_ELIG_PRFL_BK1" AUTHID CURRENT_USER as
/* $Header: becgpapi.pkh 120.0 2005/05/28 01:01:43 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_CNTNG_PRTN_ELIG_PRFL_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_CNTNG_PRTN_ELIG_PRFL_b
  (
   p_eligy_prfl_id                  in  number
  ,p_name                           in  varchar2
  ,p_pymt_must_be_rcvd_uom          in  varchar2
  ,p_pymt_must_be_rcvd_num          in  number
  ,p_pymt_must_be_rcvd_rl           in  number
  ,p_business_group_id              in  number
  ,p_cgp_attribute_category         in  varchar2
  ,p_cgp_attribute1                 in  varchar2
  ,p_cgp_attribute2                 in  varchar2
  ,p_cgp_attribute3                 in  varchar2
  ,p_cgp_attribute4                 in  varchar2
  ,p_cgp_attribute5                 in  varchar2
  ,p_cgp_attribute6                 in  varchar2
  ,p_cgp_attribute7                 in  varchar2
  ,p_cgp_attribute8                 in  varchar2
  ,p_cgp_attribute9                 in  varchar2
  ,p_cgp_attribute10                in  varchar2
  ,p_cgp_attribute11                in  varchar2
  ,p_cgp_attribute12                in  varchar2
  ,p_cgp_attribute13                in  varchar2
  ,p_cgp_attribute14                in  varchar2
  ,p_cgp_attribute15                in  varchar2
  ,p_cgp_attribute16                in  varchar2
  ,p_cgp_attribute17                in  varchar2
  ,p_cgp_attribute18                in  varchar2
  ,p_cgp_attribute19                in  varchar2
  ,p_cgp_attribute20                in  varchar2
  ,p_cgp_attribute21                in  varchar2
  ,p_cgp_attribute22                in  varchar2
  ,p_cgp_attribute23                in  varchar2
  ,p_cgp_attribute24                in  varchar2
  ,p_cgp_attribute25                in  varchar2
  ,p_cgp_attribute26                in  varchar2
  ,p_cgp_attribute27                in  varchar2
  ,p_cgp_attribute28                in  varchar2
  ,p_cgp_attribute29                in  varchar2
  ,p_cgp_attribute30                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_CNTNG_PRTN_ELIG_PRFL_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_CNTNG_PRTN_ELIG_PRFL_a
  (
   p_cntng_prtn_elig_prfl_id        in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_eligy_prfl_id                  in  number
  ,p_name                           in  varchar2
  ,p_pymt_must_be_rcvd_uom          in  varchar2
  ,p_pymt_must_be_rcvd_num          in  number
  ,p_pymt_must_be_rcvd_rl           in  number
  ,p_business_group_id              in  number
  ,p_cgp_attribute_category         in  varchar2
  ,p_cgp_attribute1                 in  varchar2
  ,p_cgp_attribute2                 in  varchar2
  ,p_cgp_attribute3                 in  varchar2
  ,p_cgp_attribute4                 in  varchar2
  ,p_cgp_attribute5                 in  varchar2
  ,p_cgp_attribute6                 in  varchar2
  ,p_cgp_attribute7                 in  varchar2
  ,p_cgp_attribute8                 in  varchar2
  ,p_cgp_attribute9                 in  varchar2
  ,p_cgp_attribute10                in  varchar2
  ,p_cgp_attribute11                in  varchar2
  ,p_cgp_attribute12                in  varchar2
  ,p_cgp_attribute13                in  varchar2
  ,p_cgp_attribute14                in  varchar2
  ,p_cgp_attribute15                in  varchar2
  ,p_cgp_attribute16                in  varchar2
  ,p_cgp_attribute17                in  varchar2
  ,p_cgp_attribute18                in  varchar2
  ,p_cgp_attribute19                in  varchar2
  ,p_cgp_attribute20                in  varchar2
  ,p_cgp_attribute21                in  varchar2
  ,p_cgp_attribute22                in  varchar2
  ,p_cgp_attribute23                in  varchar2
  ,p_cgp_attribute24                in  varchar2
  ,p_cgp_attribute25                in  varchar2
  ,p_cgp_attribute26                in  varchar2
  ,p_cgp_attribute27                in  varchar2
  ,p_cgp_attribute28                in  varchar2
  ,p_cgp_attribute29                in  varchar2
  ,p_cgp_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_CNTNG_PRTN_ELIG_PRFL_bk1;

 

/
