--------------------------------------------------------
--  DDL for Package BEN_ELIGY_PROFILE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIGY_PROFILE_BK3" AUTHID CURRENT_USER as
/* $Header: beelpapi.pkh 120.0 2005/05/28 02:19:53 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ELIGY_PROFILE_b >---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELIGY_PROFILE_b
  (p_eligy_prfl_id                  in number
  ,p_object_version_number          in number
  ,p_effective_date                 in date
  ,p_datetrack_mode                 in varchar2);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ELIGY_PROFILE_a >---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELIGY_PROFILE_a
  (p_eligy_prfl_id                  in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2);
--
end ben_ELIGY_PROFILE_bk3;

 

/
