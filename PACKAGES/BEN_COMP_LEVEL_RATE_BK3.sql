--------------------------------------------------------
--  DDL for Package BEN_COMP_LEVEL_RATE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_COMP_LEVEL_RATE_BK3" AUTHID CURRENT_USER as
/* $Header: beclrapi.pkh 120.0 2005/05/28 01:05:31 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_COMP_LEVEL_RATE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_COMP_LEVEL_RATE_b
  (
   p_comp_lvl_rt_id                 in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_COMP_LEVEL_RATE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_COMP_LEVEL_RATE_a
  (
   p_comp_lvl_rt_id                 in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_COMP_LEVEL_RATE_bk3;

 

/
