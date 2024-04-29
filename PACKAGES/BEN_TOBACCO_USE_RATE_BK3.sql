--------------------------------------------------------
--  DDL for Package BEN_TOBACCO_USE_RATE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_TOBACCO_USE_RATE_BK3" AUTHID CURRENT_USER as
/* $Header: beturapi.pkh 120.0 2005/05/28 11:58:41 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_TOBACCO_USE_RATE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_TOBACCO_USE_RATE_b
  (
   p_tbco_use_rt_id                 in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_TOBACCO_USE_RATE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_TOBACCO_USE_RATE_a
  (
   p_tbco_use_rt_id                 in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_TOBACCO_USE_RATE_bk3;

 

/
