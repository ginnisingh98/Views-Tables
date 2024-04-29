--------------------------------------------------------
--  DDL for Package BEN_PERIOD_LIMIT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PERIOD_LIMIT_BK3" AUTHID CURRENT_USER as
/* $Header: bepdlapi.pkh 120.0 2005/05/28 10:26:30 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_period_limit_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_period_limit_b
  (
   p_ptd_lmt_id                     in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_period_limit_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_period_limit_a
  (
   p_ptd_lmt_id                     in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_period_limit_bk3;

 

/
