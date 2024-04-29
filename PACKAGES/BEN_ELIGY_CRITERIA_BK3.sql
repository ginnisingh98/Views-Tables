--------------------------------------------------------
--  DDL for Package BEN_ELIGY_CRITERIA_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIGY_CRITERIA_BK3" as

--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_eligy_criteria_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_eligy_criteria_b
  (
   p_eligy_criteria_id              in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_eligy_criteria_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_eligy_criteria_a
  (
   p_eligy_criteria_id              in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_eligy_criteria_bk3;

 

/
