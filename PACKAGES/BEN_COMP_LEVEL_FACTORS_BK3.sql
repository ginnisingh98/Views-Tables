--------------------------------------------------------
--  DDL for Package BEN_COMP_LEVEL_FACTORS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_COMP_LEVEL_FACTORS_BK3" AUTHID CURRENT_USER as
/* $Header: beclfapi.pkh 120.0 2005/05/28 01:03:50 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_comp_level_factors_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_comp_level_factors_b
  (
   p_comp_lvl_fctr_id               in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_comp_level_factors_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_comp_level_factors_a
  (
   p_comp_lvl_fctr_id               in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_comp_level_factors_bk3;

 

/
