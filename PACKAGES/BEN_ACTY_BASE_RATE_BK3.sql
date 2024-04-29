--------------------------------------------------------
--  DDL for Package BEN_ACTY_BASE_RATE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ACTY_BASE_RATE_BK3" AUTHID CURRENT_USER as
/* $Header: beabrapi.pkh 120.3 2006/01/19 07:56:21 swjain noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_acty_base_rate_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_acty_base_rate_b
  (
   p_acty_base_rt_id                in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_acty_base_rate_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_acty_base_rate_a
  (
   p_acty_base_rt_id                in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_acty_base_rate_bk3;

 

/
