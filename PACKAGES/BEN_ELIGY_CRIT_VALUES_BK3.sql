--------------------------------------------------------
--  DDL for Package BEN_ELIGY_CRIT_VALUES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIGY_CRIT_VALUES_BK3" AUTHID CURRENT_USER AS
/* $Header: beecvapi.pkh 120.1 2005/07/29 09:50:47 rbingi noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_eligy_crit_values_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_eligy_crit_values_b
  (
   p_eligy_crit_values_id           In  Number
  ,p_object_version_number          In  Number
  ,p_effective_date                 In  Date
  ,p_datetrack_mode                 In  Varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_eligy_crit_values_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_eligy_crit_values_a
  (
   p_eligy_crit_values_id           In  Number
  ,p_effective_start_date           In  Date
  ,p_effective_end_date             In  Date
  ,p_object_version_number          In  Number
  ,p_effective_date                 In  Date
  ,p_datetrack_mode                 In  Varchar2
  );
--
end ben_eligy_crit_values_bk3;

 

/
