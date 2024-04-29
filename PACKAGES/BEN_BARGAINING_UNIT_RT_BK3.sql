--------------------------------------------------------
--  DDL for Package BEN_BARGAINING_UNIT_RT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BARGAINING_UNIT_RT_BK3" AUTHID CURRENT_USER as
/* $Header: beburapi.pkh 120.0 2005/05/28 00:53:43 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_BARGAINING_UNIT_RT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_BARGAINING_UNIT_RT_b
  (
   p_brgng_unit_rt_id               in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_BARGAINING_UNIT_RT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_BARGAINING_UNIT_RT_a
  (
   p_brgng_unit_rt_id               in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_BARGAINING_UNIT_RT_bk3;

 

/
