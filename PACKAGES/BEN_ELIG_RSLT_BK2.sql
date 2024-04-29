--------------------------------------------------------
--  DDL for Package BEN_ELIG_RSLT_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_RSLT_BK2" AUTHID CURRENT_USER as
/* $Header: beberapi.pkh 120.0 2005/05/28 00:39:55 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ELIG_RSLT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIG_RSLT_b
  (
   p_elig_rslt_id               in  number
  ,p_business_group_id              in  number
  ,p_elig_obj_id                    in  number
  ,p_person_id                      in  number
  ,p_assignment_id                  in  number
  ,p_elig_flag                      in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ELIG_RSLT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIG_RSLT_a
  (
   p_elig_rslt_id               in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_business_group_id              in  number
  ,p_elig_obj_id                    in  number
  ,p_person_id                      in  number
  ,p_assignment_id                  in  number
  ,p_elig_flag                      in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_ELIG_RSLT_bk2;

 

/
