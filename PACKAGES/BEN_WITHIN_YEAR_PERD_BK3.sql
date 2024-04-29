--------------------------------------------------------
--  DDL for Package BEN_WITHIN_YEAR_PERD_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_WITHIN_YEAR_PERD_BK3" AUTHID CURRENT_USER as
/* $Header: bewypapi.pkh 120.0 2005/05/28 12:21:12 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_WITHIN_YEAR_PERD_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_WITHIN_YEAR_PERD_b
  (
   p_wthn_yr_perd_id                in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_WITHIN_YEAR_PERD_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_WITHIN_YEAR_PERD_a
  (
   p_wthn_yr_perd_id                in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_WITHIN_YEAR_PERD_bk3;

 

/
