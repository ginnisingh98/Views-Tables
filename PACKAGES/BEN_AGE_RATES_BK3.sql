--------------------------------------------------------
--  DDL for Package BEN_AGE_RATES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_AGE_RATES_BK3" AUTHID CURRENT_USER as
/* $Header: beartapi.pkh 120.0 2005/05/28 00:28:27 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_age_rates_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_age_rates_b
  (
   p_age_rt_id                      in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_age_rates_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_age_rates_a
  (
   p_age_rt_id                      in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_age_rates_bk3;

 

/
