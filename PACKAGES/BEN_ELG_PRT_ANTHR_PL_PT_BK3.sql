--------------------------------------------------------
--  DDL for Package BEN_ELG_PRT_ANTHR_PL_PT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELG_PRT_ANTHR_PL_PT_BK3" AUTHID CURRENT_USER as
/* $Header: beeppapi.pkh 120.0 2005/05/28 02:42:59 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ELG_PRT_ANTHR_PL_PT_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELG_PRT_ANTHR_PL_PT_b
  (
   p_elig_prtt_anthr_pl_prte_id     in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ELG_PRT_ANTHR_PL_PT_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELG_PRT_ANTHR_PL_PT_a
  (
   p_elig_prtt_anthr_pl_prte_id     in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_ELG_PRT_ANTHR_PL_PT_bk3;

 

/
