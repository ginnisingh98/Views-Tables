--------------------------------------------------------
--  DDL for Package BEN_ELIG_CBR_QUALD_BNF_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_CBR_QUALD_BNF_BK3" AUTHID CURRENT_USER as
/* $Header: beecqapi.pkh 120.0 2005/05/28 01:52:08 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ELIG_CBR_QUALD_BNF_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELIG_CBR_QUALD_BNF_b
  (
   p_elig_cbr_quald_bnf_id          in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ELIG_CBR_QUALD_BNF_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELIG_CBR_QUALD_BNF_a
  (
   p_elig_cbr_quald_bnf_id          in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_ELIG_CBR_QUALD_BNF_bk3;

 

/
