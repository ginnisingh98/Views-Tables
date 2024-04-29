--------------------------------------------------------
--  DDL for Package BEN_MATCHING_RATES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_MATCHING_RATES_BK3" AUTHID CURRENT_USER as
/* $Header: bemtrapi.pkh 120.0 2005/05/28 03:39:53 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_MATCHING_RATES_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_MATCHING_RATES_b
  (
   p_mtchg_rt_id                    in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_MATCHING_RATES_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_MATCHING_RATES_a
  (
   p_mtchg_rt_id                    in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_MATCHING_RATES_bk3;

 

/
