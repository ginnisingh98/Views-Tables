--------------------------------------------------------
--  DDL for Package BEN_CNTNG_PRTN_PRFL_RT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CNTNG_PRTN_PRFL_RT_BK3" AUTHID CURRENT_USER as
/* $Header: becpnapi.pkh 120.0 2005/05/28 01:15:05 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_cntng_prtn_prfl_rt_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_cntng_prtn_prfl_rt_b
  (
   p_cntng_prtn_prfl_rt_id        in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_cntng_prtn_prfl_rt_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_cntng_prtn_prfl_rt_a
  (
   p_cntng_prtn_prfl_rt_id        in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_cntng_prtn_prfl_rt_bk3;

 

/
