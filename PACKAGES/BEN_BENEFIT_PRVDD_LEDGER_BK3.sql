--------------------------------------------------------
--  DDL for Package BEN_BENEFIT_PRVDD_LEDGER_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BENEFIT_PRVDD_LEDGER_BK3" AUTHID CURRENT_USER as
/* $Header: bebplapi.pkh 120.0.12000000.1 2007/01/19 01:23:08 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Benefit_Prvdd_Ledger_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Benefit_Prvdd_Ledger_b
  (
   p_bnft_prvdd_ldgr_id             in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_Benefit_Prvdd_Ledger_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Benefit_Prvdd_Ledger_a
  (
   p_bnft_prvdd_ldgr_id             in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
   ,p_datetrack_mode              in varchar2
  );
--
end ben_Benefit_Prvdd_Ledger_bk3;

 

/
