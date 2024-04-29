--------------------------------------------------------
--  DDL for Package BEN_BENEFIT_GRP_RATE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BENEFIT_GRP_RATE_BK3" AUTHID CURRENT_USER as
/* $Header: bebrgapi.pkh 120.0 2005/05/28 00:50:38 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_BENEFIT_GRP_RATE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_BENEFIT_GRP_RATE_b
  (
   p_benfts_grp_rt_id               in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_BENEFIT_GRP_RATE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_BENEFIT_GRP_RATE_a
  (
   p_benfts_grp_rt_id               in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_BENEFIT_GRP_RATE_bk3;

 

/
