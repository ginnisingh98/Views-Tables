--------------------------------------------------------
--  DDL for Package BEN_CNTNG_PRTN_ELIG_PRFL_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CNTNG_PRTN_ELIG_PRFL_BK3" AUTHID CURRENT_USER as
/* $Header: becgpapi.pkh 120.0 2005/05/28 01:01:43 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_CNTNG_PRTN_ELIG_PRFL_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_CNTNG_PRTN_ELIG_PRFL_b
  (
   p_cntng_prtn_elig_prfl_id        in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_CNTNG_PRTN_ELIG_PRFL_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_CNTNG_PRTN_ELIG_PRFL_a
  (
   p_cntng_prtn_elig_prfl_id        in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_CNTNG_PRTN_ELIG_PRFL_bk3;

 

/
