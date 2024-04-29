--------------------------------------------------------
--  DDL for Package BEN_PRTN_ELIG_PRFL_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PRTN_ELIG_PRFL_BK3" AUTHID CURRENT_USER as
/* $Header: becepapi.pkh 120.0 2005/05/28 00:59:50 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_PRTN_ELIG_PRFL_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PRTN_ELIG_PRFL_b
  (
   p_prtn_elig_prfl_id              in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_PRTN_ELIG_PRFL_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PRTN_ELIG_PRFL_a
  (
   p_prtn_elig_prfl_id              in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_PRTN_ELIG_PRFL_bk3;

 

/
