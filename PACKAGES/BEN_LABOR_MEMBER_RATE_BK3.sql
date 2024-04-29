--------------------------------------------------------
--  DDL for Package BEN_LABOR_MEMBER_RATE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LABOR_MEMBER_RATE_BK3" AUTHID CURRENT_USER as
/* $Header: belmmapi.pkh 120.0 2005/05/28 03:24:32 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_LABOR_MEMBER_RATE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_LABOR_MEMBER_RATE_b
  (
   p_lbr_mmbr_rt_id                 in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_LABOR_MEMBER_RATE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_LABOR_MEMBER_RATE_a
  (
   p_lbr_mmbr_rt_id                 in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_LABOR_MEMBER_RATE_bk3;

 

/
