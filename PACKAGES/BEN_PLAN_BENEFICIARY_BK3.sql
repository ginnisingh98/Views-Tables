--------------------------------------------------------
--  DDL for Package BEN_PLAN_BENEFICIARY_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PLAN_BENEFICIARY_BK3" AUTHID CURRENT_USER as
/* $Header: bepbnapi.pkh 115.8 2000/08/21 19:15:57 pkm ship      $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_PLAN_BENEFICIARY_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PLAN_BENEFICIARY_b
  (
   p_pl_bnf_id                      in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_PLAN_BENEFICIARY_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_PLAN_BENEFICIARY_a
  (
   p_pl_bnf_id                      in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_PLAN_BENEFICIARY_bk3;
--

 

/
