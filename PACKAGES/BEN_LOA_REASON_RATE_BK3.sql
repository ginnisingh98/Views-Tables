--------------------------------------------------------
--  DDL for Package BEN_LOA_REASON_RATE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LOA_REASON_RATE_BK3" AUTHID CURRENT_USER as
/* $Header: belarapi.pkh 120.0 2005/05/28 03:14:36 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_LOA_REASON_RATE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_LOA_REASON_RATE_b
  (
   p_loa_rsn_rt_id                  in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_LOA_REASON_RATE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_LOA_REASON_RATE_a
  (
   p_loa_rsn_rt_id                  in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_LOA_REASON_RATE_bk3;

 

/
