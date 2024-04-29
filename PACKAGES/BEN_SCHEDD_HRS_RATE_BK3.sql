--------------------------------------------------------
--  DDL for Package BEN_SCHEDD_HRS_RATE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_SCHEDD_HRS_RATE_BK3" AUTHID CURRENT_USER as
/* $Header: beshrapi.pkh 120.0 2005/05/28 11:51:30 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_SCHEDD_HRS_RATE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_SCHEDD_HRS_RATE_b
  (
   p_schedd_hrs_rt_id               in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_SCHEDD_HRS_RATE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_SCHEDD_HRS_RATE_a
  (
   p_schedd_hrs_rt_id               in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_SCHEDD_HRS_RATE_bk3;

 

/
