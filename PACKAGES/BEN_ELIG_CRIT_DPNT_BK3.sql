--------------------------------------------------------
--  DDL for Package BEN_ELIG_CRIT_DPNT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_CRIT_DPNT_BK3" AUTHID CURRENT_USER as

--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_dpnt_eligy_criteria_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_dpnt_eligy_criteria_b
  (
   p_eligy_criteria_dpnt_id              in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_dpnt_eligy_criteria_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_dpnt_eligy_criteria_a
  (
   p_eligy_criteria_dpnt_id              in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_elig_crit_dpnt_bk3;

/
