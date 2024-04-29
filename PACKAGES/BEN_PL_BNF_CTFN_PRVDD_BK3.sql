--------------------------------------------------------
--  DDL for Package BEN_PL_BNF_CTFN_PRVDD_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PL_BNF_CTFN_PRVDD_BK3" AUTHID CURRENT_USER as
/* $Header: bepbcapi.pkh 120.0 2005/05/28 10:04:28 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_PL_BNF_CTFN_PRVDD_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PL_BNF_CTFN_PRVDD_b
  (
   p_pl_bnf_ctfn_prvdd_id           in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_PL_BNF_CTFN_PRVDD_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PL_BNF_CTFN_PRVDD_a
  (
   p_pl_bnf_ctfn_prvdd_id           in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_PL_BNF_CTFN_PRVDD_bk3;

 

/
