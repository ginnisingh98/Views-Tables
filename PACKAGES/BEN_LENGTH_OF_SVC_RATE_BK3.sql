--------------------------------------------------------
--  DDL for Package BEN_LENGTH_OF_SVC_RATE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LENGTH_OF_SVC_RATE_BK3" AUTHID CURRENT_USER as
/* $Header: belsrapi.pkh 120.0 2005/05/28 03:38:18 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_LENGTH_OF_SVC_RATE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_LENGTH_OF_SVC_RATE_b
  (
   p_los_rt_id                      in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_LENGTH_OF_SVC_RATE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_LENGTH_OF_SVC_RATE_a
  (
   p_los_rt_id                      in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_LENGTH_OF_SVC_RATE_bk3;

 

/
