--------------------------------------------------------
--  DDL for Package BEN_PEOPLE_GROUP_RATE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PEOPLE_GROUP_RATE_BK3" AUTHID CURRENT_USER as
/* $Header: bepgrapi.pkh 120.0 2005/05/28 10:48:28 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_PEOPLE_GROUP_RATE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PEOPLE_GROUP_RATE_b
  (
   p_ppl_grp_rt_id                  in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_PEOPLE_GROUP_RATE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PEOPLE_GROUP_RATE_a
  (
   p_ppl_grp_rt_id                  in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_PEOPLE_GROUP_RATE_bk3;

 

/
