--------------------------------------------------------
--  DDL for Package BEN_VRBL_MATCHING_RATE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_VRBL_MATCHING_RATE_BK3" AUTHID CURRENT_USER as
/* $Header: bevmrapi.pkh 120.0 2005/05/28 12:05:30 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_VRBL_MATCHING_RATE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_VRBL_MATCHING_RATE_b
  (
   p_vrbl_mtchg_rt_id               in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_VRBL_MATCHING_RATE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_VRBL_MATCHING_RATE_a
  (
   p_vrbl_mtchg_rt_id               in  number
  ,p_effective_end_date             in  date
  ,p_effective_start_date           in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_VRBL_MATCHING_RATE_bk3;

 

/
