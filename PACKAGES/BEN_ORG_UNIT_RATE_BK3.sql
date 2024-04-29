--------------------------------------------------------
--  DDL for Package BEN_ORG_UNIT_RATE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ORG_UNIT_RATE_BK3" AUTHID CURRENT_USER as
/* $Header: beourapi.pkh 120.0 2005/05/28 09:59:00 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ORG_UNIT_RATE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ORG_UNIT_RATE_b
  (
   p_org_unit_rt_id                 in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ORG_UNIT_RATE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ORG_UNIT_RATE_a
  (
   p_org_unit_rt_id                 in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_ORG_UNIT_RATE_bk3;

 

/
