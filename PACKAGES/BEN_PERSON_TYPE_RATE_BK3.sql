--------------------------------------------------------
--  DDL for Package BEN_PERSON_TYPE_RATE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PERSON_TYPE_RATE_BK3" AUTHID CURRENT_USER as
/* $Header: beptrapi.pkh 120.0 2005/05/28 11:23:15 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_PERSON_TYPE_RATE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PERSON_TYPE_RATE_b
  (
   p_per_typ_rt_id                  in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_PERSON_TYPE_RATE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PERSON_TYPE_RATE_a
  (
   p_per_typ_rt_id                  in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_PERSON_TYPE_RATE_bk3;

 

/
