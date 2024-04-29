--------------------------------------------------------
--  DDL for Package BEN_DPNT_ELIG_CRIT_VAL_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DPNT_ELIG_CRIT_VAL_BK3" AUTHID CURRENT_USER AS
/* $Header: beedvapi.pkh 120.0.12010000.4 2010/04/19 07:30:10 pvelvano noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_dpnt_eligy_crit_val_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_dpnt_eligy_crit_val_b
  (
   p_dpnt_eligy_crit_values_id           In  Number
  ,p_object_version_number          In  Number
  ,p_effective_date                 In  Date
  ,p_datetrack_mode                 In  Varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_dpnt_eligy_crit_val_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_dpnt_eligy_crit_val_a
  (
   p_dpnt_eligy_crit_values_id           In  Number
  ,p_effective_start_date           In  Date
  ,p_effective_end_date             In  Date
  ,p_object_version_number          In  Number
  ,p_effective_date                 In  Date
  ,p_datetrack_mode                 In  Varchar2
  );
--
end ben_dpnt_elig_crit_val_bk3;

/
