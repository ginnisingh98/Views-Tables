--------------------------------------------------------
--  DDL for Package BEN_OPTION_IN_PLAN_IN_PGM_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_OPTION_IN_PLAN_IN_PGM_BK3" AUTHID CURRENT_USER as
/* $Header: beoppapi.pkh 120.0 2005/05/28 09:54:05 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_option_in_plan_in_pgm_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_option_in_plan_in_pgm_b
  (
   p_oiplip_id                      in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_option_in_plan_in_pgm_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_option_in_plan_in_pgm_a
  (
   p_oiplip_id                      in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_option_in_plan_in_pgm_bk3;

 

/
