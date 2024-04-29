--------------------------------------------------------
--  DDL for Package BEN_ACTY_BASE_RT_CTFN_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ACTY_BASE_RT_CTFN_BK3" AUTHID CURRENT_USER as
/* $Header: beabcapi.pkh 120.0 2005/05/28 00:16:42 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_acty_base_rt_ctfn_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_acty_base_rt_ctfn_b
  (
   p_acty_base_rt_ctfn_id                   in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_acty_base_rt_ctfn_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_acty_base_rt_ctfn_a
  (
   p_acty_base_rt_ctfn_id                   in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_acty_base_rt_ctfn_bk3;

 

/
