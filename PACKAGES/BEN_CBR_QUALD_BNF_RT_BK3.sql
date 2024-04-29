--------------------------------------------------------
--  DDL for Package BEN_CBR_QUALD_BNF_RT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CBR_QUALD_BNF_RT_BK3" AUTHID CURRENT_USER as
/* $Header: becqrapi.pkh 120.0 2005/05/28 01:20:21 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_cbr_quald_bnf_rt_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_cbr_quald_bnf_rt_b
  (
   p_cbr_quald_bnf_rt_id            in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode                in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_cbr_quald_bnf_rt_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_CBR_QUALD_BNF_RT_a
  (
   p_cbr_quald_bnf_rt_id            in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode                in varchar2
  );
--
end ben_cbr_quald_bnf_rt_bk3;

 

/
