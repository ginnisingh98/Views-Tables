--------------------------------------------------------
--  DDL for Package BEN_ASSIGNMENT_SET_RATE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ASSIGNMENT_SET_RATE_BK3" AUTHID CURRENT_USER as
/* $Header: beasrapi.pkh 120.0 2005/05/28 00:30:12 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ASSIGNMENT_SET_RATE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ASSIGNMENT_SET_RATE_b
  (
   p_asnt_set_rt_id                 in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ASSIGNMENT_SET_RATE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ASSIGNMENT_SET_RATE_a
  (
   p_asnt_set_rt_id                 in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_ASSIGNMENT_SET_RATE_bk3;

 

/
