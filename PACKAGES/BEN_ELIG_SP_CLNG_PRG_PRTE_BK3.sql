--------------------------------------------------------
--  DDL for Package BEN_ELIG_SP_CLNG_PRG_PRTE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_SP_CLNG_PRG_PRTE_BK3" AUTHID CURRENT_USER as
/* $Header: beespapi.pkh 120.0 2005/05/28 02:57:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ELIG_SP_CLNG_PRG_PRTE_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_elig_sp_clng_prg_prte_b
  (
   p_elig_sp_clng_prg_prte_id     in  number
  ,p_object_version_number        in  number
  ,p_effective_date               in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ELIG_SP_CLNG_PRG_PRTE_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_elig_sp_clng_prg_prte_a
  (
   p_elig_sp_clng_prg_prte_id       in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_elig_sp_clng_prg_prte_bk3;

 

/
