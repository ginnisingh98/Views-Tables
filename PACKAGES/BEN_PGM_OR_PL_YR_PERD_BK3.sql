--------------------------------------------------------
--  DDL for Package BEN_PGM_OR_PL_YR_PERD_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PGM_OR_PL_YR_PERD_BK3" AUTHID CURRENT_USER as
/* $Header: beyrpapi.pkh 120.0 2005/05/28 12:44:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_pgm_or_pl_yr_perd_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pgm_or_pl_yr_perd_b
  (
   p_yr_perd_id                     in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_pgm_or_pl_yr_perd_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pgm_or_pl_yr_perd_a
  (
   p_yr_perd_id                     in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_pgm_or_pl_yr_perd_bk3;

 

/
