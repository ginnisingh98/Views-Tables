--------------------------------------------------------
--  DDL for Package BEN_ACTY_VRBL_RATE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ACTY_VRBL_RATE_BK3" AUTHID CURRENT_USER as
/* $Header: beavrapi.pkh 120.0 2005/05/28 00:32:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_acty_vrbl_rate_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_acty_vrbl_rate_b
  (
   p_acty_vrbl_rt_id                in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_acty_vrbl_rate_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_acty_vrbl_rate_a
  (
   p_acty_vrbl_rt_id                in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_acty_vrbl_rate_bk3;

 

/
