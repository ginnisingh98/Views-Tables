--------------------------------------------------------
--  DDL for Package BEN_ELIGIBLE_PERSON_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIGIBLE_PERSON_BK3" AUTHID CURRENT_USER as
/* $Header: bepepapi.pkh 120.0 2005/05/28 10:39:02 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Eligible_Person_b >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Eligible_Person_b
  (p_elig_per_id                    in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Eligible_Person_a >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Eligible_Person_a
  (p_elig_per_id                    in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2);
--
end ben_Eligible_Person_bk3;

 

/
